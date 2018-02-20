#!/bin/sh

############ SCRIPT OPTIONS
## OPTION DEFAULTS ##
MY_FILENAME=NULL
MY_STARTING_BASE=1
MY_TRIM_LENGTH=100
MY_OUTPUTFILE=NULL

############ CREATE USAGE & HELP TEXTS
Usage="Usage: $(basename "$0") [Help: -h help] [Options: -i l] workingDir 
 ## Help:
  -h   help text (also: -help)

 ## Options:
  -i   inputFile (def: NULL) file name, in case of single input file
  -b   startingBase (def: 1) nucleotide position to start keeping bases from
       (=also starting position for counting up to trim point)
  -l   trimLength (def: $MY_TRIM_LENGTH) desired final length of reads
  -o   outputFile (def: NULL) output file name
  
 OVERVIEW
 Trims one or more fastq files from their original length to the length (trimLength) 
 desired by the user, by trimming off bases from the right (3') end of sequence reads
 in the fastq file(s). Useful for trimming reads from multiple lanes or assemblies so 
 that they all have the same length prior to calling SNPs or merging assemblies. For 
 example, the author has used this script to prepare fastqs from different lanes of 
 Illumina sequencing on different or mixed sets of samples prior to de novo or 
 reference-based assembly and SNP calling in pyRAD (Eaton 2014) or ipyrad (Eaton and 
 Overcast 2017). 

 CITATION
 Bagley, J.C. 2017. RADish v0.1.0. GitHub repository, Available at: 
	<http://github.com/justincbagley/RADish>.

 REFERENCES
 Eaton DA (2014) PyRAD: assembly of de novo RADseq loci for phylogenetic analyses. 
	Bioinformatics, 30, 1844-1849.
 Eaton DAR, Overcast I (2017) ipyrad: interactive assembly and analysis of RADseq data sets. 
	Available at: <http://ipyrad.readthedocs.io/>.
"

if [[ "$1" == "-h" ]] || [[ "$1" == "-help" ]]; then
	echo "$Usage"
	exit
fi

############ PARSE THE OPTIONS
while getopts 'i:b:l:o:' opt ; do
  case $opt in

## trimmer options:
    i) MY_FILENAME=$OPTARG ;;
    b) MY_STARTING_BASE=$OPTARG ;;
    l) MY_TRIM_LENGTH=$OPTARG ;;
    o) MY_OUTPUTFILE=$OPTARG ;;

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

echo "INFO      | $(date) |          Setting user-specified path to: "
echo "$USER_SPEC_PATH "	


echo "
##########################################################################################
#                         fastqTrimmer.sh v0.1.0, February 2018                          #
##########################################################################################
"

######################################## START ###########################################
echo "INFO      | $(date) | STEP #1: SETUP. "
###### Set new path/dir environmental variable to user specified path, then create useful
##--shell functions and variables:
if [[ "$USER_SPEC_PATH" = "$(echo $(pwd))" ]]; then
	MY_PATH=`pwd -P`
	echo "INFO      | $(date) |          Setting working directory to: $MY_PATH "
elif [[ "$USER_SPEC_PATH" != "$(echo $(pwd))" ]]; then
	MY_PATH=$USER_SPEC_PATH
	echo "INFO      | $(date) |          Setting working directory to: $MY_PATH "	
else
	echo "WARNING!  | $(date) |          Null working directory path. Quitting... "
	exit 1
fi
	CR=$(printf '\r'); 
	calc () { 
		bc -l <<< "$@" 
}

##--Move into user specified path (solves problem of executing analysis for non-local
##--working dir):
	cd $MY_PATH

## Pseudocode:

if only i is specified; then
  warning will trim file in place
  cut -c 1-trimLength ./inputFile.fastq > ./inputFile.fastq.tmp
  rm ./inputFile.fastq
  mv ./inputFile.fastq.tmp ./inputFile.fastq
elif i and o are specified; then
  cut -c 1-trimLength ./inputFile.fastq > ./outputFile.fastq
fi

if i = NULL; then
  (
    for i in ./*.fastq; do
      MYBASENAME="$()" 
      cut -c 1-trimLength ./Strauss_GBS.fastq > ./Strauss_GBS_trim.fastq
    done
  )
fi

exit 0

