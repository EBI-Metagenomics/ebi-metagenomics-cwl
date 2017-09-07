cwlVersion: v1.0
class: CommandLineTool


# For Megahit version 1.1.2

label: "megahit: metagenomics assembler"
requirements:
  - class: InlineJavascriptRequirement

doc : |
  https://github.com/voutcn/megahit/wiki

baseCommand: megahit

inputs:


  #  INPUT OPTIONS
  # TODO exclusive 1 & 2 || 12
  
  "1":
    type: File?
    inputBinding:
      position: 1
      prefix: "-1"

  "2":
    type: File?
    inputBinding:
      position: 2
      prefix: "-2"

  "12":
    type: File?
    inputBinding:
      position: 3
      prefix: "--12"

  r:
    type: File?
    inputBinding:
      position: 4
      prefix: "-r"
      # TODO check if multiple prefixes are possible?

  input-cmd:
    type: boolean?
    inputBinding:
      position: 5
      prefix: "--input-cmd"

  min-count:
    type: int?
    inputBinding:
      position: 6
      prefix: "--min-count"

  k-list:
    type: array?
    items: string
    inputBinding:
      position: 7
      prefix: "--k-list"
      itemSeparator: ","

  k-min:
    type: int?
    inputBinding:
      position: 8
      prefix: "--k-min"
  
  k-max:
    type: int?
    inputBinding:
      position: 9
      prefix: "--k-min"  

  k-step:
    type: int?
    inputBinding:
      position: 10
      prefix: "--k-min"


  no-mercy:
    type: boolean?
    inputBinding:
      position: 11
      prefix: "--no-mercy"

  bubble-level:
    type: int?
    inputBinding:
      position: 12
      prefix: "--bubble-level"

  merge-level:
    type: string?
    inputBinding:
      position: 14
      prefix: "--merge-level"

  prune-level:
    type: int?
    inputBinding:
      position: 15
      prefix: "--prune-level"

  prune-depth:
    type: int?
    inputBinding:
      position: 16
      prefix: "--prune-depth"

  low-local-ratio:
    type: float?
    inputBinding:
      position: 17
      prefix: "--low-local-ratio"

  max-tip-len:
    type: int?
    inputBinding:
      position: 18
      prefix: "--max-tip-len"

  no-local:
    type: boolena?
    inputBinding:
      position: 19
      prefix: "--kmin-1pass"
  
  presets:
    type: string?
    inputBinding:
      position: 20
      prefix: "--presets"

  m:
    type: float?
    inputBinding:
      position: 21
      prefix: "-m"

  mem-flag:
    type: int
    inputBinding:
      position: 22
      prefix: "--mem-flag"

  use-gpu:
    type: boolean?
    inputBinding:
      position: 23
      prefix: "--use-gpu"

  gpu-mem:
    type: boolean?
    inputBinding:
      position: 24
      prefix: "--gpu-mem"

  t:
    type: int?
    inputBinding:
      position: 25
      prefix: "-t"

  # OUTPUT OPTIONS

  o:
    type: string?
    inputBinding:
      position: 26
      prefix: "-o"

  out-prefix:
    type: string?
    inputBinding:
      position: 27
      prefix: "--out-prefix"

  min-contig-len:
    type: int?
    inputBinding:
      position: 28
      prefix: "--min-contig-len"

  keep-tmp-files:
    type: boolean?
    inputBinding:
      position: 29
      prefix: "--keep-tmp-files"

  tmp-dir:
    type: directory?
    inputBinding:
      position: 30
      prefix: "--tmp-dir"

  # OTHER ARGUMENTS

  continue:
    type: boolean?
    inputBinding:
      position: 31
      prefix: "--continue"

  verbose:
    type: boolean?
    inputBinding:
      position: 32
      prefix: "--verbose"


outputs:
  contigs:
    type: File
    outputBinding:
      glob: $(inputs.o || "megahit_out")/final.contigs.fa

