#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 1024  # just a default, could be lowered

inputs:
  sequences:
    type: File
    label: single-line sequences only
    format: edam:format_1929  # FASTA
    inputBinding:
      position: 1

baseCommand: RevReadSort.pl

arguments:
  - valueFrom: $(inputs.sequences.basename)_revsort.fasta
    position: 2

outputs:
  rev_sorted_sequences:
    type: File
    format: edam:format_1929  # FASTA
    outputBinding: { glob: $(inputs.sequences.basename)_revsort.fasta }

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schema.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
