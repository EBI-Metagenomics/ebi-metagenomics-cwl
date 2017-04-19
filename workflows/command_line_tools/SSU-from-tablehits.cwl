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
    in: { SSUs: grep/SSUs }
    out: [ SSUs_with_coords ]
