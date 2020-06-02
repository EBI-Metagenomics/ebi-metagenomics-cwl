#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 1024  # just a default, could be lowered

inputs:
  otu_table:
    type: File
    doc: |
      the OTU table produced for the taxonomies found in the reference
      databases that was used with MAPseq
    inputBinding:
      prefix: --otuTable 

  query:
    type: File
    label: the output from the MAPseq that assigns a taxonomy to a sequence
    inputBinding:
      prefix: --query

  label:
    type: string
    label: label to add to the top of the outfile OTU table
    inputBinding:
      prefix: --label

baseCommand: mapseq2biom.pl

arguments:
  - valueFrom: $(inputs.query.basename).tsv
    prefix: --outfile
  - valueFrom: $(inputs.label).txt
    prefix: --krona

outputs:
  otu_counts:
    type: File
    format: edam:format_3746  # BIOM
    outputBinding:
      glob: $(inputs.query.basename).tsv

  krona_otu_counts:
    type: File
    format: iana:text/tab-separated-values
    outputBinding:
      glob: $(inputs.label).txt

$namespaces:
 edam: http://edamontology.org/
 iana: https://www.iana.org/assignments/media-types/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schema.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
