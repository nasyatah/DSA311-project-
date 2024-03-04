import pandas as pd
import numpy as np
import requests

'''choosing records where year == 2023 and creating address column which 
is a concatenation of block and street name'''
resale = pd.read_csv("2017-2024_resale_prices.csv")
resale['year'] = resale['month'].str.slice(0, 4)
resale_2023 = resale[resale['year'] == '2023']
price_df = resale_2023
price_df["address"] = price_df["block"] + " " + price_df["street_name"]


'''getcoordinate function takes in an address value and returns the longitude and latitude of the address,
returns None,None if value not found'''
def getcoordinates(address):
    req = requests.get('https://www.onemap.gov.sg/api/common/elastic/search?searchVal='+address+'&returnGeom=Y&getAddrDetails=Y&pageNum=1')
    resultsdict = eval(req.text)
    if len(resultsdict['results'])>0:
        return resultsdict['results'][0]['LATITUDE'], resultsdict['results'][0]['LONGITUDE']
    else:
        return None,None
    
#use the get coordinate function to get coordinate of every address in unique_address_list
unique_address_list = price_df["address"].unique() 
unique_address_list_2 = price_df["address"].unique()[xxx:xxx] #if u want to extract records 1600-1800, change the [xxx:xxx] to [1600:1801]
coord_list = []
for address in unique_address_list_2: 
    coord = getcoordinates(address)
    print(address, coord)
    coord_list.append(coord)


#outputs a text file 
import csv
coord_xxx_to_xxx = coord_list #change xxx accordingly
with open("coord_xxx_to_xxx", mode='w', newline='') as file:
    writer = csv.writer(file)
    for row in coord_xxx_to_xxx: #change xxx accordingly
        writer.writerow(row)