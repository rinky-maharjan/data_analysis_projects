select *
from nashvillehousing

--standardize date format

alter table nashvillehousing
add saledateconvert date;

update nashvillehousing
set saledateconvert=convert(date,saledate)

select saledateconvert
from nashvillehousing

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--populate property address data

select *
from nashvillehousing
--where PropertyAddress is null
order by 2

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from nashvillehousing a
join nashvillehousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a 
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from nashvillehousing a
join nashvillehousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
--breaking out address into individual columns(address,city,state)
select 
substring(PropertyAddress,1,charindex(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress)) as City
from nashvillehousing

--address
alter table nashvillehousing
add PropertSplitAddress nvarchar(255);

update nashvillehousing
set  PropertSplitAddress=substring(PropertyAddress,1,charindex(',',PropertyAddress)-1) 

select  PropertSplitAddress
from nashvillehousing

--city
alter table nashvillehousing
add PropertSplitCity nvarchar(255);

update nashvillehousing
set  PropertSplitCity=SUBSTRING(PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress))

select  PropertSplitCity
from nashvillehousing

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--breaking out OwnerAdress into individual columns(address,city,state)//EASIER METHOD without using substring
select PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from nashvillehousing

alter table nashvillehousing
add OwnerSplitAddress nvarchar(255);

update nashvillehousing
set  OwnerSplitAddress=PARSENAME(replace(OwnerAddress,',','.'),3)

select  OwnerSplitAddress
from nashvillehousing

--city
alter table nashvillehousing
add OwnerSplitCity nvarchar(255);

update nashvillehousing
set OwnerSplitCity=PARSENAME(replace(OwnerAddress,',','.'),2)

select  OwnerSplitCity
from nashvillehousing

--state
alter table nashvillehousing
add OwnerSplitState nvarchar(255);

update nashvillehousing
set OwnerSplitState=PARSENAME(replace(OwnerAddress,',','.'),1)

select  OwnerSplitState
from nashvillehousing

------------------------------------------------------------------------------------------------------------------------------------------
--change 'Y' to 'Yes' and 'N' to 'No' in SoldAsVacantField

select distinct(SoldAsVAcant),count(SoldAsVacant)
from nashvillehousing
group by SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
case when SoldAsVacant='Y' then 'Yes'
	 when SoldAsVacant='N' then 'No'
	 else SoldAsVacant
	 End
from nashvillehousing

update nashvillehousing
set SoldAsVacant=case when SoldAsVacant='Y' then 'Yes'
	 when SoldAsVacant='N' then 'No'
	 else SoldAsVacant
	 End

---------------------------------------------------------------------------------------------------------------------------------------
--Removing Duplicate Date

With row_num_cte as(
select *, ROW_NUMBER()over(
partition by ParcelID, PropertyAddress,SalePrice,SaleDate,LegalReference
order by UniqueID) as row_num
from nashvillehousing)

delete
from row_num_cte
where row_num>1


With row_num_cte as(
select *, ROW_NUMBER()over(
partition by ParcelID, PropertyAddress,SalePrice,SaleDate,LegalReference
order by UniqueID) as row_num
from nashvillehousing)

select *
from row_num_cte
where row_num>1
order by PropertyAddress

-----------------------------------------------------------------------------------------------------------------------------------------
--delete unused columns

select *
from nashvillehousing

alter table nashvillehousing
drop column OwnerAddress, TaxDistrict,PropertyAddress