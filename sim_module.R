library(dplyr)
library(parallel)
library(foreach)
library(doParallel)
library(zeallot)
setwd("/home/o/oespinga/kmin940/autism/functions")

args=(commandArgs(TRUE)) ## retrieve variable from the job call if any
print(args)
if( length(args)>0){
  for(k in 1:length(args)){
    eval(parse(text=args[[k]]))
  }
}
print(datanum)
print(outdir)
if( !exists("datanum") ) print("arg missing")
if( !exists("n.fam") ) print("arg missing")

RNGkind("L'Ecuyer-CMRG")
set.seed(1, kind = "L'Ecuyer-CMRG")
if (datanum > 0){
  for (i in 1:datanum){
    .Random.seed = nextRNGStream(.Random.seed)
  }
}

# clust <- makeForkCluster(4)
# clusterEvalQ(clust, {library(dplyr);RNGkind("L'Ecuyer-CMRG")})
# RNGkind("L'Ecuyer-CMRG")
# len=length(clust)
# clusterExport(clust[1], varlist=c(".Random.seed"))
# if (len>1){
#  for (i in 1:(len-1)){
#    .Random.seed = nextRNGSubStream(.Random.seed)
#    clusterExport(clust[i+1], varlist=c(".Random.seed"))
#  }
#}

#registerDoParallel(clust)
#print(getDoParWorkers())

source(file = "haplotype.R")
source(file = "genotype.R")
source(file = "offspring.R")
source(file = "pen_prob.R")
source(file = "n_rv.R")
source(file = "genetic_info_module.R")

nRV <- 10
sigma <- matrix(c(1, 0, 0.5, 0.5, 0, 1, 0.5, 0.5, 0.5, 0.5, 1, 0.5, 0.5, 0.5, 0.5, 1), 4, 4)
mu <- rep(0, 4)

## assuming loci independent
# maf_RV <- runif(nRV, 0, 0.01)

setwd("../fixed_para")

load("MAF.RData")
maf = maf_RV

load(paste0(param_file, ".RData"))

# load("Updated_Various_values1.RData")
# prs1 <- up_various_values %>%
#   cbind(PRS = rep(1, 7))
# load("Updated_Various_values2.RData")
# prs2 <- up_various_values %>%
#   cbind(PRS = rep(2, 6))
# load("Updated_Various_values3.RData")
# prs3 <- up_various_values %>%
#   cbind(PRS = rep(3, 6))
# load("Updated_Various_values4.RData")
# prs4 <- up_various_values %>%
#   cbind(PRS = rep(4, 7))
# load("Updated_Various_values5.RData")
# prs5 <- up_various_values %>%
#   cbind(PRS = rep(5, 7))
# 
# PRS <- rbind(prs1, prs2, prs3, prs4, prs5)
# PRS$PRS <- log(PRS$PRS)

setwd(outdir)

# can change
# n.fam <- 1000000
j = datanum * n.fam

# (ll_values=PRS[1,])
# est_ll = c(PRS$a.values[1], log(161/656), PRS$PRS[1], PRS$rv.values[1])
# (hh_values=PRS[33,])
# est_hh = c(PRS$a.values[33], log(161/656), PRS$PRS[33], PRS$rv.values[33])
# (lh_values=PRS[7,])
# est_lh = c(PRS$a.values[7], log(161/656), PRS$PRS[7], PRS$rv.values[7])
# (hl_values=PRS[27,])
# est_hl = c(PRS$a.values[27], log(161/656), PRS$PRS[27], PRS$rv.values[27])

# clusterExport(clust, ls())

genetic.info.all <- lapply(
  (1 + j):(n.fam + j),
  genetic_info_4,
  param_combo
) %>%
  bind_rows() %>%
  data.frame(stringsAsFactors = FALSE) %>%
  magrittr::set_rownames(1:(4*n.fam))

# can change
nam = paste0("data", datanum)

saveit <- function(..., string, file) {
  x <- list(...)
  names(x) <- string
  save(list=names(x), file=file, envir=list2env(x))
}
print(sprintf("%s/data%s.RData", outdir, datanum))
# can change data name
saveit(genetic.info.all = genetic.info.all, string = nam, file=sprintf("./data%s.RData", datanum))

