/*************************************************************************************************************************
overview:
    purpose of this script IS to find ALL shoulder-related diagnoses IN cms files
    occurring near breast cancer diagnosis, for cms breast cancer cohort
req inputs: 
    -TABLE of shoulder-related icd diagnosis codes (cchapman6.icd_dx_shldr)
    -medicare ffs claims
output: 
    -TABLE with shoulder-related medicare ffs claims for cms bc cohort
*************************************************************************************************************************/

/*************************************************************************************************************************
check format of icd code IN diagnosis lookup TABLE AND cms files
*************************************************************************************************************************/
SELECT line_icd_dgns_cd, line_icd_dgns_vrsn_cd 
FROM cms_deid.bcarrier_line
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

SELECT code, code_fmt 
FROM cchapman6.icd_dx_shldr
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

/*************************************************************************************************************************
get ALL shoulder-related claims FROM physician/carrier source
shoulder-related based ON diagnosis code IN line files ONLY
*************************************************************************************************************************/
DROP TABLE cchapman6.coh_cms_car_l_shldr;
CREATE TABLE cchapman6.coh_cms_car_l_shldr AS 
/* 2011-2013 cms carrier */
SELECT a.bene_id, a.line_1st_expns_dt AS dgns_dt, a.line_icd_dgns_cd AS icd_dgns_cd, 
    a.line_icd_dgns_vrsn_cd AS icd_dgns_vrsn, b.code_type
FROM cms_deid.bcarrier_line a 
INNER JOIN cchapman6.icd_dx_shldr b
ON a.line_icd_dgns_cd = b.code
UNION ALL
/* 2014 cms carrier */
SELECT a.bene_id, a.line_1st_expns_dt AS dgns_dt, a.line_icd_dgns_cd AS icd_dgns_cd, 
    a.line_icd_dgns_vrsn_cd AS icd_dgns_vrsn, b.code_type
FROM cms_deid_2014_updated.bcarrier_line_k a 
INNER JOIN cchapman6.icd_dx_shldr b
ON a.line_icd_dgns_cd = b.code
UNION ALL
/* 2015 cms carrier */
SELECT a.bene_id, a.line_1st_expns_dt AS dgns_dt, a.line_icd_dgns_cd AS icd_dgns_cd, 
    a.line_icd_dgns_vrsn_cd AS icd_dgns_vrsn, b.code_type
FROM cms_deid_2015_updated.bcarrier_line_k a 
INNER JOIN cchapman6.icd_dx_shldr b
ON a.line_icd_dgns_cd = b.code;

/*************************************************************************************************************************
check icd version
clean up TABLE
*************************************************************************************************************************/
SELECT DISTINCT code_type, icd_dgns_vrsn FROM cchapman6.coh_cms_car_l_shldr;
ALTER TABLE cchapman6.coh_cms_car_l_shldr
    ADD (icd_d_v varchar2(7),
         clm_source varchar2(7) DEFAULT 1);
UPDATE cchapman6.coh_cms_car_l_shldr
    SET icd_d_v = CASE
        WHEN icd_dgns_vrsn IN ('0', '9', '09') THEN 9
        WHEN icd_dgns_vrsn IN ('1', '10') THEN 10
        ELSE 0 END;
SELECT DISTINCT code_type, icd_dgns_vrsn, icd_d_v FROM cchapman6.coh_cms_car_l_shldr;
DELETE FROM cchapman6.coh_cms_car_l_shldr 
    WHERE code_type <> icd_d_v;
ALTER TABLE cchapman6.coh_cms_car_l_shldr 
    DROP (icd_dgns_vrsn, icd_d_v);

/*************************************************************************************************************************
get ALL shoulder-related claims FROM outpatient source
shoulder-related based ON diagnosis code IN position 1 through 4
note that 2014 AND 2015 cms_deid don't have icd_dgns_vrsn so that code IS commented out
*************************************************************************************************************************/
DROP TABLE cchapman6.coh_cms_op_b_shldr;
CREATE TABLE cchapman6.coh_cms_op_b_shldr AS 
/* 2011-2013 cms outpatient dx pos 1-4 */
SELECT a.bene_id, a.clm_from_dt AS dgns_dt, 
    a.icd_dgns_cd1 AS icd_dgns_cd /*, a.icd_dgns_vrsn_cd1 AS icd_dgns_vrsn, b.code_type*/
