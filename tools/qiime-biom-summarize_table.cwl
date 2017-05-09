#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

requirements:
  SchemaDefRequirement:
    types:
      - $import: qiime-biom-convert-table.yaml

hints:
  SoftwareRequirement:
    packages:
      qiime:
        specs: [ "https://identifiers.org/rrid/RRID:SCR_008249" ]
        version: [ "1.9.1" ]

inputs:
  biom:
    format: edam:format_3746  # BIOM
    type: File
    inputBinding:
      prefix: --input_fp

baseCommand: [ biom, summarize-table ]

arguments:
  - valueFrom: otu_table_summary.txt
    prefix: --output_fp

outputs:
  otu_table_summary:
    type: File
    outputBinding: { glob: otu_table_summary.txt }

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
