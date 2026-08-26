# Unicycler Hybrid-Assembly Pipeline

A SLURM-based workflow for hybrid genome assembly of cultured bacterial isolates using Illumina short reads and Oxford Nanopore long reads.

The pipeline generates sample-specific SLURM scripts for:

1. Long-read adapter trimming and filtering
2. Short-read trimming
3. Unicycler hybrid assembly

The generator does not submit jobs. Preprocessing jobs are submitted in batches after inspection, and Unicycler jobs are submitted only when all required preprocessing outputs are available.

> This workflow is intended for cultured bacterial isolates, not metagenomic community assembly.

## Workflow

```text
ONT long reads
    │
    └── Porechop → Filtlong ───────────────┐
                                           │
Illumina paired-end reads                  ├── Unicycler hybrid assembly
    │                                      │
    └── Trimmomatic ───────────────────────┘
```

Long- and short-read preprocessing jobs are independent and may run concurrently. The Unicycler step must run only after both preprocessing steps finish successfully.

## Repository structure

```text
.
├── config.txt
├── generate_slurm_all.sh
├── Tools/
│   ├── build_slurm.py
│   ├── long_read_processing_template.sh
│   ├── short_read_processing_template.sh
│   └── unicycler_template.sh
└── Unicycler Hybrid-Assembly Pipeline Instructions.docx
```

Running the generator creates:

```text
Step1_Triming_LongReads/
Step2_Triming_ShortReads/
Step3_Unicycler/
```

Each directory contains one `JOB-SAMPLE_ID.sh` file per sample.

## Requirements

This workflow assumes access to a SLURM computing cluster with environment modules.

The current templates use:

- Python 3
- Trimmomatic 0.39
- Porechop 0.2.4
- Filtlong 0.2.1
- Unicycler 0.5.0
- GCC and OpenMPI modules

Module names differ between clusters. Update the `module load` commands in the templates if necessary.

The workflow expects uncompressed `.fastq` files. The templates and generator must be modified before using `.fastq.gz` files.

## Input naming convention

For a sample named `H03_S49`, the expected files are:

```text
H03_S49_R1_001.fastq
H03_S49_R2_001.fastq
H03_S49.fastq
```

The first two files are paired-end Illumina reads. The third file contains the long reads.

Every long-read sample must have matching R1 and R2 short-read files.

## Installation

Clone the repository:

```bash
git clone https://github.com/liluacrobat/Unicycler-Hybrid-Assembly-.git
cd Unicycler-Hybrid-Assembly-
```

## 1. Configure the input directories

Open `config.txt` and set `WDSHORT` and `WDLONG` to the directories containing the sequencing files.

Example:

```text
WDSHORT = /projects/academic/pidiazmo/lu/Mock_Community/organized_data_07_16_2024/fastq_short
WDLONG = /projects/academic/pidiazmo/lu/Mock_Community/organized_data_07_16_2024/fastq_long
```

Do not add quotation marks around the paths.

Before continuing, confirm that the expected files exist:

```bash
test -s /path/to/fastq_short/H03_S49_R1_001.fastq
test -s /path/to/fastq_short/H03_S49_R2_001.fastq
test -s /path/to/fastq_long/H03_S49.fastq
```

The generator’s long-read sample-discovery location must point to the same dataset specified by `WDLONG`.

## 2. Generate the SLURM scripts

From the repository root, run:

```bash
bash generate_slurm_all.sh
```

The generator creates the three processing directories and their sample-specific job scripts. It does not submit any jobs.

## 3. Set script permissions

The scripts do not require world-write permission. Use:

```bash
chmod 750 Step1_Triming_LongReads/JOB-*.sh
chmod 750 Step2_Triming_ShortReads/JOB-*.sh
chmod 750 Step3_Unicycler/JOB-*.sh
```

Avoid `chmod 777`, because it allows other users to modify the job scripts.

## 4. Inspect the generated scripts

Check for unresolved template placeholders:

```bash
grep -R '__[A-Z][A-Z_]*__' \
    Step1_Triming_LongReads \
    Step2_Triming_ShortReads \
    Step3_Unicycler
```

The command should return no output.

Inspect one sample:

```bash
grep H03_S49 Step1_Triming_LongReads/JOB-H03_S49.sh
grep H03_S49 Step2_Triming_ShortReads/JOB-H03_S49.sh
grep H03_S49 Step3_Unicycler/JOB-H03_S49.sh
```

Confirm that the Unicycler script reads short-read results from:

```text
../Step2_Triming_ShortReads/trimmomatic_paired/
```

## 5. Submit all long-read processing jobs

Enter the long-read directory:

