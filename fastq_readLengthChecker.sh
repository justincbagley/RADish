#!/bin/sh

############ SKIP OVER THE PROCESSED OPTIONS
shift $((OPTIND-1)) 
# Check for mandatory positional parameters
if [ $# -lt 1 ]; then
echo "$Usage"
  exit 1
fi
USER_SPEC_PATH="$1"


## fastq read length checker

## cd /gpfs_fs/home/eckertlab/Mitra/chapter2/dedupe

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

paste ./names.txt ./lengths.txt > fastq_lengths_summary.txt

echo "Results output to 'fastq_lengths_summary.txt' in current working directory."

exit 0

