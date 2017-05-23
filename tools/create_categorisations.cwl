#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: categorise sequences

requirements:
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - entryname: inputs.json
        entry: $(JSON.stringify(inputs))

hints:
  - class: SoftwareRequirement
    packages:
      biopython:
        specs: [ "https://identifiers.org/rrid/RRID:SCR_007173" ]
        version: [ "1.65", "1.66", "1.69" ]

inputs:
  seqs:
    type: File
    format: edam:format_1929  # FASTA
  ipr_idset: string[]
  cds_idset: string[]

baseCommand: python

arguments:
  - prefix: -c
    valueFrom: |
      from __future__ import print_function
      import re
      import json
      from Bio import SeqIO
      inputs = json.loads(open("inputs.json))
      ipr_idset = inputs['ipr_idset']
      cds_idset = inputs['cds_idset']
      ipr_output = open("interproscan.fasta", 'w')
      cds_output = open("pCDS.fasta", 'w')
      nof_output = open("noFunction.fasta", 'w')
      for record in SeqIO.parse("$(inputs.seqs.path)", "fasta"):
          if seq.name in ipr_idset:
              ipr_output.write(str(">" + seq.name + "\n" + seq.seq + "\n"))
          if seq.name in cds_idset:
              cds_output.write(str(">" + seq.name + "\n" + seq.seq + "\n"))
              if seq.name not in ipr_idset:
                   nof_output.write(str(">" + seq.name + "\n" + seq.seq + "\n"))
outputs:
  interproscan:
    type: File
    format: edam:format_1929  # FASTA
    outputBinding:
      glob: interproscan.fasta
  pCDS_seqs:
    type: File
    format: edam:format_1929  # FASTA
    outputBinding:
      glob: pCDS.fasta
  no_functions_seqs:
    type: File
    format: edam:format_1929  # FASTA
    outputBinding:
      glob: noFunction.fasta

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
