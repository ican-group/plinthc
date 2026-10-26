#!/usr/bin/env bash
# Golden tests for Plinth compile-time error messages.
#
# Note [Error message golden tests]
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Each cases/<Name>.hs uses one Haskell construct that Plinth does not
# support. This script compiles each case with plinthc, expects the
# compilation to fail, and compares the normalized compiler output with
# golden/<GHC major.minor>/<Name>.stderr (e.g. golden/9.12/): the Core in the
# Context frames and some module names (GHC.Internal.* since GHC 9.10)
# depend on the GHC version.
#
# A case whose first lines contain "-- EXPECT: ok" must compile without
# any diagnostic: it pins down what the Plinth check must accept.
# "-- EXPECT: ok-gate" must compile in gate mode only.
#
# The suite runs in two modes:
#   gate    (default) the Plinth check of the type checker rejects the
#           code; goldens in golden/<series>/;
#   nogate  -fno-plinth-gate: the plugin's Core to PIR compile rejects
#           the code; goldens in golden/<series>/nogate/. This is the
#           fallback path (defer-errors) and its messages must stay useful.
# MODES="gate" restricts the run.
#
# The plutus-tx-plugin golden tests only cover the defer-errors path,
# which drops the source location and the source snippet. These tests
# capture the real user-facing output, so changes to error reporting and
# to source-location tracking show up as golden diffs here.
#
# Files named *Helper.hs are companion modules, not test cases. Modules
# in cases/prebuilt/ are compiled first, with -fno-plinth-status, to
# stand for a library built without the Plinth check.
#
# Usage:
#   GHC=/path/to/plinthc ./run-error-tests.sh          # run tests
#   GHC=/path/to/plinthc ACCEPT=1 ./run-error-tests.sh # update goldens
#
# The package databases come from the plinth/test build tree, so run
# plinthc-test.sh (or at least its build step) first.

set -uo pipefail

HERE=$(cd "$(dirname "$0")" && pwd)
TEST_ROOT=$(cd "$HERE/.." && pwd)

: ${GHC:=$TEST_ROOT/../../ghc/_build/stage1/bin/plinthc}
: ${ACCEPT:=0}
: ${MODES:="gate nogate"}

if [ ! -x "$GHC" ]; then
  echo "error: plinthc not found ($GHC). Run plinthc-build.sh first," >&2
  echo "or set GHC to an installed plinthc." >&2
  exit 2
fi

VERSION=$("$GHC" --numeric-version)
GHC_SERIES=$(echo "$VERSION" | cut -d. -f1-2)
GOLDEN_DIR="$HERE/golden/$GHC_SERIES"
# cabal names the store directory after the compiler's "Project Unit Id":
# ghc-<ver>-plinthc with GHC 9.6, ghc-<ver>-inplace-plinthc with GHC 9.12.
UNIT_ID=$("$GHC" --info | sed -n 's/.*("Project Unit Id","\([^"]*\)").*/\1/p')
STORE_DB="$TEST_ROOT/_build/store/$UNIT_ID/package.db"
INPLACE_DB="$TEST_ROOT/_build/build/packagedb/ghc-$VERSION"

for db in "$STORE_DB" "$INPLACE_DB"; do
  if [ ! -d "$db" ]; then
    echo "error: package database not found: $db" >&2
    echo "Build the plinth/test project first (plinthc-test.sh)." >&2
    exit 2
  fi
done

# The unit id of the plutus-tx library itself. Since GHC 9.10, its public
# sublibrary plutus-tx-testlib is also listed under the package name
# plutus-tx, so "-package plutus-tx" can pick the sublibrary instead.
PLUTUS_TX_ID=$(cd "$INPLACE_DB" && ls plutus-tx-[0-9]*-inplace.conf | sed 's/\.conf$//')

OUTDIR=$(mktemp -d)
trap 'rm -rf "$OUTDIR"' EXIT

# The flag set of a regular Plinth project (see plinth-test.cabal,
# common plinth-options), plus preserve-source-locations: these tests
# exist to pin down how much source-location information the errors
# carry, so the location machinery must be on.
GHC_ARGS=(
  -package-db "$STORE_DB"
  -package-db "$INPLACE_DB"
  -hide-all-packages
  -package base
  -package containers
  -package-id "$PLUTUS_TX_ID"
  -package text
  -package bytestring
  -fplugin-opt "Plinth.Plugin:target-version=1.1.0"
  -fplugin-opt "Plinth.Plugin:preserve-source-locations"
  -fno-full-laziness -fno-spec-constr
  -fno-specialise -fno-strictness -fno-unbox-small-strict-fields
  -fno-unbox-strict-fields
  -fforce-recomp
  -fhide-source-paths
  -fdiagnostics-color=never
)

