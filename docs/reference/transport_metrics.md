# Compute Transport Metrics for an AOI

This function is a wrapper around [`osm_metrics()`](osm_metrics.md) and
processes the output of
[`transport_structure()`](transport_structure.md). It calculates
geometry-based transport metrics per category and provides a structured
summary for downstream analysis within the URBANmetRics workflow.

## Usage

``` r
transport_metrics(transport_result, aoi)
```

## Arguments

- transport_result:

  An `sf` object returned by
  [`transport_structure()`](transport_structure.md), containing
  transport features with a `category` column.

- aoi:

  An `sf` polygon representing the Area of Interest. Must be a valid
  `sf` object.

## Value

A named list containing:

- AOI:

  AOI area in m² and km²

- summary:

  Total transport area, length, count, and AOI shares

- categories:

  A data frame of transport metrics per category returned by
  [`osm_metrics()`](osm_metrics.md)

## Details

The function:

- projects the AOI and transport features to a metric CRS (EPSG:3857),

- computes category-level metrics using
  [`osm_metrics()`](osm_metrics.md),

- calculates total transport area, length, and feature count,

- returns a structured list containing AOI information, summary
  statistics, and category-level metrics.

This function provides the transport-specific metrics layer of the
URBANmetRics workflow. It does not classify transport features (this is
handled in [`transport_structure()`](transport_structure.md)), but
instead computes geometric and density-based metrics for each transport
category.

Transport metrics differ from building and green metrics because linear
features (e.g., roads, railways, cycleways) play a dominant role.
Therefore, the summary includes total length and length-based density
indicators.

The modular design ensures:

- consistent metric definitions across domains,

- reproducibility,

- separation of concerns between structure extraction and metric
  computation.

## Examples

``` r
if (FALSE) { # \dontrun{
transport <- transport_structure(aoi)
metrics <- transport_metrics(transport, aoi)
metrics$summary
} # }
```
