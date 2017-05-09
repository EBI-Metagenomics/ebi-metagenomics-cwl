#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

inputs:
  biomMethod:
    type: string
    inputBinding:
      position: 1  
  otuTable:
    type: File
    inputBinding:
      prefix: "-i"
      position: 2  
  otuTableType:
    type: string
    inputBinding:
      prefix: "--table-type"
      #separate: false
      position: 5  
    default: "OTU table"
  otuOutputFile:
    type: string
    inputBinding:
      prefix: "-o"
      position: 3  
  otuFormat:
    type: string
    inputBinding:
      prefix: "--"
      separate: false
      position: 4  
    default: "to-json"
#  otuHeader:
#    type: string
#    inputBinding:
#      prefix: "--header-key"
#      position: 6  
  
baseCommand: [ biom ]

outputs:
  otuBiom:
    type: File
    outputBinding:
      glob: otu_table.json
      #glob: $(inputs.otuOutputFile)

#biom convert -i ../../test/other_otus.txt -o otus_table.biom --table-type="OTU table" --to-json
#biom convert -i ../../test/other_otus.txt -o otus_table.biom --table-type="OTU table" --to-json

$namespaces:
 s: http://schema.org/
$schemas:
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
