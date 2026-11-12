# Instructor-led extensions. First execute Pascall_student.R successfully.
if (!exists('lesson') || !identical(lesson$source,'NATIVE R: ape + treedater + phytools'))
  stop('Run the live student script first. These extensions require native R estimates.')

# A. Date sensitivity at a FIXED root; this does not marginalise over date uncertainty.
lo <- decimal_year(Pascall_data$Date_min)
hi <- decimal_year(Pascall_data$Date_max)
ok <- is.finite(lo) & is.finite(hi)
if (!all(ok)) message('Invalid original bounds; excluded ONLY from this sensitivity subset: ',
                      paste(Pascall_data$ID[!ok],collapse=', '))
i <- match(Pascall_tree$tip.label,Pascall_data$ID)
keep <- ok[i]
# Use identical retained rows for each date convention.
for (convention in c('Date_min','Date_av','Date_max')) {
  x <- decimal_year(Pascall_data[[convention]])[i][keep]
  yy <- distance[keep];gg <- cohort[keep]
  f1 <- lm(yy~x,subset=gg=='first');f2 <- lm(yy~x,subset=gg=='second')
  print(data.frame(convention=convention,first_slope=unname(coef(f1)[2]),
                   second_slope=unname(coef(f2)[2])))
}

# B. Count lineages crossing time slices in the SAMPLED genealogy.
# This is NOT incidence, prevalence or a coalescent effective population size.
td <- Pascall_dater_relaxed
times <- td$timeOfMRCA + ape::node.depth.edgelength(td)
start <- times[td$edge[,1]];end <- times[td$edge[,2]]
grid <- seq(td$timeOfMRCA,max(td$sts),length.out=400)
n_lineages <- vapply(grid,function(t)sum(start<=t & t<end),integer(1))
plot(grid,n_lineages,type='s',xlab='Calendar year',ylab='Lineages in sampled genealogy',
     main='Serial sampling changes the number of represented lineages')

# C. Parametric bootstrap: opt-in only, potentially slow, not part of the core TP.
# Read ?treedater::parboot first. The cache is never faked if this fails.
# set.seed(20261112)
# Pascall_pb <- treedater::parboot(Pascall_dater_relaxed,nreps=50)
# saveRDS(Pascall_pb,file.path(run_dir,'bootstrap_relaxed.rds'))
# plot(Pascall_pb)
