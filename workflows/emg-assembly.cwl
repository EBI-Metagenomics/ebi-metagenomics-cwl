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
      #trainingName:
      #  valueFrom: complete
      #trainDir: fraggenescan_models
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

