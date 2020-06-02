cwlVersion: v1.0
class: CommandLineTool

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 100  # just a default, could be lowered

hints:
  SoftwareRequirement:
    packages:
      python:
        version: [ "2.7" ]

inputs:
  i5_annotations:
    type: File
    format: iana:text/tab-separated-values
    inputBinding:
      position: 1

baseCommand: [ extract_sig_coords.py ]

arguments:
  - valueFrom: $(inputs.i5_annotations.basename).matches_coords
    position: 2

outputs:
  matches_coords:
    type: File
    outputBinding: { glob: $(inputs.i5_annotations.basename).matches_coords }

$namespaces:
 iana: https://www.iana.org/assignments/media-types/
 s: http://schema.org/
$schemas:
 - https://schema.org/version/latest/schema.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder:   "EMBL - European Bioinformatics Institute"
