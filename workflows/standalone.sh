#!/bin/bash

#BSUB -M 100000
#BSUB -R "rusage[mem=100000]"
#BSUB -n 4
#BSUB -q production-rh7
#BSUB -o v4-log

set -x
set -e

#source ../../toil/env/bin/activate
source ~mcrusoe/test/bin/activate

PATH=/hps/nobackup/production/metagenomics/CWL/code/:$PATH
PATH=/hps/nobackup/production/metagenomics/production-scripts/current/mgportal/analysis-pipeline/python/tools/RNASelector-1.0/binaries/64_bit_Linux/HMMER3.1b1/:$PATH
PATH=/hps/nobackup/production/metagenomics/pipeline/tools/miniconda2-4.0.5/bin:$PATH  # for biopython, qiime
PATH=/hps/nobackup/production/metagenomics/CWL/rdf/code/mgportal/analysis-pipeline/python/tools/qc-stats/:$PATH
PATH=/hps/nobackup/production/metagenomics/CWL/code/thirdparty/SPAdes-3.10.0/:$PATH
PATH=/hps/nobackup/production/metagenomics/CWL/code/thirdparty/infernal-1.1.2/src/:$PATH
PATH=/hps/nobackup/production/metagenomics/CWL/code/thirdparty/infernal-1.1.2/easel/miniapps/:$PATH
PATH=/hps/nobackup/production/metagenomics/CWL/code/thirdparty/mapseq-1.0/:$PATH
PATH=/hps/nobackup/production/metagenomics/CWL/code/thirdparty/cmsearch_tblout_deoverlap/:$PATH
PATH=/hps/nobackup/production/metagenomics/pipeline/tools/FragGeneScan1.20/:$PATH
PATH=/hps/nobackup/production/metagenomics/pipeline/tools/interproscan-5.19-58.0/:$PATH

export PATH

cwltool --preserve-entire-environment --cache $PWD/cwltool-cache --debug \
        --outdir v4-results emg-assembly.cwl emg-assembly-job.yaml 
