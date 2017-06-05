cwlVersion: v1.0
class: Workflow
label: EMG pipeline v3.0 (single end version/Ion torrent)

requirements:
 - class: SubworkflowFeatureRequirement
 - class: SchemaDefRequirement
   types: 
    - $import: ../tools/FragGeneScan-model.yaml

inputs:
  forward_reads:
    type: File
    format: edam:format_1930  # FASTQ
  fraggenescan_model: ../tools/FragGeneScan-model.yaml#model
  16S_model:
    type: File
    format: edam:format_1370  # HMMER
  5S_model:
    type: File
    format: edam:format_1370  # HMMER
  23S_model:
    type: File
    format: edam:format_1370  # HMMER
  tRNA_model:
    type: File
    format: edam:format_1370  # HMMER
  go_summary_config: File

outputs:
  processed_sequences:
    type: File
    outputSource: unified_processing/processed_sequences
  predicted_CDS:
    type: File
    outputSource: unified_processing/predicted_CDS
  functional_annotations:
    type: File
    outputSource: unified_processing/functional_annotations
  otu_table_summary:
    type: File
    outputSource: unified_processing/otu_table_summary
  tree:
    type: File
    outputSource: unified_processing/tree 
  biom_json:
    type: File
    outputSource: unified_processing/biom_json

#TODO - need to also pull back all of the QC files..

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

  unified_processing:
    label: continue with the main workflow
    run: emg-pipeline-v3.cwl
    in:
      reads: combine_overlaped_and_unmerged_reads/merged_with_unmerged_reads
      fraggenescan_model: fraggenescan_model
      16S_model: 16S_model
      5S_model: 5S_model
      23S_model: 23S_model
      tRNA_model: tRNA_model
      go_summary_config: go_summary_config
    out:
      - processed_sequences
      - predicted_CDS
      - functional_annotations
      - otu_table_summary
      - tree
      - biom_json

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
