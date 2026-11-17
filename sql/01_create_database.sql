-- 01_create_database.sql
-- Creates the working database for the sales model.

IF DB_ID('ZS_SalesPerformance') IS NULL
    CREATE DATABASE ZS_SalesPerformance;
GO

USE ZS_SalesPerformance;
GO
