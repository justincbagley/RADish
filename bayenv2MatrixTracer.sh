#!/bin/sh

##########################################################################################
#      ____  ___    ____  _      __                                                      #
#     / __ \/   |  / __ \(_)____/ /_                                                     #
#    / /_/ / /| | / / / / / ___/ __ \                                                    #
#   / _, _/ ___ |/ /_/ / (__  ) / / /                                                    #
#  /_/ |_/_/  |_/_____/_/____/_/ /_/                                                     #
#                          bayenv2MatrixTracer v0.1.0, May 2018                          #
#  SCRIPT THAT AUTOMATES ASSESSMENT OF CONVERGENCE DURING VARIANCE-COVARIANCE MATRIX     #
#  (MATRIXFILE) ESTIMATION USING MCMC IN BAYENV2                                         #
#  Copyright ©2018 Justinc C. Bagley. For further information, see README and license    #
#  available in the RADish repository (https://github.com/justincbagley/RADish/). This   #
#  script was last updated May 31, 2018. For questions, please email jcbagley@vcu.edu.   #
##########################################################################################

##  USAGE: ./bayenv2MatrixTracer.sh [Options] <workingDir> > <outputFile>
##    e.g. ./removeFixedSNPs.sh -i ./matrix.txt -p 104 .	## matrix.txt, w/200 matrices from 100,000 generation
															## bayenv2 run, logging every 500 steps, and with
															## data (hence output rows/cols) for 104 populations.

############ SCRIPT OPTIONS
## OPTION DEFAULTS ##
MY_INPUT_MATRIX=matrix.out
MY_NUM_MATRIX_ITER=200
MY_MAT_LOG_FREQ=500
MY_NUM_POPS=20
MY_WRITEOVER_SWITCH=NULL
MY_OUTPUT_FILE=output.txt

############ CREATE USAGE & HELP TEXTS
Usage="Usage: $(basename "$0") [Help: -h help] [Options: -i n f p w o] <workingDir>
 ## Help:
  -h   help text (also: -help)

 ## Options:
  -i   inputMatrix (def: matrix.out) input MATRIXFILE name (defaults to default matrix output
       filename in Bayenv2)
  -n   numSave (def: 200) number of matrices saved during Bayenv2 run
  -f   freqSave (def: 500) frequency at which matrices were saved to file by Bayenv2 (a 
       value of 500 is also the default in Bayenv2; <numSave> x <freqSave> = total number 
       of Bayenv2 run generations)
  -p   pops (def: 20) number of populations
  -w   writeOver (def: 0/no/NULL; other: 1/yes) whether or not to overwrite original matrix
  -o   outputFile (def: output.txt) name of output file for stdout and stderr

 ## EXAMPLES: 
 ## Practical usage example (with description below):

 ./removeFixedSNPs.sh -i ./matrix.txt -p 104 . > out.txt
 
 The above reads input file named 'matrix.txt', with 200 matrices from a 100,000 generation
 bayenv2 run in which matrices were logged every 500 steps, and which involved data (hence also
 output rows/cols) for 104 populations. The greater than symbol is the shell redirection command
 and sends all screenout to a file named out.txt, so as not to overload the terminal window
 with thousands of lines of matrix values.

Copyright ©2018 Justinc C. Bagley
May 30, 2018, Richmond, VA
"

if [[ "$1" == "-h" ]] || [[ "$1" == "-help" ]]; then
	echo "$Usage"
	exit
fi


############ PARSE THE OPTIONS
while getopts 'i:n:f:p:w:o:' opt ; do
  case $opt in

## Bayenv2 options:
    i) MY_INPUT_MATRIX=$OPTARG ;;
    n) MY_NUM_MATRIX_ITER=$OPTARG ;;
    f) MY_MAT_LOG_FREQ=$OPTARG ;;
    p) MY_NUM_POPS=$OPTARG ;;
    w) MY_OVERWRITE_SWITCH=$OPTARG ;;
    o) MY_OUTPUT_FILE=$OPTARG ;;

## Missing and illegal options:
    :) printf "Missing argument for -%s\n" "$OPTARG" >&2
       echo "$Usage" >&2
       exit 1 ;;
   \?) printf "Illegal option: -%s\n" "$OPTARG" >&2
       echo "$Usage" >&2
       exit 1 ;;
  esac
done

