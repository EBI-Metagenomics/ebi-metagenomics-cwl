#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: generate a modified tsv taxonomy file that works with the current web app

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 100  # just a default, could be lowered

hints:
  SoftwareRequirement:
    packages:
      python: {}

inputs:
  uclust_log:
    type: File
  otu_table:
    type: File

baseCommand: python

arguments:
  - prefix: -c
    valueFrom: |
      from __future__ import print_function
      unassignedOTUCount = "0"
      with open("$(inputs.uclust_log.path)", "r") as uclog:
          for f in uclog:
              if f.startswith("Num failures:"):
                  unassignedOTUCount = f.rstrip().split(":")[1]
      with open("$(inputs.otu_table.path)", "r") as table:
          for line in table:
              line = line.rstrip()
              if line.startswith("#"):
                  if line.startswith("#OTU"):
                      print(line)
              else:
                  l = line.rstrip().split("\\t")
                  obsCount = l[1].replace(".0", "")
                  lineage = l[-1].replace(" ", "")
                  tax = "Root;" + lineage
                  print(l[0] + "\\t" + obsCount + "\\t" + tax)
          if unassignedOTUCount != "0":
              print("0" + "\\t" + unassignedOTUCount + "\\t" + "Root")

stdout: qiime_assigned_taxonomy.txt

outputs:
  qiime_assigned_taxonomy:
    type: stdout

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schema.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
