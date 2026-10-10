# Forest Radar — Glossary

Domain terms only. Technical terms stay in the plan and the README.

## Forest administration

**Lasy Państwowe**
The Polish State Forests. The state organization that manages most Polish forest.
_Avoid_: state forest

**BDL (Bank Danych o Lasach)**
The Forest Data Bank. The public service that publishes the data of Lasy Państwowe.
_Avoid_: forest API

**RDLP (Regionalna Dyrekcja Lasów Państwowych)**
A regional directorate. Poland has 17. Each RDLP holds several districts.
_Avoid_: region

**Nadleśnictwo**
A forest district. Poland has 429. A district manages several ranges.
_Avoid_: forest, park

**Leśnictwo**
A forest range. A range is a part of a district.

## Forest inventory

**Wydzielenie**
A forest stand. The smallest unit of the forest inventory. A stand holds one tree community.
_Avoid_: plot, parcel, compartment

**Oddział**
A division. A group of stands inside a range.

**Siedlisko (site type)**
The habitat type of a stand. The code `BMŚW` means fresh mixed conifer forest.

**Gatunek (species)**
The main tree species of a stand. The code `SO` means Scots pine.

**Zakaz wstępu do lasu**
A periodic ban on entering a forest. A district issues a ban for a fire risk or for another hazard.

**Zanocuj w lesie**
A Polish program for legal overnight camping in a forest.

## The mushroom question

**Grzyboznawca**
A certified mushroom expert. A grzyboznawca identifies a mushroom and issues an opinion.
_Avoid_: mushroom expert

**Klasyfikator grzybów**
A certified mushroom classifier. A klasyfikator identifies the species of a fresh mushroom.

**Porady grzybowe**
The free mushroom identification service. The sanitary stations offer it on weekdays.
_Avoid_: mushroom hotline

**Sanepid**
The Polish sanitary inspection. A Powiatowa or Wojewódzka Stacja Sanitarno-Epidemiologiczna holds a grzyboznawca.
_Avoid_: sanitary office

**Edibility claim**
Any statement or implication that a mushroom is safe to eat or poisonous.
The model and the program must never make an edibility claim in any output.
See `docs/decisions/0002-no-edibility-classification.md`.
_Avoid_: safety call, mushroom verdict

## The program

**Forest walk area**
A forest range selected for a walk, with a mapped walking trail crossing the range.
This listing signal does not prove permission to enter; the user must check current local access before the walk.
_Avoid_: forest stand as destination, guaranteed access

**Trip card**
The Polish page that the user takes outside.
The trip card shows forest walk areas, possible species, distances, and entry information.

**Fact block**
The structured forest data collected for a trip card. The program sends the fact block to the model.

**Hard fact**
A value from BDL or a value that the program computes from BDL data and the user location.
The program can trace a hard fact to the source data.

**Soft advice**
A suggestion from the model. The program cannot trace soft advice to the source data and marks soft advice as a suggestion.

**Possible species**
A plant or a mushroom that the model expects at the site. A possible species is a name only.
It carries no statement about edibility.
_Avoid_: candidate species, edible mushroom
