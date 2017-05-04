#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

hints:
 SoftwareRequirement:
   packages:
     owltools:
       specs: [ "https://identifiers.org/rrid/RRID:SCR_005732" ]
       version: [ "8d53bbce1ffe60d9aa3357c1001599f9a882317a" ]


inputs:
  InterProScan_results:
    type: File
    inputBinding:
      prefix: --input-file

  config:
    type: File
    inputBinding:
      prefix: --config

baseCommand: go_summary_pipeline-1.0.py

arguments:
  - valueFrom: go-summary
    prefix: --output-file

outputs:
  go_summary:
    type: File
    outputBinding: { glob: go-summary }