```bash
cd Step1_Triming_LongReads
```

Submit all generated jobs:

```bash
for job in JOB-*.sh; do
    echo "Submitting $job"
    sbatch "$job"
done
```

Return to the repository root:

```bash
cd ..
```

## 6. Submit all short-read processing jobs

The short-read jobs may be submitted immediately after the long-read jobs. SLURM can run both groups concurrently.

```bash
cd Step2_Triming_ShortReads

for job in JOB-*.sh; do
    echo "Submitting $job"
    sbatch "$job"
done

cd ..
```

Monitor active jobs:

```bash
squeue -u "$USER"
```

Review completed and failed jobs:

```bash
sacct -u "$USER" \
    --starttime today \
    --format=JobID,JobName,State,ExitCode,Elapsed,MaxRSS
```

If a preprocessing job fails, inspect its log, correct the problem, and resubmit only the failed job.

## 7. Submit eligible Unicycler jobs

Wait until the long- and short-read jobs finish.

Enter the assembly directory:

```bash
cd Step3_Unicycler
```

The following Bash code submits Unicycler only when all three processed input files exist and are nonempty. It also avoids submitting samples that already have a completed or partial assembly directory.

```bash
for job in JOB-*.sh; do
    sample=${job#JOB-}
    sample=${sample%.sh}

    long_reads="../Step1_Triming_LongReads/filtlong_filtered/${sample}_porechopped_filtered.fastq"
    short_r1="../Step2_Triming_ShortReads/trimmomatic_paired/${sample}_R1_001_trimmed_paired.fastq"
    short_r2="../Step2_Triming_ShortReads/trimmomatic_paired/${sample}_R2_001_trimmed_paired.fastq"
    assembly_dir="assembly/${sample}"
    assembly_fasta="${assembly_dir}/assembly.fasta"

    if [[ -s "$assembly_fasta" ]]; then
        echo "Skipping $sample: assembly already completed"
    elif [[ -d "$assembly_dir" ]]; then
        echo "Skipping $sample: partial assembly directory exists; inspect it first"
    elif squeue -h -u "$USER" --name="UnC-${sample}" | grep -q .; then
        echo "Skipping $sample: Unicycler job is already queued or running"
    elif [[ -s "$long_reads" && -s "$short_r1" && -s "$short_r2" ]]; then
        echo "Submitting Unicycler for $sample"
        sbatch "$job"
    else
        echo "Skipping $sample: preprocessing results are missing or empty"
    fi
done
```

This submission code uses Bash syntax. Run it from a Bash shell.

## Expected outputs

### Long-read processing

```text
Step1_Triming_LongReads/
├── porechop_output/
│   └── SAMPLE_ID_porechopped.fastq
└── filtlong_filtered/
    └── SAMPLE_ID_porechopped_filtered.fastq
```

### Short-read processing

```text
Step2_Triming_ShortReads/
├── trimmomatic_paired/
│   ├── SAMPLE_ID_R1_001_trimmed_paired.fastq
│   └── SAMPLE_ID_R2_001_trimmed_paired.fastq
└── trimmomatic_unpaired/
    ├── SAMPLE_ID_R1_001_trimmed_unpaired.fastq
    └── SAMPLE_ID_R2_001_trimmed_unpaired.fastq
```

### Unicycler assembly

```text
Step3_Unicycler/assembly/SAMPLE_ID/
├── assembly.fasta
├── assembly.gfa
└── unicycler.log
```

The principal assembled-genome file is:

```text
Step3_Unicycler/assembly/SAMPLE_ID/assembly.fasta
```

## Handling failed jobs

If a preprocessing job fails:

1. Inspect its SLURM log.
2. Identify and correct the input, module, resource, or command problem.
3. Inspect or rename partial outputs.
4. Resubmit only the failed job.
5. Confirm that the expected output is nonempty.
6. Run the Unicycler submission check again.

If an Unicycler job fails, preserve its incomplete output:

```bash
cd Step3_Unicycler

mv assembly/H03_S49 \
   assembly/H03_S49.failed.JOB_ID
```

Then resubmit the corresponding job:

```bash
sbatch JOB-H03_S49.sh
```

Do not automatically delete failed output directories. Their logs and intermediate files may help identify the cause.

## Citation

If this workflow contributes to published work, cite Unicycler:

> Wick RR, Judd LM, Gorrie CL, Holt KE. Unicycler: Resolving bacterial genome assemblies from short and long sequencing reads. *PLOS Computational Biology*. 2017;13(6):e1005595. https://doi.org/10.1371/journal.pcbi.1005595

See the [official Unicycler repository](https://github.com/rrwick/Unicycler) for additional documentation.
