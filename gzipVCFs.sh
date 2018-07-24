#!/bin/sh

## gzips and indexes all VCF (*.vcf) files in current working directory, outputting one 
## '*.vcf.gz' file and one '*.vcf.gz.tbi' file per input VCF.

(
for i in ./*.vcf; do
	bgzip -c "$i" > "$i".gz;
	tabix -p vcf "$i".gz;
done
)


exit 0
