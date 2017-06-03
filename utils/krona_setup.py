#!/usr/bin/env python

from subprocess import call
import sys

class TaxonomyRecord(object):
    ROOT = 'Root'
    KINGDOM = 'Kingdom'
    PHYLUM = 'Phylum'
    CLASS = 'Class'
    ORDER = 'Order'
    FAMILY = 'Family'
    UNASSIGNED = 'Unassigned'
    HIERARCHY_POS = {ROOT: 0, KINGDOM: 1, PHYLUM: 2, CLASS: 3, ORDER: 4, FAMILY: 5}
    
    def _cleanHierarchy(self, hierarchy):
        temp = []        
        for item in hierarchy:
            if '__' in item:
                item = item[3:]
            if item.startswith('['):
                item = item.lstrip('[')
            if item.endswith(']'):
                item = item.rstrip(']')
            if item:
                temp.append(item)
        return tuple(temp)    


    def __init__(self, taxonomyRecordString):
        
        taxonomyRecordString = taxonomyRecordString.strip()
        split = taxonomyRecordString.split()
        self.clusterID = split[0]
        self.observationCount = split[1]
        tempHierarchy = split[2].split(';')
        self.hierarchy = self._cleanHierarchy(tempHierarchy)

    def getKingdom(self):
        t = TaxonomyRecord
        if len(self.hierarchy) > t.HIERARCHY_POS[t.KINGDOM]:
            return self.hierarchy[t.HIERARCHY_POS[t.KINGDOM]]
        else:
            return t.UNASSIGNED

    def getPhylum(self):
        t = TaxonomyRecord
        
        if len(self.hierarchy) > t.HIERARCHY_POS[t.PHYLUM]:
            return self.hierarchy[t.HIERARCHY_POS[t.PHYLUM]]
        else:
            return t.UNASSIGNED    


def num(s):
    try:
        return int(s)
    except ValueError:
        return float(s)


class TaxonomyRecordCollection(object):

    def __init__(self, fileName):
        self.records = []
        inFile = open(fileName, "r")
        for line in inFile:
            if not line.startswith('#'):
                line = line.strip()
                # add lineage as many times as it has been observed
                l = line.split()
                obsCount = int(l[1])
                while (obsCount > 0):
                    self.records.append(TaxonomyRecord(line))
                    obsCount = obsCount - 1
        inFile.close()
        self.kronaSummary = self._generateKronaSummary()
        self.topTaxonomyCounts = self._generateTopTaxonomyCounts()

    def sort(self):
        self.records.sort()
   
    def _generateTopTaxonomyCounts(self):
        tempCounts = {}
        total = len(self.records)
        for taxRecord in self.records:
            kingdom = taxRecord.getKingdom()
            phylum = taxRecord.getPhylum()            
            tempCounts.setdefault( (kingdom, phylum), 0)
            tempCounts[(kingdom, phylum)] +=1            
        counts = []
        for (kingdom, phylum) in tempCounts:
            count = tempCounts[(kingdom, phylum)]
            percentage = float(count)/total * 100
            counts.append((kingdom, phylum, count, percentage) )
        return counts       

    def _generateKronaSummary(self):
        kronaSummary = {}
        for record in self.records:
            kronaSummary.setdefault(record.hierarchy, 0)
            kronaSummary[record.hierarchy] += 1
        return kronaSummary    

    def writeKronaSummary(self, outputFileName):
        outFile = open(outputFileName, 'w')
        for item in self.kronaSummary:
            # need to remove the root level for Krona chart to work properly
            itemList = list(item)
            if itemList != ['Unassignable',]:
	        itemList.remove(TaxonomyRecord.ROOT)
                itemString = '\t'.join(itemList)
                countString = str(self.kronaSummary[item])
                outFile.write(countString + '\t' + itemString + '\n')
        outFile.close()

    def writeKingdomCounts(self, outputFileName):                  
        outFile = open(outputFileName, 'w')
        for (kingdom, phylum, count, percentage) in self.topTaxonomyCounts:            
            outFile.write('{0}\t{1}\t{2}\t{3:.2f}\n'.format(kingdom, phylum, count, percentage))
        outFile.close()

if __name__ == '__main__':
    taxCollection = TaxonomyRecordCollection(sys.argv[1])
    taxCollection.writeKronaSummary(sys.argv[2])
    taxCollection.writeKingdomCounts(sys.argv[3])

