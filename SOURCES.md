# Sources and attribution — Pascall practical v1.1

## Scientific basis supplied by the instructor
Pascall DJ, Nomikou K, Bréard E, et al. (2020). “Frozen evolution” of an RNA virus suggests accidental release as a potential cause of arbovirus re-emergence. PLOS Biology 18(4):e3000673. DOI: 10.1371/journal.pbio.3000673.
https://doi.org/10.1371/journal.pbio.3000673

The article is CC BY. Figures 3 and 4B are cropped, not redrawn, from the instructor-supplied PDF. They remain published BEAST/ML results, not outputs of this teaching analysis. The source article PDF is included for context. All historical statements refer to the 2020 study, not to current BTV epidemiology.

Original teaching support: Pascall_analysis_2025.pdf (internal heading Pascall_analysis_2024.pdf), 12 pages, supplied by Xavier Bailly. The source data and the original PhyML outputs are preserved byte-for-byte in the instructor pack.

## Software documentation checked 12 November 2026
ape rtt: https://search.r-project.org/CRAN/refmans/ape/html/rtt.html
ape package reference: https://cran.r-project.org/package=ape
phytools plotBranchbyTrait: https://search.r-project.org/CRAN/refmans/phytools/html/plotBranchbyTrait.html
phytools midpoint_root: https://search.r-project.org/CRAN/refmans/phytools/html/midpoint.root.html
treedater reference: https://cloud.r-project.org/web/packages/treedater/refman/treedater.html
treedater primary implementation: https://github.com/emvolz/treedater/blob/master/R/treedater0.R

Volz EM and Frost SDW (2017). Scalable relaxed clock phylogenetic dating. Virus Evolution 3(2):vex025. DOI: 10.1093/ve/vex025.

Software APIs were inspected; native R execution was NOT possible in the preparation environment. A source check is not a runtime test. The actual locally installed versions are recorded by the full check.

## Explicit teaching adaptations (not results from the article)
- Five short blocks; ML estimation supplied, rooting and clock inference visible in the normal R route.
- The provided 164 × 18079 alignment is an exact concatenation of segments 1–7, 9 and 10. Segment 8 remains excluded as in the original practical. No missing sequence is invented.
- The original length constant 18076 is replaced by the measured alignment length. No sequence is trimmed to force that constant.
- Tree 32 is retained and mapped to run 16, F84+I+Gamma. All 56 tree records occur as 28 exact duplicate pairs, not as bootstrap replicates. AIC is reconstructed from the supplied log likelihoods using the ape::phymltest parameter-count convention; a constant common branch-length contribution is omitted. This is a comparison of stored runs, not a fresh global optimum search.
- Date_av values are retained. UKG07159 has the invalid original upper bound 2007-02-30. Its date is not corrected or guessed. Only the optional fixed-root bound sensitivity excludes this record consistently across all conventions.
- All-date RTT rooting follows the original practical; the article's first-outbreak root is not reproduced. Midpoint rooting is an explicit sensitivity comparison.
- Ordinary within-outbreak OLS is a descriptive teaching addition. No OLS p-values or conventional confidence intervals are used as independent phylogenetic evidence. The paper used a gamma model with identity link and a Bayesian follow-up.
- Times are expressed in decimal years, not elapsed days. treedater uncorrelated clock estimates are not the article's BEAST lognormal posterior.
- omegas is used for branch rates. edge.p is a diagnostic cumulative probability, not a rate. Edge order is preserved.
- Causal source attribution is qualified: the paper explicitly says the actual source was not established and the proposed link was speculative (pp. 8–9).
- Optional lineages-through-time counts refer to the sampled genealogy, not incidence, prevalence or effective population size. Parametric bootstrap remains opt-in.
