#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "InterProScan: protein sequence classifier"

doc: |
      Version 5.21-60 can be downloaded here:
      https://github.com/ebi-pf-team/interproscan/wiki/HowToDownload
      
      Documentation on how to run InterProScan 5 can be found here:
      https://github.com/ebi-pf-team/interproscan/wiki/HowToRun

requirements:
  SchemaDefRequirement:
    types: 
      - $import: InterProScan-apps.yaml
      - $import: InterProScan-protein_formats.yaml
  DockerRequirement:
    dockerPull: 'biocontainers/interproscan:v5.30-69.0_cv1'
  ShellCommandRequirement: {}
hints:
  SoftwareRequirement:
    packages:
      interproscan:
        specs: [ "https://identifiers.org/rrid/RRID:SCR_005829" ]
        version: [ "5.30-69" ]
  ResourceRequirement:
    ramMin: 8192
    coresMin: 3
inputs:
  proteinFile:
    type: File
    inputBinding:
      prefix: --input
  # outputFileType:
  #   type: InterProScan-protein_formats.yaml#protein_formats
  #   inputBinding:
  #     prefix: --formats
  applications:
    type: InterProScan-apps.yaml#apps[]?
    inputBinding:
      itemSeparator: ','
      prefix: --applications
  databases: Directory

baseCommand: []  # interproscan.sh

arguments:
 - cp
 - -r
 - /opt/interproscan
 - $(runtime.outdir)/interproscan
 - ;

 - rm
 - -rf
 - $(runtime.outdir)/interproscan/data
 - ;

 - cp
 - -rs
 - $(inputs.databases.path)/data
 - $(runtime.outdir)/interproscan/
 - ;

 - bash
 - $(runtime.outdir)/interproscan/interproscan.sh

 - prefix: --outfile
   valueFrom: $(runtime.outdir)/$(inputs.proteinFile.nameroot).i5_annotations
 - prefix: --formats
   valueFrom: TSV
 - --disable-precalc
 - --goterms
 - --pathways
 - prefix: --tempdir
   valueFrom: $(runtime.tmpdir)


outputs:
  i5Annotations:
    type: File
    format: iana:text/tab-separated-values
    outputBinding:
      glob: $(inputs.proteinFile.nameroot).i5_annotations

$namespaces:
 iana: https://www.iana.org/assignments/media-types/
 s: http://schema.org/
$schemas:
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
