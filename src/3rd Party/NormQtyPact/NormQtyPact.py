########################################################
# Use FEMA P-58_Normative Quantity Estimation Tool, which is an Excel sheet, 
# with Python script.
# 
# Dependancy: 
# pypiwin32, json
########################################################

import os
import csv
from win32com.client import Dispatch
import json
import sys
import argparse


class NormQtyPact:

    # Path of P-58 Normative Quantity Estimation Tool
    pathXls = os.path.abspath(
        "./Resources/FEMA P-58_NormativeQuantityEstimationTool_031818.xlsm")

    NumOfStories = 3
    FloorAreaList = [1,1,1]
    Occupancy1Type = ['APARTMENT','APARTMENT','APARTMENT']
    Occupancy2Type = ['none','none','none']
    Occupancy3Type = ['none','none','none']
    Occupancy1Area = [1,1,1]
    Occupancy2Area = [0,0,0]
    Occupancy3Area = [0,0,0]

    def __init__(self,NumOfStories = 3 ,FloorAreaList = [1,1,1],
        Occupancy1Type = ['APARTMENT','APARTMENT','APARTMENT'],
        Occupancy2Type = ['none','none','none'],
        Occupancy3Type = ['none','none','none'],
        Occupancy1Area = [1,1,1],
        Occupancy2Area = [0,0,0],
        Occupancy3Area = [0,0,0]):
        '''
        Parameters:
        NumOfStories,FloorAreaList (sf), 
        Occupancy1Type, Occupancy2Type, Occupancy3Type,
        Occupancy1Area, Occupancy2Area, Occupancy3Area 

        Returns:
        QtyOfNonstructCom.csv file listing the quantity of non structural components
        '''
        self.NumOfStories = NumOfStories
        self.FloorAreaList = FloorAreaList
        self.Occupancy1Type = Occupancy1Type
        self.Occupancy2Type = Occupancy2Type 
        self.Occupancy3Type = Occupancy3Type 
        self.Occupancy1Area = Occupancy1Area 
        self.Occupancy2Area = Occupancy2Area 
        self.Occupancy3Area = Occupancy3Area 

    # execute the pact excel tool
    def ExecutePactXlsmNormTool(self):
        docApp = Dispatch('Excel.Application')

        try:
            doc = docApp.Workbooks.Open(self.pathXls)
            ws = doc.Worksheets('Normative Quantity Estimate')

            # change worksheet contents
            ws.Range(ws.Cells(10,2),ws.Cells(100,10)).ClearContents()
            for i in range(self.NumOfStories):
                ws.Range('B' + str(10 + self.NumOfStories - i)).value = i + 1
                ws.Range('C' + str(10 + self.NumOfStories - i)).value = i + 1
                ws.Range('D' + str(10 + self.NumOfStories - i)).value = self.FloorAreaList[i]
                ws.Range('E' + str(10 + self.NumOfStories - i)).value = self.Occupancy1Type[i]
                ws.Range('F' + str(10 + self.NumOfStories - i)).value = self.Occupancy1Area[i]
                ws.Range('G' + str(10 + self.NumOfStories - i)).value = self.Occupancy2Type[i]
                ws.Range('H' + str(10 + self.NumOfStories - i)).value = self.Occupancy2Area[i]
                ws.Range('I' + str(10 + self.NumOfStories - i)).value = self.Occupancy3Type[i]
                ws.Range('J' + str(10 + self.NumOfStories - i)).value = self.Occupancy3Area[i]
            ws.Range('B10').value = 'Roof'
            ws.Range('C10').value = self.NumOfStories + 1
            ws.Range('D10').value = 0
            ws.Range('E10').value = 'none'
            ws.Range('F10').value = 1
            ws.Range('G10').value = 'none'
            ws.Range('H10').value = 0
            ws.Range('I10').value = 'none'
            ws.Range('J10').value = 0

            # run Excel macro
            doc.Application.Run('Sheet7.compile_fragility')
            doc.Save()
            print("Excel macro runs successfully...")
        except Exception as e:
            print(e)

        docApp.Application.Quit()

    def Output_PactComponentDirectory(self):

        self.ExecutePactXlsmNormTool()

        headers = ['No.','Component Type','Performance Group Quantity',
            'Quantity Dispersion','Fragility Correlated','Population Model','Demand Parameters',
            'Dir','Floor Num']

        # read the excel file
        docApp = Dispatch('Excel.Application')
        rows = []
        try:
            doc = docApp.Workbooks.Open(self.pathXls, ReadOnly = True)
            ws = doc.Worksheets('Normative Quantity Estimate')
            i_row = 11
            while True:
                i_floor = ws.Cells(i_row,15).value
                if i_floor is None:
                    postag = ws.Cells(i_row,13).value
                    if postag != 'END OF BUILDING SUM INPUT':
                        i_row = i_row + 1
                        continue
                    else:
                        break
                PactNo = ws.Cells(i_row,17).value
                ComponentType = ''
                PerformanceGroupQuantity = ws.Cells(i_row,20).value
                Direction = [1,2]
                if PerformanceGroupQuantity == '--': # nondirectional copmonent
                    PerformanceGroupQuantity = ws.Cells(i_row,21).value 
                    Direction = [3]
                QuantityDispersion = ws.Cells(i_row,26).value
                FragilityCorrelated = 'FALSE'
                PopulationModel = ''
                DemandParameters = ''
                for i_Dir in range(len(Direction)):
                    rows.append([PactNo,ComponentType,PerformanceGroupQuantity,
                        QuantityDispersion,FragilityCorrelated,PopulationModel,DemandParameters,
                        Direction[i_Dir],i_floor])
                i_row = i_row + 1
            doc.Save()
            print("Output successfully...")
        except Exception as e:
            print(e)
        docApp.Application.Quit()
        
        with open('PactComponentDirectory.csv','w',encoding='utf8',newline='') as f :
            writer = csv.writer(f)
            writer.writerow(headers)
            writer.writerows(rows)

    # Generate a .json file lising all nonstructural componets 
    def Output_PelicunComponentDirectory(self):

        self.ExecutePactXlsmNormTool()

        # read the excel file
        docApp = Dispatch('Excel.Application')
        jsondata = {}

        try:
            doc = docApp.Workbooks.Open(self.pathXls, ReadOnly = True)
            ws = doc.Worksheets('Normative Quantity Estimate')
            i_row = 11
            while True:
                i_floor = ws.Cells(i_row,15).value
                if i_floor is None:
                    postag = ws.Cells(i_row,13).value
                    if postag != 'END OF BUILDING SUM INPUT':
                        i_row = i_row + 1
                        continue
                    else:
                        break
                elif isinstance(i_floor,float):
                    i_floor = int(i_floor)
                elif i_floor == 'ALL':
                    i_floor = '1' # Like elevator.
                else: # all
                    pass
                PactNo = ws.Cells(i_row,17).value
                PerformanceGroupQuantity = ws.Cells(i_row,20).value
                Direction = '1, 2'
                if PerformanceGroupQuantity == '--': # nondirectional copmonent
                    PerformanceGroupQuantity = ws.Cells(i_row,21).value 
                    Direction = '3'
                QuantityDispersion = ws.Cells(i_row,26).value
                if QuantityDispersion == 'p90 low':
                    QuantityDispersion = 0.0001
                elif isinstance(QuantityDispersion,str):
                    pass
                else:
                    if QuantityDispersion < 0.0001:
                        QuantityDispersion = 0.0001
                UnitType = ws.Cells(i_row,24).value
                UnitType = UnitType.lower()
                if UnitType == 'lf':
                    UnitType = 'ft'
                elif UnitType == 'sf':
                    UnitType = 'ft2'
                else:
                    pass
                PactUnit = ws.Cells(i_row,19).value
                PactUnit_float = float("".join(list(filter(str.isdigit,PactUnit))))
                if UnitType in ['ft','ea','ft2']:
                    MedianQuantity = PerformanceGroupQuantity * \
                        PactUnit_float
                else:
                    MedianQuantity = PerformanceGroupQuantity
                    UnitType = 'ea'
                
                # add new component iterm
                ComponentContents = {
                    "location": str(i_floor),
                    "direction": Direction,
                    "Theta_0": str(MedianQuantity),
                    "distribution":"lognormal",
                    "cov": str(QuantityDispersion),
                    "unit": UnitType.lower(),
                    "Blocks": str(MedianQuantity / PactUnit_float)
                }
                if jsondata.get(PactNo) is None:
                    jsondata[PactNo] = [ComponentContents]
                else:
                    jsondata[PactNo].append(ComponentContents)
                i_row = i_row + 1
            doc.Save()
            print("Output successfully...")
        except Exception as e:
            print(e)

        # write to a json file
        with open("PelucunComponentDirectory.json", "w") as fp:
            json.dump(jsondata, fp, indent = 4)

        # write to a csv file
        with open('PelucunComponentDirectory.csv','w',encoding='utf-8-sig',newline='') as f :
            writer = csv.writer(f)
            writer.writerow(['ID','Units','Location','Direction','Theta_0','Blocks','Family','Theta_1','Comment'])
            for key in jsondata.keys():
                keyName = '.'.join([key[0], key[1:3], key[3:]]) # C1011.001c -> C.10.11.001c
                for item in jsondata[key]:
                    writer.writerow([keyName, item['unit'], item['location'], item['direction'] if item['direction'] != '3' else '0', item['Theta_0'], item['Blocks']])

        docApp.Application.Quit()


