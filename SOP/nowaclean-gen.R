#' ---
#' title: 'Nowaclean outlier removal report'
#' author: 'Nikita Shvetsov'
#' output: html_document
#' ---

#+ init-params, include=FALSE
params <- list(path='', experiment='')
params$ts <- format(Sys.time(), "%d%m%Y-%H%M%OS3")
#'

#' # Edit those parameters for the script
#+ params-set-up, eval=FALSE
params$path <- "/project/tice/pippelinen/nowaclean_outliers"
params$experiment <- "prospective_breast_cancer_run2"
params$script <- "nowaclean-gen.R"
params$overviewVars <- c("RIN", "_260_280_RNA", "_260_230_RNA", "ng_ul_RNA") # Check names of overview dataframe!
# c("RIN", "260/280_RNA", "260/230_RNA", "ng/µl_RNA")

# Not eligible outlier from Hege report
params$nonElSamples <- c()
#'

#' ***

#' ## Including nessessary libraries
#+ libr-include, message=FALSE, eval=FALSE
library(nowaclean)
library(nowac)
library(lumi)
require(methods)
#'

#+ functions, include=FALSE
# outlierObj <- setClass("OutlierCandidate", slots = c(sample="character", descr="character"))
# outlierObj <- list(sample="", descr="")

# make outlier object list from list of samples
mkOutlierObjList <- function(samples, defDescr=""){
  outlObjList <- list()
  for (i in samples)
  {
    obj <- list(sample = i, descr = defDescr, plot = NULL)
    outlObjList[[i]] <- obj
  }
  return (outlObjList)
}

getOutlierNames <- function(outlCandList){
  vec <- c()
  for (i in outlCandList)
  {
    vec <- c(vec, i$sample)
  }
  return (vec)
}

getLabInfo <- function(experiment){
  dataset = paste0(experiment, "_overview")
  labinfo <- get(dataset)
  return (labinfo)
}

getLabInfoBySample <- function(sID, experiment, sameAsThreshhold){
  if (!is.null(params$overviewVars)){
  labinfo <- getLabInfo(experiment)
  result <- labinfo[labinfo$Sample_ID == as.character(sID), ]
  if (sameAsThreshhold) result <- result[, params$overviewVars]
  return (result)
  }
  else 
  {
    return ("No lab info was found for that dataset.")
  }
}

removeBloodTypeProbes <- function(ge){
  ge <- ge[!rownames(ge) %in% blood_probes(), ]
  return (ge)
}

removeOutliers <- function(sID, ge){
  if (length(sID) != 0 && any(sampleNames(ge) %in% sID)) {
    out_ge <- ge[,-which(sampleNames(ge) %in% sID)]
    return (out_ge)
  }
  else return (ge)
}

readTF <- function(strprmt){
  n <- readline(prompt=strprmt)
  n <- tolower(n)
  if (n == 'yes' || n == 'y')
    return (T)
  else if (n == 'no' || n == 'n')
    return (F)
  else
    n <- readTF(strprmt)
}

readS <- function(strprmt){
  n <- readline(prompt=strprmt)
  n <- tolower(n)
  if (n == 'ro' || n == 'btp' || n == '') {
    return (n)
  } else n <- readS(strprmt)
}

readComment <- function(){
  n <- readline(prompt="Please write a comment: ")
  return (n)
}
#'

#+ load-data, include=FALSE, eval=FALSE
# load(path)
work_data = get(paste0(params$experiment, "_lobj"))
#'

#' ## Removing blood type probes (38 probes related to genes in HLA)
#+ remove-blood-type, eval=FALSE
gene_expression <- work_data
gene_expression_wo_blood_type <- removeBloodTypeProbes(work_data)
#'

#' ## Finding "0" outliers
#+ remove-zero-outliers, eval=FALSE
zero_outl_obj <- 
  mkOutlierObjList(colnames(gene_expression[, which(apply(gene_expression, 2, function(x) all(x==0)))]), 
                   defDescr = 'Known "all-zero" outlier')
#'

