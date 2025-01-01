test_that("ngr_str_link_repo generates a valid URL with correct anchor text", {
  repo_source <- "ngr"
  url <- "https://github.com/NewGraphEnvironment"
  target <- "_blank"

  # Test 1: Default anchor text ("url_link")
  expected_default <- '<a href="https://github.com/NewGraphEnvironment/ngr" target="_blank">url_link</a>'
  result_default <- ngr_str_link_repo(repo_source = repo_source, url = url, target = target)
  expect_equal(result_default, expected_default)

  # Test 2: Anchor text set to repo_source
  expected_repo <- '<a href="https://github.com/NewGraphEnvironment/ngr" target="_blank">ngr</a>'
  result_repo <- ngr_str_link_repo(repo_source = repo_source, url = url, anchor_text = repo_source, target = target)
  expect_equal(result_repo, expected_repo)
})
