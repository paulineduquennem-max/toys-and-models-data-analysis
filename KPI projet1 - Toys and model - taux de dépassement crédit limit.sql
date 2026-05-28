SELECT *
FROM orderdetails;

SELECT od.orderNumber, SUM(od.quantityOrdered * od.priceEach) montant_commande
FROM orderdetails od
GROUP BY od.orderNumber;

WITH commande_client AS (SELECT c.customerNumber, c.customerName, od.orderNumber, o.orderDate, SUM(od.quantityOrdered * od.priceEach) montant_commande
						FROM customers c
						JOIN orders o ON c.customerNumber = o.customerNumber
						JOIN orderdetails od ON o.orderNumber = od.orderNumber
						GROUP BY c.customerNumber, c.customerName, od.orderNumber)
SELECT *
FROM commande_client
LEFT JOIN payments ON commande_client.customerNumber = payments.customerNumber AND payments.amount = commande_client.montant_commande
ORDER BY paymentDate;

WITH commande_client AS (SELECT c.customerNumber, c.customerName, od.orderNumber, o.orderDate, SUM(od.quantityOrdered * od.priceEach) montant_commande
						FROM customers c
						JOIN orders o ON c.customerNumber = o.customerNumber
						JOIN orderdetails od ON o.orderNumber = od.orderNumber
						GROUP BY c.customerNumber, c.customerName, od.orderNumber)
SELECT commande_client.*, DATEDIFF(2024-12-31, o.orderDate) AS antériorité_de_créance
FROM commande_client
LEFT JOIN payments ON commande_client.customerNumber = payments.customerNumber AND payments.amount = commande_client.montant_commande
LEFT JOIN orders o ON commande_client.orderNumber = o.orderNumber
ORDER BY paymentDate;

-- Commande impayée
WITH commande_client AS (SELECT c.customerNumber, c.customerName, od.orderNumber, o.orderDate, SUM(od.quantityOrdered * od.priceEach) montant_commande
						FROM customers c
						JOIN orders o ON c.customerNumber = o.customerNumber
						JOIN orderdetails od ON o.orderNumber = od.orderNumber
						GROUP BY c.customerNumber, c.customerName, od.orderNumber)
SELECT c.customerNumber, c.customerName, SUM(commande_client.montant_commande) AS montant_commande_impaye, c.creditLimit
FROM customers c
JOIN commande_client ON c.customerNumber = commande_client.customerNumber
LEFT JOIN payments p ON c.customerNumber = p.customerNumber AND p.amount = commande_client.montant_commande
WHERE p.amount IS NULL 
GROUP BY c.customerNumber, c.customerName, c.creditLimit
ORDER BY montant_commande_impaye DESC;

WITH commande_client AS (SELECT c.customerNumber, c.customerName, od.orderNumber, o.orderDate, SUM(od.quantityOrdered * od.priceEach) montant_commande
						FROM customers c
						JOIN orders o ON c.customerNumber = o.customerNumber
						JOIN orderdetails od ON o.orderNumber = od.orderNumber
						GROUP BY c.customerNumber, c.customerName, od.orderNumber)
SELECT c.customerNumber, c.customerName, SUM(commande_client.montant_commande) AS montant_commande_impaye, c.creditLimit, ROUND((DATEDIFF('2024-12-31', o.orderDate)/365),0) AS antériorité_de_créance_par_annee
FROM customers c
JOIN commande_client ON c.customerNumber = commande_client.customerNumber
LEFT JOIN payments p ON c.customerNumber = p.customerNumber AND p.amount = commande_client.montant_commande
LEFT JOIN orders o ON commande_client.orderNumber = o.orderNumber
WHERE p.amount IS NULL 
GROUP BY c.customerNumber, c.customerName, c.creditLimit, antériorité_de_créance_par_annee
ORDER BY c.creditLimit DESC, montant_commande_impaye DESC;

