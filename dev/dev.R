usethis::create_package(".")
usethis::use_testthat(edition = 3)
usethis::use_pkgdown()
usethis::use_github_action("pkgdown")
usethis::use_pkgdown_github_pages()
usethis::use_mit_license()
usethis::use_directory("dev")

usethis::use_readme_rmd()
devtools::build_readme()
usethis::use_lifecycle()
usethis::use_data_raw("extdata")

usethis::use_test("ngr_cite_key_to_inline")

devtools::document()
devtools::test()


# packages
usethis::use_package("RefManageR", type = "Suggests")
usethis::use_package("stringr")
usethis::use_package("fs")

# for testing

# Step 2: clean then build and install the package
processx::run(
  command = "R",
  args = c("CMD", "INSTALL", "--preclean", "--no-multiarch", "--with-keep.source", "."),
  echo = TRUE
)


staticimports::import(
  dir = here::here("R/"),
  outfile = here::here("R/staticimports.R")
)
