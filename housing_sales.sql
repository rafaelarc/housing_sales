/*

Limpeza de Dados com SQL

*/

select 
    *
from nashville.housing_sales

-- Padronizando formato da data

alter table nashville.housing_sales
add column SaleDateConverted Date;

update nashville.housing_sales
set SaleDateConverted = parse_date("%B %e, %Y", SaleDate)
where true

-- Preenchendo dados do endereço

select 
    *
from nashville.housing_sales
where PropertyAddress is null
order by ParcelID

select 
    t1.parcelID, 
    t1.PropertyAddress, 
    t2.ParcelID, 
    t2.PropertyAddress, 
    ifnull(a.PropertyAddress, b.PropertyAddress) as PropertyAddressNew
from nashville.housing_sales t1
join nashville.housing_sales t2 on t1.ParcelID = t2.ParcelID and t1.UniqueID <> t2.UniqueID
where t1.PropertyAddress is null

update nashville.housing_sales t1
set PropertyAddress = t2.PropertyAddress
from (
  select ParcelID, 
  min(PropertyAddress) PropertyAddress
  from nashville.housing_sales
  where not PropertyAddress is null
  group by ParcelID
) t2
where t1.ParcelID = t2.ParcelID
and t1.PropertyAddress is null

-- Dividindo o endereço em colunas (endereço, cidade, estado)

select 
    PropertyAddress
from nashville.housing_sales

select
substr(PropertyAddress, 1, strpos(PropertyAddress, ",") -1) as Address, 
substr(PropertyAddress, strpos(PropertyAddress, ",") +1, length(PropertyAddress)) as Address 
from nashville.housing_sales


alter table nashville.housing_sales
add column PropertySplitAddress string;

update nashville.housing_sales
set PropertySplitAddress = substr(PropertyAddress, 1, strpos(PropertyAddress, ",") -1)
where true


alter table nashville.housing_sales
add column PropertySplitCity string;

update nashville.housing_sales
set PropertySplitCity = substr(PropertyAddress, strpos(PropertyAddress, ",") +1, length(PropertyAddress))
where true

select
SPLIT(OwnerAddress, ",") [OFFset(0)] as A,
SPLIT(OwnerAddress, ',')[OFFset(1)] as B,
SPLIT(OwnerAddress, ',')[OFFset(2)] as C
from nashville.housing_sales

alter table nashville.housing_sales
add column OwnerSplitAddress string;

update nashville.housing_sales
set OwnerSplitAddress = split(OwnerAddress, ",") [OFFset(0)]
where true

alter table nashville.housing_sales
add column OwnerSplitCity string;

update nashville.housing_sales
set OwnerSplitCity = split(OwnerAddress, ',')[OFFset(1)]
where true


alter table nashville.housing_sales
add column OwnerSplitState string;

update nashville.housing_sales
set OwnerSplitState = split(OwnerAddress, ',')[OFFset(2)]
where true

-- Alterando Y e N para Yes e No na coluna SoldAsVacant

select 
  distinct(SoldAsVacant), 
  count(SoldAsVacant)
from nashville.housing_sales
group by SoldAsVacant
order by 2

select 
  SoldAsVacant, 
  case when SoldAsVacant = 'Y' then 'Yes' when SoldAsVacant = 'N' then 'No' else SoldAsVacant end
from nashville.housing_sales

update nashville.housing_sales
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes' when SoldAsVacant = 'N' then 'No' else SoldAsVacant end

-- Removendo duplicados

create or replace table nashville.housing_sales as
select 
    *,
    row_number() over (partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference order by UniqueID) as row_num
from nashville.housing_sales
)

delete 
from nashville.housing_sales
where row_num > 1

-- Excluindo colunas desnecessárias

alter table nashville.housing_sales
drop column row_num

alter table nashville.housing_sales
drop column OwnerAddress

alter table nashville.housing_sales
drop column PropertyAddress

alter table nashville.housing_sales
drop column SaleDate