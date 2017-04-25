#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

hints:
 SoftwareRequirement:
   packages:
     seqprep:
       specs: [ https://identifiers.org/rrid/RRID:SCR_013004 ]
       version: [ "1.1" ]

inputs:
 forward_reads:
   type: File
   format: edam:format_1930  # FASTQ
   label: first read input fastq
   inputBinding:
     prefix: -f
 reverse_reads:
   type: File
   format: edam:format_1930  # FASTQ
   label: second read input fastq
   inputBinding:
     prefix: -r

baseCommand: seqprep

arguments:
 - "-1"
 - forward_unmerged.fastq
 - "-2"
 - reverse_unmerged.fastq
 - -s
 - merged.fastq
 # - "-3"
 # - forward_discarded.fastq.gz
 # - "-4"
 # - reverse_discarded.fastq.gz


outputs:
  merged_reads:
    type: File
    format: edam:format_1930  # FASTQ
    outputBinding:
      glob: merged.fastq.gz
  forward_unmerged_reads:
    type: File
    format: edam:format_1930  # FASTQ
    outputBinding:
      glob: forward_unpaired.fastq.gz
  reverse_unmerged_reads:
    type: File
    format: edam:format_1930  # FASTQ
    outputBinding:
      glob: reverse_unpaired.fastq.gz

$namespaces: { edam: "http://edamontology.org/" }
$schemas: [ "http://edamontology.org/EDAM_1.16.owl" ]