#' ## Finding probes with negative values (prevents log2 transformation for futher analysis)
#+ remove-negative-probes, eval=FALSE
gene_expression <- gene_expression[, which(apply(gene_expression, 2, function(x) !any(x<0)))]
#'

#' ## Checking non-eligible samples
#+ out-non-eligible-var, eval=FALSE
out_non_eligible_obj <- 
  mkOutlierObjList(params$nonElSamples, defDescr = 'Not eligible outlier')
#'
#' ## Removing non-eligible samples and "0" outliers
#+ intermediate-removal, eval=FALSE
for_removal_obj <- unique(c(out_non_eligible_obj, zero_outl_obj))
gene_expression <- removeOutliers(getOutlierNames(for_removal_obj), gene_expression)  

#'
#' ## Searching for technical outliers (if enabled)
#+ tech_outliers_investigation, eval=FALSE, include=FALSE
choiceTech <- readTF('Do you want to perform technical outliers search procedure? (yes/no): ')
if (choiceTech == T)
{
  another_round <- T
  
  while (another_round == T) {
    
    # PCA #-------
    expression <- log2(t(exprs(gene_expression)))
    prc_all <- prcout(expression) # PCA outlier detection
    # plot(prc_all)
    
    pca_outliers <- predict(prc_all, sdev=3)
    # pca_outliers
    
    # boxplots #-------
    boxo <- boxout(expression)
    # plot(boxo)
    
    boxplot_outliers <- predict(boxo, sdev=3)
    # boxplot_outliers
    
    # MA-plot #-------
    maout <- mapout(expression)
    # plot(maout, nout=5, lineup=T)
    
    mapoutliers <- predict(maout, sdev=3)
    # mapoutliers
    
    # Sum all outliers and check frequency
    table(c(mapoutliers, boxplot_outliers, pca_outliers))
    cand_outliers_obj <- mkOutlierObjList(unique(c(mapoutliers, boxplot_outliers, pca_outliers)))
    
    print ("Outlier candidates:")
    print (getOutlierNames(cand_outliers_obj))
    
    # Expression densities for samples with outliers
    densities <- dens(expression)
    # plot(densities, main='Expression densities', highlight=getOutlierNames(cand_outliers_obj))
    
    # Examine candidates for technical outliers
    # =========================================
    
    tech_outl_obj <- list()
    # labInfo <- getLabInfo(params$experiment)
    # Outliers candidates: "138115" "113785" "104917" "137771" "146176" "130922" "127496" "132675"
    for (i in 1:length(cand_outliers_obj)){
      cat ('\n')
      print ("------------------")
      print (paste("Sample:", cand_outliers_obj[[i]]$sample, " - Thresholds: "))
      print (getLabInfoBySample(cand_outliers_obj[[i]]$sample, params$experiment, T))
      print ("Lab thresholds:")
      print (lab_thresholds)
      print ("------------------")
      highlight(cand_outliers_obj[[i]]$sample, pca=prc_all, box=boxo, dens=densities, ma=maout)
      cand_outliers_obj[[i]]$plot <- recordPlot()
      choice <- readTF("Enter if it is an outlier (yes/no): ")
      cand_outliers_obj[[i]]$descr <- readComment()
      if (choice) {
        idx <- as.numeric(length(tech_outl_obj) + 1)
        tech_outl_obj[[idx]] <- cand_outliers_obj[[i]]
      }
      else {
        cat (paste("Omitting outlier:",  cand_outliers_obj[[i]]$sample, '\n'))
        cat ('\n')
      }
    }
    
    Sys.sleep(3)
    cat ('\n')
    print ("============Summary for round============")
    print ("Candidates:")
    print (getOutlierNames(cand_outliers_obj))
    print ("Found outliers:")
    print (getOutlierNames(tech_outl_obj))
    print ("============-----------------============")
    cat ('\n')
    
    # Plot, save outliers, save cleaned data
    prc_all <- prcout(expression) # PCA outlier detection
    plot(prc_all, highlight=getOutlierNames(tech_outl_obj))
    # 5 Sum up "0", non-eligable and technical outliers
    for_removal_obj <- unique(c(for_removal_obj, tech_outl_obj, out_non_eligible_obj, zero_outl_obj))
    
    print ("Found outlier names (tech, zero and non-eligible):")
    print (getOutlierNames(for_removal_obj))
    
    print ("Dataset params before this round outlier removal: ")
    print (dim(gene_expression))
    
    # Remove outliers
    gene_expression <- removeOutliers(getOutlierNames(for_removal_obj), gene_expression)
    
    print ("Dataset params after this round outlier removal: ")
    print (dim(gene_expression))
    
    another_round <- readTF("Do you want to perform another round of technical outlier removal? (yes/no): ")
  }
}
#'

