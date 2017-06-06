require(arrayQualityMetrics)
require(limma)
require(lumi)
require(nlme)
require(illuminaHumanv3.db)
require(illuminaHumanv4.db)
require(lumiHumanIDMapping)
require(genefilter)


## =======================================================================================
## mapToGenes
## - Map from probes to genes
## - Input: 
##     data matrix where colnames(data)=sample IDs and rownames(data) = probe IDs
## - Return value: 
##     data matrix where colnames(data)=sample IDs and rownames(data) = gene IDs
## =======================================================================================

mapToGenes <- function(data) {
  ## --- Map to gene symbol
  nuIDs <- rownames(data)
  mappingInfo <- nuID2RefSeqID(nuIDs, lib.mapping='lumiHumanIDMapping', returnAllInfo=TRUE)
  geneName <- as.character(mappingInfo[,3])
  geneName <- geneName[geneName!=""] 
  
  ## --- Compute mean of probes for each gene
  exprs0 <- data
  uGeneNames <- unique(geneName)
  exprs <- matrix(NA, ncol=ncol(exprs0), nrow=length(uGeneNames))
  colnames(exprs) <- colnames(exprs0)
  rownames(exprs) <- uGeneNames
  for (j in 1:length(uGeneNames))
    exprs[j,] <- colMeans(exprs0[mappingInfo[,3]==uGeneNames[j], ,drop=F])
  
  exprs
}


## =======================================================================================
##
## performBackgroundCorrection
## - Perform background correction and remove bad probes
## - Input: 
##     lumi object data where colnames(data)=sample IDs and rownames(data) = probe IDs
##     exprs data matrix where rownames(exprs)=sample IDs and colnames(exprs) = probe IDs
##     negCtrl matrix where rownames(exprs)=sample IDs and colnames(data) = negative control IDs
## - Return value: 
##     background corrected lumi object data where colnames(data)=sample IDs and rownames(data) = gene IDs
##
## =======================================================================================

performBackgroundCorrection <- function(data, exprs, negCtrl) {
  
  ## --- Combine data, status vector (stating for each row if it corresponds to gene or control)
  totalData <- t(cbind(exprs,negCtrl)) ## neg control probes
  status <- c(rep("regular", ncol(exprs)), rep("negative", ncol(negCtrl)))
  
  ## --- Background correct the probes using the limma nec function
  data.nec <- nec(totalData, status)  ## this gives same result as adding detection.p.
  
  ## --- Remove the negative probes from the matrix: exprs is not log2 transformed
  exprs <- t(data.nec)[,1:ncol(exprs)] ## remove the values of the negative controls 
  exprs(data) <- t(exprs) ## Make sure exprs of data object is background corrected
  
  ## --- Get rid of bad probes
  probes <- nuID2IlluminaID(as.character(featureNames(data)), lib.mapping=NULL, species ="Human", idType='Probe')
  probe.quality <- unlist(mget(as.character(probes), illuminaHumanv3PROBEQUALITY, ifnotfound=NA))
  table(probe.quality, exclude=NULL) # check mapping and missing
  good.quality <- !((probe.quality == "Bad") | (probe.quality == "No match"))
  length(good.quality[good.quality==TRUE])
  data<-data[which(good.quality==TRUE),]
  
  rm(exprs, totalData, data.nec)
  
  data	
}


## =======================================================================================
##
## Filter data 
## - Filtering on pValue and presentLimit
## - Input: 
##     lumi object data where colnames(data)=sample IDs and rownames(data) = probe IDs
##     p-value limit pValue
##     presentLimit
## - Return value: 
##     filtered lumi object data where colnames(data)=sample IDs and rownames(data) = probe IDs
##
## =======================================================================================

filterData <- function(data, pValue, presentLimit) {
  presentcall <- detectionCall(data,Th=pValue)
  filterP <- which(presentcall>(presentLimit*ncol(data)))
  data.new <- data[filterP,]
  
  data.new
}


## =======================================================================================
##
## normalize data 
## - Normalization procedure from Vanesssa
## - Input: 
##     lumi object data where colnames(data)=sample IDs and rownames(data) = probe IDs
## - Return value: 
##     normalized data matrix where colnames(data)=sample IDs and rownames(data) = probe IDs
##
## =======================================================================================

normalizeData <- function(data.new) {
  vstdata <- lumiT(data.new,method="vst")
  Nvstdata <- lumiN(vstdata,method="quantile")
  normdata <- exprs(Nvstdata)
  
  normdata
}