############ SKIP OVER THE PROCESSED OPTIONS
shift $((OPTIND-1)) 
# Check for mandatory positional parameters
if [ $# -lt 1 ]; then
echo "$Usage"
  exit 1
fi
MY_WORKING_DIR="$1"


### Send all output to file 'output.txt'
if [[ "$MY_OUTPUT_FILE" = "output.txt"  ]]; then
	exec >> ./output.txt
else
	exec >> ./"$MY_OUTPUT_FILE"
fi
exec 2>&1


echo "
##########################################################################################
#                          bayenv2MatrixTracer v0.1.0, May 2018                          #
##########################################################################################
"

######################################## START ###########################################
###### Set paths and filetypes as different variables:
echo "INFO      | $(date) |          STEP 1. SETUP AND ASSESS LOCAL ENVIRONMENT. "
echo "INFO      | $(date) |          Setting user-specified path to: $MY_WORKING_DIR "
	CR=$(printf '\r')
	calc () {
	   	bc -l <<< "$@"
	}


########################################
###### STEP 1. CHECK MACHINE TYPE:
########################################
##--This idea and code came from the following URL (Lines 87-95 code is reused here): 
##--https://stackoverflow.com/questions/3466166/how-to-check-if-running-in-cygwin-mac-or-linux 
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac
echo "INFO      | $(date) |          System: ${machine} "
echo "INFO      | $(date) |          ... "



########################################
###### STEP 2. PREP & SPLIT INPUT MATRIX:
########################################
echo "INFO      | $(date) |          STEP 2. PREP AND SPLIT INPUT MATRIX. "
echo "INFO      | $(date) |          Name of input matrix: $MY_INPUT_MATRIX "
if [[ "${machine}" = "Mac" ]]; then

####### CASE A: LOCAL MAC MACHINE (RUN LOCALLY)

MY_HEADER_SIZE="$(grep -n 'number\ of\ loci' $MY_INPUT_MATRIX | head -n1 | sed 's/\:.*//g; s/\ //g')"
MY_MATRIX_BASENAME="$(echo $MY_INPUT_MATRIX | sed 's/\.\///g; s/\.txt$//g; s/\.out$//g')"
#sed -e '1,14d' "$MY_INPUT_MATRIX" 
sed '1,'"$MY_HEADER_SIZE"'d' "$MY_INPUT_MATRIX" > ./"$MY_MATRIX_BASENAME"_headless.tmp

echo "INFO      | $(date) |          Parsing out $MY_NUM_MATRIX_ITER matrices from input matrix file...  "
MY_CUT_SIZE="$(calc $MY_NUM_POPS+2)"
{
	for i in $(seq 1 "$MY_NUM_MATRIX_ITER"); do  
		if [[ ! -f ./matrix_"$i".txt  ]]; then
			sed -n '1,'"$MY_CUT_SIZE"'p' ./"$MY_MATRIX_BASENAME"_headless.tmp > matrix_"$i".txt; 
			sed -i '' '1d' matrix_"$i".txt;
			sed -i '' '1,'"$MY_CUT_SIZE"'d' ./"$MY_MATRIX_BASENAME"_headless.tmp; 
		elif [[ -f ./matrix_"$i".txt  ]]; then
			sed -i '' '1,'"$MY_CUT_SIZE"'d' ./"$MY_MATRIX_BASENAME"_headless.tmp;
		fi
	done
} &> /dev/null

(
	for i in $(seq 1 "$MY_NUM_MATRIX_ITER"); do
		echo "matrix_$i.txt" >> ./myMatrix.list
	done
)

fi


if [[ "${machine}" = "Linux" ]]; then

####### CASE B: LINUX AND/OR LINUX-BASED SUPERCOMPUTER ENVIRONMENT (RUN ON LINUX)

MY_HEADER_SIZE="$(grep -n 'number\ of\ loci' $MY_INPUT_MATRIX | head -n1 | sed 's/\:.*//g; s/\ //g')"
MY_MATRIX_BASENAME="$(echo $MY_INPUT_MATRIX | sed 's/\.\///g; s/\.txt$//g; s/\.out$//g')"
#sed -e '1,14d' "$MY_INPUT_MATRIX" 
sed '1,'"$MY_HEADER_SIZE"'d' "$MY_INPUT_MATRIX" > ./"$MY_MATRIX_BASENAME"_headless.tmp

echo "INFO      | $(date) |          Parsing out $MY_NUM_MATRIX_ITER matrices from input matrix file...  "
MY_CUT_SIZE="$(calc $MY_NUM_POPS+2)"
{
	for i in $(seq 1 "$MY_NUM_MATRIX_ITER"); do  
		if [[ ! -f ./matrix_"$i".txt  ]]; then
			sed -n '1,'"$MY_CUT_SIZE"'p' ./"$MY_MATRIX_BASENAME"_headless.tmp > matrix_"$i".txt; 
			sed -i '1d' matrix_"$i".txt;
			sed -i '1,'"$MY_CUT_SIZE"'d' ./"$MY_MATRIX_BASENAME"_headless.tmp; 
		elif [[ -f ./matrix_"$i".txt  ]]; then
			sed -i '1,'"$MY_CUT_SIZE"'d' ./"$MY_MATRIX_BASENAME"_headless.tmp;
		fi
	done
} &> /dev/null


(
	for i in $(seq 1 "$MY_NUM_MATRIX_ITER"); do
		echo "matrix_$i.txt" >> ./myMatrix.list
	done
)

fi



########################################
###### STEP 3. MAKE AND EXECUTE CUSTOM R SCRIPT
###### TO EVALUATE CONVERGENCE OF THE MATRIX ESTIMATION.
########################################
echo "INFO      | $(date) |          ... "
echo "INFO      | $(date) |          STEP 3. MAKE AND EXECUTE CUSTOM R SCRIPT TO EVALUATE CONVERGENCE OF THE  "
echo "INFO      | $(date) |          MATRIX ESTIMATION IN BAYENV2 (THIS ALSO SAVES RESULTS TO FILE). "

	MY_PATH=`pwd -P`
	MY_SDEV_VAR="$(echo "\$sdev")"
	MY_VALUES_VAR="$(echo "\$values")"
	MY_EIG1_VAR="$(echo "\$eig1")"
	MY_PROP_EIG1_VAR="$(echo "\$prop_eig1")"
	MY_PVE_EIG1_VAR="$(echo "\$PVE_eig1")"
	MY_Z_VAR="$(echo "\$z")"

echo "INFO      | $(date) |          Building custom matrixConverge R script for assessing convergence of the matrix estimation in Bayenv2... "
############ MAKE R SCRIPT
echo "
#!/usr/bin/env Rscript

################################### matrixConverge.R #####################################

############ I. SETUP
setwd('$MY_PATH')
#
##--Load needed packages, R code, or other prelim stuff. Install packages if not present.
packages <- c('tseries', 'data.table', 'boot', 'numbers', 'scales', 'tools', 'plyr', 
	'coda', 'dplyr')
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
    install.packages(setdiff(packages, rownames(installed.packages())))
}

