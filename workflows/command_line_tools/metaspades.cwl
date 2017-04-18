cwlVersion: v1.0
class: CommandLineTool

label: metaSPAdes

doc: |
  metaSPAdes is a "versatile de novo metagenomics assembler"
  
  https://arxiv.org/abs/1604.03071
  http://cab.spbu.ru/files/release3.10.1/manual.html#meta

hints:
  SoftwareRequirement:
    packages:
      spades:
        specs: [ https://identifiers.org/rrid/RRID:SCR_000131 ]
        version: [ "3.10.1" ]

inputs:
  forwardReads:
    type: File
    format: edam:format_1930  # FASTQ
    inputBinding:
      prefix: "-1"
  reverseReads:
    type: File
    format: edam:format_1930  # FASTQ
    inputBinding:
      prefix: "-2"

baseCommand: [ metaspades.py ]

arguments: [ -o, $(runtime.outdir) ]

outputs:
  contigs:
    type: File
    format: edam:format_1929  # FASTA
    outputBinding:
      glob: contigs.fasta

  scaffolds:
    type: File
    format: edam:format_1929  # FASTA
    outputBinding:
      glob: scaffolds.fasta

  #everything:
  #  type: Directory
  #  outputBinding:
  #    glob: .

  assembly_graph:
    type: File
    #format: edam:format_TBD  # FASTG
    outputBinding:
      glob: assembly_graph.fastg

  contigs_assembly_graph:
    type: File
    outputBinding:
      glob: contigs.paths

  scaffolds_assembly_graph:
    type: File
    outputBinding:
      glob: scaffolds.paths

  contigs_before_rr:
    label: contigs before repeat resolution
    type: File
    format: edam:format_1929  # FASTA
    outputBinding:
      glob: before_rr.fasta

  params:
    label: information about SPAdes parameters in this run
    type: File
    format: text/plain
    outputBinding:
      glob: params.txt

  log:
    label: SPAdes log
    type: File
    format: text/plain
    outputBinding:
      glob: spades.log

  internal_config:
    label: internal configuration file
    type: File
    # format: text/plain
    outputBinding:
      glob: dataset.info

  internal_dataset:
    label: internal YAML data set file
    type: File
    outputBinding:
      glob: input_dataset.yaml

