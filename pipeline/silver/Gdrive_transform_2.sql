-- Silver Layer: Categorization and Normalization
-- Pipeline: B_S_expenses (Spark Declarative Pipeline)
-- Input:  workspace.s_expenses.s1_expenses (Bronze)
-- Output: workspace.s_expenses.s2_expenses (MATERIALIZED VIEW)
-- Key: 35+ fuzzy LIKE matching rules for category normalization

CREATE OR REFRESH MATERIALIZED VIEW workspace.s_expenses.S2_expenses AS
select 
  monotonically_increasing_id() as id,
  to_date(date_format(to_date(Date, 'd/M/yyyy'), 'dd/MM/yyyy'), 'dd/MM/yyyy') AS spent_date,
  case 
    when lower(category) like '%deposite%' or lower(category) like '%deposit%' then 'deposit_spends'
    when lower(category) like '%dentist%' or lower(category) like '%health%'or lower(category) like '%medical%' or lower(category) like '%medicine%' or lower(category) like '%medics%' then 'health_spends'
    when lower(category) like '%famliy%' or lower(category) like '%famly%' or lower(category) like '%family%' then 'family_spends'
    when lower(category) like '%fruit%' or lower(category) like '%fruits%' then 'fruits_spends'
    when lower(category) like '%gromming%' or lower(category) like '%grooming%' then 'grooming_spends'
    when lower(category) like '%rent%'and lower(desc) not like '%wm&f%' then 'rent_spends' 
    when lower(category) like '%subscriptions%' or lower(category) like '%subscribation%' or lower(category) like '%youtube%' then 'subscriptions_spends'
    when lower(category) like '%snack%' or lower(category) like '%snacks%' or lower(category) like '%snakcs%' or lower(category) like '%coffee%' then 'snacks_spends'
    when lower(category) like '%taxi%' then 'cab/travel_spends'
    when lower(category) like '%others%' or lower(category) like '%print%'or lower(category) like '%unknown%' or lower(category) like '%transfer%' then 'miscellaneous_spends'
    when amount_in_inr = 266.00 or (lower (category) like '%rent%' and amount_in_inr  = 250.00) or lower(desc) like '%wm&f%' then 'appliance_rent_spends'
    when lower(category) like '%rent%' or amount_in_inr = 6250 then 'flat_rent_spends'
    when lower(category) like '%chair%' then 'capital_spends'
    when lower(category) like '%cook%' or lower(category) like '%cylinder%' then 'kitchen_spends'
    when lower(category) like '%dinner%' or lower(category) like '%food%' then 'dine_spends'
    when lower(category) like '%fuel%' and  lower(category) not like '%cng%' then 'fuel_spends'
    when lower(category) like '%cng%' or lower(desc) like '%cng%'then'cng_spends'
    when lower(category) like '%credit bill%' then 'creditcard_spends'
    when lower(category) like '%grocery%' then 'grocery_spends'
    when lower(category) like '%mobile%' then 'mobile_spends'
    when lower(category) like '%fun%' or lower(category) like '%drink%' then 'fun_spends'
    when lower(category) like '%sports%' then 'sporting_spends'
    when lower(category) like '%vehicle%' then 'vechile_spends'
    when lower(category) like '%eshopping%' then 'shopping_spends'
    when lower(category) like '%car%' or lower(category) like '%maintance%' then 'car_maintenance_spends'
    when lower(category) like '%investment%' then 'investment_spends'
    when lower(category) like '%supplies%' or lower(category) like '%commodities%'or lower(category) like '%posters%' then 'supplies_spends'
    when lower(category) like '%learn%'or  lower(category) like '%learnings%'or  lower(category) like '%learning%' then 'upskill_spends'
    when lower(category) like '%hardware%' then 'hardware_spends'
    when lower(category) like '%cash%' then 'cash_spends'
    when lower(category) like '%donation%' then 'donational_spends'
    else lower(trim(category))
  end as category,
  case 
    when lower(category) like '%chiar%' then 'chair'
    when lower(category) like '%dinner%' or lower(category) like '%food%' then 'order/dine_in_food'
    when lower(category) like '%fuel%' and (CAST(Amount_in_INR AS INT) < 1000 ) then '2W_fuel_spends'
    when lower(category) like '%fuel%' and (CAST(Amount_in_INR AS INT) > 999 ) then '4W_fuel_spends'
    else lower(trim(Desc))
  end as desc,
  note, 
  CAST(amount_in_inr AS INT) AS spends_in_inr,
  date_format(CAST(Row_recivied_time AS TIMESTAMP), "yyyy-MM-dd'T'HH:mm:ss") as meta_load_dttm
from workspace.s_expenses.s1_expenses