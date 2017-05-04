cwlVersion: v1.0
class: Workflow
label: functional analysis prediction with InterProScan

requirements:
 - class: SubworkflowFeatureRequirement
 - class: SchemaDefRequirement
   types: 
    - $import: ../tools/esl-reformat-replace.yaml
    - $import: ../tools/InterProScan-apps.yaml
    - $import: ../tools/InterProScan-protein_formats.yaml

inputs:
  go_summary_config: File
  predicted_CDS: File

outputs:
  functional_annotations:
    type: File
    outputSource: functional_analysis/i5Annotations
  go_summary:
    type: File
    outputSource: summarize_with_GO/go_summary

steps:
  remove_asterisks_and_reformat:
    run: ../tools/esl-reformat.cwl
    in:
      sequences: predicted_CDS
      replace: { default: { find: '*', replace: X } }
    out: [ reformatted_sequences ]

  functional_analysis:
    doc: |
      Matches are generated against predicted CDS, using a sub set of databases
      (Pfam, TIGRFAM, PRINTS, PROSITE patterns, Gene3d) from InterPro. 
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
    doc: |
      A summary of Gene Ontology (GO) terms derived from InterPro matches to
      the sample. It is generated using a reduced list of GO terms called
      GO slim (http://www.geneontology.org/ontology/subsets/goslim_metagenomics.obo)
    run: ../tools/go_summary.cwl
    in:
      InterProScan_results: functional_analysis/i5Annotations
      config: go_summary_config
    out: [ go_summary ]

$namespaces: { edam: "http://edamontology.org/" }
$schemas: [ "http://edamontology.org/EDAM_1.16.owl" ]
