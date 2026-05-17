# Compute Urban Indices for Building, Green, and Transport Metrics

This function calculates a comprehensive set of urban indices based on
building, green, and transport metrics. It represents the final step in
the URBANmetRics workflow and expects preprocessed metric tables as
input.

## Usage

``` r
urban_index(building_metrics, green_metrics, transport_metrics)
```

## Arguments

- building_metrics:

  A data frame containing building-related metrics, including area
  shares, floor area density (m²/km²), and building counts.

- green_metrics:

  A data frame containing green area metrics, including area shares and
  category-level green information.

- transport_metrics:

  A data frame containing transport metrics, including lengths, counts,
  and transport categories.

## Value

A named list containing:

- BuildingIndex:

  Weighted building index (0.7 area, 0.3 mass)

- BuildingIndex_area:

  Area-based building intensity

- BuildingIndex_m2:

  Mass-based building intensity

- BuildingIndex_structure:

  Morphological building structure index

- BuildingDiversityIndex:

  Shannon diversity of building categories

- GreenIndex:

  Combined green index

- GreenIndex_area:

  Area-based green intensity

- GreenIndex_balance:

  Green–building balance index

- TransportIndex:

  Transport index (length + count)

- SustainableTransportScore:

  Share of sustainable transport modes

- UrbanBalanced:

  Balanced urban index

- UrbanLivability:

  Livability index

- UrbanAccessibility:

  Accessibility index

## Details

The function returns:

- Building Index (area- and mass-based)

- Green Index (area-based and balance-based)

- Transport Index (length and count)

- Sustainable Transport Score

- Building Diversity Index (Shannon diversity)

- Combined Urban Indices (Balanced, Livability, Accessibility)

## Examples

``` r
if (FALSE) { # \dontrun{
ui <- urban_index(building_metrics, green_metrics, transport_metrics)
ui$UrbanBalanced
ui$BuildingIndex
ui$GreenIndex
} # }
```