#+ naming-setup, include=FALSE
# used for .rds and .html files
path_outl <- file.path(params$path, 'outliers', paste0('outliers', '-', params$experiment, '-', params$ts))
path_report <- file.path(params$path, 'reports', paste0('report-outliers', '-', params$experiment, '-', params$ts))
path_data <- file.path(params$path, paste0('ge-data', '-', params$experiment, '-', params$ts))
#'

#' ## Saving dataset with removed outliers (optional)
#+ removing-tech-outliers, eval=FALSE
choiceSave <- readS("Save dataset with removed outliers ('ro'), save only without blood type probes ('btp') or skip?: ")
if (choiceSave == 'ro') {
  
  print (paste0("Saving dataset with removed outliers to ", paste0(path_data,"-wo_outl.rds"), ' ...'))
  saveRDS(gene_expression, file=paste0(path_data,"-wo_outl.rds"))
} else if (choiceSave == 'btp') {
  print (paste0("Saving dataset with removed blood type probes ", paste0(path_data, "-wo_btp.rds"), ' ...'))
  saveRDS(gene_expression_wo_blood_type, file=paste0(path_data, "-wo_btp.rds"))
} else {
  print ("Skipping the dataset save step ...")
}
#'


#' ## Saving found outliers
#+ save-found-outl, eval=FALSE, include=FALSE
saveRDS(getOutlierNames(for_removal_obj), file=paste0(path_outl, ".rds"))
#'

#' ## Dataset and outliers information
#+ loading-vars, echo=FALSE, eval=FALSE, include=FALSE

# # Saving objects
# rem_data <- file.path(params$path, paste0(params$experiment, "_outliers_removed.Rdata"))
# save(gene_expression, for_removal_obj, file=rem_data)

# saveRDS(for_removal_obj, file="./report_outl_full.rds")
# saveRDS(gene_expression, file="./report_ge.rds")

# # Loading objects
# for_removal_obj <- readRDS('./report_outl_full.rds')
# gene_expression <- readRDS('./report_ge.rds')
# 
# # Deleting objects
# file.remove('./report_outl_full.rds')
# file.remove('./report_ge.rds')
#'

#+ report-print, echo=FALSE, comment=''
if (length(for_removal_obj) != 0){
  print (paste0("Final dimension of the dataset: ", as.character(dim(gene_expression)[1]), ' x ' ,as.character(dim(gene_expression)[2])))
  print ("All found outliers:")
  for (i in 1:length(for_removal_obj)) {
    print (paste0("Sample: ", for_removal_obj[[i]]$sample))  
    cat (paste0("Description: ",for_removal_obj[[i]]$descr, '\n'))  
    if (!is.null(for_removal_obj[[i]]$plot)) {
      plot(1:i) # Ad-hoc showing plot
      replayPlot(for_removal_obj[[i]]$plot)
      cat('\n')
    } else {
      cat ('No plot is available')
      cat (paste0('\n','\n'))
    }
  }
}
#' 

#+ render, include=FALSE, eval=FALSE
library(rmarkdown)
rmarkdown::render(params$script, output_file = paste0(path_report, '.html'), quiet = FALSE)
#'

#+ cleaning-proc, include=FALSE, eval=FALSE
# `rmarkdown::render('script.R')`
# sessionInfo()
rm(list=ls())
#'
