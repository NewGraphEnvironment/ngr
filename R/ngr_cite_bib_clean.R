# Function to clean a BibTeX file to keep only cited entries.  Also returns a list of citation keys that are
# passed to the function but not included in the bib file so follow up can be done to determine thier
# correct keys (if present in the BibTex file)

#' @inheritParams ngr_cite_keys_to_inline
#' @export

ngr_cite_bib_clean <- function(path_bib, keys, output_file) {
  fs::file_create(output_file)
  # Read the entire BibTeX file
  lines <- readLines(path_bib)

  # Initialize variables
  keep_entry <- FALSE
  cleaned_lines <- c()

  for (line in lines) {
    # Check if the line starts a new citation entry
    if (grepl("^@", line)) {
      # Extract the citation key
      citation_key <- sub("^@.*\\{([^,]+),.*", "\\1", line)

      # Determine if the entry should be kept
      keep_entry <- citation_key %in% keys
    }

    # Add the line to cleaned_lines if the entry is to be kept
    if (keep_entry) {
      cleaned_lines <- c(cleaned_lines, line)
    }
  }

  # Write the cleaned lines to the output file
  writeLines(cleaned_lines, output_file)

  cat("Cleaned BibTeX file created:", output_file, "\n")
}


#' Check for Missing Citation Keys in a BibTeX File
#'
#' This function identifies citation keys provided in a list that are missing from
#' a specified BibTeX file. It ensures the BibTeX file exists and processes the
#' file to match the citation keys.
#' @inheritParams ngr_cite_keys_to_inline
#' @param keys [character] A vector of citation keys to check for in the BibTeX file.
#'
#' @importFrom cli cli_alert_success cli_alert_warning
#' @importFrom chk chk_file chk_string chk_character
#' @family cite
#' @export
#' @rdname ngr_cite_bib_clean
#'
#' @return A vector of citation keys missing from the BibTeX file. Returns an empty
#'   vector if all citation keys are found.
#' @examples
#' \dontrun{
#' path_bib <- system.file("extdata", "references.bib", package = "ngr")
#' citations <- c("Smith2020", "Jones2019")
#' ngr_cite_bib_keys_missing(path_bib, citations)
#' }
ngr_cite_bib_keys_missing <- function(path_bib, citations) {
  # Validate inputs
  chk::chk_string(path_bib)
  chk::chk_file(path_bib)
  chk::chk_character(citations)


  keys_bib <- ngr_cite_bib_keys_extract(path_bib)


  # Clean input citations by removing leading '@' if present
  clean_citations <- sub("^@", "", citations)

  # Identify missing citations
  missing_citations <- setdiff(clean_citations, keys_bib)

  # Output messages using cli
  if (length(missing_citations) > 0) {
    cli::cli_alert_warning("The following citations were not found in the BibTeX file:")
    print(missing_citations)
  } else {
    cli::cli_alert_success("All specified citations were found in the BibTeX file.")
  }

  # Return the missing citations
  return(missing_citations)
}

#' Extract Citation Keys from a BibTeX File
#'
#' This function extracts all citation keys from a given BibTeX file.
#'
#' @inheritParams ngr_cite_keys_to_inline
#' @return A character vector of citation keys extracted from the BibTeX file.
#' @importFrom chk chk_file
#' @rdname ngr_cite_bib_clean
#' @export
ngr_cite_bib_keys_extract <- function(path_bib) {
  # Validate the input file
  chk::chk_file(path_bib)

  # Read the contents of the BibTeX file
  bib_raw <- readLines(path_bib, warn = FALSE)

  # Extract lines that start with "@" (indicating a BibTeX entry)
  bib_keys_raw <- bib_raw[grepl("^@", bib_raw)]

  # Extract the citation keys from the BibTeX entries
  keys_bib <- sub("^@.*\\{([^,]+),.*", "\\1", bib_keys_raw)

  return(keys_bib)
}


#' @inheritParams ngr_cite_keys_to_inline
#' @return A character vector of citation keys extracted from the BibTeX file.
#' @importFrom chk chk_file
#' @importFrom stringdist stringdist
#' @rdname ngr_cite_bib_clean
#' @export
ngr_cite_keys_guess_match <- function(keys_missing, keys_bib) {
  # Create an empty result list
  result <- list(key_missing = character(0), key_missing_guess_match = character(0))

  # Loop through each missing key and find the closest match
  for (key in keys_missing) {
    # Calculate distances to all bib keys
    distances <- stringdist::stringdist(key, keys_bib)

    # Find the closest match (minimum distance)
    closest_index <- which.min(distances)
    closest_match <- keys_bib[closest_index]

    # Append results to the list
    result$key_missing <- c(result$key_missing, key)
    result$key_missing_guess_match <- c(result$key_missing_guess_match, closest_match)
  }

  # Convert the result to a data.frame
  return(data.frame(key_missing = result$key_missing,
                    key_missing_guess_match = result$key_missing_guess_match,
                    stringsAsFactors = FALSE))
}

