test_that("ngr_str_link_url generates a valid url_base with correct anchor text", {
  url_resource <- "ngr"
  url_base <- "https://github.com/NewGraphEnvironment"
  target <- "_blank"

  # Test 1: Default anchor text ("url_link")
  expected_default <- '<a href="https://github.com/NewGraphEnvironment/ngr" target="_blank">url_link</a>'
  result_default <- ngr_str_link_url(url_resource = url_resource, url_base = url_base, target = target)
  expect_equal(result_default, expected_default)

  # Test 2: Anchor text set to url_resource
  expected_repo <- '<a href="https://github.com/NewGraphEnvironment/ngr" target="_blank">ngr</a>'
  result_repo <- ngr_str_link_url(url_resource = url_resource, url_base = url_base, anchor_text = url_resource, target = target)
  expect_equal(result_repo, expected_repo)
})

test_that("ngr_str_link_url generates a valid url_base with no url_resource provided and default anchor text", {

  # Test 1: Default anchor text ("url_link")
  expected <- '<a href="https://www.github.com" target="_blank">url_link</a>'
  result <- ngr_str_link_url(url_base = "https://www.github.com")
  expect_equal(result, expected)
})


# df <- data.frame(
#    url_resource = c("ngr", "fpr"),
#    url_base = c("https://github.com/NewGraphEnvironment", "https://www.newgraphenvironment.com")
# )
# df <- df %>%
#    dplyr::mutate(
#      link = ngr_str_link_url(url_resource = url_resource, url_base = url_base, anchor_text = url_resource)
#    )

# if you want to link
# html_link <- '<a href="https://www.github.com" target="_blank">url_link</a>'
# htmltools::browsable(htmltools::HTML(html_link))


