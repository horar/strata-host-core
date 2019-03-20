## The deployment_script.py takes these arguments!
## deployment_script.py --config myconfigfile.json /absolute_path/my_directory/SEC.000.000 class-id platform-verbose-name

CONFIG_FILE="config.json"
COLLATERAL_LOCATION="/Users/zbgd3f/Documents/deployment2"

python ./deployment_script.py --config $CONFIG_FILE $COLLATERAL_LOCATION/SEC.2018.004 202 USP-PD-2-PORTS
python ./deployment_script.py --config $CONFIG_FILE $COLLATERAL_LOCATION/SEC.2018.042 203 USP-PD-4-PORTS
python ./deployment_script.py --config $CONFIG_FILE $COLLATERAL_LOCATION/SEC.2018.018 201 logic-gate
python ./deployment_script.py --config $CONFIG_FILE $COLLATERAL_LOCATION/SEC.2018.015 208 5A-Switcher
python ./deployment_script.py --config $CONFIG_FILE $COLLATERAL_LOCATION/SEC.2018.016 206 XDFN-LDO
python ./deployment_script.py --config $CONFIG_FILE $COLLATERAL_LOCATION/SEC.2018.017 207 15A-Switcher
