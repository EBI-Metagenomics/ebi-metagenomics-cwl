#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 100  # just a default, could be lowered
hints:
  SoftwareRequirement:
    packages:
      python: {}

inputs:
  krona_chart: File

baseCommand: python

arguments:
  - prefix: -c
    valueFrom: |
      text = ""
      with open("$(inputs.krona_chart.path)", "r") as inFile:
         text = inFile.read()
      notFound = r'<script id="notfound">window.onload=function(){document.body.innerHTML="Could not get resources from \\"http://krona.sourceforge.net\\"."}</script>'
      text = text.replace(notFound, "")
      oldJavaScriptUrl = "http://krona.sourceforge.net/src/krona-2.0.js"
      newJavaScriptUrl = "/metagenomics/js/krona-2.0-customized.js"
      text = text.replace(oldJavaScriptUrl, newJavaScriptUrl)
      oldImageUrlPrefix = "http://krona.sourceforge.net/img/"
      newImageUrlPrefix = "/metagenomics/img/krona/"
      text = text.replace(oldImageUrlPrefix, newImageUrlPrefix)
      with open("$(inputs.krona_chart.nameroot)_fixed.html", "w") as outFile:
          outFile.write(text)

outputs:
  fixed_krona_chart:
    type: File
    outputBinding: { glob: $(inputs.krona_chart.nameroot)_fixed.html }

$namespaces:
 s: http://schema.org/
$schemas:
 - https://schema.org/version/latest/schema.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
