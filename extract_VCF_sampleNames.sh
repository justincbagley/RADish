#!/bin/sh

##########################################################################################
#      ____  ___    ____  _      __                                                      #
#     / __ \/   |  / __ \(_)____/ /_                                                     #
#    / /_/ / /| | / / / / / ___/ __ \                                                    #
#   / _, _/ ___ |/ /_/ / (__  ) / / /                                                    #
#  /_/ |_/_/  |_/_____/_/____/_/ /_/                                                     #
#                    extract_VCF_sampleNames.sh v0.1.0, November 2018                    #
#  SHELL SCRIPT THAT GENERATES SAMPLE NAME LISTS FROM VCF FILES IN CURRENT DIRECTORY     #
#  Copyright ©2018 Justinc C. Bagley. For further information, see README and license    #
#  available in the RADish repository (https://github.com/justincbagley/RADish/). Last   #
#  update: November 6, 2018. For questions, please email bagleyj@umsl.edu.               #
##########################################################################################

## Generates a list of sample names, one per each VCF (*.vcf) file in current working dir, 
## and writes output to single '_samples.txt' file. Tested on UNIX/LINUX systems.

(
	for i in ./*.vcf; do
		MY_BASENAME="$(basename $i .vcf)"
		grep -h "^#CHROM" "$i" | sed 's/^.*FORMAT    //; s/  /\n/g' > "$MY_BASENAME"_samples.txt
	done
)

exit 0
