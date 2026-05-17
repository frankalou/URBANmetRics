#' Compute Urban Indices for Building, Green, and Transport Metrics
#'
#' This function calculates a comprehensive set of urban indices based on
#' building, green, and transport metrics. It represents the final step in 
#' the URBANmetRics workflow and expects preprocessed metric tables as input.
#' 
#' The function returns:
#' - Building Index (area- and mass-based)
#' - Green Index (area-based and balance-based)
#' - Transport Index (length and count)
#' - Sustainable Transport Score
#' - Building Diversity Index (Shannon diversity)
#' - Combined Urban Indices (Balanced, Livability, Accessibility)
#'
#' @param building_metrics A data frame containing building-related metrics,
#'   including area shares, floor area density (m²/km²), and building counts.
#' @param green_metrics A data frame containing green area metrics,
#'   including area shares and category-level green information.
#' @param transport_metrics A data frame containing transport metrics,
#'   including lengths, counts, and transport categories.
#'
#' @return A named list containing:
#'   \describe{
#'     \item{BuildingIndex}{Weighted building index (0.7 area, 0.3 mass)}
#'     \item{BuildingIndex_area}{Area-based building intensity}
#'     \item{BuildingIndex_m2}{Mass-based building intensity}
#'     \item{BuildingIndex_structure}{Morphological building structure index}
#'     \item{BuildingDiversityIndex}{Shannon diversity of building categories}
#'     \item{GreenIndex}{Combined green index}
#'     \item{GreenIndex_area}{Area-based green intensity}
#'     \item{GreenIndex_balance}{Green–building balance index}
#'     \item{TransportIndex}{Transport index (length + count)}
#'     \item{SustainableTransportScore}{Share of sustainable transport modes}
#'     \item{UrbanBalanced}{Balanced urban index}
#'     \item{UrbanLivability}{Livability index}
#'     \item{UrbanAccessibility}{Accessibility index}
#'   }
#'
#' @examples
#' \dontrun{
#' ui <- urban_index(building_metrics, green_metrics, transport_metrics)
#' ui$UrbanBalanced
#' ui$BuildingIndex
#' ui$GreenIndex
#' }
#'
#' @export
urban_index <- function(building_metrics, green_metrics, transport_metrics) {

  ## 1) ABSOLUTE SCALING PARAMETERS (adjustable)
  # These define the upper bounds for normalization (based on German cities)

  # Building
  MAX_BUILDING_AREA   <- 40        # Maximum expected building share (% of AOI)
  MAX_BUILDING_M2     <- 250000    # Maximum building floor area density (m²/km²)
  MAX_BUILDING_COUNT  <- 3000      # Maximum building count density (buildings/km²)

  # Green
  MAX_GREEN_AREA      <- 60        # Maximum expected green share (% of AOI)

  # Transport
  MAX_TRANSPORT_LENGTH <- 15       # Maximum boosted transport length (km/km²)
  MAX_TRANSPORT_COUNT  <- 300      # Maximum transport object density (objects/km²)

  ## 2) BUILDING INDEX (area-based + mass-based)

  # Area-based building intensity:
  # - Uses sum of category area shares 
  # - 0 = no buildings, 1 = very high building coverage
  building_area_percent <- sum(building_metrics$Area_Share_AOI_percent, na.rm = TRUE)
  BI_area <- min(building_area_percent / MAX_BUILDING_AREA, 1)

  # Mass-based building intensity:
  # - Uses floor area density (m² of building per km² of land)
  # - Captures built volume, indirectly reflecting multi-storey development
  # - High values indicate multi-storey or dense structures
  BI_m2 <- min(mean(building_metrics$Density_m2_per_km2, na.rm = TRUE) / MAX_BUILDING_M2, 1)

  # Morphological building structure:
  # - Measures building structure (many small vs. few large buildings)
  # - Kept separate from the main Building Index
  BI_structure <- min(mean(building_metrics$Density_count_per_km2, na.rm = TRUE) / MAX_BUILDING_COUNT, 1)

  # Main Building Index:
  # - Weighted combination of area (70%) and mass (30%)
  BI <- 0.7 * BI_area + 0.3 * BI_m2

  # Building Diversity Index (Shannon):
  # - 0 = monofunctional (e.g., pure residential)
  # - 1 = highly mixed (e.g., inner city)
  share_building_categories <- building_metrics$Area_Share_AOI_percent /
                               sum(building_metrics$Area_Share_AOI_percent)

  Shannon_Index <- -sum(share_building_categories * log(share_building_categories), na.rm = TRUE)
  Shannon_Index_max <- log(length(share_building_categories))
  BDI <- ifelse(Shannon_Index_max > 0, Shannon_Index / Shannon_Index_max, 0)

  ## 3) GREEN INDEX (area-based + balance)
 
  # Area-based green intensity:
  # - 0 = no green, 1 = extremely green 
  green_area_percent <- sum(green_metrics$Area_Share_AOI_percent, na.rm = TRUE)
  GI_area <- min(green_area_percent / MAX_GREEN_AREA, 1)

  # Green–building balance:
  # - 0 = building-dominated
  # - 0.5 = balanced
  # - 1 = green-dominated
  if ((GI_area + BI_area) == 0) {
    GI_balance <- 0
  } else {
    GI_balance <- GI_area / (GI_area + BI_area)
  }

  # Combined Green Index:
  GI <- mean(c(GI_area, GI_balance), na.rm = TRUE)

  ## 4) TRANSPORT: Boost public transport length
 
  # Convert meters to kilometers
  transport_metrics$Length_km <- transport_metrics$Length_m / 1000

  # Boost public transport: each PT stop counts as 100m
  transport_metrics$Length_km_boosted <- transport_metrics$Length_km
  transport_metrics$Length_km_boosted[transport_metrics$category == "public_transport"] <-
    transport_metrics$Count[transport_metrics$category == "public_transport"] * 0.1

  total_length <- sum(transport_metrics$Length_km_boosted, na.rm = TRUE)

  ## 5) TRANSPORT INDEX (absolute)

  # TI_length: transport supply intensity
  # TI_count: density of transport objects
  TI_length   <- min(total_length / MAX_TRANSPORT_LENGTH, 1)
  TI_count <- min(mean(transport_metrics$Density_count_per_km2) / MAX_TRANSPORT_COUNT, 1)

  TI <- mean(c(TI_length, TI_count))

  ## 6) SUSTAINABLE TRANSPORT SCORE

  # Share of sustainable modes (cycling, walking, PT, rail)
  sustainable_cats <- c("cycleway", "footway", "public_transport", "tram", "rail", "subway")

  sustainable_length <- sum(
    transport_metrics$Length_km_boosted[transport_metrics$category %in% sustainable_cats],
    na.rm = TRUE
  )

  STS <- if (total_length == 0) 0 else sustainable_length / total_length

  # 7) COMBINED URBAN INDICES

  # Balanced: equal weighting of built, green, and transport
  U_balanced <- (1/3) * BI + (1/3) * GI + (1/3) * TI

  # Livability: green + sustainable transport weighted higher
  U_livability <- 0.20 * BI + 0.50 * GI + 0.20 * TI + 0.30 * STS

  # Accessibility: transport weighted highest
  U_accessibility <- 0.20 * BI + 0.20 * GI + 0.40 * TI + 0.20 * STS

  # 8) RETURN
  
  return(list(
    BuildingIndex = BI,
    BuildingIndex_area = BI_area,
    BuildingIndex_m2 = BI_m2,
    BuildingIndex_structure = BI_structure,
    BuildingDiversityIndex = BDI,

    GreenIndex = GI,
    GreenIndex_area = GI_area,
    GreenIndex_balance = GI_balance,

    TransportIndex = TI,
    SustainableTransportScore = STS,

    UrbanBalanced = U_balanced,
    UrbanLivability = U_livability,
    UrbanAccessibility = U_accessibility
  ))
}
