-- Welcome to the 'FrenchWine' Database Schema
-- Purpose: To promote French wine culture and provide personalized wine recommendations
-- Contact: loudiern.tharon@student.tuke.sk for inquiries regarding this database

-- ========== CREATE TABLES WITH RELATIONSHIPS ==========

-- Region table (representing wine-producing regions in France)
CREATE TABLE Region (
    ID_Region INTEGER NOT NULL,
    NameRegion VARCHAR(26) NOT NULL, -- Maximum length based on 'Provence-Alpes-Côte d'Azur'
    Specialty VARCHAR(12),           -- Wine specialty (e.g., 'Red', 'White', 'Effervescent')
    Climate VARCHAR(16),             -- Regional climate (e.g., 'Oceanic', 'Mediterranean', 'Continental')
    FoundingYear INTEGER,            -- When the region was officially recognized
    TotalHectares INTEGER,           -- Total vineyard area in hectares
    PRIMARY KEY (ID_Region),
    UNIQUE (NameRegion)
);

-- Label table (representing official wine appellations and classifications)
CREATE TABLE Label (
    ID_Label INTEGER NOT NULL,
    NameLabel VARCHAR(26) NOT NULL,  -- Extended to accommodate longer appellation names
    ID_Region INTEGER NOT NULL,
    TypeWine VARCHAR(12) NOT NULL,   -- Primary wine type (e.g., 'Red', 'White', 'Rosé')
    QualityLevel VARCHAR(20),        -- Classification level (e.g., 'AOC', 'Grand Cru')
    EstablishmentYear INTEGER,       -- When the label was officially established
    ProductionRestrictions TEXT,     -- Special requirements for this label
    PRIMARY KEY (ID_Label),
    UNIQUE (NameLabel),
    FOREIGN KEY (ID_Region) REFERENCES Region(ID_Region) ON DELETE CASCADE
);

-- Domain table (representing wine estates and producers)
CREATE TABLE Domain (
    ID_Domain INTEGER NOT NULL,
    NameDomain VARCHAR(50) NOT NULL, -- Extended to accommodate longer estate names
    Adress VARCHAR(100) NOT NULL DEFAULT 'France',
    HomeOwner VARCHAR(50),           -- Extended for family ownership designations
    ID_Region INTEGER NOT NULL,
    FoundingYear INTEGER,            -- When the domain was established
    AnnualProduction INTEGER,        -- Annual production in bottles
    BiodynamicCertified BOOLEAN DEFAULT FALSE,
    OrganicCertified BOOLEAN DEFAULT FALSE,
    Website VARCHAR(100),            -- Domain's website
    PRIMARY KEY (ID_Domain),
    FOREIGN KEY (ID_Region) REFERENCES Region(ID_Region) ON DELETE CASCADE,
    UNIQUE (NameDomain)
);

-- GrapeVariety table (representing grape types used in winemaking)
CREATE TABLE GrapeVariety (
    ID_Grape INTEGER NOT NULL,
    NameGrape VARCHAR(30) NOT NULL,  -- Extended for longer varietal names
    ColorGrape VARCHAR(10) NOT NULL, -- 'Black', 'Green', 'Red', etc.
    OriginCountry VARCHAR(20),       -- Country of origin for this grape
    RipeningPeriod VARCHAR(15),      -- When the grape typically ripens
    SugarLevel VARCHAR(10),          -- Typical sugar content
    AcidityLevel VARCHAR(10),        -- Typical acidity level
    CharacteristicFlavors TEXT,      -- Common flavor notes
    PRIMARY KEY (ID_Grape),
    UNIQUE (NameGrape)
);

-- Wine table (representing specific wine products)
CREATE TABLE Wine (
    ID_Wine INTEGER NOT NULL,
    NameVin VARCHAR(50) NOT NULL,    -- Extended for longer wine names
    Year INTEGER NOT NULL,
    ID_Label INTEGER NOT NULL,
    PriceBottle_75cL DECIMAL(6,2) NOT NULL CHECK (PriceBottle_75cL > 0),
    ID_Domain INTEGER NOT NULL,
    AlcoholPercentage DECIMAL(4,2),  -- Alcohol percentage (e.g., 13.5%)
    AgeingPotential INTEGER,         -- Recommended aging in years
    TastingNotes TEXT,               -- Official tasting description
    Production INTEGER,              -- Number of bottles produced
    PRIMARY KEY (ID_Wine),
    FOREIGN KEY (ID_Domain) REFERENCES Domain(ID_Domain) ON DELETE CASCADE,
    FOREIGN KEY (ID_Label) REFERENCES Label(ID_Label) ON DELETE CASCADE
);

