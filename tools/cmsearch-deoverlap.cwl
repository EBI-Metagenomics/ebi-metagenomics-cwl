cwlVersion: v1.0
class: CommandLineTool
label: remove lower scoring overlaps from cmsearch --tblout files.
doc: "https://github.com/nawrockie/cmsearch_tblout_deoverlap/blob/master/00README.txt"
hints:
  - class: SoftwareRequirement
    packages:
      cmsearch_tblout_deoverlap:
        specs: [ "https://github.com/nawrockie/cmsearch_tblout_deoverlap" ]
        #version: [ "1.1.2" ]

inputs:
  cmsearch_matches:
    type: File
    # inputBinding:
    #   position: 1
    #   valueFrom: $(self.basename)

  clan_information:
    label: clan information on the models provided
    type: File?
    # inputBinding:
    #   prefix: --clanin
    doc: Not all models provided need to be a member of a clan

baseCommand: []  # TODO, replaces with InitialWorkDirRequirement
arguments:
  - ln
  - - s
  - $(inputs.cmsearch_matches.path)
  - $(inputs.cmsearch_matches.basename)
  - ;
  - cmsearch-deoverlap.pl
  - $(inputs.cmsearch_matches.basename)
  - --clanin
  - $(inputs.clan_information.path)

outputs:
  deoverlapped_matches:
    label: target hits table, format 2
    doc: "http://eddylab.org/infernal/Userguide.pdf#page=60"
    type: File
    outputBinding:
      glob: "*.deoverlapped"

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
