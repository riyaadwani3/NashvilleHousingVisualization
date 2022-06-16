/*
Cleaning Data in SQL Queries
*/

Select *
From NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

--------------------------------------------------------------------------------------------------------------------------

Select SaleDate, CONVERT(date, SaleDate)
From NashvilleHousing

Alter table NashvilleHousing
Alter column SaleDate date

--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Select *
From NashvilleHousing
where PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress, 
SUBSTRING(PropertyAddress,1,charindex(',',PropertyAddress)-1),
SUBSTRING(PropertyAddress,charindex(',',PropertyAddress)+1,LEN(PropertyAddress))
From NashvilleHousing

Alter table NashvilleHousing
Add PropertySplitAddress nvarchar(255), 
    PropertySplitCity Nvarchar(255)

Update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,charindex(',',PropertyAddress)-1) 

Update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress,charindex(',',PropertyAddress)+1,LEN(PropertyAddress))

Select *
From NashvilleHousing

Select OwnerAddress, 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From NashvilleHousing


Alter table NashvilleHousing
Add OwnerSplitAddress nvarchar(255), 
    OwnerSplitCity Nvarchar(255),
	OwnerSplitState Nvarchar(255)


Update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3) 

Update NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2) 

Update NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1) 

-------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

Select SoldAsVacant, COUNT(SoldAsVacant)
From NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant, 
case when SoldAsVacant = 'Y' then 'Yes' 
     when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
From NashvilleHousing

Update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes' 
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates

Select *, 
	ROW_NUMBER() over(partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by UniqueID) rn
From NashvilleHousing

with DuplicatesCTE 
as (Select *, 
	ROW_NUMBER() over(partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by UniqueID) rn
From NashvilleHousing)

Select * from DuplicatesCTE
where rn > 1
Order by PropertyAddress

Delete from DuplicatesCTE
where rn > 1

---------------------------------------------------------------------------------------------------------
-- Delete Unused Columns

Select *
From NashvilleHousing

Alter table NashvilleHousing
Drop column PropertyAddress, OwnerAddress, TaxDistrict, SaleDate

Select *
From NashvilleHousing