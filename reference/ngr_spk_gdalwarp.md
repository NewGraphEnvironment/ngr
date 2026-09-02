# Generate GDALWarp Command Arguments

**\[deprecated\]**

Moved to
[`spacehakr::spk_gdalwarp()`](http://www.newgraphenvironment.com/spacehakr/reference/spk_gdalwarp.md).
This wrapper forwards its arguments unchanged and will be removed in a
future release — call
[`spacehakr::spk_gdalwarp()`](http://www.newgraphenvironment.com/spacehakr/reference/spk_gdalwarp.md)
directly.

**Behaviour change.**
[`spacehakr::spk_gdalwarp()`](http://www.newgraphenvironment.com/spacehakr/reference/spk_gdalwarp.md)
places `params_add` *before* the input and output paths; this version
appended them after. GDAL tolerates flags in either position, so most
`params_add` values behave identically. The case that differs is a
`params_add` ending in a bare non-option token: appended last it is
taken as the destination, and the intended output path is demoted to a
source.

## Usage

``` r
ngr_spk_gdalwarp(...)
```

## Arguments

- ...:

  Passed unchanged to
  [`spacehakr::spk_gdalwarp()`](http://www.newgraphenvironment.com/spacehakr/reference/spk_gdalwarp.md),
  which owns the argument list and its defaults.

## Value

The value of
[`spacehakr::spk_gdalwarp()`](http://www.newgraphenvironment.com/spacehakr/reference/spk_gdalwarp.md).

## See also

[`spacehakr::spk_gdalwarp()`](http://www.newgraphenvironment.com/spacehakr/reference/spk_gdalwarp.md)

Other spacehakr:
[`ngr_spk_geoserv_dlv()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_geoserv_dlv.md),
[`ngr_spk_join()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_join.md),
[`ngr_spk_layer_info()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_layer_info.md),
[`ngr_spk_odm()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_odm.md),
[`ngr_spk_poly_to_points()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_poly_to_points.md),
[`ngr_spk_q_layer_info()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_q_layer_info.md),
[`ngr_spk_rast_ext()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_rast_ext.md),
[`ngr_spk_rast_not_empty()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_rast_not_empty.md),
[`ngr_spk_rast_rm_empty()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_rast_rm_empty.md),
[`ngr_spk_res()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_res.md),
[`ngr_spk_stac_calc()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_stac_calc.md)
