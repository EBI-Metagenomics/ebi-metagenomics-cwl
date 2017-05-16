#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

inputs:
  files:
    type: File[]
    inputBinding:
      position: 1

baseCommand: cat

stdout: result  # to aid cwltool's cache feature

outputs:
  result: stdout
