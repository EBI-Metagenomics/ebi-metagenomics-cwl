cwlVersion: v1.0
class: Workflow
label: EMG assembly for paired end Illumina

requirements:
  StepInputExpressionRequirement: {}
  InlineJavascriptRequirement: {}
  SubworkflowFeatureRequirement: {}

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

outputs:
  SSUs:
    type: File
    outputSource: extract_SSUs/sequences

steps:
  assembly:
    run: ../tools/metaspades.cwl
    in:
      forward_reads: forward_reads
      reverse_reads: reverse_reads
    out: [ scaffolds ]

  cmscan:
    run: ../tools/infernal-cmscan.cwl
    in: 
      query_sequences: assembly/scaffolds
      covariance_model_database: covariance_model_database
      only_hmm: { valueFrom: $(true) }
      omit_alignment_section: { valueFrom: $(true) }
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
      names_contain_subseq_coords: { valueFrom: $(true) }
    out: [ sequences ]

$namespaces: { edam: http://edamontology.org/ }
$schemas: [ http://edamontology.org/EDAM_1.16.owl ]

