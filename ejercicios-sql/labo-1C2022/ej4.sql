SELECT AddressID, City, StateProvinceID, ModifiedDate
FROM Person.Address
WHERE StateProvinceID = 32

SELECT AddressID, City, StateProvinceID, ModifiedDate
FROM Person.Address
WHERE StateProvinceID = 20

/*
La primer consulta hace un index seek sobre IX_Address_StateProvinceID, y estima que va a obtener solo una fila que cumple la condición. Luego hace un key lookup porque la info pedida no está en ese índice, sino que lo tiene que ir a buscar al índice cluster con la primary key de IX_Address_StateProvinceID.

La segunda consulta no hace un index seek, si no que busca directamente en el índice cluster, y estima que hay 308 personas que van a cumplir con la consulta. Esta parte es clave, ya que al estimar ese número se da cuenta que va a tener que hacer 308 key lookups, y prefiere hacer un scan del índice cluster, donde ya tiene la información necesaria.
*/