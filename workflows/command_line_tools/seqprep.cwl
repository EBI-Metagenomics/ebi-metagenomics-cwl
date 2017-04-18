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
 forward:
   type: File
   format: edam:format_1930  # FASTQ
   label: first read input fastq
   inputBinding:
     prefix: -f
 reverse:
   type: File
   format: edam:format_1930  # FASTQ
   label: second read input fastq
   inputBinding:
     prefix: -r

arguments:
 - "-1"
 - forward.fastq
 - "-2"
 - reverse.fastq
 - -s
 - merged.fastq

baseCommand: seqprep

outputs:
  merged_reads:
    type: File
    format: edam:format_1930  # FASTQ
    outputBinding:
      glob: merged.fastq

$namespaces: { edam: http://edamontology.org/ }
$schemas: [ http://edamontology.org/EDAM_1.16.owl ]
