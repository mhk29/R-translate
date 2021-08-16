import csv
from sklearn.cluster import KMeans
import pandas as pd
import numpy as np
#from IPython.display import display


def getKMeansClusters(csvfile):
    returns = pd.read_csv(csvfile, delimiter = ',', quotechar = '|')
    clusterAssignments = None
    for k in range(1, len(returns.columns)):
        cluster = KMeans(k, init='k-means++', n_init=20).fit(returns.T)
        clusterAssignments = pd.concat([clusterAssignments, pd.DataFrame(cluster.labels_).T])

    clusterAssignments = pd.concat([clusterAssignments, pd.DataFrame(np.array([0,1,2,3,4])).T])
    clusterAssignments = clusterAssignments.iloc[::-1]
    caOut = pd.DataFrame(data=clusterAssignments.values, columns=returns.columns)  
    print(caOut)
    caOut.to_csv(path_or_buf="./Kmeans_pyout.csv")
    return caOut

if __name__ == "__main__":
	getKMeansClusters("./Kmeans_example.csv")