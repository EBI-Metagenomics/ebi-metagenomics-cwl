cwlVersion: v1.0
class: Workflow
label: EMG pipeline v4.0 (paired end version)

requirements:
 - class: SubworkflowFeatureRequirement
 - class: SchemaDefRequirement
   types: 
    - $import: ../tools/FragGeneScan-model.yaml

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

  #Go summary file for slimming 
  go_summary_config: File

outputs:
  #
  processed_sequences:
    type: File
    outputSource: unified_processing/processed_sequences
  predicted_CDS:
    type: File
    outputSource: unified_processing/predicted_CDS
  functional_annotations:
    type: File
    outputSource: unified_processing/functional_annotations
  otu_table_summary:
    type: File
    outputSource: unified_processing/otu_table_summary


  #Keep all of the protein stuff here
  pCDS:
    type: File
    outputSource: fraggenescan/predictedCDS

  annotations:
    type: File
    outputSource: interproscan/i5Annotations
  

  #Taxonomic outputs
  otu_visualization:
    type: File
    outputSource: visualize_otu_counts/otu_visualization 

  otu_counts_hdf5:
    type: File
    outputSource: convert_otu_counts_to_hdf5/result 
  
  otu_counts_json:
    type: File
    outputSource: convert_otu_counts_to_json/result 


  #Other non-coding RNA hits
  other_ncRNAs:
    type: File
    outputSource: find_other_ncRNAs/matches

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
    run: emg-pipeline-v3.cwl
    in:
      reads: combine_overlaped_and_unmerged_reads/merged_with_unmerged_reads
      fraggenescan_model: fraggenescan_model
 #Inputs are different.
     16S_model: 16S_model
      5S_model: 5S_model
      23S_model: 23S_model
      tRNA_model: tRNA_model
      go_summary_config: go_summary_config
    out:
      - processed_sequences
      - predicted_CDS
      - functional_annotations
      - otu_table_summary
#TODO - checkouts and rationalise file names between v3 and v4
      - tree
      - biom_json

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
