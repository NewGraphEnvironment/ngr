
test_that("ngr_dbqs_filter_predicate constructs the correct SQL query", {
  result <- ngr_dbqs_filter_predicate(
    target_tbl = "whse_admin_boundaries.clab_indian_reserves",
    mask_tbl = "whse_basemapping.fwa_watershed_groups_poly",
    mask_col_filter = "watershed_group_code",
    mask_col_filter_values = c("FRAN", "NECR")
  )

  expected <- paste(
    "SELECT target.* ",
    "FROM whse_admin_boundaries.clab_indian_reserves AS target ",
    "JOIN whse_basemapping.fwa_watershed_groups_poly AS mask ON ST_Intersects(target.geom, mask.geom) ",
    "AND mask.watershed_group_code IN ('FRAN', 'NECR');",
    sep = ""
  )

  expect_equal(result, expected)
})

test_that("ngr_dbqs_filter_predicate constructs the correct SQL query with ST_Within", {
  result <- ngr_dbqs_filter_predicate(
    target_tbl = "whse_fish.pscis_design_proposal_svw",
    mask_tbl = "whse_basemapping.fwa_watershed_groups_poly",
    mask_col_filter = "watershed_group_code",
    mask_col_filter_values = c("FRAN", "NECR"),
    function_spatial = "ST_Within"
  )

  expected <- paste(
    "SELECT target.* ",
    "FROM whse_fish.pscis_design_proposal_svw AS target ",
    "JOIN whse_basemapping.fwa_watershed_groups_poly AS mask ON ",
    "ST_Within(target.geom, mask.geom) AND mask.watershed_group_code IN ('FRAN', 'NECR');",
    sep = ""
  )

  expect_equal(result, expected)
})