FROM cms_deid.outpatient_base_claims a 
INNER JOIN cchapman6.icd_dx_shldr b
ON a.icd_dgns_cd1 = b.code
WHERE a.icd_dgns_cd1 IS NOT NULL
UNION ALL
SELECT a.bene_id, a.clm_from_dt AS dgns_dt, 
    a.icd_dgns_cd2 AS icd_dgns_cd /*, a.icd_dgns_vrsn_cd2 AS icd_dgns_vrsn, b.code_type */
FROM cms_deid.outpatient_base_claims a 
INNER JOIN cchapman6.icd_dx_shldr b
ON a.icd_dgns_cd2 = b.code
WHERE a.icd_dgns_cd2 IS NOT NULL
UNION ALL 
SELECT a.bene_id, a.clm_from_dt AS dgns_dt, 
    a.icd_dgns_cd3 AS icd_dgns_cd /*, a.icd_dgns_vrsn_cd3 AS icd_dgns_vrsn, b.code_type */
FROM cms_deid.outpatient_base_claims a 
INNER JOIN cchapman6.icd_dx_shldr b
ON a.icd_dgns_cd3 = b.code
WHERE a.icd_dgns_cd3 IS NOT NULL
UNION ALL 
SELECT a.bene_id, a.clm_from_dt AS dgns_dt, 
    a.icd_dgns_cd4 AS icd_dgns_cd /*, a.icd_dgns_vrsn_cd4 AS icd_dgns_vrsn, b.code_type */
FROM cms_deid.outpatient_base_claims a 
INNER JOIN cchapman6.icd_dx_shldr b
ON a.icd_dgns_cd4 = b.code
WHERE a.icd_dgns_cd4 IS NOT NULL
/* 2014 cms outpatient dx pos 1-4 */
UNION ALL
SELECT a.bene_id, a.clm_from_dt AS dgns_dt, 
    a.icd_dgns_cd1 AS icd_dgns_cd /*, a.icd_dgns_vrsn_cd1 AS icd_dgns_vrsn, b.code_type */
FROM cms_deid_2014_updated.outpatient_base_claims_k a 
INNER JOIN cchapman6.icd_dx_shldr b
ON a.icd_dgns_cd1 = b.code
WHERE a.icd_dgns_cd1 IS NOT NULL
UNION ALL
SELECT a.bene_id, a.clm_from_dt AS dgns_dt, 
    a.icd_dgns_cd2 AS icd_dgns_cd /*, a.icd_dgns_vrsn_cd2 AS icd_dgns_vrsn, b.code_type */
FROM cms_deid_2014_updated.outpatient_base_claims_k a 
INNER JOIN cchapman6.icd_dx_shldr b
ON a.icd_dgns_cd2 = b.code
WHERE a.icd_dgns_cd2 IS NOT NULL
UNION ALL 
SELECT a.bene_id, a.clm_from_dt AS dgns_dt, 
    a.icd_dgns_cd3 AS icd_dgns_cd /*, a.icd_dgns_vrsn_cd3 AS icd_dgns_vrsn, b.code_type */
FROM cms_deid_2014_updated.outpatient_base_claims_k a 
INNER JOIN cchapman6.icd_dx_shldr b
ON a.icd_dgns_cd3 = b.code
WHERE a.icd_dgns_cd3 IS NOT NULL
UNION ALL 
SELECT a.bene_id, a.clm_from_dt AS dgns_dt, 
    a.icd_dgns_cd4 AS icd_dgns_cd /*, a.icd_dgns_vrsn_cd4 AS icd_dgns_vrsn, b.code_type*/
