#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow

inputs:
  indexed_sequences:
    type: File
    secondaryFiles: .ssi
    format: edam:format_1929  # FASTA
  model:
    type: File
    format: edam:format_1370  # HMMER
    label: rRNA protein model to search with

outputs:
   matching_sequences:
     type: File
     format: edam:format_1929  # FASTA
     outputSource: sort_matches/rev_sorted_sequences
   hmmer_search_results:
     type: File
     outputSource: hmmsearch/per_domain_summary
     
steps:
  hmmsearch:
    run: hmmsearch.cwl
    in:
      hmm_profiles: model
      sequence_query: indexed_sequences
      e_threshold: { default: "1.0E-5" }
    out: [ per_domain_summary ]

  extract_coord_lines:
    run: extract_coord_lines.cwl
    in: { summary: hmmsearch/per_domain_summary }
    out: [ coord_lines ]

  extract_coordinates:
    run:
      id: extract_coordinates  # TODO, remove when toil upgrade to a newer cwltool
      class: CommandLineTool
      inputs:
        coordinate_lines:
          type: File  
          inputBinding: { position: 1 }
          streamable: true
          doc: |
            The required columns are as follows:
            (1) target name: The name of the target sequence or profile.
            (18) from (ali coord): The start of the MEA alignment of this
                 domain with respect to the sequence, numbered 1..L for a
                 sequence of L residues.
            (19) to (ali coord): The end of the MEA alignment of this domain
                 with respect to the sequence, numbered 1..L for a sequence of
                 L residues.
      baseCommand: [ awk, '{print $1"/"$18"-"$19" "$18" "$19" "$1}' ]
      stdout: $(inputs.coordinate_lines.nameroot).names_and_coords
      outputs: { formatted_names_and_coords: { type: stdout } }
    in: { coordinate_lines: extract_coord_lines/coord_lines }
    out: [ formatted_names_and_coords ]

  fetch_aligned_sequences:
    run: esl-sfetch-manyseqs.cwl
    in:
      indexed_sequences: indexed_sequences
      names: extract_coordinates/formatted_names_and_coords
      names_contain_subseq_coords: { default: true }
    out: [ sequences ]

  reformat_matches:
    run: oneLineFasta.cwl
    in: 
      sequences: fetch_aligned_sequences/sequences
      minimum_length: { default: 80 }
    out: [ reformatted_sequences ]

  sort_matches:
    run: RevReadSort.cwl
    in:
      sequences: reformat_matches/reformatted_sequences
    out: [ rev_sorted_sequences ]

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schema.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
