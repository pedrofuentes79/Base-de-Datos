# Ej 1
ambas consultas preguntan por el producto de `ProductNumber='EC-R098`. La diferencia es que una pide `P.Name` y la otra `P.ProductId`.

Vemos que la segunda query hace solamente un `IndexSeek` en el índice de `AK_Product_ProductNumber`. Esto es porque la query pide un ProductNumber específico, entonces en ese índice es solamente un seek. Luego, vemos que para obtener el ProductId no tiene que hacer nada más, porque el índice mismo guarda el ProductId (dado que esta es la PK)

En la primera query es necesario, una vez hecho el seek en el índice de ProductNumber, hacer un KeyLookup en el indice clustered, ya que la información de `Name` no está en el índice de ProductNumber.

- No se usa el índice de `AK_Product_Name` porque la consulta pide un producto con un ProductNumber específico. Si fuese un `Name` específico, ahí sí nos evitaríamos el lookup usando el índice con `Name`.

# Ej 2
Vemos que la primera query pide por `SalesOrderId`, que es la primer clave de la clave compuesta (`SalesOrderId`, `SalesOrderDetailID`). Por ende, es solamente un seek en el indice cluster.

En la segunda query, pide por `SalesOrderDetailID`, que es la segunda clave. Por esto no puede hacer un seek en la PK, necesita tener la primera (`SalesOrderID`) para buscar en el índice clustered.
Entonces, inevitablemente va a tener que hacer un scan. Pero, el optimizador es pillo. Como ve que las columnas que tiene que devolver son las de la PK, se da cuenta que con hacer un scan sobre CUALQUIER índice alcanza, ya que todos los índices guardan la PK. Entonces, agarra el índice mas liviano que encuentre (en este caso es `IX_SalesOrderDetail_ProductID`) y hace un scan para encontrar los `SalesOrderID` que matcheen con es `SalesOrderDetailID` pedido. 
No importa que en ese índice se guarden otras cosas (`ProductID`), solamente importa recorrer todas las PK.

# Ej 3
Acá vemos que la primer consulta pide una fila pidiendo dos condiciones de igualdad, sobre `SalesOrderID` y `SalesOrderDetailID`. Como estas dos forman la PK, el optimizador hace simplemente un Clustered Index Seek.

La diferencia es que en la segunda consulta se pide que alguna de esas dos condiciones de igualdad cumpla. Entonces no se puede hacer un Clustered Index Seek (o solo se podría hacer para las filas que tengan `SalesOrderID = 43683` y despues hacer un UNION con las que solo piden `SalesOrderDetail = 240`, y sacar repetidos luego \*1)
Lo que decide hacer el optimizador es hacer directamente un Index Scan por el índice más liviano que haya (ya que las condiciones pedidas son sobre la PK, que está en todos los índices). En ese scan va a ir viendo todos, encontrando los que cumplan una condición o la otra.

\*1 . Si pensamos bien todos los pasos, pedir todas las filas que tengan `SalesOrderDetail = 240` va a implicar un scan de todas maneras. Entonces, ya que vamos a hacer un scan pidiendo una condición, pedimos todo y listo. 

# Ej 4
#### Primer consulta
La primer consulta hace una junta para obtener el nombre del Vendor que vende cada productId.

Para acceder a PPV, usa un index scan sobre un índice que ordena por `BusinessEntityID` ascendiente. En este índice solo estaría la info de `ProductID` (dado que la PK son estos dos campos). De este índice obtuvo (`BusinessEntityID`, `ProductID`) ***ordenados por*** `BusinessEntityID`. 
Luego, para obtener los nombres los busca en el índice cluster de `Product.Vendor` (no hay ningún índice con `Name`). Los devuelve ***ordenados***.

Luego, dado que la información está ordenado, lo más conveniente es hacer un Merge Join. 
Podría haber sido más conveniente traer la info desordenada de PPV? Vemos que no, si quisiéramos haber traído información del índice cluster de PPV, nos hubiese costado más, porque recorrer el índice cluster cuesta más que otros  índices. 
Por último, es absolutamente necesario hacer un scan porque estamos haciendo las juntas sobre toda la tabla, no hay ningún "filtro"

#### Segunda consulta
Esta consulta es igual a la anterior, solamente que tenemos un filtro por `StandardPrice > $10`. Este campo se encuentra en PPV. Entonces, en vez de usar el índice que solo tenía info sobre (`BusinessEntityID`, `ProductID`) vamos a tener que usar el clustered. El problema que nos presenta esto es que ahora la información no está ordenada por `BusinessEntityID`, si no que el orden lo dicta (`ProductID`, `BusinessEntityID`). 
Justamente por esto es que el operador de junta ahora es un Hash join y no un merge con un ordenamiento previo. En este caso hubiese sido más costoso ordenarlos que hacer un Hash join. Tiene que ver con la cantidad de records que se traen de PPV. Si aumentamos el filtro de StandardPrice a `$14` el optimizador elige ordenar y hacer un merge en vez de hacer hash, ya que ahí son menos que antes.