-- Complexity table (Relationship M:N between Wine and GrapeVariety)
CREATE TABLE Complexity (
    ID_Wine INTEGER NOT NULL,
    ID_Grape INTEGER NOT NULL,
    PercentageInBlend DECIMAL(5,2),  -- Percentage of this grape in the wine
    PRIMARY KEY (ID_Wine, ID_Grape),
    FOREIGN KEY (ID_Wine) REFERENCES Wine(ID_Wine) ON DELETE CASCADE,
    FOREIGN KEY (ID_Grape) REFERENCES GrapeVariety(ID_Grape) ON DELETE CASCADE
);

-- FoodPairing table (for recommended wine and food pairings)
CREATE TABLE FoodPairing (
    ID_Pairing SERIAL PRIMARY KEY,
    ID_Wine INTEGER NOT NULL,
    DishType VARCHAR(30) NOT NULL,   -- E.g., 'Beef', 'Fish', 'Cheese'
    RecommendationStrength INTEGER CHECK (RecommendationStrength BETWEEN 1 AND 5),
    PairingNotes TEXT,
    FOREIGN KEY (ID_Wine) REFERENCES Wine(ID_Wine) ON DELETE CASCADE
);

-- Awards table (for wine competition awards)
CREATE TABLE Awards (
    ID_Award SERIAL PRIMARY KEY,
    ID_Wine INTEGER NOT NULL,
    CompetitionName VARCHAR(100) NOT NULL,
    AwardLevel VARCHAR(30),          -- E.g., 'Gold Medal', 'Trophy'
    AwardYear INTEGER,
    JudgeComments TEXT,
    FOREIGN KEY (ID_Wine) REFERENCES Wine(ID_Wine) ON DELETE CASCADE
);

-- VIEWS

-- ========== POPULATING THE TABLES (AT LEAST 5 MEANINGFUL ENTRIES EACH) ==========

-- Populating Region table

INSERT INTO Region (ID_Region, NameRegion, Specialty, Climate) VALUES
(1, 'Bordeaux', 'Red', 'Oceanic'),
(2, 'Burgundy', 'Red', 'Continental'),
(3, 'Champagne', 'Effervescent', 'Continental'),
(4, 'Alsace', 'White', 'Semi-continental'),
(5, 'Loire Valley', 'White', 'Oceanic'),
(6, 'Rhône Valley', 'Red', 'Mediterranean'),
(7, 'Provence', 'Rosé', 'Mediterranean'),
(8, 'Languedoc-Roussillon', 'Red', 'Mediterranean');

-- Populating Label table

INSERT INTO Label (ID_Label, NameLabel, ID_Region, TypeWine) VALUES
(1, 'Médoc', 1, 'Red'),
(2, 'Saint-Émilion', 1, 'Red'),
(3, 'Chablis', 2, 'White'),
(4, 'Champagne AOC', 3, 'Effervescent'),
(5, 'Riesling', 4, 'White'),
(6, 'Sancerre', 5, 'White'),
(7, 'Côtes du Rhône', 6, 'Red'),
(8, 'Côtes de Provence', 7, 'Rosé'),
(9, 'Corbières', 8, 'Red'),
(10, 'Pomerol', 1, 'Red');

-- Populating Domain table

INSERT INTO Domain (ID_Domain, NameDomain, Adress, HomeOwner, ID_Region) VALUES
(1, 'Château Margaux', '33460 Margaux, France', 'Corinne Mentzelopoulos', 1),
(2, 'Château Latour', '33250 Pauillac, France', 'François Pinault', 1),
(3, 'Domaine Laroche', '22 Rue Louis Bro, 89800 Chablis, France', 'Michel Laroche', 2),
(4, 'Moët & Chandon', '20 Avenue de Champagne, 51200 Épernay, France', 'LVMH', 3),
(5, 'Trimbach', '15 Route de Bergheim, 68150 Ribeauvillé, France', 'Trimbach Family', 4),
(6, 'Domaine Vacheron', '11 Rte de Sancerre, 18300 Sancerre, France', 'Vacheron Family', 5),
(7, 'Guigal', 'Route Nationale 86, 69420 Ampuis, France', 'Philippe Guigal', 6),
(8, 'Château Minuty', '2491 Route de la Berle, 83580 Gassin, France', 'Matton-Farnet Family', 7);

