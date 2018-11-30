REM
REM Parag Kansara
REM 2015-08-31
REM This script outputs Flash Recovery Area (FRA) information
REM

COL name FORMAT a30;

SHOW PARAMETER db_recovery;

PROMPT
PROMPT V$RECOVERY_FILE_DEST
PROMPT ====================

SELECT 
   name, 
   space_limit/(1024*1024*1024) as space_limit_GB, 
   space_used/(1024*1024*1024) as space_used_GB, 
   space_reclaimable/(1024*1024*1024) as space_reclaimable_GB, 
   number_of_files, 
   round((space_used/space_limit)*100,2) "% USED" 
FROM v$recovery_file_dest
/

PROMPT
PROMPT V$RECOVERY_AREA_USAGE
PROMPT =====================

SELECT * 
FROM v$recovery_area_usage
/

PROMPT
PROMPT V$RESTORE_POINT - LISTING GUARANTEED RESTORE POINTS
PROMPT ===================================================

SELECT NAME, SCN, TIME, DATABASE_INCARNATION#,
        GUARANTEE_FLASHBACK_DATABASE,STORAGE_SIZE
FROM V$RESTORE_POINT
/

PROMPT Increasing FRA Size
PROMPT ===================
PROMPT ALTER SYSTEM SET db_recovery_file_dest_size=Size_GB SCOPE=BOTH SID='*'
PROMPT