#### Tercera consulta
Esta consulta es igual a la anterior, pero se añade un filtro extra por nombre en la tabla PV.

Primero se hace un clustered index scan sobre PV para obtener los que cumplen con ese nombre. El optimizador estima que solamente 7 de los Vendors tienen un nombre así, por eso empieza con este filtro antes que otra cosa.

Luego, el optimizador hace un seek para esos 7 vendors, para cada `BusinessEntityID` trae sus correspondientes `ProductID`. Esto lo hace usando el índice que tiene por `BusinessEntityID`,entonces hace un seek en vez de un scan. 

Luego, hace un inner join para todo eso. Y finalmente, hace un key lookup de `StandardPrice` para *estos* productos y luego los filtra con un inner join.

El optimizador decide hacer estas "vueltas" en vez de hacer dos clustered index scans justamente porque recorrer todo el índice filtrando por una condición (que tampoco es muy selectiva, la de $10) es muy caro y devuelve bastantes elementos. 
Si aumentamos el precio a $40, el optimizador ahí sí decide hacer dos clustered index scans seguidos de un hash match. Esto es porque considera que la condición va a eliminar suficientes records como para que valga la pena recorrer todo el índice.

# Ej 5
#### Primera consulta
Se pide traer el nombre del producto y su subcategoría. Como están en tablas distintas, se hace una junta.
Lo que va a hacer el optimizador es hacer un clustered index scan sobre la tabla `Product` para traer los nombres y su `ProductSubcategoryID`. No hay otra manera de hacerlo ya que no hay índices que tengan esta información. 
Para la tabla PSC, el optimizador va a usar un índice que tiene la tabla por `Name`, para evitar recorrer el índice clustered.

En este caso ***no tienen el mismo orden***. Lo de la PSC viene ordenado por `Name` y lo de `Product` viene ordenado por `ProductId`. Luego, el join va a ser Hash

#### Segunda consulta
Esta consulta es idéntica, pero nos piden que venga ordenado por `ProductSubcategoryID`. 

Dado que hay un JOIN ya sucediendo, podemos intentar que sea un MERGE JOIN en vez de HASH. Lo que hace el optimizador es hacer un scan del índice cluster de PSC. Esto es porque este ***ya está ordenado por*** `ProductSubcategoryID`. El índice que había usado antes estaba ordenado por `Name`.

Luego, hace un scan sobre el índice cluster para traer los Product con su product name y su `ProductSubcategoryID`. Luego, los ordena por este último campo, y los envía al merge join, para que coincidan con el orden de PSC.

# Ej 6
Las dos consultas piden el count de un campo distinto de una misma tabla. La diferencia va a radicar en que un campo permite nulls mientras que el otro no!

Vemos que la primera consulta trae sobre `NameStyle`. Este campo no acepta nulls. Luego, su count va a ser más fácil, ya que con recorrer cualquier índice liviano nos alcanza; va a haber tantos como haya filas. En este caso usa el índice más liviano que tiene, el de rowguid.

La segunda fila trae sobre Title. Este campo sí acepta nulls. Entonces es necesario hacer un clustered index scan para contar cuantos no nulls hay.

Ambas, luego de su scan, hacen un stream aggregate para contar los resultados.

# Ej 7
#### Primera consulta
Trae el CV de los candidatos, y hace un JOIN con Employee con `BusinessEntityID`, pero solamente lo usa para ordenar. De todos modos, el optimizador hace el JOIN con la otra tabla, porque en la definición de `JobCandidate` dice que `BusinessEntityID` podría ser null. En caso de que lo fuera, no queremos devolver esas filas!
Por esto el optimizador hace el clustered index scan en JobCandidate, hace un sort para asegurarse que se ordena como se pide en la consulta, y luego hace un clustered index seek en `Employee` para asegurarse de que todos tengan un `BusinessEntityID` que efectivamente esté en la tabla `Employee` (también podrían tener un `BusinessEntityID` que NO esté en la tabla, pero esto no es posible ya que `BusinessEntityID` está definido como una foreign key).

Al final, hace un nested loop join (que preserva el orden que hicimos, primero por `BusinessEntityID` y luego por `JobCandidateID`) El optimizador hace el sort usando el campo de `JobCandidate` porque sabe que las únicas filas que van a sobrevivir el último nested loop join van a ser las que tienen un id existente en la otra tabla, entonces ordena antes.

#### Segunda consulta
Esta consulta es igual, pero no pide traer el CV del candidato, si no que solamente quiere el `JobCandidateID` (la PK).

Entonces, va a usar el índice `IX_JobCandidate_BusinessEntityID`. Este índice tiene exactamente la información que necesitamos, entonces nos resulta más barato recorrer este que el clustered. 

Además, como este índice está ordenado por (`BusinessEntityID`, `JobCandidateID`), no tenemos que ordenar nada! El optimizador simplemente recorre este índice, hace el seek para confirmar que estos `BusinessEntityIDs` estén efectivamente en `Employee`, y listo (acá hace un nested loop join porque son pocas filas y quiere mantener el orden ya existente de `JobCandidate`)

