#' Retrieve Realtime HYDAT Data for a Station
#'
#' Convenience function to fetch primary and secondary water survey parameters for a given HYDAT station
#' over a specified number of days. Wraps [tidyhydat::realtime_ws()] with main advantage that it relies on the
#' availability of temperature data (or some other `param_primary` to be present before it will attempt to obtain
#' secondary data.
#'
#' @param id_station [character] A single station identifier string.
#' @param param_primary [numeric] A numeric vector of primary HYDAT parameter codes.
#' @param param_secondary [numeric] A numeric vector of secondary HYDAT parameter codes. This data is only retrieved if
#' there is primary data available. See the available options with [tidyhydat::param_id]
#' @param days_back [numeric] A single integer specifying how many days back to fetch data. Defaults to 581 which seems
#' to be the maximum amount retrievable
#'
#' @return A list with two elements: `primary_data` and `secondary_data`, each a data frame of results. Returns `NULL` on failure and prints a CLI alert.
#'
#' @seealso [tidyhydat::realtime_ws()]
#'
#' @importFrom tidyhydat realtime_ws
#' @importFrom cli cli_alert
#' @importFrom dplyr bind_rows
#' @export
ngr_hyd_realtime <- function(id_station = NULL,
                             param_primary = c(5),
                             param_secondary = c(
                               1, 18, 19, 41, 46,
                               # params with "Discharge in the name"
                               6, 7, 8, 10, 40, 47
                             ),
                             # think this is the max we can go back for water temp (param 5)
                             days_back = 581){
  tryCatch(
    {
      primary_data <- tidyhydat::realtime_ws(
        station_number = id_station,
        parameters = param_primary,
        start_date = Sys.Date() - days_back,
        end_date = Sys.Date()
      )

      secondary_data <- NULL
      if (!is.null(param_secondary)) {
        if (!is.null(primary_data)) {
          secondary_data <- tryCatch(
            {
              tidyhydat::realtime_ws(
                station_number = id_station,
                parameters = param_secondary,
                start_date = Sys.Date() - days_back,
                end_date = Sys.Date()
              )
            },
            error = function(e) {
              cli::cli_alert(paste("Failed to retrieve secondary data for station", id_station, "Error:", e$message))
              return(NULL)
            }
          )
        }
      }

      dplyr::bind_rows(primary_data, secondary_data)
    },
    error = function(e) {
      cli::cli_alert(paste("Failed to retrieve primary data for station", id_station, "Error:", e$message))
      return(NULL)
    }
  )
}
