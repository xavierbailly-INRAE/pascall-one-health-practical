# Run before the class, from the extracted project folder. Internet needed only here.
if (!file.exists('Pascall_student.R')) stop('Open Pascall_student.Rproj first.')
lib <- '.R-library'; dir.create(lib,showWarnings=FALSE)
.libPaths(c(normalizePath(lib),.libPaths()))
pkgs <- c('ape','phytools','treedater')
missing <- pkgs[!vapply(pkgs,requireNamespace,logical(1),quietly=TRUE)]
if (length(missing)) install.packages(missing,lib=lib,repos='https://cloud.r-project.org',
                                    dependencies=NA)
source('R/housekeeping.R');check_required(pkgs);verify_inputs()
print(data.frame(package=pkgs,version=vapply(pkgs,function(p)
  as.character(packageVersion(p)),character(1))))
cat('Packages and inputs found. This is NOT yet READY.\n')
cat('Now run RUN_R_CHECKS.R for a full native execution test.\n')
