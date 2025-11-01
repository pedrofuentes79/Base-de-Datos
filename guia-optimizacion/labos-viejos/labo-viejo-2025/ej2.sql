-- Consulta A
SELECT * FROM Sales.SalesOrderDetail
WHERE ProductID = 897;

-- Consulta B
DECLARE @prodId INT = 897;
SELECT * FROM Sales.SalesOrderDetail 
WHERE ProductID = @prodId;

--La Consulta A y la Consulta B utilizan el mismo valor, pero en muchos casos el optimizador genera un plan distinto para cada una. ¿Por qué?
--RTA
-- La consulta A hace un index seek sobre el índice que tiene (ProductID, (SalesOrderID, SalesOrderDetailID))
-- y luego hace un key lookup sobre la PK para obtener los demás campos.

-- La consulta B no hace esto, si no que actúa como si no conociese de antemano la condición por la cual tiene que filtrar
-- Hace un clustered index scan, trae TODA la tabla y después le aplica un filter.
-- Esto es porque @prodId es una variable, entonces el optimizador no puede estimar si ese ProductID es lo suficientemente selectivo, entonces
-- da un plan que sea válido para muchos casos.

-- Ejemplo: si @prodId apareciese 100,000 veces en la tabla, y seguimos el plan de la consulta A, tendríamos que hacer 100,000 key lookups
-- En ese caso el plan de la consulta B no se ve tan mal...


