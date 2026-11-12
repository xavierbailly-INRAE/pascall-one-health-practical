# PASCALL 2020 | v1.2 | WHEN GENETIC TIME AND CALENDAR TIME DISAGREE
# M2 ONE HEALTH | 55-60 MINUTES | Execute ONE numbered block at a time.
# Before class: 00_install_check.R then RUN_R_CHECKS.R.
# Normal route: LIVE R calculations. NO automatic substitution with cached results.
# Explicit rescue: Pascall_rescue.R or docs/Pascall_offline_EN.html.

# BLOCK 1 - OBSERVATIONS AND SAMPLING (8 min) -----------------------------
source('R/housekeeping.R',local=TRUE)
check_required(c('ape','phytools','treedater'))
verify_inputs()
set.seed(20261112)
dir.create('runs',showWarnings=FALSE)
run_dir <- tempfile('live_',tmpdir='runs'); dir.create(run_dir)
cat('DATA SOURCE: LIVE R INFERENCE\n')
Pascall_data <- read.csv('data/metadata.csv',stringsAsFactors=FALSE)
Pascall_alignment <- ape::read.dna('data/alignment.fasta',format='fasta')
Pascall_ML <- ape::read.tree('data/ml_F84_I_G_164.nwk')
Pascall_data$year <- decimal_year(Pascall_data$Date_av)
Pascall_data$outbreak <- factor(ifelse(Pascall_data$year<2010,'first','second'),
                                levels=c('first','second'))
Pascall_sampling_time <- setNames(Pascall_data$year,Pascall_data$ID)
Pascall_seqlen <- ncol(Pascall_alignment)  # Measured: 18079, NOT hard-coded 18076.
stopifnot(nrow(Pascall_data)==164L, !anyDuplicated(Pascall_data$ID),
          !anyNA(Pascall_data$year),
          setequal(rownames(Pascall_alignment),Pascall_data$ID),
          setequal(Pascall_ML$tip.label,Pascall_data$ID))
head(Pascall_data[,c('ID','Date_min','Date_max','Date_av','country')])
print(dim(Pascall_alignment)); print(table(Pascall_data$outbreak))
print(table(Pascall_data$country,Pascall_data$outbreak))
# Date_av is supplied as a representative date, not always an exact collection date.
# Preserve the raw date bounds. UKG07159 has an invalid upper bound (2007-02-30).
invalid_max <- is.na(as.Date(Pascall_data$Date_max,format='%Y-%m-%d'))
print(Pascall_data[invalid_max,c('ID','Date_min','Date_max','Date_av')])
begin_plot('01_sampling')
barplot(table(factor(floor(Pascall_data$year),levels=2006:2018)),
        las=2,xlab='Sampling year',ylab='Number of sequences (NOT incidence)',
        main='Observed sampling: two separated periods')
end_plot()
# Q1. What was sampled, and when? Does a missing sampled year establish absence of infection?
# This teaching alignment contains segments 1-7, 9 and 10. Segment 8 remains excluded.

# BLOCK 2 - ROOT THE SUPPLIED ML TREE (10 min) ----------------------------
# The selected tree is the old practical's tree 32: run 16, F84+I+Gamma.
# We supply the ML estimate; we do not rerun PhyML during this session.
Pascall_unrooted <- ape::unroot(Pascall_ML)
roots <- list(
  rtt=ape::rtt(Pascall_unrooted,
      tip.dates=Pascall_sampling_time[Pascall_unrooted$tip.label],
      objective='correlation',opt.tol=1e-10,ncpu=1),
  midpoint=phytools::midpoint_root(Pascall_ML)
)
rooting <- 'rtt'  # Optional comparison: 'midpoint'; rerun blocks 2-5 after changing it.
if (!rooting %in% names(roots)) stop('Choose rtt or midpoint.')
Pascall_tree <- ape::ladderize(roots[[rooting]])
i <- match(Pascall_tree$tip.label,Pascall_data$ID)
cohort <- Pascall_data$outbreak[i]
begin_plot('02_rooted_tree')
plot(Pascall_tree,show.tip.label=FALSE,main=paste('ML tree | root:',rooting))
ape::tiplabels(pch=ifelse(cohort=='first',1,17),cex=0.65)
ape::add.scale.bar(length=0.0005)
legend('topleft',c('2006-2009','2015-2018'),pch=c(1,17),bty='n',cex=0.8)
mtext('Branch lengths: substitutions/site. This is not yet a dated tree.',1,2.5,cex=0.8)
end_plot()
# Q2. Where are the later samples? Does rooting convert substitutions into years?
# This retains the old TP's all-date rooting. The article used first-outbreak rooting.

