#!/bin/bash

# Hardcoded Mac Model Identifier
mac_model=$(/usr/sbin/sysctl -n hw.model)

##################################################
# Define Regex Strings to exclude Mac Models that *do not support* each OS Version
not_elcapitan_or_older_regex="^((MacPro|Macmini|MacBookPro)[1-2],[0-9]|iMac[1-6],[0-9]|MacBook[1-4],[0-9]|MacBookAir1,[0-9])$"
not_highsierra_regex="^(MacPro[1-4],[0-9]|iMac[1-9],[0-9]|Macmini[1-3],[0-9]|(MacBook|MacBookPro)[1-5],[0-9]|MacBookAir[1-2],[0-9])$"
not_mojave_regex="^(MacPro[1-4],[0-9]|iMac([1-9]|1[0-2]),[0-9]|Macmini[1-5],[0-9]|MacBook[1-7],[0-9]|MacBookAir[1-4],[0-9]|MacBookPro[1-8],[0-9])$"
not_catalina_regex="^(MacPro[1-5],[0-9]|iMac([1-9]|1[0-2]),[0-9]|Macmini[1-5],[0-9]|MacBook[1-7],[0-9]|MacBookAir[1-4],[0-9]|MacBookPro[1-8],[0-9])$"
not_bigsur_regex="^(MacPro[1-5],[0-9]|iMac((([1-9]|1[0-3]),[0-9])|14,[0-3])|Macmini[1-6],[0-9]|MacBook[1-7],[0-9]|MacBookAir[1-5],[0-9]|MacBookPro([1-9]|10),[0-9])$"
not_monterey_regex="^(MacPro[1-5],[0-9]|iMac([1-9]|1[0-5]),[0-9]|(Macmini|MacBookAir)[1-6],[0-9]|MacBook[1-8],[0-9]|MacBookPro(([1-9]|10),[0-9]|11,[0-3]))$"
not_ventura_regex="^(MacPro[1-6],[0-9]|iMac([1-9]|1[0-7]),[0-9]|(Macmini|MacBookAir)[1-7],[0-9]|MacBook[1-9],[0-9]|MacBookPro([1-9]|1[0-3]),[0-9])$"
not_sonoma_regex="^(MacPro[1-6],[0-9]|iMac([1-9]|1[0-8]),[0-9]|(Macmini|MacBookAir)[1-7],[0-9]|MacBook[0-9,]+|MacBookPro([1-9]|1[0-4]),[0-9])$"

##################################################
# Setup Function

model_check() {
    # $1 = Mac Model Identifier
    local model="${1}"

    if [[ $model =~ $not_elcapitan_or_older_regex || $model =~ ^Xserve.*$ ]]; then
        echo "<10.11"
        exit 0
    elif [[ $model =~ $not_highsierra_regex ]]; then
        echo "10.12"
    elif [[ $model =~ $not_mojave_regex ]]; then
        echo "10.13"
    elif [[ $model =~ $not_catalina_regex ]]; then
        echo "10.14"
    elif [[ $model =~ $not_bigsur_regex ]]; then
        echo "10.15"
    elif [[ $model =~ $not_monterey_regex ]]; then
        echo "11"
    elif [[ $model =~ $not_ventura_regex ]]; then
        echo "12"
    elif [[ $model =~ $not_sonoma_regex ]]; then
        echo "13"
    else
        echo "14"
    fi
}

##################################################
# Main Logic

# Check for compatibility based on the hardcoded Mac Model
model_result=$( model_check "${mac_model}" )
echo "$model_result"
exit 0