FROM cms_deid_2014_updated.outpatient_base_claims_k a 
INNER JOIN cchapman6.icd_dx_shldr b
ON a.icd_dgns_cd4 = b.code
WHERE a.icd_dgns_cd4 IS NOT NULL
/* 2015 cms outpatient dx pos 1-4 */
UNION ALL
SELECT a.bene_id, a.clm_from_dt AS dgns_dt, 
    a.icd_dgns_cd1 AS icd_dgns_cd /*, a.icd_dgns_vrsn_cd1 AS icd_dgns_vrsn, b.code_type*/
FROM cms_deid_2015_updated.outpatient_base_claims_k a 
INNER JOIN cchapman6.icd_dx_shldr b
ON a.icd_dgns_cd1 = b.code
WHERE a.icd_dgns_cd1 IS NOT NULL
UNION ALL
SELECT a.bene_id, a.clm_from_dt AS dgns_dt, 
    a.icd_dgns_cd2 AS icd_dgns_cd /*, a.icd_dgns_vrsn_cd2 AS icd_dgns_vrsn, b.code_type*/
FROM cms_deid_2015_updated.outpatient_base_claims_k a 
INNER JOIN cchapman6.icd_dx_shldr b
ON a.icd_dgns_cd2 = b.code
WHERE a.icd_dgns_cd2 IS NOT NULL
UNION ALL 
SELECT a.bene_id, a.clm_from_dt AS dgns_dt, 
    a.icd_dgns_cd3 AS icd_dgns_cd /*, a.icd_dgns_vrsn_cd3 AS icd_dgns_vrsn, b.code_type*/
FROM cms_deid_2015_updated.outpatient_base_claims_k a 
INNER JOIN cchapman6.icd_dx_shldr b
ON a.icd_dgns_cd3 = b.code
WHERE a.icd_dgns_cd3 IS NOT NULL
UNION ALL 
SELECT a.bene_id, a.clm_from_dt AS dgns_dt, 
    a.icd_dgns_cd4 AS icd_dgns_cd /*, a.icd_dgns_vrsn_cd4 AS icd_dgns_vrsn, b.code_type*/
FROM cms_deid_2015_updated.outpatient_base_claims_k a 
INNER JOIN cchapman6.icd_dx_shldr b
ON a.icd_dgns_cd4 = b.code
WHERE a.icd_dgns_cd4 IS NOT NULL;

/*************************************************************************************************************************
CREATE  indicator for source
commented out regular operation due to  2014/2015 outpatient claims missing diagnosis version
check icd version
clean up TABLE
*************************************************************************************************************************/
ALTER TABLE cchapman6.coh_cms_op_b_shldr
    ADD clm_source varchar2(7) DEFAULT 2;
/*
SELECT DISTINCT code_type, icd_dgns_vrsn FROM cchapman6.coh_cms_op_b_shldr;
ALTER TABLE cchapman6.coh_cms_op_b_shldr
    ADD icd_d_v varchar2(7);
UPDATE cchapman6.coh_cms_op_b_shldr
    SET icd_d_v = CASE
        WHEN icd_dgns_vrsn IN ('0', '9', '09') THEN 9
        WHEN icd_dgns_vrsn IN ('1', '10') THEN 10
        ELSE 0 END;
SELECT DISTINCT code_type, icd_dgns_vrsn, icd_d_v FROM cchapman6.coh_cms_op_b_shldr;
DELETE FROM cchapman6.coh_cms_op_b_shldr 
    WHERE code_type <> icd_d_v;
ALTER TABLE cchapman6.coh_cms_op_b_shldr 
    DROP (icd_dgns_vrsn, icd_d_v);
*/

/*************************************************************************************************************************
get ALL shoulder-related claims FROM inpatient source
shoulder-related based ON diagnosis code IN position 1 through 4
*************************************************************************************************************************/
DROP TABLE cchapman6.coh_cms_ip_shldr;
CREATE TABLE cchapman6.coh_cms_ip_shldr AS 
/* 2011-2013 cms inpatient dx pos 1-4 */
SELECT a.bene_id, a.admsn_dt AS dgns_dt, 
    a.dgns_1_cd AS icd_dgns_cd, a.dgns_vrsn_cd_1 AS icd_dgns_vrsn, b.code_type