# BLOCK 3 - CALCULATE TEMPORAL SIGNAL, NOT JUST A P-VALUE (12 min) ---------
year <- Pascall_sampling_time[Pascall_tree$tip.label]
distance <- ape::node.depth.edgelength(Pascall_tree)[seq_len(ape::Ntip(Pascall_tree))]
rtt_data <- data.frame(ID=Pascall_tree$tip.label,year=unname(year),
                       distance=distance,outbreak=cohort)
fit_all <- lm(distance ~ year,data=rtt_data)
fit_first <- lm(distance ~ year,data=rtt_data,subset=outbreak=='first')
fit_second <- lm(distance ~ year,data=rtt_data,subset=outbreak=='second')
clock_diagnostic <- data.frame(group=c('pooled','first','second'),
  slope=c(coef(fit_all)[2],coef(fit_first)[2],coef(fit_second)[2]),
  descriptive_R2=c(summary(fit_all)$r.squared,summary(fit_first)$r.squared,
                    summary(fit_second)$r.squared),row.names=NULL)
print(clock_diagnostic)
begin_plot('03_clock_pooled')
plot(rtt_data$year,rtt_data$distance,pch=ifelse(cohort=='first',1,17),
     xlab='Sampling year',ylab='Root-to-tip distance (substitutions/site)',
     main='One pooled line: what might it hide?')
abline(fit_all,lwd=2)
legend('topleft',c('2006-2009','2015-2018'),pch=c(1,17),bty='n')
end_plot()
begin_plot('04_clock_by_outbreak')
plot(rtt_data$year,rtt_data$distance,pch=ifelse(cohort=='first',1,17),
     xlab='Sampling year',ylab='Root-to-tip distance (substitutions/site)',
     main='Separate descriptive fits: compare slopes AND intercepts')
x_first <- seq(min(year[cohort=='first']),max(year[cohort=='first']),length.out=50)
x_second <- seq(min(year[cohort=='second']),max(year[cohort=='second']),length.out=50)
lines(x_first,predict(fit_first,newdata=data.frame(year=x_first)),lwd=2)
lines(x_second,predict(fit_second,newdata=data.frame(year=x_second)),lwd=2,lty=2)
legend('topleft',c('2006-2009','2015-2018'),pch=c(1,17),lty=c(1,2),bty='n')
end_plot()
# Q3. Can both outbreaks evolve while one continuous clock across the gap fits poorly?
# Tips share ancestry; OLS p-values and ordinary confidence intervals are not valid
# as independent evidence here. These fits are descriptive, not the article's models.
# An intercept extrapolation is not a directly observed date or a dated ancestor.

# BLOCK 4 - FIT STRICT AND RELAXED CLOCKS (15 min) ------------------------
# Same rooted input and dates for both fits. Rate unit: substitutions/site/YEAR.
# Initial rates are estimated automatically; numStartConditions requests extra starts.
# treedater may try more candidates than this number. Keep warnings visible.
Pascall_dater_strict <- treedater::dater(
  tre=Pascall_tree,sts=Pascall_sampling_time[Pascall_tree$tip.label],s=Pascall_seqlen,
  clock='strict',minblen=1/365.25,
  temporalConstraints=TRUE,numStartConditions=3,ncpu=1,quiet=FALSE)
Pascall_dater_relaxed <- treedater::dater(
  tre=Pascall_tree,sts=Pascall_sampling_time[Pascall_tree$tip.label],s=Pascall_seqlen,
  clock='uncorrelated',minblen=1/365.25,
  temporalConstraints=TRUE,numStartConditions=3,ncpu=1,quiet=FALSE)
check_dated(Pascall_dater_strict,Pascall_sampling_time)
check_dated(Pascall_dater_relaxed,Pascall_sampling_time)
# Numerical minimum branch duration: one day; NOT date precision or a biological claim.
clock_comparison <- data.frame(clock=c('strict','uncorrelated'),
  root_year=c(Pascall_dater_strict$timeOfMRCA,Pascall_dater_relaxed$timeOfMRCA),
  mean_rate=c(Pascall_dater_strict$mean.rate,Pascall_dater_relaxed$mean.rate),
  rate_CV=c(Pascall_dater_strict$coef_of_variation,
            Pascall_dater_relaxed$coef_of_variation))
