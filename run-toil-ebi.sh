#!/bin/bash

set -x
set -e

PATH=/hps/nobackup/production/metagenomics/CWL/code/thirdparty/SPAdes-3.10.0/:$PATH
PATH=/hps/nobackup/production/metagenomics/CWL/code/thirdparty/infernal/src/:$PATH
PATH=/hps/nobackup/production/metagenomics/CWL/code/thirdparty/infernal/easel/miniapps/:$PATH
PATH=/hps/nobackup/production/metagenomics/CWL/code/thirdparty/mapseq-1.0/:$PATH
PATH=/hps/nobackup/production/metagenomics/pipeline/tools/FragGeneScan1.20/:$PATH
PATH=/hps/nobackup/production/metagenomics/pipeline/tools/interproscan-5.19-58.0/:$PATH

export PATH
export TOIL_LSF_ARGS="-q production-rh7"
pip install html5lib 

#CWLTOIL="ipdb ../../toil-hack/venv/bin/cwltoil"
CWLTOIL=cwltoil

workdir=${PWD}/toil-workdir
mkdir -p ${workdir}
# must be a directory accessible from all nodes

${CWLTOIL} --logDebug --logFile $PWD/toil-log --preserve-environment PATH \
	--batchSystem LSF --workDir ${workdir} --jobStore $PWD/toil-jobstore \
	--disableCaching --defaultMemory 1Gi \
	emg-assembly.cwl emg-assembly-job.yaml