FROM cms_deid.medpar_all a 
INNER JOIN cchapman6.icd_dx_shldr b
ON a.dgns_1_cd = b.code
WHERE a.dgns_1_cd IS NOT NULL
UNION ALL
SELECT a.bene_id, a.admsn_dt AS dgns_dt, 
    a.dgns_2_cd AS icd_dgns_cd, a.dgns_vrsn_cd_2 AS icd_dgns_vrsn, b.code_type 
FROM cms_deid.medpar_all a 
INNER JOIN cchapman6.icd_dx_shldr b
ON a.dgns_2_cd = b.code
WHERE a.dgns_2_cd IS NOT NULL
UNION ALL 
SELECT a.bene_id, a.admsn_dt AS dgns_dt, 
    a.dgns_3_cd AS icd_dgns_cd, a.dgns_vrsn_cd_3 AS icd_dgns_vrsn, b.code_type 
FROM cms_deid.medpar_all a 
INNER JOIN cchapman6.icd_dx_shldr b
ON a.dgns_3_cd = b.code
WHERE a.dgns_3_cd IS NOT NULL
UNION ALL 
SELECT a.bene_id, a.admsn_dt AS dgns_dt, 
    a.dgns_4_cd AS icd_dgns_cd, a.dgns_vrsn_cd_4 AS icd_dgns_vrsn, b.code_type 
FROM cms_deid.medpar_all a 
INNER JOIN cchapman6.icd_dx_shldr b
ON a.dgns_4_cd = b.code
WHERE a.dgns_4_cd IS NOT NULL
/* 2014 cms inpatient dx pos 1-4 */
UNION ALL
SELECT a.bene_id, a.admsn_dt AS dgns_dt, 
    a.dgns_1_cd AS icd_dgns_cd, a.dgns_vrsn_cd_1 AS icd_dgns_vrsn, b.code_type 
FROM cms_deid_2014_updated.medpar_all a 
INNER JOIN cchapman6.icd_dx_shldr b
ON a.dgns_1_cd = b.code
WHERE a.dgns_1_cd IS NOT NULL
UNION ALL
SELECT a.bene_id, a.admsn_dt AS dgns_dt, 
    a.dgns_2_cd AS icd_dgns_cd, a.dgns_vrsn_cd_2 AS icd_dgns_vrsn, b.code_type 
FROM cms_deid_2014_updated.medpar_all a 
INNER JOIN cchapman6.icd_dx_shldr b
ON a.dgns_2_cd = b.code
WHERE a.dgns_2_cd IS NOT NULL
UNION ALL 
SELECT a.bene_id, a.admsn_dt AS dgns_dt, 
    a.dgns_3_cd AS icd_dgns_cd, a.dgns_vrsn_cd_3 AS icd_dgns_vrsn, b.code_type 
FROM cms_deid_2014_updated.medpar_all a 
INNER JOIN cchapman6.icd_dx_shldr b
ON a.dgns_3_cd = b.code
WHERE a.dgns_3_cd IS NOT NULL
UNION ALL 
SELECT a.bene_id, a.admsn_dt AS dgns_dt, 
    a.dgns_4_cd AS icd_dgns_cd, a.dgns_vrsn_cd_4 AS icd_dgns_vrsn, b.code_type
FROM cms_deid_2014_updated.medpar_all a 
INNER JOIN cchapman6.icd_dx_shldr b
ON a.dgns_4_cd = b.code
WHERE a.dgns_4_cd IS NOT NULL
/* 2015 cms inpatient dx pos 1-4 */
UNION ALL
SELECT a.bene_id, a.admsn_dt AS dgns_dt, 
    a.dgns_1_cd AS icd_dgns_cd, a.dgns_vrsn_cd_1 AS icd_dgns_vrsn, b.code_type
FROM cms_deid_2015_updated.medpar_all a 
INNER JOIN cchapman6.icd_dx_shldr b
ON a.dgns_1_cd = b.code
WHERE a.dgns_1_cd IS NOT NULL
UNION ALL
SELECT a.bene_id, a.admsn_dt AS dgns_dt, 
    a.dgns_2_cd AS icd_dgns_cd, a.dgns_vrsn_cd_2 AS icd_dgns_vrsn, b.code_type
