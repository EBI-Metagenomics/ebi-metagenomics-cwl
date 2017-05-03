cwlVersion: v1.0
class: CommandLineTool

hints:
  - class: SoftwareRequirement
    packages:
      fastx_toolkit:
        specs: [ "https://identifiers.org/rrid/RRID:SCR_005534" ]
        version: [ "0.0.13" ]

inputs:
  fastq:
    type: File
    inputBinding:
      prefix: -i
    format: edam:format_1930  # FASTQ

baseCommand: [ fastq_to_fasta ]

stdout: fasta # helps with cwltool's --cache

outputs:
  fasta:
    type: stdout
    format: edam:format_1929  # FASTA

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
