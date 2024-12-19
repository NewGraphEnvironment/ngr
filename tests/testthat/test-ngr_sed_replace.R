test_that("ngr_sed_replace correctly replaces all occurrences of key_missing", {
  # Create temporary files with test content
  temp_file1 <- tempfile(fileext = ".txt")
  temp_file2 <- tempfile(fileext = ".txt")

  writeLines(c("officeofthewetsuweten2013Wetsuweten is here.",
               "flnrord2017NaturalResourcea is there.",
               "officeofthewetsuweten2013Wetsuweten is mentioned again."), temp_file1)
  writeLines(c("eccc2016Climatedataa is everywhere.",
               "ilmb2007MoriceLanda is nowhere.",
               "eccc2016Climatedataa is repeated here."), temp_file2)

  # Define files and replacements
  files <- c(temp_file1, temp_file2)
  keys_matched <- data.frame(
    key_missing = c("officeofthewetsuweten2013Wetsuweten",
                    "flnrord2017NaturalResourcea",
                    "eccc2016Climatedataa",
                    "ilmb2007MoriceLanda"),
    key_missing_guess_match = c("officeofthewetsuweten2013Wetsuwet",
                                "flnrord2017NaturalResource",
                                "eccc2016Climatedata",
                                "ilmb2007MoriceLand"),
    stringsAsFactors = FALSE
  )

  # Apply the custom map2 with ngr_sed_replace
  map2(
    .x = keys_matched$key_missing,
    .y = keys_matched$key_missing_guess_match,
    .f = function(text_current, text_replace) {
      ngr_sed_replace(text_current = text_current, text_replace = text_replace, files = files)
    }
  )

  # Check file contents
  output1 <- readLines(temp_file1)
  output2 <- readLines(temp_file2)

  # Ensure no occurrences of key_missing remain
  for (i in seq_along(keys_matched$key_missing)) {
    expect_false(any(grepl(keys_matched$key_missing[i], c(output1, output2))))
  }

  # Ensure all occurrences are replaced with key_missing_guess_match
  for (i in seq_along(keys_matched$key_missing_guess_match)) {
    expect_true(any(grepl(keys_matched$key_missing_guess_match[i], c(output1, output2))))
  }

  # Clean up
  file.remove(temp_file1, temp_file2)
})

