#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

inputs:
  tsv_otu_table: File

baseCommand: [ awk, '/#/ {next};{print $1}' ]

stdin: $(inputs.tsv_otu_table.path)

stdout: observations  # helps cwltool's cache

outputs:
  observations: stdout

