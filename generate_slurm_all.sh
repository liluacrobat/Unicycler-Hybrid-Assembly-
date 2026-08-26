#!/bin/sh
module load gcc/11.2.0 openmpi/4.1.1
module load scipy-bundle/2021.10
ln -s /projects/academic/pidiazmo/Sequence_storage/MOCK_community_study/Culturomics/Long_read_fastq/*.fastq .

mkdir Step1_Triming_LongReads
mkdir Step2_Triming_ShortReads
mkdir Step3_Unicycler

for f in *.fastq;
    do b=$(echo "$f" | sed "s/^\(.*\).fastq$/\1/");
        python Tools/build_slurm.py -s $b -t long_read_processing_template.sh -d Step1_Triming_LongReads;
    done
    
for f in *.fastq;
    do b=$(echo "$f" | sed "s/^\(.*\).fastq$/\1/");
        python Tools/build_slurm.py -s $b -t short_read_processing_template.sh -d Step2_Triming_ShortReads;
    done

for f in *.fastq;
    do b=$(echo "$f" | sed "s/^\(.*\).fastq$/\1/");
        python Tools/build_slurm.py -s $b -t unicycler_template.sh -d Step3_Unicycler;
    done
    
