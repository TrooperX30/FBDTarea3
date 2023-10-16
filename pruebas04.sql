--INSERT INTO hoteles
--VALUES (999, 'hotelardo', 5, 45, 45, 'AT', 2108, 2894)

--INSERT INTO habitaciones
--VALUES (999, 100, 4, 50)

--INSERT INTO costos_habitacion
--VALUES (999, 100, '2000-02-01', 100, 300);

--INSERT INTO CLIENTES
--VALUES (111, 'pedro', 'sanchez', 'Masculino', '1900-01-01', '01114', 'ES', 2406, 394);

--INSERT INTO estadias_anteriores
--VALUES (999, 100, 111, '2001-02-01', '2001-02-02');

UPDATE costos_habitacion
SET fecha_desde = '2000-01-01'
WHERE hotel_codigo = 999 AND nro_habitacion = 100 AND fecha_desde = '2005-01-01';

--DELETE FROM costos_habitacion
--WHERE hotel_codigo = 999 AND nro_habitacion = 100 AND fecha_desde = '2000-01-01';

SELECT *
FROM estadias_anteriores NATURAL JOIN costos_habitacion
WHERE hotel_codigo = 999 AND nro_habitacion = 100 AND cliente_documento = 111

--SELECT *
--FROM costos_habitacion NATURAL JOIN estadias_anteriores
--WHERE hotel_codigo = 999 AND nro_habitacion = 100 AND cliente_documento = 111