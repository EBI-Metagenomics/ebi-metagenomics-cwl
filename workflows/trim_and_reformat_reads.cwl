cwlVersion: v1.0
class: Workflow
label: Trim and reformat reads (single and paired end version)

requirements:
 - class: SubworkflowFeatureRequirement
 - class: SchemaDefRequirement
   types:
    - $import: ../tools/trimmomatic-sliding_window.yaml
    - $import: ../tools/trimmomatic-end_mode.yaml
    - $import: ../tools/trimmomatic-phred.yaml

inputs:
  reads:
    type: File
    format: edam:format_1930  # FASTQ

outputs:
  trimmed_and_reformatted_reads:
    type: File
    outputSource: clean_fasta_headers/sequences_with_cleaned_headers
 
 
steps:
  trim_quality_control:
    doc: |
      Low quality trimming (low quality ends and sequences with < quality scores
      less than 15 over a 4 nucleotide wide window are removed)
    run: ../tools/trimmomatic.cwl
    in:
      reads1: reads
      phred: { default: '33' }
      leading: { default: 3 }
      trailing: { default: 3 }
      end_mode: { default: SE }
      minlen: { default: 100 }
      slidingwindow:
        default:
          windowSize: 4
          requiredQuality: 15
    out: [reads1_trimmed]

  convert_trimmed_reads_to_fasta:
    run: ../tools/fastq_to_fasta.cwl
    in:
      fastq: trim_quality_control/reads1_trimmed
    out: [ fasta ]

  clean_fasta_headers:
    run: ../tools/clean_fasta_headers.cwl
    in:
      sequences: convert_trimmed_reads_to_fasta/fasta
    out: [ sequences_with_cleaned_headers ]

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schema.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
