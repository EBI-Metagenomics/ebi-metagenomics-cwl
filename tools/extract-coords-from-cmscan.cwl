#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

inputs:
  infernal_matches:
    label: output from infernal cmscan or cmsearch
    type: File
    streamable: true

baseCommand: awk

stdout: matched_seqs_with_coords  # helps with cwltool's --cache

arguments:
  - '{print $4"-"$3"/"$10"-"$11" "$10" "$11" "$4}'
  - $(inputs.infernal_matches.path)

outputs:
  matched_seqs_with_coords:
    type: stdout

doc: |
  The awk script takes the output of Infernal's cm{scan,search} fmt=2 mode and
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