print(clock_comparison)
for (model in c('strict','relaxed')) {
  td <- if (model=='strict') Pascall_dater_strict else Pascall_dater_relaxed
  begin_plot(paste0('05_dated_',model))
  ape::plot.phylo(td,show.tip.label=FALSE,main=paste('Time tree |',model,'clock'))
  marks <- pretty(range(td$timeOfMRCA,td$sts))
  axis(1,at=marks-td$timeOfMRCA,labels=marks)
  mtext('Calendar year | conditional point estimates',1,2.5,cex=0.8)
  end_plot()
}
# Q4. What changes when rates can differ between branches? Is flexibility itself proof?
# treedater's uncorrelated clock is NOT BEAST's lognormal relaxed-clock analysis.

# BLOCK 5 - IDENTIFY THE BRANCH, INTERPRET THE EVIDENCE (15 min) -----------
td <- Pascall_dater_relaxed
late_ids <- Pascall_data$ID[Pascall_data$outbreak=='second']
late_node <- ape::getMRCA(td,late_ids)
stopifnot(ape::is.monophyletic(td,late_ids))
stem_edge <- which(td$edge[,2]==late_node)
stopifnot(length(stem_edge)==1L)
# Native branch-rate estimates are omegas. edge.p contains diagnostic probabilities.
branch_rates <- td$omegas
stopifnot(length(branch_rates)==nrow(td$edge),all(branch_rates>0))
begin_plot('06_branch_rates')
phytools::plotBranchbyTrait(plain_phylo(td),log10(branch_rates),mode='edges',
    show.tip.label=FALSE,legend=TRUE,prompt=FALSE,
    title='log10 rate: substitutions/site/year')
end_plot()
# Keep this edge order. Ladderizing without realigning rates could miscolour branches.
node_year <- td$timeOfMRCA + ape::node.depth.edgelength(td)
branch_table <- data.frame(parent=td$edge[,1],child=td$edge[,2],
  start_year=node_year[td$edge[,1]],end_year=node_year[td$edge[,2]],
  duration_years=td$edge.length,genetic_length=td$intree$edge.length,
  fitted_rate=branch_rates,diagnostic_CDF=td$edge.p)
print(branch_table[stem_edge,])
cat('Stem rate / median fitted branch rate:',
    branch_rates[stem_edge]/median(branch_rates),'\n')
# Q5. Separate: (a) observed pattern, (b) model-dependent inference, (c) causal hypothesis.
# Compare your result with the ARTICLE's Fig. 3, not with a fabricated expected value.
# These data alone do not identify a particular source of reintroduction.
# Conclude with one supported finding, one limitation and one additional evidence need.

lesson <- list(source='NATIVE R: ape + treedater + phytools',version='1.2',
  metadata=Pascall_data,alignment_length=Pascall_seqlen,ml=Pascall_ML,roots=roots,
  rooting=rooting,rooted=Pascall_tree,rtt_data=rtt_data,
  diagnostic=clock_diagnostic,strict=Pascall_dater_strict,relaxed=Pascall_dater_relaxed,
  clock_comparison=clock_comparison,branch_table=branch_table,stem_edge=stem_edge,
  input_md5=read.csv('data/INPUT_MD5.csv',stringsAsFactors=FALSE))
saveRDS(lesson,file.path(run_dir,'lesson.rds'))
write.csv(rtt_data,file.path(run_dir,'root_to_tip.csv'),row.names=FALSE)
write.csv(clock_diagnostic,file.path(run_dir,'clock_diagnostic.csv'),row.names=FALSE)
write.csv(clock_comparison,file.path(run_dir,'clock_comparison.csv'),row.names=FALSE)
write.csv(branch_table,file.path(run_dir,'branch_rates.csv'),row.names=FALSE)
ape::write.tree(plain_phylo(td),file.path(run_dir,'dated_relaxed.nwk'),digits=12)
writeLines(c(lesson$source,paste('rooting:',rooting),capture.output(sessionInfo())),
           file.path(run_dir,'provenance.txt'))
writeLines(run_dir,'runs/latest_run.txt')
cat('Live results saved in:',run_dir,'\n')
