SELECT *
FROM Purchasing.ShipMethod
ORDER BY Name

SELECT *
FROM Purchasing.ShipMethod
WHERE Name IS NOT null

/*
Vemos que la primer consulta hace un index scan y luego un key lookup. Era más rápido recorrerla por orden + key lookup que hacer el scan en el índice cluster y luego ordenarlos.
Si los datos fuesen más, se notaría más la diferencia, ya que ordenarlos sería mucho más pesado.

La segunda consulta hace un scan en el índice cluster. Esto se debe a que: 1) no importa el orden, 2) tengo que traer todos los campos, 3) la columna Name no permite nulls. Entonces se convierte en un select * from Purchasing.ShipMethod

*/