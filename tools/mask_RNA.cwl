#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

requirements:
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
 - nhmmer.txt
 - ;
 - ln
 - -s
 - $(inputs.16s_rRNA_hmmer_matches.path)
 - nhmmer.16s.txt
 - ;
 - ln
 - -s
 - $(inputs.23s_rRNA_hmmer_matches.path)
 - nhmmer.23s.txt
 - ;
 - ln
 - -s
 - $(inputs.5s_rRNA_hmmer_matches.path)
 - nhmmer.5s.txt
 - ;
 - rnaMaskingStep.py
 - --hmmer
 - nhmmer.txt
 - --nhmmer
 - $(inputs.unique_tRNA_hits.path)
 - --seq_id
 - $(inputs.tRNA_matches.path)
 - --input
 - $(inputs.sequences.path)
 - --output
 - masked_sequences.fasta

   #  TODO: either re-write using InitialWorkDirRequirement when Toil gets
   #  support or add parsing of a CWL JSON object to the python script

outputs:
  masked_sequences:
    type: File
    format: edam:format_1929  # FASTA
    outputBinding: { glob: masked_sequences.fasta }

$namespaces: { edam: "http://edamontology.org/" }
$schemas: [ "http://edamontology.org/EDAM_1.16.owl" ]
