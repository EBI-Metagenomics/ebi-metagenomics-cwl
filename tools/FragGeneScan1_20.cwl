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
  SchemaDefRequirement:
    types:
      - $import: FragGeneScan-model.yaml
  InlineJavascriptRequirement: {}
  ShellCommandRequirement: {}

hints:
  SoftwareRequirement:
    packages:
      fraggenescan:
        specs: [ "https://identifiers.org/rrid/RRID:SCR_011929" ]
        version: [ "1.20" ]

inputs:
  sequence:
    type: File
    format: edam:format_1929  # FASTA
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
  model: FragGeneScan-model.yaml#model
  threadNumber:
    type: int?
    inputBinding:
      prefix: -p


arguments:
 - mkdir
 - train
 - ;
 - ln
 - -s
 - $(inputs.model.main.path)
 - train/
 - ;
 - ln
 - -s
 - $(inputs.model.prob_forward.path)
 - train/gene
 - ;
 - ln
 - -s
 - $(inputs.model.prob_backward.path)
 - train/rgene
 - ;
 - ln
 - -s
 - $(inputs.model.prob_noncoding.path)
 - train/noncoding
 - ;
 - ln
 - -s
 - $(inputs.model.prob_start.path)
 - train/start
 - ;
 - ln
 - -s
 - $(inputs.model.prob_stop.path)
 - train/stop
 - ;
 - ln
 - -s
 - $(inputs.model.prob_start1.path)
 - train/start1
 - ;
 - ln
 - -s
 - $(inputs.model.prob_stop1.path)
 - train/stop1
 - ;
 - ln
 - -s
 - $(inputs.model.pwm_dist.path)
 - train/pwm
 - ;
 - FragGeneScan
 - -o
 - $(runtime.outdir)/predicted_cds
 - -t
 - train/$(inputs.model.main.basename)

# TODO: when Toil supports the InitialWorkDirRequirement, use that instead of
# this ShellCommandRequirement hack/workaround

outputs:
  predictedCDS:
    type: File
    format: edam:format_1929  # FASTA
    outputBinding:
      glob: predicted_cds.faa

$namespaces: { edam: "http://edamontology.org/" }
$schemas: [ "http://edamontology.org/EDAM_1.16.owl" ]
