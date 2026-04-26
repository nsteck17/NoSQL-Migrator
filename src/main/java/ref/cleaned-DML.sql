-- Cleaned standard SQL statements extracted from raw-DML.sql

-- 1. SELECT with JOIN (originally with Java string concatenation and Oracle-specific elements)
SELECT
    MNS.NTFN_ID,
    MNS.SEQ_ID,
    MNS.NTFN_HIST_STAT_IND,
    MNS.NTFN_STAT_CODE,
    MNS.CMNT_TEXT,
    MNS.CRTN_TMST,
    MNS.CRTN_USER_ID,
    MNS.LAST_UPTD_TMST,
    MNS.LAST_UPTD_USER_ID,
    MNS.CRTN_USER_TRCK_ID,
    MNS.LAST_UPTD_USER_TRCK_ID,
    MNSC.NTFN_STAT_CMNT_ID,
    MNSC.NTFN_HIST_STAT_IND AS MNSC_NTFN_HIST_STAT_IND,
    MNSC.CMNT_TEXT AS MNSC_CMNT_TEXT,
    MNSC.CRTN_TMST AS MNSC_CRTN_TMST,
    MNSC.CRTN_USER_ID AS MNSC_CRTN_USER_ID,
    MNSC.LAST_UPTD_TMST AS MNSC_LAST_UPTD_TMST,
    MNSC.LAST_UPTD_USER_ID AS MNSC_LAST_UPTD_USER_ID,
    MNSC.CRTN_USER_TRCK_ID AS MNSC_CRTN_USER_TRCK_ID,
    MNSC.LAST_UPTD_USER_TRCK_ID AS MNSC_LAST_UPTD_USER_TRCK_ID
FROM MCS_NTFN_STAT MNS
LEFT JOIN MCS_NTFN_STAT_CMNT MNSC
    ON MNS.NTFN_ID = MNSC.NTFN_ID
    AND MNS.SEQ_ID = MNSC.NTFN_STAT_SEQ_ID
WHERE MNS.NTFN_ID IN (?);

-- 2. INSERT statement (standardized, removed Java formatting)
INSERT INTO MCS_NTFN_STAT_CMNT (
    NTFN_STAT_CMNT_ID,
    NTFN_ID,
    NTFN_STAT_SEQ_ID,
    NTFN_HIST_STAT_IND,
    CMNT_TEXT,
    CRTN_TMST
) VALUES (
    ?, ?, ?, ?, ?, CURRENT_TIMESTAMP
);

-- 3. SELECT with GROUP BY and date filtering (SYSDATE replaced)
SELECT
    NS.NTFN_STAT_CODE,
    COUNT(*) AS COUNT
FROM MCS_NTFN N
JOIN MCS_NTFN_STAT NS ON NS.NTFN_ID = N.NTFN_ID
    AND NS.NTFN_HIST_STAT_IND = 'C'
WHERE (
    (NS.NTFN_STAT_CODE = 'C' AND NS.CRTN_TMST >= CURRENT_TIMESTAMP - INTERVAL '1' DAY)
    OR (NS.NTFN_STAT_CODE <> 'C')
)
AND N.REPR_FAC_AREA_ID = ?
GROUP BY NS.NTFN_STAT_CODE;

-- 4. SELECT with IN clause (parameterized)
SELECT
    NTFN.PHYS_RESR_ID AS physicalResourceId,
    NTFN.NTFN_SEVR_CODE AS severityCode
FROM MCS_NTFN NTFN
INNER JOIN MCS_NTFN_STAT HIST ON HIST.NTFN_ID = NTFN.NTFN_ID
WHERE HIST.NTFN_HIST_STAT_IND = 'C'
    AND HIST.NTFN_STAT_CODE NOT IN ('C','X')
    AND NTFN.PHYS_RESR_ID IN (?);

