#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

inputs:
  summary:
    type: File
    inputBinding: { position: 1 }
    streamable: true

baseCommand: [ grep, -v, "^#" ]

successCodes: [ 0, 1 ]  # allow empty matches

stdout: coord_lines  # helps with cwltool's --cache

outputs:
  coord_lines: stdout
