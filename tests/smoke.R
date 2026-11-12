# Run in a disposable project copy: Rscript tests/smoke.R
source('R/housekeeping.R')
dir.create('tests/output',recursive=TRUE,showWarnings=FALSE)
checks <- list()
check <- function(name,ok) {
  checks[[length(checks)+1L]] <<- data.frame(test=name,passed=isTRUE(ok))
  if (!isTRUE(ok)) stop('FAILED: ',name)
}
initial_devices <- dev.list();initial_sink <- sink.number()
started <- proc.time()[['elapsed']]
source('RUN_R_CHECKS.R')
check('native_gate_READY',file.exists('validation/NATIVE_READY.txt'))
check('graphics_and_sink_restored',identical(dev.list(),initial_devices) && sink.number()==initial_sink)
z <- readRDS('rescue/native/lesson.rds');validate_native_cache(z)
check('13_native_checks',nrow(z$validation)==13 && all(z$validation$passed))
ref <- read.csv('reference/regression_summary.csv');cp <- ape::cophenetic.phylo(z$ml)
for (root in names(z$roots)) {
 tr <- z$roots[[root]];d <- ape::node.depth.edgelength(tr)[seq_len(ape::Ntip(tr))]
 i <- match(tr$tip.label,z$metadata$ID);year <- decimal_year(z$metadata$Date_av[i]);group <- z$metadata$outbreak[i]
 check(paste(root,'pairwise_distances'),max(abs(cp-ape::cophenetic.phylo(tr)[rownames(cp),colnames(cp)]))<1e-9)
 for (g in c('pooled','first','second')) {
  keep <- if(g=='pooled') rep(TRUE,length(year)) else group==g
  f <- lm(d[keep]~year[keep]);r <- ref[ref$rooting==root & ref$group==g,]
  check(paste(root,g,'independent_OLS'),abs(unname(coef(f)[2])-r$slope)<1e-7 && abs(summary(f)$r.squared-r$R2)<1e-5)
 }
}
for (mode in c('native','reference')) {
 options(pascall.rescue_mode=mode);pdf(paste0('tests/output/rescue_',mode,'.pdf'))
 sys.source('Pascall_rescue.R',new.env(parent=globalenv()));dev.off();check(paste(mode,'rescue'),TRUE)
}
options(pascall.rescue_mode=NULL)
e <- new.env(parent=globalenv())
invisible(list2env(list(lesson=z,Pascall_data=z$metadata,Pascall_tree=z$rooted,
 distance=z$rtt_data$distance,cohort=z$rtt_data$outbreak,Pascall_dater_relaxed=z$relaxed),envir=e))
pdf('tests/output/optional.pdf');sys.source('OPTIONAL_extensions.R',e);dev.off()
check('optional_date_sensitivity_and_lineages',TRUE)
midpoint_code <- sub("rooting <- 'rtt'","rooting <- 'midpoint'",readLines('Pascall_student.R'),fixed=TRUE)
m <- new.env(parent=globalenv());eval(parse(text=midpoint_code),m)
check('midpoint_full_route',identical(m$lesson$rooting,'midpoint'))
for (kind in c('negative_rate','old_code','unvalidated')) {
 bad <- z
 if(kind=='negative_rate'){bad$relaxed$omegas[] <- -1;bad$branch_table$fitted_rate[] <- -1}
 if(kind=='old_code')bad$code_md5$md5[1] <- 'outdated'
 if(kind=='unvalidated')bad$validation <- NULL
 check(paste('reject',kind),inherits(try(validate_native_cache(bad),silent=TRUE),'try-error'))
}
local({
 original <- readBin('data/metadata.csv','raw',file.info('data/metadata.csv')$size)
 paths <- list.files('validation',full.names=TRUE);paths <- paths[file.info(paths)$isdir==FALSE]
 backup <- lapply(paths,function(p)readBin(p,'raw',file.info(p)$size))
 on.exit({writeBin(original,'data/metadata.csv');saveRDS(z,'rescue/native/lesson.rds')
  for(i in seq_along(paths))writeBin(backup[[i]],paths[i]);unlink('validation/native_error.txt')},add=TRUE)
 cat('\n',file='data/metadata.csv',append=TRUE);err <- try(source('RUN_R_CHECKS.R'),silent=TRUE)
 check('reject_changed_input',inherits(err,'try-error'))
 check('invalidate_stale_READY',!file.exists('validation/NATIVE_READY.txt'))
 check('invalidate_stale_cache',!file.exists('rescue/native/lesson.rds'))
 check('record_preflight_error',file.exists('validation/native_error.txt'))
 check('failure_restores_graphics_and_sink',identical(dev.list(),initial_devices) && sink.number()==initial_sink)
})
check('final_graphics_and_sink_restored',identical(dev.list(),initial_devices) && sink.number()==initial_sink)
write.csv(do.call(rbind,checks),'tests/output/smoke_checks.csv',row.names=FALSE)
pkgs <- c('ape','phytools','treedater','igraph')
write.csv(data.frame(package=pkgs,version=vapply(pkgs,function(p)as.character(packageVersion(p)),character(1))),
 'tests/output/packages.csv',row.names=FALSE)
writeLines(c(R.version.string,Sys.info()[['sysname']],paste('Elapsed seconds:',proc.time()[['elapsed']]-started)),
 'tests/output/environment.txt')
cat('PASS:',length(checks),'R harness checks plus 13 native checks and two dated-tree checks.\n')
