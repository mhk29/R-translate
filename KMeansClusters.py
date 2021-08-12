import csv
from sklearn.cluster import KMeans
import pandas as pd
import numpy as np
#from IPython.display import display


def KMC(csvfile):
    returns = pd.read_csv(csvfile, delimiter = ',', quotechar = '|')
    for k in range(1, len(returns.columns)):
        cluster = KMeans(k, init='k-means++', n_init=20).fit(returns.T)
        print(cluster.labels_)
        #print(cluster.values)
        try:
            clusterAssignments = pd.concat([clusterAssignments, pd.DataFrame(cluster.labels_).T])
            print("working")
            returns = pd.read_csv(csvfile, delimiter = ',', quotechar = '|')
        else: 
            clusterAssignments = pd.DataFrame(cluster.labels_).T

    print(clusterAssignments)

if __name__ == "__main__":
	KMC("./Kmeans_example.csv")