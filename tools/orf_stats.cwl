#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: gather stats from ORF caller

hints:
  - class: SoftwareRequirement
    packages:
      biopython:
        specs: [ "https://identifiers.org/rrid/RRID:SCR_007173" ]
        version: [ "1.65", "1.66", "1.69" ]

inputs:
  orfs:
    type: File
    #format: edam:format_1929  # FASTA

baseCommand: python

arguments:
  - prefix: -c
    valueFrom: |
      from __future__ import print_function
      import re
      import json
      from Bio import SeqIO
      accessionPattern = re.compile("(\\S+)_\\d+_\\d+_[+-]")
      numberOrfs = 0
      readsWithOrf = set()
      for record in SeqIO.parse("$(inputs.orfs.path)", "fasta"):
          readAccessionMatch = re.match(accessionPattern, record.id)
          readAccession = readAccessionMatch.group(1)
          readsWithOrf.add(readAccession)
          numberOrfs += 1
      numberReadsWithOrf = len(readsWithOrf)
      print(json.dumps({
        "numberReadsWithOrf": numberReadsWithOrf,
        "numberOrfs": numberOrfs,
        "readsWithOrf": list(readsWithOrf) }))

stdout: cwl.output.json

outputs:
  numberReadsWithOrf: int
  numberOrfs: int
  readsWithOrf: string[]

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
