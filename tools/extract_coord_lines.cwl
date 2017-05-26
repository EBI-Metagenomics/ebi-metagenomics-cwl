#!/usr/bin/env cwl-runner
cwlVersion: v1.0

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 100  # just a default, could be lowered

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

$namespaces:
 s: http://schema.org/
$schemas:
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
