cwlVersion: v1.0
class: CommandLineTool

hints:
  - class: SoftwareRequirement
    packages:
      biopython:
        specs: [ "https://identifiers.org/rrid/RRID:SCR_007173" ]
        version: [ "1.65", "1.66", "1.69" ]

inputs:
  fastq:
    type: File
    format: edam:format_1930  # FASTQ

baseCommand: [ python ]

arguments:
  - valueFrom: |
      from Bio import SeqIO; SeqIO.convert($(inputs.fastq.path), "fastq", "$(inputs.fastq.basename).fasta", "fasta");
    prefix: -c

outputs:
  fasta:
    type: File
    outputBinding: { glob: $(inputs.fastq.basename).fasta }
    format: edam:format_1929  # FASTA

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
