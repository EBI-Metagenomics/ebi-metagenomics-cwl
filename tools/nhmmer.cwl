cwlVersion: v1.0
class: CommandLineTool
label: search profile(s) against a sequence database
requirements:
  ResourceRequirement:
    coresMax: 4
    ramMin: 1024  # just a default, could be lowered
hints:
  SoftwareRequirement:
    packages:
      hmmer:
        specs: [ "https://identifiers.org/rrid/RRID:SCR_005305" ]
        version: [ "3.1b2" ]

inputs:
  query:
    type: File
    inputBinding:
      position: 1
    format: edam:format_1370  # HMMER

  sequences:
    type: File
    inputBinding:
      position: 2

  bitscore_threshold:
    type: int?
    label: report sequences >= this bit score threshold in output
    inputBinding:
      prefix: -T

baseCommand: [ nhmmer ]

arguments:
 - --tblout
 - per_target_summary.txt
 - valueFrom: $(runtime.cores)
   prefix: --cpu

outputs:
  per_target_summary:
    type: File
    outputBinding:
      glob: per_target_summary.txt

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schema.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
