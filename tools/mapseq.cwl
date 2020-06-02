cwlVersion: v1.0
class: CommandLineTool
label: MAPseq
doc: |
  sequence read classification tools designed to assign taxonomy and OTU
  classifications to ribosomal RNA sequences.
  http://meringlab.org/software/mapseq/

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 10240
hints:
  SoftwareRequirement:
    packages:
      mapseq:
        version: [ "1.0" ]
        # specs: [ https://identifiers.org/rrid/RRID:TBD ]

inputs:
  sequences:
    type: File
    inputBinding:
      position: 1
    format: edam:format_1929  # FASTA

  database:
    type: File
    secondaryFiles: .mscluster 
    inputBinding:
      position: 2
    format: edam:format_1929  # FASTA

  taxonomy:
    type: File
    inputBinding:
      position: 3

baseCommand: mapseq

arguments:
 - valueFrom: "4"  # $(runtime.cores)
   prefix: -nthreads

stdout: classifications  # helps with cwltool's --cache

outputs:
  classifications:
    type: stdout
    format: iana:text/tab-separated-values

$namespaces:
 edam: http://edamontology.org/
 iana: https://www.iana.org/assignments/media-types/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schema.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
