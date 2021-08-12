#' Calculate PCA of supplied asset returns and give back standard set of information
#' 
#' @description Returns a list containing commonly used PCA output
#' @param assetReturns a dataframe containing a timeseries of the returns you want to base the PCA on. Row names should be dates and column names should be the assets. 
#'See sample data, USLargeCapGrowthReturns, for an example.
#' @param portfolioReturns a dataframe containing a timeseries of the returns you want to analyse via the principle components. Row names should be dates and column names should be the portfolios. 
#' @param portfolioWeights a dataframe containing the portfolio weights. The rownames should be the portfolio names and the column names should be the individual asset names.
#'                         Weights should be recorded as decimals, not percents. Note: this function does not work with dynamic weights!
#' @param periods how manys periods make up a year in this dataset (ex. 12 if monthly returns, 252 if daily)
#' @param lookbackWindow a vector of numbers specifying the different rolling windows to use.
#' @return a list with the following elements:
#'         Raw - the full prcomp() output
#'         Importance - dataframe giving std deviation, % variance explained, and cumulative % variance explained of PCs; summary(prcomp())$importance
#'         RollingVarExplained - rolling percentage variance explained by drivers
#'         AssetCorrelations - correlation between assets and drivers
#'         FundBreakdown - breakdown fund vol by drivers
#' @export
#' 
#' 

#getStandardPCA <- function(assetReturns, portfolioReturns, portfolioWeights, periods, lookbackWindow){
assetReturns <- read.csv("./PCA_example.csv")
periods <- 12
portfolioReturns <- matrix(NA, nrow = 1, ncol = 0)

 PCAOutput = list()
  pca = prcomp(assetReturns, center = FALSE, scale. = FALSE)
  PCAReturns = pca$x
  
  PCAOutput$Raw = pca
  
  #importance includes % variance explained, and cumulative % variance explained
  PCAOutput$Importance = summary(pca)$importance
  
  #correlations
  assetCorrelations = cor(PCAReturns, assetReturns)
  PCAOutput$AssetCorrelations = assetCorrelations
  
  ###########################################################
  #MATT - everything after here is 'bonus'
  ###########################################################
  
  
  
  
  #breakdown fund variance by Driver
  ##handle assets first, then portfolios, checking that there are in fact portfolios
  assetVol = apply(assetReturns, 2, sd)*sqrt(periods)
  PCAVols = apply(PCAReturns, 2, sd)*sqrt(periods)
  
  #calc regression betas
  assetBetas = matrix(NA, nrow = ncol(assetReturns), ncol = ncol(assetReturns))
  for(i in 1:ncol(assetReturns)){
    tmpFit = lm(assetReturns[,i]~PCAReturns)
    assetBetas[,i] = tmpFit$coefficients[2:(ncol(assetReturns)+1)]
  }
  #for readability/debug
  colnames(assetBetas) = colnames(assetReturns)
  rownames(assetBetas) = colnames(PCAReturns)
  
  
  PCAAssetVolDecomp = matrix(NA, nrow = ncol(assetReturns), ncol = ncol(assetReturns))
  #there is 100% a smarter way to do this than loops
  for(i in 1:ncol(assetReturns)){
    for(j in 1:ncol(assetReturns)){
      PCAAssetVolDecomp[i,j] = PCAVols[i]*assetCorrelations[i,j]*assetBetas[i,j]/assetVol[j]
      
    }
  }
  colnames(PCAAssetVolDecomp) = colnames(assetReturns)
  rownames(PCAAssetVolDecomp) = colnames(PCAReturns)
  
  if(ncol(portfolioReturns)>0){ #verify there are in fact portfolios
    portVol = apply(portfolioReturns, 2, sd)*sqrt(periods)
    portCorrelations = cor(PCAReturns, portfolioReturns)
    
    #calc regression betas
    portBetas = matrix(NA, nrow = ncol(PCAReturns), ncol = ncol(portfolioReturns))
    for(i in 1:ncol(portfolioReturns)){
      tmpFit = lm(portfolioReturns[,i]~PCAReturns)
      portBetas[,i] = tmpFit$coefficients[2:(ncol(PCAReturns)+1)]
    }
    colnames(portBetas) = colnames(portfolioReturns)
    rownames(portBetas) = colnames(PCAReturns)
    
    PCAPortVolDecomp = matrix(NA, nrow = ncol(PCAReturns), ncol = ncol(portfolioReturns))
    #there is 100% a smarter way to do this than loops
    for(i in 1:ncol(assetReturns)){
      for(j in 1:ncol(portfolioReturns)){
        PCAPortVolDecomp[i,j] = PCAVols[i]*portCorrelations[i,j]*portBetas[i,j]/portVol[j]
        
      }
    }
    colnames(PCAPortVolDecomp) = colnames(portfolioReturns)
    rownames(PCAPortVolDecomp) = colnames(PCAReturns)
    
    PCAOutput$FundBreakdown = list(PCAAssetVolDecomp = PCAAssetVolDecomp, PCAPortVolDecomp = PCAPortVolDecomp)
  }else{
    PCAOutput$FundBreakdown = list(PCAAssetVolDecomp = PCAAssetVolDecomp)
  }
  
  madcatBacktest::write.xlsx.superComplexList(PCAOutput, "./pca_sample.xlsx")
#   return(PCAOutput)
# }