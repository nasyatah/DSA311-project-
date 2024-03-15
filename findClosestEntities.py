import pandas as pd
from oneMapAPIFunctions import findClosestEntity
import tqdm

sch_df = pd.read_csv("./data/2021PrimarySchools.csv")
trans_df = pd.read_csv("./data/MrtLrt.csv")
beach_df = pd.read_csv("./data/beaches.csv").iloc[:,1:]
mall_df = pd.read_csv("./data/malls.csv").iloc[:,1:]
hdbCoordinates = pd.read_csv("./data/hdbCoord.csv").iloc[:,1:]

beach_df.columns = ["name", "lat", "long"]
trans_df.columns = ["name", "type", "lat", "long"]
mall_df.columns = ["name", "lat", "long"]

tqdm.tqdm.pandas()

# closestBeaches = hdbCoordinates[["lat", "long"]].progress_apply(lambda x: findClosestEntity(x.values, beach_df), axis = 1)
# closestBeaches = pd.DataFrame(list(closestBeaches))
# closestBeaches.columns = ["closestBeach", "distToBeach", "timeToBeach", "beachesIn10km"]
# hdbCoordinates.join(closestBeaches).to_csv("./data/closestBeaches.csv")

# closestMalls = hdbCoordinates[["lat", "long"]].progress_apply(lambda x: findClosestEntity(x.values, mall_df), axis = 1)
# closestMalls = pd.DataFrame(list(closestMalls))
# closestMalls.columns = ["closestMall", "distToMall", "timeToMall", "mallsIn10km"]
# hdbCoordinates.join(closestMalls).to_csv("./data/closestMalls.csv")

# closestPrimarySchs = hdbCoordinates[["lat", "long"]].progress_apply(lambda x: findClosestEntity(x.values, sch_df), axis = 1)
# closestPrimarySchs = pd.DataFrame(list(closestPrimarySchs))
# closestPrimarySchs.columns = ["closestPrimarySch", "distToPrimarySch", "timeToPrimarySch", "PrimarySchsIn10km"]
# hdbCoordinates.join(closestPrimarySchs).to_csv("./data/closestPrimarySchs.csv")

closestMRTStations = hdbCoordinates[["lat", "long"]].iloc[0:2].progress_apply(lambda x: findClosestEntity(x.values, trans_df, dist_type = "walk"), axis = 1)
closestMRTStations = pd.DataFrame(list(closestMRTStations))
closestMRTStations.columns = ["closestMRTStation", "distToMRTStation", "timeToMRTStation", "MRTStationsIn10km"]
hdbCoordinates.join(closestMRTStations).to_csv("./data/closestMRTStations.csv")