def main(args):
    '''
    Parameters:
        NumOfStories (int): Number of stories. e.g. 3
        FloorAreaList (str): Floor area of each story. e.g. '1,1,1'
        Occupancy1Type (str): 1st Occupancy type of each story. e.g. 'APARTMENT,APARTMENT,APARTMENT'. 
        Occupancy2Type (str): 2nd Occupancy type of each story. e.g. 'none,none,none'
        Occupancy3Type (str): 3rd Occupancy type of each story. e.g. 'none,none,none'
        Occupancy1Area (str): area percentage of 1st Occupancy of each story. e.g. '1,1,1'
        Occupancy2Area (str): area percentage of 2nd Occupancy of each story. e.g. '0,0,0'
        Occupancy3Area (str): area percentage of 3rd Occupancy of each story. e.g. '0,0,0'
    '''

    parser = argparse.ArgumentParser()
    parser.add_argument("--NumOfStories", type=int, default=3)
    parser.add_argument("--FloorAreaList", type=str, default='1,1,1')
    parser.add_argument("--Occupancy1Type", type=str, default='APARTMENT,APARTMENT,APARTMENT')
    parser.add_argument("--Occupancy2Type", type=str, default='none,none,none')
    parser.add_argument("--Occupancy3Type", type=str, default='none,none,none')
    parser.add_argument("--Occupancy1Area", type=str, default='1,1,1')
    parser.add_argument("--Occupancy2Area", type=str, default='0,0,0')
    parser.add_argument("--Occupancy3Area", type=str, default='0,0,0')
    args = parser.parse_args(args)

    NumOfStories = args.NumOfStories
    FloorAreaList = list(map(float,args.FloorAreaList.split(',')))
    Occupancy1Type = args.Occupancy1Type.split(',')
    Occupancy2Type = args.Occupancy2Type.split(',')
    Occupancy3Type = args.Occupancy3Type.split(',')
    Occupancy1Area = list(map(float,args.Occupancy1Area.split(',')))
    Occupancy2Area = list(map(float,args.Occupancy2Area.split(',')))
    Occupancy3Area = list(map(float,args.Occupancy3Area.split(',')))

    # create a instance of NormQtyPact
    obj = NormQtyPact(NumOfStories = NumOfStories,
        FloorAreaList = FloorAreaList,
        Occupancy1Type = Occupancy1Type,
        Occupancy2Type = Occupancy2Type,
        Occupancy3Type = Occupancy3Type,
        Occupancy1Area = Occupancy1Area,
        Occupancy2Area = Occupancy2Area,
        Occupancy3Area = Occupancy3Area)
    obj.Output_PactComponentDirectory()
    obj.Output_PelicunComponentDirectory()

if __name__ == '__main__':
    main(sys.argv[1:])