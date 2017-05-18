cwlVersion: v1.0
class: Workflow
label: EMG core analysis for Illumina

requirements:
 - class: StepInputExpressionRequirement
 - class: SubworkflowFeatureRequirement
 - class: SchemaDefRequirement
   types: 
     - $import: ../tools/FragGeneScan-model.yaml
     - $import: ../tools/InterProScan-apps.yaml
     - $import: ../tools/InterProScan-protein_formats.yaml
     - $import: ../tools/esl-reformat-replace.yaml
     - $import: ../tools/biom-convert-table.yaml

inputs:
  sequencing_run_id: string
  reads:
    type: File
    format: edam:format_1929  # FASTA
  ncRNA_ribosomal_models: File[]
  ncRNA_ribosomal_model_clans: File
  ncRNA_other_models: File[]
  ncRNA_other_model_clans: File
  fraggenescan_model: ../tools/FragGeneScan-model.yaml#model
  mapseq_ref:
    type: File
    format: edam:format_1929  # FASTA
    secondaryFiles: .mscluster
  mapseq_taxonomy: File
  go_summary_config: File

outputs:  

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


 
  #Taxonomic analysis step
  SSUs:
    type: File
    outputSource: extract_SSUs/sequences

  classifications:
    type: File
    outputSource: classify_SSUs/classifications



  #The predicted proteins and their annotations
  pCDS:
    type: File
    outputSource: fraggenescan/predictedCDS

  go_summary:
    type: File
    outputSource: functional_analysis/go_summary

  annotations:
    type: File
    outputSource: interproscan/i5Annotations



  #Taxonomic visualisation step
  otu_visualization:
    type: File
    outputSource: visualize_otu_counts/otu_visualization 

  otu_counts_hdf5:
    type: File
    outputSource: convert_otu_counts_to_hdf5/result 
  
  otu_counts_json:
    type: File
    outputSource: convert_otu_counts_to_json/result 



  #Non-coding RNA analysis
  other_ncRNAs:
    type: File
    outputSource: find_other_ncRNAs/matches


#TODO - check all the outputs
#Sequence cat
#Summary files
#LSU based taxonomy


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


  #sequence QC stats
  sequence_stats:
    run: ../tools/qc-stats.cwl
    in: 
      QCedreads: 
    out: 
      - summary_out
      - seq_length_pcbin
      - seq_length_bin
      - seq_length_out 
      - nucleotide_distribution_out
      - gc_sum_pcbin
      - gc_sum_bin
      - gc_sum_out



  #Ribosomal ncRNA identification
  find_ribosomal_ncRNAs:
    run:  cmsearch-multimodel.cwl 
    in: 
      query_sequences: QCed_reads
      covariance_models: ncRNA_ribosomal_models
      clan_info: ncRNA_ribosomal_model_clans
    out: [ matches ]


  
  #SSU classification
  get_SSU_coords:
    run: ../tools/SSU-from-tablehits.cwl
    in:
      table_hits: find_ribosomal_ncRNAs/matches
    out: [ SSU_coordinates ]

  index_reads:
    run: ../tools/esl-sfetch-index.cwl
    in:
      sequences: QCed_reads
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
      database: mapseq_ref
      taxonomy: mapseq_taxonomy
    out: [ classifications ]



  #TODO - LSU classification

  #TODO - Longer term ITS1 identification


  #Visualisation of taxonomic classification
  convert_classifications_to_otu_counts:
    run: ../tools/mapseq2biom.cwl
    in:
       otu_table: mapseq_taxonomy
       label: sequencing_run_id
       query: classify_SSUs/classifications
    out: [ otu_counts, krona_otu_counts ]

  visualize_otu_counts:
    run: ../tools/krona.cwl
    in:
      otu_counts: convert_classifications_to_otu_counts/krona_otu_counts
    out: [ otu_visualization ]

  convert_otu_counts_to_hdf5:
    run: ../tools/biom-convert.cwl
    in:
       biom: convert_classifications_to_otu_counts/otu_counts
       hdf5: { default: true }
       table_type: { default: OTU table }
    out: [ result ]

  convert_otu_counts_to_json:
    run: ../tools/biom-convert.cwl
    in:
       biom: convert_classifications_to_otu_counts/otu_counts
       json: { default: true }
       table_type: { default: OTU table }
    out: [ result ]



  #Find other ubquitious ncRNAs
  find_other_ncRNAs:
    run:  cmsearch-multimodel.cwl 
    in: 
      query_sequences: QCed_reads
      covariance_models: ncRNA_other_models
      clan_info: ncRNA_other_model_clans
    out: [ matches ]


  #Protein identification
  fraggenescan:
    run: ../tools/FragGeneScan1_20.cwl
    in:
      sequence: QC_reads
      completeSeq: { default: false }
      model: fraggenescan_model
    out: [ predictedCDS ]

  remove_asterisks_and_reformat:
    run: ../tools/esl-reformat.cwl
    in:
      sequences: fraggenescan/predictedCDS
      replace: { default: { find: '*', replace: X } }
    out: [ reformatted_sequences ]


  #TODO - check that <60aa length are being removed.


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
      # outputFileType:
      #   valueFrom: TSV
    out: [i5Annotations]

    
  #TODO - Sequence catagorisation & summary steps.
    
$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"