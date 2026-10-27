#!/usr/bin/env bash
# The Plinth gate sweep: compile the Plinth compiler test-suites with the
# gate in warning mode and list the modules that it would reject.
#
# Note [The gate sweep]
# ~~~~~~~~~~~~~~~~~~~~~
# The gate (see GHC.Plinth.Check in the GHC fork) rejects a Plinth splice
# that uses unsupported code. The test-suites of plutus-tx-plugin compile
# thousands of valid splices, and some deliberately invalid ones (the
# modules that use defer-errors). This sweep compiles all of them with
# -fplinth-gate-warn, so that a rejection is a warning and the build goes
# on, then compares the set of rejecting modules with gate-sweep.allow:
# the modules that are expected to contain invalid code. A module not in
# the list is a false positive of the gate.
#
# Usage (from plinth/test, after plinthc-test.sh built the project):
#   GHC=/path/to/plinthc ./gate-sweep.sh
#
# The sweep builds into _build/sweep, so it does not disturb the regular
# build tree. It forces a recompilation of the test-suites.

set -uo pipefail

HERE=$(cd "$(dirname "$0")" && pwd)
: ${GHC:=$HERE/../../ghc/_build/stage1/bin/plinthc}
: ${JOBS:=}
: ${SWEEP_TARGETS:="plutus-tx-plugin:plutus-tx-plugin-tests plutus-tx-plugin:plutus-ledger-api-plugin-test plutus-tx-plugin:frontend-plugin-tests plutus-tx-plugin:size plutus-tx:plutus-tx-test"}

cd "$HERE"
LOG=_build/sweep.log
mkdir -p _build

cabal --project-file=cabal.project \
      --remote-repo-cache _build/packages \
      --store-dir=_build/store \
      --logs-dir=_build/logs \
      build -j${JOBS} -w "$GHC" \
      --builddir=_build/sweep \
      --enable-tests \
      --ghc-options="-fplinth-gate-warn -fforce-recomp -fhide-source-paths -fdiagnostics-color=never" \
      ${SWEEP_TARGETS} 2>&1 | tee "$LOG"
rc=${PIPESTATUS[0]}
if [ "$rc" -ne 0 ]; then
  echo "gate-sweep: the build failed (exit $rc); see $LOG" >&2
  exit 2
fi

# "Foo/Bar.hs:12:5: warning: [PLINTH-00008]" -> Foo/Bar.hs
actual=$(grep -E '^[^ ]+\.hs:[0-9]+:[0-9]+: warning: \[PLINTH-00008\]' "$LOG" \
           | sed -e 's/:[0-9]*:[0-9]*: warning.*//' | sort -u)
expected=$(grep -v '^#' gate-sweep.allow | grep -v '^$' | sort -u)

unexpected=$(comm -23 <(printf '%s\n' "$actual") <(printf '%s\n' "$expected"))
missing=$(comm -13 <(printf '%s\n' "$actual") <(printf '%s\n' "$expected"))

status=0
if [ -n "$unexpected" ]; then
  echo "gate-sweep: the gate rejects modules that are not in gate-sweep.allow:"
  printf '%s\n' "$unexpected" | sed 's/^/    /'
  echo "    (grep '\\[PLINTH-00008\\]' $LOG for the messages)"
  status=1
fi
if [ -n "$missing" ]; then
  echo "gate-sweep: modules in gate-sweep.allow that the gate accepts now:"
  printf '%s\n' "$missing" | sed 's/^/    /'
  status=1
fi
if [ $status -eq 0 ]; then
  echo "gate-sweep: the gate rejects exactly the modules in gate-sweep.allow"
fi
exit $status