-- 5. Cleaned and formatted version of the query below
SELECT
    HISTORYTABLE.NTFN_ID,
    HISTORYTABLE.SEQ_ID,
    HISTORYTABLE.NTFN_STAT_CODE AS STATUSCODE,
    (
        SELECT VALU_SHRT_DESC
        FROM MCS.ACA_CD_TBL_HDR H
        LEFT JOIN MCS.ACA_CD_TBL_VALU V ON H.CODE_TBL_HDR_ID = V.CODE_TBL_HDR_ID
        WHERE H.VALU_LABL_NM = 'ILP NOTIFY STATUS CODES'
          AND VALU_TEXT = HISTORYTABLE.NTFN_STAT_CODE
          AND ROWNUM = 1 -- Oracle-specific: returns only the first match
    ) AS statusDescription,
    (HISTORYTABLE.CRTN_TMST + (locStn.CST_OSET_VALU / 24)) AS statusAdjustedTime,
    HISTORYTABLE.CRTN_TMST AS statusCreationDate,
    (cmts.CRTN_TMST + (locStn.CST_OSET_VALU / 24)) AS commentAdjustedTime,
    cmts.CRTN_TMST AS commentCreationDate,
    cmts.CMNT_TEXT AS COMMENTS,
    cmts.NTFN_STAT_CMNT_ID AS commentId,
    HISTORYTABLE.CRTN_USER_ID AS statusUserId,
    HISTORYTABLE.CRTN_USER_TRCK_ID AS statusEmplId,
    CASE
        WHEN HISTORYTABLE.CRTN_USER_TRCK_ID = 'AUTOESCL' THEN 'AUTO'
        ELSE (
            SELECT person.FIR_NAME
            FROM mcs_pno_pers_v1 person
            WHERE person.full_pers_id = HISTORYTABLE.CRTN_USER_TRCK_ID
        )
    END AS statusCreateFirstName,
    CASE
        WHEN HISTORYTABLE.CRTN_USER_TRCK_ID = 'AUTOESCL' THEN 'ESCALATED'
        ELSE (
            SELECT person.LAST_NAME
            FROM mcs_pno_pers_v1 person
            WHERE person.full_pers_id = HISTORYTABLE.CRTN_USER_TRCK_ID
        )
    END AS statusCreateLastName,
    cmts.CRTN_USER_ID AS commentCreatedUserId,
    cmts.CRTN_USER_TRCK_ID AS commentCreatedEmplId,
    CASE
        WHEN cmts.CRTN_USER_TRCK_ID = 'AUTOESCL' THEN 'AUTO'
        ELSE (
            SELECT person.FIR_NAME
            FROM mcs_pno_pers_v1 person
            WHERE person.full_pers_id = cmts.CRTN_USER_TRCK_ID
        )
    END AS commentCreateFirstName,
    CASE
        WHEN cmts.CRTN_USER_TRCK_ID = 'AUTOESCL' THEN 'ESCALATED'
        ELSE (
            SELECT person.LAST_NAME
            FROM mcs_pno_pers_v1 person
            WHERE person.full_pers_id = cmts.CRTN_USER_TRCK_ID
        )
    END AS commentCreateLastName
FROM MCS_NTFN_STAT HISTORYTABLE
    LEFT JOIN MCS_NTFN NFT ON HISTORYTABLE.NTFN_ID = NFT.NTFN_ID
    LEFT JOIN sfm_repr_fac_area RepairArea ON RepairArea.Repr_Fac_Area_Id = NFT.REPR_FAC_AREA_ID
    LEFT JOIN mcs_work_repr_fac RepairFac ON RepairFac.WORK_UNIT_ID = RepairArea.WORK_UNIT_ID
    LEFT JOIN mcs_loc_sys_stn_v1 locStn ON locStn.STN_CRC7_CODE = RepairFac.REPR_FAC_CRC7
    LEFT JOIN MCS_NTFN_STAT_CMNT cmts ON HISTORYTABLE.NTFN_ID = cmts.NTFN_ID
        AND HISTORYTABLE.SEQ_ID = cmts.NTFN_STAT_SEQ_ID
WHERE HISTORYTABLE.NTFN_ID = ?
ORDER BY HISTORYTABLE.SEQ_ID DESC;


-- 6. query with comparison > or < clause
SELECT
    NTFN_ID
FROM MCS_NTFN_STAT
WHERE NTFN_ID = ?
AND CRTN_TMST > (CURRENT_TIMESTAMP - INTERVAL '1' DAY)
ORDER BY SEQ_ID DESC;

-- 7. query with comparison = ok
SELECT
    NTFN_ID
FROM MCS_NTFN_STAT
WHERE NTFN_ID = ?
AND CRTN_TMST = (CURRENT_TIMESTAMP - INTERVAL '1' DAY)
ORDER BY SEQ_ID DESC;