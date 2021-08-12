#' Compute K-means Clusters
#' 
#' @description Perform k-means clustering on a specified set of funds. K varies from 1 to the number of columns in data provided
#' @param returns a dataframe containing a timeseries of the returns. Row names should be dates and column names should be the assets or portfolios. 
                    #'See sample data, USLargeCapGrowthReturns, for an example.
#' @return a dataframe specifying the cluster assignments of the funds. The first row contains assignments when k=ncol(returns), and k decreases in subsequent rows
#' @details To perform the clustering on returns, each date in the timeseries is treated as a variable
#' @examples 
#' ### get kmeans clusters w/ k=3 
#' clusters <- getKMeansClusters(USLargeCapGrowthReturns)
#' clusters[ncol(USLargeCapGrowthReturns)-2,]
#' @importFrom stats kmeans
#' @export
#'
#' 
 
#getKMeansClusters = function(returns) {

returns <- read.csv("./Kmeans_example.csv")
  clusterAssignments <- c()
  for(i in 2:ncol(returns)-1) {
    cluster <- kmeans(t(returns), i, nstart = 20) #we want dates as vars, funds as obs, so we transpose
    clusterAssignments <- rbind(clusterAssignments, cluster$cluster)
  }
  KmeansTmp = rbind(clusterAssignments, 1:ncol(returns))
  KmeansOut <- apply(KmeansTmp, 2, rev) #add a last column with everybody in own cluster
  
  write.csv(KmeansOut, "./Kmeans_sample.csv")
  
#  return(KmeansOut)
#}
