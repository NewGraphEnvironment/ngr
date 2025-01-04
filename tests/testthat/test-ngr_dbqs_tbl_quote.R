a <- ngr_dbqs_tbl_quote("whse_admin_boundaries.clab_indian_reserves")
b <- "whse_admin_boundaries.clab_indian_reserves"
identical(a, b)


path <- "/Users/airvine/Projects/gis/sern_skeena_2023/background_layers.gpkg"

t <- sf::st_read(
  dsn = path,
  #test_intersects_poly <- fpr_db_query(
  query = "SELECT * FROM 'whse_admin_boundaries.clab_indian_reserves'"
  )

library(DBI)
library(RSQLite)

# Connect to GeoPackage
con <- dbConnect(RSQLite::SQLite(), path)

# Load SpatiaLite
dbExecute(con, "SELECT load_extension('/opt/homebrew/lib/mod_spatialite.dylib');")

query <- ngr_dbqs_filter_predicate(
  target_tbl = "whse_admin_boundaries.clab_indian_reserves",
  mask_tbl = "whse_basemapping.fwa_watershed_groups_poly",
  mask_col_filter = "watershed_group_code",
  mask_col_filter_values = c("BULK"),
  quote_tbl = TRUE
)

result <- DBI::dbGetQuery(con, query)
print(result)

dbDisconnect(con)
