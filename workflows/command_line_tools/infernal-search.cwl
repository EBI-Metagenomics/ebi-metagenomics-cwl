cwlVersion: v1.0
class: CommandLineTool
label: search sequence(s) against a covariance model database
doc: http://eddylab.org/infernal/Userguide.pdf
hints:
  SoftwareRequirement:
    packages:
      spades:
        specs: [ https://identifiers.org/rrid/RRID:SCR_011809 ]
        version: [ "1.1.2" ]
inputs:
  covariance_model_database:
    type: File
    inputBinding:
      position: 1
    secondaryFiles:
     - .i1f
     - .i1i
     - .i1m
     - .i1p
    #format: 

  query_sequences:
    type: File
    streamable: true
    inputBinding:
      position: 1
    format:
      - edam:format_1929  # FASTA
      - edam:format_1927  # EMBL
      - edam:format_1936  # Genbank entry format
      - edam:format_1961  # Stockholm
      - edam:format_3281  # A2M
      - edam:format_1982  # Clustal
      - edam:format_1997  # PHYLIP
      # ddbj ?
      # pfam ?
      # afa ?

  omit_alignment_section:
    label: Omit the alignment section from the main output.
    type: boolean?
    default: false
    inputBinding:
      prefix: --noali
    doc: This can greatly reduce the output volume.

  #threads:
  #  label: number of parallel worker threads
  #  type: int
  #  default: $(runtime.cores)  # not working in CWL v1.0
  #  inputBinding:
  #    prefix: --cpu

baseCommand: cmscan

arguments:
 - --fmt
 - '2'
 - --tblout
 - matches.tbl
 - valueFrom: $(runtime.cores)
   prefix: --cpu

outputs:
  matches:
    type: File
    outputBinding:
      glob: matches.tbl
