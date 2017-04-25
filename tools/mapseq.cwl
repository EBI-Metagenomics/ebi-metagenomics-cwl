cwlVersion: v1.0
class: CommandLineTool
label: MAPseq
doc: |
  sequence read classification tools designed to assign taxonomy and OTU
  classifications to ribosomal RNA sequences.
  http://meringlab.org/software/mapseq/

hints:
  SoftwareRequirement:
    packages:
      mapseq:
        version: [ "1.0" ]
        # specs: [ https://identifiers.org/rrid/RRID:TBD ]

inputs:
  sequences:
    type: File
    inputBinding:
      position: 1
    format: edam:format_1929  # FASTA

  database:
    type: File?
    inputBinding:
      position: 2
    format: edam:format_1929  # FASTA

  taxonomies:
    type: File[]?
    inputBinding:
      position: 3

  threads:
    type: int?
    default: 4
    inputBinding:
      prefix: -nthreads

baseCommand: mapseq

outputs:
  classifications:
    type: stdout
    format: text/tab-separated-values

$namespaces: { edam: "http://edamontology.org/" }
$schemas: [ "http://edamontology.org/EDAM_1.16.owl" ]
