# Validation report — Pascall v1.1

Executed:
- 16 source-file hashes; 164 sample IDs and the complete 18079-position nine-segment concatenation checked.
- 28 PhyML runs mapped to 56 exact paired duplicate tree records; original selection 32 retained and identified.
- Independent Python reference rooting and OLS, plus patristic-distance checks.
- Portable regeneration in a separate directory reproduced 4 reference CSVs and 3 student input files.
- 7 R files passed a lexical delimiter/string check. This is NOT an R parser or runtime check.
- 5 authored PDFs (24 pages total) rendered; text bounds checked. Student and instructor layouts and reference figures inspected as raster images.
- Standalone browser content exercised in Chromium: five tabs, code disclosure, two root images, both OLS modes, 5-note export, all image loads, mobile 390 px layout, zero JavaScript errors and zero external requests.
- Browser OLS agreed with independent Python to < 1e-10 (largest numerical difference about 3e-14).

Browser caveat: the environment blocked file:// navigation by administrator policy. Tests loaded the exact standalone HTML with Playwright set_content; they did not establish that the environment could navigate its local file URL. No web server or network dependency is required by the delivered file.

Not executed:
- Any native R inference, package installation, native rescue replay or bootstrap.
- Native Windows/macOS classroom trials.

See JSON files in this directory for the machine-readable checks. Actual ZIP CRC/extraction/hash checks are written in the outer release manifest; do not confuse archive validity with scientific or R runtime validation.

## Finalisation check (v1.1)
Repeated the source identity checks and independent regeneration from extracted instructor tools: all seven compared files match. The repeated package-manager attempt again failed to resolve the repository host. Native R remains unexecuted. See independent_recheck.json and apt_attempt.log.
