cwlVersion: v1.0
class: Workflow
label: EMG pipeline v4.0 (paired end version)

requirements:
 - class: SubworkflowFeatureRequirement
 - class: SchemaDefRequirement
   types: 
    - $import: ../tools/FragGeneScan-model.yaml
    - $import: ../tools/InterProScan-apps.yaml
    - $import: ../tools/InterProScan-protein_formats.yaml
    - $import: ../tools/esl-reformat-replace.yaml
    - $import: ../tools/biom-convert-table.yaml

inputs:
  forward_reads:
    type: File
    format: edam:format_1930  # FASTQ
  reverse_reads:
    type: File
    format: edam:format_1930  # FASTQ
  fraggenescan_model: ../tools/FragGeneScan-model.yaml#model
  
  #Rfam modelts for ribosomal subunits and other ubiquitous ncRNAs
  #For each there is an assoicated clan file.
  ncRNA_ribosomal_models: File[]
  ncRNA_ribosomal_model_clans: File
  ncRNA_other_models: File[]
  ncRNA_other_model_clans: File
  
  #Input files for mapseq
  mapseq_ref:
    type: File
    format: edam:format_1929  # FASTA
    secondaryFiles: .mscluster
  mapseq_taxonomy: File
  sequencing_run_id: string

  #Go summary file for slimming 
  go_summary_config: File

outputs:
  #
  processed_nucleotide_reads:
    type: File
    outputSource: unified_processing/processed_nucleotide_reads
 
  #The idenditied SSU rRNA and their classification
  SSU_sequences:
    type: File
    outputSource: unified_processing/SSU_sequences  
  ssu_classifications:
    type: File
    outputSource: unified_processing/ssu_classifications
  LSU_sequences:
    type: File
    outputSource: unified_processing/LSU_sequences  
  5S_sequences:
    type: File
    outputSource: unified_processing/5S_sequences  

  
  predicted_CDS:
    type: File
    outputSource: unified_processing/predicted_CDS


  #Keep all of the protein stuff here
  predicted_CDS:
    type: File
    outputSource: unified_processing/predicted_CDS

  functional_annotations:
    type: File
    outputSource: unified_processing/functional_annotations
  go_summary:
    type: File
    outputSource: unified_processing/go_summary 
  go_summary_slim:
    type: File
    outputSource: unified_processing/go_summary_slim

  #Other non-coding RNA hits
  other_ncRNAs:
    type: File
    outputSource: unified_processing/other_ncRNAs

  #All of the sequence file QC stats
  qc_stats_summary:
    type: File
    outputSource: unified_processing/qc_stats_summary
  qc_stats_seq_len_pbcbin:
    type: File
    outputSource: unified_processing/qc_stats_seq_len_pcbin
  qc_stats_seq_len_bin:
    type: File
    outputSource: unified_processing/qc_stats_seq_len_bin
  qc_stats_seq_len:
    type: File
    outputSource: unified_processing/qc_stats_seq_len
  qc_stats_nuc_dist:
    type: File
    outputSource: unified_processing/qc_stats_nuc_dist
  qc_stats_gc_pcbin:
    type: File
    outputSource: unified_processing/qc_stats_gc_pcbin
  qc_stats_gc_bin:
    type: File
    outputSource: unified_processing/qc_stats_gc_bin
  qc_stats_gc:
    type: File
    outputSource: unified_processing/qc_stats_gc

  #TODO -
  # Add a step to extract ncRNAs
  # Sequence categoriastion outputs
  # Summary files
 
steps:
  overlap_reads:
    label: Paired-end overlapping reads are merged
    run: ../tools/seqprep.cwl
    in:
      forward_reads: forward_reads
      reverse_reads: reverse_reads
    out: [ merged_reads, forward_unmerged_reads, reverse_unmerged_reads ]

  combine_overlaped_and_unmerged_reads:
    run: ../tools/seqprep-merge.cwl
    in: 
      merged_reads: overlap_reads/merged_reads
      forward_unmerged_reads: overlap_reads/forward_unmerged_reads
      reverse_unmerged_reads: overlap_reads/reverse_unmerged_reads
    out: [ merged_with_unmerged_reads ]

  unified_processing:
    label: continue with the main workflow
    run: emg-core-analysis-v4.cwl
    in:
      mapseq_ref: mapseq_ref
      mapseq_taxonomy: mapseq_taxonomy 
      sequencing_run_id: sequencing_run_id
      reads: combine_overlaped_and_unmerged_reads/merged_with_unmerged_reads
      fraggenescan_model: fraggenescan_model
 #Inputs are different.
      ncRNA_ribosomal_models: ncRNA_ribosomal_models
      ncRNA_ribosomal_model_clans: ncRNA_ribosomal_model_clans
      ncRNA_other_models: ncRNA_other_models
      ncRNA_other_model_clans: ncRNA_other_model_clans
      go_summary_config: go_summary_config
    out:
      - processed_nucleotide_reads
      - other_ncRNAs
      - SSU_sequences
      - LSU_sequences
      - 5S_sequences
      - ssu_classifications
      - predicted_CDS
      - functional_annotations
      - go_summary
      - go_summary_slim
      - qc_stats_summary
      - qc_stats_seq_len_pcbin
      - qc_stats_seq_len_bin
      - qc_stats_seq_len
      - qc_stats_nuc_dist
      - qc_stats_gc_pcbin
      - qc_stats_gc_bin
      - qc_stats_gc
      #- otu_table_summary
#TODO - checkouts and rationalise file names between v3 and v4
      #- tree
      #- biom_json

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
