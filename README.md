# Pascall One Health practical

**[Ouvrir le TP dans le navigateur](https://xavierbailly-inrae.github.io/pascall-one-health-practical/)**

Parcours M2 One Health en cinq étapes, environ 60 minutes, après Biek et TiPS.
Aucune installation ni compte GitHub pour le parcours navigateur. Les consignes sont en anglais.

## Démarrer la séance

1. Ouvrir le lien du TP et parcourir les cinq onglets dans l’ordre.
2. Formuler une prédiction, examiner les résultats et rédiger une interprétation dans chaque zone de notes.
3. Utiliser **Export my notes** pour conserver le travail. Les notes restent aussi dans le navigateur lorsque son stockage est autorisé.

Le navigateur recalcule les régressions descriptives sur des racines de référence préparées en Python.
Les figures BEAST sont celles de l’article. Il n’exécute pas R et ne réestime pas les horloges.

## Réaliser les calculs dans R

[Télécharger le projet complet](https://github.com/xavierbailly-INRAE/pascall-one-health-practical/archive/refs/heads/main.zip),
extraire le ZIP dans un dossier accessible en écriture et ouvrir `Pascall_student.Rproj` dans RStudio.
Avant la séance :

```r
source("00_install_check.R")
source("RUN_R_CHECKS.R")
```

Attendre **READY**, puis exécuter `Pascall_student.R` un bloc numéroté complet à la fois.
L’installation nécessite internet ; les calculs utilisent ensuite les données locales.
Voir [les consignes étudiantes](docs/Pascall_student_EN.pdf) et [le guide d’installation](docs/Installation_EN.pdf).

Sans RStudio, depuis le dossier extrait :

```sh
Rscript 00_install_check.R
Rscript RUN_R_CHECKS.R
Rscript run_without_rstudio.R
```

Les figures et tableaux sont enregistrés dans `runs/live_*`.
Secours explicite : `Rscript run_without_rstudio.R --rescue` pour le cache R validé,
ou `Rscript run_without_rstudio.R --reference` pour les seules références descriptives.
Le HTML autonome se trouve aussi dans `docs/Pascall_offline_EN.html`.

## Validation et limites

Version **1.2**, 12 novembre 2026. Le harnais couvre le parcours natif, les deux racines,
les deux secours, les extensions, les erreurs d’entrée et les caches invalides.
Voir [les résultats locaux](validation/VALIDATION.md), [les tests R](tests/smoke.R),
[les tests JavaScript](tests/browser_harness.cjs) et [GitHub Actions](https://github.com/xavierbailly-INRAE/pascall-one-health-practical/actions).
Le bootstrap optionnel de 50 répétitions ne fait pas partie du parcours validé.

L’alignement pédagogique contient neuf segments. Ce TP n’est pas une reproduction exacte
de l’analyse de l’article sur dix segments. Il distingue observations, inférences conditionnelles
et hypothèses causales. Voir [les sources](SOURCES.md).
Les contenus et logiciels conservent leurs conditions respectives ; aucune licence globale nouvelle n’est attribuée.
