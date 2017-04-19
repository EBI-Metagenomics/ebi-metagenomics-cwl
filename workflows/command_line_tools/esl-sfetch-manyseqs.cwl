cwlVersion: v1.0
class: CommandLineTool
label: index a sequence file for use by esl-sfetch
doc: https://github.com/EddyRivasLab/easel

# hints:
#   - class: SoftwareRequirement
#     packages:
#       spades:
#         specs: [ https://identifiers.org/rrid/RRID:TBD ]
#         version: [ "???" ]

inputs:
  sequences:
    label: sequence file indexed by esl-sfetch-index
    type: File
    secondaryFiles: .ssi
    inputBinding:
      prefix: -f
      position: 1
    format:
      - edam:format_1929  # FASTA
      - edam:format_1927  # EMBL
      - edam:format_1936  # Genbank entry format
      - edam:format_1961  # Stockholm
      - edam:format_1963  # UniProt
      # ddbj ?

  names:
    type: File
    label: sequence names to retrieve, one per line
    inputBinding:
      position: 2

baseCommand: [ esl-sfetch ]

outputs:
  sequence:
    type: stdout
    format: edam:format_1929  # FASTA

$namespaces: { edam: http://edamontology.org/ }
$schemas: [ http://edamontology.org/EDAM_1.16.owl ]
