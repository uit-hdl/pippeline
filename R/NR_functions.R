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
  
  return (exprs)
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
  probe.quality <- unlist(BiocGenerics::mget(as.character(probes), illuminaHumanv3PROBEQUALITY, ifnotfound=NA)) # TODO: check V4
  table(probe.quality, exclude=NULL) # check mapping and missing
  good.quality <- !((probe.quality == "Bad") | (probe.quality == "No match"))
  length(good.quality[good.quality==TRUE])
  data<-data[which(good.quality==TRUE),]
  
  rm(exprs, totalData, data.nec)
  
  return (data)
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
  return (data.new)
}


#' Log2 transformation using a variance stabilizing technique* and quantile normalization.
#' 
#' * Lin SM, Du P, Huber W, Kibbe WA. Model-based variance-stabilizing transformation for 
#' Illumina microarray data. Nucleic Acids Res. 2008;36(2):e11.
#'
#' Check also: http://journals.plos.org/plosone/article/file?id=10.1371/journal.pone.0156594&type=printable
#' 
#' @param data.new lumi object where colnames(data)=sample IDs and rownames(data) = probe IDs
#' @return normalized matrix where colnames(data)=sample IDs and rownames(data) = probe IDs
#' @export
normalizeDataVstQ <- function(data.new) {
  vstdata <- lumiT(data.new, method="vst", verbose=FALSE)
  Nvstdata <- lumiN(vstdata, method="quantile", verbose=FALSE)
  normdata <- exprs(Nvstdata)
  return (normdata)
}

#'
#' @param data.new lumi object where colnames(data)=sample IDs and rownames(data) = probe IDs
#' @param bTabName name of the table, which is used for extracting batch variable
#' @param sampleID name of column in data.new dataframe, which represents sample ID number
#' @param batchVar batch variable, i.e. vector formed from dataset, which gives batch parameter for ComBat
#' @return normalized matrix where colnames(data)=sample IDs and rownames(data) = probe IDs
#' @export
normalizeDataComBat <- function(data.new, bTabName, sampleID, batchVar) {
  # stop('Method not supported.')
  tryCatch({
    # First stabilize variance using lumiT with log2 method
    vstdata <- lumiT(data.new, method='log2', verbose=FALSE)

    batchVarsTable <- get(bTabName)[, c(sampleID, batchVar)]
    batchVarsTable <- batchVarsTable[complete.cases(batchVarsTable), ]

    bTab <- as.data.frame(batchVarsTable, row.names = as.character(batchVarsTable[[sampleID]]))
    modcombat <- model.matrix(sampleID~1, data=vstdata) # Add adjustment variables (just intersection for now)
    # modcombat <- as.data.frame(modcombat) 

    # Correct number of samples in batch table
    bTab <- bTab[which(rownames(modcombat) %in% rownames(bTab)), ]

    # Batching according to variable
    batch <- bTab[[batchVar]]
    normdata <- ComBat(dat=exprs(vstdata), batch=as.factor(batch), mod=modcombat)
    return (normdata)
  }, error = function() {
    message("Normalizing with ComBat failed. Returning original data. Try other batch")
    return(data.new)
  })
}

# # Normalizing with both methods as in article: http://journals.plos.org/plosone/article/file?id=10.1371/journal.pone.0156594&type=printable
# normalizeVstQCmB<- function(data.new, bTabName, batchVar) {
#   data.vstqN <- normalizeDataVstQ(data.new)
#   data.vstqcmbtN <- normalizeDataComBat(data.vstqN, bTabName, batchVar)
#   return (data.vstqcmbtN)
# }
