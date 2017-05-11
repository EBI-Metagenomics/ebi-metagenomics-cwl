cwlVersion: v1.0
class: Workflow
label: EMG QC workflow, (paired end version). Benchmarking with MG-RAST expt.

requirements:
 - class: SubworkflowFeatureRequirement

inputs:
  forward_reads:
    type: File
    format: edam:format_1930  # FASTQ
  reverse_reads:
    type: File
    format: edam:format_1930  # FASTQ

outputs:
  processed_sequences:
    type: File
    outputSource: unified_processing/processed_sequences

steps:
  overlap_reads:
    label: Paired-end overlapping reads are merged
    run: ../tools/seqprep.cwl
    in:
      forward_reads: forward_reads
      reverse_reads: reverse_reads
    out: [ merged_reads, forward_unmerged_reads, reverse_unmerged_reads ]

  combine_overlaped_and_unmerged_reads:
    run: ../tools/seqprep-merge.cwl
    in: 
      merged_reads: overlap_reads/merged_reads
      forward_unmerged_reads: overlap_reads/forward_unmerged_reads
      reverse_unmerged_reads: overlap_reads/reverse_unmerged_reads
    out: [ merged_with_unmerged_reads ]

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
