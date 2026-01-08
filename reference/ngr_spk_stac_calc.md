# Spectral index calculation from a STAC item

Compute a spectral index for a single STAC item. By default, the
function reads red and near-infrared (NIR) assets to compute NDVI, but
this is only the default configuration. The function is designed to read
any two or three assets and apply different spectral index calculations
as they are added in the future.

## Usage

``` r
ngr_spk_stac_calc(
  feature,
  aoi = NULL,
  asset_a = "red",
  asset_b = "nir08",
  asset_c = NULL,
  calc = "ndvi",
  vsi_prefix = "/vsicurl/",
  quiet = FALSE,
  timing = FALSE
)
```

## Arguments

- feature:

  [list](https://rdrr.io/r/base/list.html) A single STAC Item (one
  element from an `items$features` list).

- aoi:

  [sf::sf](https://r-spatial.github.io/sf/reference/sf.html) or
  [NULL](https://rdrr.io/r/base/NULL.html) Optional. An AOI object used
  to restrict reads (by bbox) and to crop and mask the output. If
  `NULL`, the full assets are read and no crop/mask is applied. Default
  is `NULL`.

- asset_a:

  [character](https://rdrr.io/r/base/character.html) Optional. A single
  string giving the asset name for the first input band. For NDVI this
  corresponds to the red band. Default is `"red"`.

- asset_b:

  [character](https://rdrr.io/r/base/character.html) Optional. A single
  string giving the asset name for the second input band. For NDVI this
  corresponds to the NIR band. Default is `"nir08"`.

- asset_c:

  [character](https://rdrr.io/r/base/character.html) or
  [NULL](https://rdrr.io/r/base/NULL.html) Optional. A single string
  giving the asset name for an optional third input band, used by some
  calculations. Default is `NULL`.

- vsi_prefix:

  [character](https://rdrr.io/r/base/character.html) Optional. A single
  string giving the GDAL VSI prefix used by
  [`terra::rast()`](https://rspatial.github.io/terra/reference/rast.html)
  to enable streaming, windowed reads over HTTP. Exposed to allow
  alternative VSI backends (e.g. `/vsis3/`). Default is `"/vsicurl/"`.

- quiet:

  [logical](https://rdrr.io/r/base/logical.html) Optional. If `TRUE`,
  suppress CLI messages. Default is `FALSE`.

- timing:

  [logical](https://rdrr.io/r/base/logical.html) Optional. If `TRUE`,
  emit simple elapsed-time messages for reads. Default is `FALSE`.

## Value

A
[terra::SpatRaster](https://rspatial.github.io/terra/reference/SpatRaster-class.html)
with calculated index values.

## Details

The default asset names (`"red"` and `"nir08"`) align with common
conventions in Landsat Collection 2 Level-2 STAC items (e.g. the
`landsat-c2-l2` collection on Planetary Computer), but are fully
parameterized to support other collections with different band naming
schemes.

This function expects `feature` to provide the required `assets`
referenced by `asset_a`, `asset_b`, and (if used) `asset_c`. When `aoi`
is not `NULL`, `feature` must also have `properties$"proj:epsg"` so the
AOI can be transformed for windowed reads.

The calculation performed is controlled by `calc`. By default,
`calc = "ndvi"` computes the Normalized Difference Vegetation Index
using `(b - a) / (b + a)`. This structure allows additional spectral
indices (e.g. NDWI, EVI) to be added in the future without changing the
data access or cropping logic.

When `aoi` is provided, reading is limited to the AOI bounding box in
the feature's projected CRS, and then cropped/masked to the AOI. When
`aoi = NULL`, the full assets are read and the calculated raster is
returned for the full raster extent.

## Production-ready alternative

This function is a proof of concept demonstrating how to perform raster
calculations on STAC items using `terra`. For production workflows
involving time series reductions, multi-image composites, or data cubes
with varying pixel sizes and coordinate reference systems, consider the
[gdalcubes](https://github.com/appelmar/gdalcubes) package. Key
functions include:

- `gdalcubes::stac_image_collection()`: Create an image collection
  directly from STAC query results with automatic band detection and VSI
  prefix handling.

- `gdalcubes::cube_view()`: Define spatiotemporal extent, resolution,
  aggregation, and resampling method in a single specification.

- `gdalcubes::raster_cube()`: Build a data cube from an image
  collection, automatically reprojecting and resampling images to a
  common grid.

- `gdalcubes::apply_pixel()`: Apply arithmetic expressions (e.g.,
  `"(nir - red) / (nir + red)"`) across all pixels.

- `gdalcubes::reduce_time()`: Temporal reductions (mean, median, max,
  etc.) to composite multi-date imagery.

## See also

[`terra::rast()`](https://rspatial.github.io/terra/reference/rast.html),
[`terra::crop()`](https://rspatial.github.io/terra/reference/crop.html),
[`terra::mask()`](https://rspatial.github.io/terra/reference/mask.html),
[`sf::st_transform()`](https://r-spatial.github.io/sf/reference/st_transform.html)

Other spacehakr:
[`ngr_spk_gdalwarp()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_gdalwarp.md),
[`ngr_spk_join()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_join.md),
[`ngr_spk_layer_info()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_layer_info.md),
[`ngr_spk_odm()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_odm.md),
[`ngr_spk_poly_to_points()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_poly_to_points.md),
[`ngr_spk_q_layer_info()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_q_layer_info.md),
[`ngr_spk_rast_ext()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_rast_ext.md),
[`ngr_spk_rast_not_empty()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_rast_not_empty.md),
[`ngr_spk_rast_rm_empty()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_rast_rm_empty.md),
[`ngr_spk_res()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_res.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# STAC query against Planetary Computer (Landsat C2 L2)
stac_url <- "https://planetarycomputer.microsoft.com/api/stac/v1"
y <- 2000
date_time <- paste0(y, "-05-01/", y, "-07-30")

# Define an AOI from a bounding box (WGS84)
bbox <- c(
  xmin = -126.55350240037997,
  ymin =  54.4430453753869,
  xmax = -126.52422763064457,
  ymax =  54.46001902038006
)

aoi <- sf::st_as_sfc(sf::st_bbox(bbox, crs = 4326)) |>
  sf::st_as_sf()

stac_query <- rstac::stac(stac_url) |>
  rstac::stac_search(
    collections = "landsat-c2-l2",
    datetime = date_time,
    intersects = sf::st_geometry(aoi)[[1]],
    limit = 200
  ) |>
  rstac::ext_filter(`eo:cloud_cover` <= 10)

items <- stac_query |>
  rstac::post_request() |>
  rstac::items_fetch() |>
  rstac::items_sign_planetary_computer()

ndvi_list <- items$features |>
  purrr::map(ngr_spk_stac_calc, aoi = aoi)

ndvi_list <- ndvi_list |>
  purrr::set_names(purrr::map_chr(items$features, "id"))
} # }
```
