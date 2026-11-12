# Validation Pascall v1.2

Linux, 12 novembre 2026. R 4.5.2 ; versions des packages dans packages.csv.

- 13 contrôles natifs dans native_tests.csv et deux arbres datés validés.
- 24 contrôles R supplémentaires dans smoke_checks.csv : distances, OLS indépendantes, racine alternative, secours, extensions, caches invalides, échec précoce, état graphique.
- Harnais JavaScript : browser_harness.json. Les tests de logique ne remplacent pas le contrôle réel du navigateur effectué lors de la publication.
- Le cache rescue/native/lesson.rds provient du contrôle réussi ; ses données, code et valeurs numériques sont revalidés avant lecture.
- Le bootstrap optionnel de 50 répétitions n’est pas exécuté dans le TP principal.

Relancer RUN_R_CHECKS.R sur le poste de séance. READY vérifie l’exécution et la cohérence numérique, pas la validité d’une hypothèse biologique. Rapports historiques : preparation_v1.1/.
