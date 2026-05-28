-- Clients générant le plus de revenus 2024
SELECT c.customerName, SUM(p.amount) montant_total
FROM customers c
LEFT JOIN payments p ON c.customerNumber = p.customerNumber
WHERE p.paymentDate LIKE '%2024%'
GROUP BY c.customerName
ORDER BY montant_total DESC
LIMIT 5;

-- Clients générant le moins de revenus 2024
SELECT c.customerName, SUM(p.amount) montant_total
FROM customers c
LEFT JOIN payments p ON c.customerNumber = p.customerNumber
WHERE p.paymentDate LIKE '%2024%'
GROUP BY c.customerName
HAVING montant_total IS NOT NULL
ORDER BY montant_total ASC
LIMIT 5;

-- Clients générant le plus de revenus 2023
SELECT c.customerName, SUM(p.amount) montant_total
FROM customers c
LEFT JOIN payments p ON c.customerNumber = p.customerNumber
WHERE p.paymentDate LIKE '%2023%'
GROUP BY c.customerName
ORDER BY montant_total DESC
LIMIT 5;

-- Clients générant le moins de revenus 2023
SELECT c.customerName, SUM(p.amount) montant_total
FROM customers c
LEFT JOIN payments p ON c.customerNumber = p.customerNumber
WHERE p.paymentDate LIKE '%2023%'
GROUP BY c.customerName
HAVING montant_total IS NOT NULL
ORDER BY montant_total ASC
LIMIT 5;

-- Clients générant le plus de revenus 2022
SELECT c.customerName, SUM(p.amount) montant_total
FROM customers c
LEFT JOIN payments p ON c.customerNumber = p.customerNumber
WHERE p.paymentDate LIKE '%2022%'
GROUP BY c.customerName
ORDER BY montant_total DESC
LIMIT 5;

-- Clients générant le moins de revenus 2022
SELECT c.customerName, SUM(p.amount) montant_total
FROM customers c
LEFT JOIN payments p ON c.customerNumber = p.customerNumber
WHERE p.paymentDate LIKE '%2022%'
GROUP BY c.customerName
HAVING montant_total IS NOT NULL
ORDER BY montant_total ASC
LIMIT 5;

-- Clients générant le plus de revenus toutes années confondus
SELECT c.customerName, SUM(p.amount) montant_total, YEAR(p.paymentDate)
FROM customers c
LEFT JOIN payments p ON c.customerNumber = p.customerNumber
GROUP BY YEAR(p.paymentDate), c.customerName
ORDER BY montant_total DESC
LIMIT 5;

-- Clients générant le moins de revenus toutes années confondus
SELECT c.customerName, SUM(p.amount) montant_total, YEAR(p.paymentDate)
FROM customers c
LEFT JOIN payments p ON c.customerNumber = p.customerNumber
GROUP BY c.customerName, YEAR(p.paymentDate)
HAVING montant_total IS NOT NULL
ORDER BY montant_total ASC
LIMIT 10;

-- Client générant le plus de revenus
SELECT c.customerName, SUM(p.amount) montant_total
FROM customers c
LEFT JOIN payments p ON c.customerNumber = p.customerNumber
GROUP BY c.customerName
ORDER BY montant_total DESC
LIMIT 10;

-- Client générant le moins de revenus
SELECT c.customerName, SUM(p.amount) montant_total
FROM customers c
LEFT JOIN payments p ON c.customerNumber = p.customerNumber
GROUP BY c.customerName
HAVING montant_total IS NOT NULL
ORDER BY montant_total
LIMIT 10;



-- Nombre de commande par trimestre
SELECT YEAR(o.orderDate) annee, COUNT(o.orderNumber) AS nombre_vente
FROM orders o
GROUP BY annee;

-- Nombre de commande par trimestre année 2022
SELECT QUARTER(o.orderDate) Trimestre, COUNT(o.orderNumber) AS nombre_commande, SUM(p.amount) total_par_trimestre
FROM orders o
JOIN payments p
WHERE o.orderDate LIKE '%2022%' 
GROUP BY Trimestre;

