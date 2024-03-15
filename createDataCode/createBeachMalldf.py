import pandas as pd
import bs4
import re
from oneMapAPIFunctions import getcoordinates
import tqdm

beaches = ["East Coast Park", "Sembawang Park", "West Coast Park", "Pasir Ris Park", "Changi Beach Park", "Punggol Beach", "Palawan Beach", "Siloso Beach", "Tanjong Beach", "Tonjong Rimau Beach", "Ketam Beach", "Ketam Beach", "Lazarus Island", "Saint John's Island", "Coney Island"]
beach_df = pd.DataFrame({"beachName": beaches, "beachCoord": [getcoordinates(beach_name, token_header) for beach_name in beaches]})
beach_df = beach_df.join(pd.DataFrame(beach_df.beachCoord.to_list()).rename({0: "lat", 1: "long"}, axis = 1)).drop("beachCoord", axis = 1)
beach_df = beach_df.dropna().reset_index(drop = True)
beach_df.to_csv("beaches.csv")

shopping_malls = requests.get("https://en.wikipedia.org/wiki/List_of_shopping_malls_in_Singapore")
shopping_malls = bs4.BeautifulSoup(shopping_malls.text)
shopping_malls = shopping_malls.find_all(attrs = "div-col")
shopping_malls = [re.sub("\[\d+\]", "", mall_name.text) for region in shopping_malls for mall_name in region.find_all("li")]

mall_df = pd.DataFrame({"mallName": shopping_malls, "mallCoord": [getcoordinates(mall_name, token_header) for mall_name in tqdm.tqdm(shopping_malls)]})
mall_df = mall_df.join(pd.DataFrame(mall_df.mallCoord.to_list()).rename({0: "lat", 1: "long"}, axis = 1)).drop("mallCoord", axis = 1)
mall_df = mall_df.dropna()
mall_df.to_csv("malls.csv")