cwlVersion: v1.0
class: Workflow
label: EMG assembly for paired end Illumina

requirements:
 - class: StepInputExpressionRequirement
 - class: SubworkflowFeatureRequirement
 - $import: ../tools/InterProScan5.21-60-types.yaml

inputs:
  forward_reads:
    type: File
    format: edam:format_1930  # FASTQ
  reverse_reads:
    type: File
    format: edam:format_1930  # FASTQ
  covariance_model_database:
    type: File
    secondaryFiles:
     - .i1f
     - .i1i
     - .i1m
     - .i1p
  fraggenescan_model: File
  fraggenescan_prob_forward: File
  fraggenescan_prob_backward: File
  fraggenescan_prob_noncoding: File
  fraggenescan_prob_start: File
  fraggenescan_prob_stop: File
  fraggenescan_prob_start1: File
  fraggenescan_prob_stop1: File
  fraggenescan_pwm_dist: File
  assembly_mem_limit:
    type: int
    doc: in Gb

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
  assembly:
    run: ../tools/metaspades.cwl
    in:
      forward_reads: forward_reads
      reverse_reads: reverse_reads
      memory_limit: assembly_mem_limit
    out: [ scaffolds ]

  cmscan:
    run: ../tools/infernal-cmscan.cwl
    in: 
      query_sequences: assembly/scaffolds
      covariance_model_database: covariance_model_database
      only_hmm: { default: true }
      omit_alignment_section: { default: true }
    out: [ matches ]
  
  get_SSU_coords:
    run: ../tools/SSU-from-tablehits.cwl
    in:
      table_hits: cmscan/matches
    out: [ SSU_coordinates ]

  index_scaffolds:
    run: ../tools/esl-sfetch-index.cwl
    in:
      sequences: assembly/scaffolds
    out: [ sequences_with_index ]

  extract_SSUs:
    run: ../tools/esl-sfetch-manyseqs.cwl
    in:
      indexed_sequences: index_scaffolds/sequences_with_index
      names: get_SSU_coords/SSU_coordinates
      names_contain_subseq_coords: { default: true }
    out: [ sequences ]

  classify_SSUs:
    run: ../tools/mapseq.cwl
    in:
      sequences: extract_SSUs/sequences
    out: [ classifications ]

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

