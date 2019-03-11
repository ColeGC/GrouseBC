SELECT COUNT(DISTINCT bene_id) AS nbene FROM cchapman6.bc_cms_shldr_clms 
UNION ALL
SELECT COUNT(DISTINCT patid) AS nbene FROM cchapman6.bc_emr_shldr_clms 
UNION ALL
SELECT COUNT(DISTINCT patid) AS nbene FROM cchapman6.bc_cdtcms_shldr_clms 
UNION ALL
SELECT COUNT(DISTINCT patid) AS nbene FROM mschroeder5.f_cohort_cdm_11_15_2154
UNION ALL
SELECT COUNT(DISTINCT patid) AS nbene FROM mschroeder5.f_cohort_cdm_11_15;

DROP TABLE cchapman6.all_shldr_clms;
CREATE TABLE cchapman6.all_shldr_clms AS
SELECT bene_id AS patid, icd_dgns_cd, dgns_dt FROM cchapman6.bc_cms_shldr_clms 
UNION ALL
SELECT patid, icd_dgns_cd, dgns_dt FROM cchapman6.bc_emr_shldr_clms 
UNION ALL
SELECT patid, icd_dgns_cd, dgns_dt FROM cchapman6.bc_cdtcms_shldr_clms;

DROP TABLE cchapman6.bc_all_shldr_clms;
CREATE TABLE cchapman6.bc_all_shldr_clms AS
SELECT a.patid, a.icd_dgns_cd AS dx_shldr, 
	a.dgns_dt AS dx_dt_shldr, 
    b.site AS bc_site, b.dxdate AS dx_dt_bc, 
    b.stage AS bc_stage, b.classcase AS bc_classcase
FROM cchapman6.all_shldr_clms a 
INNER JOIN mschroeder5.f_cohort_cdm_11_15 b
ON a.patid = b.patid;

DROP TABLE cchapman6.all_shldr_clms;

SELECT COUNT(DISTINCT patid) AS nbene FROM cchapman6.bc_all_shldr_clms
WHERE dx_dt_bc - 365 <= dx_dt_shldr;
SELECT COUNT(DISTINCT patid) AS nbene FROM cchapman6.bc_all_shldr_clms
WHERE dx_dt_shldr <= dx_dt_bc + 365*5;

