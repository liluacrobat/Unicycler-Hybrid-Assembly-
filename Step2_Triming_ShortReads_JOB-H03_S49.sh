#!/bin/sh
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute
#SBATCH --time=71:00:00
#SBATCH --nodes=1
#SBATCH --mem=60000
#SBATCH --ntasks-per-node=12
#SBATCH --job-name="STrim-H03_S49"
#SBATCH --output=STrim-H03_S49.log

module load trimmomatic/0.39-Java-11.0.16

echo '--------------------'
echo 'Trimming ...'
mkdir trimmomatic_paired
mkdir trimmomatic_unpaired
java -jar $EBROOTTRIMMOMATIC/trimmomatic-0.39.jar PE -threads 12 -phred33  /projects/academic/pidiazmo/lu/Mock_Community/organized_data_07_16_2024/fastq_short/H03_S49_R1_001.fastq /projects/academic/pidiazmo/lu/Mock_Community/organized_data_07_16_2024/fastq_short/H03_S49_R2_001.fastq trimmomatic_paired/H03_S49_R1_001_trimmed_paired.fastq trimmomatic_unpaired/H03_S49_R1_001_trimmed_unpaired.fastq trimmomatic_paired/H03_S49_R2_001_trimmed_paired.fastq trimmomatic_unpaired/H03_S49_R2_001_trimmed_unpaired.fastq ILLUMINACLIP:/projects/academic/pidiazmo/projectsoftwares/trimmomatic_adapters/TruSeq3-PE-2.fa:2:30:10:2:True LEADING:3 TRAILING:3 MINLEN:36

echo 'Trimming Succeed'
echo '--------------------'
