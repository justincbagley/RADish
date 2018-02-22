# RADish

Scripts aiding file processing and analysis of RADseq and GBS data

## LICENSE

All code within the ```RADish``` v0.1.0 repository is available "AS IS" under a generous GNU license. See the [LICENSE](LICENSE) file for more information.

## CITATION

If you use scripts from this repository as part of your published research, I require that you cite the repository as follows (also see DOI information below): 
  
- Bagley, J.C. 2017. RADish. GitHub repository, Available at: http://github.com/justincbagley/RADish.

Alternatively, please provide the following link to this software repository in your manuscript:

- https://github.com/justincbagley/RADish


### fastq_ReadLengthChecker

Example usage code and output to screen during a ```fastq_ReadLengthChecker.sh``` run, in which
reads were discovered to range from 78 bp to 140 bp in length:

```
$ ./fastq_readLengthChecker.sh .

##########################################################################################
#                     fastq_ReadLengthChecker v0.1.0, February 2018                      #
##########################################################################################

INFO      | Wed Feb 21 17:58:12 EST 2018 | Found 1123 .fastq files in current working directory. 
INFO      | Wed Feb 21 17:58:12 EST 2018 | Shortest read length: 78 bp 
INFO      | Wed Feb 21 17:58:12 EST 2018 | Longest read length: 140 bp 
INFO      | Wed Feb 21 17:58:12 EST 2018 | Results output to 'fastq_lengths_summary.txt' in current working directory.
INFO      | Wed Feb 21 17:58:12 EST 2018 | 
INFO      | Wed Feb 21 17:58:12 EST 2018 | ...Cleaning up workspace... 
INFO      | Wed Feb 21 17:58:12 EST 2018 | 
INFO      | Wed Feb 21 17:58:12 EST 2018 | Done checking fastq read lengths. 
INFO      | Wed Feb 21 17:58:12 EST 2018 | Bye.
```

### fastqTrimmer

Example usage code and output to screen during a ```fastqTrimmer.sh``` run, in which all fastq
files within the working directory were trimmed down to the first 1-91 bases:

```
$ ./fastqTrimmer.sh -l 91 .

##########################################################################################
#                           fastqTrimmer v0.1.0, February 2018                           #
##########################################################################################

INFO      | Thu Feb 22 09:32:59 MST 2018 | STEP #1: SETUP. 
INFO      | Thu Feb 22 09:32:59 MST 2018 |          Setting working directory to: . 
INFO      | Thu Feb 22 09:32:59 MST 2018 | STEP #2: TRIMMING READS. 
INFO      | Thu Feb 22 09:32:59 MST 2018 |          Trimming reads in all .fastq files in current directory. Trimmed files will be moved to 
INFO      | Thu Feb 22 09:32:59 MST 2018 |          ./trimmed_fastq/, and original fastq files will be moved to ./orig_fastq/.  
./APA1_1.R1.fastq
./APA1_2.R1.fastq
./APA1_3.R1.fastq
./APA1_4.R1.fastq
./APA1_5.R1.fastq
./APA1_6.R1.fastq
./APA1_7.R1.fastq
./APA1_8.R1.fastq
./CAP1H_10.R1.fastq
./CAP1H_1.R1.fastq
./CAP1H_2.R1.fastq
./CAP1H_3.R1.fastq
./CAP1H_4.R1.fastq
./CAP1H_5.R1.fastq
./CAP1H_6.R1.fastq
./CAP1H_7.R1.fastq
./CAP1H_8.R1.fastq
./CAP1H_9.R1.fastq
./CAP1L_10.R1.fastq
./CAP1L_1.R1.fastq
.
.
.
```


February 22, 2018
Justin C. Bagley, Richmond, VA, USA
