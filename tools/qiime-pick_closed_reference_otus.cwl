#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

hints:
 SoftwareRequirement:
   packages:
     qiime:
       specs: [ "https://identifiers.org/rrid/RRID:SCR_008249" ]
       version: [ "1.9.1" ]

inputs:
 sequences:
   type: File
   format: edam:format_1929  # FASTA
   inputBinding:
     prefix: --input_fp

baseCommand: pick_closed_reference_otus.py

arguments:
 - valueFrom: $(runtime.outdir)
   prefix: --output_dir

outputs: []

$namespaces: { edam: "http://edamontology.org/" }
$schemas: [ "http://edamontology.org/EDAM_1.16.owl" ]
