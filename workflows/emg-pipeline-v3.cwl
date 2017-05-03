cwlVersion: v1.0
class: Workflow
label: EMG pipeline v3.0 (draft CWL version)

requirements:
 - class: InlineJavascriptRequirement
 - class: StepInputExpressionRequirement
 - class: SubworkflowFeatureRequirement
 - class: MultipleInputFeatureRequirement
 - class: SchemaDefRequirement
   types: 
    - $import: ../tools/InterProScan-apps.yaml
    - $import: ../tools/InterProScan-protein_formats.yaml
    - $import: ../tools/trimmomatic-sliding_window.yaml
    - $import: ../tools/trimmomatic-end_mode.yaml
    - $import: ../tools/trimmomatic-phred.yaml
    - $import: ../tools/esl-reformat-replace.yaml
    - $import: ../tools/qiime-biom-convert-table.yaml

inputs:
  forward_reads:
    type: File
    format: edam:format_1930  # FASTQ
  reverse_reads:
    type: File
    format: edam:format_1930  # FASTQ
  fraggenescan_model: File
  fraggenescan_prob_forward: File
  fraggenescan_prob_backward: File
  fraggenescan_prob_noncoding: File
  fraggenescan_prob_start: File
  fraggenescan_prob_stop: File
  fraggenescan_prob_start1: File
  fraggenescan_prob_stop1: File
  fraggenescan_pwm_dist: File
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

outputs:
  processed_sequences:
    type: File
    outputSource: mask_rRNA_and_tRNA/masked_sequences
  pCDS:
    type: File
    outputSource: fraggenescan/predictedCDS
  annotations:
    type: File
    outputSource: interproscan/i5Annotations
  otu_table_summary:
    type: File
    outputSource: create_otu_text_summary/otu_table_summary
  tree:
    type: File
    outputSource: prune_tree/pruned_tree 

