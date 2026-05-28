-- Délai de paiement moyen par client
WITH montant_cde_par_client AS (
   SELECT c.customerNumber, c.customerName, o.orderDate, SUM(od.quantityOrdered * od.priceEach) montant_commande
     FROM customers c
     JOIN orders o ON c.customerNumber = o.customerNumber
     JOIN orderdetails od ON o.orderNumber = od.orderNumber
 GROUP BY c.customerNumber, c.customerName, o.orderDate
 ORDER BY c.customerName, o.orderDate),
montant_cde_cumule_par_client AS (
   SELECT montant_cde_par_client.customerNumber, 
          montant_cde_par_client.customerName, montant_cde_par_client.orderDate, SUM(mcpc2.montant_commande) montant_cumule_cde
     FROM montant_cde_par_client
LEFT JOIN montant_cde_par_client mcpc2 ON montant_cde_par_client.orderDate >= mcpc2.orderDate AND montant_cde_par_client.customerNumber = mcpc2.customerNumber
 GROUP BY montant_cde_par_client.customerNumber, montant_cde_par_client.customerName, montant_cde_par_client.orderDate),
montant_paiement_par_client AS (
SELECT c.customerNumber, c.customerName, p.paymentDate, SUM(p.amount) montant_payé
FROM customers c
JOIN payments p ON c.customerNumber = p.customerNumber
GROUP BY c.customerNumber, c.customerName, p.paymentDate
ORDER BY c.customerName, p.paymentDate),
montant_paiement_cumule_par_client AS (
SELECT mppc.customerNumber, mppc.customerName, mppc.paymentDate, SUM(mppc2.montant_payé) montant_cumule_paye
FROM montant_paiement_par_client mppc
LEFT JOIN montant_paiement_par_client mppc2 ON mppc.paymentDate >= mppc2.paymentDate AND mppc.customerNumber = mppc2.customerNumber
GROUP BY mppc.customerNumber, mppc.customerName, mppc.paymentDate),
delai_paiement_jour AS (
SELECT mccpc.customerNumber, mccpc.customerName, mccpc.orderDate, COALESCE(MIN(mpcpc.paymentDate), date_format('2024-02-25', '%Y-%m-%d')) date_paiement, 
DATEDIFF(COALESCE(MIN(mpcpc.paymentDate), date_format('2024-02-25', '%Y-%m-%d')), mccpc.orderDate) delai_paiement_en_jour
FROM montant_cde_cumule_par_client mccpc
LEFT JOIN montant_paiement_cumule_par_client mpcpc ON mccpc.orderDate <= mpcpc.paymentDate AND mccpc.customerNumber = mpcpc.customerNumber AND mccpc.montant_cumule_cde <= mpcpc.montant_cumule_paye
GROUP BY mccpc.customerNumber, mccpc.customerName, mccpc.orderDate)
SELECT dpj.customerNumber, dpj.customerName, ROUND(AVG(dpj.delai_paiement_en_jour),2) delai_moyen_paiement
FROM delai_paiement_jour dpj
GROUP BY dpj.customerNumber, dpj.customerName;

