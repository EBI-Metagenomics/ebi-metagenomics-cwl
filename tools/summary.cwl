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
  submitted_count: int
  initial_filtered_count: int
  reads_with_orf: int
  rna_count: int
  reads_with_match: int
  predicted_CDS_count: int
  CDS_with_match: int
  IPS_matches: int

baseCommand: python

arguments:
  - prefix: -c
    valueFrom: |
      from __future__ import print_function
      print("Submitted nucleotide sequences\t$(submitted_count)")
      print("Nucleotide sequences after trimming and quality "
            "filtering\t$(initial_filtered_count)")
      print("Nucleotide sequences with predicted CDS\t$(reads_with_orf)")
      print("Nucleotide sequences with predicted RNA\t$(rna_count)")
      print("Nucleotide sequences with InterProScan match\t$(reads_with_match)")
      print("Predicted CDS\t$(predicted_CDS_count)")
      print("Predicted CDS with InterProScan match\t$(CDS_with_match)")
      print("Total InterProScan matches\t$(IPS_matches)")

stdout: summary

outputs:
  summary: stdout

$namespaces:
 s: http://schema.org/
$schemas:
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
