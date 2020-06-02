#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 100  # just a default, could be lowered

inputs:
  tsv_otu_table:
    type: File
    streamable: true

baseCommand: [ awk, '/#/ {next};{print $1}' ]

stdin: $(inputs.tsv_otu_table.path)

stdout: observations  # helps cwltool's cache

outputs:
  observations: stdout

$namespaces:
 s: http://schema.org/
$schemas:
 - https://schema.org/version/latest/schema.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
