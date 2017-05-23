#!/bin/bash

set -x
set -e

CLASSPATH=/hps/nobackup/production/metagenomics/production-scripts/current/mgportal/analysis-pipeline/python/tools/Trimmomatic-0.35/trimmomatic-0.35.jar:$CLASSPATH
PATH=/hps/nobackup/production/metagenomics/CWL/code/:$PATH
PATH=/hps/nobackup/production/metagenomics/production-scripts/current/mgportal/analysis-pipeline/python/tools/SeqPrep-1.1/:$PATH
PATH=/hps/nobackup/production/metagenomics/production-scripts/current/mgportal/analysis-pipeline/python/tools/RNASelector-1.0/binaries/64_bit_Linux/HMMER3.1b1/:$PATH
PATH=/hps/nobackup/production/metagenomics/pipeline/tools/miniconda2-4.0.5/bin:$PATH  # for biopython
PATH=/hps/nobackup/production/metagenomics/CWL/code/thirdparty/SPAdes-3.10.0/:$PATH
PATH=/hps/nobackup/production/metagenomics/CWL/code/thirdparty/cmsearch_tblout_deoverlap/:$PATH
PATH=/hps/nobackup/production/metagenomics/CWL/code/thirdparty/infernal-1.1.2/src/:$PATH
PATH=/hps/nobackup/production/metagenomics/CWL/code/thirdparty/infernal-1.1.2/easel/miniapps/:$PATH
PATH=/hps/nobackup/production/metagenomics/CWL/code/thirdparty/mapseq-1.0/:$PATH
PATH=/hps/nobackup/production/metagenomics/pipeline/tools/FragGeneScan1.20/:$PATH
PATH=/hps/nobackup/production/metagenomics/pipeline/tools/interproscan-5.19-58.0/:$PATH

export PATH
export CLASSPATH
export TOIL_LSF_ARGS="-q production-rh7"
#export LSB_DEFAULTQUEUE=production-rh7 
#pip install html5lib 

#CWLTOIL="ipdb ../../toil-v3.8.0a/venv/bin/cwltoil"
CWLTOIL=cwltoil

workdir=${PWD}/toil-workdir
mkdir -p ${workdir}
# must be a directory accessible from all nodes

RESTART=--restart

${CWLTOIL} ${RESTART} --logDebug --logFile $PWD/toil-log --preserve-environment PATH --batchSystem LSF \
	--workDir ${workdir} --jobStore $PWD/toil-jobstore --disableCaching --defaultMemory 10Gi \
	emg-assembly.cwl emg-assembly-job.yaml
