# French Wine Database Documentation

## Overview

This comprehensive documentation covers the FrenchWine database system, designed to store and analyze information about French wines, regions, grape varieties, and related data. The system includes:

- A relational database schema with 8 interconnected tables
- 10 analytical views providing business insights
- Automated triggers for key management and view operations

## Database Schema

### Core Tables

#### Region
```sql
CREATE TABLE Region (
    ID_Region INTEGER NOT NULL,
    NameRegion VARCHAR(26) NOT NULL,  -- Maximum length based on 'Provence-Alpes-Côte d'Azur'
    Specialty VARCHAR(12),            -- Wine specialty (e.g., 'Red', 'White', 'Effervescent')
    Climate VARCHAR(16),              -- Regional climate (e.g., 'Oceanic', 'Mediterranean')
    FoundingYear INTEGER,             -- When the region was officially recognized
    TotalHectares INTEGER,            -- Total vineyard area in hectares
    PRIMARY KEY (ID_Region),
    UNIQUE (NameRegion)
);
```
**Purpose**: Stores information about French wine-producing regions with geographical and production characteristics.

#### Wine
```sql
CREATE TABLE Wine (
    ID_Wine INTEGER NOT NULL,
    NameVin VARCHAR(50) NOT NULL,     -- Extended for longer wine names
    Year INTEGER NOT NULL,
    ID_Label INTEGER NOT NULL,
    PriceBottle_75cL DECIMAL(6,2) NOT NULL CHECK (PriceBottle_75cL > 0),
    ID_Domain INTEGER NOT NULL,
    AlcoholPercentage DECIMAL(4,2),   -- Alcohol percentage (e.g., 13.5%)
    AgeingPotential INTEGER,          -- Recommended aging in years
    TastingNotes TEXT,                -- Official tasting description
    Production INTEGER,               -- Number of bottles produced
    PRIMARY KEY (ID_Wine),
    FOREIGN KEY (ID_Domain) REFERENCES Domain(ID_Domain) ON DELETE CASCADE,
    FOREIGN KEY (ID_Label) REFERENCES Label(ID_Label) ON DELETE CASCADE
);
```
**Purpose**: Central table containing specific wine products with detailed attributes and relationships to producers and classifications.

### Complete Schema Diagram
```
Region (1) → (N) Domain (1) → (N) Wine (N) → (M) GrapeVariety
    ↑               ↑                   ↑
    |               |                   |
Label (1)       Awards (N)          FoodPairing (N)
```

## Data Model Features

### Auto-Increment Primary Keys
The database implements sequences and triggers for automatic ID generation:

| Sequence Name | Starting Value | Table |
|---------------|----------------|-------|
| `region_id_seq` | 9 | Region |
| `label_id_seq` | 11 | Label |
| `domain_id_seq` | 9 | Domain |
| `grape_id_seq` | 11 | GrapeVariety |
| `wine_id_seq` | 15 | Wine |

**Example Trigger**:
```sql
CREATE OR REPLACE FUNCTION auto_increment_region_id()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.ID_Region IS NULL THEN
        NEW.ID_Region := nextval('region_id_seq');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

## Analytical Views

### CompleteWineInfo
```sql
CREATE VIEW CompleteWineInfo AS
SELECT
    w.NameVin,
    w.Year,
    w.PriceBottle_75cL,
    l.NameLabel,
    l.TypeWine,
    d.NameDomain,
    d.HomeOwner,
    r.NameRegion,
    r.Specialty,
    r.Climate
FROM Wine w
JOIN Label l ON w.ID_Label = l.ID_Label
JOIN Domain d ON w.ID_Domain = d.ID_Domain
JOIN Region r ON d.ID_Region = r.ID_Region
ORDER BY r.NameRegion, w.PriceBottle_75cL DESC;
```
**Insight**: Comprehensive wine profile including producer, region, and classification details.

### AveragePriceByRegion
```sql
CREATE VIEW AveragePriceByRegion AS
SELECT
    r.NameRegion,
    COUNT(w.ID_Wine) AS WineCount,
    ROUND(AVG(w.PriceBottle_75cL), 2) AS AveragePrice,
    MIN(w.PriceBottle_75cL) AS MinPrice,
    MAX(w.PriceBottle_75cL) AS MaxPrice
