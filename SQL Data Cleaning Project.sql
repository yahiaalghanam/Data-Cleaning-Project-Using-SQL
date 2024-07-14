
-- Cleaning data in SQL queiries  
SELECT *
FROM houses

--Standrize Data Format 
SELECT SaleDate, CONVERT (date, SaleDate) as NewSaleDate 
FROM houses 

-- Convert sale date to the stander form in the original table 
alter table houses 
add NewSaleDate date 

update houses  
set NewSaleDate = CONVERT (date, SaleDate)


SELECT NewSaleDate 
FROM houses 


-- Popuate Property adderss data
select * 
from houses 

SELECT a.PropertyAddress , b.PropertyAddress , isnull (a.PropertyAddress, b.PropertyAddress)as NewPropertyAddress 
FROM houses a join houses b 
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID 
where a.PropertyAddress is null 

--Update the table in the database 
update a
set PropertyAddress = isnull (a.PropertyAddress, b.PropertyAddress) 
FROM houses a join houses b 
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID

--Review the selected attribute 
select * from houses 
where PropertyAddress is  null 


--------------------------------------------------------------------------------------------------
-- Breaking out the address into (address, city, state) 
select PropertyAddress, SUBSTRING(PropertyAddress, -1,CHARINDEX(',' , PropertyAddress)) as address, 
SUBSTRING(PropertyAddress,CHARINDEX(',' , PropertyAddress)+1, len(PropertyAddress)) as NewAddress 
from houses 


--Saver the changes to the table

alter table houses 
add spilittedAddress nvarchar (255)

update houses  
set 
spilittedAddress= SUBSTRING(PropertyAddress, -1,CHARINDEX(',' , PropertyAddress))
from houses 


alter table houses 
add spilittedCity nvarchar (255)

update houses  
set 
spilittedCity= SUBSTRING(PropertyAddress,CHARINDEX(',' , PropertyAddress)+1, len(PropertyAddress))
from houses 
select  spilittedAddress, spilittedCity
from houses 


------------------------------------------------------------------------------------------------
-- The second way to Breaking out the address into (address, city, state)  
 select 
 parsename(replace( OwnerAddress, ',','.'),3) as address,
 parsename(replace( OwnerAddress, ',','.'),2) as city ,
 parsename(replace( OwnerAddress, ',','.'),1) as state
 from houses 


 --Saving the result 
 alter table houses 
 add address nvarchar (255), 
 city nvarchar (255), 
 state nvarchar (255)


 --Update the table 
 update houses 
 set  
 address = parsename(replace( OwnerAddress, ',','.'),3) ,
 city=parsename(replace( OwnerAddress, ',','.'),2) ,
 state = parsename(replace( OwnerAddress, ',','.'),1) 
 from houses 

 select address, city, state 
 from houses 

 
---------------------------------------------------------------------------------------------
 -- Change 'Y' into Yes and 'N' into No in Sold as vegent coulumn 
select SoldAsVacant, 
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end  as NewSoldAsVacant
from houses


-- Add the updates in the main table 
alter table houses
add NewSoldAsVacant nvarchar (255)

update houses
set NewSoldAsVacant= case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end 
from houses


select SoldAsVacant, NewSoldAsVacant
from houses


-----------------------------------------------------------------------------------------------
--Remove duplicates 
--Create a Temporary table to demove duplicate rows from it 
with RowNumCTE 
as (
 select * , 
			ROW_NUMBER() over ( Partition by ParcelID, PropertyAddress, SaleDate, LegalReference 
			order by UniqueID )  RowNum
			
 from houses 
 )
 delete  
 from RowNumCTE
 where RowNum > 1 


 ----------------------------------------------------------------------------------------------
 --Delete Unused coulumn 
alter table houses 
drop column SaleDate, SoldAsVacant

select * from houses 