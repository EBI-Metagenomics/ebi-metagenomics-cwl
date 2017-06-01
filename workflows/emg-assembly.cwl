cwlVersion: v1.0
class: Workflow
label: EMG assembly for paired end Illumina

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
  forward_reads:
    type: File?
    format: edam:format_1930  # FASTQ
  reverse_reads:
    type: File?
    format: edam:format_1930  # FASTQ
  unpaired_reads:
    type: File?
    format: edam:format_1930  # FASTQ
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
  mapseq_taxonomy_otu_table: File
  go_summary_config: File

outputs:
  SSUs:
    type: File
    outputSource: extract_SSUs/sequences

  classifications:
    type: File
    outputSource: classify_SSUs/classifications

  scaffolds:
    type: File
    outputSource: discard_short_scaffolds/filtered_sequences

  pCDS:
    type: File
    outputSource: ORF_prediction/predicted_CDS_aa

  annotations:
    type: File
    outputSource: functional_analysis/functional_annotations
  #TODO - pull back the GO and GO/slim files.
    
  otu_visualization:
    type: File
    outputSource: visualize_otu_counts/otu_visualization 

  otu_counts_hdf5:
    type: File
    outputSource: convert_otu_counts_to_hdf5/result 
  
  otu_counts_json:
    type: File
    outputSource: convert_otu_counts_to_json/result 

  other_ncRNAs:
    type: File
    outputSource: find_other_ncRNAs/matches

#TODO
# Add step to expand counts according to coverage
# Add quality control steps
# Write code to extract other ncRNAs


steps:
  assembly:
    run: ../tools/metaspades.cwl
    in:
      forward_reads: forward_reads
      reverse_reads: reverse_reads
      unpaired_reads: unpaired_reads
    out: [ scaffolds ]

  discard_short_scaffolds:
    run: ../tools/discard_short_seqs.cwl
    in:
      sequences: assembly/scaffolds
      minimum_length: { default: 100 }
    out: [ filtered_sequences ]

  find_ribosomal_ncRNAs:
    run:  cmsearch-multimodel.cwl 
    in: 
      query_sequences: discard_short_scaffolds/filtered_sequences
      covariance_models: ncRNA_ribosomal_models
      clan_info: ncRNA_ribosomal_model_clans
    out: [ matches ]
  
  get_SSU_coords:
    run: ../tools/SSU-from-tablehits.cwl
    in:
      table_hits: find_ribosomal_ncRNAs/matches
    out: [ SSU_coordinates ]

  index_scaffolds:
    run: ../tools/esl-sfetch-index.cwl
    in:
      sequences: discard_short_scaffolds/filtered_sequences
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

  convert_classifications_to_otu_counts:
    run: ../tools/mapseq2biom.cwl
    in:
       otu_table: mapseq_taxonomy_otu_table
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


  find_other_ncRNAs:
    run:  cmsearch-multimodel.cwl 
    in: 
      query_sequences: discard_short_scaffolds/filtered_sequences
      covariance_models: ncRNA_other_models
      clan_info: ncRNA_other_model_clans
    out: [ matches ]

  ORF_prediction:
    run: orf_prediction.cwl
    in:
      sequence: discard_short_scaffolds/filtered_sequences
      completeSeq: { default: true }
      model: fraggenescan_model
    out: [predicted_CDS_aa]

  functional_analysis:
    doc: |
      Matches are generated against predicted CDS, using a sub set of databases
      (Pfam, TIGRFAM, PRINTS, PROSITE patterns, Gene3d) from InterPro.
    run: functional_analysis.cwl
    in:
      predicted_CDS: ORF_prediction/predicted_CDS_aa
      go_summary_config: go_summary_config
    out: [ functional_annotations, go_summary, go_summary_slim ]

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
