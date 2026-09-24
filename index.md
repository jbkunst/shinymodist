# shinymodist

A lightweight Shiny input wrapper around
[modist](https://github.com/williambdean/modist): draggable probability
distributions that behave like regular Shiny inputs.

`shinymodist` keeps the default presentation compact and low-noise,
while retaining an opt-in `style = "modist"` mode close to the upstream
experience.

## Install

``` r

pak::pak("jbkunst/shinymodist")
```

## Basic use

``` r

library(shiny)
library(shinymodist)

ui <- fluidPage(
  modist_input(
    "dist",
    family = "normal",
    value = list(mu = 0, sigma = 1)
  ),
  verbatimTextOutput("value")
)

server <- function(input, output, session) {
  output$value <- renderPrint(input$dist)
}

shinyApp(ui, server)
```

The input returns the distribution family and its canonical parameters:

``` r

list(
  family = "normal",
  mu = 0,
  sigma = 1
)
```

A fixed visible scale can be supplied when comparisons need a common
domain:

``` r

modist_input(
  "scores",
  family = "normal",
  value = list(mu = 1, sigma = 1),
  domain = c(-5, 5)
)
```

Server-side updates use
[`update_modist_input()`](https://jbkunst.github.io/shinymodist/reference/update_modist_input.md).

## Styles and bslib

The default `style = "minimal"` is intentionally quiet: no grid or
toolbar, and its visual accents inherit `--bs-primary` when used inside
a bslib theme.

``` r

bslib::page_fluid(
  theme = bslib::bs_theme(primary = "#6f42c1"),
  modist_input("dist")
)
```

Use `style = "modist"` to keep the original modist appearance and
controls.

## Distribution families

The wrapper exposes all distribution families bundled by modist:

- Normal, Beta, Gamma and Student t
- Exponential, Half Normal and Log Normal
- Cauchy, Laplace and Logistic
- Weibull, Half Student t and Chi-squared
- Inverse Gamma and Kumaraswamy

All families use the same
[`modist_input()`](https://jbkunst.github.io/shinymodist/reference/modist_input.md)
API. See the distribution gallery for a compact grid plus narrow-sidebar
examples.

## WebAssembly and Shinylive

WebAssembly compatibility is treated as a supported deployment target.
Every push is checked with the r-wasm toolchain. Package releases also
build a webR filesystem image so the package can be bundled by Shinylive
without compiling R packages in the browser.

Interactive Shinylive embeds in pkgdown can be added after the first
package release is available as a WebAssembly binary.

Documentation: <https://jbkunst.github.io/shinymodist/>

## Credits

`shinymodist` wraps the JavaScript distribution widgets from [William
Dean’s modist](https://github.com/williambdean/modist), distributed
under the MIT License.

The compact Shiny-input philosophy is also inspired by Carson Sievert’s
[histoslider](https://github.com/cpsievert/histoslider).

## License

MIT