-- Nombre de commande par trimestre année 2023
SELECT QUARTER(o.orderDate) Trimestre, COUNT(o.orderNumber) AS nombre_commande, SUM(p.amount) total_par_trimestre
FROM orders o
JOIN payments p
WHERE o.orderDate LIKE '%2023%' 
GROUP BY Trimestre;

-- Nombre de commande par trimestre année 2024
SELECT QUARTER(o.orderDate) Trimestre, COUNT(o.orderNumber) AS nombre_commande, SUM(p.amount) total_par_trimestre
FROM orders o
JOIN payments p
WHERE o.orderDate LIKE '%2024%' 
GROUP BY Trimestre;

-- Nombre de vente par trimestre année 2022
SELECT QUARTER(p.paymentDate) Trimestre, COUNT(p.checkNumber) AS nombre_vente, SUM(p.amount) total_par_trimestre
FROM payments p
WHERE p.paymentDate LIKE '%2022%' 
GROUP BY Trimestre
ORDER BY total_par_trimestre DESC;

-- Nombre de vente et total encaissé par trimestre et par année classé par année et montant total encaissé par trimestre 
SELECT YEAR(p.paymentDate) Annee, QUARTER(p.paymentDate) Trimestre, COUNT(p.checkNumber) AS nombre_vente, SUM(p.amount) total_par_trimestre
FROM payments p
GROUP BY Trimestre, Annee
ORDER BY Annee, total_par_trimestre DESC;

-- Evolution du nombre de ventes et du chiffre encaissé par trimestre
WITH vente_par_trimestre AS( 
SELECT YEAR(p.paymentDate) Annee, QUARTER(p.paymentDate) Trimestre, COUNT(p.checkNumber) AS nombre_vente, SUM(p.amount) total_par_trimestre
FROM payments p
GROUP BY Trimestre, Annee
ORDER BY Annee, Trimestre)
SELECT vpt.*,ROUND(((vpt.nombre_vente - vpt2.nombre_vente) / vpt2.nombre_vente) * 100, 2) AS evoution_nombre_vente, ROUND(((vpt.total_par_trimestre - vpt2.total_par_trimestre) / vpt2.total_par_trimestre) * 100, 2) AS evolution_CA
FROM vente_par_trimestre vpt
LEFT JOIN vente_par_trimestre vpt2 ON vpt.annee-1 = vpt2.annee and vpt.Trimestre = vpt2.Trimestre;

-- Autre méthode
WITH vente_par_trimestre AS( 
SELECT YEAR(p.paymentDate) Annee, QUARTER(p.paymentDate) Trimestre, COUNT(p.checkNumber) AS nombre_vente, SUM(p.amount) total_par_trimestre
FROM payments p
GROUP BY Trimestre, Annee
ORDER BY Annee, Trimestre)
SELECT vpt.*,ROUND(((vpt.nombre_vente - vpt2.nombre_vente) / vpt2.nombre_vente) * 100, 2) AS evoution_nombre_vente, ROUND(((vpt.total_par_trimestre - vpt2.total_par_trimestre) / vpt2.total_par_trimestre) * 100, 2) AS evolution_CA
FROM vente_par_trimestre vpt
LEFT JOIN vente_par_trimestre vpt2 ON vpt.annee-1 = vpt2.annee and vpt.Trimestre = vpt2.Trimestre;

WITH vente_par_trimestre AS( 
SELECT YEAR(p.paymentDate) Annee, QUARTER(p.paymentDate) Trimestre, COUNT(p.checkNumber) AS nombre_vente, SUM(p.amount) total_par_trimestre
FROM payments p
GROUP BY Trimestre, Annee
ORDER BY Annee, Trimestre)
SELECT vpt.*,
	ROUND(((vpt.nombre_vente - LAG(nombre_vente, 4) OVER(ORDER BY Annee, Trimestre)) / LAG(nombre_vente, 4) OVER(ORDER BY Annee, Trimestre)) * 100, 2) AS evoution_nombre_vente, 
	ROUND(((vpt.total_par_trimestre - LAG(total_par_trimestre, 4) OVER(ORDER BY Annee, Trimestre)) / LAG(total_par_trimestre, 4) OVER(ORDER BY Annee, Trimestre)) * 100, 2) AS evolution_CA
