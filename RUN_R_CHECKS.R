local({
# Full native integration check, not a replacement for the student blocks.
# Creates a native rescue snapshot ONLY after successful execution and checks.
# Invalidate the previous result BEFORE dependency/input checks can fail.
dir.create('validation',showWarnings=FALSE)
ready_file <- 'validation/NATIVE_READY.txt'
unlink(c(ready_file,'validation/native_tests.csv'))
native <- 'rescue/native'
if (file.exists(file.path(native,'lesson.rds'))) {
  history <- tempfile('previous_',tmpdir='rescue')
  if (!file.rename(native,history)) stop('Cannot archive the previous native cache.')
}
dir.create(native,recursive=TRUE,showWarnings=FALSE)
before_devices <- grDevices::dev.list()
before_sink <- sink.number()
con <- file('validation/native_run.log',open='wt')
sink(con,split=TRUE)
tryCatch({
  source('R/housekeeping.R',local=TRUE)
  check_required(c('ape','phytools','treedater'));verify_inputs()
  e <- new.env(parent=globalenv())
  withCallingHandlers(sys.source('Pascall_student.R',envir=e),
    warning=function(w) cat('RECORDED WARNING:',conditionMessage(w),'\n'))
  z <- e$lesson
  check_dated(z$strict,e$Pascall_sampling_time)
  check_dated(z$relaxed,e$Pascall_sampling_time)
  cp0 <- ape::cophenetic.phylo(z$ml)
  cp1 <- ape::cophenetic.phylo(z$rooted)
  cp1 <- cp1[rownames(cp0),colnames(cp0)]
  fits <- list(pooled=e$fit_all,first=e$fit_first,second=e$fit_second)
  required_figures <- paste0(c('01_sampling','02_rooted_tree','03_clock_pooled',
    '04_clock_by_outbreak','05_dated_strict','05_dated_relaxed','06_branch_rates'),'.pdf')
  passed <- c(n_samples=nrow(z$metadata)==164,
    alignment_length=z$alignment_length==18079,
    tip_identity=setequal(z$metadata$ID,z$rooted$tip.label),
    root_distances_invariant=max(abs(cp0-cp1))<1e-9,
    cohort_sizes=identical(as.integer(table(z$metadata$outbreak)),c(95L,69L)),
    fits_finite=all(vapply(fits,function(f)all(is.finite(coef(f))),logical(1))),
    strict_single_rate=diff(range(z$strict$omegas))<1e-12,
    late_clade=ape::is.monophyletic(z$relaxed,z$metadata$ID[z$metadata$outbreak=='second']),
    stem_unique=length(z$stem_edge)==1L,
    rates_positive=all(z$branch_table$fitted_rate>0),
    valid_diagnostic_probabilities=all(is.finite(z$relaxed$edge.p)) &&
      all(z$relaxed$edge.p>=0 & z$relaxed$edge.p<=1),
    figures_written=all(file.exists(file.path(e$run_dir,required_figures))),
    lesson_written=file.exists(file.path(e$run_dir,'lesson.rds')))
  write.csv(data.frame(test=names(passed),passed=unname(passed)),
            'validation/native_tests.csv',row.names=FALSE)
  if (!all(passed)) stop('Native check failed: ',paste(names(passed)[!passed],collapse=', '))
  z$validation <- data.frame(test=names(passed),passed=unname(passed))
  z$code_md5 <- code_hashes()
  validate_native_cache(z)
  saveRDS(z,file.path(e$run_dir,'lesson.rds'))
  native <- 'rescue/native';dir.create(native,recursive=TRUE,showWarnings=FALSE)
  if (file.exists(file.path(native,'lesson.rds'))) {
    history <- tempfile('previous_',tmpdir='rescue'); dir.create(history)
    file.copy(list.files(native,full.names=TRUE),history,overwrite=FALSE)
  }
  stopifnot(file.copy(file.path(e$run_dir,'lesson.rds'),file.path(native,'lesson.rds'),overwrite=TRUE))
  figures <- list.files(e$run_dir,pattern='\\.(pdf|png)$',full.names=TRUE)
  stopifnot(all(file.copy(figures,native,overwrite=TRUE)))
  writeLines(c('Native R rescue; input hashes stored in lesson.rds.',
    capture.output(sessionInfo())),file.path(native,'PROVENANCE.txt'))
  if (file.exists('validation/native_error.txt')) file.remove('validation/native_error.txt')
  writeLines(c('READY: complete native R path executed and validated.',
    paste('Run directory:',e$run_dir),capture.output(sessionInfo())),ready_file)
  cat('\nREADY: native R checks passed. Native rescue snapshot created.\n')
},error=function(err) {
  unlink(c(ready_file,file.path(native,'lesson.rds')))
  writeLines(conditionMessage(err),'validation/native_error.txt')
  stop('NOT READY: ',conditionMessage(err),call.=FALSE)
},finally={
  for (id in setdiff(grDevices::dev.list(),before_devices)) grDevices::dev.off(id)
  while(sink.number()>before_sink) sink()
  close(con)
})

})
