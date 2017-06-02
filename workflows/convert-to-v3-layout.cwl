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
  biom_hdf5:
    type: File
  biom_tsv:
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
  actual_run_id: string
  post_qc_reads: File
  post_qc_read_count: int
  summary: File

expression: |
  ${ var run_id = inputs.actual_run_id + "_MERGED_FASTQ";
     inputs.qc_stats_summary.basename = "summary.out";
     inputs.qc_stats_seq_len_pbcbin.basename = "seq-length.out.full_pcbin";
     inputs.qc_stats_seq_len_bin.basename = "seq-length.out.full_bin";
     inputs.qc_stats_seq_len.basename = "seq-length.out.full";
     inputs.qc_stats_nuc_dist.basename = "nucleotide-distribution.out.full";
     inputs.qc_stats_gc_pcbin.basename = "GC-distribution.out.full_pcbin";
     inputs.qc_stats_gc_bin.basename = "GC-distribution.out.full_bin";
     inputs.qc_stats_gc.basename = "GC-distribution.out.full";
     inputs.16S_matches.basename = "16S.fasta";
     inputs.23S_matches.basename = "23S.fasta";
     inputs.5S_matches.basename = "5S.fasta";
     inputs.interproscan_matches.basename = "interproscan.fasta";
     inputs.no_functions_seqs.basename = "noFunction.fasta";
     inputs.pCDS_seqs.basename = "pCDS.fasta";
     inputs.qiime_sequences-filtered_clusters.basename = run_id + "_16S_rRNA_QIIME_clusters.uc";
     inputs.qiime_sequences-filtered_otus.basename = run_id + "_16S_rRNA_QIIME_otus.txt";
     inputs.tree.basename = run_id + "_pruned.tree";
     inputs.biom_json.basename = run_id + "_otu_table_json.biom";
     inputs.biom_hdf5.basename = run_id + "_otu_table_hdf5.biom";
     inputs.biom_tsv.basename = run_id + "_otu_table.txt";
     inputs.qiime_assigned_taxonomy.basename = run_id + "_qiime_assigned_taxonomy.txt";
     inputs.processed_sequences.basename = run_id + "_RNAFiltered.fasta";
     inputs.functional_annotations.basename = run_id + "_I5.tsv";
     inputs.go_summary.basename = run_id + "_summary.go";
     inputs.go_summary_slim.basename = run_id + "_summary.go_slim";
     inputs.annotated_CDS_nuc.basename = run_id + "_CDS_annotated.ffn";
     inputs.annotated_CDS_aa.basename = run_id + "_CDS_annotated.faa";
     inputs.unannotated_CDS_nuc.basename = run_id + "_CDS_unannotated.ffn";
     inputs.unannotated_CDS_aa.basename = run_id + "_CDS_unannotated.faa";
     inputs.post_qc_reads.basename = run_id + ".fasta";
     inputs.ipr_summary.basename = run_id + "_summary.ipr";
     inputs.summary.basename = run_id + "_summary";
     var r = {
       "outputs":
         { "class": "Directory",
           "basename": run_id,
           "listing": [
             { "class": "Directory",
               "basename": "qc-statistics",
               "listing": [
                 inputs.qc_stats_summary,
                 inputs.qc_stats_seq_len_pbcbin,
                 inputs.qc_stats_seq_len_bin,
                 inputs.qc_stats_seq_len,
                 inputs.qc_stats_nuc_dist,
                 inputs.qc_stats_gc_pcbin,
                 inputs.qc_stats_gc_bin,
                 inputs.qc_stats_gc ] },
              { "class": "Directory",
               "basename": "sequence-categorisation",
               "listing": [
                 inputs.16S_matches,
                 inputs.23S_matches,
                 inputs.5S_matches,
                 inputs.interproscan_matches,
                 inputs.no_functions_seqs,
                 inputs.pCDS_seqs
               ] },
             { "class": "Directory",
               "basename": "cr_otus",
               "listing": [
                 { "class": "Directory",
                   "basename": "uclust_ref_picked_otus",
                   "listing": [
                     inputs.qiime_sequences-filtered_clusters,
                     inputs.qiime_sequences-filtered_otus
                   ] },
                 inputs.tree,
                 inputs.biom_json,
                 inputs.biom_hdf5,
                 inputs.biom_tsv,
                 inputs.biom_qiime_assigned_taxonomy
               ] },
             { "class": "File",
               "contents": inputs.post_qc_read_count,
               "basename": run_id + ".fasta.submitted.count" },
             inputs.processed_sequences,
             inputs.functional_annotations,
             inputs.go_summary,
             inputs.go_summary_slim,
             inputs.annotated_CDS_nuc,
             inputs.annotated_CDS_aa,
             inputs.unannotated_CDS_nuc,
             inputs.unannotated_CDS_aa,
             inputs.summary_ipr,
             inputs.summary
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
