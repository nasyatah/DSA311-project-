import requests
import json
import pandas as pd

with open("oneMapAPIAuth.json") as auth_file:
    token_header = eval(auth_file.read())

def getcoordinates(address, auth = token_header):
    req = requests.get('https://www.onemap.gov.sg/api/common/elastic/search?searchVal='+ address +'&returnGeom=Y&getAddrDetails=Y&pageNum=1', headers = auth)
    if req.status_code == 200:
        resultsdict = eval(req.text)
        if len(resultsdict['results'])>0:
            return resultsdict['results'][0]['LATITUDE'], resultsdict['results'][0]['LONGITUDE']
        else:
            pass
    else:
        print(req.status_code)


def getTravelDistTime(loc1, loc2, type = "pt", auth = token_header):
    req =  f"https://www.onemap.gov.sg/api/public/routingsvc/route?start={loc1[0]}%2C{loc1[1]}&end={loc2[0]}%2C{loc2[1]}&routeType={type}&date=08-13-2023&time=12%3A00%3A00&mode=TRANSIT&numItineraries=1"
    req = requests.get(req, headers = auth)
    if req.status_code == 200:
        resultsdict = json.loads(req.text)
        if type == "pt":
            itineraries = resultsdict["plan"]["itineraries"]
            if len(itineraries) > 0:
                itinDist = sum([x["distance"] for x in itineraries[0]["legs"]])/1000
                itinDura = itineraries[0]["duration"]/60
        elif (type in ["walk", "drive"]) and (resultsdict["status"] == 0):
            itinDist = resultsdict["route_summary"]["total_distance"]/1000
            itinDura = resultsdict["route_summary"]["total_time"]/60
        else:
            itinDist = None
            itinDura = None
            
        return (itinDist, itinDura)

def findClosestEntity(focus, entity_df, dist_type = "drive", auth_token = token_header, radius = 10):

    try:
        entityDistTime = entity_df[["lat", "long"]].apply(lambda x: getTravelDistTime(focus, x.values, type = dist_type, auth = auth_token), axis = 1)
        entityDistTime = pd.DataFrame(list(entityDistTime))
        minDist = entityDistTime.min().values[0]
        minTime = entityDistTime[entityDistTime[0] == minDist][1].values[0]
        closestEntity = entity_df[entityDistTime[0] == minDist]["name"].values[0]
        no_within_radius = sum(entityDistTime[0] <= radius)
    except:
        return None, None, None, None
    
    return (closestEntity, minDist, minTime, no_within_radius)