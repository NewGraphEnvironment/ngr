#' Extract Layer Information from QGIS Project
#'
#' Reads a QGIS project file (`.qgs` or `.qgz`) and extracts layer metadata, including menu name, provider, data source, and layer name.
#'
#' @param path [character] A single file path to a QGIS project file. Must end with `.qgs` or `.qgz`.
#'
#' @details
#' If the input is a `.qgz` file, it will be unzipped to extract the internal `project.qgs`. The function then parses the XML structure of the project to extract layer information from `<layer-tree-layer>` nodes.
#'
#' Returned columns include:
#' - `name_menu`: layer name as displayed in the QGIS menu
#' - `provider`: data provider key (e.g., `ogr`, `gdal`)
#' - `source`: absolute or relative path to the data source
#' - `layer_name`: the internal layer name string
#' - `id`: QGIS-assigned layer id
#' - `time_exported`: timestamp in format `yyyymmdd hh::mm` when the function was run
#'
#' @return A [tibble::tibble] with one row per layer, including `name_menu`, `provider`, `source`, `layer_name`, `id`, and `time_exported`, sorted alphabetically by `name_menu`.
#'
#' @examples
#' \dontrun{
#' res <- ngr_spk_q_layer_info(
#'   "/Users/airvine/Projects/gis/ng_koot_west_2023/ng_koot_west_2023.qgs"
#' )
#' }
#'
#' @importFrom fs path_temp dir_create path path_dir path_abs
#' @importFrom xml2 read_xml xml_ns_strip xml_find_all xml_attr
#' @importFrom tibble tibble
#' @importFrom dplyr mutate if_else select arrange
#' @family spacehakr
#' @export
ngr_spk_q_layer_info <- function(path) {
  # Validate input
  chk::chk_string(path)

  if (grepl("\\.qgz$", path, ignore.case = TRUE)) {
    tmpdir <- fs::path_temp("qgz"); fs::dir_create(tmpdir)
    unzip(path, files = "project.qgs", exdir = tmpdir)
    path <- fs::path(tmpdir, "project.qgs")
  }

  doc <- xml2::read_xml(path); xml2::xml_ns_strip(doc)
  proj_dir <- fs::path_dir(path)

  nodes <- xml2::xml_find_all(doc, "//layer-tree-layer[@id]")
  tibble::tibble(
    id         = xml2::xml_attr(nodes, "id"),
    name_menu  = xml2::xml_attr(nodes, "name"),
    provider   = xml2::xml_attr(nodes, "providerKey"),
    source_raw = xml2::xml_attr(nodes, "source")
  ) |>
    dplyr::mutate(
      source = dplyr::if_else(
        startsWith(source_raw, "./"),
        fs::path_abs(fs::path(proj_dir, substring(source_raw, 3L))),
        source_raw
      ),
      layer_name   = sub(".*\\|layername=([^|]+).*", "\\1", source_raw),
      time_exported = format(Sys.time(), "%Y%m%d %H:%M")
    ) |>
    dplyr::select(name_menu, provider, source, layer_name, id, time_exported) |>
    dplyr::arrange(name_menu)
}
