# Download a Vector Layer from a GeoServer WFS

**\[deprecated\]**

Moved to
[`spacehakr::spk_geoserv_dlv()`](https://rdrr.io/pkg/spacehakr/man/spk_geoserv_dlv.html).
This wrapper forwards its arguments unchanged and will be removed in a
future release — call
[`spacehakr::spk_geoserv_dlv()`](https://rdrr.io/pkg/spacehakr/man/spk_geoserv_dlv.html)
directly.

**Behaviour change.**
[`spacehakr::spk_geoserv_dlv()`](https://rdrr.io/pkg/spacehakr/man/spk_geoserv_dlv.html)
aborts via
[`cli::cli_abort()`](https://cli.r-lib.org/reference/cli_abort.html) on
a non-200 response. This version printed a message and returned the
output path regardless, so a failed download looked like a successful
one. The success message also moves from
[`cat()`](https://rdrr.io/r/base/cat.html) on stdout to
[`cli::cli_alert_success()`](https://cli.r-lib.org/reference/cli_alert.html)
on stderr, so anything capturing stdout sees a different result.

## Usage

``` r
ngr_spk_geoserv_dlv(...)
```

## Arguments

- ...:

  Passed unchanged to
  [`spacehakr::spk_geoserv_dlv()`](https://rdrr.io/pkg/spacehakr/man/spk_geoserv_dlv.html),
  which owns the argument list and its defaults.

## Value

The value of
[`spacehakr::spk_geoserv_dlv()`](https://rdrr.io/pkg/spacehakr/man/spk_geoserv_dlv.html).

## See also

[`spacehakr::spk_geoserv_dlv()`](https://rdrr.io/pkg/spacehakr/man/spk_geoserv_dlv.html)

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
[`ngr_spk_res()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_res.md),
[`ngr_spk_stac_calc()`](https://newgraphenvironment.github.io/ngr/reference/ngr_spk_stac_calc.md)
