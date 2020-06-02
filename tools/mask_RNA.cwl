#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

requirements:
  InitialWorkDirRequirement:
    listing:
      - entryname: hmmer.txt
        entry: $(inputs.unique_rRNA_hits)
      - entryname: hmmer.16s.txt
        entry: $(inputs.16s_rRNA_hmmer_matches)
      - entryname: hmmer.23s.txt
        entry: $(inputs.23s_rRNA_hmmer_matches)
      - entryname: hmmer.5s.txt
        entry: $(inputs.5s_rRNA_hmmer_matches)
  ResourceRequirement:
   coresMax: 1
   ramMin: 1024  # just a default, could be lowered

inputs:
  unique_rRNA_hits: File
  16s_rRNA_hmmer_matches: File
  23s_rRNA_hmmer_matches: File
  5s_rRNA_hmmer_matches: File
  unique_tRNA_hits: File
  tRNA_matches: File
  sequences: File

baseCommand: rnaMaskingStep.py

arguments:
 - prefix: --hmmer
   valueFrom: hmmer.txt
 - prefix: --nhmmer
   valueFrom: $(inputs.tRNA_matches.path)
 - prefix: --seq_id
   valueFrom: $(inputs.unique_tRNA_hits.path)
 - prefix: --input
   valueFrom: $(inputs.sequences.path)
 - prefix: --output
   valueFrom: masked_sequences.fasta

outputs:
  masked_sequences:
    type: File
    format: edam:format_1929  # FASTA
    outputBinding: { glob: masked_sequences.fasta }

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schema.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
