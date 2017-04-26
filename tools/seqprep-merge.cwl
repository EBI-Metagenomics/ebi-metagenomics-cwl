#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

hints:
 SoftwareRequirement:
   packages: { gunzip }

inputs:
 merged_reads:
   type: File
   format: edam:format_1930  # FASTQ
   inputBinding: { position: 3 }
 forward_unmerged_reads:
   type: File
   format: edam:format_1930  # FASTQ
   inputBinding: { position: 1 }
 reverse_unmerged_reads:
   type: File
   format: edam:format_1930  # FASTQ
   inputBinding: { position: 2 }

baseCommand: [ gunzip, -c ]

stdout: merged_with_unmerged_reads  # helps with cwltool's --cache

outputs:
  merged_with_unmerged_reads:
    type: stdout
    format: edam:format_1930  # FASTQ

$namespaces: { edam: "http://edamontology.org/" }
$schemas: [ "http://edamontology.org/EDAM_1.16.owl" ]