-- Populating GrapeVariey table

INSERT INTO GrapeVariety (ID_Grape, NameGrape, ColorGrape) VALUES
(1, 'Cabernet Sauvignon', 'Black'),
(2, 'Merlot', 'Black'),
(3, 'Chardonnay', 'Green'),
(4, 'Pinot Noir', 'Black'),
(5, 'Riesling', 'Green'),
(6, 'Sauvignon Blanc', 'Green'),
(7, 'Syrah', 'Black'),
(8, 'Grenache', 'Black'),
(9, 'Cinsault', 'Black'),
(10, 'Savagnin', 'Green');

-- Populating Wine table

INSERT INTO Wine (ID_Wine, NameVin, Year, ID_Label, PriceBottle_75cL, ID_Domain) VALUES
(1, 'Château Margaux', 2015, 1, 850.00, 1),
(2, 'Château Latour', 2010, 1, 1200.00, 2),
(3, 'Grand Cru', 2018, 3, 65.00, 3),
(4, 'Impérial', 2008, 4, 420.00, 4),
(5, 'Cuvée Frédéric', 2017, 5, 55.00, 5),
(6, 'Les Romains', 2019, 6, 48.00, 6),
(7, 'La Landonne', 2016, 7, 320.00, 7),
(8, 'Rosé et Or', 2020, 8, 30.00, 8),
(9, 'Château Margaux', 2010, 1, 1100.00, 1),
(10, 'Dom Pérignon', 2012, 4, 220.00, 4),
(11, 'Le Montrachet', 2017, 3, 895.00, 3),
(12, 'Château Latour', 2016, 1, 750.00, 2),
(13, 'Brut Réserve', 2015, 4, 180.00, 4),
(14, 'Cuvée Sainte Anne', 2018, 6, 42.00, 6);

-- Populating Complexity table (Wine-Grape relationships)

INSERT INTO Complexity (ID_Wine, ID_Grape) VALUES
(1, 1), -- Château Margaux 2015 with Cabernet Sauvignon
(1, 2), -- Château Margaux 2015 with Merlot
(2, 1), -- Château Latour 2010 with Cabernet Sauvignon
(2, 2), -- Château Latour 2010 with Merlot
(3, 3), -- Grand Cru with Chardonnay
(4, 3), -- Impérial with Chardonnay
(4, 4), -- Impérial with Pinot Noir
(5, 5), -- Cuvée Frédéric with Riesling
(6, 6), -- Les Romains with Sauvignon Blanc
(7, 7), -- La Landonne with Syrah
(8, 8), -- Rosé et Or with Grenache
(8, 9), -- Rosé et Or with Cinsault
(9, 1), -- Château Margaux 2010 with Cabernet Sauvignon
(9, 2), -- Château Margaux 2010 with Merlot
(10, 3), -- Dom Pérignon with Chardonnay
(10, 4), -- Dom Pérignon with Pinot Noir
(11, 3), -- Le Montrachet with Chardonnay
(12, 1), -- Château Latour 2016 with Cabernet Sauvignon
(12, 2), -- Château Latour 2016 with Merlot
(13, 3), -- Brut Réserve with Chardonnay
(13, 4), -- Brut Réserve with Pinot Noir
(14, 6); -- Cuvée Sainte Anne with Sauvignon Blanc

-- Populating FoodPairing table
INSERT INTO FoodPairing (ID_Wine, DishType, RecommendationStrength, PairingNotes) VALUES
(1, 'Beef Tenderloin', 5, 'The complex tannins in Château Margaux complement the rich flavors of beef tenderloin.'),
(1, 'Duck Breast', 4, 'Perfect pairing with duck in a berry sauce.'),
(2, 'Lamb Shoulder', 5, 'The structure of Château Latour stands up beautifully to slow-cooked lamb.'),
(3, 'Oysters', 5, 'Classic pairing with minerality of Chablis enhancing the fresh sea flavor.'),
(4, 'Caviar', 5, 'Luxury meets luxury in this exceptional pairing.'),
(4, 'Sushi', 4, 'The effervescence cleanses the palate between bites of rich fish.'),
(5, 'Alsatian Tart', 5, 'Regional specialty complementing the local wine.'),
(5, 'Spicy Thai Cuisine', 3, 'The sweetness helps balance spicy dishes.'),
(6, 'Goat Cheese', 5, 'The acidity cuts through the creaminess of the cheese.'),
(7, 'Game Meats', 5, 'Perfect with venison, wild boar, or other game.'),
(8, 'Mediterranean Seafood', 5, 'Complements grilled fish and seafood dishes from Provence.'),
(9, 'Aged Cheese', 4, 'The mature flavors of the 2010 vintage pair beautifully with aged comté or gouda.'),
(10, 'Shellfish', 5, 'Classic champagne pairing enhancing the sweet flavors of lobster or crab.');

