cwlVersion: v1.0
class: CommandLineTool
label: "FragGeneScan: find (fragmented) genes in short reads"
doc: |
      FragGeneScan is an application for finding (fragmented) genes in short
      reads. It can also be applied to predict prokaryotic genes in incomplete
      assemblies or complete genomes.

      FragGeneScan was first released through omics website (http://omics.informatics.indiana.edu/FragGeneScan/)
      in March 2010, where you can find its old releases. FragGeneScan migrated to SourceForge in October, 2013
      (https://sourceforge.net/projects/fraggenescan/).

      Version 1.20 can be downloaded here:
      https://sourceforge.net/projects/fraggenescan/files/

baseCommand: [] # FragGeneScan

requirements:
  - $import: FragGeneScan1_20-types.yaml
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
#  - class: InitialWorkDirRequirement
#    listing: [ $(inputs.trainDir) ]

hints:
  SoftwareRequirement:
    packages:
      fraggenescan:
        specs: [ "https://identifiers.org/rrid/RRID:SCR_011929" ]
        version: [ "1.20" ]

arguments:
 - mkdir
 - train
 - ;
 - ln
 - -s
 - $(inputs.model.path)
 - train/
 - ;
 - ln
 - -s
 - $(inputs.prob_forward.path)
 - train/gene
 - ;
 - ln
 - -s
 - $(inputs.prob_backward.path)
 - train/rgene
 - ;
 - ln
 - -s
 - $(inputs.prob_noncoding.path)
 - train/noncoding
 - ;
 - ln
 - -s
 - $(inputs.prob_start.path)
 - train/start
 - ;
 - ln
 - -s
 - $(inputs.prob_stop.path)
 - train/stop
 - ;
 - ln
 - -s
 - $(inputs.prob_start1.path)
 - train/start1
 - ;
 - ln
 - -s
 - $(inputs.prob_stop1.path)
 - train/stop1
 - ;
 - ln
 - -s
 - $(inputs.pwm_dist.path)
 - train/pwm
 - ;
 - FragGeneScan
 - -o
 - $(runtime.outdir)/predicted_cds

# TODO: when Toil supports the InitialWorkDirRequirement, use that instead of
# this ShellCommandRequirement hack/workaround

inputs:
  sequence:
    type: File
    inputBinding:
      prefix: -s
  completeSeq:
    doc: |
       True if the sequence file has complete genomic sequences
       False if the sequence file has short sequence reads
    type: boolean
    inputBinding:
      valueFrom: |
       ${ if (self) {
            return [ "-w", "1" ];
          } else {
            return [ "-w", "0" ];
          }
        }
  model:
    type: File
    inputBinding:
      prefix: -t
      valueFrom: $(self.basename)
  prob_forward:
    type: File
    label: Forward probability model
  prob_backward:
    type: File
    label: Backward probability model
  prob_noncoding:
    type: File
    label: Noncoding probability model
  prob_start:
    type: File
    label: Start probability model
  prob_stop:
    type: File
    label: Stop probability model
  prob_start1:
    type: File
    label: Start1 probability model
  prob_stop1:
    type: File
    label: Stop1 probability model
  pwm_dist:
    type: File
    label: pwm distribution
  threadNumber:
    type: int?
    inputBinding:
      prefix: -p
#  trainDir: Directory
#  trainingName:
#    type: string
#    doc: |
#      default models:
#      [complete] for complete genomic sequences or short sequence reads without sequencing error
#      [sanger_5] for Sanger sequencing reads with about 0.5% error
#      [sanger_10] for Sanger sequencing reads with about 1% error
#      [454_5] for 454 pyrosequencing reads with about 0.5% error
#      [454_10] for 454 pyrosequencing reads with about 1% error
#      [454_30] for 454 pyrosequencing reads with about 3% error
#      [illumina_5] for Illumina sequencing reads with about 0.5%
#      [illumina_10] for Illumina sequencing reads with about 1% error rate
#    inputBinding:
#      prefix: -t
outputs:
  predictedCDS:
    type: File
    outputBinding:
      glob: predicted_cds.faa
