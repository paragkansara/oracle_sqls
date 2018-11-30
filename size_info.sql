REM
REM Display size of Data, Undo and Temp tablespaces 
REM
REM 03/28/2017 - Parag Kansara
REM

COL data_gb FORMAT 99999.90;
COL undo_gb FORMAT 99999.90;
COL temp_gb FORMAT 99999.90;
COL redo_gb FORMAT 99999.90;
COL total_gb FORMAT 99999.90;

/* Permanent tablespaces size */
SELECT ROUND(SUM (bytes)/(1024*1024*1024),2) AS DATA_FILE_GB
  FROM dba_data_files
 WHERE tablespace_name IN (SELECT tablespace_name
                             FROM dba_tablespaces
                            WHERE contents = 'PERMANENT')
/

SELECT ROUND(SUM(bytes)/(1024*1024*1024),2)  DATA_SIZE_GB 
  FROM dba_segments
 WHERE tablespace_name IN (SELECT tablespace_name
                             FROM dba_tablespaces
                            WHERE contents = 'PERMANENT')
/

/* Undo tablespaces size */
SELECT ROUND(SUM(bytes)/(1024*1024*1024),2) AS UNDO_GB
  FROM dba_data_files
 WHERE tablespace_name IN (SELECT tablespace_name
                             FROM dba_tablespaces
                            WHERE contents != 'PERMANENT')
/

/* Temp tablespaces size */
SELECT ROUND(SUM(bytes)/(1024*1024*1024),2) AS TEMP_GB FROM dba_temp_files
/

/* Redo Logs size */
SELECT ROUND(SUM(bytes)/(1024*1024*1024),2) AS REDO_GB FROM v$log
/

/* Total database size */
SELECT data_gb+undo_gb+temp_gb+redo_gb AS total_gb 
FROM 
(SELECT SUM (bytes) / (1024 * 1024 * 1024) AS DATA_GB
  FROM dba_data_files
 WHERE tablespace_name IN (SELECT tablespace_name
                             FROM dba_tablespaces
                            WHERE contents = 'PERMANENT')) a,
(SELECT SUM (bytes) / (1024 * 1024 * 1024) AS UNDO_GB
  FROM dba_data_files
 WHERE tablespace_name IN (SELECT tablespace_name
                             FROM dba_tablespaces
                            WHERE contents != 'PERMANENT')) b,
(SELECT SUM (bytes) / (1024 * 1024 * 1024) AS TEMP_GB FROM dba_temp_files) c,
(SELECT SUM (bytes) / (1024 * 1024 * 1024) AS REDO_GB FROM v$log) d
/

PROMPT * The difference between DATA_FILE_GB and DATA_SIZE_GB is because of Segment Fragmentation due to data delete and updates. 

SELECT ROUND(100 - ((DATA_SIZE_GB*100)/DATA_FILE_GB),2) AS PCT_FRAGMENT, ROUND(DATA_FILE_GB - DATA_SIZE_GB,2) AS SIZE_GB_FRAGMENT
 FROM 
(
SELECT SUM (bytes) / (1024 * 1024 * 1024) AS DATA_FILE_GB
  FROM dba_data_files
 WHERE tablespace_name IN (SELECT tablespace_name
                             FROM dba_tablespaces
                            WHERE contents = 'PERMANENT')
),
(
SELECT SUM(bytes)/1024/1024/1024 AS DATA_SIZE_GB 
  FROM dba_segments
 WHERE tablespace_name IN (SELECT tablespace_name
                             FROM dba_tablespaces
                            WHERE contents = 'PERMANENT')
)
/
