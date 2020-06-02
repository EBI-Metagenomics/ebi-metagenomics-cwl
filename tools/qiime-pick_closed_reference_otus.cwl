#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 1024  # just a default, could be lowered
hints:
 SoftwareRequirement:
   packages:
     qiime:
       specs: [ "https://identifiers.org/rrid/RRID:SCR_008249" ]
       version: [ "1.9.1" ]

inputs:
 sequences:
   type: File
   format: edam:format_1929  # FASTA
   inputBinding:
     prefix: --input_fp

baseCommand: pick_closed_reference_otus.py

arguments:
 - valueFrom: $(runtime.outdir)
   prefix: --output_dir
 - --force

outputs:
  otus_tree:
    type: File
    outputBinding: { glob: 97_otus.tree }
  otu_table:
    type: File
    format: edam:format_3746  # BIOM
    outputBinding: { glob: otu_table.biom }
  log:
    type: File
    outputBinding: { glob: log_*.txt }
  sequences-filtered_clusters:
    type: File
    outputBinding: { glob: uclust_ref_picked_otus/*_clusters.uc }
  sequences-filtered_failures:
    type: File
    outputBinding: { glob: uclust_ref_picked_otus/*_failures.txt }
  sequences-filtered_otus:
    type: File
    outputBinding: { glob: uclust_ref_picked_otus/*_otus.txt }
  sequences-filtered_otus_log:
    type: File
    outputBinding: { glob: uclust_ref_picked_otus/*_otus.log }

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schema.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
