cwlVersion: v1.0
class: Workflow
label: functional analysis prediction with InterProScan

requirements:
 - class: SubworkflowFeatureRequirement
 - class: ScatterFeatureRequirement
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
    outputSource: combine_annotations/result
  go_summary:
    type: File
    outputSource: summarize_with_GO/go_summary
  go_summary_slim:
    type: File
    outputSource: summarize_with_GO/go_summary_slim

steps:
  remove_asterisks_and_reformat:
    run: ../tools/esl-reformat.cwl
    in:
      sequences: predicted_CDS
      replace: { default: { find: '*', replace: X } }
    out: [ reformatted_sequences ]

  chunk_inputs:
    run: ../tools/fasta_chunker.cwl
    in:
      seqs: remove_asterisks_and_reformat/reformatted_sequences
      chunk_size: { default: 10000 }
    out: [ chunks ]

  functional_analysis:
    doc: |
      Matches are generated against predicted CDS, using a sub set of databases
      (Pfam, TIGRFAM, PRINTS, PROSITE patterns, Gene3d) from InterPro. 
    run: ../tools/InterProScan5.30-69.cwl
    in:
      proteinFile: chunk_inputs/chunks
      applications:
        default:
          - Pfam
          - TIGRFAM
          - PRINTS
          - ProSitePatterns
          - Gene3D
    scatter: proteinFile
    out: [i5Annotations]

  combine_annotations:
    run: ../tools/concatenate.cwl
    in:
      files: functional_analysis/i5Annotations
    out: [ result ]

  summarize_with_GO:
    doc: |
      A summary of Gene Ontology (GO) terms derived from InterPro matches to
      the sample. It is generated using a reduced list of GO terms called
      GO slim (http://www.geneontology.org/ontology/subsets/goslim_metagenomics.obo)
    run: ../tools/go_summary.cwl
    in:
      InterProScan_results: combine_annotations/result
      config: go_summary_config
    out: [ go_summary, go_summary_slim ]

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
