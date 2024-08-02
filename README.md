# macOS Compatibility Script
This script will check the hardware model ID of the Mac you run it on, then will output the maximum supported OS it is compatible with. For example, if the Mac is compatible with Sonoma, it will output 14.

It is a refactor of [this script that is meant for use in JAMF](https://github.com/macadmins/sofa/blob/main/tool-scripts/macOSCompatibilityCheck-EA.sh) and was built for use as a custom fact in Addigy.

## Output
The output is based on data from [SOFA](https://sofa.macadmins.io/), so the script is dynamic and doesn't need to be updated when new models or new major OS versions come out.

For any supported OS versions, the script will output the numerical version such as `14`. For unsupported OS versions (such as Big Sur, Catalina, etc) it will output `Unsupported`.

## Use Cases
To use as an Addigy Custom Fact, simply create a Custom Fact with a string output and put the script in it.

To use with a more verbose output, change `LOG_MODE` in the script to `true`. This is useful for other methods such as commands and Smart Software.