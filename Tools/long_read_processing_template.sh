#!/bin/sh
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute
#SBATCH --time=71:00:00
#SBATCH --nodes=1
#SBATCH --mem=60000
#SBATCH --ntasks-per-node=12
#SBATCH --job-name="LTrim-__SAMPLE_ID__"
#SBATCH --output=LTrim-__SAMPLE_ID__.log

module load gcccore/11.2.0
module load porechop/0.2.4

echo '--------------------'
echo 'Trimming ...'
mkdir porechop_output
porechop -i __WDLONG__/__SAMPLE_ID__.fastq -o porechop_output/__SAMPLE_ID___porechopped.fastq --discard_middle

echo 'Trimming Succeed'
echo '--------------------'
echo 'Filtering ...'

module load gcc/11.2.0
module load filtlong/0.2.1
mkdir filtlong_filtered
filtlong --min_length 500 porechop_output/__SAMPLE_ID___porechopped.fastq > filtlong_filtered/__SAMPLE_ID___porechopped_filtered.fastq

echo 'Filtering Succeed'
echo '--------------------'
