cwlVersion: v1.0
class: Workflow
label: EMG pipeline v3.0 (single end version)

requirements:
 - class: SubworkflowFeatureRequirement
 - class: SchemaDefRequirement
   types: 
    - $import: ../tools/FragGeneScan-model.yaml
    - $import: ../tools/trimmomatic-sliding_window.yaml
    - $import: ../tools/trimmomatic-end_mode.yaml
    - $import: ../tools/trimmomatic-phred.yaml

inputs:
  reads:
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

  #TODO - check if we need the post-QC sequences. Below fetches it.
  post_sequences:
    type: File
    outputSource: clean_fasta_headers/sequences_with_cleaned_headers

  #Sequences that are masked after the ribosomal step
  processed_sequences:
    type: File
    outputSource: find_SSUs_and_mask/masked_sequences
  
  #Taxonomic analysis step
  otu_table_summary:
    type: File
    outputSource: 16S_taxonomic_analysis/otu_table_summary
  tree:
    type: File
    outputSource: 16S_taxonomic_analysis/tree
  biom_json:
    type: File
    outputSource: 16S_taxonomic_analysis/biom_json

  #The predicted proteins and their annotations
  predicted_CDS_aa:
    type: File
    outputSource: ORF_prediction/predicted_CDS_aa
  functional_annotations:
    type: File
    outputSource: functional_analysis/functional_annotations
  go_summary:
    type: File
    outputSource: functional_analysis/go_summary
  go_summary_slim:
    type: File
    outputSource: functional_analysis/go_summary_slim

  #All of the sequence file QC stats
  qc_stats_summary:
    type: File
    outputSource: sequence_stats/summary_out
  qc_stats_seq_len_pbcbin:
    type: File
    outputSource: sequence_stats/seq_length_pcbin
  qc_stats_seq_len_bin:
    type: File
    outputSource: sequence_stats/seq_length_bin
  qc_stats_seq_len:
    type: File
    outputSource: sequence_stats/seq_length_out 
  qc_stats_nuc_dist:
    type: File
    outputSource: sequence_stats/nucleotide_distribution_out
  qc_stats_gc_pcbin:
    type: File
    outputSource: sequence_stats/gc_sum_pcbin
  qc_stats_gc_bin:
    type: File
    outputSource: sequence_stats/gc_sum_bin
  qc_stats_gc:
    type: File
    outputSource: sequence_stats/gc_sum_out
  ipr_matchNumber:
    type: int
    outputSource: ipr_stats/matchNumber
  ipr_cdsWithMatchNumber:
    type: int
    outputSource: ipr_stats/cdsWithMatchNumber
  ipr_readWithMatchNumber:
    type: int
    outputSource: ipr_stats/readWithMatchNumber
  ipr_reads:
    type: File
    outputSource: ipr_stats/reads
  ipr_summary:
    type: File
    outputSource: ipr_summary/ipr_summary
  annotated_CDS_nuc:
    type: File
    outputSource: relabel_annotated_cds_nuc_seqs/relabeled_sequences
  annotated_CDS_aa:
    type: File
    outputSource: relabel_annotated_cds_aa_seqs/relabeled_sequences
  unannotated_CDS_nuc:
    type: File
    outputSource: divide_ffn/rejected_sequences
  unannotated_CDS_aa:
    type: File
    outputSource: divide_faa/rejected_sequences

#TODO - check all the outputs

