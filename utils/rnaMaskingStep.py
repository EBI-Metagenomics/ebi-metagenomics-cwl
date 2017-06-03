#!/usr/bin/env python2
import argparse

from Bio import SeqIO
import sys
import datetime
import os
import time
import logging


def file_open(fileName, fileMode, buffer=0):
    """File opening utility that accounts for NFS delays
       Logs how long each file-opening attempt takes
       fileMode should be 'r' or 'w'
    """
    startTime = datetime.datetime.today()
    # print "Fileop: Trying to open file", fileName,"in mode", fileMode, "at", startTime.isoformat()
    if fileMode == 'w' or fileMode == 'wb':
        fileHandle = open(fileName, fileMode)
        fileHandle.close()
    while not os.path.exists(fileName):
        currentTime = datetime.datetime.today()
        timeSoFar = currentTime - startTime
        if timeSoFar.seconds > 30:
            print "Fileop: Took more than 30s to try and open", fileName
            print "Exiting"
            sys.exit(1)
        time.sleep(1)
    try:
        fileHandle = open(fileName, fileMode, buffer)
    except IOError as e:
        print "I/O error writing file{0}({1}): {2}".format(fileName, e.errno, e.strerror)
        print "Exiting"
        sys.exit(1)
    endTime = datetime.datetime.today()
    totalTime = endTime - startTime
    # print "Fileop: Opened file", fileName, "in mode", fileMode, "in", totalTime.seconds, "seconds"
    return fileHandle


def process_hmmer_output(file_name):
    """
    creates dictionary with read ID as key and a list (seqlength, startcoord, endcoord) as value
    """
    dict = {}
    with file_open(file_name, "r") as f:
        try:
            for l in f:
                if not l.startswith("#"):
                    field = l.split()
                    if not field[0] in dict:
                        dict[field[0]] = [field[2], field[17], field[18]]
                    else:
                        if int(dict[field[0]][1]) > int(field[17]):
                            dict[field[0]][1] = field[17]
                        if int(dict[field[0]][2]) < int(field[18]):
                            dict[field[0]][2] = field[18]
        except IndexError:
	    return {}
    return dict


def process_n_hmmer_output(file_name):
    """
    creates dictionary with read ID as key and a list of 'alifrom' 'ali to' and 'sq len' as a value.

    Example output of a nhmmer output file:

    # target name   accession   query name  accession   hmmfrom hmm to  alifrom ali to  envfrom env to  sq len  strand
    E-value score   bias    description of target
    ------------------- ---------- -------------------- ---------- ------- ------- ------- ------- ------- -------
    ----- ------ --------- ------ ----- ---------------------
    ERR866592.2371397-HWI-ST1233:228:H0KLTADXX:1:2104:20788:98011-1 -   tRNA    RF00005 3   69  7   74  5   76  100 +
    1.2e-07 40.2    0.1 -
    """
    dict = {}
    with file_open(file_name, "r") as f:
        for l in f:
            if not l.startswith("#"):
                field = l.split()
                target_name = field[0]
                ali_from = int(field[6])
                ali_to = int(field[7])
                sq_len = field[10]
                # flip the co-ordinates start position is bigger then the stop position
                if ali_from > ali_to:
                    ali_from = int(field[7])
                    ali_to = int(field[6])

                if not target_name in dict:
                    dict[target_name] = [sq_len, ali_from, ali_to]
                else:
                    if dict[target_name][1] > ali_from:
                        dict[target_name][1] = ali_from
                    if dict[target_name][2] < ali_to:
                        dict[target_name][2] = ali_to
    return dict


def maskRibosomalSequence(seqRecord, dict16S, dict23S, dict5S, dict_t_rna):
    passed = False
    seq = seqRecord.seq
    id = seqRecord.id
    dicts = [dict16S, dict23S, dict5S, dict_t_rna]

    for d in dicts:
        if id in d:
            start_pos = d[id][1]
            end_pos = d[id][2]
            seq_length = d[id][0]
            logging.debug("identifier: " + id)
            logging.debug("Start : " + str(start_pos))
            logging.debug("End   : " + str(end_pos))
            logging.debug("Length: " + str(seq_length))
            logging.debug("original sequence: " + seq)
            # mask the RNA regions
            seq = seq[:int(start_pos) - 1] + "N" * (int(end_pos) - int(start_pos) + 1) + seq[
                                                                                         int(end_pos):int(seq_length)]
            logging.debug("masked sequence  : " + seq)
    # write the resulting masked sequences to file
    if len(str(seq).replace("N", "")) > 60:
        seqRecord.seq = seq
        passed = True
    return seqRecord, passed


