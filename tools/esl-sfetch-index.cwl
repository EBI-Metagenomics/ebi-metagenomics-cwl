cwlVersion: v1.0
class: CommandLineTool
label: index a sequence file for use by esl-sfetch
doc: "https://github.com/EddyRivasLab/easel"

# hints:
#   - class: SoftwareRequirement
#     packages:
#       spades:
#         specs: [ https://identifiers.org/rrid/RRID:TBD ]
#         version: [ "???" ]

requirements:
  InitialWorkDirRequirement:
    listing: [ $(inputs.sequences) ]

inputs:
  sequences:
    type: File
    inputBinding:
      position: 1
      valueFrom: $(self.basename)
    format:
      - edam:format_1929  # FASTA
      - edam:format_1927  # EMBL
      - edam:format_1936  # Genbank entry format
      - edam:format_1961  # Stockholm
      - edam:format_1963  # UniProt
      # ddbj ?

baseCommand: [ esl-sfetch, --index ]

outputs:
  sequences_with_index:
    type: File
    secondaryFiles: .ssi
    format: $(inputs.sequences.format)
    outputBinding:
      glob: $(inputs.sequences.basename)

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
