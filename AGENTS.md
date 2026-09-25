# shinymodist

R package providing a lightweight Shiny input wrapper around William
Dean’s modist interactive distribution widgets.

## Goal

Expose modist distributions as compact, reusable Shiny inputs.

The component should feel closer to a functional sparkline or
histoslider than to a full chart.

Start simple. Add functionality only when it has a concrete use and is
inexpensive to maintain.

## Non-negotiable design decisions

### Use modist, do not reimplement it

- Use the upstream modist JavaScript implementation for distribution
  mathematics and drag interactions.
- Do not recreate Normal, Beta, or Gamma parameter-solving logic in R or
  JavaScript.
- Vendor and pin the upstream JavaScript bundle so runtime does not
  depend on a CDN.
- Preserve upstream MIT attribution and license information.
- Keep vendor changes minimal and documented.
- No Python, marimo, anywidget, scipy, or PyMC dependency is required by
  the R package.

### Shiny input first

The primary API is:

``` R
modist_input()
update_modist_input()
```

modist_input() returns a regular Shiny input value containing the family
and canonical parameters.

update_modist_input() updates parameter values from the server.

User drags should be debounced before reaching Shiny. Match Shiny’s
native slider/text-input convention with a 250 ms debounce. Rendering
inside the browser remains immediate. Server-side updates should update
the browser immediately and notify Shiny of the resulting input value
once, matching native Shiny inputs so reactive dependents stay
synchronized.

Do not build an htmlwidget in the first version.

### Minimal by default

The default appearance must be compact and low-noise:

- responsive width: 100% of its container
- suitable for a sidebar as well as wider layouts
- transparent background
- compatible with plain Shiny and bslib
- no vertical grid by default
- no unnecessary toolbar
- no pan instruction text
- restrained axis and ticks
- curve and draggable handles remain the visual focus
- use the surrounding bslib primary color for all interactive accents in
  minimal style
- do not preserve modist’s blue/orange distinction in minimal style
  unless it carries necessary semantics

Do not expose cosmetic options merely because they are possible.

Container-responsive label sizing is an internal design responsibility.
SVG labels must remain readable in narrow cards/sidebars without adding
public font-size arguments. Keep narrow-container typography between
upstream modist and the previous oversized minimal treatment: ticks
should stay restrained, while interactive chip labels may be moderately
larger for readability. Avoid abrupt breakpoint jumps. In minimal Normal
inputs, display the center handle as μ rather than the longer “mean”
label.

### Preserve access to the original modist experience

Support two high-level styles:

``` R
style = "minimal"   # default
style = "modist"    # close to upstream modist appearance and controls
```

Do not duplicate every style difference as an R argument.

### Useful visual overrides

ticks and grid may override the selected style when useful.

Use NULL to inherit the style default.

Avoid adding more visual arguments until a concrete use case requires
them.

### Domain

``` R
domain = NULL
```

uses modist automatic domain behavior.

``` R
domain = c(min, max)
```

uses a fixed visible domain.

A fixed domain must remain fixed when parameters change. Do not silently
auto-fit it.

This matters when multiple distributions need a common visual scale.

### Responsive behavior

Do not require a sidebar or size mode.

The component must adapt naturally to its container.

`height = NULL` is the default and preserves the responsive aspect
ratio. An explicit CSS `height` is allowed as a layout escape hatch for
constrained containers. Do not add width/size presets or font-size
arguments unless a real use case requires them.

Avoid fixed pixel widths in the public API.

### Distribution families

Once the common binding is stable, expose all distribution families
already bundled by the pinned modist version. Adding an upstream family
is cheap when it only requires a factory mapping, defaults, and
validation.

Do not implement new statistical families independently in shinymodist.
New distribution mathematics belongs upstream in modist.

### Updating

For the first version, update_modist_input() updates value.

Do not add dynamic family replacement unless a real use case requires
it.

### bslib

bslib compatibility is important, but bslib must not be required for the
component to function.

Prefer CSS inheritance and fallbacks such as currentColor, transparent
backgrounds, Bootstrap CSS variables when present, and sensible
standalone defaults.

Do not hard-code a theme that fights the surrounding application.

## Reference implementations

### modist

Source of distribution mathematics, rendering, and drag behavior.

Do not fork its statistical behavior unless there is a documented
technical reason.

### histoslider

Reference for the desired Shiny product philosophy:

- compact visual input
- responsive
- useful inside a sidebar
- simple R API
- server-side update function
- integrates with surrounding styling rather than behaving like a full
  chart

Do not copy histoslider’s React architecture unless it provides a
concrete benefit. modist already provides standalone JavaScript.

