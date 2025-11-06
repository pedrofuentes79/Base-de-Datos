SELECT *
FROM Person.Person
WHERE LastName Like 'Duffy%'

SELECT *
FROM Person.Person
WHERE LastName Like '%Duffy'

/*
La primer consulta es un index seek, pues hay un índice que ordena por LastName,FirstName,MiddleName
Como estima que va a encontrar dos, hace un index seek y luego un key lookup

La segunda consulta es un index scan sobre este mismo índice. No hace un index scan pues no puede usar el orden existente para ver "cuales terminan con Duffy", ya que esas palabras podrían estar en cualquier lugar del índice (i.e: no es SARGable)
*/
