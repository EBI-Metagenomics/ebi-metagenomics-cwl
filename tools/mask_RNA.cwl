#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 1024  # just a default, could be lowered
  ShellCommandRequirement: {}

inputs:
  unique_rRNA_hits: File
  16s_rRNA_hmmer_matches: File
  23s_rRNA_hmmer_matches: File
  5s_rRNA_hmmer_matches: File
  unique_tRNA_hits: File
  tRNA_matches: File
  sequences: File

baseCommand: []

arguments:
 - ln
 - -s
 - $(inputs.unique_rRNA_hits.path)
 - hmmer.txt
 - ;
 - ln
 - -s
 - $(inputs.16s_rRNA_hmmer_matches.path)
 - hmmer.16s.txt
 - ;
 - ln
 - -s
 - $(inputs.23s_rRNA_hmmer_matches.path)
 - hmmer.23s.txt
 - ;
 - ln
 - -s
 - $(inputs.5s_rRNA_hmmer_matches.path)
 - hmmer.5s.txt
 - ;
 - rnaMaskingStep.py
 - valueFrom: hmmer.txt
   prefix: --hmmer
 - valueFrom: $(inputs.tRNA_matches.path)
   prefix: --nhmmer
 - valueFrom: $(inputs.unique_tRNA_hits.path)
   prefix: --seq_id
 - valueFrom: $(inputs.sequences.path)
   prefix: --input
 - valueFrom: masked_sequences.fasta
   prefix: --output

   #  TODO: either re-write using InitialWorkDirRequirement when Toil gets
   #  support or add parsing of a CWL JSON object to the python script

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
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
