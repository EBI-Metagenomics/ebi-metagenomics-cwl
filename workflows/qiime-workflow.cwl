cwlVersion: v1.0
class: Workflow
label: EMG pipeline's QIIME workflow
doc: |
      Step 1: Set environment
      PYTHONPATH, QIIME_ROOT, PATH

      Step 2: Run QIIME script pick_closed_reference_otus.py
      ${python} ${qiimeDir}/bin/pick_closed_reference_otus.py -i $1 -o $2 -r ${qiimeDir}/gg_13_8_otus/rep_set/97_otus.fasta -t ${qiimeDir}/gg_13_8_otus/taxonomy/97_otu_taxonomy.txt -p ${qiimeDir}/cr_otus_parameters.txt

      Step 3: Convert new biom format to old biom format (json)
      ${qiimeDir}/bin/biom convert -i ${resultDir}/cr_otus/otu_table.biom -o ${resultDir}/cr_otus/${infileBase}_otu_table_json.biom --table-type="OTU table" --to-json

      Step 4: Convert new biom format to a classic OTU table.
      ${qiimeDir}/bin/biom convert -i ${resultDir}/cr_otus/otu_table.biom -o ${resultDir}/cr_otus/${infileBase}_otu_table.txt --to-tsv --header-key taxonomy --table-type "OTU table"

      Step 5: Create otu summary
      ${qiimeDir}/bin/biom summarize-table -i ${resultDir}/cr_otus/otu_table.biom -o ${resultDir}/cr_otus/${infileBase}_otu_table_summary.txt

      Step 6: Move one of the result files
      mv ${resultDir}/cr_otus/otu_table.biom ${resultDir}/cr_otus/${infileBase}_otu_table_hdf5.biom

      Step 7: Create a list of observations
      awk '{print $1}' ${resultDir}/cr_otus/${infileBase}_otu_table.txt | sed '/#/d' > ${resultDir}/cr_otus/${infileBase}_otu_observations.txt

      Step 8: Create a phylogenetic tree by pruning GreenGenes and keeping observed otus
      ${python} ${qiimeDir}/bin/filter_tree.py -i ${qiimeDir}/gg_13_8_otus/trees/97_otus.tree -t ${resultDir}/cr_otus/${infileBase}_otu_observations.txt -o ${resultDir}/cr_otus/${infileBase}_pruned.tree

inputs:
  inp: File
  ex: string

outputs:
  classout:
    type: File
    outputSource: compile/classfile

steps:
  qiime:
    run: pick_closed_reference_otus.cwl
    in:
      tarfile: inp
      extractfile: ex
    out: [example_out]

  compile:
    run: arguments.cwl
    in:
      src: untar/example_out
    out: [classfile]