
# Houses Data Cleaning Using SQL Project

## Overview

This project focuses on cleaning and standardizing data in a SQL database, specifically targeting a `houses` table. The operations include standardizing date formats, populating missing data, breaking down addresses, removing duplicates, and more.

## Table of Contents

- [Data Cleaning and Standardization](#data-cleaning-and-standardization)
  - [Retrieve All Data](#retrieve-all-data)
  - [Standardize Sale Date Format](#standardize-sale-date-format)
  - [Update Original Table with Standardized Dates](#update-original-table-with-standardized-dates)
  - [Populate Property Address Data](#populate-property-address-data)
  - [Update Property Address in the Database](#update-property-address-in-the-database)
  - [Review Updated Property Address Data](#review-updated-property-address-data)
- [Address Breakdown](#address-breakdown)
  - [Break Out Address into Address and City](#break-out-address-into-address-and-city)
  - [Save Changes to the Table](#save-changes-to-the-table)
  - [Alternate Method for Breaking Out Address](#alternate-method-for-breaking-out-address)
  - [Save and Update the Results](#save-and-update-the-results)
- [Standardize SoldAsVacant Column](#standardize-soldasvacant-column)
  - [Change 'Y' to Yes and 'N' to No](#change-y-to-yes-and-n-to-no)
  - [Add and Update the Main Table](#add-and-update-the-main-table)
- [Remove Duplicates](#remove-duplicates)
  - [Remove Duplicate Rows](#remove-duplicate-rows)
- [Delete Unused Columns](#delete-unused-columns)
  - [Remove Unused Columns](#remove-unused-columns)

## Data Cleaning and Standardization

### Retrieve All Data
```sql
SELECT * FROM houses;
```
This query selects all columns from the `houses` table, retrieving the entire dataset for review and analysis.

### Standardize Sale Date Format
```sql
SELECT SaleDate, CONVERT(date, SaleDate) as NewSaleDate FROM houses;
```
This query converts the `SaleDate` column to a standardized date format and creates a new column `NewSaleDate` to store these standardized dates temporarily.

### Update Original Table with Standardized Dates
```sql
ALTER TABLE houses ADD NewSaleDate date;

UPDATE houses SET NewSaleDate = CONVERT(date, SaleDate);

SELECT NewSaleDate FROM houses;
```
These queries first add a new column `NewSaleDate` to the `houses` table. Then, they update this new column with the standardized sale dates. Finally, the `NewSaleDate` column is selected to verify the updates.

### Populate Property Address Data
```sql
SELECT * FROM houses;

SELECT a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) AS NewPropertyAddress 
FROM houses a 
JOIN houses b ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID 
WHERE a.PropertyAddress IS NULL;
```
These queries are used to identify and fill in missing `PropertyAddress` values. The `ISNULL` function is used to select the non-null `PropertyAddress` from either table `a` or `b`.

### Update Property Address in the Database
```sql
UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM houses a 
JOIN houses b ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID;
```
This query updates the `PropertyAddress` column in the `houses` table using the non-null `PropertyAddress` values from the joined tables.

### Review Updated Property Address Data
```sql
SELECT * FROM houses WHERE PropertyAddress IS NULL;
```
This final query checks the `houses` table to identify any remaining records where the `PropertyAddress` is still null, ensuring data completeness and accuracy.

## Address Breakdown

### Break Out Address into Address and City
```sql
SELECT PropertyAddress, 
       SUBSTRING(PropertyAddress, -1, CHARINDEX(',', PropertyAddress)) AS address, 
       SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS NewAddress 
FROM houses;
```
This query breaks out the `PropertyAddress` into `address` and `NewAddress` components.

### Save Changes to the Table
```sql
ALTER TABLE houses ADD splittedAddress NVARCHAR(255);

UPDATE houses 
SET splittedAddress = SUBSTRING(PropertyAddress, -1, CHARINDEX(',', PropertyAddress));

ALTER TABLE houses ADD splittedCity NVARCHAR(255);

UPDATE houses 
SET splittedCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

SELECT splittedAddress, splittedCity FROM houses;
```
These queries add new columns `splittedAddress` and `splittedCity` to the `houses` table and update them with the respective values.

### Alternate Method for Breaking Out Address
```sql
SELECT 
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS address,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS city,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS state 
FROM houses;
```
This query uses the `PARSENAME` function to break out the `OwnerAddress` into `address`, `city`, and `state`.

### Save and Update the Results
```sql
ALTER TABLE houses 
ADD address NVARCHAR(255), city NVARCHAR(255), state NVARCHAR(255);

UPDATE houses 
SET  
    address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
    city = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
    state = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

SELECT address, city, state FROM houses;
```
These queries add new columns `address`, `city`, and `state` to the `houses` table and update them with the respective values.

## Standardize SoldAsVacant Column

### Change 'Y' to Yes and 'N' to No
```sql
SELECT SoldAsVacant, 
       CASE 
           WHEN SoldAsVacant = 'Y' THEN 'Yes'
           WHEN SoldAsVacant = 'N' THEN 'No'
           ELSE SoldAsVacant
       END AS NewSoldAsVacant 
FROM houses;
```
This query standardizes the `SoldAsVacant` column by replacing 'Y' with 'Yes' and 'N' with 'No'.

### Add and Update the Main Table
```sql
ALTER TABLE houses ADD NewSoldAsVacant NVARCHAR(255);

UPDATE houses 
SET NewSoldAsVacant = CASE 
                          WHEN SoldAsVacant = 'Y' THEN 'Yes'
                          WHEN SoldAsVacant = 'N' THEN 'No'
                          ELSE SoldAsVacant
                      END;

SELECT SoldAsVacant, NewSoldAsVacant FROM houses;
```
These queries add a new column `NewSoldAsVacant` to the `houses` table and update it with the standardized values.

## Remove Duplicates

### Remove Duplicate Rows
```sql
WITH RowNumCTE AS (
    SELECT *, 
           ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SaleDate, LegalReference 
                              ORDER BY UniqueID) AS RowNum 
    FROM houses
)
DELETE FROM RowNumCTE WHERE RowNum > 1;
```
This query removes duplicate rows by creating a common table expression (CTE) with row numbers for each partition of duplicates and then deletes the duplicates.

## Delete Unused Columns

### Remove Unused Columns
```sql
ALTER TABLE houses DROP COLUMN SaleDate, SoldAsVacant;

SELECT * FROM houses;
```
This query drops the `SaleDate` and `SoldAsVacant` columns from the `houses` table, cleaning up unused data.

