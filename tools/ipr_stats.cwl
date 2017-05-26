#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
label: gather stats from InterProScan
requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 1024  # just a default, could be lowered
hints:
  SoftwareRequirement:
    packages:
      python: {}

inputs:
  iprscan:
    type: File
    streamable: true

baseCommand: python

arguments:
  - prefix: -c
    valueFrom: |
      from __future__ import print_function
      import re
      import json
      accessionPattern = re.compile("(\\S+)_\\d+_\\d+_[+-]")
      matchNumber = 0
      cdsWithMatchNumber = 0
      readWithMatchNumber = 0
      cds = set()
      reads = set()
      for line in open("$(inputs.iprscan.path)", "r"):
          splitLine = line.strip().split("\\t")
          cdsAccessions = splitLine[0].split("|")
          for cdsAccession in cdsAccessions:
              cds.add(cdsAccession)
              readAccessionMatch = re.match(accessionPattern, cdsAccession)
              readAccession = readAccessionMatch.group(1)
              reads.add(readAccession)
              matchNumber += 1
      cdsWithMatchNumber = len(cds)
      readWithMatchNumber = len(reads)
      with open("reads.json", "w") as readsFile:
          json.dump(list(reads), readsFile)
      print(json.dumps({
        "matchNumber": matchNumber,
        "cdsWithMatchNumber": cdsWithMatchNumber,
        "readWithMatchNumber": readWithMatchNumber,
        "reads": {
            "class": "File",
            "format": "https://www.iana.org/assignments/media-types/application/json",
            "path": "$(runtime.outdir)/reads.json" } }))

stdout: cwl.output.json

outputs:
  matchNumber: int
  cdsWithMatchNumber: int
  readWithMatchNumber: int
  reads:
    type: File
    streamable: true
    format: iana:application/json

$namespaces:
 iana: https://www.iana.org/assignments/media-types/
 s: http://schema.org/
$schemas:
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