library(tseries); 
library(data.table);
library(scales);
library(tools); 
library(dplyr);
library(plyr);
library(coda);


############ II. READ MATRICES, WRITE SUMMARY TO FILE
## What we really want is to save a list of the matrix files themselves inside R:
matrixFiles <- list.files(pattern='matrix_.*txt')

## Make dummy matrix that we will fill with eigenvalues...
eigen_mat <- matrix(data=NA, nrow=$MY_NUM_MATRIX_ITER, ncol=4)

## Read in the data matrices...
for(i in 1:length(matrixFiles)){
	## Read each matrix using 'read.matrix' function of tseries:
		mat.in <- read.matrix(paste('matrix_',i,'.txt',sep=''))
		assign(paste('mat',i,sep='_'), mat.in)
}

save.image('matrixConverge_Workspace.RData')

for(i in 1:length(matrixFiles)){
	## Do PCA on the matrix using prcomp function, and summarize (get eigenvalues, including 1st eigenvalue):
		pca <- prcomp(get(paste('mat',i,sep='_')))
		eigs <- pca$MY_SDEV_VAR^2

		## get first proportional eigenvalue (prop_eig1) and place it in the dummy data/summary matrix:
		eigen_mat[i,1] <- eigs[1]

		## get first proportion variance explained (PVE) of proportional eigenvalue nd place it in dummy matrix:
		PVE <- eigs/sum(eigs)
		PVE_eig1 <- eigs[1]/sum(eigs)
		eigen_mat[i,2] <- PVE_eig1
#
	## Get first 'real' eigenvalue (eig1) for the matrix:
		eigen_mat[i,3] <- eigen(get(paste('mat',i,sep='_')))$MY_VALUES_VAR[1]
		eigen_mat[i,4] <- paste('mat',i,sep='_')
}

colnames(eigen_mat) <- c('prop_eig1','PVE_eig1','eig1','matrix')

eigen_mat
#
#
write.table(eigen_mat, file='eigen_matrix.txt', sep='\t')

eigen_mat_df <- as.data.frame(eigen_mat)
eigen_mat_df


############ III. ASSESS CONVERGENCE QUALITATIVELY USING GRAPHICAL PLOTS OF CONVERGENCE
############      METRICS (BY ITER), AND SAVE RESULTS TO PDF FILES
### PLOT #1:
pdf('eigen_mat_eig1_plot_blue.pdf')
	plot(eigen_mat_df$MY_EIG1_VAR ~ seq(from=500,to=100000,by=500), type='l', col='blue', xlab='Iteration', ylab=expression(paste('First eigenvalue (', lambda[1], ') of the var-covar matrix')), font.lab=1)
