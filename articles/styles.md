# Styles and bslib

The default `style = "minimal"` is intended to behave like a compact
Shiny input rather than a full chart. When a bslib theme is present, the
curve, handles, reference lines, and labels inherit its primary color.

``` r

theme <- bslib::bs_theme(
  version = 5,
  primary = "#6f42c1"
)

bslib::page_fluid(
  theme = theme,
  modist_input("dist")
)
```

The upstream modist appearance remains available explicitly:

``` r

modist_input(
  "dist",
  style = "modist"
)
```

Useful visual details can still override a style when needed:

``` r

modist_input(
  "dist",
  style = "minimal",
  grid = TRUE,
  ticks = FALSE
)
```

Run the complete comparison with:

``` r

shiny::runApp(system.file("examples/styles", package = "shinymodist"))
```
