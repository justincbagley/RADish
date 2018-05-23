#!/bin/sh

##########################################################################################
#                            removeFixedSNPs v0.1.0, May 2018                            #
#  SCRIPT THAT AUTOMATES REMOVING MONOMORPHIC SNP LOCI (FIXED SNPs), IF PRESENT, FROM    #
#  BAYENV2 INPUT SNPSFILE; ALSO WORKS ON HEADLESS/NONINDEXED GENO FILE (e.g. MINOR       #
#  ALLELE-CODED GENOTYPE SNP MATRIX FILES)                                               #
#  Copyright ©2018 Justinc C. Bagley. For further information, see README and license    #
#  available in the RADish repository (https://github.com/justincbagley/RADish/). This   #
#  script was last updated May 22, 2018. For questions, please email jcbagley@vcu.edu.   #
##########################################################################################

##  USAGE: ./removeFixedSNPs.sh <bayenvInput> <zeroSumRowList>
##    e.g. ./removeFixedSNPs.sh ./toy.txt ./zero.txt						## PREP
##    e.g. ./removeFixedSNPs.sh ./bayenv2_input.txt ./bayenvZeroLines.txt	## REAL LIFE

####### SETUP:
calc () { 
	bc -l <<< "$@" 
}

echo "
##########################################################################################
#                            removeFixedSNPs v0.1.0, May 2018                            #
##########################################################################################
"


####### CHECK MACHINE TYPE:
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
echo "INFO      | $(date) | System: ${machine}"



if [[ "${machine}" = "Mac" ]]; then

####### CASE 1: LOCAL MAC MACHINE 

####### RUN LOCALLY:
(
	echo "INFO      | $(date) | Removing problem SNP #1... "
	line="$(head -n1 $2)"
#
		if [[ $((line % 2)) -eq 0 ]]; then
			##echo "$var is even"; 
			MY_LINE_MINUS_ONE="$(calc $line-1)";
			sed -i '' ''"$MY_LINE_MINUS_ONE"','"$line"'d' "$1";
		else 
			##echo "$var is odd"; 
			MY_LINE_PLUS_ONE="$(calc $line+1)";
			sed -i '' ''"$line"','"$MY_LINE_PLUS_ONE"'d' "$1"; 
		fi
#
)

sed -i '' '1d' "$2"

(
	count=1
	while read line; do
#
		MY_DIFF="$(calc $count*2)"
		MY_NEW_LINE="$(calc $line-$MY_DIFF)"
		if [[ $((line % 2)) -eq 0 ]]; then
			##echo "$var is even"; 
			MY_NEW_LINE_MINUS_ONE="$(calc $MY_NEW_LINE-1)";
			sed -i '' ''"$MY_NEW_LINE_MINUS_ONE"','"$MY_NEW_LINE"'d' "$1";
		else 
			##echo "$var is odd"; 
			MY_NEW_LINE_PLUS_ONE="$(calc $MY_NEW_LINE+1)";
			sed -i '' ''"$MY_NEW_LINE"','"$MY_NEW_LINE_PLUS_ONE"'d' "$1"; 
		fi
#
	MY_COUNT_PLUS_ONE="$(calc $count+1)"
	echo "INFO      | $(date) | $((count++))+1 = Removing problem SNP #$MY_COUNT_PLUS_ONE... "
	done < "$2"

)

fi




if [[ "${machine}" = "Linux" ]]; then

####### CASE 2: LINUX AND/OR LINUX-BASED SUPERCOMPUTER ENVIRONMENT 

####### RUN ON LINUX AND/OR LINUX-BASED SUPERCOMPUTER:
(
	echo "INFO      | $(date) | Removing problem SNP #1... "
	line="$(head -n1 $2)"
#
		if [[ $((line % 2)) -eq 0 ]]; then
			##echo "$var is even"; 
			MY_LINE_MINUS_ONE="$(calc $line-1)";
			sed -i ''"$MY_LINE_MINUS_ONE"','"$line"'d' "$1";
		else 
			##echo "$var is odd"; 
			MY_LINE_PLUS_ONE="$(calc $line+1)";
			sed -i ''"$line"','"$MY_LINE_PLUS_ONE"'d' "$1"; 
		fi
#
)

sed -i '1d' "$2"

(
	count=1
	while read line; do
#
		MY_DIFF="$(calc $count*2)"
		MY_NEW_LINE="$(calc $line-$MY_DIFF)"
		if [[ $((line % 2)) -eq 0 ]]; then
			##echo "$var is even"; 
			MY_NEW_LINE_MINUS_ONE="$(calc $MY_NEW_LINE-1)";
			sed -i ''"$MY_NEW_LINE_MINUS_ONE"','"$MY_NEW_LINE"'d' "$1";
		else 
			##echo "$var is odd"; 
			MY_NEW_LINE_PLUS_ONE="$(calc $MY_NEW_LINE+1)";
			sed -i ''"$MY_NEW_LINE"','"$MY_NEW_LINE_PLUS_ONE"'d' "$1"; 
		fi
#
	MY_COUNT_PLUS_ONE="$(calc $count+1)"
	echo "INFO      | $(date) | $((count++))+1 = Removing problem SNP #$MY_COUNT_PLUS_ONE... "
	done < "$2"

)

fi




exit 0

