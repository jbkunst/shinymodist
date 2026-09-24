# shinymodist

R package providing a lightweight Shiny input wrapper around William Dean's modist interactive distribution widgets.

## Goal

Expose modist distributions as compact, reusable Shiny inputs.

The component should feel closer to a functional sparkline or histoslider than to a full chart.

Start simple. Add functionality only when it has a concrete use and is inexpensive to maintain.

## Non-negotiable design decisions

### Use modist, do not reimplement it

- Use the upstream modist JavaScript implementation for distribution mathematics and drag interactions.
- Do not recreate Normal, Beta, or Gamma parameter-solving logic in R or JavaScript.
- Vendor and pin the upstream JavaScript bundle so runtime does not depend on a CDN.
- Preserve upstream MIT attribution and license information.
- Keep vendor changes minimal and documented.
- No Python, marimo, anywidget, scipy, or PyMC dependency is required by the R package.

### Shiny input first

The primary API is:

    modist_input()
    update_modist_input()

modist_input() returns a regular Shiny input value containing the family and canonical parameters.

update_modist_input() updates parameter values from the server.

User drags should be debounced before reaching Shiny. Match Shiny's native
slider/text-input convention with a 250 ms debounce. Rendering inside the
browser remains immediate. Server-side updates should update the browser
immediately without bouncing the same change back to the server.

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
- use the surrounding bslib primary color for all interactive accents in minimal style
- do not preserve modist's blue/orange distinction in minimal style unless it carries necessary semantics

Do not expose cosmetic options merely because they are possible.

### Preserve access to the original modist experience

Support two high-level styles:

    style = "minimal"   # default
    style = "modist"    # close to upstream modist appearance and controls

Do not duplicate every style difference as an R argument.

### Useful visual overrides

ticks and grid may override the selected style when useful.

Use NULL to inherit the style default.

Avoid adding more visual arguments until a concrete use case requires them.

### Domain

    domain = NULL

uses modist automatic domain behavior.

    domain = c(min, max)

uses a fixed visible domain.

A fixed domain must remain fixed when parameters change. Do not silently auto-fit it.

This matters when multiple distributions need a common visual scale.

### Responsive behavior

Do not require a sidebar or size mode.

The component must adapt naturally to its container.

Avoid fixed pixel widths in the public API.

### Initial scope

Start with:

- Normal
- Beta
- Gamma

Do not expand scope merely because upstream modist supports more families.
Additional families can be added when the common implementation makes them cheap and they are tested.

### Updating

For the first version, update_modist_input() updates value.

Do not add dynamic family replacement unless a real use case requires it.

### bslib

bslib compatibility is important, but bslib must not be required for the component to function.

Prefer CSS inheritance and fallbacks such as currentColor, transparent backgrounds, Bootstrap CSS variables when present, and sensible standalone defaults.

Do not hard-code a theme that fights the surrounding application.

## Reference implementations

### modist

Source of distribution mathematics, rendering, and drag behavior.

Do not fork its statistical behavior unless there is a documented technical reason.

### histoslider

Reference for the desired Shiny product philosophy:

- compact visual input
- responsive
- useful inside a sidebar
- simple R API
- server-side update function
- integrates with surrounding styling rather than behaving like a full chart

Do not copy histoslider's React architecture unless it provides a concrete benefit. modist already provides standalone JavaScript.

## Development order

1. Implement one Normal Shiny input end-to-end.
2. Verify initial values and drag to input$id.
3. Implement update_modist_input().
4. Verify fixed domain.
5. Implement the minimal default appearance.
6. Verify style = "modist".
7. Add Beta and Gamma.
8. Test narrow sidebar and wide/card layouts.
9. Test plain Shiny and bslib.
10. Keep examples and documentation small.
11. Only then consider more distribution families.

Avoid building infrastructure for roadmap items before it is needed.

## Examples

Examples are documentation, not showcase applications. Keep each focused on one reason to use the package.

Initial examples, in this order:

1. basic
   - Minimal modist_input() usage.
   - Show the reactive input value.
   - Show update_modist_input().

2. styles
   - Compare the default minimal style with style = "modist".
   - Demonstrate that minimal style inherits a bslib primary color.
   - Show one simple override such as grid = TRUE.

3. roc
   - Two Normal inputs representing positive and negative score distributions.
   - Use a shared fixed domain.
   - Demonstrate that the component works naturally in a sidebar.
   - Use base R dnorm(), pnorm(), and base graphics for statistical and plotting code.
   - Do not reproduce the full visual-data-lab application or introduce highcharter/tidyverse dependencies.

4. bayes-beta-binomial
   - Demonstrate Beta prior elicitation.
   - Dragging the Beta input changes alpha and beta.
   - Show prior and conjugate posterior after observing x successes out of n.
   - Use base R dbeta() and Shiny only.
   - Do not introduce Stan, brms, JAGS, or similar frameworks merely for the example.

pkgdown may document these demos now. Shinylive embedding can be considered later once the package API is stable.

## Future roadmap

### Shiny for Python

A Python wrapper is planned after the R API and interaction contract are stable.

The Python implementation should reuse the same upstream modist JavaScript and as much of the small presentation layer and CSS as practical.

Do not maintain two independent implementations of the statistical or visual interaction logic.

A separate Python repository is preferred once the R behavior is established.

### htmlwidgets

An htmlwidget is not currently required.

Consider it only if there is a demonstrated need to use the component outside Shiny, for example in static Quarto or R Markdown output.

Do not build an htmlwidget merely for completeness.
