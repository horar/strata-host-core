## The deployment_script.py takes these arguments!
## deployment_script.py --config myconfigfile.json /absolute_path/my_directory/STR-USBC-4PORT-200W-EVK class-id platform-verbose-name

CONFIG_FILE="config.json"
COLLATERAL_LOCATION="/Users/zbgd3f/Documents/deployment2"

python ./deployment_script.py --config $CONFIG_FILE $COLLATERAL_LOCATION/STR-USBC-4PORT-200W-EVK 203 USP-PD-4-PORTS
python ./deployment_script.py --config $CONFIG_FILE $COLLATERAL_LOCATION/STR-NCV6356-EVK 208 NCV6356-5A-AOT-Step-Down-Converter
python ./deployment_script.py --config $CONFIG_FILE $COLLATERAL_LOCATION/STR-NCP110-EVK 210 NCP110-200mA-LDO
python ./deployment_script.py --config $CONFIG_FILE $COLLATERAL_LOCATION/STR-NCP115-EVK 211 NCP115-300mA-LDO
python ./deployment_script.py --config $CONFIG_FILE $COLLATERAL_LOCATION/STR-NCV8170-NCP170-EVK 212 NCV8170-NCP170-150mA-LDO
python ./deployment_script.py --config $CONFIG_FILE $COLLATERAL_LOCATION/STR-NCV8163-NCP163-EVK 214 NCV8163-NCP163-250mA-LDO
python ./deployment_script.py --config $CONFIG_FILE $COLLATERAL_LOCATION/STR-NCP171-EVK 217 NCP171-80mA-Dual-Power-Mode-LDO
python ./deployment_script.py --config $CONFIG_FILE $COLLATERAL_LOCATION/STR-NCP3232N-EVK 219 23V-INPUT-15A-SWITCHER
python ./deployment_script.py --config $CONFIG_FILE $COLLATERAL_LOCATION/STR-NCP3235-EVK 207 23V-INPUT-15A-SWITCHER
python ./deployment_script.py --config $CONFIG_FILE $COLLATERAL_LOCATION/STR-NCV6356-EVK 208 NCV6356-5A-AOT-Step-Down-Converter
python ./deployment_script.py --config $CONFIG_FILE $COLLATERAL_LOCATION/STR-NCP3231-EVK 220 18V-INPUT-25A-SWITCHER