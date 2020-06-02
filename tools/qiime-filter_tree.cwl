#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 1024  # just a default, could be lowered
hints:
 SoftwareRequirement:
   packages:
     qiime:
       specs: [ "https://identifiers.org/rrid/RRID:SCR_008249" ]
       version: [ "1.9.1" ]

inputs:
  tree:
    type: File
    inputBinding:
      prefix: --input_tree_filepath=
      separate: false

  tips_or_seqids_to_retain:
    type: File?
    doc: |
      A list of tips (one tip per line) or sequence identifiers (tab-delimited
      lines with a seq identifier in the first field) which should be retained 
    inputBinding:
      prefix: --tips_fp=
      separate: false

baseCommand: filter_tree.py

arguments:
 - valueFrom: pruned.tree
   prefix: --output_tree_filepath=
   separate: false

outputs:
  pruned_tree:
    type: File
    outputBinding: { glob: pruned.tree }

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schema.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
