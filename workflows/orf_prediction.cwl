cwlVersion: v1.0
class: Workflow
label: Find reads with predicted coding sequences above 60 AA in length

requirements:
 - class: SchemaDefRequirement
   types: 
     - $import: ../tools/FragGeneScan-model.yaml

inputs:
  sequence:
    type: File
    format: edam:format_1929  # FASTA
  completeSeq: boolean
  model: ../tools/FragGeneScan-model.yaml#model

outputs:
  predicted_CDS_aa:
    type: File
    format: edam:format_1929  # FASTA
    outputSource: ORF_prediction/predicted_CDS_aa
  predicted_CDS_nuc:
    type: File
    format: edam:format_1929  # FASTA
    outputSource: ORF_prediction/predicted_CDS_nuc


steps:
  ORF_prediction:
    doc: |
      Find reads with predicted coding sequences (pCDS)
    run: ../tools/FragGeneScan1_20.cwl
    in:
      sequence: sequence
      completeSeq: completeSeq
      model: model
    out: [ predicted_CDS_aa, predicted_CDS_nuc ]

  # remove_short_pCDS:
    # run: ../tools/discard_short_seqs.cwl
    # in:
    #   sequences: ORF_prediction/predictedCDS
    #  minimum_length: { default: 60 }
    # out: [ filtered_sequences ]

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
