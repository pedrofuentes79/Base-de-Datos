SELECT CardType
FROM Sales.CreditCard
GROUP BY CardType

SELECT CardNumber
FROM Sales.CreditCard
GROUP BY CardNumber

/*

La primera consulta hace un group by por CardType. Como se necesita ver todos los CardType, necesitamos ir a buscar esa info al índice clustered. Hace un hash match porque los CardType no deberían ser muchos (crédito, débito, prepaga?, etc.). 

La segunda consulta hace lo mismo, pero por CardNumber. Como solo necesitamos ver los CardNumber, directamente hacemos un scan sobre el índice que los tiene; es mas barato recorrer un índice chiquito que el clustered. 
En este group by no hacemos hash match ni nada, porque van a ser tantos que casi seguro que hay un CardNumber por fila
*/
