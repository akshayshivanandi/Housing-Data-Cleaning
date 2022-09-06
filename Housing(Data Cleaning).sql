
--#Data Cleaning

USE Housing;

SELECT *
FROM Housing.dbo.HousingProject

--------------------------------------------------------------------

--Formatting the date

SELECT SaleDate 
FROM Housing..HousingProject

ALTER TABLE Housing..HousingProject
ALTER COLUMN SaleDate Date;

-----------------------------------------------------------------------------

-- Fixing Property Address Column

SELECT *
FROM Housing..HousingProject
WHERE PropertyAddress is Null;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM Housing..HousingProject a
JOIN Housing..HousingProject b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is Null;

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Housing..HousingProject a
JOIN Housing..HousingProject b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is Null;

-------------------------------------------------------------------------------------------

------Breaking the address

--For Property Address

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as PropertyAddressUpdated,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as PropertyCity
FROM Housing..HousingProject


ALTER TABLE HousingProject ADD PropertyAddressUpdated VARCHAR(255)

UPDATE HousingProject
SET PropertyAddressUpdated = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE HousingProject ADD PropertyCity VARCHAR(255);

UPDATE HousingProject
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


--For Owner Address

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM HousingProject

ALTER TABLE HousingProject ADD OwnerAddressUpdated VARCHAR(255);

UPDATE HousingProject
SET OwnerAddressUpdated = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3);


ALTER TABLE HousingProject ADD OwnerCity VARCHAR(255);

UPDATE HousingProject
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2);


ALTER TABLE HousingProject ADD OwnerState VARCHAR(255);

UPDATE HousingProject
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1);


---------------------------------------------------

-- Fixing SoldAsVacant Column(Changing Y & N to Yes & No respectively)

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM HousingProject
GROUP BY SoldAsVacant;

UPDATE HousingProject 
SET SoldAsVacant =
CASE WHEN SoldAsVacant = 'Y' then 'Yes'
	 WHEN SoldAsVacant = 'N' then 'No'
	 ELSE SoldAsVacant END;


-----------------------------------------------------------------------

-- Deleting Duplicates

WITH HousingCTE as 
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY ParcelID,
							   PropertyAddress,
							   SaleDate,
							   SalePrice,
							   LegalReference,
							   OwnerName
							   ORDER BY UniqueId) as Row_num
FROM HousingProject
)
SELECT * 
FROM HousingCTE
WHERE Row_num > 1;


WITH HousingCTE as 
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY ParcelID,
							   PropertyAddress,
							   SaleDate,
							   SalePrice,
							   LegalReference,
							   OwnerName
							   ORDER BY UniqueId) as Row_num
FROM HousingProject
)
SELECT *
FROM HousingCTE
WHERE Row_num > 1;

								
SELECT *
FROM HousingProject;


----------------------------------------------------------------------------

-- Delete Extra Columns

ALTER TABLE HousingProject
DROP COLUMN PropertyAddress,OwnerAddress, TaxDistrict;

EXECUTE SP_RENAME @objname = 'HousingProject.PropertyAddressUpdated', @newname = 'PropertyAddress', @objtype = 'COLUMN';
EXECUTE SP_RENAME @objname = 'HousingProject.OwnerAddressUpdated', @newname = 'OwnerAddress', @objtype = 'COLUMN';


SELECT *
FROM HousingProject;


