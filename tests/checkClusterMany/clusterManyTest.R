#Usage: nohup Rscript clusterManyTest.R <tagString> <compareTo(optional)> &
# If get that corrupted file, probably copied from laptop or elsewhere that only has tag
# Do git lfs checkout L5_sumExp.rda
library(devtools)
#library(profmem)
load_all()
#install.packages(pkgs="../../../clusterExperiment",repos=NULL,type="source")
#library(clusterExperiment)
load("L5_sumExp.rda")
outpath<-"resultsDirectory"
if(!file.exists(outpath)) dir.create(outpath)
ncores<-5
args<-commandArgs(TRUE)
if(length(args)==0) stop("Usage should be 'RScript clusterManyTest.R <tagString>' where <tagString> will be name on saved file of output.")
tag<-args[1]
fixedVersion<-if(length(args)==2) args[2] else "fixedClusterManyResult.txt"

x<-sessionInfo()
version<-x$otherPkgs[["clusterExperiment"]][["Version"]]
nm<-paste(tag,"_",version,sep="")
# library(benchmarkme) #to get information about RAM and CPUs on machine:
# print(get_ram())
# print(get_cpu())
# print(sessionInfo())

outfile<-file.path(outpath,paste(nm,".Rout",sep=""))
cat("Results for test of",version,"\n",file=outfile)
cat("-------------------\n",file=outfile,append=TRUE)
cat("Running clusterMany...",file=outfile,append=TRUE)
# Old version: 
# cl <-clusterMany(l5, reduceMethod = "PCA", nReducedDims = 50, isCount=TRUE,
#                  ks=4:8, clusterFunction="hierarchical01",
#                  alphas=c(0.2,0.3), subsample=TRUE, sequential=TRUE,
#                  ncores=ncores, subsampleArgs=list(resamp.num=20,
#                                               clusterFunction="kmeans",
#                                               clusterArgs=list(nstart=1)),
#                  seqArgs=list(beta=0.9,k.min=3,verbose=FALSE),
#                  mainClusterArgs=list(minSize=5, verbose=FALSE),
#                  random.seed=21321, run=TRUE)
sttm<-proc.time()
cl <-clusterMany(l5, reduceMethod = "PCA", nReducedDims = 50, isCount=TRUE,
                 ks=4:8, clusterFunction="hierarchical01",
                 beta=0.9, minSize=5,
				 mainClusterArgs=list(clusterArgs=list("whichHierDist"="dist")), #added this to be back-compatible with previous defauls.
				 seqArgs=list(top.can=15),#added this to be back-compatible with previous defauls.
                 alphas=c(0.2,0.3), subsample=TRUE, sequential=TRUE,
                 ncores=ncores, subsampleArgs=list(resamp.num=20,
                                                   clusterFunction="kmeans",
                                                   clusterArgs=list(nstart=1)),
                 random.seed=21321, run=TRUE)
endtm<-proc.time()
tm<-endtm-sttm
#save(cl, file=paste(tag,"_",version,".rda",sep=""))
cat("done.\n",file=outfile,append=TRUE)
cat(paste("Ellapsed Time:",tm[3]/60,"minutes\n"),file=outfile,append=TRUE)
cat(paste("Number of clusters:",nClusterings(cl),"\n"),file=outfile,append=TRUE)
cat(paste("Number of genes of Assay:",nrow(cl),"\n"),file=outfile,append=TRUE)
cat(paste("Number of samples of Assay:",ncol(cl),"\n"),file=outfile,append=TRUE)


mat<-clusterMatrix(cl)
row.names(mat)<-colnames(cl)
matFile<-paste(nm,".txt",sep="")
write.table(mat,file=file.path(outpath,matFile),sep=",",col.names = TRUE,row.names = TRUE)

cat("Current Version:",version,"\n",file=outfile,append=TRUE)
cat("User-given tag:",tag,"\n",file=outfile,append=TRUE)
##Read both in, just to make sure not catching differences due write/read differences
cat("Compare",matFile,"to fixed version (", fixedVersion,")", ":\n",file=outfile,append=TRUE)
compMat<-read.table(fixedVersion,sep=",",header=TRUE)
newMat<-read.table(file.path(outpath,matFile),sep=",",header=TRUE)
compResult<-all.equal(compMat,newMat)
printResult<-if(isTRUE(compResult)) "Yes" else "No"
cat("Are all entries exactly the same?\n",printResult,"\n",file=outfile,append=TRUE)
#If not the same, check if they are permutation
if(!isTRUE(compResult)){
	cat("Are all cluster results the same up to permutation in ids?\n",file=outfile,append=TRUE)
	if(!all(dim(compMat)==dim(newMat))){
		cat("No. (New results do not have the same dimensions as old)\n",file=outfile,append=TRUE)
	}else{
		#check if same clusters, but just different ids given
		ncl<-ncol(compMat)
		numbMinus1<-all(sapply(1:ncl,function(i){
			sum(compMat[,i]== -1)==sum(newMat[,i]==-1)
		})
		)
		numbMinus2<-all(sapply(1:ncl,function(i){
			sum(compMat[,i]== -2)==sum(newMat[,i]==-2)
		})
		)
		if(!numbMinus1 || !numbMinus2){
			cat("No. (number unassigned not the same)\n",file=outfile,append=TRUE)
		}else{
			dimsMatch<-all(sapply(1:ncl,function(i){
				all(apply(table(compMat[,i],newMat[,i]),1,function(x){length(x[x!=0])==1}))
			})
			)
			if(!dimsMatch){
				cat("No. (tabulation of clusters are not the same)\n",file=outfile,append=TRUE)
			}else{
				#now really check the same...convert between one numbering and another
				matchedClusterings<-do.call("cbind",lapply(1:ncl,function(i){
							tab<-table(compMat[,i],newMat[,i])
							mValue<-apply(tab,1,function(x){which(x!=0)})
							valCorresp<-cbind(as.numeric(rownames(tab)),as.numeric(colnames(tab)[mValue]))
							m<-match(newMat[,i],valCorresp[,2])
							return(valCorresp[m,1])
						})
						)
				colnames(matchedClusterings)<-colnames(newMat)
				rownames(matchedClusterings)<-rownames(newMat)
				if(all.equal(matchedClusterings,data.matrix(compMat))){
					cat("Yes.\n",file=outfile,append=TRUE)
				}else{
					if(!all(dimnames(compMat)==dimnames(matchedClusterings))){
						dimnames(matchedClusterings)<-dimnames(compMat)
						if(all.equal(matchedClusterings,compMat)){
							cat("Yes, but the dimnames of the two matrices are not the same.")
						}else{
							cat("No (identification of individual cells to clusters are not the same, though overall tabulations are the same. Also the dimnames do not match).\n",file=outfile,append=TRUE)
						}
						
					}else{
						cat("No (identification of individual cells to clusters are not the same, though overall tabulations are the same).\n",file=outfile,append=TRUE)
					}
				}
			}
		}
	}

}
cat("-------------------\n",file=outfile,append=TRUE)
cat("Complete Session Info:\n",file=outfile,append=TRUE)
cat(paste(capture.output(x),collapse="\n"),file=outfile,append=TRUE )


