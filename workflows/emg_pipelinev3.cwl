cwlVersion: v1.0
class: Workflow
label: EMG pipeline description in CWL
doc: |
     Current steps include FragGeneScan (Fgs) and InterProScan (Ips).
      
inputs:
  FgsInputFile: File	# FragGeneScan input file
  FgsLength: int
  FgsTrainingSet: string
  FgsThreads: int	# FragGeneScan number of threads
  FgsTrainingDir: Directory
  IpsWorkdir: Directory	# InterProScan installation directory
  IpsApps: string
  IpsType: string

outputs: []

steps:
  fraggenescan:
    run: FragGeneScan1_20.cwl
    in:
      trainDir: FgsTrainingDir
      sequenceFileName: FgsInputFile
      sequenceLength: FgsLength
      trainingFileName: FgsTrainingSet 
      threadNumber: FgsThreads
    out: [predictedCDS]

  interproscan:
    run: InterProScan5.21-60.cwl
    in:
      proteinFile: fraggenescan/predictedCDS
      workDir: IpsWorkdir
      applications: IpsApps
      outputFileType: IpsType
    out: [i5Annotations]
