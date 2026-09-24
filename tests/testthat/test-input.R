test_that("normal input carries initial configuration", {
  x <- modist_input(
    "dist",
    family = "normal",
    value = list(mu = 1, sigma = 2),
    domain = c(-5, 5)
  )

  config <- jsonlite::fromJSON(
    x$attribs[["data-shinymodist-config"]],
    simplifyVector = FALSE
  )

  expect_equal(x$attribs$id, "dist")
  expect_equal(config$family, "normal")
  expect_equal(config$value$mu, 1)
  expect_equal(config$value$sigma, 2)
  expect_equal(unlist(config$domain), c(-5, 5))
})

test_that("family defaults are simple and stable", {
  expect_silent(modist_input("normal"))
  expect_silent(modist_input("beta", family = "beta"))
  expect_silent(modist_input("gamma", family = "gamma"))
})

test_that("invalid domains fail early", {
  expect_error(modist_input("x", domain = c(1, 1)), "strictly increasing")
  expect_error(modist_input("x", domain = c(1, Inf)), "finite")
})

test_that("distribution parameters are validated", {
  expect_error(
    modist_input("x", value = list(sigma = 0)),
    "greater than 0"
  )

  expect_error(
    modist_input("x", family = "beta", value = list(alpha = -1)),
    "greater than 0"
  )
})
