#!/usr/bin/env
cwlVersion: v1.0
class: CommandLineTool

inputs:
  hits: { type: File, streamable: true }

baseCommand: [ grep, RF00002 ]

stdout: 5Ss  # helps with cwltool's --cache

arguments: [ $(inputs.hits.path) ]

outputs: { 5Ss: { type: stdout } }

$namespaces:
 s: http://schema.org/
$schemas:
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
