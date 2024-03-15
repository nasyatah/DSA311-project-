import pandas as pd

# Read and process the hdb resale price dataframe

months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
no_of_rooms = {'2 ROOM': 2, '3 ROOM': 3, '4 ROOM': 4, '5 ROOM': 5, 'EXECUTIVE': 5, 'MULTI-GENERATION': 5, '1 ROOM': 1}

def convert_to_years(x):
    if len(x) == 1:
        return int(x[0])
    else:
        return float(x[0]) + float(x[1])/12

df2023 = pd.read_csv("./data/ResaleflatpricesbasedonregistrationdatefromJan2017onwards.csv")
# Filter for 2023
df2023 = df2023[df2023.month.apply(lambda x: x.split("-")[0] == "2023")]
# Convert month to string/categorical variable
df2023.month = df2023.month.apply(lambda x: months[int(x.split("-")[1])-1])
# Convert remaining_lease to numerical years
df2023.remaining_lease = df2023.remaining_lease.str.findall("\d{2}").apply(convert_to_years)
# Calculate remaining_lease using the lease_commence_date for NA values
df2023.remaining_lease = df2023.lease_commence_date + 99 - 2023
# Calculate avg_storey using the storey_range variable
df2023["avg_storey"] = df2023.storey_range.str.findall("\d{2}").apply(lambda x: (int(x[0]) + int(x[1]))/2)
# Input number of rooms for each HDB
df2023["no_of_rooms"] = df2023.flat_type.apply(lambda x: no_of_rooms[x])

df2023.to_csv("./data/hdb_resale_price_2023.csv")