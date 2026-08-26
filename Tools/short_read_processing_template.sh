#!/bin/sh
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute
#SBATCH --time=71:00:00
#SBATCH --nodes=1
#SBATCH --mem=60000
#SBATCH --ntasks-per-node=12
#SBATCH --job-name="STrim-__SAMPLE_ID__"
#SBATCH --output=STrim-__SAMPLE_ID__.log

module load trimmomatic/0.39-Java-11.0.16

echo '--------------------'
echo 'Trimming ...'
mkdir trimmomatic_paired
mkdir trimmomatic_unpaired
java -jar $EBROOTTRIMMOMATIC/trimmomatic-0.39.jar PE -threads 12 -phred33  __WDSHORT__/__SAMPLE_ID___R1_001.fastq __WDSHORT__/__SAMPLE_ID___R2_001.fastq trimmomatic_paired/__SAMPLE_ID___R1_001_trimmed_paired.fastq trimmomatic_unpaired/__SAMPLE_ID___R1_001_trimmed_unpaired.fastq trimmomatic_paired/__SAMPLE_ID___R2_001_trimmed_paired.fastq trimmomatic_unpaired/__SAMPLE_ID___R2_001_trimmed_unpaired.fastq ILLUMINACLIP:/projects/academic/pidiazmo/projectsoftwares/trimmomatic_adapters/TruSeq3-PE-2.fa:2:30:10:2:True LEADING:3 TRAILING:3 MINLEN:36

echo 'Trimming Succeed'
echo '--------------------'
