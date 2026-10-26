---
title: plinthc
permalink: /
layout: page
show_title: false
sidebar: false
aside: false
full_width: true
landing: true
---
<!-- The welcome page. It uses the theme's page layout without the docs
     sidebar and the in-page TOC, and builds its sections from the theme's
     grid, button and menu classes. The styles are in assets/css/landing.css
     and the card texts in _data/landing.yml. -->
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
      {%- for card in site.data.landing.highlights %}
      <div class="cell cell--12 cell--md-6 cell--lg-4">
        <div class="landing__card">
          <h3>{{ card.title }}</h3>
          <p>{{ card.text }}</p>
          <p>
            {%- for l in card.links -%}
              {%- unless forloop.first %} &middot; {% endunless -%}
              <a href="{% link {{ l.page }} %}{% if l.anchor %}#{{ l.anchor }}{% endif %}">{{ l.text }}</a>
            {%- endfor -%}
          </p>
        </div>
      </div>
      {%- endfor %}
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
      {%- for card in site.data.landing.docs %}
      <div class="cell cell--12 cell--md-6 cell--lg-3">
        <div class="landing__card">
          <h3><a href="{% link {{ card.page }} %}">{{ card.title }}</a></h3>
          <p><em>{{ card.kind }}</em> {{ card.text }}</p>
        </div>
      </div>
      {%- endfor %}
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