dev.off()

### PLOT #2:
pdf('eig1_blue_vs_prop_eig1_green_plot.pdf')
	par(mar = c(5, 4, 4, 4) + 0.3)  # Leave space for z axis
	plot(eigen_mat_df$MY_EIG1_VAR ~ seq(from=500,to=100000,by=500), type='l', col='blue', xlab='Iteration', ylab=expression(paste('First eigenvalue (', lambda[1], ') of the var-covar matrix')), font.lab=1)
	par(new = TRUE)
	plot(eigen_mat_df$MY_PROP_EIG1_VAR ~ seq(from=500,to=100000,by=500), type='l', col='green4', axes=FALSE, bty='n', xlab='', ylab='')
	axis(side=4, at = pretty(range(eigen_mat_df$MY_PROP_EIG1_VAR)), col='green4', col.axis='green4')
	mtext('Proportional eigenvalue of the var-covar matrix', side=4, col='green4', line=3)
dev.off()

## IDEAS:
# pdf()
#	par(mar = c(5, 4, 4, 4) + 0.3)  # Leave space for z axis
#	plot(eigen_mat_df$MY_EIG1_VAR ~ seq(from=500,to=100000,by=500), type='l', col='black', xlab='Iteration', ylab=expression(paste('First eigenvalue (', lambda[1], ') of the var-covar matrix')), font.lab=1)
#	par(new = TRUE)
#	plot(eigen_mat_df$MY_PVE_EIG1_VAR ~ seq(from=500,to=100000,by=500), type='l', col='red', axes=FALSE, bty='n', xlab='', ylab='')
#	axis(side=4, at=pretty(range(eigen_mat_df$MY_PVE_EIG1_VAR)), col='red', col.axis='red')
#	mtext('Proportion of variance explained (PVE)', side=4, col='red',line=3)
# dev.off()

# pdf()
#	par(mar = c(5, 4, 4, 4) + 0.3)  # Leave space for z axis
#	plot(eigen_mat_df$MY_EIG1_VAR ~ seq(from=500,to=100000,by=500), type='l', col='black', xlab='Iteration', ylab=expression(paste('First eigenvalue (', lambda[1], ') of the var-covar matrix')), font.lab=1)
#	par(new = TRUE)
#	plot(eigen_mat_df$MY_PROP_EIG1_VAR ~ seq(from=500,to=100000,by=500), type='l', col='red', axes=FALSE, bty='n', xlab='', ylab='')
#	par(new = TRUE)
#	plot(eigen_mat_df$MY_PVE_EIG1_VAR ~ seq(from=500,to=100000,by=500), type='l', col='red', axes=FALSE, bty='n', xlab='', ylab='')
#	axis(side=4, at=pretty(range(eigen_mat_df$MY_PVE_EIG1_VAR)), col='red', col.axis='red')
#	mtext('Y-axis 2', side=4, col='red',line=3)
# dev.off()

### PLOT #3 (best):
pdf('eig1_blue_vs_prop_eig1+PVE_green_plot.pdf')
	par(mar = c(5, 4, 4, 4) + 0.3)  # Leave space for z axis
 	plot(eigen_mat_df$MY_EIG1_VAR ~ seq(from=500,to=100000,by=500), type='l', col='blue', xlab='Iteration', ylab=expression(paste('First eigenvalue (', lambda[1], ') of the var-covar matrix')), font.lab=1, col.lab='black')
 	par(new = TRUE)
 	plot(eigen_mat_df$MY_PROP_EIG1_VAR ~ seq(from=500,to=100000,by=500), type='l', col='green4', axes=FALSE, bty='n', xlab='', ylab='')
 	par(new = TRUE)
 	plot(eigen_mat_df$MY_PVE_EIG1_VAR ~ seq(from=500,to=100000,by=500), type='l', lty=2, col='green4', axes=FALSE, bty='n', xlab='', ylab='')
 	axis(side=4, at=pretty(range(eigen_mat_df$MY_PVE_EIG1_VAR)), col='green4', col.axis='green4')
 	mtext('Proportional eigenvalue results', side=4, col='green4',line=3)
 	legend('topright', inset=.05, legend=c('eigenvalue','prop. eigenvalue','PVE, prop. eigenvalue'), col=c('blue','green4','green4'), lty=c(1,1,2), box.lty=0, horiz=FALSE)
dev.off()

save.image('matrixConverge_Workspace.RData')


