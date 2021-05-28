/* 
Data Cleaning 
/* 

-- Fixing Empty PropertyAddress Cells --

select a.ParcelID, a.PropertyAddress, b.parcelID, b.propertyaddress,coalesce(a.propertyaddress,b.propertyaddress)
from houses as a join houses as b
on a.parcelID = b.parcelID
where a.uniqueID != b.uniqueID 
and a.propertyaddress is null

update houses as a
join houses as b 
on a.parcelid = b.parcelid 
set a.propertyaddress = coalesce(a.propertyaddress,b.propertyaddress)
where a.uniqueid != b.uniqueID
and a.propertyaddress is null

-- Fixing LandUse Column -- 

select distinct(landuse)
from houses

update houses
set landuse = 'Vacant Residential Land'
where landuse = 'Vacant Res Land'

update houses
set landuse = 'Greenbelt'
where landuse = 'GREENBELT/RES GREENBELT/RES'


-- Seperate Property Address --

select SUBSTRING_INDEX(propertyaddress,",",1) as propertyAddressStreet,
SUBSTRING_INDEX(propertyaddress,",",-1) as propertyAddressCity
from houses

alter table houses
add column propertyAddressStreet varchar(50)

update houses
set propertyAddressStreet = SUBSTRING_INDEX(propertyaddress,",",1)

alter table houses
add column propertyAddressCity varchar(50)

update houses
set propertyAddressCity = SUBSTRING_INDEX(propertyaddress,",",-1)

alter table houses
drop column propertyaddress


-- Separate Owner Address -- 

alter table houses
add column ownerAddressStreet varchar(50)

update houses
set ownerAddressStreet = substring_index(ownerAddress,",",1) 

alter table houses
add column ownerAddressCity varchar(50)

update houses
set ownerAddressCity = SUBSTRING_INDEX(substring_index(ownerAddress,",",-2),",",1) 

alter table houses
add column ownerAddressState varchar(50)

update houses
set ownerAddressState =  substring_index(ownerAddress,",",-1) 

alter table houses
drop column owneraddress


-- Standardize SoldasVacant Column -- 

update houses
set soldasvacant = "Yes"
where soldasvacant = "Y"

update houses
set soldasvacant = "No"
where soldasvacant = "N"


-- Deleting Duplicate Row Entries -- 

create temporary table rowNums
(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
					) rowNum
From houses
)
delete 
from rowNums
where rownum > 1

drop table houses

create table houses 
select * from rowNums

alter table houses
drop column rowNum
