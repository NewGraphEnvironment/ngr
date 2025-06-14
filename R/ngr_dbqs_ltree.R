#' Cast Character to PostgreSQL ltree
#'
#' Constructs a PostgreSQL ltree literal from a character string.
#' This is useful for composing queries that rely on ltree path syntax.
#'
#' @param x [character] A single string or character vector to be cast to `ltree`.
#'
#' @returns [character] A string or character vector of PostgreSQL ltree-compatible text. Each element is wrapped in single quotes and cast with `::ltree`.
#'
#' @details
#' This function is typically used to help construct PostgreSQL queries that operate on `ltree` data types.
#' It simply formats each input string into the PostgreSQL `ltree` cast syntax.
#'
#'
#' @importFrom chk chk_character
#'
#' @export
#'
#' @family Database Query
#'
#' @examples
#' ngr_dbqs_ltree("400.431358.623573")
#'
ngr_dbqs_ltree <- function(x) {
  chk::chk_character(x)
  paste0("'", x, "'::ltree")
}