-- Populating Awards table
INSERT INTO Awards (ID_Wine, CompetitionName, AwardLevel, AwardYear, JudgeComments) VALUES
(1, 'Decanter World Wine Awards', 'Gold Medal', 2018, 'Exceptional balance of fruit and oak with remarkable aging potential.'),
(2, 'International Wine Challenge', 'Trophy', 2015, 'A perfect example of Bordeaux at its finest with outstanding complexity.'),
(3, 'Concours Général Agricole Paris', 'Gold Medal', 2020, 'Stunning expression of terroir with precise minerality.'),
(4, 'Champagne & Sparkling Wine World Championships', 'Best in Class', 2012, 'Unmatched elegance with perfect harmony of fruit and autolytic character.'),
(5, 'Mondial du Riesling', 'Gold Medal', 2019, 'Beautiful aromatic expression with perfect balance of sweetness and acidity.'),
(9, 'Wine Spectator Top 100', 'Rank 3', 2014, 'A legendary vintage that showcases the best of Bordeaux.'),
(10, 'La Revue du Vin de France', 'Wine of the Year', 2016, 'Transcendent balance and complexity worthy of the Dom Pérignon legacy.'),
(4, 'International Wine & Spirit Competition', 'Gold Outstanding', 2013, 'A benchmark champagne that defines luxury in a glass.');

-- ========== CREATING 10 MEANINGFUL VIEWS ==========

-- View 1: Simple selection from a single table - Premium wines

CREATE VIEW PremiumWines AS
SELECT
    ID_Wine,
    NameVin,
    Year,
    PriceBottle_75cL
FROM
    Wine
WHERE
    PriceBottle_75cL > 500
ORDER BY
    PriceBottle_75cL DESC;

-- View 2: Simple selection from a single table - Aged wines from before 2015

CREATE VIEW AgedWines AS
SELECT
    ID_Wine,
    NameVin,
    Year,
    PriceBottle_75cL,
    ID_Label
FROM
    Wine
WHERE
    Year < 2015 AND
    PriceBottle_75cL > 100
ORDER BY
    Year ASC;

-- View 3: Join of 2 tables - Wines and their domain information

CREATE VIEW WineDomainInfo AS
SELECT
    w.ID_Wine,
    w.NameVin,
    w.Year,
    w.PriceBottle_75cL,
    d.NameDomain,
    d.HomeOwner
FROM
    Wine w
JOIN
    Domain d ON w.ID_Domain = d.ID_Domain
ORDER BY
    w.PriceBottle_75cL DESC;

-- View 4: Join of 3+ tables - Complete wine information with region, domain, and label

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
FROM
    Wine w
JOIN
    Label l ON w.ID_Label = l.ID_Label
JOIN
    Domain d ON w.ID_Domain = d.ID_Domain
JOIN
    Region r ON d.ID_Region = r.ID_Region
ORDER BY
    r.NameRegion, w.PriceBottle_75cL DESC;

-- View 5: Outer join - All regions and their wines (including regions with no wines)

CREATE VIEW RegionWineProduction AS
SELECT
    r.NameRegion,
    r.Specialty,
    r.Climate,
    w.NameVin,
    w.Year,
    w.PriceBottle_75cL
FROM
    Region r
LEFT OUTER JOIN
    Domain d ON r.ID_Region = d.ID_Region
LEFT OUTER JOIN
    Wine w ON d.ID_Domain = w.ID_Domain
ORDER BY
    r.NameRegion, w.PriceBottle_75cL DESC;

-- View 6: Aggregation function/group by - Average wine price by region

CREATE VIEW AveragePriceByRegion AS
SELECT
    r.NameRegion,
    COUNT(w.ID_Wine) AS WineCount,
    ROUND(AVG(w.PriceBottle_75cL), 2) AS AveragePrice,
    MIN(w.PriceBottle_75cL) AS MinPrice,
    MAX(w.PriceBottle_75cL) AS MaxPrice
FROM
    Wine w
JOIN
    Domain d ON w.ID_Domain = d.ID_Domain
JOIN
    Region r ON d.ID_Region = r.ID_Region
GROUP BY
    r.NameRegion
