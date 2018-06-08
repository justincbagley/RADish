#!/bin/sh

##########################################################################################
#      ____  ___    ____  _      __                                                      #
#     / __ \/   |  / __ \(_)____/ /_                                                     #
#    / /_/ / /| | / / / / / ___/ __ \                                                    #
#   / _, _/ ___ |/ /_/ / (__  ) / / /                                                    #
#  /_/ |_/_/  |_/_____/_/____/_/ /_/                                                     #
#                       bayenv2SNPSFILESplitter v0.1.0, June 2018                        #
#  SCRIPT FOR SPLITTING SNPSFILE FOR BAYENV2 INTO SEPARATE SNPFILES, ONE PER SNP, FOR    #
#  SUBSEQUENT LONG ENVIRONMENTAL ASSOCIATION ANALYSES IN BAYENV2                         #
#  Copyright ©2018 Justinc C. Bagley. For further information, see README and license    #
#  available in the RADish repository (https://github.com/justincbagley/RADish/). This   #
#  script was last updated June 8, 2018. For questions, please email jcbagley@vcu.edu.   #
##########################################################################################

############ SCRIPT OPTIONS
## OPTION DEFAULTS ##
MY_SNPSFILE=SNPSFILE.txt
MY_NUM_SNPS=1000

############ CREATE USAGE & HELP TEXTS
## Justin's Usage note: 
# ./bayenv2SNPSFILESplitter.sh -i <inputSNPSFILE> -n <numSNPs> <workingDir>
# ./bayenv2SNPSFILESplitter.sh -i SWWP_104_SNPSFILE.txt -n 72845 .

## Usage text for users:
Usage="Usage: $(basename "$0") [Help: -h help] -i <inputSNPSFILE> -n <numSNPs> <workingDir> 
 ## Help:
  -h   help text (also: -help)

 ## Options:
  -i   inputSNPSFILE (def: SNPSFILE.txt) name of input SNPSFILE for BAYENV2
  -n   numSNPs (def: 1000) total number of SNPs in data matrix

 OVERVIEW
 THIS SCRIPT converts a SNPSFILE input file formatted for BAYENV2 (Günther and Coop 2013) 
 into separate files, one per SNP, for subsequent environmental association analysis in 
 BAYENV2. All flags are mandatory, as is the user specification of the <workingDir> (e.g. 
 '.' for the current working directory). The default value for the total number of SNPs is 
 '1000' and this is just a general value that most users will want to set to the correct 
 number of SNPs in their datasets. If this value undershoots the actual number of SNPs, then 
 SNPs that are left out wil not be present in the resulting BAYENV2 input files (and down-
 stream output will be of different length than expected). See the BAYENV2 user manual for
 further details including file format specifications.

 CITATION
 Bagley, J.C. 2017. RADish v0.1.0. GitHub repository, Available at:  
	<http://github.com/justincbagley/RADish>.

 REFERENCES
 Günther T, Coop G (2013) Robust identification of local adaptation from allele frequencies. 
	Genetics, 195(1), 205-220.
"

if [[ "$1" == "-h" ]] || [[ "$1" == "-help" ]]; then
	echo "$Usage"
	exit
fi

############ PARSE THE OPTIONS
while getopts 'i:n:' opt ; do
  case $opt in

## script options:
    i) MY_SNPSFILE=$OPTARG ;;
    n) MY_NUM_SNPS=$OPTARG ;;

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
USER_SPEC_PATH="$1"

echo "
##########################################################################################
#                       bayenv2SNPSFILESplitter v0.1.0, June 2018                        #
##########################################################################################
"

######################################## START ###########################################
## SETUP

echo "INFO      | $(date) |          User-specified path is: "
echo "$USER_SPEC_PATH "	
calc () { 
	bc -l <<< "$@"  
}


	################################## SNPSFILEsplitter ##################################

SNPSFILEsplitter () {	

cp "$MY_SNPSFILE" ./SNPs.tmp
mkdir SNPFILEs/

echo "INFO      | $(date) |          Splitting input SNPSFILE $MY_SNPSFILE into one file per SNP... "
{
	(
		for i in $(seq 1 "$MY_NUM_SNPS"); do
			sed -n "1,2p" ./SNPs.tmp > ./SNPFILEs/SNP_"$i".txt
			sed -i "1,2d" ./SNPs.tmp
		done
	)
} &> /dev/null

rm ./SNPs.tmp

}

SNPSFILEsplitter

echo "INFO      | $(date) |          Conducting final check on number of SNPFILES generated... "

cd ./SNPFILEs/
MY_NUM_SNPFILES_GEN="$(	ls . | wc -l | sed 's/\ //g')"
if [[ "$MY_NUM_SNPFILES_GEN" -eq "$MY_NUM_SNPS" ]]; then
	echo "INFO      | $(date) |               Everything looks good! "
else
	echo "WARNING!  | $(date) |               Oops! Expected $MY_NUM_SNPS files, but found only $MY_NUM_SNPFILES_GEN. Quitting...  "
	exit 1
fi


echo "INFO      | $(date) |          Done splitting up your SNPSFILE. "
echo "INFO      | $(date) |          Bye. "

exit 0

