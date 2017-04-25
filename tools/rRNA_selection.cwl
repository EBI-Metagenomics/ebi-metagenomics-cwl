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
     outputSource: fetch_aligned_sequences/sequences

steps:
  hmmsearch:
    run: hmmsearch.cwl
    in:
      hmm_profiles: model
      sequence_query: indexed_sequences
    out: [ per_domain_summary ]

  extract_coord_lines:
    run:
      class: CommandLineTool
      inputs:
        summary:
          type: File
          inputBinding: { position: 1 }
      baseCommand: [ grep, -v, "^#" ]
      outputs:
        coord_lines: { type: stdout }
    in: { summary: hmmsearch/per_domain_summary }
    out: [ coord_lines ]

  extract_coordinates:
    run:
      class: CommandLineTool
      inputs:
        coordinate_lines:
          type: File  
          inputBinding: { position: 1 }
          doc: |
            The required columns are as follows:
            (1) target name: The name of the target sequence or profile.
            (18) from (ali coord): The start of the MEA alignment of this
                 domain with respect to the sequence, numbered 1..L for a
                 sequence of L residues.
            (19) to (ali coord): The end of the MEA alignment of this domain
                 with respect to the sequence, numbered 1..L for a sequence of
                 L residues.
      baseCommand: [ awk, '{print $1, $18, $19, $1}' ]
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

