/*
===========================================================
    Nashville Housing Data Cleaning Project
===========================================================
    Database: Project1
    Schema: dbo
    Table: PortfolioProject.dbo.NashvilleHousing
===========================================================
*/


USE Project1;
GO


/*
-----------------------------------------------------------
1. Standardize Date Format
-----------------------------------------------------------
*/

SELECT *
FROM dbo.[PortfolioProject.dbo.NashvilleHousing];


SELECT
    SaleDate,
    CONVERT(Date, SaleDate) AS SaleDateConverted
FROM dbo.[PortfolioProject.dbo.NashvilleHousing];


/*
Create a new column for the converted date
*/

ALTER TABLE dbo.[PortfolioProject.dbo.NashvilleHousing]
ADD SaleDateConverted Date;


UPDATE dbo.[PortfolioProject.dbo.NashvilleHousing]
SET SaleDateConverted = CONVERT(Date, SaleDate);


/*
-----------------------------------------------------------
2. Populate Missing Property Address Data
-----------------------------------------------------------
*/

SELECT *
FROM dbo.[PortfolioProject.dbo.NashvilleHousing]
ORDER BY ParcelID;


SELECT
    a.ParcelID,
    a.PropertyAddress,
    b.ParcelID,
    b.PropertyAddress,
    ISNULL(a.PropertyAddress, b.PropertyAddress) AS PropertyAddressUpdated
FROM dbo.[PortfolioProject.dbo.NashvilleHousing] a
JOIN dbo.[PortfolioProject.dbo.NashvilleHousing] b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;


UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.[PortfolioProject.dbo.NashvilleHousing] a
JOIN dbo.[PortfolioProject.dbo.NashvilleHousing] b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;


/*
-----------------------------------------------------------
3. Split Property Address into Address and City
-----------------------------------------------------------
*/

SELECT
    PropertyAddress
FROM dbo.[PortfolioProject.dbo.NashvilleHousing];


SELECT
    SUBSTRING(
        PropertyAddress,
        1,
        CHARINDEX(',', PropertyAddress) - 1
    ) AS PropertySplitAddress,

    SUBSTRING(
        PropertyAddress,
        CHARINDEX(',', PropertyAddress) + 1,
        LEN(PropertyAddress)
    ) AS PropertySplitCity
FROM dbo.[PortfolioProject.dbo.NashvilleHousing];


/*
Create PropertySplitAddress
*/

ALTER TABLE dbo.[PortfolioProject.dbo.NashvilleHousing]
ADD PropertySplitAddress NVARCHAR(255);


UPDATE dbo.[PortfolioProject.dbo.NashvilleHousing]
SET PropertySplitAddress =
    SUBSTRING(
        PropertyAddress,
        1,
        CHARINDEX(',', PropertyAddress) - 1
    );


/*
Create PropertySplitCity
*/

ALTER TABLE dbo.[PortfolioProject.dbo.NashvilleHousing]
ADD PropertySplitCity NVARCHAR(255);


UPDATE dbo.[PortfolioProject.dbo.NashvilleHousing]
SET PropertySplitCity =
    SUBSTRING(
        PropertyAddress,
        CHARINDEX(',', PropertyAddress) + 1,
        LEN(PropertyAddress)
    );


/*
-----------------------------------------------------------
4. Split Owner Address into Address, City, and State
-----------------------------------------------------------
*/

SELECT
    OwnerAddress
FROM dbo.[PortfolioProject.dbo.NashvilleHousing];


SELECT
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerSplitAddress,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerSplitCity,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerSplitState
FROM dbo.[PortfolioProject.dbo.NashvilleHousing];


/*
Create OwnerSplitAddress
*/

ALTER TABLE dbo.[PortfolioProject.dbo.NashvilleHousing]
ADD OwnerSplitAddress NVARCHAR(255);


UPDATE dbo.[PortfolioProject.dbo.NashvilleHousing]
SET OwnerSplitAddress =
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);


/*
Create OwnerSplitCity
*/

ALTER TABLE dbo.[PortfolioProject.dbo.NashvilleHousing]
ADD OwnerSplitCity NVARCHAR(255);


UPDATE dbo.[PortfolioProject.dbo.NashvilleHousing]
SET OwnerSplitCity =
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);


/*
Create OwnerSplitState
*/

ALTER TABLE dbo.[PortfolioProject.dbo.NashvilleHousing]
ADD OwnerSplitState NVARCHAR(255);


UPDATE dbo.[PortfolioProject.dbo.NashvilleHousing]
SET OwnerSplitState =
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);


/*
-----------------------------------------------------------
5. Change Y and N to Yes and No
-----------------------------------------------------------
*/

SELECT
    SoldAsVacant,
    COUNT(SoldAsVacant) AS CountOfValues
FROM dbo.[PortfolioProject.dbo.NashvilleHousing]
GROUP BY SoldAsVacant
ORDER BY CountOfValues;


SELECT
    SoldAsVacant,
    CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END AS SoldAsVacantUpdated
FROM dbo.[PortfolioProject.dbo.NashvilleHousing];


UPDATE dbo.[PortfolioProject.dbo.NashvilleHousing]
SET SoldAsVacant =
    CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END;


/*
-----------------------------------------------------------
6. Identify Duplicate Records
-----------------------------------------------------------
*/

WITH RowNumCTE AS
(
    SELECT *,
        ROW_NUMBER() OVER
        (
            PARTITION BY
                ParcelID,
                PropertyAddress,
                SalePrice,
                SaleDate,
                LegalReference
            ORDER BY [UniqueID ]
        ) AS RowNum

    FROM dbo.[PortfolioProject.dbo.NashvilleHousing]
)

SELECT *
FROM RowNumCTE
WHERE RowNum > 1
ORDER BY PropertyAddress;


/*
-----------------------------------------------------------
Delete Duplicate Records
-----------------------------------------------------------
*/

WITH RowNumCTE AS
(
    SELECT *,
        ROW_NUMBER() OVER
        (
            PARTITION BY
                ParcelID,
                PropertyAddress,
                SalePrice,
                SaleDate,
                LegalReference
            ORDER BY [UniqueID ]
        ) AS RowNum

    FROM dbo.[PortfolioProject.dbo.NashvilleHousing]
)

DELETE FROM RowNumCTE
WHERE RowNum > 1;


/*
-----------------------------------------------------------
7. Remove Unused Columns
-----------------------------------------------------------
*/

SELECT *
FROM dbo.[PortfolioProject.dbo.NashvilleHousing];


ALTER TABLE dbo.[PortfolioProject.dbo.NashvilleHousing]
DROP COLUMN
    OwnerAddress,
    TaxDistrict,
    PropertyAddress,
    SaleDate;


/*
-----------------------------------------------------------
8. Final Clean Dataset
-----------------------------------------------------------
*/

SELECT *
FROM dbo.[PortfolioProject.dbo.NashvilleHousing];


/*
===========================================================
    END OF NASHVILLE HOUSING DATA CLEANING PROJECT
===========================================================
*/