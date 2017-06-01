cwlVersion: v1.0
class: ExpressionTool
requirements:
  InlineJavascriptRequirement: {}
inputs:
  processed_sequences:
    type: File
  predicted_CDS_aa:
    type: File
  functional_annotations:
    type: File
  go_summary:
    type: File
  go_summary_slim:
    type: File
  otu_table_summary:
    type: File
  tree:
    type: File
  biom_json:
    type: File
  qc_stats_summary:
    type: File
  qc_stats_seq_len_pbcbin:
    type: File
  qc_stats_seq_len_bin:
    type: File
  qc_stats_seq_len:
    type: File
  qc_stats_nuc_dist:
    type: File
  qc_stats_gc_pcbin:
    type: File
  qc_stats_gc_bin:
    type: File
  qc_stats_gc:
    type: File
  ipr_match_count:
    type: int
  ipr_CDS_with_match_count:
    type: int
  ipr_reads_with_match_count:
    type: int
  ipr_reads:
    type: File
  ipr_summary:
    type: File
  annotated_CDS_nuc:
    type: File
  annotated_CDS_aa:
    type: File
  unannotated_CDS_nuc:
    type: File
  unannotated_CDS_aa:
    type: File
  qiime_sequences-filtered_clusters:
    type: File
  qiime_sequences-filtered_otus:
    type: File
  qiime_assigned_taxonomy:
    type: File
  16S_matches:
    type: File
  23S_matches:
    type: File
  5S_matches:
    type: File
  tRNA_matches:
    type: File
  interproscan_matches:
    type: File
  pCDS_seqs:
    type: File
  no_functions_seqs:
    type: File
  run_id: string

expression: |
  ${ var run_id = inputs.run_id + "_MERGED_FASTQ";
     inputs.tree.basename = run_id + "_pruned.tree";
     inputs.biom_json.basename = run_id + "_otu_table_json.biom";
     inputs.processed_sequences.basename = run_id + "_RNAFiltered.fasta";
     inputs.functional_annotations.basename = run_id + "_I5.tsv";
     inputs.go_summary.basename = run_id + "_summary.go";
     inputs.go_summary_slim.basename = run_id + "_summary.go_slim";
     var r = {
       "outputs":
         { "class": "Directory",
           "basename": run_id,
           "listing": [
             { "class": "Directory",
               "basename": "cr_otus",
               "listing": [
                 inputs.tree,
                 inputs.biom_json
               ] },
             inputs.processed_sequences,
             inputs.functional_annotations,
             inputs.go_summary,
             inputs.go_summary_slim
             ] } };
     return r; }

outputs:
  results: Directory


$namespaces:
 s: http://schema.org/
$schemas:
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
