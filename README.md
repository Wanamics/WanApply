# Extension WanApply<!-- omit in toc -->

Les anglophones *appliquent* (to Apply) des écritures les unes aux autres.  
La traduction de Business Central a retenu **Lettrage** dont l'éthimologie est ici paradoxale (voir [Code lettrage... enfin - Wanamics](https://www.wanamics.fr/code-lettrage-enfin)).

Cette extension complète les fonctions standards de lettrage des écritures clients, écritures fournisseurs et écritures salariés.

![Lettrage](docs/assets/README.png)

> Ce n’est que l’une des extensions gracieusement mises à votre disposition (voir [Extensions - Wanamics](https://www.wanamics.fr/extensions-business-central/Extensions)).  
Vous pouvez donc en disposer librement dans le cadre de la licence open source qui vous est accordée (voir [Licence Open Source - Wanamics](https://www.wanamics.fr/licence-open-source/)).

Voir aussi :
* [Lettrage à posteriori - Wanamics](https://www.wanamics.fr/lettrage-a-posteriori/)

* [Paiement à la commande et lettrage - Wanamics](https://www.wanamics.fr/paiement-a-la-commande-et-lettrage/)

### Sommaire 
- [Écritures comptables clients, fournisseurs et salariés](#écritures-comptables-clients-fournisseurs-et-salariés)
- [Écritures comptables clients](#écritures-comptables-clients)
  - [Colonnes](#colonnes)
  - [Actions](#actions)
- [Feuille règlement](#feuille-règlement)
  - [Actions](#actions-1)
- [Traitements Appliquer ID Lettrage...](#traitements-appliquer-id-lettrage)
- [APIs](#apis)
  - [custAppliedLedgerEntries](#custappliedledgerentries)
- [Outils d'administration](#outils-dadministration)

## Écritures comptables clients, fournisseurs et salariés
* La colonne **Code lettrage** est ajoutée (voir [Code lettrage... enfin - Wanamics](https://www.wanamics.fr/code-lettrage-enfin))

## Écritures comptables clients

### Colonnes
* **ID lettrage** est ajouté. Il pourra être saisi pour un lettrage 'à l'ancienne' par un même code (à votre convenance) sur les écritures à lettrer entre elles (voir action Appliquer lettrage)  
    * Remarque : ce champ standard est habituellement utilisé via les feuille de saisie (ex : en particulier Feuilles règlements, et Feuilles paiement) via l'action **Ecritures ouvertes**.

### Actions
*   **Transférer**\
Permet de 'rectifier' la **Date comptabilisation**, le **N° client** ou les imputations analytiques des 2 axes principaux, en contrepassant l'écriture d'origine par ces nouvelles informations. 
    * Une confirmation est demandée.
    * Plusieurs écritures peuvent être sélectionnées et se verront appliquer les mêmes modifications.
    * Les écritures concernées ne doivent pas relever de la TVA sur encaissements.
    * Les écritures concernées ne doivent pas être lettrées (même partiellement) et ne pas avoir été déjà contrepassées.
    * L'écriture d'origine et sa contrepassation sont lettrées entre elles (étant marquées **Contre-passé** elles ne pourront être de nouveau transférées).
    * Si la **Date comptabilisation** est modifiée, elle est reprise pour l'écriture de contrepassation comme pour la nouvelle (faute de quoi l'opération de serait pas équilibrée à date).
    * La **Description** de l'écriture de contrepassation est suffixée '-', celle de la nouvelle est suffixée '+'.
    * Le **N° séquence lettrage final** sera celui de de l'écriture la plus récente, de même que la **Date lettrage**.
* **Appliquer lettrage**\
 Voir [Appliquer ID lettrage](#traitements-appliquer-id-lettrage)
* **Clôturer par P & P**\
Valide une écriture venant solder et lettrer le **Montant restant** de chacune des écritures sélectionnées (le **Groupe compta. client** est complété à cet effet des **N° compte P & P débit** et **N° compte P & P crédit**).
   
## Feuille règlement

### Actions
* **Proposer écarts de règlementpar montant ouvert**\
Propose de solder les écritures dont le montant ouvert est 'faible' (ex : -0,05..0,05).  
Le **N° compte contrepartie** reprend le Compte écart règlement associé au **Groupe compta client**.

* **Proposer écarts de règlement par ID lettrage**\
Propose de solder et lettrer les écritures de même de même **ID lettrage**, **Code devise** et **Groupe compta** dont le montant ouvert est inférieur au montant indiqué (le **Montant écart règlement max.** défini en **Paramètres comptabilité** est proposé).  
Le **N° compte contrepartie** reprend le Compte écart règlement associé au **Groupe compta client**.

## Traitements Appliquer ID Lettrage...
Ce traitement peut concerner les clients, les fournisseurs ou les salariés.

Si, au sein d'un même compte, le total du **Montant ouvert** des écritures de même **ID lettrage**, **Code devise** et **Groupe compta** est nul, elles sont lettrées entre elles.

Ces traitements seront particulièrement utiles suite à une reprise de données (Voir [WanaStart - Wanamics](https://www.wanamics.fr/wanastart)).


## APIs
Pour mémoire, la syntaxe d'un endpoint est la suivante :
```
{{apiRoute}}/{{tenantID}}/{{environment}}/api/{{apiPublisher}}/{{apiGroup}}/{{apiVersion}}/companies({{companyID}})/{entitySetName}
```
### custAppliedLedgerEntries
Permet aux application tierces (ex : e-commerce, facturation extene...) d'être informé du règlement des factures.
``` 
    APIPublisher = 'Wanamics';
    APIGroup = 'wanApply';
    APIVersion = 'v1.0';
    EntitySetName = 'custAppliedLedgerEntries';
    EntityName = 'custAppliedLedgerEntry';
````

## Outils d'administration
* ?Report=87476 "Apply Applies-to ID/Cust.Inv."\
Recherche pour chaque **Ecriture client** de la sélection débritrice dont **ID lettrage** est non vide, les écritures de même **ID lettrage** à lettrer, même partiellement.
