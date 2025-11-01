-- Consulta A
SELECT * FROM Sales.SalesOrderDetail d
JOIN Production.Product p ON d.ProductID = p.ProductID;
-- Consulta B
SELECT * FROM Sales.SalesOrderDetail d
JOIN Production.Product p ON d.ProductID = p.ProductID
WHERE p.Name LIKE 'A%';

-- ambas generan el mismo plan de consulta, a pesar de que una tiene un where
-- explicar porque
-- RTA:

-- El optimizador decide hacer un clustered index scan en la segunda consulta (en vez de usar el índice que ya existe por nombre)
-- dado que va a tener que traer todos los campos del índice cluster de todos modos. Entonces, su estimación le da que es más barato
-- recorrer el índice cluster entero que tener que hacer ~14 key lookups de cada uno de los ProductID del índice que tiene solamente
-- (Name, ProductID).


