#!/bin/sh
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute
#SBATCH --time=71:00:00
#SBATCH --nodes=1
#SBATCH --mem=60000
#SBATCH --ntasks-per-node=16
#SBATCH --job-name="UnC-__SAMPLE_ID__"
#SBATCH --output=UnC-__SAMPLE_ID__.log

module load gcc/11.2.0
module load openmpi/4.1.1
module load unicycler/0.5.0
echo '--------------------'
echo 'Unicycler ...'
mkdir assembly
unicycler -t 16 --keep 0 --mode normal -o assembly/__SAMPLE_ID__ -1 ../Step2_Triming_ShortReads/trimmomatic_paired/__SAMPLE_ID___R1_001_trimmed_paired.fastq -2 ../Step2_Triming_ShortReads/trimmomatic_paired/__SAMPLE_ID___R2_001_trimmed_paired.fastq -l ../Step1_Triming_LongReads/filtlong_filtered/__SAMPLE_ID___porechopped_filtered.fastq

echo 'Unicycler Succeed'
echo '--------------------'
