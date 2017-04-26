#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool

inputs:
  summary:
    type: File
    inputBinding: { position: 1 }
    streamable: true

baseCommand: [ grep, -v, "^#" ]

outputs:
  coord_lines: stdout
