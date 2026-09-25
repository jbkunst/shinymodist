# shinymodist

A lightweight Shiny input wrapper around [modist](https://github.com/williambdean/modist): draggable probability distributions that behave like regular Shiny inputs.

`shinymodist` keeps the default presentation compact and low-noise, while retaining an opt-in `style = "modist"` mode close to the upstream experience.


## Try it live

The two inputs below define priors for a simple Bayesian Normal model: a Normal
prior for the mean and an Inverse-Gamma prior for the variance. Drag either
distribution to update the implied prior predictive distribution.

<iframe
  src="https://jkunst.com/shinymodist/demos/normal-priors/"
  title="Bayesian normal model with shinymodist"
  style="width: 100%; height: 620px; border: 1px solid #dee2e6; border-radius: 0.75rem;"
></iframe>


## Install

```r
pak::pak("jbkunst/shinymodist")
```

## Basic use

```r
library(shiny)
library(shinymodist)

ui <- bslib::page_sidebar(
  title = "Basic shinymodist input",
  sidebar = bslib::sidebar(
    modist_input(
      "dist",
      family = "normal",
      value = list(mu = 0, sigma = 1)
    )
  ),
  bslib::card(
    bslib::card_header("Reactive value"),
    verbatimTextOutput("value")
  )
)

server <- function(input, output, session) {
  output$value <- renderPrint(input$dist)
}

shinyApp(ui, server)
```

The input returns the distribution family and its canonical parameters:

```r
list(
  family = "normal",
  mu = 0,
  sigma = 1
)
```

A fixed visible scale can be supplied when comparisons need a common domain:

```r
modist_input(
  "scores",
  family = "normal",
  value = list(mu = 1, sigma = 1),
  domain = c(-5, 5)
)
```

Server-side updates use `update_modist_input()`.

## Styles and bslib

The default `style = "minimal"` is intentionally quiet: no grid or toolbar,
and its visual accents inherit `--bs-primary` when used inside a bslib theme.

```r
bslib::page_fluid(
  theme = bslib::bs_theme(primary = "#6f42c1"),
  modist_input("dist")
)
```

Use `style = "modist"` to keep the original modist appearance and controls.

The input is responsive by default. A fixed CSS height is available only when
the surrounding layout needs it:

```r
modist_input("dist", height = "180px")
```

The default `height = NULL` keeps the current aspect-ratio behavior.

## Live demos

The pkgdown site exports the package examples with Shinylive, so they run
entirely in the browser with webR:

- [Basic input](https://jkunst.com/shinymodist/demos/basic/)
- [Distribution gallery](https://jkunst.com/shinymodist/demos/gallery/)
- [ROC curve](https://jkunst.com/shinymodist/demos/roc/)
- [Beta-Binomial](https://jkunst.com/shinymodist/demos/bayes-beta-binomial/)
- [Bayesian normal model](https://jkunst.com/shinymodist/demos/normal-priors/)

The live examples run entirely in the browser with Shinylive and webR.

## Distribution families

The wrapper exposes all distribution families bundled by modist:

- Normal, Beta, Gamma and Student t
- Exponential, Half Normal and Log Normal
- Cauchy, Laplace and Logistic
- Weibull, Half Student t and Chi-squared
- Inverse Gamma and Kumaraswamy

All families use the same `modist_input()` API. See the distribution gallery
for a compact grid plus narrow-sidebar examples.

## WebAssembly and Shinylive

The examples can run entirely in the browser with Shinylive and webR.
WebAssembly compatibility is checked in CI and supported in package releases.

## Credits

`shinymodist` wraps the JavaScript distribution widgets from [William Dean's modist](https://github.com/williambdean/modist), distributed under the MIT License.

The compact Shiny-input philosophy is also inspired by Carson Sievert's [histoslider](https://github.com/cpsievert/histoslider).

## License

MIT
