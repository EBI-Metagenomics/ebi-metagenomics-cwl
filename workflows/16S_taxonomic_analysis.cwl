cwlVersion: v1.0
class: Workflow
label: Functional analyis of sequences that match the 16S SSU

requirements:
 - class: SchemaDefRequirement
   types: 
    - $import: ../tools/biom-convert-table.yaml

inputs:
  16S_matches:
    type: File

outputs:
  otu_table_summary:
    type: File
    outputSource: create_otu_text_summary/otu_table_summary
  tree:
    type: File
    outputSource: prune_tree/pruned_tree 
  biom_tsv:
    type: File
    outputSource: convert_new_biom_to_classic/result
  biom_json:
    type: File
    outputSource: convert_new_biom_to_old_biom/result
  biom_hdf5:
    type: File
    outputSource: convert_otu_counts_to_hdf5/result
  qiime_sequences-filtered_clusters:
    type: File
    outputSource: pick_closed_reference_otus/sequences-filtered_clusters
  qiime_sequences-filtered_otus:
    type: File
    outputSource: pick_closed_reference_otus/sequences-filtered_otus
  qiime_assigned_taxonomy:
    type: File
    outputSource: modify_taxonomy_table/qiime_assigned_taxonomy

steps:
  pick_closed_reference_otus:
    run: ../tools/qiime-pick_closed_reference_otus.cwl
    in:
      sequences: 16S_matches
    out:
      - otu_table
      - otus_tree
      - sequences-filtered_clusters
      - sequences-filtered_otus
      - sequences-filtered_otus_log

  modify_taxonomy_table:
    run: ../tools/modify_taxonomy_table.cwl
    in:
      uclust_log: pick_closed_reference_otus/sequences-filtered_otus_log
      otu_table: convert_new_biom_to_classic/result
    out: [ qiime_assigned_taxonomy ]

  convert_new_biom_to_old_biom:
    run: ../tools/biom-convert.cwl
    in:
      biom: pick_closed_reference_otus/otu_table
      table_type: { default: OTU table }
      json: { default: true }
    out: [ result ]

  convert_new_biom_to_classic:
    run: ../tools/biom-convert.cwl
    in:
      biom: pick_closed_reference_otus/otu_table
      header_key: { default: taxonomy }
      table_type: { default: OTU table }
      tsv: { default: true }
    out: [ result ]

  convert_otu_counts_to_hdf5:
    run: ../tools/biom-convert.cwl
    in:
      biom: pick_closed_reference_otus/otu_table
      hdf5: { default: true }
      table_type: { default: OTU table }
    out: [ result ]

  create_otu_text_summary:
    run: ../tools/biom-summarize_table.cwl
    in:
      biom: pick_closed_reference_otus/otu_table
    out: [ otu_table_summary ]

  extract_observations:
    run: ../tools/extract_observations.cwl
    in:
      tsv_otu_table: convert_new_biom_to_classic/result
    out: [ observations ]

  prune_tree:
    run: ../tools/qiime-filter_tree.cwl
    in:
      tree: pick_closed_reference_otus/otus_tree
      tips_or_seqids_to_retain: extract_observations/observations
    out: [ pruned_tree ]

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