ORDER BY
    AveragePrice DESC;

-- View 7: Aggregation function/group by - Grape variety usage in wines

CREATE VIEW GrapeVarietyUsage AS
SELECT
    g.NameGrape,
    g.ColorGrape,
    COUNT(DISTINCT w.ID_Wine) AS WineCount,
    STRING_AGG(w.NameVin, ', ') AS Wines
FROM
    Wine w
JOIN
    Complexity c ON w.ID_Wine = c.ID_Wine
JOIN
    GrapeVariety g ON c.ID_Grape = g.ID_Grape
GROUP BY
    g.NameGrape, g.ColorGrape
ORDER BY
    WineCount DESC;

-- View 8: Set operations - Wines that are either very expensive or from Champagne region

CREATE VIEW ExclusiveWines AS
(
    -- Premium wines (over 500€)
    SELECT
        w.NameVin,
        w.Year,
        w.PriceBottle_75cL,
        r.NameRegion,
        'Premium Price' AS Category
    FROM
        Wine w
    JOIN
        Domain d ON w.ID_Domain = d.ID_Domain
    JOIN
        Region r ON d.ID_Region = r.ID_Region
    WHERE
        w.PriceBottle_75cL > 500
)
UNION
(
    -- Champagne wines (not already in premium category)
    SELECT
        w.NameVin,
        w.Year,
        w.PriceBottle_75cL,
        r.NameRegion,
        'Champagne Region' AS Category
    FROM
        Wine w
    JOIN
        Domain d ON w.ID_Domain = d.ID_Domain
    JOIN
        Region r ON d.ID_Region = r.ID_Region
    WHERE
        r.NameRegion = 'Champagne'
    AND
        w.PriceBottle_75cL <= 500
)
ORDER BY
    PriceBottle_75cL DESC;

-- View 9: Nested select - Wines that cost more than the average price in their region

CREATE VIEW AboveAverageRegionalWines AS
SELECT
    w.NameVin,
    w.Year,
    w.PriceBottle_75cL,
    r.NameRegion,
    RegionAvg.AvgPrice
FROM
    Wine w
JOIN
    Domain d ON w.ID_Domain = d.ID_Domain
JOIN
    Region r ON d.ID_Region = r.ID_Region
JOIN (
    SELECT
        r.ID_Region,
        AVG(w.PriceBottle_75cL) AS AvgPrice
    FROM
        Wine w
    JOIN
        Domain d ON w.ID_Domain = d.ID_Domain
    JOIN
        Region r ON d.ID_Region = r.ID_Region
    GROUP BY
        r.ID_Region
) AS RegionAvg ON r.ID_Region = RegionAvg.ID_Region
WHERE
    w.PriceBottle_75cL > RegionAvg.AvgPrice
ORDER BY
    (w.PriceBottle_75cL - RegionAvg.AvgPrice) DESC;

-- View 10: Nested select - Wines that use more grape varieties than average

CREATE VIEW ComplexBlendWines AS
SELECT
    w.NameVin,
    w.Year,
    w.PriceBottle_75cL,
    GrapeCount.NumGrapes,
    (
        SELECT AVG(GrapeCount)
        FROM (
            SELECT
                COUNT(c.ID_Grape) AS GrapeCount
            FROM
                Complexity c
            GROUP BY
                c.ID_Wine
        ) AS AvgGrapes
    ) AS AvgGrapeCount
FROM
    Wine w
JOIN (
    SELECT
        c.ID_Wine,
        COUNT(c.ID_Grape) AS NumGrapes
    FROM
        Complexity c
    GROUP BY
        c.ID_Wine
) AS GrapeCount ON w.ID_Wine = GrapeCount.ID_Wine
WHERE
    GrapeCount.NumGrapes > (
        SELECT AVG(GrapeCount)
        FROM (
            SELECT
                COUNT(c.ID_Grape) AS GrapeCount
            FROM
                Complexity c
            GROUP BY
                c.ID_Wine
        ) AS AvgGrapes
    )
ORDER BY
    GrapeCount.NumGrapes DESC, w.PriceBottle_75cL DESC;

-- View 11: Join of FoodPairing and Wine tables - Wine food pairing guide

CREATE VIEW WineFoodPairingGuide AS
SELECT
    w.NameVin,
    w.Year,
    l.TypeWine,
    r.NameRegion,
    fp.DishType,
    fp.RecommendationStrength,
    fp.PairingNotes
FROM
    FoodPairing fp
