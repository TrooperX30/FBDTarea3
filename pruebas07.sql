--INSERT INTO estadias_anteriores
--VALUES (6325565, 100, 56888371, '1977-11-08', '1977-11-08');
--UPDATE estadias_anteriores 
--SET check_out = '1977-11-10'--nro_habitacion = 101
--WHERE hotel_codigo = 6325565 AND nro_habitacion = 100 AND cliente_documento = 56888371 AND check_in = '1977-11-08';
--DELETE FROM estadias_anteriores e
--WHERE e.hotel_codigo = 6325565 AND e.nro_habitacion = 100 AND e.cliente_documento = 56888371 AND e.check_in = '1977-11-08';

--INSERT INTO finguitos_usuarios
--VALUES (56888371, 6325565, '1977-10-08', '1977-10-08', '1977-11-08', '1979-10-08', 555, current_timestamp, 1);
--DELETE FROM finguitos_usuarios f
--WHERE f.hotel_codigo = 6325565 AND f.cliente_documento = 56888371 AND f.check_in = '1977-11-08';

SELECT *
FROM finguitos_usuarios