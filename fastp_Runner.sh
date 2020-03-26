#!/bin/sh

##########################################################################################
#      ____  ___    ____  _      __                                                      #
#     / __ \/   |  / __ \(_)____/ /_                                                     #
#    / /_/ / /| | / / / / / ___/ __ \                                                    #
#   / _, _/ ___ |/ /_/ / (__  ) / / /                                                    #
#  /_/ |_/_/  |_/_____/_/____/_/ /_/                                                     #
#                                                                                        #
# File: fastp_Runner.sh                                                                  #
  version="v0.1.0"                                                                       #
# Author: Justin C. Bagley                                                               #
# Date: created by Justin Bagley ib Thu, Mar 26 14:01:30 CDT 2020                        #
# Last update: March 26, 2020                                                            #
# Copyright (c) 2020 Justin C. Bagley. All rights reserved.                              #
# Please report bugs to <bagleyj@umsl.edu>.                                              #
#                                                                                        #
# Description:                                                                           #
# SHELL SCRIPT THAT AUTOMATES ALL-IN-ONE FASTQ PROCESSING (CLEANING AND TRIMMING READS)  #
# USING fastp ON GROUP OF MULTIPLE FASTQ FILES IN CURRENT WORKING DIRECTORY              #
#                                                                                        #
# USAGE:       $ chmod u+x ./fastp_Runner.sh                                             #
#              $ ./fastp_Runner.sh                                                       #
#                                                                                        #
# ASSUMPTIONS: Runs on one or multiple paired-end (PE; usually Illumina), gzipped FASTQ  #
#               files ('.fastq.gz' extension) in current working directory on UNIX-like  #
#               machine on which main dependency, fastp, is available from the command   #
#               line as 'fastp'. The FASTQ files should be named with the suffixes       #
#               '_PE1.fastq.gz' for forward reads and '_PE2.fastq.gz' for the reverse    #
#               reads (analogous to _R1.fastq.gz and _R2.fastq.gz from Illumina output,  # 
#               respectively).                                                           #
#                                                                                        #
# FASTP INFO:                                                                            #
# fastp ultrafast all-in-one fastq QC processor (cleans and trims reads)                 #
# URL: https://github.com/OpenGene/fastp                                                 #
# URL: https://github.com/OpenGene/fastp#overrepresented-sequence-analysis               #
##########################################################################################

echo "
##########################################################################################
#                            fastp_Runner v0.1.0, March 2020                             #
##########################################################################################
"

######################################## START ###########################################
echo "INFO      | $(date) | Starting fastp_Runner analysis... "

echo "INFO      | $(date) | STEP #1: SET UP WORKING DIR. "
echo "INFO      | $(date) | Current working directory:  $PWD  "
if [[ ! -s ./PE1_file_order.list.txt ]]; then 
	for file in ./*PE1.fastq.gz ; do 
	echo "$file" >> ./PE1_file_order.list.txt; 
	done ; 
fi ;
if [[ ! -s fastp_results/ ]]; then mkdir fastp_results/ ; fi ;

## Log output to file (default filename 'fastp_results/fastp_Runner.out.txt'):
exec >> ./fastp_results/fastp_Runner.out.txt
exec 2>&1
echo "INFO      | $(date) | Logging output to file at ./fastp_results/fastp_Runner.out.txt ... "

echo "
##########################################################################################
#                            fastp_Runner v0.1.0, March 2020                             #
##########################################################################################
"
echo "INFO      | $(date) | Starting fastp_Runner analysis... "

echo "INFO      | $(date) | STEP #1: SET UP WORKING DIR. "
echo "INFO      | $(date) | Current working directory:  $PWD  "


echo "INFO      | $(date) | STEP #2: CREATE AND RUN fastp_Runner FUNCTION, RUNS fastp ON ALL PE FASTQ FILES IN CURRENT WORKING DIR. "
fastp_Runner () {

(
#	for i in ./*PE1.fastq.gz ; do
	while read i; do
		MY_BASENAME="$(basename "$i" '_PE1.fastq.gz')";
		echo "
		INFO      | $(date) | ###############  Sample: ${MY_BASENAME} ############### "
#
		# fastp abs. path on local machine: /Users/justinbagley/opt/anaconda2/bin/fastp
		fastp -i "$MY_BASENAME"_PE1.fastq.gz -I "$MY_BASENAME"_PE2.fastq.gz -o out_PE1.fastq.gz -O out_PE2.fastq.gz --overrepresentation_analysis -j "$MY_BASENAME"_fastp.json -h "$MY_BASENAME"_fastp.html  ;
#
		## Overwrite original FASTQ files with cleaned reads files (all in cwd):
		if [[ -s ./out_PE1.fastq.gz ]]; then 
			mv ./out_PE1.fastq.gz ./"$MY_BASENAME"_PE1.fastq.gz ;
		fi
		if [[ -s ./out_PE2.fastq.gz ]]; then 
			mv ./out_PE2.fastq.gz ./"$MY_BASENAME"_PE2.fastq.gz ;
		fi
#
		## Move fastp JSON and HTML output for current FASTQ file into results subfolder:
		if [[ -s ./"$MY_BASENAME"_fastp.json ]]; then 
			echo "INFO      | $(date) | Moving fastp JSON results to results subfolder (fastp_results/)... "
			mv ./"$MY_BASENAME"_fastp.json fastp_results/  ;
		fi
		if [[ -s ./"$MY_BASENAME"_fastp.html ]]; then 
			echo "INFO      | $(date) | Moving fastp HTML results to results subfolder (fastp_results/)... "
			mv ./"$MY_BASENAME"_fastp.html fastp_results/  ;
		fi
#
	done < ./PE1_file_order.list.txt
)

echo "INFO      | $(date) | ######################################## "

}

## DON'T FORGET TO RUN THE FUNCTION!!
fastp_Runner


echo "INFO      | $(date) | STEP #3: CLEAN UP WORKING DIRECTORY. "
mv ./PE1_file_order.list.txt ./fastp_results/ ;


echo "INFO      | $(date) | Done processing FASTQ files in fastp using fastp_Runner. "
echo "INFO      | $(date) | Bye.
"
#
#
#
######################################### END ############################################

exit 0
