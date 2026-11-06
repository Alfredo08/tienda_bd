-- Al terminar, suspende únicamente el warehouse creado para esta clase.
-- Se conservan tablas, archivos y vistas; el almacenamiento puede seguir consumiendo saldo.
USE ROLE SYSADMIN;
ALTER WAREHOUSE CLASE_M2L7_WH SUSPEND;
-- Si ya está suspendido, el mensaje correspondiente no indica pérdida de datos.

-- Verifica que CLASE_M2L8_WH aparece en estado SUSPENDED.
SHOW WAREHOUSES LIKE 'CLASE_M2L7_WH';

-- No vuelvas a ejecutar reportes después de suspenderlo: AUTO_RESUME puede activarlo.
