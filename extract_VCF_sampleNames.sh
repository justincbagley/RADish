#!/bin/sh

##########################################################################################
#      ____  ___    ____  _      __                                                      #
#     / __ \/   |  / __ \(_)____/ /_                                                     #
#    / /_/ / /| | / / / / / ___/ __ \                                                    #
#   / _, _/ ___ |/ /_/ / (__  ) / / /                                                    #
#  /_/ |_/_/  |_/_____/_/____/_/ /_/                                                     #
#                    extract_VCF_sampleNames.sh v0.1.0, February 2019                    #
#  SHELL SCRIPT THAT GENERATES SAMPLE NAME LISTS FROM VCF FILES IN CURRENT DIRECTORY     #
#  Copyright ©2018 Justinc C. Bagley. For further information, see README and license    #
#  available in the RADish repository (https://github.com/justincbagley/RADish/). Last   #
#  update: February 4, 2019. For questions, please email bagleyj@umsl.edu.               #
##########################################################################################

############ SCRIPT OPTIONS
## OPTION DEFAULTS ##
ALL_VCF_PWD_SWITCH=1
SINGLE_VCF_SWITCH=0
MY_OUTPUT_FILE_SWITCH=NULL

############ CREATE USAGE & HELP TEXTS
Usage="Usage: $(basename "$0") [Help: -h help] [Options: -a s o] workingDir 
 ## Help:
  -h   help text (also: -help)

 ## Options:
  -a   allVCFs (def: 1, on; other: 0, off) specify to run on all VCF files in specified 
       working directory, <workingDir>
  -s   singleVCF (def: 0, off; other: <VCF_filename>) call to run on a single VCF file with 
       user-specified name, <VCF_filename>, that must follow this flag
  -o   outputFile (def: NULL) specify name of output file (in case of -a 1, this is a partial
       basename for output text files for all VCFs; case -s 1, this is the full basename for 
       the output file for a single VCF)

 OVERVIEW
 Generates a list of sample names from variant call format (VCF; Danecek et al. 2011) files 
 (extension '.vcf', '.VCF') in current working directory (cwd). User may specify to run while 
 looping through all VCF files in cwd (-a 1; default) or to run on a single VCF file (-s 
 <VCF_filename>). After options, user must specify path to working directory, <workingDir>,
 which is a mandatory positional parameter (e.g. absolute path, relative path, '.' for current
 directory, or '..' for up one directory). All output is written to text files ('.txt') in
 <workingDir>. This script has been tested on UNIX/LINUX systems.

 CITATION
 Bagley JC (2017) RADish v0.1.0. GitHub repository, Available at: 
	<http://github.com/justincbagley/RADish>.

 REFERENCES
 Danecek P, Auton A, Abecasis G, Albers CA, Banks E, DePristo MA, ... , McVean G (2011) The 
	variant call format and VCFtools. Bioinformatics, 27(15), 2156-2158.
"

if [[ "$1" == "-h" ]] || [[ "$1" == "-help" ]]; then
	echo "$Usage"
	exit
fi

############ PARSE THE OPTIONS
while getopts 'a:s:o:' opt ; do
  case $opt in

## extract_VCF_SNP_IDs options:
    a) ALL_VCF_PWD_SWITCH=$OPTARG ;;
    s) SINGLE_VCF_SWITCH=$OPTARG ;;
    o) MY_OUTPUT_FILE_SWITCH=$OPTARG ;;

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

echo "INFO      | $(date) |          Setting user-specified path to: $USER_SPEC_PATH "
#echo "$USER_SPEC_PATH "	

echo "INFO      | $(date) |          Finding sample names and saving them to file... "

if [[ "$ALL_VCF_PWD_SWITCH" -eq "1" ]] && [[ "$SINGLE_VCF_SWITCH" = "0" ]] && [[ "$MY_OUTPUT_FILE_SWITCH" = "NULL" ]]; then

	(
		for i in ./*.vcf; do
			echo "INFO      | $(date) |          ###     $i     ### "
			grep -h "^\#CHROM.*FORMAT" "$i" | perl -pe $'s/^\#CHROM.*FORMAT\t//g' | perl -pe $'s/\t/\n/g' > "$i".samples.txt
			MY_NUM_SAMPLE_NAMES="$(cat ${i}.samples.txt | perl -pe $'s/\t//g; s/\ //g' | wc -l)"
			echo "INFO      | $(date) |          Saved $MY_NUM_SAMPLE_NAMES sample names to file.  "
		done
	)
fi

if [[ "$ALL_VCF_PWD_SWITCH" -eq "1" ]] && [[ "$SINGLE_VCF_SWITCH" = "0" ]] && [[ ! "$MY_OUTPUT_FILE_SWITCH" = "NULL" ]]; then

	(
		for i in ./*.vcf; do
			echo "INFO      | $(date) |          ###     $i     ### "
			grep -h "^\#CHROM.*FORMAT" "$i" | perl -pe $'s/^\#CHROM.*FORMAT\t//g' | perl -pe $'s/\t/\n/g' > "$i"."$MY_OUTPUT_FILE_SWITCH".txt
			MY_NUM_SAMPLE_NAMES="$(cat ${i}.${MY_OUTPUT_FILE_SWITCH}.txt | perl -pe $'s/\t//g; s/\ //g' | wc -l)"
			echo "INFO      | $(date) |          Saved $MY_NUM_SAMPLE_NAMES sample names to file.  "
		done
	)
fi

if [[ ! "$SINGLE_VCF_SWITCH" = "0" ]] && [[ "$MY_OUTPUT_FILE_SWITCH" = "NULL" ]]; then
	grep -h "^\#CHROM.*FORMAT" "$SINGLE_VCF_SWITCH" | perl -pe $'s/^\#CHROM.*FORMAT\t//g' | perl -pe $'s/\t/\n/g' > "$SINGLE_VCF_SWITCH".samples.txt
	MY_NUM_SAMPLE_NAMES="$(cat ${SINGLE_VCF_SWITCH}.samples.txt | perl -pe $'s/\t//g; s/\ //g' | wc -l)"
	echo "INFO      | $(date) |          Saved $MY_NUM_SAMPLE_NAMES sample names to file.  "
fi

if [[ ! "$SINGLE_VCF_SWITCH" = "0" ]] && [[ ! "$MY_OUTPUT_FILE_SWITCH" = "NULL" ]]; then
	grep -h "^\#CHROM.*FORMAT" "$SINGLE_VCF_SWITCH" | perl -pe $'s/^\#CHROM.*FORMAT\t//g' | perl -pe $'s/\t/\n/g' > "$MY_OUTPUT_FILE_SWITCH".txt
	MY_NUM_SAMPLE_NAMES="$(cat ${MY_OUTPUT_FILE_SWITCH}.txt | perl -pe $'s/\t//g; s/\ //g' | wc -l)"
	echo "INFO      | $(date) |          Saved $MY_NUM_SAMPLE_NAMES sample names to file.  "
fi

echo "INFO      | $(date) |          Done. Bye. "


exit 0
