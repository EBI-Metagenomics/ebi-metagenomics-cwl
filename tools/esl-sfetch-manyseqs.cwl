cwlVersion: v1.0
class: CommandLineTool
label: extract by names from an indexed sequence file
doc: "https://github.com/EddyRivasLab/easel"

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 100  # just a default, could be lowered
hints:
  SoftwareRequirement:
    packages:
      easel: {}
        # specs: [ https://identifiers.org/rrid/RRID:TBD ]
        # version: [ "???" ]

inputs:
  indexed_sequences:
    label: sequence file indexed by esl-sfetch-index
    type: File
    secondaryFiles: .ssi
    inputBinding:
      prefix: -f
      position: 1
    format: edam:format_1929  # FASTA

  names:
    type: File
    label: sequence names to retrieve, one per line
    streamable: true
    inputBinding:
      position: 2

  names_contain_subseq_coords:
    doc: |
        GDF format: <newname> <from> <to> <source seqname>
        space/tabdelimited
    type: boolean
    inputBinding:
      prefix: -C

baseCommand: [ esl-sfetch ]

stdout: $(inputs.indexed_sequences.nameroot)_$(inputs.names.nameroot).fasta

outputs:
  sequences:
    type: stdout
    format: edam:format_1929  # FASTA

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schema.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
