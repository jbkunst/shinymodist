# Bayesian normal model

## Live demo

[Open this example in
Shinylive](https://jkunst.com/shinymodist/demos/normal-priors/)

This example uses two interactive priors for a Normal likelihood:

\\ y_i \mid \mu, \sigma^2 \sim \mathcal{N}(\mu, \sigma^2), \\

\\ \mu \sim \mathcal{N}(m_0, s_0^2), \qquad \sigma^2 \sim
\operatorname{InverseGamma}(\alpha_0, \beta_0). \\

The posterior is proportional to likelihood times priors:

\\ p(\mu, \sigma^2 \mid y) \propto p(y \mid \mu, \sigma^2)\\ p(\mu)\\
p(\sigma^2). \\

The app evaluates this posterior on a small deterministic grid, then
integrates the joint surface numerically to obtain marginal posterior
densities for \\\mu\\ and \\\sigma^2\\. This keeps the example
transparent and avoids an MCMC dependency.

The two priors are ordinary
[`modist_input()`](https://jkunst.com/shinymodist/reference/modist_input.md)
controls:

``` r

modist_input(
  "mu_prior",
  family = "normal",
  value = list(mu = 0, sigma = 1.25)
)

modist_input(
  "variance_prior",
  family = "inversegamma",
  value = list(alpha = 3, beta = 1)
)
```

Run it locally with:

``` r

shiny::runApp(
  system.file("examples/normal-priors", package = "shinymodist")
)
```
