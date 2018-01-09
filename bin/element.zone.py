#!/usr/bin/env python3

import csv,sys,math
from collections import OrderedDict
from collections import defaultdict

naStr = '0'
ZoneNum = 50.0

print(sys.argv)

class Vividict(dict):
    def __missing__(self, key):
        value = self[key] = type(self)()
        return value

MethRate = Vividict()
MethRateCnt = 0
with open(sys.argv[1],'rt') as f:
    tsvin = csv.reader(f, delimiter='\t')
    for row in tsvin:
        if row[0].startswith('#'):
            continue
        MethRate[row[0]][int(row[1])] = float(row[9])
        MethRateCnt += 1

CDSdatCnt = 0
CDSdat = defaultdict(set)

with open(sys.argv[2],'rt') as f:
    tsvin = csv.reader(f, delimiter='\t')
    for row in tsvin:
        ZoneLength = 1 + int(row[2]) - int(row[1])
        theKey = '\t'.join(row[0:3])
        CDSdat[theKey].add(row[3])
        CDSdatCnt += 1
print((MethRateCnt,CDSdatCnt,len(MethRate),len(CDSdat)))

with open(sys.argv[3],'wt') as outf:
    for k, v in CDSdat.items():
        v = ','.join(sorted(v))
        (Chrid,pLeft,pRight) = k.split('\t')
        pLeft = int(pLeft)
        pRight = int(pRight)
        #print((k,v,CDSdat[k],Chrid,pLeft,pRight))
        ZoneLen = 1 + pRight - pLeft
        ZoneStep = math.ceil(float(ZoneLen)/ZoneNum)
        ZoneCnt = math.ceil(ZoneLen/ZoneStep)
        ZoneValues = []
        ZoneValueCntV = ZoneCnt
        startPos = pLeft
        while startPos <= pRight:
            endPos = startPos + ZoneStep
            if endPos > pRight: endPos = pRight
            ZoneSum = 0
            ZoneHits = 0
            for p in range(startPos,endPos):
                if p in MethRate[Chrid]:
                    ZoneSum += MethRate[Chrid][p]
                    ZoneHits += 1
            if ZoneHits == 0:
                ZoneValues.append(naStr)
                ZoneValueCntV -= 1
            else:
                ZoneValue1 = float(ZoneSum/ZoneHits)
                ZoneValues.append("%.8f" % ZoneValue1)
            startPos += ZoneStep
        ZoneValues = [v,k,','.join(map(str,(ZoneStep,ZoneCnt,ZoneValueCntV)))] + ZoneValues
        if ZoneValueCntV > 0:
            print('\t'.join(ZoneValues),file=outf,flush=True)