-- TAUX de dépassement crédit limit par client pour les commandes impayées
WITH commande_client AS (SELECT c.customerNumber, c.customerName, od.orderNumber, o.orderDate, SUM(od.quantityOrdered * od.priceEach) montant_commande
						FROM customers c
						JOIN orders o ON c.customerNumber = o.customerNumber
						JOIN orderdetails od ON o.orderNumber = od.orderNumber
						GROUP BY c.customerNumber, c.customerName, od.orderNumber)
SELECT c.customerNumber, c.customerName, SUM(commande_client.montant_commande) AS montant_commande_impaye,  c.creditLimit,
ROUND((((SUM(commande_client.montant_commande) - c.creditLimit) * 100) / c.creditLimit), 2) AS taux_de_depassement_credit_Limit
FROM customers c
JOIN commande_client ON c.customerNumber = commande_client.customerNumber
LEFT JOIN payments p ON c.customerNumber = p.customerNumber AND p.amount = commande_client.montant_commande
WHERE p.amount IS NULL
GROUP BY c.customerNumber, c.customerName, c.creditLimit
ORDER BY taux_de_depassement_credit_Limit DESC;

-- Taux d'impayés par clients
WITH commande_client AS (SELECT c.customerNumber, c.customerName, od.orderNumber, o.orderDate, SUM(od.quantityOrdered * od.priceEach) montant_commande
						FROM customers c
						JOIN orders o ON c.customerNumber = o.customerNumber
						JOIN orderdetails od ON o.orderNumber = od.orderNumber
						GROUP BY c.customerNumber, c.customerName, od.orderNumber),
commande_client_impayee AS (SELECT c.customerNumber, c.customerName, SUM(commande_client.montant_commande) AS montant_commande_impaye, c.creditLimit
							FROM customers c
							JOIN commande_client ON c.customerNumber = commande_client.customerNumber
							LEFT JOIN payments p ON c.customerNumber = p.customerNumber AND p.amount = commande_client.montant_commande
							WHERE p.amount IS NULL 
							GROUP BY c.customerNumber, c.customerName, c.creditLimit
							ORDER BY montant_commande_impaye DESC)
SELECT c.customerName, ROUND((cci.montant_commande_impaye / SUM(cl.montant_commande)) * 100, 2) Taux_impaye 
FROM commande_client_impayee cci
JOIN customers c ON cci.customerNumber = c.customerNumber
JOIN commande_client cl ON cci.customerNumber = cl.customerNumber 
GROUP BY c.customerNumber
ORDER BY Taux_impaye DESC; 

-- Commande impayée dépassant le crédit Limit
WITH commande_client AS (SELECT c.customerNumber, c.customerName, od.orderNumber, o.orderDate, SUM(od.quantityOrdered * od.priceEach) montant_commande
						FROM customers c
						JOIN orders o ON c.customerNumber = o.customerNumber
						JOIN orderdetails od ON o.orderNumber = od.orderNumber
						GROUP BY c.customerNumber, c.customerName, od.orderNumber)
SELECT c.customerNumber, c.customerName, SUM(commande_client.montant_commande) AS montant_commande_impaye, c.creditLimit, ROUND((((SUM(commande_client.montant_commande) - c.creditLimit) * 100) / c.creditLimit), 2) AS taux_de_depassement_credit_Limit
FROM customers c
JOIN commande_client ON c.customerNumber = commande_client.customerNumber
LEFT JOIN payments p ON c.customerNumber = p.customerNumber AND p.amount = commande_client.montant_commande
WHERE p.amount IS NULL
GROUP BY c.customerNumber, c.customerName, c.creditLimit
HAVING montant_commande_impaye > creditLimit
ORDER BY montant_commande_impaye DESC;

-- Montant commandes payé par client
WITH commande_client AS (SELECT c.customerNumber, c.customerName, od.orderNumber, o.orderDate, SUM(od.quantityOrdered * od.priceEach) montant_commande
						FROM customers c
						JOIN orders o ON c.customerNumber = o.customerNumber
						JOIN orderdetails od ON o.orderNumber = od.orderNumber
						GROUP BY c.customerNumber, c.customerName, od.orderNumber)
