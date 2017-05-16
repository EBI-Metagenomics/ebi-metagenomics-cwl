cwlVersion: v1.0
class: CommandLineTool

#MGRAST_base.py -l seq-length.out.full -g GC-distribution.out.full -d nucleotide-distribution.out.full -o summary -m 2000000 -i merged_with_unmerged_reads.trimmed.fastq.fasta
label: "Post QC-ed input analysis of sequence file"

#doc: |

requirements:
  InlineJavascriptRequirement: {}

inputs:
  qc_reas:
    type: File
    format: edam:format_1929  # FASTA
    inputBinding:
      prefix: "-i"
  length_sum:
    label: Summary of length distribution
    type:string
    default: seq-length.out.full
    inputBinding:
      prefix: -l
  gc_sum:
    label: Summary of GC distribution
    type:string
    default: GC-distribution.out.full 
    inputBinding:
      prefix: -g
  nucleotide_distribution:
    label: Nucleotide distribution
    type:string
    default: nucleotide-distribution.out.full
    inputBinding:
      prefix: -l
  summmary:
    label: Summary of .......
    type:string
    default: summary
    inputBinding:
      prefix: -o
  max_seq:
    label: Maximum number of sequences to sub-sample 
    type: int?
    default: 2000000
    inputBinding:
      prefix: -m

baseCommand: [ MGRAST_base.py ]

outputs:
  summary:
    label: information
    type: File
    format: text/plain
    outputBinding:
      glob: $(inputs.summary.nameroot).trimmed.fastq
 
   seq_length_pcbin:
    label: information
    type: File
    format: text/plain
    outputBinding:
      glob: $(inputs.length_sum.nameroot)_pcbin

   seq_length_bin:
    label: information
    type: File
    format: text/plain
    outputBinding:
      glob: $(inputs.length_sum.nameroot)_bin

   seq_length:
    label: information
    type: File
    format: text/plain
    outputBinding:
      glob: $(inputs.length_sum.nameroot)

   nucleotide_distribution:
    label: information
    type: File
    format: text/plain
    outputBinding:
      glob: $(inputs.nucleotide_distribution.nameroot)

   gc_sum_pcbin:
    label: information
    type: File
    format: text/plain
    outputBinding:
      glob: $(inputs.gc_sum.nameroot)_pcbin

  gc_sum_bin:
    label: information
    type: File
    format: text/plain
    outputBinding:
      glob: $(inputs.length_sum.nameroot)_bin

  gc_sum:
    label: information
    type: File
    format: text/plain
    outputBinding:
      glob: $(inputs.gc_sum.nameroot)



$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder:   "EMBL - European Bioinformatics Institute"
