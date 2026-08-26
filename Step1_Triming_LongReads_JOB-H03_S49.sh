#!/bin/sh
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute
#SBATCH --time=71:00:00
#SBATCH --nodes=1
#SBATCH --mem=60000
#SBATCH --ntasks-per-node=12
#SBATCH --job-name="LTrim-H03_S49"
#SBATCH --output=LTrim-H03_S49.log

module load gcccore/11.2.0
module load porechop/0.2.4

echo '--------------------'
echo 'Trimming ...'
mkdir porechop_output
porechop -i /projects/academic/pidiazmo/lu/Mock_Community/organized_data_07_16_2024/fastq_long/H03_S49.fastq -o porechop_output/H03_S49_porechopped.fastq --discard_middle

echo 'Trimming Succeed'
echo '--------------------'
echo 'Filtering ...'

module load gcc/11.2.0
module load filtlong/0.2.1
mkdir filtlong_filtered
filtlong --min_length 500 porechop_output/H03_S49_porechopped.fastq > filtlong_filtered/H03_S49_porechopped_filtered.fastq

echo 'Filtering Succeed'
echo '--------------------'
