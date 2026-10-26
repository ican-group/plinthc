---
title: plinthc
permalink: /
layout: page
show_title: false
sidebar: false
aside: false
full_width: true
---
<!-- The welcome page. It uses the theme's page layout without the docs
     sidebar and the in-page TOC, and builds its sections from the theme's
     grid, button and menu classes. The page-only styles are below. -->
<style>
  /* Bands: each section spans the viewport; the text stays at 950px, the
     theme's content width. */
  .landing { padding: 3rem 0; }
  .landing--alt { background-color: #f2f2f2; }
  .landing__inner { max-width: 950px; margin: 0 auto; padding: 0 1rem; }
  .landing--hero { text-align: center; }
  .landing h2 { margin: 0 0 1rem; font-size: 1.9rem; }
  .landing--hero h2 { margin-top: .5rem; font-size: 2.2rem; }
  .landing__lead { max-width: 40rem; margin: 0 auto 1.5rem; font-size: 1.2rem; }
  .landing__intro { margin: 0 0 1.5rem; }
  .landing__actions { margin-bottom: 2rem; }
  .landing__actions .button { margin: .25rem; }
  .landing__actions .button svg { vertical-align: -.15em; margin-right: .3em; fill: currentColor; }
  /* The code sample: left-aligned text in a centred box. */
  .landing__sample { max-width: 40rem; margin: 0 auto; text-align: left; }
  .landing__sample .highlight pre { margin: 0; overflow-x: auto; }
  .landing__caption { margin: .75rem 0 0; font-size: .85rem; color: #888; }
  /* Cards: a white tile on the grey band, a plain cell on the white band. */
  .landing__card { height: 100%; padding: 1rem 1.25rem; text-align: left; }
  .landing--alt .landing__card { background-color: #fff; border: 1px solid rgba(0, 0, 0, .1); border-radius: .4rem; }
  .landing__card h3 { margin: 0 0 .5rem; font-size: 1.2rem; }
  .landing__card p { margin: 0 0 .5rem; }
  .landing__card p:last-child { margin-bottom: 0; }
  .landing code { padding: .1em .3em; font-size: .9em; background-color: rgba(0, 0, 0, .05); border-radius: .2rem; }
  .landing .highlight code { padding: 0; font-size: inherit; background: none; }
  .landing__repos { padding-left: 1.2rem; }
  .landing__repos li { margin-bottom: .3rem; }
  @media (max-width: 500px) {
    .landing { padding: 2rem 0; }
    .landing--hero h2 { font-size: 1.6rem; }
    .landing__lead { font-size: 1.05rem; }
  }
  /* The wordmark: the animation plays once; anyone who has asked for less
     motion gets the still instead. */
  .wordmark-still { display: none; }
  @media (prefers-reduced-motion: reduce) {
    .wordmark-anim  { display: none; }
    .wordmark-still { display: inline; }
  }
</style>

<section class="landing landing--hero">
  <div class="landing__inner">
    <!-- The wordmark animation. It plays once and stops on a frame identical to
         plinthc-wordmark.png, so the clip and the still are interchangeable once
         it has finished. The poster is the animation's FIRST frame, not the
         finished mark -- see Note [The poster is the FIRST frame] in
         _logo/make-anim.sh. Two sources so there is always a playable one.

         width/height give the aspect ratio up front so the page does not jump
         on load. They are presentational hints, and this site has no global
         "height: auto" rule to cancel the height one, hence it in the style. -->
    <p style="margin: 0 0 1rem;">
      <video class="wordmark-anim" autoplay muted playsinline preload="auto"
             aria-label="plinthc"
             poster="{{ '/assets/images/plinthc-wordmark-poster.webp' | relative_url }}"
             width="1448" height="467"
             style="width: 100%; max-width: 620px; height: auto;">
        <source src="{{ '/assets/images/plinthc-wordmark.webm' | relative_url }}"
                type="video/webm">
        <source src="{{ '/assets/images/plinthc-wordmark.mp4' | relative_url }}"
                type="video/mp4">
      </video>
      <img class="wordmark-still" alt="plinthc"
           src="{{ '/assets/images/plinthc-wordmark.png' | relative_url }}"
           width="1448" height="467"
           style="width: 100%; max-width: 620px; height: auto;">
    </p>

    <h2>Write Cardano smart contracts in Haskell</h2>

    <p class="landing__lead">
      plinthc is <a href="https://www.haskell.org/ghc/">GHC</a> with the
      <a href="https://plutus.cardano.intersectmbo.org/docs/">Plinth</a>
      compiler built in. Plinth (formerly Plutus Tx) is a subset of Haskell
      compiled to Plutus Core, the language the
      <a href="https://cardano.org/">Cardano</a> ledger runs on-chain.
    </p>

    <ul class="menu menu--center landing__actions">
      <li><a class="button button--primary button--pill button--lg"
             href="{% link tutorials/first-smart-contract.md %}">Get started</a></li>
      <li><a class="button button--outline-primary button--pill button--lg"
             href="{% link how-to/install.md %}">Install</a></li>
      <li><a class="button button--outline-primary button--pill button--lg"
             href="https://github.com/ican-group/plinthc"><svg viewBox="0 0 16 16" aria-hidden="true"><path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0016 8c0-4.42-3.58-8-8-8z"/></svg>GitHub</a></li>
    </ul>

    <div class="landing__sample">
{% highlight haskell %}
{-# LANGUAGE TemplateHaskell #-}
module MyValidator where

import PlutusTx
import PlutusTx.Prelude qualified as PlutusTx

-- The on-chain rule: ordinary Haskell, in the Plinth subset.
mustEqual :: Integer -> Bool
mustEqual redeemer = redeemer PlutusTx.== 42

-- The untyped wrapper the ledger runs.
untypedValidator :: BuiltinData -> PlutusTx.BuiltinUnit
untypedValidator arg =
  PlutusTx.check (mustEqual (PlutusTx.unsafeFromBuiltinData arg))

-- Compiled to Plutus Core by plinthc, at compile time.
validatorCode :: CompiledCode (BuiltinData -> PlutusTx.BuiltinUnit)
validatorCode = $$(PlutusTx.compile [|| untypedValidator ||])
{% endhighlight %}
      <p class="landing__caption">
        A complete validator. No plugin flags, no <code>INLINEABLE</code>
        pragmas: build it with <code>cabal build</code> and plinthc emits the
        Plutus Core. See
        <a href="{% link how-to/test.md %}">Test a Plinth contract locally</a>
        for the tests that go with it.
      </p>
    </div>
  </div>
</section>

<section class="landing landing--alt">
  <div class="landing__inner">
    <h2>Why plinthc</h2>
    <div class="grid grid--p-3">
      <div class="cell cell--12 cell--md-6 cell--lg-4">
        <div class="landing__card">
          <h3>GHC with Plinth built in</h3>
          <p>There is no plugin to install or configure. Point cabal at plinthc
             and it behaves like an ordinary GHC. When a module defines Plinth
             code, the compiler emits the Plutus Core next to the usual
             outputs.</p>
          <p><a href="{% link explanation/standalone-compiler.md %}">How the compiler is built</a></p>
        </div>
      </div>
      <div class="cell cell--12 cell--md-6 cell--lg-4">
        <div class="landing__card">
          <h3>Installs with ghcup, next to your GHC</h3>
          <p>One <code>ghcup install</code> gives you a binary for Linux
             (x86_64 and aarch64, glibc and musl), macOS (Apple Silicon) or
             Windows. plinthc never replaces your <code>ghc</code>. Releases
             track GHC 9.12 and GHC 9.6.</p>
          <p><a href="{% link how-to/install.md %}">Install plinthc</a></p>
        </div>
      </div>
      <div class="cell cell--12 cell--md-6 cell--lg-4">
        <div class="landing__card">
          <h3>The whole Haskell ecosystem</h3>
          <p>Write the on-chain validator and the off-chain code in one
             language, even in one file. The same types cross the on-chain
             boundary safely. Use cabal, GHCi and Hackage as you do today.</p>
          <p><a href="{% link explanation/languages.md %}">Plinth among the contract languages</a></p>
        </div>
      </div>
      <div class="cell cell--12 cell--md-6 cell--lg-4">
        <div class="landing__card">
          <h3>No <code>INLINEABLE</code> pragmas, works at <code>-O0</code></h3>
          <p>plinthc keeps the definitions the Plinth compiler needs available
             without pragmas, and its <code>base</code>, <code>ghc-prim</code>
             and <code>ghc-bignum</code> libraries ship ready for Plinth. You
             can build Plinth code with <code>-O0</code>.</p>
          <p><a href="{% link explanation/plinth-language.md %}">The Plinth contract language</a></p>
        </div>
      </div>
      <div class="cell cell--12 cell--md-6 cell--lg-4">
        <div class="landing__card">
          <h3>Reproducible Plutus Core</h3>
          <p>The Plinth translation depends on how GHC compiles the code around
             it. plinthc pins the compiler and the Plinth compiler together and
             validates them as one unit, with tests and benchmarks.</p>
          <p><a href="{% link how-to/build.md %}#test-and-benchmark">Test and benchmark</a></p>
        </div>
      </div>
      <div class="cell cell--12 cell--md-6 cell--lg-4">
        <div class="landing__card">
          <h3>Blueprints and local tests</h3>
          <p>Generate CIP-57 blueprints from Haskell values. Test a contract
             without a node: as plain Haskell, on the CEK machine, by its
             execution budget, or on a simulated ledger.</p>
          <p><a href="{% link how-to/generate-blueprint.md %}">Generate a blueprint</a>
             &middot; <a href="{% link how-to/test.md %}">Test locally</a></p>
        </div>
      </div>
    </div>
  </div>
</section>

<section class="landing">
  <div class="landing__inner">
    <h2>Documentation</h2>
    <p class="landing__intro">
      This documentation follows the <a href="https://diataxis.fr/">Diataxis</a>
      framework, which separates docs into four kinds by what you need from
      them. New to Plinth? Start with
      <a href="{% link tutorials/first-smart-contract.md %}">Your first smart contract with Plinth</a>.
    </p>
    <div class="grid grid--p-3">
      <div class="cell cell--12 cell--md-6 cell--lg-3">
        <div class="landing__card">
          <h3><a href="{% link explanation/index.md %}">Explanation</a></h3>
          <p><em>Understanding-oriented.</em> Background and discussion: what
             Plinth is and how the compiler works.</p>
        </div>
      </div>
      <div class="cell cell--12 cell--md-6 cell--lg-3">
        <div class="landing__card">
          <h3><a href="{% link tutorials/index.md %}">Tutorials</a></h3>
          <p><em>Learning-oriented.</em> Start here if you are new: hands-on
             lessons that walk you through compiling your first smart contract
             and running it on a local chain.</p>
        </div>
      </div>
      <div class="cell cell--12 cell--md-6 cell--lg-3">
        <div class="landing__card">
          <h3><a href="{% link how-to/index.md %}">How-to guides</a></h3>
          <p><em>Task-oriented.</em> Practical recipes for a specific job:
             install the compiler, use it in a project, test a contract, and
             generate a blueprint.</p>
        </div>
      </div>
      <div class="cell cell--12 cell--md-6 cell--lg-3">
        <div class="landing__card">
          <h3><a href="{% link reference/index.md %}">Reference</a></h3>
          <p><em>Information-oriented.</em> Dry facts to look up.</p>
        </div>
      </div>
    </div>
  </div>
</section>

<section class="landing landing--alt">
  <div class="landing__inner">
    <h2>About</h2>
    <p>
      plinthc is developed by <a href="https://icangroup.co.uk">ICAN Group</a>
      (Luite Stegeman and Sylvain Henry). It is a fork of
      <a href="https://www.haskell.org/ghc/">GHC</a>, the Glasgow Haskell
      Compiler, with the Plinth compiler built in.
    </p>
    <p>
      The Plinth compiler itself, the <code>plutus-tx-plugin</code>, is
      developed by the Plutus team. See the
      <a href="https://plutus.cardano.intersectmbo.org/docs/">Plinth documentation</a>
      and the <a href="https://github.com/IntersectMBO/plutus">plutus repository</a>.
    </p>
    <p>The source code is on GitHub:</p>
    <ul class="landing__repos">
      <li><a href="https://github.com/ican-group/plinthc">ican-group/plinthc</a>:
          the build scripts, the tests, the examples and the issue tracker.</li>
      <li><a href="https://github.com/ican-group/ghc-plinth">ican-group/ghc-plinth</a>:
          the GHC fork.</li>
      <li><a href="https://github.com/ican-group/ghc-plinth-plutus">ican-group/ghc-plinth-plutus</a>:
          the plutus fork, which supplies the Plinth compiler and libraries.</li>
    </ul>
    <ul class="menu landing__actions">
      <li><a class="button button--outline-primary button--pill"
             href="https://github.com/ican-group/plinthc">View on GitHub</a></li>
      <li><a class="button button--outline-primary button--pill"
             href="https://github.com/ican-group/plinthc/issues">Report an issue</a></li>
    </ul>
  </div>
</section>
