---
title: Install plinthc
permalink: /how-to/install/
---
[plinthc]({% link explanation/standalone-compiler.md %}) (`plinthc`)
is distributed as a custom tool named `plinthc` for
[ghcup](https://www.haskell.org/ghcup/), the standard installer for Haskell
toolchains. Installing it via ghcup, as described here, is the recommended way
to get it. To work on the compiler itself, or when no binary distribution
covers your platform, [build it from source]({% link how-to/build.md %})
instead.

## Install via ghcup

You need ghcup 0.2.1.0 or newer (check with `ghcup --version`). Add the plinthc
release channel, then install and activate the tool:

```console
$ ghcup config add-release-channel https://raw.githubusercontent.com/ican-group/plinthc/ghcup-channel/ghcup-plinthc.yaml
$ ghcup install plinthc 9.12.170.1
$ ghcup set plinthc 9.12.170.1
```

`ghcup install` downloads the binary distribution for your platform and
installs it under ghcup's own directory; `ghcup set` then links `plinthc` and
`plinthc-pkg` (the compiler's own `ghc-pkg`) into ghcup's `bin` directory
(`~/.ghcup/bin` by default), which is already on `PATH` for ghcup users.
Verify with:

```console
$ plinthc --version
```

Installing `plinthc` does not affect any GHC installed by ghcup: only
`plinthc*` binaries are put on `PATH`, so your regular `ghc` is left untouched.

## Supported platforms

Binary distributions are published for:

- Linux, x86_64 and aarch64 (glibc, and musl/Alpine)
- macOS, Apple Silicon
- Windows, x86_64

List the available versions with `ghcup list -t plinthc`.

## GHC 9.6-based releases

plinthc is released on two GHC versions. The version number tells them
apart: `9.12.<plinth>.<n>` is based on GHC 9.12 and is the recommended one;
`9.6.<plinth>.<n>` is based on GHC 9.6. Both compile the same Plinth
version (the third component: `170` is Plinth 1.70) and produce the same kind
of Plutus Core.

Use a 9.6-based release if your project or one of its dependencies does not
build with GHC 9.12 yet:

```console
$ ghcup install plinthc 9.6.170.1
$ ghcup set plinthc 9.6.170.1
```

Then use `plinthc-9.6.170.1` and `plinthc-pkg-9.6.170.1` in your
`cabal.project` (see [Use plinthc in a project]({% link how-to/use.md %})),
and the `ghc-plinth-plutus` commit of that release:
`1a74ed2d09f333ac516a0e49328cd62053ff4c9d`.

Once installed, head over to
[Use plinthc in a project]({% link how-to/use.md %}).