FROM cms_deid_2015_updated.medpar_all a 
INNER JOIN cchapman6.icd_dx_shldr b
ON a.dgns_2_cd = b.code
WHERE a.dgns_2_cd IS NOT NULL
UNION ALL 
SELECT a.bene_id, a.admsn_dt AS dgns_dt, 
    a.dgns_3_cd AS icd_dgns_cd, a.dgns_vrsn_cd_3 AS icd_dgns_vrsn, b.code_type
FROM cms_deid_2015_updated.medpar_all a 
INNER JOIN cchapman6.icd_dx_shldr b
ON a.dgns_3_cd = b.code
WHERE a.dgns_3_cd IS NOT NULL
UNION ALL 
SELECT a.bene_id, a.admsn_dt AS dgns_dt, 
    a.dgns_4_cd AS icd_dgns_cd, a.dgns_vrsn_cd_4 AS icd_dgns_vrsn, b.code_type
FROM cms_deid_2015_updated.medpar_all a 
INNER JOIN cchapman6.icd_dx_shldr b
ON a.dgns_4_cd = b.code
WHERE a.dgns_4_cd IS NOT NULL;

/*************************************************************************************************************************
check icd version
clean up TABLE
*************************************************************************************************************************/
SELECT DISTINCT code_type, icd_dgns_vrsn FROM cchapman6.coh_cms_ip_shldr;
ALTER TABLE cchapman6.coh_cms_ip_shldr
    ADD (icd_d_v varchar2(7),
         clm_source varchar2(7) DEFAULT 3);
UPDATE cchapman6.coh_cms_ip_shldr
    SET icd_d_v = CASE
        WHEN icd_dgns_vrsn IN ('0', '9', '09') THEN 9
        WHEN icd_dgns_vrsn IN ('1', '10') THEN 10
        ELSE 0 END;
SELECT DISTINCT code_type, icd_dgns_vrsn, icd_d_v FROM cchapman6.coh_cms_ip_shldr;
DELETE FROM cchapman6.coh_cms_ip_shldr 
    WHERE code_type <> icd_d_v;
ALTER TABLE cchapman6.coh_cms_ip_shldr 
    DROP (icd_dgns_vrsn, icd_d_v);
    
/*************************************************************************************************************************
bring together shoulder claims FROM bcarrier, outpatient, inpatient
reduce to bc cohort
remove unnecessary tables
*************************************************************************************************************************/
DROP TABLE cchapman6.bc_cms_shldr_clms;
CREATE TABLE cchapman6.bc_cms_shldr_clms AS
SELECT bene_id, icd_dgns_cd, dgns_dt FROM cchapman6.coh_cms_car_l_shldr
WHERE bene_id IN 
	(
	SELECT DISTINCT patid
	FROM mschroeder5.f_cohort_cdm_11_15
	)
UNION ALL
SELECT bene_id, icd_dgns_cd, dgns_dt FROM cchapman6.coh_cms_op_b_shldr
WHERE bene_id IN 
	(
	SELECT DISTINCT patid
	FROM mschroeder5.f_cohort_cdm_11_15
	)
UNION ALL
SELECT bene_id, icd_dgns_cd, dgns_dt FROM cchapman6.coh_cms_ip_shldr
WHERE bene_id IN 
	(
	SELECT DISTINCT patid
	FROM mschroeder5.f_cohort_cdm_11_15
	);
DROP TABLE cchapman6.coh_cms_car_l_shldr;
DROP TABLE cchapman6.coh_cms_op_b_shldr;
DROP TABLE cchapman6.coh_cms_ip_shldr;

SELECT COUNT(DISTINCT bene_id) FROM cchapman6.bc_cms_shldr_clms 
UNION ALL
SELECT COUNT(DISTINCT patid) FROM mschroeder5.f_cohort_cdm_11_15_2154
UNION ALL
SELECT COUNT(DISTINCT patid) FROM mschroeder5.f_cohort_cdm_11_15;
