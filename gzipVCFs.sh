#!/bin/sh

##########################################################################################
#      ____  ___    ____  _      __                                                      #
#     / __ \/   |  / __ \(_)____/ /_                                                     #
#    / /_/ / /| | / / / / / ___/ __ \                                                    #
#   / _, _/ ___ |/ /_/ / (__  ) / / /                                                    #
#  /_/ |_/_/  |_/_____/_/____/_/ /_/                                                     #
#                               gzipVCFs v0.1.0, July 2018                               #
#  SHELL SCRIPT THAT GZIPS AND INDEXES ALL VCF FILES IN CURRENT WORKING DIRECTORY        #
#  Copyright ©2018 Justinc C. Bagley. For further information, see README and license    #
#  available in the RADish repository (https://github.com/justincbagley/RADish/). Last   #
#  update: July 24, 2018. For questions, please email jcbagley@vcu.edu.                  #
##########################################################################################

## gzips and indexes all VCF (*.vcf) files in current working directory, outputting one 
## '*.vcf.gz' file and one '*.vcf.gz.tbi' file per input VCF. Relies upon bgzip and 
## tabix dependencies and has only been tested on UNIX/LINUX-type systems (macOS High 
## Sierra and CentOS 5/6/7).

(
for i in ./*.vcf; do
	bgzip -c "$i" > "$i".gz;
	tabix -p vcf "$i".gz;
done
)


exit 0
