cwlVersion: v1.0
class: Workflow
label: EMG pipeline v3.0 (draft CWL version)

requirements:
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
          class: ../tools/trimmomatic-sliding_window.yaml#slidingWindow
          windowSize: 4
          requiredQuality: 15
    out: [reads1_trimmed]

  normalize_reads:
    run: ../tools/seq-normalize.cwl
    in:
      sequences: trim_quality_control/reads1_trimmed
    out: [ reformatted_sequences ]

  index_reads:
    run: ../tools/esl-sfetch-index.cwl
    in:
      sequences: normalize_reads/reformatted_sequences
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
    run: ../tools/collate_unique_rRNA_headers.cwl
    in:
      hits:
        - find_16S_matches/hmmer_search_results
        - find_23S_matches/hmmer_search_results
        - find_5S_matches/hmmer_search_results
    out: [ unique_hits ]

  collate_unique_tRNA_hmmer_hits:
    run: ../tools/collate_unique_rRNA_headers.cwl
    in:
      hits: [ find_tRNA_matches/hmmer_search_results ]
    out: [ unique_hits ]

  mask_rRNA_and_tRNA:
    run: ../tools/mask_RNA.cwl
    in:
      unique_rRNA_hits: collate_unique_rRNA_hmmer_hits/unique_hits
      16s_rRNA_hmmer_matches: find_16S_matches/matching_sequences
      23s_rRNA_hmmer_matches: find_23S_matches/matching_sequences
      5s_rRNA_hmmer_matches: find_5S_matches/matching_sequences
      unique_tRNA_hits: collate_unique_tRNA_hmmer_hits/unique_hits
      tRNA_matches: find_tRNA_matches/matching_sequences
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

  interproscan:
    run: ../tools/InterProScan5.21-60.cwl
    in:
      proteinFile: fraggenescan/predictedCDS
      applications:
        default:
          - Pfam
          - TIGRFAM
          - PRINTS
          - ProSitePatterns
          - Gene3d
      # outputFileType: { valueFrom: "TSV" }
    out: [i5Annotations]

$namespaces: { edam: "http://edamontology.org/" }
$schemas: [ "http://edamontology.org/EDAM_1.16.owl" ]

