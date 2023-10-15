--INSERT INTO estadias_anteriores
--VALUES (6325565, 100, 56888371, '1971-11-08', '1971-11-08');
--UPDATE estadias_anteriores 
--SET hotel_codigo = 6462075
--WHERE hotel_codigo = 6325565 AND nro_habitacion = 100 AND cliente_documento = 2131040 AND check_in = '1971-11-15';
DELETE FROM estadias_anteriores
WHERE hotel_codigo = 6325565 AND nro_habitacion = 100 AND cliente_documento = 56888371 AND check_in = '1971-11-08';

SELECT *
FROM audit_estadia