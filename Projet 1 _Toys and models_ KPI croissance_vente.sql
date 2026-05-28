-- Evolution du nombre de ventes et du chiffre encaissé par trimestre
WITH vente_par_trimestre AS( 
SELECT YEAR(p.paymentDate) Annee, QUARTER(p.paymentDate) Trimestre, COUNT(p.checkNumber) AS nombre_vente, SUM(p.amount) total_par_trimestre
FROM payments p
GROUP BY Trimestre, Annee
ORDER BY Annee, Trimestre)
SELECT vpt.*,
ROUND(((vpt.nombre_vente - vpt2.nombre_vente) / vpt2.nombre_vente) * 100, 2) AS evoution_nombre_vente, 
ROUND(((vpt.total_par_trimestre - vpt2.total_par_trimestre) / vpt2.total_par_trimestre) * 100, 2) AS evolution_CA
FROM vente_par_trimestre vpt
LEFT JOIN vente_par_trimestre vpt2 ON vpt.annee-1 = vpt2.annee and vpt.Trimestre = vpt2.Trimestre;

-- Evolution panier moyen
SELECT YEAR(o.orderDate) Annee, QUARTER(o.orderDate) Trimestre, SUM(od.quantityOrdered * od.priceEach) / COUNT(DISTINCT o.orderNumber) AS panier_moyen
FROM orders o
LEFT JOIN orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY Annee, Trimestre;

WITH panier_moyen_par_trimestre AS (SELECT YEAR(o.orderDate) Annee, QUARTER(o.orderDate) Trimestre, 
									ROUND(SUM(od.quantityOrdered * od.priceEach) / COUNT(DISTINCT o.orderNumber), 2) AS panier_moyen
									FROM orders o
									LEFT JOIN orderdetails od ON o.orderNumber = od.orderNumber
									GROUP BY Annee, Trimestre)
SELECT pmpt.*, ROUND(((pmpt.panier_moyen - pmpt2.panier_moyen) / pmpt2.panier_moyen) * 100, 2) AS evoution_paier_moyen
FROM panier_moyen_par_trimestre pmpt
LEFT JOIN panier_moyen_par_trimestre pmpt2 ON pmpt.annee-1 = pmpt2.annee and pmpt.Trimestre = pmpt2.Trimestre;