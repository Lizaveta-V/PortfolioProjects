/*
Cleaning Data in SQL Queries
*/


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing



--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


SELECT SaleDate, CONVERT(DATE, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD SaleDateConverted DATE


UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)


SELECT SaleDateConverted, CONVERT(DATE, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing



--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data


SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
	WHERE a.PropertyAddress IS NULL



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255),
	PropertySplitCity NVARCHAR(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1),
	PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));



Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255),
	OwnerSplitCity NVARCHAR(255),
	OwnerSplitState NVARCHAR(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);



--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						  WHEN SoldAsVacant = 'N' THEN 'No'
						  ELSE SoldAsVacant
						  END
FROM PortfolioProject.dbo.NashvilleHousing


UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
					    WHEN SoldAsVacant = 'N' THEN 'No'
					    ELSE SoldAsVacant
					    END



--------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates


WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY UniqueID)
	row_num
FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)

DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress



--------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