steps:
  trim_quality_control:
    doc: |
      Low quality trimming (low quality ends and sequences with < quality scores
      less than 15 over a 4 nucleotide wide window are removed)
    run: ../tools/trimmomatic.cwl
    in:
      reads1: reads
      phred: { default: '33' }
      leading: { default: 3 }
      trailing: { default: 3 }
      end_mode: { default: SE }
      minlen: { default: 100 }
      slidingwindow:
        default:
          windowSize: 4
          requiredQuality: 15
    out: [reads1_trimmed]

  convert_trimmed-reads_to_fasta:
    run: ../tools/fastq_to_fasta.cwl
    in:
      fastq: trim_quality_control/reads1_trimmed
    out: [ fasta ]

  clean_fasta_headers:
    run: ../tools/clean_fasta_headers.cwl
    in:
      sequences: convert_trimmed-reads_to_fasta/fasta
    out: [ sequences_with_cleaned_headers ]

  sequence_stats:
    run: ../tools/qc-stats.cwl
    in: 
      QCed_reads: clean_fasta_headers/sequences_with_cleaned_headers
    out: 
        - summary_out
        - seq_length_pcbin
        - seq_length_bin
        - seq_length_out 
        - nucleotide_distribution_out
        - gc_sum_pcbin
        - gc_sum_bin
        - gc_sum_out

  find_SSUs_and_mask:
    run: rna-selector.cwl
    in: 
      reads: clean_fasta_headers/sequences_with_cleaned_headers
      run_id: run_id
      16S_model: 16S_model
      5S_model: 5S_model
      23S_model: 23S_model
      tRNA_model: tRNA_model
    out: [ 16S_matches, masked_sequences ]

  ORF_prediction:
    run: orf_prediction.cwl
    in:
      sequence: find_SSUs_and_mask/masked_sequences
      completeSeq: { default: false }
      model: fraggenescan_model
    out: [predicted_CDS_aa, predicted_CDS_nuc]

  functional_analysis:
    doc: |
      Matches are generated against predicted CDS, using a sub set of databases
      (Pfam, TIGRFAM, PRINTS, PROSITE patterns, Gene3d) from InterPro. 
    run: functional_analysis.cwl
    in:
      predicted_CDS: ORF_prediction/predicted_CDS_aa
      go_summary_config: go_summary_config
    out: [ functional_annotations, go_summary, go_summary_slim ]

  16S_taxonomic_analysis:
    doc: |
      16s rRNA are annotated using the Greengenes reference database
      (default closed-reference OTU picking protocol with Greengenes
      13.8 reference with reverse strand matching enabled).
    run: 16S_taxonomic_analysis.cwl
    in:
      16S_matches: find_SSUs_and_mask/16S_matches
    out: [ otu_table_summary, tree, biom_json ]

  ipr_stats:
    run: ../tools/ipr_stats.cwl
    in:
      iprscan: functional_analysis/functional_annotations
    out:
      - matchNumber
      - cdsWithMatchNumber
      - readWithMatchNumber
      - reads
      - id_list
      - ipr_entry_maps

  ipr_summary:
    run: ../tools/write_ipr_summary.cwl
    in:
      ipr_entry_maps: ipr_stats/ipr_entry_maps
    out: [ ipr_summary ]

  divide_faa:
    run: ../tools/faselector.cwl
    in:
      sequences: ORF_prediction/predicted_CDS_aa
      id_list: ipr_stats/id_list
    out: [ kept_sequences, rejected_sequences ]

  divide_ffn:
    run: ../tools/faselector.cwl
    in:
      sequences: ORF_prediction/predicted_CDS_nuc
      id_list: ipr_stats/id_list
    out: [ kept_sequences, rejected_sequences ]

  extract_iprscan_coords:
    run: ../tools/extract_sig_coords.cwl
    in:
      i5_annotations: functional_analysis/functional_annotations
    out: [ matches_coords ]

  orf_stats:
    run: ../tools/orf_stats.cwl
    in:
      orfs: ORF_prediction/predicted_CDS_aa
    out: [ numberReadsWithOrf, numberOrfs, readsWithOrf ]

  relabel_annotated_cds_aa_seqs:
    run: ../tools/map_fa_headers.cwl
    in:
      sequences: divide_faa/kept_sequences
      header_mapping: extract_iprscan_coords/matches_coords
      append: { default: true }
    out: [ relabeled_sequences ]

  relabel_annotated_cds_nuc_seqs:
    run: ../tools/map_fa_headers.cwl
    in:
      sequences: divide_ffn/kept_sequences
      header_mapping: extract_iprscan_coords/matches_coords
      append: { default: true }
    out: [ relabeled_sequences ]

  categorisation:
    run: ../tools/create_categorisations.cwl
    in:
      seqs: find_SSUs_and_mask/masked_sequences
      ipr_idset: ipr_stats/reads
      cds_idset: orf_stats/readsWithOrf
    out: [ interproscan, pCDS_seqs, no_functions_seqs ]

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
