# Compute Green Space Metrics for an AOI

This function is a wrapper around [`osm_metrics()`](osm_metrics.md) and
processes the output of [`green_structure()`](green_structure.md). It
calculates geometry-based green-space metrics per category and provides
a structured summary for downstream analysis within the URBANmetRics
workflow.

## Usage

``` r
green_metrics(green_result, aoi)
```

## Arguments

- green_result:

  An `sf` object returned by [`green_structure()`](green_structure.md),
  containing green-space features with a `category` column.

- aoi:

  An `sf` polygon representing the Area of Interest. Must be a valid
  `sf` object.

## Value

A named list containing:

- AOI:

  AOI area in m² and km²

- summary:

  Total green area and its share of the AOI

- categories:

  A data frame of green-space metrics per category returned by
  [`osm_metrics()`](osm_metrics.md)

## Details

The function:

- projects the AOI and green features to a metric CRS (EPSG:3857),

- computes category-level metrics using
  [`osm_metrics()`](osm_metrics.md),

- calculates total green area and its share of the AOI,

- returns a structured list containing AOI information, summary
  statistics, and category-level metrics.

This function provides the green-specific metrics layer of the
URBANmetRics workflow. It does not classify green features (this is
handled in [`green_structure()`](green_structure.md)), but instead
computes geometric and density-based metrics for each green-space
category.

The modular design ensures:

- consistent metric definitions across domains,

- reproducibility,

- separation of concerns between structure extraction and metric
  computation

## Examples

``` r
if (FALSE) { # \dontrun{
greens <- green_structure(aoi)
metrics <- green_metrics(greens, aoi)
metrics$summary
} # }
```
