#' Coerce column types in one data frame to match another
#'
#' This function ensures that shared columns in `dat_to_type` are coerced to match
#' the data types of corresponding columns in `dat_w_types`.
#' @param dat_w_types [data.frame] Reference data frame with desired column types.
#' @param dat_to_type [data.frame] Data frame to be coerced to match `dat_w_types`.
#'
#' @return [data.frame] `dat_to_type` with shared columns coerced to the types in `dat_w_types`.
#'
#' @importFrom cli cli_abort cli_inform cli_warn
#' @importFrom chk chk_data
#' @family tidy
#' @export
#'
#' @examples
#' dat_w_types <- data.frame(a = as.numeric(1:3), b = as.character(4:6))
#' dat_to_type <- data.frame(a = as.character(1:3), b = 4:6)
#' ngr_tidy_type(dat_w_types, dat_to_type)
ngr_tidy_type <- function(dat_w_types, dat_to_type) {
  chk::chk_data(dat_w_types)
  chk::chk_data(dat_to_type)

  common <- intersect(names(dat_to_type), names(dat_w_types))
  if (length(common) == 0) {
    cli::cli_abort("No common columns found between `dat_w_types` and `dat_to_type`.")
  }

  dat_to_type[common] <- mapply(function(x, y, colname) {
    target_class <- class(y)[1]
    as_fun <- get(paste0("as.", target_class), mode = "function")

    result <- tryCatch(
      {
        converted <- suppressWarnings(as_fun(x))

        if (all(is.na(converted)) && any(!is.na(x))) {
          cli::cli_abort("Conversion of column {colname} to {target_class} resulted in all NAs.",
                         colname = colname, target_class = target_class)
        }

        if (any(is.na(converted) & !is.na(x))) {
          cli::cli_warn("Coercion of column {colname} to {target_class} introduced NAs.",
                        colname = cli::col_yellow(colname), target_class = cli::col_yellow(target_class))
        }

        cli::cli_inform("Successfully converted column {colname} to {target_class}.",
                        colname = colname, target_class = target_class)
        converted
      },
      error = function(e) {
        cli::cli_abort(c(
          "Failed to convert column {colname} to {target_class}.",
          "x" = e$message
        ), colname = colname, target_class = target_class)
      }
    )

    result
  }, dat_to_type[common], dat_w_types[common], common, SIMPLIFY = FALSE)

  dat_to_type
}
