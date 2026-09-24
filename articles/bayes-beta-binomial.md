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

The Shiny input provides the current `alpha` and `beta` values:

``` r

modist_input(
  "prior",
  family = "beta",
  value = list(alpha = 2, beta = 2)
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
