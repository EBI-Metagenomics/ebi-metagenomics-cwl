cwlVersion: v1.0
class: CommandLineTool

label: "InterProScan: protein sequence classifier"

doc: |
      Version 5.21-60 can be downloaded here:
      https://github.com/ebi-pf-team/interproscan/wiki/HowToDownload
      
      Documentation on how to run InterProScan 5 can be found here:
      https://github.com/ebi-pf-team/interproscan/wiki/HowToRun

requirements:
 - class: SchemaDefRequirement
   types: 
     - $import: InterProScan-apps.yaml
     - $import: InterProScan-protein_formats.yaml

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
  # outputFileType:
  #   type: InterProScan-protein_formats.yaml#protein_formats
  #   inputBinding:
  #     prefix: --formats
  applications:
    type: InterProScan-apps.yaml#apps[]?
    inputBinding:
      itemSeparator: ','
      prefix: --applications

baseCommand: interproscan.sh

arguments:
 - valueFrom: i5_annotations
   prefix: --outfile
 - valueFrom: TSV
   prefix: --formats
 - --disable-precalc
 - --goterms
 - --pathways
 - valueFrom: $(runtime.tmpdir)
   prefix: --tempdir


outputs:
  i5Annotations:
    type: File
    outputBinding:
      glob: i5_annotations
