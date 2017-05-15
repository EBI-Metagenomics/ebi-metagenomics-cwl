#!/bin/bash

#set -x
#set -e

echo $1

. /hps/nobackup/production/metagenomics/software/miniconda2/bin/activate cwl-runner
CLASSPATH=/hps/nobackup/production/metagenomics/production-scripts/current/mgportal/analysis-pipeline/python/tools/Trimmomatic-0.35/trimmomatic-0.35.jar:$CLASSPATH
PATH=$PATH:/hps/nobackup/production/metagenomics/CWL/code/thirdparty/node-v6.10.3
PATH=/hps/nobackup/production/metagenomics/pipeline/tools/miniconda2-4.0.5/bin:$PATH

export PATH
export CLASSPATH
cwltool --preserve-entire-environment /hps/nobackup/production/metagenomics/CWL/rdf/code/ebi-metagenomics-cwl/workflows/$1\.cwl /hps/nobackup/production/metagenomics/CWL/rdf/code/ebi-metagenomics-cwl/workflows/$1\-job.yaml

#cwltool --preserve-environment PATH,CLASSPATH --cache $PWD/cwltool-cache --debug \
	#emg-pipeline-v3-paired.cwl emg-pipeline-v3-paired-job.yaml
