SELECT *
FROM sales.SalesOrderDetail
WHERE UnitPrice > ALL (
  SELECT UnitPrice 
  FROM Sales.SalesOrderDetail 
  WHERE OrderQty >12
)

SELECT *
FROM sales.SalesOrderDetail
WHERE UnitPrice > (
SELECT MAX(UnitPrice)
FROM Sales.SalesOrderDetail
WHERE OrderQty >12
)

/*
Vemos que ambas consultas devuelven lo mismo, ya que ver que UnitPrice sea mayor a TODOS los que tienen >12 OrderQty es lo mismo que pedir que sea mayor al mas grande de todos estos.

La primer query es mucho más costosa, el motor no se da cuenta de que hacen lo mismo. Termina generando una tabla auxiliar (table spool) para guardarse los UnitPrice de todos los del subconjunto "OrderQty>12" y ver si es mayor a cada uno de ellos. Se guarda esa tabla auxiliar para que sea mas facil chequear cada una de las rows contra las del subconjunto.

La segunda query, en vez de guardarse eso, simplemente toma el maximo de ese subconjunto y compara cada uno de las rows para ver si tienen un UnitPrice mayor a ese. Es muchísimo mas barato que el otro, son n comparaciones en vez de n*m, donde m es el tamaño del subconjunto.

En particular, ambas usan un clustered index scan para obtener la info del subconjunto, pues no hay un indice de OrderQty. Lo mismo para UnitPrice, no hay un indice que tenga esa info.

*/
