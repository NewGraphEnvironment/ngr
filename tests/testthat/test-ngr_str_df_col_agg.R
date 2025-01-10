# path <- system.file("extdata", "form_fiss_site_2024.gpkg", package = "ngr")
#
# df <- sf::st_read(path)
#
# # dat |> dplyr::select(dplyr::matches("ave|avg"))
#
# col_str_negate = "time|method|avg|ave"
#
# col_str_match = "channel_width"
# result <- ngr_str_df_col_agg(
#   dat = df,
#   col_str_match = col_str_match,
#   col_result = "avg_channel_width_m",
#   col_str_negate = col_str_negate,
#   decimal_places = 1
# )
#
# result |>
#   dplyr::select(dplyr::contains(col_str_match)) |>
#   print()
#
# col_str_match = "wetted_width"
# result <- ngr_str_df_col_agg(
#   dat = df,
#   col_str_match = col_str_match,
#   col_result = "avg_wetted_width_m",
#   col_str_negate = col_str_negate,
#   decimal_places = 1
# )
#
# result |>
#   dplyr::select(dplyr::contains(col_str_match)) |>
#   print()
#
#
# col_str_match <-  "residual_pool"
# result <- ngr_str_df_col_agg(
#   dat = df,
#   col_str_match = col_str_match,
#   col_result = "average_residual_pool_depth_m",
#   col_str_negate = "time|method|avg|ave",
#   decimal_places = 1
# )
#
# result |>
#   dplyr::select(dplyr::contains(col_str_match)) |>
#   print()
#
# col_str_match <- "gradient"
# result <- ngr_str_df_col_agg(
#   dat = df,
#   col_str_match = col_str_match,
#   col_result = "average_gradient_percent",
#   col_str_negate = "time|method|avg|ave",
#   decimal_places = 1
# )
#
# result |>
#   dplyr::select(dplyr::contains(col_str_match)) |>
#   print()
#
#
