# Compute Basic OSM Metrics for an AOI

This function calculates core geometric and density-based metrics for
OSM features extracted with [`osm_structure()`](osm_structure.md). It
represents the metrics-level foundation of the URBANmetRics workflow.
Wrapper functions such as [`building_metrics()`](building_metrics.md),
[`green_metrics()`](green_metrics.md), and
[`transport_metrics()`](transport_metrics.md) build on this function to
compute domain-specific indicators.

## Usage

``` r
osm_metrics(osm_raw, aoi)
```

## Arguments

- osm_raw:

  An `sf` object returned by [`osm_structure()`](osm_structure.md),
  containing OSM features with a `category` column.

- aoi:

  An `sf` polygon representing the Area of Interest. Must be a valid
  `sf` object.

## Value

A data frame containing aggregated OSM metrics per category, including:

- category:

  Feature category assigned by the structure wrapper

- Area_m2:

  Total area of polygonal features

- Length_m:

  Total length of linear features

- Count:

  Total feature count

- Area_Share_percent:

  Share of total area across categories

- Length_Share_percent:

  Share of total length across categories

- Count_Share_percent:

  Share of total count across categories

- Area_Share_AOI_percent:

  Area share relative to AOI size

- Length_Share_AOI_percent:

  Length share relative to AOI size

- Count_Share_AOI_percent:

  Count share relative to total count

- Density_m2_per_km2:

  Area density per km²

- Density_count_per_km2:

  Count density per km²

## Details

The function:

- projects the AOI and OSM features to a metric CRS (EPSG:3857),

- computes feature-level area, length, and count,

- aggregates metrics by category,

- calculates category shares (relative and AOI-based),

- computes density metrics per km²

This function is the core metrics engine of the URBANmetRics workflow.
It does not apply thematic interpretation. Instead, it provides a
standardized, geometry-based metrics table that is used by the
domain-specific metrics wrappers.

The modular design ensures:

- consistent metric definitions across domains,

- reproducibility,

- separation of concerns between extraction, structure, and metrics.

## Examples

``` r
if (FALSE) { # \dontrun{
raw <- osm_structure(aoi, tags = building_tags)
metrics <- osm_metrics(raw, aoi)
} # }
```
