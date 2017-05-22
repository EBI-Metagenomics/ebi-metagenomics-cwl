#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: split FASTA by number of records

inputs:
  seqs:
    type: File
    format: edam:format_1929  # FASTA
  chunk_size: int

baseCommand:
  - python
  - -c
  - |
    from Bio import SeqIO
    currentSequences = []
    for record in SeqIO.parse("$(inputs.seqs.path)", "fasta"):
        currentSequences.append(record)
        if len(currentSequences) == $(inputs.chunkSize):
            fileName = currentSequences[0].id + "_" + currentSequences[-1].id
            fileName = fileName.replace("/", "_").replace(" ", "_")
            SeqIO.write(currentSequences, "$(runtime.outdir)/"+fileName, "fasta")
            currentSequences = []

    # write any remaining sequences
    if len(currentSequences) > 0:
        fileName = currentSequences[0].id + "_" + currentSequences[-1].id
        fileName = fileName.replace("/", "_").replace(" ", "_")
        SeqIO.write(currentSequences, "$(runtime.outdir)/"+fileName, "fasta")

outputs:
  chunks:
    format: edam:format_1929  # FASTA
    type: File[]
    outputBinding:
      glob: '*'

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
