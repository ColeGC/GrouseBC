/* Get numbers for benes found in emr */

DROP TABLE cchapman6.bene_emr;
CREATE TABLE cchapman6.bene_emr AS
SELECT DISTINCT patid FROM cchapman6.bc_emr_shldr_clms;

DROP TABLE cchapman6.bene_emr_coh;
CREATE TABLE cchapman6.bene_emr_coh AS
SELECT patid FROM cchapman6.bene_emr
WHERE patid IN 
	(
	SELECT DISTINCT patid
	FROM mschroeder5.f_cohort_cdm_11_15
	);

DROP TABLE cchapman6.bene_emr_2154;
CREATE TABLE cchapman6.bene_emr_2154 AS
SELECT patid FROM cchapman6.bene_emr
WHERE patid IN 
	(
	SELECT DISTINCT patid
	FROM mschroeder5.f_cohort_cdm_11_15_2154
	);

SELECT COUNT(DISTINCT patid) FROM cchapman6.bene_emr_coh;
SELECT COUNT(DISTINCT patid) FROM cchapman6.bene_emr_2154;

DROP TABLE cchapman6.bene_emr;
DROP TABLE cchapman6.bene_emr_coh;
DROP TABLE cchapman6.bene_emr_2154;

/* Get numbers for benes found in cms */

DROP TABLE cchapman6.bene_cms;
CREATE TABLE cchapman6.bene_cms AS
SELECT DISTINCT bene_id AS patid FROM cchapman6.bc_cms_shldr_clms;

DROP TABLE cchapman6.bene_cms_coh;
CREATE TABLE cchapman6.bene_cms_coh AS
SELECT patid FROM cchapman6.bene_cms
WHERE patid IN 
	(
	SELECT DISTINCT patid
	FROM mschroeder5.f_cohort_cdm_11_15
	);

DROP TABLE cchapman6.bene_cms_2154;
CREATE TABLE cchapman6.bene_cms_2154 AS
SELECT patid FROM cchapman6.bene_cms
WHERE patid IN 
	(
	SELECT DISTINCT patid
	FROM mschroeder5.f_cohort_cdm_11_15_2154
	);

SELECT COUNT(DISTINCT patid) FROM cchapman6.bene_cms_coh;
SELECT COUNT(DISTINCT patid) FROM cchapman6.bene_cms_2154;

DROP TABLE cchapman6.bene_cms;
DROP TABLE cchapman6.bene_cms_coh;
DROP TABLE cchapman6.bene_cms_2154;

/* Get numbers for benes found in cdt */

DROP TABLE cchapman6.bene_cdt;
CREATE TABLE cchapman6.bene_cdt AS
SELECT DISTINCT patid FROM cchapman6.bc_cdtcms_shldr_clms;

DROP TABLE cchapman6.bene_cdt_coh;
CREATE TABLE cchapman6.bene_cdt_coh AS
SELECT patid FROM cchapman6.bene_cdt
WHERE patid IN 
	(
	SELECT DISTINCT patid
	FROM mschroeder5.f_cohort_cdm_11_15
	);

DROP TABLE cchapman6.bene_cdt_2154;
CREATE TABLE cchapman6.bene_cdt_2154 AS
SELECT patid FROM cchapman6.bene_cdt
WHERE patid IN 
	(
	SELECT DISTINCT patid
	FROM mschroeder5.f_cohort_cdm_11_15_2154
	);

SELECT COUNT(DISTINCT patid) FROM cchapman6.bene_cdt_coh;
SELECT COUNT(DISTINCT patid) FROM cchapman6.bene_cdt_2154;

DROP TABLE cchapman6.bene_cdt;
DROP TABLE cchapman6.bene_cdt_coh;
DROP TABLE cchapman6.bene_cdt_2154;

/* Get numbers for all benes found in all sources */

DROP TABLE cchapman6.all_shldr_clms;
CREATE TABLE cchapman6.all_shldr_clms AS 
SELECT bene_id AS patid FROM cchapman6.bc_cms_shldr_clms 
UNION ALL
SELECT patid FROM cchapman6.bc_emr_shldr_clms 
UNION ALL
SELECT patid FROM cchapman6.bc_cdtcms_shldr_clms;

DROP TABLE cchapman6.benes_all;
CREATE TABLE cchapman6.benes_all AS
SELECT DISTINCT patid FROM cchapman6.all_shldr_clms;

DROP TABLE cchapman6.bene_all_coh;
CREATE TABLE cchapman6.bene_all_coh AS
SELECT patid FROM cchapman6.benes_all
WHERE patid IN 
	(
	SELECT DISTINCT patid
	FROM mschroeder5.f_cohort_cdm_11_15
	);

DROP TABLE cchapman6.bene_all_2154;
CREATE TABLE cchapman6.bene_all_2154 AS
SELECT patid FROM cchapman6.benes_all
WHERE patid IN 
	(
	SELECT DISTINCT patid
	FROM mschroeder5.f_cohort_cdm_11_15_2154
	);

SELECT COUNT(DISTINCT patid) FROM cchapman6.bene_all_coh;
SELECT COUNT(DISTINCT patid) FROM cchapman6.bene_coh_2154;

DROP TABLE cchapman6.all_shldr_clms;
DROP TABLE cchapman6.benes_all;
DROP TABLE cchapman6.bene_all_coh;
DROP TABLE cchapman6.bene_all_2154;