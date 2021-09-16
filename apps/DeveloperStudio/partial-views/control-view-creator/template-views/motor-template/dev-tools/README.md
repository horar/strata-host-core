# How to Test Template with COM Port Loop Back
The `platform.py` can be used to fake a COM port connection to Strata as if a physical platform was connected. This allows easy testing of the UI: send platform detection commmands automatically, send bulk notifications to configure the UI elements/fake a motor spinning, or sending custom notifications to the UI from the script.

## Requirements
* Python 3 (was not tested with Python 2)
* COM Port Loop Back Tool
    * com0com, free but a pain to use: http://com0com.sourceforge.net/
    * Virtual Serial Port Driver, free week trial then $140, but is very easy to use: https://www.eltima.com/products/vspdxp/

## Setup
1. Close all Strata applications, including SCI
2. Setup COM loop back tool between two COM ports
3. Modify COM port number in `platform.py` to one of the COM ports setup in step 2, i.e. `port='COM5'`
4. Optionally modify the class_id in the `request_platform_id` section of `platform.py` to your own class_id. This is not required if using CVC as you can which platform you want to use inside CVC.
5. Run the python script `py -3 platform.py`
6. Open Strata
7. Strata should detect the looped COM port as a platform
8. Use the python terminal to see activity on the COM port