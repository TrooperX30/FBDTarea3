CREATE OR REPLACE FUNCTION actividad_cliente(codigo char(1), clientedoc integer, anio integer) RETURNS integer AS $$
BEGIN
	-- Comprobar si existe cliente
	IF NOT EXISTS (SELECT 1 FROM clientes c WHERE c.cliente_documento = clientedoc) THEN
		RAISE NOTICE 'No existe el cliente';
		RETURN -1;
	END IF;

	IF codigo = 'R' OR codigo = 'r' THEN
		RETURN (SELECT COUNT(*) FROM reservas_anteriores r WHERE r.cliente_documento = clientedoc AND EXTRACT(YEAR FROM r.fecha_reserva) = anio);
	ELSIF codigo = 'E' OR codigo = 'e' THEN
		RETURN (SELECT COUNT(*) FROM estadias_anteriores e WHERE e.cliente_documento = clientedoc AND EXTRACT(YEAR FROM e.check_in) = anio);
	ELSE
		RAISE NOTICE 'Código de operación incorrecto';
		RETURN -1;
	END IF;
END
$$ LANGUAGE 'plpgsql'