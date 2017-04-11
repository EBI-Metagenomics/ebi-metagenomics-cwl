cwlVersion: v1.0
class: Workflow
label: EMG pipeline description in CWL
doc: |
     Current steps include FragGeneScan (Fgs) and InterProScan (Ips).
      
inputs:
  FgsInputFile:
    type: File
    label: FragGeneScan input file
  FgsLength: int
  FgsTrainingSet: string
  FgsThreads:
    type: int
    label: FragGeneScan number of threads
  FgsTrainingDir: Directory
  IpsWorkdir:
    type: Directory
    label: InterProScan installation directory
  IpsApps: string
  IpsType: string

outputs: []

steps:
  fraggenescan:
    run: command_line_tools/FragGeneScan1_20.cwl
    in:
      trainDir: FgsTrainingDir
      sequenceFileName: FgsInputFile
      sequenceLength: FgsLength
      trainingFileName: FgsTrainingSet 
      threadNumber: FgsThreads
    out: [predictedCDS]

  interproscan:
    run: command_line_tools/InterProScan5.21-60.cwl
    in:
      proteinFile: fraggenescan/predictedCDS
      workDir: IpsWorkdir
      applications: IpsApps
      outputFileType: IpsType
    out: [i5Annotations]
