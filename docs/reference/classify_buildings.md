# Classify building features into functional categories

This internal helper function assigns building classes based on OSM
`building=*` and `amenity=*` tags. It is used by
[`building_structure()`](building_structure.md) to create the
`building_class` and `category` columns.

## Usage

``` r
classify_buildings(df)
```

## Arguments

- df:

  An `sf` object returned by [`osm_structure()`](osm_structure.md).

## Value

The same `sf` object with an additional `building_class` column.
