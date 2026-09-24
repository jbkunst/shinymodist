# ROC curve

## Live demo

[Open this example in
Shinylive](https://jkunst.com/shinymodist/demos/roc/)

The app runs entirely in the browser with webR; no local R installation
is required for the demo.

This demo uses two Normal inputs on the same fixed domain. The common
scale makes changes in location and spread directly comparable.

The statistical calculations are base R:
[`dnorm()`](https://rdrr.io/r/stats/Normal.html) for the score densities
and [`pnorm()`](https://rdrr.io/r/stats/Normal.html) for the ROC curve.

``` r

score_domain <- c(-5, 5)

modist_input(
  "positive",
  value = list(mu = 1, sigma = 1),
  domain = score_domain
)

modist_input(
  "negative",
  value = list(mu = -1, sigma = 1),
  domain = score_domain
)
```

Run the complete sidebar example with:

``` r

shiny::runApp(system.file("examples/roc", package = "shinymodist"))
```

The example uses `bslib` only for layout. The probability calculations
and plots remain base R.
