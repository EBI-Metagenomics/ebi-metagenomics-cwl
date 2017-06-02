#!/bin/bash

#BSUB -M 100000
#BSUB -R "rusage[mem=100000]"
#BSUB -n 4
#BSUB -q production-rh7
#BSUB -o cwltool-v3-paired-log

#  to run: bsub < standalone-v3-paired.sh

source ~mcrusoe/test/bin/activate

source ebi-setup.sh
set -o pipefail

DEBUG=--debug  # uncomment to make output & logs more verbose

workdir=/tmp
#mkdir -p ${workdir}
# must be a directory accessible from all nodes

RUN=v3-paired
DESC=../emg-pipeline-v3-paired.cwl
INPUTS=../emg-pipeline-v3-paired-job.yaml

start=cwltool-${RUN}
mkdir -p ${start}
cd ${start}
cp ${INPUTS} ./

cwltool --pack ${DESC} > packed.cwl

cwltool ${DEBUG} --outdir ${PWD}/results --on-error continue \
	--preserve-entire-environment --cache ${PWD}/../cwltool-cache \
       	${DESC} ${INPUTS} | tee output 
