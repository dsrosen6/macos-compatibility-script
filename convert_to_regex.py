import re

# I use this python script to convert a list pulled from EveryMac.com into a Regex pattern...since I have no idea how to build a regex pattern
list_to_convert = """
iMac19,2
iMac19,1
iMac20,1
iMac20,2
iMac21,2
iMac21,1
Mac15,4
Mac15,5
iMacPro1,1
Macmini8,1
Macmini9,1
Mac14,3
Mac14,12
MacPro7,1
Mac14,8
Mac13,1
Mac13,2
Mac14,13
Mac14,14
MacBookAir9,1
MacBookAir10,1
Mac14,2
Mac14,15
Mac15,12
Mac15,13
MacBookPro15,2
MacBookPro15,1
MacBookPro15,3
MacBookPro15,4
MacBookPro16,1
MacBookPro16,3
MacBookPro16,2
MacBookPro16,4
MacBookPro17,1
MacBookPro18,3
MacBookPro18,4
MacBookPro18,1
MacBookPro18,2
Mac14,7
Mac14,9
Mac14,5
Mac14,10
Mac14,6
Mac15,3
Mac15,6
Mac15,10
Mac15,8
Mac15,7
Mac15,11
Mac15,9
"""

# Convert the list to a regex
regex = re.compile(r"\b(" + "|".join(list_to_convert.split()) + r")\b")

# Print the regex in bash format
print(regex.pattern)