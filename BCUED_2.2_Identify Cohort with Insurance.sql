DROP TABLE cchapman6.t0_emr;
CREATE TABLE cchapman6.t0_emr AS
SELECT  b.*
FROM cchapman6.bc_emr_shldr_clms a 
INNER JOIN cchapman6.bc_all_shldr_clms b
ON a.patid = b.patid AND a.dgns_dt = b.dx_dt_shldr;

DROP TABLE cchapman6.t0_cms;
CREATE TABLE cchapman6.t0_cms AS
SELECT  b.*
FROM cchapman6.bc_cms_shldr_clms a 
INNER JOIN cchapman6.bc_all_shldr_clms b
ON a.bene_id = b.patid AND a.dgns_dt = b.dx_dt_shldr;

/* To Limit Claims on Source, bc_all_shldr_clms to t0_emr or t1_emr */

DROP TABLE cchapman6.t1;
CREATE TABLE cchapman6.t1 AS 
SELECT DISTINCT a.patid, a.dx_dt_shldr, a.dx_dt_bc
FROM cchapman6.bc_all_shldr_clms a
/* FROM cchapman6.t0_cms a */
/* FROM cchapman6.t0_emr a */
INNER JOIN mschroeder5.f_cohort_cdm_11_15_2154 b
ON a.patid = b.patid;

SELECT COUNT(DISTINCT patid) AS nbene FROM cchapman6.t1
WHERE dx_dt_bc <= dx_dt_shldr AND dx_dt_shldr <= dx_dt_bc + 365;

SELECT COUNT(DISTINCT patid) AS nbene FROM cchapman6.t1
WHERE dx_dt_bc <= dx_dt_shldr AND dx_dt_shldr <= dx_dt_bc + 365*2;

DROP TABLE cchapman6.t1ins;
CREATE TABLE cchapman6.t1ins AS
SELECT a.*, b.enr_start_date, b.enr_end_date
FROM cchapman6.t1 a
INNER JOIN mschroeder5.f_cohort_cms_ins b
ON a.patid = b.patid
WHERE b.COVERAGE = 'AB';

DROP TABLE cchapman6.t1ins2;
CREATE TABLE cchapman6.t1ins2 AS
SELECT * 
FROM cchapman6.t1ins
WHERE enr_start_date <= dx_dt_bc AND dx_dt_bc + 365 <= enr_end_date;

SELECT COUNT(DISTINCT patid) AS nbene FROM cchapman6.t1ins2;

SELECT COUNT(DISTINCT patid) AS nbene FROM cchapman6.t1ins2
WHERE dx_dt_bc <= dx_dt_shldr AND dx_dt_shldr <= dx_dt_bc + 365;

DROP TABLE cchapman6.t1ins3;
CREATE TABLE cchapman6.t1ins3 AS
SELECT * 
FROM cchapman6.t1ins
WHERE enr_start_date <= dx_dt_bc AND dx_dt_bc + 2*365 <= enr_end_date;

SELECT COUNT(DISTINCT patid) AS nbene FROM cchapman6.t1ins3
WHERE dx_dt_bc <= dx_dt_shldr AND dx_dt_shldr <= dx_dt_bc + 2*365;

DROP TABLE cchapman6.t0_emr;
DROP TABLE cchapman6.t0_cms;
DROP TABLE cchapman6.t1;
DROP TABLE cchapman6.t1ins;
DROP TABLE cchapman6.t1ins2;
DROP TABLE cchapman6.t1ins3;