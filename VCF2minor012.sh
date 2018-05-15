#!/bin/bash


##########################################################################################
#                             VCF2minor012 v0.1.0, May 2018                              #
#  CONVERTS INPUT VCF FILE INTO MINOR ALLELE-CODED 012 GENOTYPE MATRIX, VIA PLINK        #
#  Copyright ©2018 Justinc C. Bagley. For further information, see README and license    #
#  available in the RADish repository (https://github.com/justincbagley/RADish/. This    #
#  script was last updated May 15, 2018. For questions, please email jcbagley@vcu.edu.   #
##########################################################################################

############ SCRIPT OPTIONS
## OPTION DEFAULTS ##
#MY_INPUT_VCF=input.vcf
#MY_MINOR012_OUTPUT=minor012.txt

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
 counts of the minor allele. The main dependency of this software is PLINK v1.9++ (Purcell
 and Chang 2017), which must be available from the user's command line interface as 'plink'. 

 CITATION
 Bagley, J.C. 2017. RADish v0.1.0. GitHub repository, Available at: 
	<http://github.com/justincbagley/RADish>.

 REFERENCES
 Chang CC, Chow CC, Tellier LCAM, Vattikuti S, Purcell SM, Lee JJ (2015) Second-generation 
	PLINK: rising to the challenge of larger and richer datasets. GigaScience, 4.
 Purcell SM, Chang CC (2017) PLINK v1.9. [software] Available from:
	<http://www.cog-genomics.org/plink/1.9/> (Last accessed 15 May 2018).
"

if [[ "$1" == "-h" ]] || [[ "$1" == "-help" ]]; then
	echo "$Usage"
	exit
fi

echo "
##########################################################################################
#                             VCF2minor012 v0.1.0, May 2018                              #
##########################################################################################
"

######################################## START ###########################################

###### Setup:
MY_PATH=`pwd -P`
echo "INFO      | $(date) |          Setting working directory to: $MY_PATH "
TAB=$(printf '\t');


###### Make recode12 ped file with 1 individual per row, and '012'-coded SNP genotypes in 
## columns:
## Here, '$MY_VCF_BASENAME' is an environmental variable containing the basename of the 
## .ped and .map files, both of which are needed and are (must be) present in the current 
## working directory for the conversions to 012/minor012 files to work.
MY_VCF_BASENAME="$(basename $1)"
echo "$MY_VCF_BASENAME"

plink --file "$MY_VCF_BASENAME" --recode12 --tab --out "$MY_VCF_BASENAME"_recode12


###### Copy ped recode file to 'minor012.txt' file, and then recode the file according to 
## the minor allele counts:
## Key for genotype coding changes:
## 0 0 - missing data 	 --> -9
## 1 1 - 2 minor alleles --> 2
## 1 2 - 1 minor allele  --> 1
## 2 2 - 0 minor alleles --> 0
cp ./"$MY_VCF_BASENAME"_recode12.ped ./"$2".txt;

sed -i 's/'"$TAB"'0\ 0/'"$TAB"'\-9/g; s/'"$TAB"'1\ 1/'"$TAB"'2/g; s/'"$TAB"'1\ 2/'"$TAB"'1/g; s/'"$TAB"'2\ 2/'"$TAB"'0/g' ./"$2".txt;
mkdir minor012;
cp ./"$2".txt ./minor012/"$2".txt;


## File checks:
mkdir checks;
cat ./"$MY_VCF_BASENAME"_recode12.ped | awk '{print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15}' | head -n40 > ./checks/ped_recode12_15x40Check.txt;
head -n1 ./"$MY_VCF_BASENAME"_recode12.ped > ./checks/ped_recode12_head1.txt;

cat ./"$2".txt | awk '{print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15}' | head -n40 > ./checks/"$2"_15x40Check.txt;
head -n1 ./"$2".txt > ./checks/"$2"_head1.txt;



echo "INFO      | $(date) | Done converting SNPs from VCF format to minor-allele coded 012 genotype format using VCF2minor012.sh. "
echo "INFO      | $(date) | Bye.
"
#
#
#
######################################### END ############################################


exit 0


