USE ROLE SYSADMIN;
USE WAREHOUSE CLASE_M2L7_WH;
USE DATABASE CLASE_M2L7_DB;
USE SCHEMA RAW;

-- Comprueba que el CSV está en el stage. Debe aparecer ventas_tienda.csv.
LIST @ARCHIVOS_TIENDA;

-- Carga el archivo en la tabla. Aborta si encuentra un error de carga.
-- Al terminar comprueba ROWS_LOADED=10 y el estado de carga.
COPY INTO VENTAS_CARGA
FROM @ARCHIVOS_TIENDA
FILES = ('ventas_tienda.csv')
FILE_FORMAT = (FORMAT_NAME = 'CSV_TIENDA')
ON_ERROR = 'ABORT_STATEMENT';

-- Verifica filas, unidades e importe antes de transformar.
-- Esperado: 10, 21 y 3650.
SELECT COUNT(*) AS VENTAS, SUM(CANTIDAD) AS UNIDADES,
       SUM(CANTIDAD * PRECIO_UNITARIO) AS INGRESOS
FROM VENTAS_CARGA;

