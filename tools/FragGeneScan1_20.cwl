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

baseCommand: FragGeneScan

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 1024  # just a default, could be lowered
  SchemaDefRequirement:
    types:
      - $import: FragGeneScan-model.yaml
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - entryname: train/model
        entry: $(inputs.model.main)
      - entryname: train/gene
        entry: $(inputs.model.prob_forward)
      - entryname: train/rgene
        entry: $(inputs.model.prob_backward)
      - entryname: train/noncoding
        entry: $(inputs.model.prob_noncoding)
      - entryname: train/start
        entry: $(inputs.model.prob_start)
      - entryname: train/stop
        entry: $(inputs.model.prob_stop)
      - entryname: train/start1
        entry: $(inputs.model.prob_start1)
      - entryname: train/stop1
        entry: $(inputs.model.prob_stop1)
      - entryname: train/pwm
        entry: $(inputs.model.pwm_dist)
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
 - prefix: -o
   valueFrom: $(runtime.outdir)/predicted_cds
 - prefix: -t
   valueFrom: model

outputs:
  predicted_CDS_aa:
    type: File
    format: edam:format_1929  # FASTA
    outputBinding:
      glob: predicted_cds.faa
  predicted_CDS_nuc:
    type: File
    format: edam:format_1929  # FASTA
    outputBinding:
      glob: predicted_cds.ffn


$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schema.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
