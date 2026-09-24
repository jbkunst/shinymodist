# Distribution gallery

## Live demo

[Open this example in
Shinylive](https://jkunst.com/shinymodist/demos/gallery/)

The app runs entirely in the browser with webR; no local R installation
is required for the demo.

`shinymodist` exposes the distribution families provided by the bundled
modist version through the same input API.

The gallery is primarily a visual and responsive QA example: it places
all families in a grid and also shows a Normal input in a narrow 300 px
sidebar.

``` r

modist_input("normal", family = "normal")
modist_input("beta", family = "beta")
modist_input("studentt", family = "studentt")
modist_input("weibull", family = "weibull")
```

Run the complete gallery with:

``` r

shiny::runApp(
  system.file("examples/gallery", package = "shinymodist")
)
```

By default, height remains responsive to the available width. For
constrained layouts, an explicit CSS height can be supplied:

``` r

modist_input(
  "dist",
  family = "normal",
  height = "180px"
)
```

The default remains unchanged when `height = NULL`. Text sizing is
intentionally opinionated and not exposed as R arguments; advanced
applications can override the package CSS if needed.
