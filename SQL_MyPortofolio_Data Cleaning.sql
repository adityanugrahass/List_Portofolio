-- Before we doing query on the data, its really important to check the data type, because if the data type is not relevant/support with the function/statement you’ll get some error.
-- Execute this one by one.
USE PortofolioProject
SP_HELP NashvilleHousing


------------------------------------ Queries for Data Cleaning in SQL ------------------------------------

SELECT *
FROM PortofolioProject.dbo.NashvilleHousing


------------------------------------------------------------------------------------------------------------
--------------- 1. Standardized Date Format ---------------

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortofolioProject.dbo.NashvilleHousing

ALTER TABLE PortofolioProject.dbo.NashvilleHousing 
Add SaleDateConverted Date;

UPDATE PortofolioProject.dbo.NashvilleHousing 
SET SaleDateConverted = CONVERT(Date, SaleDate)



------------------------------------------------------------------------------------------------------------

--------------- 2. Populate Property Address Data ---------------

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress) 
FROM PortofolioProject.dbo.NashvilleHousing a
JOIN PortofolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM PortofolioProject.dbo.NashvilleHousing a
JOIN PortofolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL



------------------------------------------------------------------------------------------------------------
--------------- 3. Breaking out Address into Individuals Columns (Address, City, State) ---------------

--Breaking out PropertyAddress

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) Address
FROM PortofolioProject..NashvilleHousing


--Adding new columns

ALTER TABLE PortofolioProject.dbo.NashvilleHousing 
Add PropertySplitAddress Nvarchar(255);

UPDATE PortofolioProject.dbo.NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE PortofolioProject.dbo.NashvilleHousing 
Add PropertySplitCity NVARCHAR(255);

UPDATE PortofolioProject.dbo.NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))


--Breaking out OwnerAddress

SELECT OwnerAddress
FROM PortofolioProject..NashvilleHousing
WHERE OwnerAddress is NOT NULL

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM PortofolioProject..NashvilleHousing
WHERE OwnerAddress is NOT NULL


--Adding new columns

ALTER TABLE PortofolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortofolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE PortofolioProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortofolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE PortofolioProject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortofolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



------------------------------------------------------------------------------------------------------------
--------------- 4. Change Y and N to Yes and No in "Sold as Vacant" field ---------------

--Find the data in SoldAsVacant column then check the data and adjust it so that the data content has a consistent value

SELECT DISTINCT SoldAsVacant, COUNT (SoldAsVacant) CntSoldAsVacant
FROM PortofolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2 DESC

--Change Y and N to Yes and No

SELECT SoldAsVacant,
	CASE SoldAsVacant
			WHEN 'Y' THEN 'Yes'
			WHEN 'N' THEN 'No'
		ELSE SoldAsVacant	
	END NewSold
FROM PortofolioProject..NashvilleHousing


--Update the changes that have been made

UPDATE PortofolioProject.dbo.NashvilleHousing
SET SoldAsVacant =
	CASE SoldAsVacant
			WHEN 'Y' THEN 'Yes'
			WHEN 'N' THEN 'No'
	ELSE SoldAsVacant
	END



------------------------------------------------------------------------------------------------------------
--------------- 5. Remove Duplicates ---------------

WITH RowNumCTE
AS
(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM PortofolioProject.dbo.NashvilleHousing
)

DELETE
FROM RowNumCTE
WHERE row_num > 1



------------------------------------------------------------------------------------------------------------
--------------- 6. Delete Unused Columns ---------------

SELECT *
FROM PortofolioProject..NashvilleHousing

ALTER TABLE PortofolioProject..NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, SaleDate, TaxDistrict