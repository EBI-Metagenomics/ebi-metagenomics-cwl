cwlVersion: v1.0
class: Workflow
label: EMG pipeline v3.0 (single end version)

requirements:
 - class: SubworkflowFeatureRequirement
 - class: SchemaDefRequirement
   types: 
    - $import: ../tools/FragGeneScan-model.yaml
    - $import: ../tools/InterProScan-apps.yaml
    - $import: ../tools/InterProScan-protein_formats.yaml
    - $import: ../tools/trimmomatic-sliding_window.yaml
    - $import: ../tools/trimmomatic-end_mode.yaml
    - $import: ../tools/trimmomatic-phred.yaml
    - $import: ../tools/esl-reformat-replace.yaml
    - $import: ../tools/qiime-biom-convert-table.yaml

inputs:
  reads:
    type: File
    format: edam:format_1930  # FASTQ
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
    outputSource: find_SSUs_and_mask/masked_sequences
  predicted_CDS:
    type: File
    outputSource: fraggenescan/predictedCDS
  annotations:
    type: File
    outputSource: interproscan/i5Annotations
  otu_table_summary:
    type: File
    outputSource: 16S_taxonomic_analysis/otu_table_summary
  tree:
    type: File
    outputSource: 16S_taxonomic_analysis/tree
  biom_json:
    type: File
    outputSource: 16S_taxonomic_analysis/biom_json
  go_summary:
    type: File
    outputSource: summarize_with_GO/go_summary

steps:
  trim_quality_control:
    run: ../tools/trimmomatic.cwl
    in:
      reads1: reads
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

  find_SSUs_and_mask:
    run: rna-selector.cwl
    in: 
      reads: convert_trimmed-reads_to_fasta/fasta
      16S_model: 16S_model
      5S_model: 5S_model
      23S_model: 23S_model
      tRNA_model: tRNA_model
    out: [ 16S_matches, masked_sequences ]

  fraggenescan:
    run: ../tools/FragGeneScan1_20.cwl
    in:
      sequence: find_SSUs_and_mask/masked_sequences
      completeSeq: { default: true }
      model: fraggenescan_model
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
    out: [i5Annotations]

  summarize_with_GO:
    run: ../tools/go_summary.cwl
    in:
      InterProScan_results: interproscan/i5Annotations
      config: go_summary_config
    out: [ go_summary ]

  16S_taxonomic_analysis:
    run: 16S_taxonomic_analysis.cwl
    in:
      16S_matches: find_SSUs_and_mask/16S_matches
    out: [ otu_table_summary, tree, biom_json ]

$namespaces: { edam: "http://edamontology.org/" }
$schemas: [ "http://edamontology.org/EDAM_1.16.owl" ]
