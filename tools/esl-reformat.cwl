cwlVersion: v1.0
class: CommandLineTool
label: normalize to fasta
doc: |
  normalizes input sequeces to FASTA with fixed number of sequence characters
  per line using esl-reformat from https://github.com/EddyRivasLab/easel

# hints:
#   - class: SoftwareRequirement
#     packages:
#       easel:
#         specs: [ https://identifiers.org/rrid/RRID:TBD ]
#         version: [ "???" ]

inputs:
  sequences:
    type: File
    inputBinding:
      position: 1
    format:
      - edam:format_1930  # FASTQ
      - edam:format_1929  # FASTA
      - edam:format_1927  # EMBL
      - edam:format_1936  # Genbank entry format
      - edam:format_1961  # Stockholm
      - edam:format_1963  # UniProt
      # ddbj ?
  protein_IUPAC_only:
    type: boolean?
    default: false
    doc: remove DNA IUPAC codes; convert ambig chars to N
    inputBinding:
      prefix: -n

baseCommand: [ esl-reformat, fasta ]

outputs:
  reformatted_sequences:
    type: stdout
    format: edam:format_1929

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
