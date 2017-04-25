cwlVersion: v1.0
class: Workflow
label: EMG pipeline v3.0 (draft CWL version)

requirements:
 - class: StepInputExpressionRequirement
 - class: SubworkflowFeatureRequirement
 - class: MultipleInputFeatureRequirement
 - $import: ../tools/InterProScan5.21-60-types.yaml
 - $import: ../trimmomatic-types.yml

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

outputs:
  SSUs:
    type: File
    outputSource: extract_SSUs/sequences

  classifications:
    type: File
    outputSource: classify_SSUs/classifications

  scaffolds:
    type: File
    outputSource: assembly/scaffolds

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
      forward_unmerged_reads: forward_unmerged_reads
      reverse_unmerged_reads: reverse_unmerged_reads
    out: [ merged_with_unmerged_reads ]

  trim_quality_control:
    run: ../tools/trimmomatic.cwl
    in:
      reads1: combine_seqprep/merged_with_unmerged_reads
      phred: { default: '33' }
      leading: { default: '3' }
      trailing: { default: '3' }
      end_mode: { default: 'SE' }
      slidingwindow:
        default:
          class: ../trimmomatic-types.yml#slidingWindow
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
      index_sequences: index_reads/sequences_with_index
      model: 16S_model
    out: [ matching_sequences ]

  fraggenescan:
    run: ../tools/FragGeneScan1_20.cwl
    in:
      sequence: assembly/scaffolds
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
      outputFileType:
        valueFrom: TSV
    out: [i5Annotations]

$namespaces: { edam: "http://edamontology.org/" }
$schemas: [ "http://edamontology.org/EDAM_1.16.owl" ]