# Normalize compiler output so the goldens are stable:
#  - strip ANSI escape sequences (the source snippet uses colors);
#  - strip GHC uniques from Core dumps in Context frames
#    (e.g. "x_a5GN" -> "x", "wild_X0" -> "wild");
#  - drop GHC --make progress lines ("[1 of 2] Compiling ...");
#  - drop CRs (Windows).
# POSIX sed only: BSD sed (macOS) has no \b, \x1b or \r escapes. The
# unique pattern needs no trailing \b: the greedy [0-9a-zA-Z]* always
# ends at a non-alphanumeric character.
ESC=$(printf '\033')
CR=$(printf '\r')
normalize () {
  sed -e "s/${ESC}\\[[0-9;]*m//g" \
      -e 's/_[a-zA-Z][0-9][0-9a-zA-Z]*//g' \
      -e '/^\[ *[0-9][0-9]* of [0-9][0-9]*\]/d' \
      -e "s/${CR}\$//"
}

failures=0
total=0

cd "$HERE/cases"

# The prebuilt modules: compiled without the Plinth check, so their
# bindings carry no status. They are found through the search path.
PREBUILT="$OUTDIR/prebuilt"
PREBUILT_MODULES=""
mkdir -p "$PREBUILT"
if ls prebuilt/*.hs >/dev/null 2>&1; then
  for helper in prebuilt/*.hs; do
    PREBUILT_MODULES="$PREBUILT_MODULES $(basename "$helper" .hs)"
    if ! out=$("$GHC" -c "${GHC_ARGS[@]}" -fno-plinth-status \
                 -outputdir "$PREBUILT" "$helper" 2>&1); then
      echo "error: cannot compile $helper:" >&2
      echo "$out" >&2
      exit 2
    fi
  done
fi

run_case () {
  local mode=$1 case_file=$2
  local name=${case_file%.hs}
  local golden expect mode_args actual_raw rc actual diff_out label
  case "$mode" in
    gate)   golden="$GOLDEN_DIR/$name.stderr"; mode_args=(); label="$name" ;;
    nogate) golden="$GOLDEN_DIR/nogate/$name.stderr"; mode_args=(-fno-plinth-gate)
            label="$name (nogate)" ;;
  esac
  # "-- EXPECT: ok": must compile in both modes; "-- EXPECT: ok-gate":
  # must compile in gate mode and fail in nogate mode (the plugin alone
  # rejects a module-wide construct, the check looks at each declaration).
  if head -5 "$case_file" | grep -q -- "-- EXPECT: ok-gate"; then
    if [ "$mode" = gate ]; then expect=ok; else expect=fail; fi
  elif head -5 "$case_file" | grep -q -- "-- EXPECT: ok"; then
    expect=ok
  else
    expect=fail
  fi
  total=$((total + 1))

  # A case that imports a prebuilt module compiles in one-shot mode (-c):
  # --make looks for sources only, -c finds the .hi in the search path.
  local ghc_mode=(--make) helper
  for helper in $PREBUILT_MODULES; do
    if grep -q "^import $helper\b" "$case_file"; then ghc_mode=(-c); fi
  done
  actual_raw=$("$GHC" "${ghc_mode[@]}" "${GHC_ARGS[@]}" "${mode_args[@]}" \
                 -i"$PREBUILT" -outputdir "$OUTDIR/$mode/$name" \
                 "$case_file" 2>&1)
  rc=$?
  actual=$(printf '%s\n' "$actual_raw" | normalize)

  if [ "$expect" = ok ]; then
    # Must compile, with no diagnostic at all.
    if [ $rc -ne 0 ] || [ -n "$(printf '%s' "$actual" | tr -d '[:space:]')" ]; then
      echo "FAIL $label: expected the compilation to succeed silently"
      printf '%s\n' "$actual" | sed 's/^/    /'
      failures=$((failures + 1))
    else
      echo "ok   $label"
    fi
    return
  fi

  if [ $rc -eq 0 ]; then
    echo "FAIL $label: expected the compilation to fail, but it succeeded"
    failures=$((failures + 1))
    return
  fi

  if [ "$ACCEPT" -eq 1 ]; then
    mkdir -p "$(dirname "$golden")"
    printf '%s\n' "$actual" > "$golden"
    echo "ACCEPT $label"
    return
  fi

  if [ ! -f "$golden" ]; then
    echo "FAIL $label: golden file missing ($golden); run with ACCEPT=1"
    failures=$((failures + 1))
    return
  fi

  if ! diff_out=$(printf '%s\n' "$actual" | diff -u "$golden" - 2>&1); then
    echo "FAIL $label: output differs from golden"
    echo "$diff_out" | sed 's/^/    /'
    failures=$((failures + 1))
  else
    echo "ok   $label"
  fi
}

for mode in $MODES; do
  for case_file in *.hs; do
    case "$case_file" in
      *Helper.hs) continue ;;
    esac
    run_case "$mode" "$case_file"
  done
done

echo ""
if [ "$ACCEPT" -eq 1 ]; then
  echo "error-tests: accepted goldens for $total cases"
elif [ $failures -eq 0 ]; then
  echo "error-tests: all $total cases passed"
else
  echo "error-tests: $failures of $total cases failed"
  exit 1
fi