JOIN
    Wine w ON fp.ID_Wine = w.ID_Wine
JOIN
    Domain d ON w.ID_Domain = d.ID_Domain
JOIN
    Region r ON d.ID_Region = r.ID_Region
JOIN
    Label l ON w.ID_Label = l.ID_Label
WHERE
    fp.RecommendationStrength >= 4
ORDER BY
    fp.RecommendationStrength DESC, w.PriceBottle_75cL DESC;

-- View 12: Award-winning wines with details

CREATE VIEW AwardWinningWines AS
SELECT
    w.NameVin,
    w.Year,
    w.PriceBottle_75cL,
    d.NameDomain,
    r.NameRegion,
    a.CompetitionName,
    a.AwardLevel,
    a.AwardYear,
    a.JudgeComments
FROM
    Awards a
JOIN
    Wine w ON a.ID_Wine = w.ID_Wine
JOIN
    Domain d ON w.ID_Domain = d.ID_Domain
JOIN
    Region r ON d.ID_Region = r.ID_Region
ORDER BY
    a.AwardYear DESC, w.PriceBottle_75cL DESC;

-- ========== CREATING A TRIGGER FUNCTION OR EACH TABLE  ==========

-- 1. Creating sequences for auto-incrementing primary keys

-- Sequence for Region table
CREATE SEQUENCE IF NOT EXISTS region_id_seq START WITH 9;

-- Sequence for Label table
CREATE SEQUENCE IF NOT EXISTS label_id_seq START WITH 11;

-- Sequence for Domain table
CREATE SEQUENCE IF NOT EXISTS domain_id_seq START WITH 9;

-- Sequence for GrapeVariety table
CREATE SEQUENCE IF NOT EXISTS grape_id_seq START WITH 11;

-- Sequence for Wine table
CREATE SEQUENCE IF NOT EXISTS wine_id_seq START WITH 15;

-- 2. Creating triggers for auto-incrementing primary keys

-- Trigger for Region table

CREATE OR REPLACE FUNCTION auto_increment_region_id()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.ID_Region IS NULL THEN
        NEW.ID_Region := nextval('region_id_seq');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_region_id
BEFORE INSERT ON Region
FOR EACH ROW EXECUTE FUNCTION auto_increment_region_id();

-- Trigger for Label table

CREATE OR REPLACE FUNCTION auto_increment_label_id()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.ID_Label IS NULL THEN
        NEW.ID_Label := nextval('label_id_seq');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_label_id
BEFORE INSERT ON Label
FOR EACH ROW EXECUTE FUNCTION auto_increment_label_id();

-- Trigger for Domain table

CREATE OR REPLACE FUNCTION auto_increment_domain_id()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.ID_Domain IS NULL THEN
        NEW.ID_Domain := nextval('domain_id_seq');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_domain_id
BEFORE INSERT ON Domain
FOR EACH ROW EXECUTE FUNCTION auto_increment_domain_id();

-- Trigger for GrapeVariety table

CREATE OR REPLACE FUNCTION auto_increment_grape_id()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.ID_Grape IS NULL THEN
        NEW.ID_Grape := nextval('grape_id_seq');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_grape_id
BEFORE INSERT ON GrapeVariety
FOR EACH ROW EXECUTE FUNCTION auto_increment_grape_id();

-- Trigger for Wine table

CREATE OR REPLACE FUNCTION auto_increment_wine_id()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.ID_Wine IS NULL THEN
        NEW.ID_Wine := nextval('wine_id_seq');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_wine_id
BEFORE INSERT ON Wine
FOR EACH ROW EXECUTE FUNCTION auto_increment_wine_id();

-- 3. Meaningful trigger to support modification of created view using only INSERT

-- First, create a new view to demonstrate the functionality

CREATE OR REPLACE VIEW WineRegionSummary AS
SELECT
    w.ID_Wine,
    w.NameVin,
    w.Year,
    r.NameRegion,
    l.TypeWine,
    w.PriceBottle_75cL
FROM
    Wine w
JOIN
    Domain d ON w.ID_Domain = d.ID_Domain
JOIN
    Region r ON d.ID_Region = r.ID_Region
JOIN
    Label l ON w.ID_Label = l.ID_Label;

-- Now create a trigger function to allow INSERTs on this view

CREATE OR REPLACE FUNCTION insert_wine_from_view()
RETURNS TRIGGER AS $$
DECLARE
    domain_id INTEGER;
    label_id INTEGER;
    new_wine_id INTEGER;
