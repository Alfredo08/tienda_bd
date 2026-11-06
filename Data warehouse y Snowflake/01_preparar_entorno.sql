-- Ejecutar en Snowsight > Projects > Workspaces > SQL File.
-- Preparado para tu cuenta personal de prácticas, no para una cuenta productiva.
-- El rol SYSADMIN crea y administra estos recursos; no se requiere ACCOUNTADMIN aquí.
USE ROLE SYSADMIN;

-- Muestra tu contexto y permite comprobar que estás en la cuenta correcta.
SELECT CURRENT_USER(), CURRENT_ROLE(), CURRENT_ACCOUNT();

-- Crea un motor de cómputo pequeño. No es una base de datos.
-- Comienza suspendido; se activa al consultar y se suspende tras inactividad.
-- Si el nombre ya existe, se detiene: no reemplaza un warehouse existente.
CREATE WAREHOUSE CLASE_M2L7_WH
    WAREHOUSE_TYPE = STANDARD
    WAREHOUSE_SIZE = XSMALL
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE;

-- Crea el contenedor de datos y dos espacios para separar carga y análisis.
CREATE DATABASE CLASE_M2L7_DB;
CREATE SCHEMA CLASE_M2L7_DB.RAW;
CREATE SCHEMA CLASE_M2L7_DB.ANALITICA;

-- Selecciona el cómputo y la ubicación que usarán las siguientes sentencias.
USE WAREHOUSE CLASE_M2L7_WH;
USE DATABASE CLASE_M2L7_DB;
USE SCHEMA RAW;

-- Define cómo interpretar el CSV: comas, encabezado y fechas año-mes-día.
CREATE FILE FORMAT CSV_TIENDA
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    DATE_FORMAT = 'YYYY-MM-DD'
    ENCODING = 'UTF8';

-- Crea el lugar de llegada del archivo dentro de Snowflake: stage interno nombrado.
CREATE STAGE ARCHIVOS_TIENDA
    FILE_FORMAT = CSV_TIENDA;

-- Crea una tabla de llegada. Aún no contiene filas.
-- RAW conserva nombres y ciudades tal como llegan; números y fecha se tipan al cargar.
CREATE TABLE VENTAS_CARGA (
    VENTA_ID NUMBER(10,0),
    CLIENTE_ID NUMBER(10,0),
    CLIENTE VARCHAR,
    CIUDAD VARCHAR,
    PRODUCTO_ID NUMBER(10,0),
    PRODUCTO VARCHAR,
    FECHA DATE,
    CANTIDAD NUMBER(10,0),
    PRECIO_UNITARIO NUMBER(10,2)
);

-- Confirma que la tabla existe y está vacía: esperado 0.
SELECT COUNT(*) AS FILAS_ANTES_DE_CARGAR FROM VENTAS_CARGA;

-- PAUSA: ahora sube ventas_tienda.csv al stage con la interfaz.
-- Ingestion > Add Data > Load files into a Stage.
-- Destino: CLASE_M2L7_DB > RAW > ARCHIVOS_TIENDA, sin subcarpeta.
-- No elijas Load data into a Table: COPY INTO se demostrará en el siguiente archivo.
