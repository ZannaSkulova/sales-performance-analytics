# Data

## Source

Complete DAX Practice Dataset, a synthetic sales dataset (fact table plus five dimension tables) made for learning Power BI and DAX.

- Page: https://www.kaggle.com/datasets/thesnak/complete-dax-practice-dataset
- Author: thesnak (Kaggle user)
- License: Apache License 2.0, https://www.apache.org/licenses/LICENSE-2.0
- Downloaded: DD.MM.YYYY

The data is synthetic. It does not describe a real company, so the findings in this project show the method, not real business results.

## Changes made to the original data

- The six CSV files were loaded into SQL Server (database ZS_SalesPerformance). Text flags True/False in the date table were converted to bit; other values are unchanged.
- The reporting views (schema bi) leave out customer and employee names, customer e-mail and phone, which the analysis does not need.
- In the date view a month start date, a year-month number and a day name were added.
- The Power BI report reads only the bi.* views.

## Files

The six CSV files in this folder are unchanged copies of the files from the Kaggle page above, stored here so the project does not depend on that page staying available: DimDate, DimGeography, DimProduct, DimCustomer, DimEmployee, FactSales.

The customer and employee files contain generated names and contact fields. They are synthetic, not real people.

The data is used under the Apache License 2.0, a copy of the license is in LICENSE.txt. The code, SQL scripts and report design in this repository are my own work.
