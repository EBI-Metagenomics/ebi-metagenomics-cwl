cwlVersion: v1.0
class: CommandLineTool

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 100  # just a default, could be lowered

inputs:
  sequences:
    type: File
    format: edam:format_1929  # FASTA
    inputBinding:
      prefix: -i

  header_mapping:
    type: File
    inputBinding:
      prefix: -m

  append:
    type: boolean?
    label: append to old header rather than replacing
    inputBinding:
      prefix: -a

baseCommand: [ map_fa_headers ]

arguments:
  - valueFrom: $(inputs.sequences.basename).newheaders.fasta
    prefix: -o

outputs:
  relabeled_sequences:
    type: File
    format: edam:format_1929  # FASTA
    outputBinding: { glob: $(inputs.sequences.basename).newheaders.fasta }

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schema.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
