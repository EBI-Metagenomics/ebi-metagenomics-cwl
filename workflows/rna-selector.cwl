cwlVersion: v1.0
class: Workflow
label: RNASelector as a CWL workflow
doc: "https://doi.org/10.1007/s12275-011-1213-z"

requirements:
 - class: StepInputExpressionRequirement
 - class: SubworkflowFeatureRequirement
 - class: InlineJavascriptRequirement
 - class: MultipleInputFeatureRequirement
 - class: SchemaDefRequirement
   types: 
    - $import: ../tools/trimmomatic-sliding_window.yaml
    - $import: ../tools/trimmomatic-end_mode.yaml
    - $import: ../tools/trimmomatic-phred.yaml

inputs:
  reads:
    type: File
    format: edam:format_1929  # FASTA
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

outputs:
  16S_matches:
    type: File
    outputSource: discard_short_16S_matches/filtered_sequences
  masked_sequences:
    type: File
    outputSource: mask_rRNA_and_tRNA/masked_sequences

steps:
  index_reads:
    run: ../tools/esl-sfetch-index.cwl
    in:
      sequences: reads
    out: [ sequences_with_index ]

  find_16S_matches:
    run: ../tools/rRNA_selection.cwl
    in:
      indexed_sequences: index_reads/sequences_with_index
      model: 16S_model
    out: [ matching_sequences, hmmer_search_results ]

  discard_short_16S_matches:
    run: ../tools/discard_short_seqs.cwl
    in:
      sequences: find_16S_matches/matching_sequences
      minimum_length: { default: 80 }
    out: [ filtered_sequences ]

  find_23S_matches:
    run: ../tools/rRNA_selection.cwl
    in:
      indexed_sequences: index_reads/sequences_with_index
      model: 23S_model
    out: [ matching_sequences, hmmer_search_results ]

  find_5S_matches:
    run: ../tools/rRNA_selection.cwl
    in:
      indexed_sequences: index_reads/sequences_with_index
      model: 5S_model
    out: [ matching_sequences, hmmer_search_results ]

  find_tRNA_matches:
    run: ../tools/tRNA_selection.cwl
    in:
      indexed_sequences: index_reads/sequences_with_index
      model: tRNA_model
    out: [ matching_sequences, hmmer_search_results ]

  collate_unique_rRNA_hmmer_hits:
    run: ../tools/collate_unique_SSU_headers.cwl
    in:
      hits:
        - find_16S_matches/hmmer_search_results
        - find_23S_matches/hmmer_search_results
        - find_5S_matches/hmmer_search_results
    out: [ unique_hits ]

  collate_unique_tRNA_hmmer_hits:
    run: ../tools/collate_unique_SSU_headers.cwl
    in:
      hits:
        source: find_tRNA_matches/hmmer_search_results
        valueFrom: ${ return [ self ]; }
    out: [ unique_hits ]

  mask_rRNA_and_tRNA:
    run: ../tools/mask_RNA.cwl
    in:
      unique_rRNA_hits: collate_unique_rRNA_hmmer_hits/unique_hits
      16s_rRNA_hmmer_matches: find_16S_matches/hmmer_search_results
      23s_rRNA_hmmer_matches: find_23S_matches/hmmer_search_results
      5s_rRNA_hmmer_matches: find_5S_matches/hmmer_search_results
      unique_tRNA_hits: collate_unique_tRNA_hmmer_hits/unique_hits
      tRNA_matches: find_tRNA_matches/hmmer_search_results
      sequences: index_reads/sequences_with_index
    out: [ masked_sequences ]

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
