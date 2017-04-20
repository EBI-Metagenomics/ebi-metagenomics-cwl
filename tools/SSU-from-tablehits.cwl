#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow

inputs:
 table_hits: File

outputs:
 SSU_coordinates: { type: File, outputSource: extract_coords/SSUs_with_coords }

steps:
  grep:
    run:
      class: CommandLineTool
      inputs:
        hits: { type: File, streamable: true }
      baseCommand: [ grep, SSU ]
      arguments: [ $(inputs.hits.path) ]
      outputs: { SSUs: { type: stdout } }
    in: { hits: table_hits }
    out: [ SSUs ]

  extract_coords:
    run:
      class: CommandLineTool
      inputs:
        SSUs: { type: File, streamable: true }
      baseCommand: awk
      arguments:
        - '{print $4"-"$3"/"$10"-"$11" "$10" "$11" "$4}'
        - $(inputs.SSUs.path)
      outputs: { SSUs_with_coords: { type: stdout } }
      doc: |
        The awk script takes the output of Infernal's cmscan, fmt=2 mode and
        makes it suitable for use by esl-sfetch, a sequence selector
        
        Reading the user's guide for Infernal, Version 1.1.2; July 2016
        http://eddylab.org/infernal/Userguide.pdf#page=60 we see that
        the relevant fields in the cmscan output are:
        (fmt2 column number: explanation)
        3: The accession of the target sequence or profile, or ’-’ if none
        4: The name of the query sequence or profile 
        10: The start of the alignment of this hit with respect to the
            sequence, numbered 1..L for a sequence of L residues.
        11: The end of the alignment of this hit with respect to the sequence,
            numbered 1..L for a sequence of L residues

        Likewise the format esl-sfetch wants is: <newname> <from> <to> <source seqname>

        Putting it all together we see that the newname (which esl-sfetch with
        output using) is a concatenation of the original name, the sequence
        number, and the coordinates.
    in: { SSUs: grep/SSUs }
    out: [ SSUs_with_coords ]
