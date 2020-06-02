cwlVersion: v1.0
class: CommandLineTool
label: visualize using krona
requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 1024  # just a default, could be lowered
hints:
  SoftwareRequirement:
    packages:
      krona:
        specs: [ "https://identifiers.org/rrid/RRID:SCR_012785" ]
        version: [ "2.3", "2.7" ]

inputs:
  otu_counts:
    type: File
    format: iana:text/tab-separated-values
    label: Tab-delimited text file
    inputBinding:
      position: 2

baseCommand: ktImportText

arguments:
  - valueFrom: $(inputs.otu_counts.nameroot).html
    prefix: -o

outputs:
  otu_visualization:
    type: File
    format: iana:text/html
    outputBinding:
      glob: $(inputs.otu_counts.nameroot).html

$namespaces:
 edam: http://edamontology.org/
 iana: https://www.iana.org/assignments/media-types/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schema.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
