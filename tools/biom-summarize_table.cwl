#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 100  # just a default, could be lowered
  SchemaDefRequirement:
    types:
      - $import: biom-convert-table.yaml

hints:
  SoftwareRequirement:
    packages:
      biom-format:
        specs: [ "https://doi.org/10.1186/2047-217X-1-7" ]
        version: [ "2.1.6" ]

inputs:
  biom:
    format: edam:format_3746  # BIOM
    type: File
    inputBinding:
      prefix: --input-fp

baseCommand: [ biom, summarize-table ]

arguments:
  - valueFrom: otu_table_summary.txt
    prefix: --output-fp

outputs:
  otu_table_summary:
    type: File
    outputBinding: { glob: otu_table_summary.txt }

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schema.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
