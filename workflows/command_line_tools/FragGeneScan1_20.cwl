cwlVersion: v1.0
class: CommandLineTool
label: A wrapper around FragGeneScan v1.20, an application for finding (fragmented) genes in short reads.
doc: |
      FragGeneScan is an application for finding (fragmented) genes in short reads. It can also be applied to
      predict prokaryotic genes in incomplete assemblies or complete genomes.

      FragGeneScan was first released through omics website (http://omics.informatics.indiana.edu/FragGeneScan/)
      in March 2010, where you can find its old releases. FragGeneScan migrated to SourceForge in October, 2013
      (https://sourceforge.net/projects/fraggenescan/).

      Version 1.20 can be downloaded here:
      https://sourceforge.net/projects/fraggenescan/files/
baseCommand: FragGeneScan
requirements:
  InitialWorkDirRequirement:
    listing: [ $(inputs.trainDir) ]
#  EnvVarRequirement:
#    envDef:
#      PATH: $(inputs.pathToBinary)
arguments: [ -o, predicted_cds ]
inputs:
  trainDir: Directory
  sequenceFileName:
    type: File
    inputBinding:
      prefix: -s
  sequenceLength:
    type: int
    inputBinding:
      prefix: -w
  trainingFileName:
    type: string
    inputBinding:
      prefix: -t
  threadNumber:
    type: int?
    inputBinding:
      prefix: -p
outputs:
  predictedCDS:
    type: File
    outputBinding:
      glob: predicted_cds.faa
