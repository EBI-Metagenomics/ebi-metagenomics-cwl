#!/bin/bash

CLASSPATH=/hps/nobackup/production/metagenomics/production-scripts/current/mgportal/analysis-pipeline/python/tools/Trimmomatic-0.35/trimmomatic-0.35.jar:$CLASSPATH
PATH=/hps/nobackup/production/metagenomics/CWL/code/:$PATH
PATH=/hps/nobackup/production/metagenomics/CWL/code/thirdparty/cmsearch_tblout_deoverlap/:$PATH
PATH=/hps/nobackup/production/metagenomics/CWL/code/thirdparty/infernal/easel/miniapps/:$PATH
PATH=/hps/nobackup/production/metagenomics/CWL/code/thirdparty/infernal/src/:$PATH
PATH=/hps/nobackup/production/metagenomics/CWL/code/thirdparty/mapseq-1.0/:$PATH
PATH=/hps/nobackup/production/metagenomics/CWL/code/thirdparty/SPAdes-3.10.0/:$PATH
PATH=/hps/nobackup/production/metagenomics/CWL/rdf/code/mgportal/analysis-pipeline/python/tools/qc-stats/:$PATH
PATH=/hps/nobackup/production/metagenomics/pipeline/tools/FragGeneScan1.20/:$PATH
PATH=/hps/nobackup/production/metagenomics/pipeline/tools/interproscan-5.19-58.0/:$PATH
PATH=/hps/nobackup/production/metagenomics/pipeline/tools/miniconda2-4.0.5/bin:$PATH
PATH=/hps/nobackup/production/metagenomics/pipeline/tools/miniconda2-4.0.5/bin:$PATH  # for biopython, qiime
PATH=/hps/nobackup/production/metagenomics/production-scripts/current/mgportal/analysis-pipeline/python/tools/go_summary_generator/:$PATH
PATH=/hps/nobackup/production/metagenomics/production-scripts/current/mgportal/analysis-pipeline/python/tools/KronaTools-2.3/bin/:$PATH
PATH=/hps/nobackup/production/metagenomics/production-scripts/current/mgportal/analysis-pipeline/python/tools/RNASelector-1.0/binaries/64_bit_Linux/HMMER3.1b1/:$PATH
PATH=/hps/nobackup/production/metagenomics/production-scripts/current/mgportal/analysis-pipeline/python/tools/SeqPrep-1.1/:$PATH
PATH=$PATH:/hps/nobackup/production/metagenomics/CWL/code/thirdparty/node-v6.10.3export PATH

export CLASSPATH
export TOIL_LSF_ARGS="-q production-rh7"



