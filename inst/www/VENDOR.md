# Vendored modist

shinymodist vendors the standalone browser bundle from:

- Project: https://github.com/williambdean/modist
- Version: v0.7.1
- License: MIT
- Source used: site/index.html, inline standalone bundle

The upstream license is stored in modist-LICENSE.txt and the copyright banner
is preserved in modist.js.

## Local patch

The vendored bundle contains one deliberately small integration patch:
standalone factories accept an optional third configuration object with a
fixed domain.

Example:

    modist.normal(element, { mu: 0, sigma: 1 }, { domain: [-5, 5] })

When domain is present, the internal view remains fixed instead of auto-fitting
after parameter changes. Distribution mathematics and drag-to-parameter logic
remain upstream modist behavior.