-- Délai moyen paiement client confondus
WITH montant_cde_par_client AS (
SELECT c.customerNumber, c.customerName, o.orderDate, SUM(od.quantityOrdered * od.priceEach) montant_commande
FROM customers c
JOIN orders o ON c.customerNumber = o.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY c.customerNumber, c.customerName, o.orderDate
ORDER BY c.customerName, o.orderDate),
montant_cde_cumule_par_client AS (
SELECT montant_cde_par_client.customerNumber, montant_cde_par_client.customerName, montant_cde_par_client.orderDate, SUM(mcpc2.montant_commande) montant_cumule_cde
FROM montant_cde_par_client
LEFT JOIN montant_cde_par_client mcpc2 ON montant_cde_par_client.orderDate >= mcpc2.orderDate AND montant_cde_par_client.customerNumber = mcpc2.customerNumber
GROUP BY montant_cde_par_client.customerNumber, montant_cde_par_client.customerName, montant_cde_par_client.orderDate),
montant_paiement_par_client AS (
SELECT c.customerNumber, c.customerName, p.paymentDate, SUM(p.amount) montant_payé
FROM customers c
JOIN payments p ON c.customerNumber = p.customerNumber
GROUP BY c.customerNumber, c.customerName, p.paymentDate
ORDER BY c.customerName, p.paymentDate),
montant_paiement_cumule_par_client AS (
SELECT mppc.customerNumber, mppc.customerName, mppc.paymentDate, SUM(mppc2.montant_payé) montant_cumule_paye
FROM montant_paiement_par_client mppc
LEFT JOIN montant_paiement_par_client mppc2 ON mppc.paymentDate >= mppc2.paymentDate AND mppc.customerNumber = mppc2.customerNumber
GROUP BY mppc.customerNumber, mppc.customerName, mppc.paymentDate),
delai_paiement_jour AS (
SELECT mccpc.customerNumber, mccpc.customerName, mccpc.orderDate, COALESCE(MIN(mpcpc.paymentDate), date_format('2024-02-25', '%Y-%m-%d')) date_paiement, 
DATEDIFF(COALESCE(MIN(mpcpc.paymentDate), date_format('2024-02-25', '%Y-%m-%d')), mccpc.orderDate) delai_paiement_en_jour
FROM montant_cde_cumule_par_client mccpc
LEFT JOIN montant_paiement_cumule_par_client mpcpc ON mccpc.orderDate <= mpcpc.paymentDate AND mccpc.customerNumber = mpcpc.customerNumber AND mccpc.montant_cumule_cde <= mpcpc.montant_cumule_paye
GROUP BY mccpc.customerNumber, mccpc.customerName, mccpc.orderDate)
SELECT ROUND(AVG(dpj.delai_paiement_en_jour),2) delai_moyen_paiement
FROM delai_paiement_jour dpj;


-- Test
WITH montant_cde_par_client AS (
SELECT c.customerNumber, c.customerName, o.orderDate, SUM(od.quantityOrdered * od.priceEach) montant_commande
FROM customers c
JOIN orders o ON c.customerNumber = o.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY c.customerNumber, c.customerName, o.orderDate
ORDER BY c.customerName, o.orderDate),
montant_cde_cumule_par_client AS (
SELECT montant_cde_par_client.customerNumber, montant_cde_par_client.customerName, montant_cde_par_client.orderDate, SUM(mcpc2.montant_commande) montant_cumule_cde
FROM montant_cde_par_client
LEFT JOIN montant_cde_par_client mcpc2 ON montant_cde_par_client.orderDate >= mcpc2.orderDate AND montant_cde_par_client.customerNumber = mcpc2.customerNumber
GROUP BY montant_cde_par_client.customerNumber, montant_cde_par_client.customerName, montant_cde_par_client.orderDate),
montant_paiement_par_client AS (
SELECT c.customerNumber, c.customerName, p.paymentDate, SUM(p.amount) montant_payé
FROM customers c
JOIN payments p ON c.customerNumber = p.customerNumber
GROUP BY c.customerNumber, c.customerName, p.paymentDate
ORDER BY c.customerName, p.paymentDate),
montant_paiement_cumule_par_client AS (
SELECT mppc.customerNumber, mppc.customerName, mppc.paymentDate, SUM(mppc2.montant_payé) montant_cumule_paye
FROM montant_paiement_par_client mppc
LEFT JOIN montant_paiement_par_client mppc2 ON mppc.paymentDate >= mppc2.paymentDate AND mppc.customerNumber = mppc2.customerNumber
GROUP BY mppc.customerNumber, mppc.customerName, mppc.paymentDate)
SELECT mccpc.customerNumber, mccpc.customerName, mccpc.orderDate, COALESCE(MIN(mpcpc.paymentDate), date_format('2024-02-25', '%Y-%m-%d')) date_paiement, 
DATEDIFF(COALESCE(MIN(mpcpc.paymentDate),date_format('2024-02-25', '%Y-%m-%d')), mccpc.orderDate) delai_paiement_en_jour
FROM montant_cde_cumule_par_client mccpc
LEFT JOIN montant_paiement_cumule_par_client mpcpc ON mccpc.orderDate <= mpcpc.paymentDate AND mccpc.customerNumber = mpcpc.customerNumber AND mccpc.montant_cumule_cde <= mpcpc.montant_cumule_paye
GROUP BY mccpc.customerNumber, mccpc.customerName, mccpc.orderDate;