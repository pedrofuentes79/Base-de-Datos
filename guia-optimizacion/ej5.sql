SELECT P.Name, PSC.Name SubCatrom FROM Production.Product P 
JOIN Production.ProductSubcategory PSC ON p.ProductSubcategoryID = psc.ProductSubcategoryID;

SELECT P.Name, PSC.Name SubCatrom FROM Production.Product P 
JOIN Production.ProductSubcategory PSC ON p.ProductSubcategoryID = psc.ProductSubcategoryID 
ORDER BY psc.ProductSubcategoryID;