## Development order

1.  Implement one Normal Shiny input end-to-end.
2.  Verify initial values and drag to input\$id.
3.  Implement update_modist_input().
4.  Verify fixed domain.
5.  Implement the minimal default appearance.
6.  Verify style = “modist”.
7.  Expose the remaining upstream modist families through the same
    binding.
8.  Test narrow sidebar and wide/card layouts.
9.  Test plain Shiny and bslib.
10. Keep examples and documentation small.

Avoid building infrastructure for roadmap items before it is needed.

## Examples

Examples are documentation, not showcase applications. Keep each focused
on one reason to use the package.

Initial examples, in this order:

1.  basic
    - Minimal modist_input() usage.
    - Show the reactive input value.
    - Show update_modist_input().
2.  gallery
    - Show every supported upstream distribution and nothing else.
    - Use `bslib::layout_column_wrap(width = 1 / 4)` as a fillable
      4-column grid; with 15 families the final cell remains empty.
    - Use bslib so minimal style visibly inherits the theme primary
      color.
    - Use a small grid gap and page padding so card borders do not
      visually intersect.
    - Keep gallery cards compact: mildly rounded corners and light,
      low-padding headers.
    - Let each input fill its card height. Keep narrow-sidebar and
      style-comparison testing outside the gallery.
3.  roc
    - Two Normal inputs representing positive and negative score
      distributions.
    - Start with wider sigmas so the draggable handles are comfortably
      separated.
    - Use a shared fixed domain.
    - Demonstrate that the component works naturally in a sidebar.
    - Use restrained blue density fills and an amber threshold,
      borrowing the visual grammar (not the full complexity) of
      visual-data-lab.
    - Use base R dnorm(), pnorm(), and base graphics for statistical and
      plotting code.
    - Do not reproduce the full visual-data-lab application or introduce
      highcharter/tidyverse dependencies.
4.  bayes-beta-binomial
    - Demonstrate Beta prior elicitation.
    - Dragging the Beta input changes alpha and beta.
    - Show prior and conjugate posterior after observing x successes out
      of n.
    - Keep posterior parameters as a simple verbatim str() output, not a
      card.
    - Use base R dbeta() and Shiny only.
    - Do not introduce Stan, brms, JAGS, or similar frameworks merely
      for the example.

pkgdown may document these demos now. Shinylive embedding can be
considered later once the package API is stable.

## WebAssembly and Shinylive

WebAssembly support is mandatory, not optional.

- Every push and pull request should build the package with r-wasm.
- GitHub releases should publish a webR filesystem image using the
  official r-wasm actions.
- The `main` branch maintains a rolling `dev` prerelease whose tag is
  moved to the latest commit and whose WebAssembly assets are replaced
  on each push. pkgdown installs `jbkunst/shinymodist@dev` before
  exporting Shinylive apps, so the package metadata points Shinylive to
  those release assets.
- Keep runtime dependencies compatible with webR where practical.
- Shinylive cannot compile R packages from source in the browser; it
  needs precompiled WebAssembly binaries.
- Export the runnable package examples under `docs/demos/` with
  [`shinylive::export()`](https://posit-dev.github.io/r-shinylive/reference/export.html)
  after the rolling dev WebAssembly image is ready.
- Start with links to the live demos. Inline iframe embeds are optional
  later and should only be added if they improve the documentation
  experience.
- Do not add compiled dependencies without checking their WebAssembly
  support.

## Future roadmap

### Shiny for Python

A Python wrapper is planned after the R API and interaction contract are
stable.

The Python implementation should reuse the same upstream modist
JavaScript and as much of the small presentation layer and CSS as
practical.

Do not maintain two independent implementations of the statistical or
visual interaction logic.

A separate Python repository is preferred once the R behavior is
established.

### htmlwidgets

An htmlwidget is not currently required.

Consider it only if there is a demonstrated need to use the component
outside Shiny, for example in static Quarto or R Markdown output.

Do not build an htmlwidget merely for completeness.

## Homepage live demo

The pkgdown index embeds the `normal-priors` Shinylive example. It
intentionally uses two different distribution inputs: Normal for the
mean and Inverse-Gamma for the variance. Real `mtcars$mpg` observations
and an observation-count slider show prior-to-posterior updating for
both parameters. Prior/posterior plots use restrained teal fills with
amber data markers. The posterior is evaluated on a deterministic grid
so the example stays dependency-free and browser-friendly. Keep this
example compact because it is part of the landing page. Use a sidebar
for the two priors and compact observation slider, and stack the two
posterior cards vertically so the embedded app remains readable without
horizontal scrolling.
