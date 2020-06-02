cwlVersion: v1.0
class: CommandLineTool

label: drop short seqs

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 100  # just a default, could be lowered

hints:
  SoftwareRequirement:
    packages:
      biopython:
        specs: [ "https://identifiers.org/rrid/RRID:SCR_007173" ]
        version: [ "1.65", "1.66", "1.69" ]

inputs:
  sequences:
    type: File
    format: edam:format_1929  # FASTA

  minimum_length:
    type: int
    label: discard if number of bases is less than this amount

baseCommand: [ python ]

arguments:
  - valueFrom: |
      from Bio import SeqIO
      input_seq_iterator = SeqIO.parse("$(inputs.sequences.path)", "fasta")
      short_seq_iterator = (record for record in input_seq_iterator if len(record.seq) >= $(inputs.minimum_length))
      SeqIO.write(short_seq_iterator, "$(inputs.sequences.basename).filtered.fasta", "fasta")
    prefix: -c

outputs:
  filtered_sequences:
    type: File
    outputBinding: { glob: $(inputs.sequences.basename).filtered.fasta }
    format: edam:format_1929  # FASTA

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schema.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
