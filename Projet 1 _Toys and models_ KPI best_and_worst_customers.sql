-- Client générant le plus de revenus
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
SELECT c.customerName, mppc.montant_paye AS montant_total_encaissé, mipc.montant_impaye, c.creditLimit
FROM customers c
LEFT JOIN montant_paye_par_client mppc ON c.customerNumber = mppc.customerNumber
LEFT JOIN montant_impaye_par_client mipc ON c.customerNumber = mipc.customerNumber
ORDER BY montant_total_encaissé DESC, c.creditLimit DESC;

-- Client générant le moins de revenus
SELECT c.customerName, SUM(p.amount) montant_total, c.creditLimit
FROM customers c
LEFT JOIN payments p ON c.customerNumber = p.customerNumber
GROUP BY c.customerName, c.creditLimit
HAVING montant_total IS NOT NULL
ORDER BY montant_total, c.creditLimit DESC;

-- Client avec aucun encaissement et aucune commande
SELECT COUNT(c.customerNumber)
FROM customers c
LEFT JOIN payments p ON c.customerNumber = p.customerNumber
WHERE p.amount IS NULL;

SELECT c.customerName, COUNT(o.orderNumber), c.creditLimit
FROM customers c
LEFT JOIN orders o ON c.customerNumber = o.customerNumber
LEFT JOIN payments p ON c.customerNumber = p.customerNumber
WHERE p.amount IS NULL
GROUP BY c.customerName, c.creditLimit;

-- Classement client par rapport au chiffres encaissé et aux montant total des commandes passées et credit Limit
WITH montant_total_commande_par_client AS (SELECT c.customerName, SUM(od.priceEach * od.quantityOrdered) montant_total_commandé
											FROM customers c
                                            LEFT JOIN orders o ON c.customerNumber = o.customerNumber
                                            LEFT JOIN orderdetails od ON o.orderNumber = od.orderNumber
                                            WHERE o.status LIKE '%shipped%' OR '%resolved%'
                                            GROUP BY c.customerName
                                            ORDER BY montant_total_commandé DESC)
SELECT c.customerName, SUM(p.amount) montant_total_encaissé, c.creditLimit, montant_total_commande_par_client.*
FROM customers c
LEFT JOIN payments p ON c.customerNumber = p.customerNumber
LEFT JOIN orders o ON c.customerNumber = o.customerNumber
LEFT JOIN orderdetails od ON o.orderNumber = od.orderNumber
LEFT JOIN montant_total_commande_par_client ON c.customerName = montant_total_commande_par_client.customerName
GROUP BY c.customerName, c.creditLimit
ORDER BY montant_total_encaissé DESC, montant_total_commandé DESC;

SELECT c.customerName, SUM(od.quantityOrdered * od.priceEach) - SUM(p.amount) AS montant_restant
FROM customers c
LEFT JOIN payments p ON c.customerNumber = p.customerNumber
LEFT JOIN orders o ON c.customerNumber = o.customerNumber
LEFT JOIN orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY c.customerName
order by montant_restant DESC;


