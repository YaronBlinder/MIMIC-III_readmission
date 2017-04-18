set search_path to mimiciii;

drop materialized view if exists all_data;
create materialized view all_data as
  with lab_aggs as
  (
    select le.subject_id, le.hadm_id
    , min(case when le.itemid=51006 then le.valuenum else null end) as urea_N_min
    , max(case when le.itemid=51006 then le.valuenum else null end) as urea_N_max
    , avg(case when le.itemid=51006 then le.valuenum else null end) as urea_N_mean
    , min(case when le.itemid=51265 then le.valuenum else null end) as platelets_min
    , max(case when le.itemid=51265 then le.valuenum else null end) as platelets_max
    , avg(case when le.itemid=51265 then le.valuenum else null end) as platelets_mean
    , max(case when le.itemid=50960 then le.valuenum else null end) as magnesium_max
    , min(case when le.itemid=50862 then le.valuenum else null end) as albumin_min
    , min(case when le.itemid=50893 then le.valuenum else null end) as calcium_min
    from labevents le
    where hadm_id is not null
    group by 1,2 order by 1,2
  )
  , chartevent_aggs as
  (
    select hadm_id
    , min(case when itemid in (615,618,220210,224690) and valuenum > 0 and valuenum < 70 then valuenum else null end) as RespRate_Min
    , max(case when itemid in (615,618,220210,224690) and valuenum > 0 and valuenum < 70 then valuenum else null end) as RespRate_Max
    , avg(case when itemid in (615,618,220210,224690) and valuenum > 0 and valuenum < 70 then valuenum else null end) as RespRate_Mean
    , min(case when itemid in (807,811,1529,3745,3744,225664,220621,226537) and valuenum > 0 then valuenum else null end) as Glucose_Min
    , max(case when itemid in (807,811,1529,3745,3744,225664,220621,226537) and valuenum > 0 then valuenum else null end) as Glucose_Max
    , avg(case when itemid in (807,811,1529,3745,3744,225664,220621,226537) and valuenum > 0 then valuenum else null end) as Glucose_Mean
    , min(case when itemid in (211,220045) and valuenum > 0 and valuenum < 300 then valuenum else null end) as HR_min
    , max(case when itemid in (211,220045) and valuenum > 0 and valuenum < 300 then valuenum else null end) as HR_max
    , round(cast(avg(case when itemid in (211,220045) and valuenum > 0 and valuenum < 300 then valuenum else null end) as numeric), 2) as HR_mean
    , min(case when itemid in (51,442,455,6701,220179,220050) and valuenum > 0 and valuenum < 400 then valuenum else null end) as SysBP_min
    , max(case when itemid in (51,442,455,6701,220179,220050) and valuenum > 0 and valuenum < 400 then valuenum else null end) as SysBP_max
    , round(cast(avg(case when itemid in (51,442,455,6701,220179,220050) and valuenum > 0 and valuenum < 400 then valuenum else null end) as numeric), 2) as SysBP_mean
    , min(case when itemid in (8368,8440,8441,8555,220180,220051) and valuenum > 0 and valuenum < 300 then valuenum else null end) as DiasBP_min
    , max(case when itemid in (8368,8440,8441,8555,220180,220051) and valuenum > 0 and valuenum < 300 then valuenum else null end) as DiasBP_max
    , round(cast(avg(case when itemid in (8368,8440,8441,8555,220180,220051) and valuenum > 0 and valuenum < 300 then valuenum else null end) as numeric), 2) as DiasBP_mean
    , min(case when itemid in (223761,678) and valuenum > 70 and valuenum < 120 then (valuenum-32)/1.8
               when itemid in (223762,676)  and valuenum > 10 and valuenum < 50 then valuenum else null end) as temp_min
    , max(case when itemid in (223761,678) and valuenum > 70 and valuenum < 120 then (valuenum-32)/1.8
               when itemid in (223762,676)  and valuenum > 10 and valuenum < 50 then valuenum else null end) as temp_max
    , round(cast(avg(case when itemid in (223761,678) and valuenum > 70 and valuenum < 120 then (valuenum-32)/1.8
               when itemid in (223762,676)  and valuenum > 10 and valuenum < 50 then valuenum else null end) as numeric), 2) as temp_mean
    from chartevents
    where itemid in
    (
      615,618,220210,224690, --- RespRate
      807,811,1529,3745,3744,225664,220621,226537, --- Glucose
      211,220045,---HR
      51,442,455,6701,220179,220050,---SysBP
      8368,8440,8441,8555,220180,220051,--DiasBP
      223761,678,223762,676--Temp
    )
    and hadm_id is not null
    group by 1
  )
  , output_agg as
  (
    select hadm_id
    , min(value) as urine_min
    , max(value) as urine_max
    , round(cast(avg(value) as numeric)) as urine_mean
    from outputevents
    where itemid in (40055,226559)
    and hadm_id is not null
    group by 1
  )


  select la.subject_id, la.hadm_id, ad.admittime, ad.dischtime, ad.deathtime
  , ie.first_careunit, ie.last_careunit
  , extract(epoch from (ad.admittime - p.dob))/60.0/60.0/24.0/365.242 as age
  , p.gender as gender
  , ad.marital_status as marital_status
  , ad.insurance as insurance
  , urea_N_min
  , urea_N_max
  , urea_N_mean
  , platelets_min
  , platelets_max
  , platelets_mean
  , magnesium_max
  , albumin_min
  , calcium_min
  , RespRate_Min
  , RespRate_Max
  , RespRate_Mean
  , Glucose_Min
  , Glucose_Max
  , Glucose_Mean
  , HR_min
  , HR_max
  , HR_mean
  , SysBP_min
  , SysBP_max
  , SysBP_mean
  , DiasBP_min
  , DiasBP_max
  , DiasBP_mean
  , temp_min
  , temp_max
  , temp_mean
  , sapsii
  , sofa
  , urine_min
  , urine_mean
  , urine_max

  from lab_aggs la
    inner join output_agg oa
    on la.hadm_id = oa.hadm_id
    inner join patients p
    on la.subject_id = p.subject_id
    inner join admissions ad
    on la.hadm_id = ad.hadm_id
    inner join chartevent_aggs ca
    on la.hadm_id = ca.hadm_id
    inner join icustays ie
    on la.hadm_id = ie.hadm_id
    inner join SAPSII
    on la.hadm_id = SAPSII.hadm_id
    inner join SOFA
    on la.hadm_id = SOFA.hadm_id
  group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26
  ,27,28,29,30,31,32,33,34,35,36,37,38,39,40, 41, 42, 43
  order by 1,3
  ;
