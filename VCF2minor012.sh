#!/bin/bash


##########################################################################################
#      ____  ___    ____  _      __                                                      #
#     / __ \/   |  / __ \(_)____/ /_                                                     #
#    / /_/ / /| | / / / / / ___/ __ \                                                    #
#   / _, _/ ___ |/ /_/ / (__  ) / / /                                                    #
#  /_/ |_/_/  |_/_____/_/____/_/ /_/                                                     #
#                           VCF2minor012 v0.2.0, October 2021                            #
#  CONVERTS INPUT VCF FILE INTO REGULAR AND MINOR ALLELE-CODED 012 GENOTYPE MATRIX       #
#  FORMATS, USING VCFTOOLS AND PLINK                                                     #
#  Copyright ©2021 Justinc C. Bagley. For further information, see README and license    #
#  available in the RADish repository (https://github.com/justincbagley/RADish/). This   #
#  script was last updated October 8, 2021. For questions, please email jbagley@jsu.edu. #
##########################################################################################

############ SCRIPT OPTIONS
## OPTION DEFAULTS ##
#NONE

############ USAGE & HELP TEXTS
Usage="Usage: $(basename "$0") [Help: -h help] <inputVCF> <output>
 ## Help:
  -h   help text (also: -help)

 ## Required input:
  <inputVCF>   name of input VCF file
  <output>     basename for output file (e.g. 'minor012' obtains output file 'minor012.txt') 

 OVERVIEW
 THIS SCRIPT runs a few operations that ultimately convert a Variant Call Format (VCF)-style
 input SNP dataset into 1) a '012' genotype matrix with standard PLINK (Chang et al. 2015) 
 formatting, which includes counts of the reference allele (whether it is the major or minor 
 allele is not taken into account), and 2) a minor-allele coded '012' genotype matrix with 
 counts of the minor allele. The final regular 012 matrix is placed in a '012' subfolder
 created by the program; the final minor allele-coded 012 matrix is placed into a 'minor012'
 subfolder, as well as the main working directory (for ease of access).
	This script is part of the RADish repository. Please see the RADish website for 
 additional information including the license (https://github.com/justincbagley/RADish/).  
 The main dependencies of this software are vcftools v0.1++ (Danecek et al. 2011) and PLINK 
 v1.9++ (Purcell and Chang 2017), which must be installed and available from the user's 
 command line interface as 'vcftools' and 'plink', respectively. 

 CITATION
 Bagley JC (2017) RADish v0.1.0. GitHub repository, Available at: 
	<http://github.com/justincbagley/RADish>.

 REFERENCES
 Bagley JC (2017) RADish v0.1.0. GitHub repository, Available at: 
	<http://github.com/justincbagley/RADish>.
 Chang CC, Chow CC, Tellier LCAM, Vattikuti S, Purcell SM, Lee JJ (2015) Second-generation 
	PLINK: rising to the challenge of larger and richer datasets. GigaScience, 4.
 Danecek P, Auton A, Abecasis G, Albers CA, Banks E, DePristo MA, Handsaker RE, Lunter G, 
 	Marth GT, Sherry ST, McVean G (2011) The variant call format and VCFtools. Bioinformatics, 
 	27, 2156-2158.
 Purcell SM, Chang CC (2017) PLINK v1.9. [software] Available from:
	<http://www.cog-genomics.org/plink/1.9/> (Last accessed 15 May 2018).
"

if [[ "$1" == "-h" ]] || [[ "$1" == "-help" ]]; then
	echo "$Usage"
	exit
fi

echo "
##########################################################################################
#                           VCF2minor012 v0.2.0, October 2021                            #
##########################################################################################
"

######################################## START ###########################################

###### Setup:
MY_PATH=`pwd -P`
echo "INFO      | $(date) |          Setting working directory to: $MY_PATH "
TAB=$(printf '\t');

###### Check machine type:
echo "INFO      | $(date) |          Checking machine type... "
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


###### Convert VCF to plink with vcftools:
echo "INFO      | $(date) |          Converting input VCF to PLINK ped format... "

	# Get VCF name characteristics and set basename:
	MY_INPUT_VCF=$(basename -- "$1")
	MY_INPUT_VCF_EXTENSION="${MY_INPUT_VCF##*.}"
	MY_VCF_BASENAME="$(basename $1 ."$MY_INPUT_VCF_EXTENSION")"
	echo "INFO      | $(date) |          Input VCF: ${MY_INPUT_VCF}"
	echo "INFO      | $(date) |          Input VCF basename: ${MY_VCF_BASENAME}"
	#echo "$MY_VCF_BASENAME"

	# Do conversion:
	vcftools --vcf $1 --plink --out "$MY_VCF_BASENAME"_plink

echo "INFO      | $(date) |          Fixing PLINK .map file... "
	# Fix plink .map file, which will have contig numbers for each SNP that will be mistaken 
	# by plink in the next step as human chromosome numbers and throw the following error: 
	#
	# 	Error: Invalid chromosome code '27' on line 298 of .map file.
	# 	(This is disallowed for humans.  Check if the problem is with your data, or if
	# 	you forgot to define a different chromosome set with e.g. --chr-set.).
	#
	# We can fix this by changing the chromosome numbers (raw 1st col #s) to be contig 
	# names/numbers, as follows:
	if [[ -s "$MY_VCF_BASENAME"_plink.map ]] && [[ "$machine" = "Mac" ]]; then 
		sed -i '' 's/^/Contig\_/g' "$MY_VCF_BASENAME"_plink.map ;
	fi
	if [[ -s "$MY_VCF_BASENAME"_plink.map ]] && [[ "$machine" = "Linux" ]]; then 
		sed -i 's/^/Contig\_/g' "$MY_VCF_BASENAME"_plink.map ;
	fi
	

###### Make recode12 ped file with 1 individual per row, and '012'-coded SNP genotypes in 
## columns:
## Here, "$MY_VCF_BASENAME"_plink indicates the basename of the .ped and .map files, both 
## of which are needed and are (must be) present in the current working directory for the 
## conversions to 012/minor012 files to work.
echo "INFO      | $(date) |          Converting ped file to '012' genotype matrix... "

	# OLD CODE (now deprecated in part):
	# plink --file "$MY_VCF_BASENAME"_plink --recode12 --tab --out "$MY_VCF_BASENAME"_plink_recode12
	# NEW CODE:
	plink --file "$MY_VCF_BASENAME"_plink --recode 12 --tab --out "$MY_VCF_BASENAME"_plink_recode12 --allow-extra-chr 0

  
  
###### Copy ped recode file to 'minor012.txt' file, and then recode the file according to 
## the minor allele counts:
## Key for genotype coding changes:
## 0 0 - missing data 	 --> -9
## 1 1 - 2 minor alleles --> 2
## 1 2 - 1 minor allele  --> 1
## 2 2 - 0 minor alleles --> 0
echo "INFO      | $(date) |          Converting regular 012 matrix to minor allele-coded 012 matrix named $2.txt... "

	cp ./"$MY_VCF_BASENAME"_plink_recode12.ped ./"$2".txt;

	sed -i 's/'"$TAB"'0\ 0/'"$TAB"'\-9/g; s/'"$TAB"'1\ 1/'"$TAB"'2/g; s/'"$TAB"'1\ 2/'"$TAB"'1/g; s/'"$TAB"'2\ 2/'"$TAB"'0/g' ./"$2".txt;
	mkdir minor012;
	cp ./"$2".txt ./minor012/"$2".txt;


###### File checks etc.:
echo "INFO      | $(date) |          Finalizing directory structure, conducting final file checks... "

	mkdir checks;
	cat ./"$MY_VCF_BASENAME"_plink_recode12.ped | awk '{print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15}' | head -n40 > ./checks/ped_recode12_15x40Check.txt;
	head -n1 ./"$MY_VCF_BASENAME"_plink_recode12.ped > ./checks/ped_recode12_head1.txt;

	cat ./"$2".txt | awk '{print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15}' | head -n40 > ./checks/"$2"_15x40Check.txt;
	head -n1 ./"$2".txt > ./checks/"$2"_head1.txt;

	mkdir 012
	mv ./"$MY_VCF_BASENAME"_plink_recode12.ped ./012/


echo "INFO      | $(date) | Done converting SNPs from VCF format to regular and minor allele-coded 012 genotype formats using VCF2minor012.sh. "
echo "INFO      | $(date) | Bye.
"
#
#
#
######################################### END ############################################


exit 0
