SELECT ProductID, PV.BusinessEntityID, Name FROM Purchasing.ProductVendor PPV 
JOIN Purchasing.Vendor PV ON (PPV.BusinessEntityID = PV.BusinessEntityID);

SELECT ProductID, PV.BusinessEntityID, Name FROM Purchasing.ProductVendor PPV 
JOIN Purchasing.Vendor PV ON (PPV.BusinessEntityID = PV.BusinessEntityID) 
WHERE StandardPrice > $10 ;

SELECT ProductID, PV.BusinessEntityID, Name FROM Purchasing.ProductVendor PPV 
JOIN Purchasing.Vendor PV ON (PPV.BusinessEntityID = PV.BusinessEntityID) 
WHERE StandardPrice > $40 AND Name LIKE N'F%';