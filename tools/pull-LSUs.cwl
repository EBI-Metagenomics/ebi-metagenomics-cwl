#!/usr/bin/env
cwlVersion: v1.0
class: CommandLineTool
requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 100  # just a default, could be lowered

inputs:
  hits: { type: File, streamable: true }

stdin: $(inputs.hits.path)

baseCommand: [ grep, "-e RF02543 -e RF02541 -e RF02541 -e RF00002" ]

stdout: LSUs  # helps with cwltool's --cache

outputs: { LSUs: { type: stdout } }

$namespaces:
 s: http://schema.org/
$schemas:
 - https://schema.org/version/latest/schema.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
