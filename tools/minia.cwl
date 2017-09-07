cwlVersion: v1.0
class: CommandLineTool


# For Minia 2.0.7

label: "minia: metagenomics assembler"
requirements:
  - class: InlineJavascriptRequirement

doc : |
  http://minia.genouest.org/
  http://minia.genouest.org/files/minia.pdf

baseCommand: minia

inputs:
  # Assembly options

  # Input graph file (hdf5 format)
  graph:
    type: File?
    inputBinding:
      position: 1
      prefix: "-graph"
  
  # Input file (fasta or fastq, or file containing line-seperated list of input filenames)
  in:
    type: File?
    inputBinding:
      position: 2
      prefix: "-in"
  
  # Turn off length cutoff at 2*k in output sequences
  no-length-cutoff:
    type: boolean?
    inputBinding:
      position: 3
      prefix: "-no-length-cutoff"
  
  # Traversal type ('contig', 'unitig')
  traversal:
    type: string?
    inputBinding:
      position: 4
      prefix: "-traversal"

  # Starting node ('best', 'simple')
  starter:
    type: string?
    inputBinding:
      position: 5
      prefix: "-starter"

  # Maximum length of contigs
  contig-max-len:
    type: int?
    inputBinding:
      position: 6
      prefix: "-contig-max-len"

  # Maximum depth for BFS
  bfs-max-depth:
    type: int?
    inputBinding:
      position: 7
      prefix: "-bfs-max-depth"  

  # Maximum breadth for BFS
  bfs-max-breadth:
    type: int?
    inputBinding:
      position: 8
      prefix: "-bfs-max-breadth"

  # Number of nucleotides per line in fasta output
  fasta-line:
    type: int?
    inputBinding:
      position: 9
      prefix: "-fasta-line"
  



  # KMER COUNT OPTIONS


  # Size of a kmer
  kmer-size:
    type: int?
    inputBinding:
      position: 10
      prefix: "-kmer-size"

  # Min abundance threshold for solid kmers
  abundance-min:
    type: long?
    inputBinding:
      position: 11
      prefix: "-abundance-min"
  
  # Max abundance threshold for solid kmers
  abundance-max:
    type: long?
    inputBinding:
      position: 12
      prefix: "-abundance-max"

  # Max number of values in kmers histogram
  histo-max:
    type: int?
    inputBinding:
      position: 13
      prefix: "-histo-max"

  # Solidity-kind ('sum', 'min' or 'max')
  solidity-kind:
    type: string?
    inputBinding:
      position: 14
      prefix: "-solidity-kind"
  
  # Maximum memory in MBytes - REPLACED BY ARGUMENT (SEE BELOW)
  # max-memory:
  #   type: long?
  #   inputBinding:
  #     position: 15
  #     prefix: "-max-memory"

  # Maximum disk usage in MBytes 
  max-disk:
    type: long?
    inputBinding:
      position: 16
      prefix: "-max-disk"

  # Specify output filename, otherwise use input file name
  out:
    type: string?
    inputBinding:
      position: 17
      prefix: "-out"
  
  # Specify output directory - REPLACED BY ARGUMENT (SEE BELOW)
  # out-dir:
  #   type: string?
  #   inputBinding:
  #     position: 18
  #     prefix: "-out-dir"

  # Minimiser type (0=lexi, 1=freq)
  minimizer-type:
    type: int?
    inputBinding:
      position: 19
      prefix: "-minimizer-type"

  # Size of a minimizer
  minimizer-size:
    type: int?
    inputBinding:
      position: 20
      prefix: "-minimizer-size"

  # Minimiser repartition (0=unordered, 1=ordered)
  repartition-type:
    type: int?
    inputBinding:
      position: 21
      prefix: "-repartition-type"


  # BLOOM OPTIONS

  # Bloom type ('basic', 'cache', 'neighbor')
  bloom:
    type: string?
    inputBinding:
      position: 22
      prefix: "-bloom"
  
  # Debloom type ('none', 'original' or 'cascading')
  debloom:
    type: string?
    inputBinding:
      position: 23
      prefix: "-debloom"

  # Debloom impl ('basic', 'minimizer')
  debloom-impl:
    type: string?
    inputBinding:
      position: 24
      prefix: "-debloom-impl"

  
  # BRANCHING OPTIONS

  # Branching type ('none', 'stored')
  branching-nodes:
    type: string?
    inputBinding:
      position: 25
      prefix: "-branching-nodes"

  # Topological information level (0 for none)
  topology-stats:
    type: int?
    inputBinding:
      position: 26
      prefix: "-topology-stats"

  # Mphf type ('none', 'emphf')
  mphf:
    type: string?
    inputBinding:
      position: 27
      prefix: "-mphf"


  # GENERAL OPTIONS

  # Number of cores - REPLACED BY ARGUMENT (SEE BELOW)
  # nb-cores:
  #   type: int?
  #   inputBinding:
  #     position: 28
  #     prefix: "-nb-cores"
  
  verbose:
    type: int?
    inputBinding:
      position: 29
      prefix: "-verbose"

  integer-precision:
    type: int?
    inputBinding:
      position: 30
      prefix: "-integer-precision"

arguments:
  - valueFrom: $(runtime.cores)
    prefix: "-nb-cores"
  
  -valueFrom: $(runtime.outdir)
    prefix: "-out-dir"

  - valueFrom: $(runtime.ram)
    prefix: "-max-memory"  

outputs:
  contigs:
    type: File
    outputBinding:
      glob: $(inputs.out || inputs.in.nameroot).contigs.fa
  
  h5:
    type: File
    outputBinding:
      glob: $(inputs.out || inputs.in.nameroot).h5