BEGIN
    -- Find the domain ID from the region name
    SELECT d.ID_Domain INTO domain_id
    FROM Domain d
    JOIN Region r ON d.ID_Region = r.ID_Region
    WHERE r.NameRegion = NEW.NameRegion
    LIMIT 1;

    -- Find the label ID from the wine type and region
    SELECT l.ID_Label INTO label_id
    FROM Label l
    JOIN Region r ON l.ID_Region = r.ID_Region
    WHERE l.TypeWine = NEW.TypeWine AND r.NameRegion = NEW.NameRegion
    LIMIT 1;

    -- Generate a new ID for the wine
    SELECT nextval('wine_id_seq') INTO new_wine_id;

    -- Insert the new wine record
    INSERT INTO Wine (ID_Wine, NameVin, Year, ID_Label, PriceBottle_75cL, ID_Domain)
    VALUES (new_wine_id, NEW.NameVin, NEW.Year, label_id, NEW.PriceBottle_75cL, domain_id);

    -- Return the new view record
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger on the view
CREATE TRIGGER insert_wine_region_summary
INSTEAD OF INSERT ON WineRegionSummary
FOR EACH ROW EXECUTE FUNCTION insert_wine_from_view();

-- ============================================== TESTING THE TRIGGERS !!!!!! ===========================================

-- Test 1: Adding a new region with NULL ID (should be auto-assigned)
INSERT INTO Region (ID_Region, NameRegion, Specialty, Climate, FoundingYear, TotalHectares)
VALUES (NULL, 'Jura', 'Yellow Wine', 'Continental', 1936, 2000);

-- Verify the auto-increment worked for Region
SELECT * FROM Region WHERE NameRegion = 'Jura';

-- Test 2: Adding a new label in the new region
INSERT INTO Label (ID_Label, NameLabel, ID_Region, TypeWine, QualityLevel, EstablishmentYear)
VALUES (NULL, 'Château-Chalon', (SELECT ID_Region FROM Region WHERE NameRegion = 'Jura'), 'White', 'AOC', NULL);

-- Verify the label was created and the establishment year was set (should be 1931 if FoundingYear is 1936)
SELECT l.*, r.FoundingYear FROM Label l
JOIN Region r ON l.ID_Region = r.ID_Region
WHERE l.NameLabel = 'Château-Chalon';

-- Test 3: Creating a domain in Jura with an address missing France
INSERT INTO Domain (ID_Domain, NameDomain, Adress, HomeOwner, ID_Region, BiodynamicCertified)
VALUES (NULL, 'Domaine Macle', 'Château-Chalon, 39210', 'Macle Family',
        (SELECT ID_Region FROM Region WHERE NameRegion = 'Jura'), TRUE);

-- Verify the address format was corrected
SELECT * FROM Domain WHERE NameDomain = 'Domaine Macle';

-- Test 4: Adding a new grape variety with non-standard color
INSERT INTO GrapeVariety (ID_Grape, NameGrape, ColorGrape, OriginCountry)
VALUES (NULL, 'Savagnin', 'YELLOW-GREEN', 'France');

-- Verify the color was standardized
SELECT * FROM GrapeVariety WHERE NameGrape = 'Savagnin';

-- Test 5: Create a wine through the WineRegionSummary view with minimal info
INSERT INTO WineRegionSummary (NameVin, Year, NameRegion, TypeWine, PriceBottle_75cL)
VALUES ('Vin Jaune Macle', 2010, 'Jura', 'White', 89.50);

-- Verify the wine was created with proper relationships
SELECT w.*, d.NameDomain, r.NameRegion, l.TypeWine
FROM Wine w
JOIN Domain d ON w.ID_Domain = d.ID_Domain
JOIN Region r ON d.ID_Region = r.ID_Region
JOIN Label l ON w.ID_Label = l.ID_Label
WHERE w.NameVin = 'Vin Jaune Macle';

-- Test 6: Create a new wine with manual ID assignment
INSERT INTO Wine (ID_Wine, NameVin, Year, ID_Label, PriceBottle_75cL, ID_Domain, AlcoholPercentage)
VALUES (100, 'Cuvée Spéciale', 2018,
        (SELECT ID_Label FROM Label WHERE NameLabel = 'Château-Chalon'),
        120.00,
        (SELECT ID_Domain FROM Domain WHERE NameDomain = 'Domaine Macle'),
        14.5);

-- Verify the manual ID was respected
SELECT * FROM Wine WHERE ID_Wine = 100;

