/*

Data Cleaning

*/

Select *
From	Portfolio_Project..NashvilleHousing NashvilleHousing


-- Standardize Date Format

Select SaleDate, CONVERT(Date,SaleDate)
From	Portfolio_Project..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


-- Populate Property Address Data

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From	Portfolio_Project..NashvilleHousing a JOIN Portfolio_Project..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From	Portfolio_Project..NashvilleHousing a JOIN Portfolio_Project..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


-- Breaking out Address into Individual Columns (Adress, City, State)

Select PropertyAddress
From Portfolio_Project..NashvilleHousing

Select 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) As Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) As City
From Portfolio_Project..NashvilleHousing
--
ALTER TABLE Portfolio_Project..NashvilleHousing
Add PropertySplitAdress Nvarchar(255);

Update Portfolio_Project..NashvilleHousing
SET PropertySplitAdress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 
--
ALTER TABLE Portfolio_Project..NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update Portfolio_Project..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


Select OwnerAddress
From Portfolio_Project..NashvilleHousing

Select
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) As State,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) As City,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) As Address
From Portfolio_Project..NashvilleHousing


ALTER TABLE Portfolio_Project..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update Portfolio_Project..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE Portfolio_Project..NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update Portfolio_Project..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE Portfolio_Project..NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update Portfolio_Project..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-- Change Yes and No to Y and N in 'sold as vacant'

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Portfolio_Project..NashvilleHousing
Group by  SoldAsVacant
Order by 2

Select SoldAsVacant,
	CASE 
		when SoldAsVacant = 'Y' THEN 'Yes'
		when SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
From Portfolio_Project..NashvilleHousing

Update Portfolio_Project..NashvilleHousing
SET SoldAsVacant = CASE 
		when SoldAsVacant = 'Y' THEN 'Yes'
		when SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END


-- Remove Duplicates

Select *
From Portfolio_Project..NashvilleHousing


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY 
		ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER by
			UniqueID
) row_num
From Portfolio_Project..NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1


-- Delete Unused Columns

Select *
From Portfolio_Project..NashvilleHousing

Alter TABLE Portfolio_Project..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

Alter TABLE Portfolio_Project..NashvilleHousing
DROP COLUMN SaleDate



