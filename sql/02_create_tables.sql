-- 02_create_tables.sql
-- Empty tables for the six source files. Re-running drops and recreates everything.

USE ZS_SalesPerformance;
GO

DROP TABLE IF EXISTS dbo.FactSales;
DROP TABLE IF EXISTS dbo.DimCustomer;
DROP TABLE IF EXISTS dbo.DimEmployee;
DROP TABLE IF EXISTS dbo.DimProduct;
DROP TABLE IF EXISTS dbo.DimGeography;
DROP TABLE IF EXISTS dbo.DimDate;
GO

CREATE TABLE dbo.DimDate (
    DateKey    int         NOT NULL PRIMARY KEY,  -- yyyymmdd
    [Date]     date        NOT NULL,
    [Year]     smallint    NOT NULL,
    [Quarter]  tinyint     NOT NULL,
    [Month]    tinyint     NOT NULL,
    MonthName  varchar(20) NOT NULL,
    [Day]      tinyint     NOT NULL,
    DayOfWeek  tinyint     NOT NULL,              -- 1 = Monday, 7 = Sunday
    IsWeekend  bit         NOT NULL,
    IsHoliday  bit         NOT NULL
);

CREATE TABLE dbo.DimGeography (
    GeographyKey int         NOT NULL PRIMARY KEY,
    Country      varchar(50) NOT NULL,
    Region       varchar(20) NOT NULL,
    City         varchar(50) NOT NULL
);

CREATE TABLE dbo.DimProduct (
    ProductKey   int           NOT NULL PRIMARY KEY,
    ProductName  varchar(30)   NOT NULL,
    Category     varchar(30)   NOT NULL,
    SubCategory  varchar(30)   NOT NULL,
    Color        varchar(20)   NOT NULL,
    Size         varchar(5)    NOT NULL,          -- 'NA' is a value, not a missing one
    StandardCost decimal(10,2) NOT NULL,
    ListPrice    decimal(10,2) NOT NULL
);

CREATE TABLE dbo.DimCustomer (
    CustomerKey  int           NOT NULL PRIMARY KEY,
    CustomerName nvarchar(100) NOT NULL,
    Email        varchar(100)  NOT NULL,
    Phone        varchar(20)   NOT NULL,          -- text because of the leading +
    SignupDate   date          NOT NULL,
    GeographyKey int           NOT NULL,
    LoyaltyTier  varchar(20)   NOT NULL,
    Gender       char(1)       NOT NULL
);

CREATE TABLE dbo.DimEmployee (
    EmployeeKey  int           NOT NULL PRIMARY KEY,
    EmployeeName nvarchar(100) NOT NULL,
    HireDate     date          NOT NULL,
    Role         varchar(30)   NOT NULL,
    GeographyKey int           NOT NULL
);

CREATE TABLE dbo.FactSales (
    SalesKey      int           NOT NULL PRIMARY KEY,
    OrderDateKey  int           NOT NULL,
    ShipDateKey   int           NOT NULL,
    ProductKey    int           NOT NULL,
    CustomerKey   int           NOT NULL,
    EmployeeKey   int           NOT NULL,
    GeographyKey  int           NOT NULL,
    Quantity      int           NOT NULL,
    UnitPrice     decimal(10,2) NOT NULL,
    Discount      decimal(4,2)  NOT NULL,
    SalesAmount   decimal(12,2) NOT NULL,
    TotalCost     decimal(12,2) NOT NULL,
    Profit        decimal(12,2) NOT NULL,
    Channel       varchar(20)   NOT NULL,
    PaymentMethod varchar(20)   NOT NULL,
    OrderPriority varchar(10)   NOT NULL
);
GO