FROM vente_par_trimestre vpt;


-- Nombre de commande et total des montants des commandes par trimestre et par année classé par année et montant total commandé par trimestre 
SELECT YEAR(o.orderDate) Année, QUARTER(o.orderDate) Trimestre, COUNT(o.orderNumber) AS nombre_commande, SUM(od.priceEach) total_par_trimestre
FROM orders o
JOIN orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY Année, Trimestre
ORDER BY Année, total_par_trimestre;

SELECT c.customerName, o.orderNumber, p.productName, p.buyPrice, p.MSRP, od.priceEach
FROM customers c
LEFT JOIN orders o ON c.customerNumber = o.customerNumber
LEFT JOIN orderdetails od ON o.orderNumber = od.orderNumber
JOIN products p ON od.productCode = p.productCode;

WITH worst_customers AS (SELECT c.customerName, SUM(p.amount) montant_total
FROM customers c
LEFT JOIN payments p ON c.customerNumber = p.customerNumber
GROUP BY c.customerName
HAVING montant_total IS NOT NULL
ORDER BY montant_total
LIMIT 10),
best_customers AS (SELECT c.customerName, SUM(p.amount) montant_total
FROM customers c
LEFT JOIN payments p ON c.customerNumber = p.customerNumber
GROUP BY c.customerName
ORDER BY montant_total DESC
LIMIT 10)
SELECT c.customerName, p.productName, p.buyPrice, p.MSRP, od.priceEach, SUM(od.quantityOrdered), o.orderDate, worst_customers.customerName, best_customers.customerName
FROM customers c
LEFT JOIN orders o ON c.customerNumber = o.customerNumber
LEFT JOIN orderdetails od ON o.orderNumber = od.orderNumber
JOIN products p ON od.productCode = p.productCode
LEFT JOIN worst_customers ON c.customerName = worst_customers.customerName
LEFT JOIN best_customers ON c.customerName = best_customers.customerName
WHERE productName LIKE '%1992 Ferrari 360 Spider red%'
GROUP BY c.customerName, p.productName, p.buyPrice, p.MSRP, od.priceEach, o.orderDate
ORDER BY o.orderDate, c.customerName, od.priceEach ;

WITH worst_customers AS (SELECT c.customerName, SUM(p.amount) montant_total
FROM customers c
LEFT JOIN payments p ON c.customerNumber = p.customerNumber
GROUP BY c.customerName
HAVING montant_total IS NOT NULL
ORDER BY montant_total
LIMIT 10),
best_customers AS (SELECT c.customerName, SUM(p.amount) montant_total
FROM customers c
LEFT JOIN payments p ON c.customerNumber = p.customerNumber
GROUP BY c.customerName
ORDER BY montant_total DESC
LIMIT 10)
SELECT c.customerName, p.productName, AVG(od.priceEach), AVG(od.quantityOrdered), p.MSRP, CONCAT(MONTH(o.orderDate),'/', YEAR(orderDate)) AS order_periode, worst_customers.customerName AS Worst_Customer, best_customers.customerName AS Best_customers
FROM customers c 
LEFT JOIN orders o ON c.customerNumber = o.customerNumber
LEFT JOIN orderdetails od ON o.orderNumber = od.orderNumber
JOIN products p ON od.productCode = p.productCode
LEFT JOIN worst_customers ON c.customerName = worst_customers.customerName
LEFT JOIN best_customers ON c.customerName = best_customers.customerName
WHERE p.productName LIKE '%1992 Ferrari%'
GROUP BY c.customerName, p.productName, p.MSRP, CONCAT(MONTH(o.orderDate),'/', YEAR(orderDate));
