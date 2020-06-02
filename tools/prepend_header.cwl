#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: prepend a string + an underscore to all headers in a FASTA sequence file

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 100  # just a default, could be lowered

inputs:
  sequences:
    type: File
    format: edam:format_1929  # FASTA
    streamable: true
  label: string

stdin: $(inputs.sequences.path)

baseCommand: sed

arguments: [ "s/^>/>$(inputs.label)_/" ]

stdout: $(inputs.sequences.basename).labeled.fasta  # to aid cwltool's cache feature

outputs:
  labeled_sequences:
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
