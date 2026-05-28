# 🚗 Toys & Models — Analyse Commerciale & Logistique (SQL & Power BI)

<img width="1435" height="808" alt="Dashboard Finance Toys and models" src="https://github.com/user-attachments/assets/03e94c30-75bc-4df4-91e7-ba1590679d38" />

## 📌 Contexte du Projet
Ce projet simule une mission de conseil en Business Intelligence pour l'entreprise "Toys & Models", un distributeur international de modèles réduits et objets de collection. L'objectif était d'analyser la performance globale de l'entreprise et d'apporter des recommandations stratégiques basées sur la donnée aux directions commerciale, financière et logistique.

## 🎯 Objectifs Business & Missions Analytiques
* **Analyse de Performance Commerciale & Croissance :** Calcul du Chiffre d'Affaires (CA) et du volume des ventes agrégés par année et par trimestre. Modélisation de l'évolution du panier moyen ($N$ vs $N-1$) pour identifier les cycles de croissance.
* **Gestion du Risque Financier & Clients :** Identification des meilleurs et moins bons clients en termes de revenus encaissés. Cartographie fine des encours, calcul des montants restants dus et suivi rigoureux des risques de dépassement de la limite de crédit (`creditLimit`).
* **Suivi de la Supply Chain & Délais :** Modélisation et calcul complexe du délai de paiement moyen par client et global en jours (`DATEDIFF`) en croisant de manière itérative les historiques cumulés de commandes et d'encaissements.

## 🛠️ Stack Technique
* **Langage de requête :** SQL (MySQL) — Requêtes d'extraction massives, jointures complexes (`LEFT JOIN`), agrégations, sous-requêtes, CTE (`WITH`), et fonctions de fenêtrage (`LAG() OVER`).
* **Outil de Business Intelligence :** Power BI (Modélisation en étoile, DAX, et Data Visualization).

## 📊 Structure des Analyses SQL Disponibles
Le dépôt contient les scripts d'extraction et d'analyse suivants :
1. **`KPI croissance_vente.sql` :** Analyse de l'évolution trimestrielle du CA, du volume de transactions et du panier moyen avec calculs de variations en pourcentage.
2. **`KPI best_and_worst_customers.sql` :** Classement et segmentation des portefeuilles clients selon la réalité des flux financiers encaissés vs commandés.
3. **`delai moyen par paiement.sql` :** Algorithme SQL utilisant des CTE croisées pour attribuer chronologiquement les paiements aux factures correspondantes et en déduire le délai moyen de règlement en jours.
4. **`taux de dépassement crédit limit.sql` :** Analyse de santé financière identifiant les clients à risque (calcul des taux d'impayés et alertes sur les dépassements de plafonds de crédit autorisés).

## 🚀 Impact Business
Ces requêtes fournissent les fondations analytiques permettant aux décideurs de Toys & Models de sécuriser la trésorerie (relance des impayés à risque), d'ajuster les politiques d'octroi de crédit et d'optimiser le ciblage des campagnes commerciales sur les segments les plus rentables.