############ IV. ASSESS CONVERGENCE QUANTITATIVELY IN CODA, AND SAVE RESULTS TO FILE
### EFFECTIVE SAMPLE SIZES:

sink('coda_ESS_for_estimating_means.txt')
	print('Effective sample size for estimating the mean of the first eigenvalue:', quote=FALSE)
		effectiveSize(as.numeric(eigen_mat_df$MY_EIG1_VAR))
	print('Effective sample size for estimating the mean of the first proportional eigenvalue:', quote=FALSE)
		effectiveSize(as.numeric(eigen_mat_df$MY_PROP_EIG1_VAR))
	print('Effective sample size for estimating the mean of the proportion of variance explained by the first proportional eigenvalue:', quote=FALSE)
		effectiveSize(as.numeric(eigen_mat_df$MY_PVE_EIG1_VAR))
sink()


### AUTOCORRELATION:
pdf('coda_3panel_autocorrelations_plot.pdf')
	par(mfrow=c(1,3))
	autocorr.plot(as.numeric(eigen_mat_df$MY_EIG1_VAR), auto.layout=FALSE, col='blue')
		legend('bottom', inset=.05, legend=c('eigenvalue'), col='blue', lty=1, box.lty=0, horiz=TRUE)
	autocorr.plot(as.numeric(eigen_mat_df$MY_PROP_EIG1_VAR), auto.layout=FALSE, col='green4')
		legend('bottom', inset=.05, legend=c('prop. eigenvalue'), col='green4', lty=1, box.lty=0, horiz=TRUE)
	autocorr.plot(as.numeric(eigen_mat_df$MY_PVE_EIG1_VAR), auto.layout=FALSE, col='green4')
		legend('bottom', inset=.05, legend=c('PVE, prop. eigenvalue'), col='green4', lty=2, box.lty=0, horiz=TRUE)
dev.off()


### POSTERIOR DISTRIBUTION HISTOGRAMS:
pdf('eig1_posterior.pdf')
	hist(as.numeric(eigen_mat_df$MY_EIG1_VAR), col='blue', breaks=100, border='white', xlab=expression(paste('First eigenvalue (', lambda[1], ') of the var-covar matrix')), main=NULL)
dev.off()

pdf('prop_eig1_posterior.pdf')
	hist(as.numeric(eigen_mat_df$MY_PROP_EIG1_VAR), col='green4', breaks=100, border='white', xlab='First proportional eigenvalue', main=NULL)
dev.off()

pdf('PVE_prop_eig1_posterior.pdf')
	hist(as.numeric(eigen_mat_df$MY_PVE_EIG1_VAR), col='green4', breaks=100, border='white', xlab='Prop. variance explained by first proportional eigenvalue', main=NULL)
dev.off()



### GEWEKE DIAG-BASED CONVERGENCE POINT:
eig1_geweke_mat <- matrix(data=NA, nrow=20, ncol=1, dimnames=NULL)

## first val, half step (2.5% frac1)
res <- geweke.diag(as.numeric(eigen_mat_df$MY_EIG1_VAR), 0.025, 0.975)
eig1_geweke_mat[1,] <- res$MY_Z_VAR[[1]]

## all subsequent values, full steps (5% increment up for frac1)
for(i in 1:19){
	frac1 <- i/20
	frac2 <- 1-frac1
	res <- geweke.diag(as.numeric(eigen_mat_df$MY_EIG1_VAR), frac1, frac2)
	eig1_geweke_mat[i+1,] <- res$MY_Z_VAR[[1]]
}

pdf('eig1_Geweke_diagnostic_det_frac_convergence_plot.pdf')
	plot(eig1_geweke_mat[,1] ~ seq(from=500,to=100000,by=5000), type='o', col='blue4', ylab='Geweke diagnostic', xlab='Iteration')
	abline(h=1, lty=2)
dev.off()





save.image('matrixConverge_Workspace.RData')

" > matrixConverge.R

############ FINALLY, RUN THE R SCRIPT AND CLEANUP FILES IN WORKING DIRECTORY:
echo "INFO      | $(date) |          RUN THE R SCRIPT (WHICH ALSO SAVES RESULTS TO FILE). "
	R CMD BATCH ./matrixConverge.R

## Cleanup:
	cp ./matrixConverge.Rout ./matrixConverge.Rout.txt



echo "INFO      | $(date) |          ... "
echo "INFO      | $(date) | Done analyzing matrices (e.g. convergence) from Bayenv2 MATRIXFILE using bayenv2MatrixTracer in RADish. "
echo "INFO      | $(date) | Bye.
"
#
#
#
######################################### END ############################################

exit 0
