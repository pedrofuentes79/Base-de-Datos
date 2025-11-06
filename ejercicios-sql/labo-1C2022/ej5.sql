SELECT COUNT(UnitPrice)
FROM sales.SalesOrderDetail

SELECT SUM(UnitPrice)
FROM sales.SalesOrderDetail
/*
La primer consulta hace un index scan (no clustered), ya que UnitPrice no puede ser null. Entonces, sabe que cualquier row va a tener un UnitPrice, por ende COUNT(UnitPrice) es la cantidad de filas de la tabla. Entonces decide hacer eso de la manera más eficiente que puede, y es con un scan del índice de ProductID (que tampoco puede ser null)

La segunda consulta no puede hacer lo mismo, ya que necesita saber el valor en sí mismo del UnitPrice, por ende tiene que accederlo directamente. Como no hay ningún índice que tenga esa info, tiene que ir a buscarlo al índice cluster con un scan.

*/