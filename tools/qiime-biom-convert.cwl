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
    type: File
    format: edam:format_3746
    inputBinding:
      prefix: --input_fp

  table_type:
    type: qiime-biom-convert-table.yaml#table_type?
    inputBinding:
      prefix: --table-type

  json:
    type: boolean?
    label: Output as JSON-formatted table.
    inputBinding:
      prefix: --to-json

  tsv:
    type: boolean?
    label: Output as TSV-formatted (classic) table.
    inputBinding:
      prefix: --to-tsv

  header_key:
    type: string?
    doc: |
      The observation metadata to include from the input BIOM table file when
      creating a tsv table file. By default no observation metadata will be
      included.
    inputBinding:
      prefix: --header-key

baseCommand: [ biom, convert ]

arguments:
  - valueFrom: result
    prefix: --output_fp

outputs:
  result:
    type: File
    outputBinding: { glob: result }

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
