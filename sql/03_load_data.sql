-- 03_load_data.sql
-- Loads the six CSV files, fixes the date table, adds foreign keys, runs checks.
-- Before running: replace C:\data\sales\ with the full path to the data folder (six lines below).
-- If BULK INSERT fails on the last column, the files have Windows line endings: change 0x0a to \r\n.

USE ZS_SalesPerformance;
GO

-- True/False in DimDate.csv are text, so the file goes into a staging table first
DROP TABLE IF EXISTS dbo.stg_DimDate;
CREATE TABLE dbo.stg_DimDate (
    DateKey int, [Date] date, [Year] smallint, [Quarter] tinyint, [Month] tinyint,
    MonthName varchar(20), [Day] tinyint, DayOfWeek tinyint,
    IsWeekend varchar(5), IsHoliday varchar(5)
);
GO

BULK INSERT dbo.stg_DimDate  FROM 'C:\data\sales\DimDate.csv'      WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
BULK INSERT dbo.DimGeography FROM 'C:\data\sales\DimGeography.csv' WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
BULK INSERT dbo.DimProduct   FROM 'C:\data\sales\DimProduct.csv'   WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
BULK INSERT dbo.DimCustomer  FROM 'C:\data\sales\DimCustomer.csv'  WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
BULK INSERT dbo.DimEmployee  FROM 'C:\data\sales\DimEmployee.csv'  WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
BULK INSERT dbo.FactSales    FROM 'C:\data\sales\FactSales.csv'    WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO

INSERT dbo.DimDate (DateKey, [Date], [Year], [Quarter], [Month], MonthName, [Day], DayOfWeek, IsWeekend, IsHoliday)
SELECT DateKey, [Date], [Year], [Quarter], [Month], MonthName, [Day], DayOfWeek,
       CASE WHEN IsWeekend = 'True' THEN 1 ELSE 0 END,
       CASE WHEN IsHoliday = 'True' THEN 1 ELSE 0 END
FROM dbo.stg_DimDate;

DROP TABLE dbo.stg_DimDate;
GO

-- 137 orders ship after 2024-12-31 (the latest ship date is 2025-01-14), but DimDate ends
-- on 2024-12-31. Extend it through January 2025 so the ship date relationship has no gaps.
WITH d AS (
    SELECT CAST('2025-01-01' AS date) AS dt
    UNION ALL
    SELECT DATEADD(day, 1, dt) FROM d WHERE dt < '2025-01-31'
)
INSERT dbo.DimDate (DateKey, [Date], [Year], [Quarter], [Month], MonthName, [Day], DayOfWeek, IsWeekend, IsHoliday)
SELECT CONVERT(int, CONVERT(char(8), dt, 112)),
       dt,
       YEAR(dt),
       DATEPART(quarter, dt),
       MONTH(dt),
       CHOOSE(MONTH(dt), 'January','February','March','April','May','June',
                         'July','August','September','October','November','December'),
       DAY(dt),
       (DATEDIFF(day, '19000101', dt) % 7) + 1,
       CASE WHEN (DATEDIFF(day, '19000101', dt) % 7) + 1 IN (6, 7) THEN 1 ELSE 0 END,
       0
FROM d
OPTION (MAXRECURSION 0);
GO

ALTER TABLE dbo.DimCustomer ADD CONSTRAINT FK_DimCustomer_Geography FOREIGN KEY (GeographyKey) REFERENCES dbo.DimGeography (GeographyKey);
ALTER TABLE dbo.DimEmployee ADD CONSTRAINT FK_DimEmployee_Geography FOREIGN KEY (GeographyKey) REFERENCES dbo.DimGeography (GeographyKey);
ALTER TABLE dbo.FactSales   ADD CONSTRAINT FK_FactSales_OrderDate    FOREIGN KEY (OrderDateKey)  REFERENCES dbo.DimDate (DateKey);
ALTER TABLE dbo.FactSales   ADD CONSTRAINT FK_FactSales_ShipDate     FOREIGN KEY (ShipDateKey)   REFERENCES dbo.DimDate (DateKey);
ALTER TABLE dbo.FactSales   ADD CONSTRAINT FK_FactSales_Product      FOREIGN KEY (ProductKey)    REFERENCES dbo.DimProduct (ProductKey);
ALTER TABLE dbo.FactSales   ADD CONSTRAINT FK_FactSales_Customer     FOREIGN KEY (CustomerKey)   REFERENCES dbo.DimCustomer (CustomerKey);
ALTER TABLE dbo.FactSales   ADD CONSTRAINT FK_FactSales_Employee     FOREIGN KEY (EmployeeKey)   REFERENCES dbo.DimEmployee (EmployeeKey);
ALTER TABLE dbo.FactSales   ADD CONSTRAINT FK_FactSales_Geography    FOREIGN KEY (GeographyKey)  REFERENCES dbo.DimGeography (GeographyKey);
GO

-- Checks. Expected rows: FactSales 100000, DimDate 2588, DimCustomer 1500,
-- DimProduct 200, DimEmployee 50, DimGeography 40.
SELECT 'FactSales' AS tbl, COUNT(*) AS row_count FROM dbo.FactSales
UNION ALL SELECT 'DimDate',      COUNT(*) FROM dbo.DimDate
UNION ALL SELECT 'DimCustomer',  COUNT(*) FROM dbo.DimCustomer
UNION ALL SELECT 'DimProduct',   COUNT(*) FROM dbo.DimProduct
UNION ALL SELECT 'DimEmployee',  COUNT(*) FROM dbo.DimEmployee
UNION ALL SELECT 'DimGeography', COUNT(*) FROM dbo.DimGeography;

-- Should be 0: Profit = SalesAmount - TotalCost
SELECT COUNT(*) AS profit_mismatch
FROM dbo.FactSales
WHERE ABS(SalesAmount - TotalCost - Profit) > 0.02;
GO
