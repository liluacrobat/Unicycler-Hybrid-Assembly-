#!/bin/sh
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute
#SBATCH --time=71:00:00
#SBATCH --nodes=1
#SBATCH --mem=240G
#SBATCH --ntasks-per-node=12
#SBATCH --job-name="DU-__SAMPLE_ID__"
#SBATCH --output=DU-__SAMPLE_ID__.log

module load gcc/11.2.0
module load openmpi/4.1.1
module load unicycler/0.5.0

echo '--------------------'
echo 'trycycler susampling ...'

WD='/projects/academic/pidiazmo/lu/Mock_Community/organized_data_07_16_2024/Unicycler_processing'

mkdir U_assembly

unicycler -t 16 --keep 0 --mode normal -o U_assembly/H03_S49 -1 $WD/Step2_Triming_ShortReads/trimmomatic_paired/H03_S49_R1_001_trimmed_paired.fastq -2 $WD/Step2_Triming_ShortReads/trimmomatic_paired/H03_S49_R2_001_trimmed_paired.fastq -l $WD/Step1_Triming_LongReads/filtlong_filtered/H03_S49_porechopped_filtered.fastq
echo 'Unicycler ucceed'
echo '--------------------'
