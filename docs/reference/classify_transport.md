# Classify transport features into functional categories

Internal helper function used by
[`transport_structure()`](transport_structure.md) to assign transport
classes based on OSM `highway=*`, `railway=*`, and `public_transport=*`
tags.

## Usage

``` r
classify_transport(df)
```

## Arguments

- df:

  An `sf` object returned by [`osm_structure()`](osm_structure.md).

## Value

The same `sf` object with an additional `transport_class` column.
