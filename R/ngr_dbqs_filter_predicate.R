#' Construct a SQL Query Using Spatial Predicates
#'
#' This function generates a SQL query to filter and join tables based on spatial predicates. Should work on any SQL
#' database that supports spatial functions.
#'
#' @details To enable geopackage support:
#'
#' 1. Install spatialite-tools on cmd line with
#'
#'    `brew install spatialite-tools`
#'
#' 2. Find your installation on cmd line with
#'
#'    `find /opt/homebrew -name mod_spatialite.dylib`
#'
#' 3. Then Connect to GeoPackage in R with
#'
#'    `con <- DBI::dbConnect(RSQLite::SQLite(), path_to_gpkg)`
#'
#' 4. Load SpatiaLite
#'
#'    `dbExecute(con, "SELECT load_extension('/opt/homebrew/lib/mod_spatialite.dylib');")`
#'
#' 5. Run queries with
#'
#'    `DBI::dbGetQuery(con, query = ngr_dbqs_filter_predicate(blah, blah, blah, quote_tbl = TRUE))`
#'
#' @param target_tbl [character] The name of the target table. Required.
#' @param mask_tbl [character] The name of the mask table. Required.
#' @param target_col_return [character] Columns to return from the target table. Default is '*', meaning all columns.
#' @param mask_col_return [character] Columns to return from the mask table. Default is `NULL`, meaning no columns are returned.
#' @param mask_col_filter [character] The column from the mask table used for filtering. Default is `NULL`.
#' @param mask_col_filter_values [character] Values to filter the mask column by. Default is `NULL`.
#' @param mask_col_filter_values_negate [logical] Whether to negate the filter condition for the mask column. Default is `FALSE`.
#' @param function_spatial [character] The spatial function to use for filtering, e.g., "ST_Intersects". Default is "ST_Intersects". Valid options are:
#'   - `ST_Intersects`
#'   - `ST_Contains`
#'   - `ST_Within`
#'   - `ST_Overlaps`
#'   - `ST_Crosses`
#'   - `ST_Touches`
#'
#'   For more details on spatial functions, see
#'   [PostGIS Query Functions](https://postgis.net/docs/using_postgis_query.html#:~:text=To%20make%20it%20easy%20to,%2C%20ST_Overlaps%2C%20ST_Touches%2C%20ST_Within.).
#'
#' @param quote_tbl [logical] Whether to quote table names to handle special characters. Default is `FALSE`. Allows
#' quoting to be adjusted so can be used in geopackage when table names have periods in them.  Uses [ngr_dbqs_tbl_quote()] to quote table names.
#' @param ... Additional arguments passed to `ngr::ngr_fdb_tbl_quote()` if `quote_tbl` is `TRUE`.
#'
#' @return [character] A SQL query string.
#'
#' @examples
#' ngr_dbqs_filter_predicate(
#'   target_tbl = "target_table",
#'   mask_tbl = "mask_table",
#'   target_col_return = c("col1", "col2"),
#'   mask_col_return = c("filter_col"),
#'   mask_col_filter = "filter_col",
#'   mask_col_filter_values = c("value1", "value2"),
#'   function_spatial = "ST_Intersects"
#' )
#'
#' @importFrom glue glue glue_collapse
#' @importFrom cli cli_abort cli_alert_danger
#' @export
#' @family spatial
ngr_dbqs_filter_predicate <- function(
    target_tbl,
    mask_tbl,
    target_col_return = '*',
    mask_col_return = NULL,
    mask_col_filter = NULL,
    mask_col_filter_values = NULL,
    mask_col_filter_values_negate = FALSE,
    function_spatial = 'ST_Intersects',
    quote_tbl = FALSE,
    ...
) {
  # Validate spatial function choice
  valid_functions <- c(
    "ST_Intersects",
    "ST_Contains",
    "ST_Within",
    "ST_Overlaps",
    "ST_Crosses",
    "ST_Touches"
  )

  if (!function_spatial %in% valid_functions)  {
    cli::cli_abort("{function_spatial} in not a valid spatial function.  Please select from {valid_functions}")
  }

  # Wrap scalar inputs in vectors
  if (!is.null(target_col_return) && !is.vector(target_col_return)) {
    target_col_return <- c(target_col_return)
  }
  if (!is.null(mask_col_return) && !is.vector(mask_col_return)) {
    mask_col_return <- c(mask_col_return)
  }
  if (!is.null(mask_col_filter_values) && !is.vector(mask_col_filter_values)) {
    mask_col_filter_values <- c(mask_col_filter_values)
  }

  chk::chk_not_null(target_tbl)
  chk::chk_not_null(mask_tbl)
  chk::chk_string(target_tbl)
  chk::chk_string(mask_tbl)
  chk::chk_not_null(target_col_return)
  chk::chk_vector(target_col_return)
  if (!is.null(mask_col_return)) {
    chk::chk_vector(mask_col_return)
  }
  if (!is.null(mask_col_filter)) {
    chk::chk_vector(mask_col_filter)
  }
  if (!is.null(mask_col_filter_values)) {
    chk::chk_vector(mask_col_filter_values)
  }

  # Check if '*' is an element of mask_col_return, if mask_col_return is not NULL
  if (!is.null(mask_col_return) && '*' %in% mask_col_return) {
    cli::cli_abort(message = "Using '*' for mask_col_return is not allowed. Please specify mask_col_return explicitly or
                   leave it NULL if no additional columns are needed from the mask layer.")
  }

  if ("geom" %in% target_col_return) {
    cli::cli_abort("explicitly requesting 'geom' in target_col_return is not necessary as it will be returned.
                    Pleae revise target_col_return input")
  }

  # Check if 'target_col_return' is a single value equal to "*" and capture that
  is_star <- identical(target_col_return, "*")
  # Use 'is_star' to decide whether to construct the columns string or use 'target.*'
  cols_target_str <- if (!is_star) {
    glue::glue_collapse(
      glue::glue("target.{target_col_return}"),
      sep = ", "
    )
  } else {
    "target.*"
  }

  # Check if 'mask_col_return' is NULL or has values and construct 'cols_mask_str' accordingly
  cols_mask_str <- if (!is.null(mask_col_return) && length(mask_col_return) > 0) {

    # Construct the mask columns string
    mask_cols <- glue::glue("mask.{mask_col_return}")
    mask_cols_glued <- glue::glue_collapse(mask_cols, sep = ", ")
    glue::glue(", {mask_cols_glued}")  # Adding a leading comma for SQL syntax
  } else {
    ""  # If 'mask_col_return' is NULL or empty, no mask columns are added
  }

  # Adjust the filtering condition for the mask layer based on mask_col_filter_values_negate
  mask_filter_condition <- if (!is.null(mask_col_filter) && !is.null(mask_col_filter_values)) {
    filter_values_str <- glue::glue_collapse(
      glue::glue("'{mask_col_filter_values}'"),
      sep = ", "
    )
    if (mask_col_filter_values_negate) {
      glue::glue(" AND mask.{mask_col_filter} NOT IN ({filter_values_str})")
    } else {
      glue::glue(" AND mask.{mask_col_filter} IN ({filter_values_str})")
    }
  } else {
    ""
  }

  join_condition <- glue::glue("{function_spatial}(target.geom, mask.geom){mask_filter_condition}")

  if (quote_tbl) {
    target_tbl <- ngr::ngr_dbqs_tbl_quote(target_tbl, ...)
    mask_tbl <- ngr::ngr_dbqs_tbl_quote(mask_tbl, ...)
  }

  query <- glue::glue(
    "SELECT {cols_target_str}{cols_mask_str} ",
    "FROM {target_tbl} AS target ",
    "JOIN {mask_tbl} AS mask ON {join_condition};"
  )

  return(query)
}
