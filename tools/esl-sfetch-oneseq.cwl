cwlVersion: v1.0
class: CommandLineTool
label: index a sequence file for use by esl-sfetch
doc: "https://github.com/EddyRivasLab/easel"

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 100  # just a default, could be lowered
hints:
  SoftwareRequirement:
    packages:
      easel: {}
        # specs: [ https://identifiers.org/rrid/RRID:TBD ]
        # version: [ "???" ]

inputs:
  sequences:
    label: sequence file indexed by esl-sfetch-index
    type: File
    secondaryFiles: .ssi
    inputBinding:
      position: 1
    format:
      - edam:format_1929  # FASTA
      # - edam:format_1927  # EMBL
      # - edam:format_1936  # Genbank entry format
      # - edam:format_1961  # Stockholm
      # - edam:format_1963  # UniProt
      # ddbj ?

  name:
    type: string
    label: sequence name to retrieve
    inputBinding:
      position: 2

baseCommand: [ esl-sfetch ]

stdout: sequence  # helps with cwltool's --cache

outputs:
  sequence:
    type: stdout
    format: edam:format_1929  # FASTA

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schema.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
