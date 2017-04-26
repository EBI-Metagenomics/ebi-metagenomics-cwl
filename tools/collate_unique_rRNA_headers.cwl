#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow

requirements:
  ScatterFeatureRequirement: {}

inputs:
  hits: File[]

outputs:
   unique_hits:
     type: File
     outputSource: sort_uniq_names/sorted_uniq_names
 
steps:
  extract_coord_lines:
    run: extract_coord_lines.cwl
    in: { summary: hits }
    scatter: summary
    out: [ coord_lines ]

  extract_names:
    run:
      class: CommandLineTool
      inputs:
        coordinate_lines:
          type: File  
          inputBinding: { position: 1 }
          doc: |
            The required columns are as follows:
            (1) target name: The name of the target sequence or profile.
      baseCommand: [ awk, '{print $1}' ]
      outputs: { names: { type: stdout } }
    in: { coordinate_lines: extract_coord_lines/coord_lines }
    scatter: coordinate_lines
    out: [ names ]

  sort_uniq_names:
    run:
      class: CommandLineTool
      inputs:
        names:
          type: File[]
          inputBinding: { position: 1 }
      baseCommand: [ sort, --unique ]
      outputs: { sorted_uniq_names: stdout }
    in: { names: extract_names/names }
    out: [ sorted_uniq_names ]