FROM Wine w
JOIN Domain d ON w.ID_Domain = d.ID_Domain
JOIN Region r ON d.ID_Region = r.ID_Region
GROUP BY r.NameRegion
ORDER BY AveragePrice DESC;
```
**Insight**: Statistical analysis of wine pricing distribution across regions.

## Advanced Features

### View Modification Trigger
Enables inserting data through the `WineRegionSummary` view while automatically resolving relationships:

```sql
CREATE OR REPLACE FUNCTION insert_wine_from_view()
RETURNS TRIGGER AS $$
DECLARE
    domain_id INTEGER;
    label_id INTEGER;
    new_wine_id INTEGER;
BEGIN
    -- Resolve domain ID from region name
    SELECT d.ID_Domain INTO domain_id
    FROM Domain d
    JOIN Region r ON d.ID_Region = r.ID_Region
    WHERE r.NameRegion = NEW.NameRegion
    LIMIT 1;
    
    -- Resolve label ID from wine type and region
    SELECT l.ID_Label INTO label_id
    FROM Label l
    JOIN Region r ON l.ID_Region = r.ID_Region
    WHERE l.TypeWine = NEW.TypeWine AND r.NameRegion = NEW.NameRegion
    LIMIT 1;
    
    -- Generate new wine ID
    SELECT nextval('wine_id_seq') INTO new_wine_id;
    
    -- Insert into Wine table
    INSERT INTO Wine (ID_Wine, NameVin, Year, ID_Label, PriceBottle_75cL, ID_Domain)
    VALUES (new_wine_id, NEW.NameVin, NEW.Year, label_id, NEW.PriceBottle_75cL, domain_id);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

## Data Science Applications

1. **Price Prediction**: Use region, grape variety, and production data to build predictive models for wine pricing
2. **Market Segmentation**: Cluster wines based on characteristics and pricing
3. **Recommendation System**: Implement collaborative filtering based on food pairings and awards
4. **Time Series Analysis**: Analyze vintage year effects on pricing and ratings

## Sample Queries

### Top Premium Wine Regions
```sql
SELECT 
    r.NameRegion,
    AVG(w.PriceBottle_75cL) AS AvgPrice,
    COUNT(*) AS WineCount
FROM Wine w
JOIN Domain d ON w.ID_Domain = d.ID_Domain
JOIN Region r ON d.ID_Region = r.ID_Region
GROUP BY r.NameRegion
HAVING AVG(w.PriceBottle_75cL) > 100
ORDER BY AvgPrice DESC;
```

### Grape Variety Analysis
```sql
SELECT 
    g.NameVariety,
    COUNT(c.ID_Wine) AS WineCount,
    ROUND(AVG(w.PriceBottle_75cL), 2) AS AvgPrice
FROM GrapeVariety g
JOIN Complexity c ON g.ID_Variety = c.ID_Variety
JOIN Wine w ON c.ID_Wine = w.ID_Wine
GROUP BY g.NameVariety
ORDER BY AvgPrice DESC;
```

## Maintenance Recommendations

1. **Sequence Management**: Regularly check and adjust sequence values after bulk operations
2. **Performance Tuning**: Add indexes on frequently joined columns
3. **Data Validation**: Implement additional CHECK constraints for business rules
4. **Backup Strategy**: Regular backups with point-in-time recovery capability

## Future Enhancements

1. **Geospatial Extension**: Add coordinates to regions for mapping visualization
2. **Sentiment Analysis**: Process tasting notes with NLP techniques
3. **Market Data Integration**: Connect with real-time pricing APIs
4. **ML Integration**: Deploy predictive models as database functions

This documentation provides both technical implementation details and analytical perspectives for data science applications in the wine industry.
