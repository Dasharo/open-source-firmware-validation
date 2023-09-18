import os
import sys
import xml.etree.ElementTree as ET

platform = sys.argv[1]

with open("test_cases_statuses_daily.csv", "w") as csv_file:
    csv_file.write("Test case,Result\n")
    for file in os.listdir(platform):
        if file.endswith(".xml"):
            tree = ET.parse(os.path.join(platform, file))
            root = tree.getroot()
            for test in root.iter("test"):
                name = test.get("name")
                name = name.replace(",", "")
                result = test[-1].get("status")
                data = name + "," + result + "\n"
                csv_file.write(data)
