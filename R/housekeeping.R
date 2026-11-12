# Output management and integrity checks only. Scientific calls stay in the main script.
if (dir.exists('.R-library')) .libPaths(c(normalizePath('.R-library'), .libPaths()))
check_required <- function(pkgs) {
  missing <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly=TRUE)]
  if (length(missing)) stop('Install packages before class: ', paste(missing,collapse=', '),
                            '. Run 00_install_check.R. No automatic rescue.')
}
decimal_year <- function(x) {
  d <- as.Date(x, format='%Y-%m-%d'); y <- as.integer(format(d,'%Y'))
  lo <- as.Date(paste0(y,'-01-01')); hi <- as.Date(paste0(y+1L,'-01-01'))
  y + as.numeric(d-lo)/as.numeric(hi-lo)
}
verify_inputs <- function() {
  expected <- read.csv('data/INPUT_MD5.csv', stringsAsFactors=FALSE)
  if (!all(file.exists(expected$file))) stop('Extract the COMPLETE project folder.')
  actual <- unname(tools::md5sum(expected$file))
  if (!identical(actual, expected$md5)) stop('Input checksum mismatch. Restore the released data.')
  invisible(TRUE)
}
plain_phylo <- function(x) {
  keep <- intersect(c('edge','edge.length','tip.label','Nnode','node.label','root.edge'),names(x))
  z <- x[keep]; class(z) <- 'phylo'; z
}
plot_state <- new.env(parent=emptyenv())
begin_plot <- function(name, width=10, height=7) {
  plot_state$name <- name; plot_state$width <- width; plot_state$height <- height
  grDevices::pdf(file.path(run_dir,paste0(name,'.pdf')),width=width,height=height)
  grDevices::dev.control(displaylist='enable')
  graphics::par(mar=c(5,4.6,3.5,1.2), las=1)
}
end_plot <- function() {
  p <- grDevices::recordPlot(); grDevices::dev.off()
  grDevices::png(file.path(run_dir,paste0(plot_state$name,'.png')),
                width=plot_state$width, height=plot_state$height, units='in',res=160)
  grDevices::replayPlot(p); grDevices::dev.off()
  if (interactive()) {
    if (grDevices::dev.cur()==1L) grDevices::dev.new()
    grDevices::replayPlot(p)
  }
  invisible(NULL)
}
check_dated <- function(td, times) {
  stopifnot(inherits(td,'treedater'), is.finite(td$loglik), is.finite(td$mean.rate),
            td$mean.rate>0, setequal(td$tip.label,names(times)),
            all(is.finite(td$edge.length)), all(td$edge.length>=-1e-8),
            length(td$omegas)==nrow(td$edge), all(is.finite(td$omegas)), all(td$omegas>0),
            identical(td$edge,td$intree$edge), identical(td$tip.label,td$intree$tip.label))
  z <- times[td$tip.label] - ape::node.depth.edgelength(td)[seq_len(ape::Ntip(td))]
  if (max(abs(z-median(z)))>1e-5) stop('Dated tips do not match supplied sample times.')
  if (abs(median(z)-td$timeOfMRCA)>1e-5) stop('Inconsistent root date in treedater object.')
  invisible(TRUE)
}

# Provenance and numerical validation also apply when loading a saved result.
code_hashes <- function() {
  paths <- c('Pascall_student.R','R/housekeeping.R','RUN_R_CHECKS.R')
  data.frame(file=paths,md5=unname(tools::md5sum(paths)),stringsAsFactors=FALSE)
}
validate_native_cache <- function(z) {
  tryCatch({
    stopifnot(identical(z$source,'NATIVE R: ape + treedater + phytools'),
      identical(z$version,'1.2'),
      identical(z$input_md5,read.csv('data/INPUT_MD5.csv',stringsAsFactors=FALSE)),
      identical(z$code_md5,code_hashes()),
      is.data.frame(z$validation),nrow(z$validation)==13L,
      !anyDuplicated(z$validation$test),all(z$validation$passed),
      nrow(z$metadata)==164L,!anyDuplicated(z$metadata$ID),
      z$alignment_length==18079L)
    times <- setNames(decimal_year(z$metadata$Date_av),z$metadata$ID)
    check_dated(z$strict,times);check_dated(z$relaxed,times)
    b <- z$branch_table;td <- z$relaxed
    stopifnot(nrow(b)==nrow(td$edge),all(is.finite(b$fitted_rate)),
      all(b$fitted_rate>0),identical(b$parent,td$edge[,1]),
      identical(b$child,td$edge[,2]),
      isTRUE(all.equal(b$fitted_rate,td$omegas)),
      all(is.finite(td$edge.p)),all(td$edge.p>=0 & td$edge.p<=1),
      all(is.finite(z$clock_comparison$mean_rate)),
      all(z$clock_comparison$mean_rate>0))
    late <- z$metadata$ID[z$metadata$outbreak=='second']
    stopifnot(ape::is.monophyletic(td,late),
      identical(z$stem_edge,which(td$edge[,2]==ape::getMRCA(td,late))))
  },error=function(e) stop('Invalid or outdated native cache. Run RUN_R_CHECKS.R again.',call.=FALSE))
  invisible(TRUE)
}
