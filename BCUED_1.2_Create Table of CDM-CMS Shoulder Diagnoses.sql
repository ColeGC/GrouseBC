DROP TABLE cchapman6.cdt_cms_shldrdx;
CREATE TABLE cchapman6.cdt_cms_shldrdx AS 
SELECT a.patid, a.dx AS icd_dgns_cd, a.admit_date AS dgns_dt, 
	a.dx_type AS icd_dgns_vrsn, b.code_type
FROM cms_cdm_11_15_7s.diagnosis a 
INNER JOIN cchapman6.icd_dx_shldr b
ON a.dx = b.code_fmt;

/*************************************************************************************************************************
check icd version
clean up TABLE
*************************************************************************************************************************/
SELECT DISTINCT code_type, icd_dgns_vrsn FROM cchapman6.cdt_cms_shldrdx;
ALTER TABLE cchapman6.cdt_cms_shldrdx
    ADD icd_d_v varchar2(7);
UPDATE cchapman6.cdt_cms_shldrdx
    SET icd_d_v = CASE
        WHEN icd_dgns_vrsn IN ('9', '09', '0') THEN 9
        WHEN icd_dgns_vrsn IN ('1', '10') THEN 10
        ELSE 0 END;
SELECT DISTINCT code_type, icd_dgns_vrsn, icd_d_v FROM cchapman6.cdt_cms_shldrdx;
DELETE FROM cchapman6.cdt_cms_shldrdx 
    WHERE code_type <> icd_d_v;
ALTER TABLE cchapman6.cdt_cms_shldrdx 
    DROP (icd_dgns_vrsn, icd_d_v);

DROP TABLE cchapman6.bc_cdtcms_shldr_clms;
CREATE TABLE cchapman6.bc_cdtcms_shldr_clms AS
SELECT patid, icd_dgns_cd, dgns_dt FROM cchapman6.cdt_cms_shldrdx
WHERE patid IN 
	(
	SELECT DISTINCT patid
	FROM mschroeder5.f_cohort_cdm_11_15
	);

SELECT COUNT(DISTINCT patid) FROM cchapman6.bc_cdtcms_shldr_clms 
UNION ALL
SELECT COUNT(DISTINCT patid) FROM mschroeder5.f_cohort_cdm_11_15;

DROP TABLE cchapman6.cdt_cms_shldrdx;