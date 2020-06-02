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

  id_list:
    type: File
    inputBinding:
      prefix: -d

baseCommand: faselector

arguments:
  - valueFrom: $(inputs.sequences.basename).keep.fasta
    prefix: -k
  - valueFrom: $(inputs.sequences.basename).reject.fasta
    prefix: -r

outputs:
  kept_sequences:
    type: File
    format: edam:format_1929  # FASTA
    outputBinding: { glob: $(inputs.sequences.basename).keep.fasta }
  rejected_sequences:
    type: File
    format: edam:format_1929  # FASTA
    outputBinding: { glob: $(inputs.sequences.basename).reject.fasta }

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schema.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
