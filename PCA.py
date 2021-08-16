import csv
from sklearn.decomposition import PCA
from sklearn.decomposition import FactorAnalysis
from scipy.stats import pearsonr
import pandas as pd
import numpy as np
from numpy.linalg import eig
from numpy.linalg import norm

#from IPython.display import display

def getStandardPCA(assetreturns, portfolioReturns, portfolioWeights, periods, lookbackWindow):
    returns = pd.read_csv(assetreturns, delimiter = ',', quotechar = '|')
    pca_obj = PCA(n_components=len(returns.columns))
    pca = pca_obj.fit_transform(returns)
    assetCorrelations = np.zeros(shape=(len(returns.columns), pca.shape[1]))
    rotation = np.zeros(shape=(len(returns.columns), pca.shape[1]))

    for m in range(len(returns.columns)):
        for k in range(pca.shape[1]):
            assetCorrelations[m,k] = pearsonr(returns.to_numpy()[:,m], pca[:,k])[0]

    df_pca = pd.DataFrame(pca)
    pca_loadings = pd.DataFrame(pca_obj.components_)
    # maybe it is by mean column
    mean_returns = returns - returns.mean()
    # still must make each column a unit vector in rotation
    rotation = mean_returns.cov()

    sdv = pd.DataFrame(pca).std()
    vare = pd.DataFrame(pca).var()
    vare = vare/sum(vare)

if __name__ == "__main__":
	getStandardPCA("./PCA_example.csv", np.array([]), None, 12, None)