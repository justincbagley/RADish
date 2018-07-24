#!/bin/sh

##########################################################################################
#      ____  ___    ____  _      __                                                      #
#     / __ \/   |  / __ \(_)____/ /_                                                     #
#    / /_/ / /| | / / / / / ___/ __ \                                                    #
#   / _, _/ ___ |/ /_/ / (__  ) / / /                                                    #
#  /_/ |_/_/  |_/_____/_/____/_/ /_/                                                     #
#                        extract_VCF_SNP_IDs.sh v0.1.0, July 2018                        #
#  SHELL SCRIPT THAT GENERATES LISTS OF SNP IDs FROM VCF FILES IN CURRENT DIRECTORY      #
#  Copyright ©2018 Justinc C. Bagley. For further information, see README and license    #
#  available in the RADish repository (https://github.com/justincbagley/RADish/). Last   #
#  update: July 24, 2018. For questions, please email jcbagley@vcu.edu.                  #
##########################################################################################

## Generates a list of SNP IDs, one per each VCF (*.vcf) file in current working directory, 
## and writes output to single '.txt' file. Tested on UNIX/LINUX systems.

(
	for i in ./*.vcf; do
		grep -v "^##" "$i" | cut -f3 > "$i".txt
	done
)

exit 0
