files_in <- fs::path(
  "/Volumes/backup_2022/backups/new_graph/archive/uav_imagery/skeena/bulkley/sakals_2024",
  c(
    "fullres-0-0.tif",
    "fullres-0-1.tif",
    "fullres-1-0.tif",
    "fullres-1-1.tif"
  )
)

file_out <- "/Volumes/backup_2022/backups/new_graph/archive/uav_imagery/skeena/bulkley/2024/bulkley-mckilligan-barren/test.tif"

args <- ngr::ngr_spk_gdalwarp(
  path_in = files_in,
  path_out = file_out,
  t_srs = "EPSG:32609",
  target_resolution = c(1, 1)
)

expected_args <- c(
  "-overwrite",
  "-multi", "-wo", "NUM_THREADS=ALL_CPUS",
  "-t_srs", "EPSG:32609",
  "-r", "bilinear",
  "-tr", "1", "1",
  files_in,
  file_out
)



test_that("ngr_spk_gdalwarp constructs correct arguments", {
  expect_equal(args, expected_args)
})


# processx::run(
#   command = "gdalwarp",
#   args = args,
#   echo = TRUE,
#   spinner = TRUE
# )
