agepopdf = pd.read_excel("PopData.xls", header = 5, sheet_name = "AgeGroupPop").iloc[:, 1:].dropna(subset = ["Subzone"])
agepopdf["Planning Area"] = agepopdf["Planning Area"].ffill()
agepopdf = agepopdf[~(agepopdf.Subzone == "Total") & ~(agepopdf.Subzone == "Subzone")]
agepopdf = agepopdf.drop("Total", axis = 1)
agepopdf.columns = ["area", "subarea", "2yrPop", "7yrPop", "12yrPop", "17yrPop", "22yrPop", "27yrPop", "32yrPop", "37yrPop", "42yrPop", "47yrPop", "52yrPop", "57yrPop", "62yrPop", "67yrPop", "72yrPop", "77yrPop", "82yrPop", "90yrPop"]
ethnicpopdf = pd.read_excel("PopData.xls", header = 5, sheet_name = "EthnicityPop").iloc[:, 1:].dropna(subset = ["Subzone"])
ethnicpopdf["Planning Area"] = ethnicpopdf["Planning Area"].ffill()
ethnicpopdf = ethnicpopdf[~(ethnicpopdf.Subzone == "Total") & ~(ethnicpopdf.Subzone == "Subzone")]
ethnicpopdf = ethnicpopdf.drop("Total", axis = 1)
ethnicpopdf = ethnicpopdf[["Planning Area", "Subzone", "Chinese", "Malays", "Indians", "Others"]]
ethnicpopdf.columns = ["area", "subarea", "chinesePop", "malayPop", "indianPop", "otherPop"]

inddf = pd.read_excel("IncomeData.xls", sheet_name = "IndByArea")
occdf = pd.read_excel("IncomeData.xls", sheet_name = "OccByArea")
incomedf = pd.read_excel("IncomeData.xls", sheet_name = "MonthlyIncomeByArea")
transportdf = pd.read_excel("IncomeData.xls", sheet_name = "TransportByArea")
traveltimedf = pd.read_excel("IncomeData.xls", sheet_name = "AvgTravelTimeByArea")