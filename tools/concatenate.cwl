#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

requirements:
  InlineJavascriptRequirement: {}  # to propagate the file format
  ResourceRequirement:
    coresMax: 1
    ramMin: 100  # just a default, could be lowered

inputs:
  files:
    type: File[]
    streamable: true
    inputBinding:
      position: 1

baseCommand: cat

stdout: result  # to aid cwltool's cache feature

outputs:
  result:
    type: File
    outputBinding:
      glob: result
      outputEval: |
        ${ self[0].format = inputs.files[0].format;
           return self; }

$namespaces:
 s: http://schema.org/
$schemas:
 - https://schema.org/version/latest/schema.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
