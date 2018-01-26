#' Map probes to genes.
#' 
#' @param data matrix where colnames(data)=sample IDs and rownames(data) = probe IDs
#' @return matrix where colnames(data)=sample IDs and rownames(data) = gene IDs
#' @export
mapToGenes <- function(data) {
  # --- Map to gene symbol
  nuIDs <- rownames(data)
  mappingInfo <- nuID2RefSeqID(nuIDs, lib.mapping='lumiHumanIDMapping', returnAllInfo=TRUE)
  geneName <- as.character(mappingInfo[,3])
  geneName <- geneName[geneName!=""] 
  
  # --- Compute mean of probes for each gene
  exprs0 <- data
  uGeneNames <- unique(geneName)
  exprs <- matrix(NA, ncol=ncol(exprs0), nrow=length(uGeneNames))
  colnames(exprs) <- colnames(exprs0)
  rownames(exprs) <- uGeneNames
  for (j in 1:length(uGeneNames))
    exprs[j,] <- colMeans(exprs0[mappingInfo[,3]==uGeneNames[j], ,drop=F])
  
  exprs
}


#' Perform background correction and remove bad probes.
#' 
#' @param data lumi object with gene expression matrix exprs(data) where
#'        colnames(exprs(data)) = sample IDs ( = labnr)
#'        rownames(exprs(data)) = probe IDs
#' @param negCtrl matrix where
#'        rownames(negCtrl) is a superset of colnames(exprs(data))
#'        each column in negCtrl contains expression values for a negative control probe
#' @return background-corrected lumi object where 
#'         colnames(exprs(data)) = sample IDs ( = labnr)
#'         rownames(exprs(data)) = probe IDs
#' @export
performBackgroundCorrection <- function(data, negCtrl) {
  
  ## --- Extract and transpose the expression matrix from the lumi object data
  ##     and select rows from the negCtrl matrix  
  exprs <- t(exprs(data))
  negCtrl <- negCtrl[rownames(exprs),]
  ## Now: rownames(exprs)==rownames(negCtrl) 
  
  # --- Combine data, status vector (stating for each row if it corresponds to gene or control)
  totalData <- t(cbind(exprs,negCtrl)) # neg control probes
  status <- c(rep("regular", ncol(exprs)), rep("negative", ncol(negCtrl)))
  
  # --- Background correct the probes using the limma nec function
  data.nec <- nec(totalData, status)  # this gives same result as adding detection.p.
  
  # --- Remove the negative probes from the matrix: exprs is not log2 transformed
  exprs <- t(data.nec)[,1:ncol(exprs)] # remove the values of the negative controls 
  exprs(data) <- t(exprs) # Make sure exprs of data object is background corrected
  
  # --- Get rid of bad probes
  probes <- nuID2IlluminaID(as.character(featureNames(data)), lib.mapping=NULL, species ="Human", idType='Probe')
  probe.quality <- unlist(BiocGenerics::mget(as.character(probes), illuminaHumanv3PROBEQUALITY, ifnotfound=NA))
  table(probe.quality, exclude=NULL) # check mapping and missing
  good.quality <- !((probe.quality == "Bad") | (probe.quality == "No match"))
  length(good.quality[good.quality==TRUE])
  data<-data[which(good.quality==TRUE),]
  
  rm(exprs, totalData, data.nec)
  
  data	
}


#' Filtering based on on pValue and presentLimit.
#' 
#' @param data lumi object where colnames(data)=sample IDs and rownames(data) = probe IDs
#' @param pValue p-value
#' @param presentLimit limit
#' @return filtered lumi object where colnames(data)=sample IDs and rownames(data) = probe IDs
#' @export
filterData <- function(data, pValue, presentLimit) {
  presentcall <- detectionCall(data,Th=pValue)
  filterP <- which(presentcall>(presentLimit*ncol(data)))
  data.new <- data[filterP,]
  
  data.new
}


#' Log2 transformation using a variance stabilizing technique* and quantile normalization.
#' 
#' * Lin SM, Du P, Huber W, Kibbe WA. Model-based variance-stabilizing transformation for 
#' Illumina microarray data. Nucleic Acids Res. 2008;36(2):e11.
#' 
#' @param data.new lumi object where colnames(data)=sample IDs and rownames(data) = probe IDs
#' @param method string describing the normalization method
#' @return normalized matrix where colnames(data)=sample IDs and rownames(data) = probe IDs
#' @export
normalizeData <- function(data.new, method = 'vstQuantileNorm', batchVar='Plate') {
  if (method == 'vstQuantileNorm') {
    vstdata <- lumiT(data.new, method="vst")
    Nvstdata <- lumiN(vstdata, method="quantile")
    normdata <- exprs(Nvstdata)
  } else if (method == 'ComBat') {
    stop('Method not supported.')
    # Batching according to variable
    # batch <- data.new[[batchVar]]
    # normdata <- ComBat(dat=data.new, batch=batch)
  }
  return (normdata)
}
