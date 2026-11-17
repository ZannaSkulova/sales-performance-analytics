-- 04_views_star_schema.sql
-- Views in schema bi: the star schema that Power BI connects to.
-- Left out on purpose: customer and employee names, customer e-mail and phone (not needed for analysis).
-- Customer and employee geography is flattened into Country/Region columns, so DimGeography relates only to FactSales (sales location) and the model has no second filter path.

USE ZS_SalesPerformance;
GO

IF SCHEMA_ID('bi') IS NULL
    EXEC ('CREATE SCHEMA bi');
GO

CREATE OR ALTER VIEW bi.DimDate AS
SELECT DateKey,
       [Date],
       [Year],
       [Quarter],
       [Month],
       MonthName,
       [Year] * 100 + [Month] AS YearMonth,          -- sort key for month labels
       DATEFROMPARTS([Year], [Month], 1) AS MonthStart,
       [Day],
       DayOfWeek,
       CHOOSE(DayOfWeek, 'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday') AS DayName,
       IsWeekend,
       IsHoliday
FROM dbo.DimDate;
GO

CREATE OR ALTER VIEW bi.DimGeography AS
SELECT GeographyKey, Country, Region, City
FROM dbo.DimGeography;
GO

CREATE OR ALTER VIEW bi.DimProduct AS
SELECT ProductKey, ProductName, Category, SubCategory, Color, Size, StandardCost, ListPrice
FROM dbo.DimProduct;
GO

CREATE OR ALTER VIEW bi.DimCustomer AS
SELECT c.CustomerKey,
       c.SignupDate,
       c.LoyaltyTier,
       CASE c.LoyaltyTier WHEN 'Bronze' THEN 1 WHEN 'Silver' THEN 2
                          WHEN 'Gold' THEN 3 WHEN 'Platinum' THEN 4 END AS LoyaltyTierSort,
       c.Gender,
       g.Country,
       g.Region
FROM dbo.DimCustomer AS c
JOIN dbo.DimGeography AS g ON g.GeographyKey = c.GeographyKey;
GO

CREATE OR ALTER VIEW bi.DimEmployee AS
SELECT e.EmployeeKey,
       e.HireDate,
       e.Role,
       g.Country,
       g.Region
FROM dbo.DimEmployee AS e
JOIN dbo.DimGeography AS g ON g.GeographyKey = e.GeographyKey;
GO

CREATE OR ALTER VIEW bi.FactSales AS
SELECT SalesKey,
       OrderDateKey,
       ShipDateKey,
       ProductKey,
       CustomerKey,
       EmployeeKey,
       GeographyKey,
       Quantity,
       UnitPrice,
       Discount,
       SalesAmount,
       TotalCost,
       Profit,
       Channel,
       PaymentMethod,
       OrderPriority
FROM dbo.FactSales;
GO

-- Check: row counts should match the tables (100000, 2588, 1500, 200, 50, 40)
SELECT 'bi.FactSales' AS view_name, COUNT(*) AS row_count FROM bi.FactSales
UNION ALL SELECT 'bi.DimDate',      COUNT(*) FROM bi.DimDate
UNION ALL SELECT 'bi.DimCustomer',  COUNT(*) FROM bi.DimCustomer
UNION ALL SELECT 'bi.DimProduct',   COUNT(*) FROM bi.DimProduct
UNION ALL SELECT 'bi.DimEmployee',  COUNT(*) FROM bi.DimEmployee
UNION ALL SELECT 'bi.DimGeography', COUNT(*) FROM bi.DimGeography;
GO
