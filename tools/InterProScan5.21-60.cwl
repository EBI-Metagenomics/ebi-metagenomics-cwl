cwlVersion: v1.0
class: CommandLineTool

label: "InterProScan: protein sequence classifier"

doc: |
      Version 5.21-60 can be downloaded here:
      https://github.com/ebi-pf-team/interproscan/wiki/HowToDownload
      
      Documentation on how to run InterProScan 5 can be found here:
      https://github.com/ebi-pf-team/interproscan/wiki/HowToRun

requirements:
 - $import: InterProScan5.21-60-types.yaml

hints:
  SoftwareRequirement:
    packages:
      interproscan:
        specs: [ "https://identifiers.org/rrid/RRID:SCR_005829" ]
        version: [ "5.21-60" ]

inputs:
  proteinFile:
    type: File
    inputBinding:
      prefix: --input
  outputFileType:
    type: InterProScan5.21-60-types.yaml#protein_formats
    inputBinding:
      prefix: --formats
  applications:
    type: InterProScan5.21-60-types.yaml#apps[]?
    inputBinding:
      prefix: --applications

baseCommand: interproscan.sh

arguments: [ --outfile, i5_annotations ]

outputs:
  i5Annotations:
    type: File
    outputBinding:
      glob: i5_annotations
