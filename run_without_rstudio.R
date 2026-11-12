# From the extracted project: Rscript run_without_rstudio.R
args <- commandArgs(trailingOnly=TRUE)
if (any(c('--rescue','--reference') %in% args)) {
  options(pascall.rescue_mode=if ('--reference' %in% args) 'reference' else 'native')
  dir.create('runs',showWarnings=FALSE)
  grDevices::pdf(file.path('runs',paste0('rescue_',getOption('pascall.rescue_mode'),'.pdf')),
                 width=10,height=7)
  source('Pascall_rescue.R')
  grDevices::dev.off()
} else source('Pascall_student.R')
