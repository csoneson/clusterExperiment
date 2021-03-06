% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/subset.R
\docType{methods}
\name{subset}
\alias{subset}
\alias{removeClusterings,ClusterExperiment,character-method}
\alias{removeClusterings,ClusterExperiment,numeric-method}
\alias{removeClusters,ClusterExperiment,numeric-method}
\alias{removeClusters}
\alias{removeClusters,ClusterExperiment,character-method}
\alias{[,ClusterExperiment,ANY,character,ANY-method}
\alias{[,ClusterExperiment,ANY,ANY,ANY-method}
\alias{[,ClusterExperiment,ANY,logical,ANY-method}
\alias{[,ClusterExperiment,ANY,numeric,ANY-method}
\title{Functions to subset ClusterExperiment Objects}
\usage{
\S4method{removeClusterings}{ClusterExperiment,character}(x, whichClusters, ...)

\S4method{removeClusterings}{ClusterExperiment,numeric}(x, whichClusters)

\S4method{removeClusters}{ClusterExperiment,numeric}(x, whichCluster,
  clustersToRemove, makePrimary = FALSE, clusterLabels = NULL)

\S4method{removeClusters}{ClusterExperiment,character}(x, whichCluster, ...)

\S4method{[}{ClusterExperiment,ANY,character,ANY}(x, i, j, ..., drop = TRUE)

\S4method{[}{ClusterExperiment,ANY,logical,ANY}(x, i, j, ..., drop = TRUE)

\S4method{[}{ClusterExperiment,ANY,numeric,ANY}(x, i, j, ..., drop = TRUE)
}
\arguments{
\item{x}{a ClusterExperiment object.}

\item{whichClusters}{argument that can be either numeric or character value
indicating the clusters to be used. If numeric, gives the indices of the
\code{clusterMatrix} to return; this can also be used to defined an
ordering for the clusterings (as relevant). \code{whichClusters} can be a
character value identifying the \code{clusterTypes} to be used, or if not
matching \code{clusterTypes} then \code{clusterLabels}; alternatively
\code{whichClusters} can be either 'all' or 'workflow' or 'primary' to
indicate choosing all clusterings or choosing all 
\code{\link{workflowClusters}} clusterings or choosing the 'primary'
clustering, respectively. If missing, the entire matrix of all clusterings
is returned.}

\item{...}{The arguments \code{transformation}, \code{clusterTypes} and
\code{clusterInfo} to be passed to the constructor for signature
\code{SingleCellExperiment,matrix}.}

\item{whichCluster}{Clustering from which to remove clusters for
\code{removeCluster}. Note that it is a singular cluster.}

\item{clustersToRemove}{numeric vector identifying the clusters to remove (whose samples will be reassigned to -1 value).}

\item{makePrimary}{whether to make the added cluster the primary cluster (only relevant if \code{y} is a vector)}

\item{clusterLabels}{label(s) for the clusters being added. If \code{y} a
matrix, the column names of that matrix will be used by default, if
\code{clusterLabels} is not given.}

\item{i, j}{A vector of logical or integer subscripts, indicating the rows and columns to be subsetted for \code{i} and \code{j}, respectively.}

\item{drop}{A logical scalar that is ignored.}
}
\value{
A \code{\link{ClusterExperiment}} object.

\code{removeClusterings} returns a \code{ClusterExperiment} object,
 unless all clusters are removed, in which case it returns a
 \code{\link{SingleCellExperiment}} object.
}
\description{
These functions are used to subset ClusterExperiment objects, either by removing samples, genes, or clusterings
}
\details{
\code{removeClusterings} removes the clusters given by
 \code{whichClusters}. If the
 \code{primaryCluster} is one of the clusters removed, the
 \code{primaryClusterIndex} is set to 1 and the dendrogram and coclustering
 matrix are discarded and orderSamples is set to \code{1:NCOL(x)}.

\code{removeClusters} creates a new cluster that unassigns samples in cluster \code{clustersToRemove} (in the clustering defined by \code{whichClusters}) and assigns them to -1 (unassigned)

Note that when subsetting the data, the dendrogram information and
the co-clustering matrix are lost.
}
