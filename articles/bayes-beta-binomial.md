# Beta-Binomial prior elicitation

## Live demo

[Open this example in
Shinylive](https://jkunst.com/shinymodist/demos/bayes-beta-binomial/)

The app runs entirely in the browser with webR; no local R installation
is required for the demo.

A Beta input provides a direct way to shape a prior over a probability.

If the prior is

``` math
p \sim \mathrm{Beta}(\alpha, \beta)
```

and we observe $`x`$ successes in $`n`$ Bernoulli trials, the conjugate
posterior is

``` math
p \mid x,n \sim
\mathrm{Beta}(\alpha + x, \beta + n - x).
```

The example uses
[`bslib::page_sidebar()`](https://rstudio.github.io/bslib/reference/page_sidebar.html):
the editable prior and trial controls live in the sidebar, while the
prior/posterior plot is shown in a
[`bslib::card()`](https://rstudio.github.io/bslib/reference/card.html).

The Shiny input provides the current `alpha` and `beta` values:

``` r

bslib::sidebar(
  modist_input(
    "prior",
    family = "beta",
    value = list(alpha = 2, beta = 2)
  ),
  sliderInput("n", "Trials", min = 1, max = 100, value = 20),
  sliderInput("x", "Successes", min = 0, max = 20, value = 12)
)
```

The prior and posterior curves need only base R’s
[`dbeta()`](https://rdrr.io/r/stats/Beta.html).

Run the complete example with:

``` r

shiny::runApp(
  system.file("examples/bayes-beta-binomial", package = "shinymodist")
)
```
