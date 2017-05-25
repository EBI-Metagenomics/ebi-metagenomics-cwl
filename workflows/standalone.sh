#!/bin/bash

#BSUB -M 100000
#BSUB -R "rusage[mem=100000]"
#BSUB -n 4
#BSUB -q production-rh7
#BSUB -o cwltool-v4-assembly/log

#  to run: bsub < standalone-v4.sh

source ~mcrusoe/test/bin/activate

source ebi-setup.sh

#DEBUG=--debug  # uncomment to make output & logs more verbose

workdir=/tmp
#mkdir -p ${workdir}
# must be a directory accessible from all nodes

RUN=v4-assembly
DESC=../emg-assembly.cwl
INPUTS=../emg-assembly-job.yaml

start=cwlool-${RUN}
mkdir -p ${start}
cd ${start}

cwltool ${DEBUG} --outdir ${PWD}/results --on-error continue \
	--preserve-entire-environment --cache ${PWD}/../cwltool-cache \
       	${DESC} ${INPUTS} | tee output 