def mask_sequence_records(rRNASelectorOutput, fullFastaFileName, outputFastaFile, t_rna_selector_uniq_seq_ids,
                          t_rna_selector_nhmmer_output):
    # Store all read sequence identifiers with RNA matches in a single set
    rna_sequences = set()
    # First of all for rRNA matches
    allrRNAHeaders = file_open(rRNASelectorOutput, "r")
    for line in allrRNAHeaders:
        rna_sequences.add(line.rstrip())
    # Secondly for tRNA matches
    t_rna_read_seq_ids = file_open(t_rna_selector_uniq_seq_ids, "r")
    for line in t_rna_read_seq_ids:
        rna_sequences.add(line.rstrip())

    rRNACoordFiles = []  # initialise empty list
    # generate rRNAselect text file names
    rRNA16s_txt_file = rRNASelectorOutput.replace("txt", "16s.txt")
    rRNA23s_txt_file = rRNASelectorOutput.replace("txt", "23s.txt")
    rRNA5s_txt_file = rRNASelectorOutput.replace("txt", "5s.txt")
    dict16S = process_hmmer_output(rRNA16s_txt_file)
    dict23S = process_hmmer_output(rRNA23s_txt_file)
    dict5S = process_hmmer_output(rRNA5s_txt_file)
    dict_t_rna = process_n_hmmer_output(t_rna_selector_nhmmer_output)

    # open output file with large buffer to limit number of write operations
    maskedRibosomalFasta = file_open(outputFastaFile, "w", 1000000)

    seq_not_passed_counter = 0
    for seqRecord in SeqIO.parse(fullFastaFileName, "fasta"):
        if not seqRecord.id in rna_sequences:
            SeqIO.write([seqRecord], maskedRibosomalFasta, "fasta")
        else:
            maskedSeqRecord, passed = maskRibosomalSequence(seqRecord, dict16S, dict23S, dict5S, dict_t_rna)
            if passed is True:
                SeqIO.write([maskedSeqRecord], maskedRibosomalFasta, "fasta")
            else:
                seq_not_passed_counter += 1
    logging.debug(str(seq_not_passed_counter) + " reads did not pass length criteria (>60) after masking.")

    maskedRibosomalFasta.flush()  # safer when using large buffer size
    maskedRibosomalFasta.close()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="RNA masking tool.")
    parser.add_argument("-l", "--log", help="Log level, e.g. DEBUG", default="INFO", required=False)
    parser.add_argument("-hm", "--hmmer", help="HMMER output file (rRNA selection).", required=True)
    parser.add_argument("-nh", "--nhmmer", help="nhmmer output file (tRNA selection).", required=True)
    parser.add_argument("-i", "--input", help="FASTA input file.", required=True)
    parser.add_argument("-o", "--output", help="Output file path.", required=True)
    parser.add_argument("-id", "--seq_id", help="tRNA sequence identifiers.", required=True)

    args = parser.parse_args()
    log_level = args.log
    numeric_level = getattr(logging, log_level.upper(), None)
    if not isinstance(numeric_level, int):
        raise ValueError('Invalid log level: %s' % log_level)
    logging.basicConfig(level=numeric_level)

    rRNASelectorOutput = args.hmmer
    fullFastaFileName = args.input
    outputFastaFile = args.output
    t_rna_selector_uniq_seq_ids = args.seq_id
    t_rna_selector_nhmmer_output = args.nhmmer
    mask_sequence_records(rRNASelectorOutput, fullFastaFileName, outputFastaFile, t_rna_selector_uniq_seq_ids,
                          t_rna_selector_nhmmer_output)
