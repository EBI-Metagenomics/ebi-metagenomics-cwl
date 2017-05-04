cwlVersion: v1.0
class: Workflow
label: Functional analyis of sequences that match the 16S SSU

requirements:
 - class: SchemaDefRequirement
   types: 
    - $import: ../tools/qiime-biom-convert-table.yaml

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
  biom_json:
    type: File
    outputSource: convert_new_biom_to_old_biom/result

steps:
  pick_closed_reference_otus:
    run: ../tools/qiime-pick_closed_reference_otus.cwl
    in:
      sequences: 16S_matches
    out: [ otu_table, otus_tree ]

  convert_new_biom_to_old_biom:
    run: ../tools/qiime-biom-convert.cwl
    in:
      biom: pick_closed_reference_otus/otu_table
      table_type: { default: OTU Table }
      json: { default: true }
    out: [ result ]

  convert_new_biom_to_classic:
    run: ../tools/qiime-biom-convert.cwl
    in:
      biom: pick_closed_reference_otus/otu_table
      header_key: { default: taxonomy }
      table_type: { default: OTU Table }
      tsv: { default: true }
    out: [ result ]

  create_otu_text_summary:
    run: ../tools/qiime-biom-summarize_table.cwl
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
