#!/usr/bin/env
cwlVersion: v1.0
class: CommandLineTool

inputs:
  hits: { type: File, streamable: true }

baseCommand: [ grep, SSU ]

arguments: [ $(inputs.hits.path) ]

outputs: { SSUs: { type: stdout } }

