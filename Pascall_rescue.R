# EXPLICIT RESCUE ONLY. Never called automatically from the student script.
# Choose 'native' only after RUN_R_CHECKS.R has successfully created a cache.
rescue_mode <- getOption('pascall.rescue_mode','native')  # Or explicitly 'reference'.
source('R/housekeeping.R');check_required('ape');verify_inputs()
if (rescue_mode=='native') {
  f <- 'rescue/native/lesson.rds'
  if (!file.exists(f)) stop('No native cache. Run checks or EXPLICITLY choose reference.')
  lesson <- readRDS(f)
  validate_native_cache(lesson)
  cat('SOURCE: SAVED NATIVE R RESULTS. No clock is fitted in this rescue session.\n')
  print(lesson$clock_comparison)
  print(lesson$branch_table[lesson$stem_edge,])
  ape::plot.phylo(lesson$relaxed,show.tip.label=FALSE,
                  main='SAVED NATIVE R | relaxed-clock time tree')
  marks <- pretty(range(lesson$relaxed$timeOfMRCA,lesson$relaxed$sts))
  axis(1,at=marks-lesson$relaxed$timeOfMRCA,labels=marks)
} else if (rescue_mode=='reference') {
  cat('SOURCE: PYTHON-ROOTED REFERENCE TREE + LIVE DESCRIPTIVE OLS IN R.\n')
  cat('NO NATIVE DATING CACHE: use the article for the dated-tree comparison.\n')
  rooting <- 'rtt'  # Or 'midpoint'. These are supplied reference roots, not ape::rtt results.
  tree <- ape::read.tree(paste0('reference/root_',rooting,'_python.nwk'))
  metadata <- read.csv('data/metadata.csv',stringsAsFactors=FALSE)
  i <- match(tree$tip.label,metadata$ID)
  year <- decimal_year(metadata$Date_av[i])
  distance <- ape::node.depth.edgelength(tree)[seq_len(ape::Ntip(tree))]
  first <- year<2010
  f1 <- lm(distance ~ year,subset=first);f2 <- lm(distance ~ year,subset=!first)
  plot(year,distance,pch=ifelse(first,1,17),xlab='Sampling year',
       ylab='Distance (subs/site)',main=paste('EXPLICIT REFERENCE | root:',rooting))
  for (group in c(TRUE,FALSE)) {
    x <- range(year[first==group]);fit <- if(group) f1 else f2
    lines(x,predict(fit,newdata=data.frame(year=x)),lty=if(group)1 else 2)
  }
  print(c(first_slope=coef(f1)[2],second_slope=coef(f2)[2]))
  cat('Open docs/Pascall_offline_EN.html for all five blocks and published reference figures.\n')
} else stop('Choose reference or native. No automatic fallback.')
