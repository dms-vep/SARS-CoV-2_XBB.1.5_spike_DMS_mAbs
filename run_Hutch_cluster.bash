#!/bin/bash
#
#SBATCH -c 8

snakemake -j 8 --rerun-incomplete --use-conda -s dms-vep-pipeline-3/Snakefile
