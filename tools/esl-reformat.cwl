cwlVersion: v1.0
class: CommandLineTool
label: normalize to fasta
doc: |
  normalizes input sequeces to FASTA with fixed number of sequence characters
  per line using esl-reformat from https://github.com/EddyRivasLab/easel

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 100  # just a default, could be lowered
  SchemaDefRequirement:
    types:
      - $import: esl-reformat-replace.yaml
hints:
  SoftwareRequirement:
    packages:
      easel: {}
        # specs: [ https://identifiers.org/rrid/RRID:TBD ]
        # version: [ "???" ]
inputs:
  sequences:
    type: File
    inputBinding:
      position: 3
    format:
      - edam:format_1929  # FASTA
      # - edam:format_1930  # FASTQ
      # - edam:format_1927  # EMBL
      # - edam:format_1936  # Genbank entry format
      # - edam:format_1961  # Stockholm
      # - edam:format_1963  # UniProt
      # ddbj ?

  replace:
    type: esl-reformat-replace.yaml#replace?
    inputBinding:
      position: 1
      prefix: --replace
      valueFrom: "$(self.find):$(self.replace)"

baseCommand: [ esl-reformat ]

arguments:
  - valueFrom: fasta
    position: 2

stdout: reformatted_sequences  # helps with cwltool's --cache

outputs:
  reformatted_sequences:
    type: stdout
    format: edam:format_1929

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schema.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
