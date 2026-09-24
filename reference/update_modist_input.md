# Update an interactive distribution input

Updates one or more parameter values of an existing
[`modist_input()`](https://jkunst.com/shinymodist/reference/modist_input.md)
from the Shiny server.

## Usage

``` r
update_modist_input(
  input_id,
  value,
  session = shiny::getDefaultReactiveDomain()
)
```

## Arguments

- input_id:

  Id of the input to update.

- value:

  Named list of parameter values to update.

- session:

  The Shiny session.

## Value

Invisibly returns `NULL`.
