import pandas as pd
from oneMapAPIFunctions import getcoordinates
import tqdm

df2023 = pd.read_csv("./data/hdb_resale_price_2023.csv")

addresslist = (df2023.street_name + " " + df2023.block).drop_duplicates()

hdbCoordinates = [getcoordinates(address) for address in tqdm.tqdm(addresslist)]
hdbCoordinates = pd.DataFrame(hdbCoordinates)
hdbCoordinates.columns = ["lat", "long"]
hdbCoordinates["address"] = addresslist.values

missing_address = hdbCoordinates[hdbCoordinates.lat.isna()].address
missing_coord = [getcoordinates(address) for address in tqdm.tqdm(missing_address)]

hdbCoordinates.loc[hdbCoordinates.address.isin(missing_address.values), ["lat", "long"]] = missing_coord
hdbCoordinates.to_csv("./data/hdbCoord.csv")