steps:
  overlap_reads:
    run: ../tools/seqprep.cwl
    in:
      forward_reads: forward_reads
      reverse_reads: reverse_reads
    out: [ merged_reads, forward_unmerged_reads, reverse_unmerged_reads ]

  combine_seqprep:
    run: ../tools/seqprep-merge.cwl
    in: 
      merged_reads: overlap_reads/merged_reads
      forward_unmerged_reads: overlap_reads/forward_unmerged_reads
      reverse_unmerged_reads: overlap_reads/reverse_unmerged_reads
    out: [ merged_with_unmerged_reads ]

  trim_quality_control:
    run: ../tools/trimmomatic.cwl
    in:
      reads1: combine_seqprep/merged_with_unmerged_reads
      phred: { default: '33' }
      leading: { default: 3 }
      trailing: { default: 3 }
      end_mode: { default: SE }
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

  index_reads:
    run: ../tools/esl-sfetch-index.cwl
    in:
      sequences: convert_trimmed-reads_to_fasta/fasta
    out: [ sequences_with_index ]

  find_16S_matches:
    run: ../tools/rRNA_selection.cwl
    in:
      indexed_sequences: index_reads/sequences_with_index
      model: 16S_model
    out: [ matching_sequences, hmmer_search_results ]

  find_23S_matches:
    run: ../tools/rRNA_selection.cwl
    in:
      indexed_sequences: index_reads/sequences_with_index
      model: 23S_model
    out: [ matching_sequences, hmmer_search_results ]

  find_5S_matches:
    run: ../tools/rRNA_selection.cwl
    in:
      indexed_sequences: index_reads/sequences_with_index
      model: 5S_model
    out: [ matching_sequences, hmmer_search_results ]

  find_tRNA_matches:
    run: ../tools/tRNA_selection.cwl
    in:
      indexed_sequences: index_reads/sequences_with_index
      model: tRNA_model
    out: [ matching_sequences, hmmer_search_results ]

  collate_unique_rRNA_hmmer_hits:
    run: ../tools/collate_unique_SSU_headers.cwl
    in:
      hits:
        - find_16S_matches/hmmer_search_results
        - find_23S_matches/hmmer_search_results
        - find_5S_matches/hmmer_search_results
    out: [ unique_hits ]

  collate_unique_tRNA_hmmer_hits:
    run: ../tools/collate_unique_SSU_headers.cwl
    in:
      hits:
        source: find_tRNA_matches/hmmer_search_results
        valueFrom: ${ return [ self ]; }
    out: [ unique_hits ]

  mask_rRNA_and_tRNA:
    run: ../tools/mask_RNA.cwl
    in:
      unique_rRNA_hits: collate_unique_rRNA_hmmer_hits/unique_hits
      16s_rRNA_hmmer_matches: find_16S_matches/hmmer_search_results
      23s_rRNA_hmmer_matches: find_23S_matches/hmmer_search_results
      5s_rRNA_hmmer_matches: find_5S_matches/hmmer_search_results
      unique_tRNA_hits: collate_unique_tRNA_hmmer_hits/unique_hits
      tRNA_matches: find_tRNA_matches/hmmer_search_results
      sequences: index_reads/sequences_with_index
    out: [ masked_sequences ]

  fraggenescan:
    run: ../tools/FragGeneScan1_20.cwl
    in:
      sequence: mask_rRNA_and_tRNA/masked_sequences
      completeSeq: { default: true }
      model: fraggenescan_model
      prob_forward: fraggenescan_prob_forward
      prob_backward: fraggenescan_prob_backward
      prob_noncoding: fraggenescan_prob_noncoding
      prob_start: fraggenescan_prob_start
      prob_stop: fraggenescan_prob_stop
      prob_start1: fraggenescan_prob_start1
      prob_stop1: fraggenescan_prob_stop1
      pwm_dist: fraggenescan_pwm_dist
    out: [predictedCDS]

  remove_asterisks_and_reformat:
    run: ../tools/esl-reformat.cwl
    in:
      sequences: fraggenescan/predictedCDS
      replace: { default: { find: '*', replace: X } }
    out: [ reformatted_sequences ]

  interproscan:
    run: ../tools/InterProScan5.21-60.cwl
    in:
      proteinFile: remove_asterisks_and_reformat/reformatted_sequences
      applications:
        default:
          - Pfam
          - TIGRFAM
          - PRINTS
          - ProSitePatterns
          - Gene3D
      # outputFileType: { valueFrom: "TSV" }
    out: [i5Annotations]

  pick_closed_reference_otus:
    run: ../tools/qiime-pick_closed_reference_otus.cwl
    in:
      sequences: find_16S_matches/matching_sequences
    out: [ otu_table, otus_tree ]

  convert_new_biom_to_old_biom:
    run: ../tools/qiime-biom-convert.cwl
    in:
      biom: pick_closed_reference_otus/otu_table
      table_type: { default: OTU Table }
      json: { default: true }
    out: [ result ]

  convert_new_biom_to_classic:
    run: ../tools/qiime-biom-convert.cwl
    in:
      biom: pick_closed_reference_otus/otu_table
      header_key: { default: taxonomy }
      table_type: { default: OTU Table }
      tsv: { default: true }
    out: [ result ]

  create_otu_text_summary:
    run: ../tools/qiime-biom-summarize_table.cwl
    in:
      biom: pick_closed_reference_otus/otu_table
    out: [ otu_table_summary ]

  extract_observations:
    run:
      class: CommandLineTool
      inputs: { tsv_otu_table: File }
      baseCommand: [ awk, '/#/ {next};{print $1}' ]
      stdin: $(inputs.tsv_otu_table.path)
      stdout: observations  # helps cwltool's cache
      outputs: { observations: stdout }
    in: { tsv_otu_table: convert_new_biom_to_classic/result }
    out: [ observations ]

  prune_tree:
    run: ../tools/qiime-filter_tree.cwl
    in:
      tree: pick_closed_reference_otus/otus_tree
      tips_or_seqids_to_retain: extract_observations/observations
    out: [ pruned_tree ]

$namespaces: { edam: "http://edamontology.org/" }
$schemas: [ "http://edamontology.org/EDAM_1.16.owl" ]