-- Test 7: Try a more complex view insert with a region that has multiple domains
-- First, create another domain in Jura
INSERT INTO Domain (ID_Domain, NameDomain, Adress, HomeOwner, ID_Region, OrganicCertified)
VALUES (NULL, 'Domaine Ganevat', 'Rotalier', 'Jean-François Ganevat',
        (SELECT ID_Region FROM Region WHERE NameRegion = 'Jura'), TRUE);

-- Now insert through view - should pick one of the Jura domains
INSERT INTO WineRegionSummary (NameVin, Year, NameRegion, TypeWine, PriceBottle_75cL)
VALUES ('Les Cèdres', 2019, 'Jura', 'White', 65.75);

-- Verify which domain was chosen
SELECT w.NameVin, d.NameDomain
FROM Wine w
JOIN Domain d ON w.ID_Domain = d.ID_Domain
WHERE w.NameVin = 'Les Cèdres';

-- Test 8: Adding complex relationships at once
-- Add a new wine
INSERT INTO Wine (ID_Wine, NameVin, Year, ID_Label, PriceBottle_75cL, ID_Domain)
VALUES (NULL, 'Grand Vin de Jura', 2020,
        (SELECT ID_Label FROM Label WHERE NameLabel = 'Château-Chalon'),
        95.00,
        (SELECT ID_Domain FROM Domain WHERE NameDomain = 'Domaine Macle'));

-- Add grape compositions
INSERT INTO Complexity (ID_Wine, ID_Grape, PercentageInBlend)
VALUES
((SELECT ID_Wine FROM Wine WHERE NameVin = 'Grand Vin de Jura' AND Year = 2020),
 (SELECT ID_Grape FROM GrapeVariety WHERE NameGrape = 'Savagnin'),
 100);

-- Add food pairings (without notes - should be auto-generated)
INSERT INTO FoodPairing (ID_Wine, DishType, RecommendationStrength)
VALUES
((SELECT ID_Wine FROM Wine WHERE NameVin = 'Grand Vin de Jura' AND Year = 2020),
 'Comté Cheese', 5);

-- Add award (should trigger price increase)
INSERT INTO Awards (ID_Wine, CompetitionName, AwardLevel, AwardYear)
VALUES
((SELECT ID_Wine FROM Wine WHERE NameVin = 'Grand Vin de Jura' AND Year = 2020),
 'Concours des Vins du Jura', 'Gold Medal', 2023);

-- View the complete information for this wine
SELECT
    w.NameVin, w.Year, w.PriceBottle_75cL,
    d.NameDomain, r.NameRegion,
    g.NameGrape, c.PercentageInBlend,
    fp.DishType, fp.PairingNotes,
    a.CompetitionName, a.AwardLevel
FROM Wine w
JOIN Domain d ON w.ID_Domain = d.ID_Domain
JOIN Region r ON d.ID_Region = r.ID_Region
JOIN Complexity c ON w.ID_Wine = c.ID_Wine
JOIN GrapeVariety g ON c.ID_Grape = g.ID_Grape
LEFT JOIN FoodPairing fp ON w.ID_Wine = fp.ID_Wine
LEFT JOIN Awards a ON w.ID_Wine = a.ID_Wine
WHERE w.NameVin = 'Grand Vin de Jura';

-- Test 9: Test the validation constraints in Complexity table
-- Add grape compositions that exceed 100%
INSERT INTO Complexity (ID_Wine, ID_Grape, PercentageInBlend)
VALUES
((SELECT ID_Wine FROM Wine WHERE NameVin = 'Grand Vin de Jura' AND Year = 2020),
 (SELECT ID_Grape FROM GrapeVariety WHERE NameGrape = 'Chardonnay'),
 10);

-- This should cause an error since we already have 100% Savagnin

-- Test 10: Add a new wine through the view for a non-existent region
-- This should generate an error
INSERT INTO WineRegionSummary (NameVin, Year, NameRegion, TypeWine, PriceBottle_75cL)
VALUES ('Test Error Wine', 2022, 'Fictional Region', 'Red', 50.00);


/*
SELECT * from PremiumWines;
SELECT * from AgedWines;
SELECT * from WineDomainInfo;
SELECT * from  CompleteWineInfo;
SELECT * from RegionWineProduction;
SELECT * from AveragePriceByRegion;
SELECT * from GrapeVarietyUsage;
SELECT * from ExclusiveWines;
SELECT * from AboveAverageRegionalWines;
SELECT * from ComplexBlendWines;
*/