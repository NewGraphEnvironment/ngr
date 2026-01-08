#' Combine daily Streamflow Data from HYDAT and ECCC Realtime Sources
#'
#' Retrieve and amalgamate daily streamflow data for one or more HYDAT stations,
#' combining historical daily flows from HYDAT with available realtime daily flow
#' data where supported. The function warns when realtime data are unavailable and
#' checks for missing dates in the combined time series.
#'
#' @param id_station [character] A character vector of one or more HYDAT station IDs
#' @param date_rt_start [Date] Optional. A single start date (or string coercible to date) for realtime data retrieval.
#'   Defaults to `Sys.Date() - 581` (18 months).
#' @param date_rt_end [Date] Optional. A single end date (or string coercible to date) for realtime data retrieval.
#'   Defaults to `Sys.Date()`.
#' @param date_hydat_start [character] Optional. A single date (or string coercible to date) giving the start
#'   date for historical HYDAT daily flows. Default is "1980-01-01".
#' @param ... Optional. Additional arguments passed to
#'   [ngr::ngr_chk_dt_complete()] when checking for missing dates within each
#'   `STATION_NUMBER` time series (ex print_missing = FALSE).
#'
#' @details
#' Historical daily flows are retrieved using
#' [tidyhydat::hy_daily_flows()]. Realtime daily flows are retrieved using
#' [tidyhydat::realtime_ws()] for stations that support realtime reporting, as
#' identified by [tidyhydat::realtime_stations()]. Realtime data are coerced to
#' daily resolution and typed to match the HYDAT data using
#' [ngr::ngr_tidy_type()].
#'
#' Input dates are validated using [ngr::ngr_chk_coerce_date()]. Missing daily
#' timestamps are checked per station using [ngr::ngr_chk_dt_complete()].
#'
#' Duplicate station-date records are removed, keeping historical HYDAT values
#' where overlaps occur. The function reports stations with missing dates using
#' cli messages.
#'
#' @returns
#' A data frame containing daily streamflow data for the requested stations.
#' Warnings are emitted when realtime data are unavailable for some stations or
#' when missing dates are detected.
#'
#' @examples
#' ngr_hyd_q_daily(id_station = c("08NH118", "08NH126"))
#'
#' @importFrom tidyhydat hy_daily_flows realtime_ws realtime_stations
#' @importFrom dplyr bind_rows distinct
#' @importFrom cli cli_alert_warning cli_alert_success
#'
#' @export
ngr_hyd_q_daily <- function(
    id_station,
    date_rt_start = Sys.Date() - 581,
    date_rt_end = Sys.Date(),
    date_hydat_start = "1980-01-01",
    ...
){
  ngr_chk_coerce_date(date_rt_start)
  ngr_chk_coerce_date(date_rt_end)
  ngr_chk_coerce_date(date_hydat_start)
  chk::chk_character(id_station)

  hy_hy <- tidyhydat::hy_daily_flows(
    station_number = id_station,
    start_date = date_hydat_start
  )
  # below used for test
  # dplyr::filter(
  #   Date < "2018-01-01" | Date > "2018-01-03"
  # )

  stations_all <- tidyhydat::realtime_stations()[["STATION_NUMBER"]]
  stations_no_rt <- setdiff(id_station, stations_all)
  if (!all(id_station %in% stations_all)) {
    cli::cli_alert_warning("There is no realtime daily flow data for {stations_no_rt}")
  }

  stations_rt <- setdiff(id_station, stations_no_rt)

  if (length(stations_rt) > 0) {
    hy_rt <- tidyhydat::realtime_ws(
      station_number = stations_rt,
      parameters = 6,
      start_date = date_rt_start,
      end_date = date_rt_end
    )

    hy_rt$Date <- as.Date(hy_rt$Date)

    hy_rt <- ngr::ngr_tidy_type(dat_w_types = hy_hy, dat_to_type = hy_rt)

    hy_all <- dplyr::bind_rows(hy_hy, hy_rt)
  }

  if (length(stations_rt) == 0) {
    hy_all <- hy_hy
  }

  hy_all <- dplyr::distinct(
    hy_all,
    STATION_NUMBER,
    Date,
    .keep_all = TRUE
  )

  by_station <- split(hy_all$Date, hy_all$STATION_NUMBER)
  by_station <- by_station[order(names(by_station))]

  bad <- character()

  for (stn in names(by_station)) {
    ok <- ngr_chk_dt_complete(
      by_station[[stn]],
      units = "days",
      ...
    )

    if (!ok) {
      cli::cli_alert_warning("Station {stn} missing dates printed above")
      bad <- c(bad, stn)
    }
  }

  return(hy_all)
}
