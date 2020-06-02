#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 1024  # just a default, could be lowered
hints:
  SoftwareRequirement:
    packages: { python: {} }

inputs:
  qiime_taxonomy:
    type: File
    streamable: true
    inputBinding:
      position: 1

baseCommand: krona_setup.py

arguments:
  - valueFrom: $(inputs.qiime_taxonomy.nameroot).krona-input.txt
    position: 2
  - valueFrom: $(inputs.qiime_taxonomy.nameroot).kingdom-counts.txt
    position: 3

outputs:
  krona_input:
    type: File
    streamable: true
    format: iana:text/tab-separated-values
    outputBinding: { glob: $(inputs.qiime_taxonomy.nameroot).krona-input.txt }
  kingdom_counts:
    type: File
    streamable: true
    outputBinding: { glob: $(inputs.qiime_taxonomy.nameroot).kingdom-counts.txt }

$namespaces:
 s: http://schema.org/
 iana: https://www.iana.org/assignments/media-types/
$schemas:
 - https://schema.org/version/latest/schema.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
