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

You need ghcup 0.2.1.0 or newer (check with `ghcup --version`). Add the
plinthc release channel to the ghcup configuration, then install and activate
plinthc:

```console
$ ghcup config add-release-channel https://raw.githubusercontent.com/ican-group/plinthc/ghcup-channel/ghcup-plinthc.yaml
$ ghcup install plinthc 9.12.172.1 --set
```

You add the channel only once: later `ghcup` commands for plinthc
(`ghcup list -t plinthc`, updates) use it. `ghcup install` downloads the
binary distribution for your platform and installs it under ghcup's own
directory. `--set` then links `plinthc` and `plinthc-pkg` (the compiler's own
`ghc-pkg`) into ghcup's `bin` directory (`~/.ghcup/bin` by default), which is
already on `PATH` for ghcup users.

> To install without changing the ghcup configuration, give the channel to
> one command with `--url-source`:
> `ghcup --url-source=https://raw.githubusercontent.com/ican-group/plinthc/ghcup-channel/ghcup-plinthc.yaml install plinthc 9.12.172.1 --set`.
> ghcup does not keep the channel, so you must give `--url-source` again for
> each later plinthc command.

Verify with:

```console
$ plinthc --version
```

Installing `plinthc` does not affect any GHC installed by ghcup: only
`plinthc*` binaries are put on `PATH`, so your regular `ghc` is left untouched.

## Update

Install the new release with `--set`, so that `plinthc` becomes the new
release:

```console
$ ghcup install plinthc latest --set
```

Without `--set`, ghcup installs the new release but `plinthc` stays the old
release. `latest` is the newest GHC 9.12-based release. For a GHC 9.6-based
release, give its version (see `ghcup list -t plinthc`).

A project that names the release in `cabal.project` (see
[Use plinthc in a project]({% link how-to/use.md %})) keeps its release until
you change the name there. The old release stays installed until you remove
it with `ghcup rm plinthc <version>`.

## Supported platforms

Binary distributions are published for:

- Linux, x86_64 and aarch64 (glibc, and musl/Alpine)
- macOS, Apple Silicon
- Windows, x86_64

The Linux glibc builds need glibc 2.38 or newer, for example Debian 13,
Ubuntu 24.04 or Fedora 39. Check your version with `ldd --version`. On a Linux
with an older glibc, the installation stops with an error such as
``version `GLIBC_2.38' not found``. ghcup offers the musl builds only on Alpine
Linux. On an older glibc,
[build plinthc from source]({% link how-to/build.md %}).

List the available versions with `ghcup list -t plinthc`.

## GHC 9.6-based releases

plinthc is released on two GHC versions. The version number tells them
apart: `9.12.<plinth>.<n>` is based on GHC 9.12 and is the recommended one;
`9.6.<plinth>.<n>` is based on GHC 9.6. Both compile the same Plinth
version (the third component: `172` is Plinth 1.72) and produce the same kind
of Plutus Core.

Use a 9.6-based release if your project or one of its dependencies does not
build with GHC 9.12 yet:

```console
$ ghcup install plinthc 9.6.172.1 --set
```

Then use `plinthc-9.6.172.1` and `plinthc-pkg-9.6.172.1` in your
`cabal.project` (see [Use plinthc in a project]({% link how-to/use.md %})),
and the `ghc-plinth-plutus` commit of that release:
`9a524ece4853086df34c90733195a01211329610`.

Once installed, head over to
[Use plinthc in a project]({% link how-to/use.md %}).