SELECT c.customerNumber, c.customerName, SUM(commande_client.montant_commande) AS montant_commande_paye, c.creditLimit
FROM customers c
JOIN commande_client ON c.customerNumber = commande_client.customerNumber
LEFT JOIN payments p ON c.customerNumber = p.customerNumber AND p.amount = commande_client.montant_commande
WHERE p.amount IS NOT NULL 
GROUP BY c.customerNumber, c.customerName, c.creditLimit
ORDER BY montant_commande_paye DESC; 

-- Montant impayé par client
-- Montant total commandé par client
SELECT c.customerNumber, c.customerName, SUM(od.quantityOrdered * od.priceEach) montant_commande
FROM customers c
JOIN orders o ON c.customerNumber = o.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY c.customerNumber, c.customerName; 

-- Montant payé par client
SELECT c.customerNumber, c.customerName, SUM(p.amount) montant_paye
FROM customers c
JOIN payments p ON c.customerNumber = p.customerNumber
GROUP BY c.customerNumber, c.customerName;

WITH montant_commande_par_client AS (SELECT c.customerNumber, c.customerName, SUM(od.quantityOrdered * od.priceEach) montant_commande
									FROM customers c
									JOIN orders o ON c.customerNumber = o.customerNumber
									JOIN orderdetails od ON o.orderNumber = od.orderNumber
									GROUP BY c.customerNumber, c.customerName),
montant_paye_par_client AS(SELECT c.customerNumber, c.customerName, SUM(p.amount) montant_paye
							FROM customers c
							JOIN payments p ON c.customerNumber = p.customerNumber
							GROUP BY c.customerNumber, c.customerName)
SELECT c.customerName, (mcpc.montant_commande - mppc.montant_paye) montant_impaye
FROM customers c
LEFT JOIN montant_commande_par_client mcpc ON c.customerNumber = mcpc.customerNumber
LEFT JOIN montant_paye_par_client mppc ON c.customerNumber = mppc.customerNumber
GROUP BY c.customerNumber, c.customerName
HAVING montant_impaye > 0
ORDER BY montant_impaye DESC;

-- Montant impayé par client et le taux d'impayé
WITH montant_commande_par_client AS (SELECT c.customerNumber, c.customerName, SUM(od.quantityOrdered * od.priceEach) montant_commande
									FROM customers c
									JOIN orders o ON c.customerNumber = o.customerNumber
									JOIN orderdetails od ON o.orderNumber = od.orderNumber
                                    WHERE o.status <> 'cancelled'
									GROUP BY c.customerNumber, c.customerName),
montant_paye_par_client AS(SELECT c.customerNumber, c.customerName, SUM(p.amount) montant_paye
							FROM customers c
							JOIN payments p ON c.customerNumber = p.customerNumber
							GROUP BY c.customerNumber, c.customerName),
montant_impaye_par_client AS (SELECT c.customerNumber, (mcpc.montant_commande - mppc.montant_paye) montant_impaye
							FROM customers c
							LEFT JOIN montant_commande_par_client mcpc ON c.customerNumber = mcpc.customerNumber
							LEFT JOIN montant_paye_par_client mppc ON c.customerNumber = mppc.customerNumber
							GROUP BY c.customerNumber, c.customerName)
SELECT c.customerName, mcpc.montant_commande, mppc.montant_paye, mipc.montant_impaye, c.creditLimit, 
ROUND(((mipc.montant_impaye / mcpc.montant_commande) *100), 2)Taux_impaye,
ROUND((((mipc.montant_impaye - c.creditLimit) * 100) / c.creditLimit), 2) AS taux_de_depassement_credit_Limit
FROM customers c 
LEFT JOIN montant_impaye_par_client mipc ON c.customerNumber = mipc.customerNumber
LEFT JOIN montant_commande_par_client mcpc ON c.customerNumber = mcpc.customerNumber
LEFT JOIN montant_paye_par_client mppc ON c.customerNumber = mppc.customerNumber
ORDER BY montant_impaye DESC;