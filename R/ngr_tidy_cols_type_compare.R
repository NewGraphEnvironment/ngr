#' Compare Column Type Consistency Across Nested Dataframes
#'
#' This function checks for column type consistency across multiple dataframes nested in a list.
#'
#' @param nested_list_df [list] A named list of dataframes, where each dataframe is expected to have consistent column names.
#'
#' @return A [data.frame] with the following columns:
#'   - `col_name`: The name of the column.
#'   - `types`: A comma-separated string of unique types found for the column across all datasets.
#'   - `consistent`: A logical value indicating whether the column types are consistent across all datasets.
#' @family tidy
#' @details
#' This function inspects the class of each column across a list of dataframes. It aggregates the unique types for each column and determines if the column types are consistent across all datasets in the list.
#'
#' @examples
#' nested_list_df <- list(
#'   df1 = data.frame(a = 1:3, b = c("x", "y", "z"), c = as.Date("2023-01-01") + 0:2, stringsAsFactors = FALSE),
#'   df2 = data.frame(a = c(1.1, 2.2, 3.3), b = c("x", "y", "z"), c = c(TRUE, FALSE, TRUE), stringsAsFactors = FALSE),
#'   df3 = data.frame(a = c("one", "two", "three"), b = c("x", "y", "z"), c = as.Date("2023-01-01") + 0:2, stringsAsFactors = FALSE)
#' )
#' ngr_tidy_cols_type_compare(nested_list_df)
#'
#' @importFrom chk chk_list chk_data
#' @export
ngr_tidy_cols_type_compare <- function(nested_list_df) {
  # Validate input
  chk::chk_list(nested_list_df)
  if (is.null(names(nested_list_df)) || any(names(nested_list_df) == "")) {
    stop("The input list must be named.")
  }
  lapply(nested_list_df, chk::chk_data)

  # Extract column types for each dataframe
  nested_list_types <- lapply(nested_list_df, function(df) {
    sapply(df, class)
  })

  # Create a list to store column types across datasets
  column_types <- list()

  for (dataset_name in names(nested_list_types)) {
    dataset <- nested_list_types[[dataset_name]]
    for (col_name in names(dataset)) {
      col_types <- dataset[[col_name]]
      column_types[[col_name]] <- c(column_types[[col_name]], list(unique(col_types)))
    }
  }

  # Check for consistency across datasets
  result_df <- data.frame(
    col_name = names(column_types),
    types = sapply(column_types, function(types) {
      paste(
        unique(unlist(types)),
        collapse = ", "
      )
    }),
    consistent = sapply(column_types, function(types) {
      # Check if all datasets have the same types
      length(unique(sapply(types, paste, collapse = ", "))) == 1
    }),
    row.names = NULL
  )

  return(result_df)
}
