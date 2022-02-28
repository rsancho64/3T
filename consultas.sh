mysql -u root -pbea -e "\
use 3T;
drop table if exists Venta;
-- 
-- SELECT id, firstName , lastName FROM Clientes;
-- SELECT id, modelo, anio, color FROM Vehiculos;
-- SELECT id, clienteId FROM Ventas;
-- 
SELECT * FROM Ventas JOIN Clientes 
ON Ventas.clienteId = Clientes.id;
-- 
SELECT Ventas.id as 'v.id', Ventas.clienteID as 'fk', Clientes.id as 'Cl.id'
FROM Ventas JOIN Clientes 
ON Ventas.clienteId = Clientes.id;
--
SELECT * FROM Ventas JOIN Vehiculos
ON Ventas.vehiculoId = Vehiculos.id;


"

mysql -u root -pbea -e "\
use 3T;
--    SELECT * FROM Clientes JOIN Ventas 
--    ON Clientes.id = Ventas.clienteId;
"
# SELECT t1.col, t3.col
# FROM table1
# JOIN table2 ON table1.primarykey = table2.foreignkey
# JOIN table3 ON table2.primarykey = table3.foreignkey