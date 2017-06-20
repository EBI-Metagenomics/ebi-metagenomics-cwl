cwlVersion: v1.0
class: Workflow
label: Find reads with predicted coding sequences above 60 AA in length

requirements:
 ScatterFeatureRequirement: {}
 SchemaDefRequirement:
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
    outputSource: combine_predicted_CDS_aa/result
  predicted_CDS_nuc:
    type: File
    format: edam:format_1929  # FASTA
    outputSource: combine_predicted_CDS_nuc/result


steps:
  split_seqs:
    run: ../tools/fasta_chunker.cwl
    in:
      seqs: sequence
      chunk_size: { default: 100000 }
    out: [ chunks ]
    
  ORF_prediction:
    doc: |
      Find reads with predicted coding sequences (pCDS)
    run: ../tools/FragGeneScan1_20.cwl
    in:
      sequence: split_seqs/chunks
      completeSeq: completeSeq
      model: model
    scatter: sequence
    out: [ predicted_CDS_aa, predicted_CDS_nuc ]

  combine_predicted_CDS_aa:
    run: ../tools/concatenate.cwl
    in:
      files: ORF_prediction/predicted_CDS_aa
    out: [ result ]

  combine_predicted_CDS_nuc:
    run: ../tools/concatenate.cwl
    in:
      files: ORF_prediction/predicted_CDS_nuc
    out: [ result ]


$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
