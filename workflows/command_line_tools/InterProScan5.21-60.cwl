cwlVersion: v1.0
class: CommandLineTool
label: InterProScan 5.21-60 job.
doc: |
      InterProScan is an application for classifying protein sequences.

      Version 5.21-60 can be downloaded here:
      https://github.com/ebi-pf-team/interproscan/wiki/HowToDownload
      
      Documentation on how to run InterProScan 5 can be found here:
      https://github.com/ebi-pf-team/interproscan/wiki/HowToRun
baseCommand: interproscan.sh
requirements:
  InitialWorkDirRequirement:
    listing: [ $(inputs.workDir) ]
arguments: [ -o, i5_annotations ]
inputs:
  workDir: Directory
  proteinFile:
    type: File
    inputBinding:
      prefix: -i
  outputFileType:
    type: string
    inputBinding:
      prefix: -f
  applications:
    type: string
    inputBinding:
      prefix: -appl
outputs:
  i5Annotations:
    type: File
    outputBinding:
      glob: i5_annotations
