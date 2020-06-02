cwlVersion: v1.0
class: CommandLineTool
label: index a sequence file for use by esl-sfetch
doc: "https://github.com/EddyRivasLab/easel"

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 1024  # just a default, could be lowered
  InitialWorkDirRequirement:
    listing: [ $(inputs.sequences) ]
hints:
  SoftwareRequirement:
    packages:
      easel: {}
        # specs: [ https://identifiers.org/rrid/RRID:TBD ]
        # version: [ "???" ]

inputs:
  sequences:
    type: File
    inputBinding:
      position: 1
      valueFrom: $(self.basename)
    format: edam:format_1929  # FASTA

baseCommand: [ esl-sfetch, --index ]

outputs:
  sequences_with_index:
    type: File
    secondaryFiles: .ssi
    format: edam:format_1929  # FASTA
    outputBinding:
      glob: $(inputs.sequences.basename)

$namespaces:
  edam: http://edamontology.org/
  s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schema.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
