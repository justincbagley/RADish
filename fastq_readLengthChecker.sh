#!/bin/sh

##########################################################################################
#      ____  ___    ____  _      __                                                      #
#     / __ \/   |  / __ \(_)____/ /_                                                     #
#    / /_/ / /| | / / / / / ___/ __ \                                                    #
#   / _, _/ ___ |/ /_/ / (__  ) / / /                                                    #
#  /_/ |_/_/  |_/_____/_/____/_/ /_/                                                     #
#                     fastq_ReadLengthChecker v0.1.0, February 2018                      #
#  SHELL SCRIPT FOR CHECKING AND SUMMARIZING LENGTHS OF READS IN FASTQ FILES             #
#  Copyright ©2018 Justinc C. Bagley. For further information, see README and license    #
#  available in the RADish repository (https://github.com/justincbagley/RADish/). Last   #
#  update: February 22, 2018. For questions, please email jcbagley@vcu.edu.              #
##########################################################################################

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
#                     fastq_ReadLengthChecker v0.1.0, February 2018                      #
##########################################################################################
"

if [[ -s names.txt  ]]; then
	rm ./names.txt
fi
if [[ -s lengths.txt  ]]; then
	rm ./lengths.txt
fi

(
	for i in ./*.fastq; do 
		echo "$i" >> names.txt; 
		sed -n '2p' "$i" | wc -c >> lengths.txt; 
	done 
)

NUM_FASTQS="$(wc -l ./names.txt | sed 's/\ \.\/names\.txt//g' | sed 's/\ //g')"
echo "INFO      | $(date) | Found $NUM_FASTQS .fastq files in current working directory. "

paste ./names.txt ./lengths.txt > fastq_lengths_summary.tmp

echo "file	read_length" > header.tmp

cat ./header.tmp ./fastq_lengths_summary.tmp > ./fastq_lengths_summary.txt

SHORTEST_READS="$(cut -f2 -d$'\t' fastq_lengths_summary.txt | sort -n | head -2 | tail -n1 | sed 's/\ //g')"
LONGEST_READS="$(cut -f2 -d$'\t' fastq_lengths_summary.txt | sort -n | tail -1 | tail -n1 | sed 's/\ //g')"

echo "INFO      | $(date) | Shortest read length: $SHORTEST_READS bp "
echo "INFO      | $(date) | Longest read length: $LONGEST_READS bp "
echo "INFO      | $(date) | Results output to 'fastq_lengths_summary.txt' in current working directory."

echo "INFO      | $(date) | "
echo "INFO      | $(date) | ...Cleaning up workspace... "
rm ./header.tmp ./fastq_lengths_summary.tmp ./names.txt ./lengths.txt

echo "INFO      | $(date) | "
echo "INFO      | $(date) | Done checking fastq read lengths. "
echo "INFO      | $(date) | Bye.
"
#
#
#
######################################### END ############################################

exit 0

