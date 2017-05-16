#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

inputs:
  otu_table:
    type: File
    label: the OTU table produced for the taxonomies found in the reference databases that was used with MAPseq
    inputBinding:
      prefix: --otuTable 

  query:
    type: File
    label: the output from the MAPseq that assigns a taxonomy to a sequence
    inputBinding:
      prefix: --otuTable 

  label:
    type: string
    label: label to add to the top of the outfile OTU table
    inputBinding:
      prefix: --label

baseCommand: mapseq2biom.pl

arguments:
  - valueFrom: $(inputs.query.basename).tsv
    prefix: --outFile
  - valueFrom: $(inputs.label).txt
    prefix: --krona

outputs:
  otu_counts:
    type: File
    format: text/tab-separated-values
    outputBinding:
      glob: $(inputs.query.basename).tsv

  krona_otu_counts:
    type: File
    format: text/tab-separated-values
    outputBinding:
      glob: $(inputs.label).txt


