cwlVersion: v1.0
class: Workflow
label: EMG pipeline v3.0 (paired end version)

requirements:
 - class: SubworkflowFeatureRequirement
 - class: SchemaDefRequirement
   types: 
    - $import: ../tools/FragGeneScan-model.yaml

inputs:
  forward_reads:
    type: File
    format: edam:format_1930  # FASTQ
  reverse_reads:
    type: File
    format: edam:format_1930  # FASTQ
  run_id: string
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
  predicted_CDS_aa:
    type: File
    outputSource: unified_processing/predicted_CDS_aa
  functional_annotations:
    type: File
    outputSource: unified_processing/functional_annotations
  go_summary:
    type: File
    outputSource: unified_processing/go_summary
  go_summary_slim:
    type: File
    outputSource: unified_processing/go_summary_slim
  otu_table_summary:
    type: File
    outputSource: unified_processing/otu_table_summary
  tree:
    type: File
    outputSource: unified_processing/tree 
  biom_json:
    type: File
    outputSource: unified_processing/biom_json
  qc_stats_summary:
    type: File
    outputSource: unified_processing/qc_stats_summary
  qc_stats_seq_len_pbcbin:
    type: File
    outputSource: unified_processing/qc_stats_seq_len_pbcbin
  qc_stats_seq_len_bin:
    type: File
    outputSource: unified_processing/qc_stats_seq_len_bin
  qc_stats_seq_len:
    type: File
    outputSource: unified_processing/qc_stats_seq_len
  qc_stats_nuc_dist:
    type: File
    outputSource: unified_processing/qc_stats_nuc_dist
  qc_stats_gc_pcbin:
    type: File
    outputSource: unified_processing/qc_stats_gc_pcbin
  qc_stats_gc_bin:
    type: File
    outputSource: unified_processing/qc_stats_gc_bin
  qc_stats_gc:
    type: File
    outputSource: unified_processing/qc_stats_gc
  ipr_match_count:
    type: int
    outputSource: unified_processing/ipr_match_count
  ipr_CDS_with_match_count:
    type: int
    outputSource: unified_processing/ipr_CDS_with_match_count
  ipr_reads_with_match_count:
    type: int
    outputSource: unified_processing/ipr_reads_with_match_count
  ipr_reads:
    type: File
    outputSource: unified_processing/ipr_reads
  ipr_summary:
    type: File
    outputSource: unified_processing/ipr_summary
  annotated_CDS_nuc:
    type: File
    outputSource: unified_processing/annotated_CDS_nuc
  annotated_CDS_aa:
    type: File
    outputSource: unified_processing/annotated_CDS_aa
  unannotated_CDS_nuc:
    type: File
    outputSource: unified_processing/unannotated_CDS_nuc
  unannotated_CDS_aa:
    type: File
    outputSource: unified_processing/unannotated_CDS_aa
  qiime_sequences-filtered_clusters:
    type: File
    outputSource: unified_processing/qiime_sequences-filtered_clusters
  qiime_sequences-filtered_otus:
    type: File
    outputSource: unified_processing/qiime_sequences-filtered_otus
  qiime_assigned_taxonomy:
    type: File
    outputSource: unified_processing/qiime_assigned_taxonomy
  16S_matches:
    type: File
    outputSource: unified_processing/16S_matches
  23S_matches:
    type: File
    outputSource: unified_processing/23S_matches
  5S_matches:
    type: File
    outputSource: unified_processing/5S_matches
  tRNA_matches:
    type: File
    outputSource: unified_processing/tRNA_matches 
  interproscan_matches:
    type: File
    outputSource: unified_processing/interproscan_matches
  pCDS_seqs:
    type: File
    outputSource: unified_processing/pCDS_seqs
  no_functions_seqs:
    type: File
    outputSource: unified_processing/no_functions_seqs
  run_id:
    type: string
    outputSource: unified_processing/run_id

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
      run_id: run_id
      fraggenescan_model: fraggenescan_model
      16S_model: 16S_model
      5S_model: 5S_model
      23S_model: 23S_model
      tRNA_model: tRNA_model
      go_summary_config: go_summary_config
    out:
      - processed_sequences
      - predicted_CDS_aa
      - functional_annotations
      - go_summary
      - go_summary_slim
      - otu_table_summary
      - tree
      - biom_json
      - qc_stats_summary
      - qc_stats_seq_len_pbcbin
      - qc_stats_seq_len_bin
      - qc_stats_seq_len
      - qc_stats_nuc_dist
      - qc_stats_gc_pcbin
      - qc_stats_gc_bin
      - qc_stats_gc
      - ipr_match_count
      - ipr_CDS_with_match_count
      - ipr_reads_with_match_count
      - ipr_reads
      - ipr_summary
      - annotated_CDS_nuc
      - annotated_CDS_aa
      - unannotated_CDS_nuc
      - unannotated_CDS_aa
      - qiime_sequences-filtered_clusters
      - qiime_sequences-filtered_otus
      - qiime_assigned_taxonomy
      - tRNA_matches
      - 16S_matches
      - 23S_matches
      - 5S_matches
      - interproscan_matches
      - pCDS_seqs
      - no_functions_seqs

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
