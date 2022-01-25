##
## Copyright (c) 2018-2022 onsemi.
##
## All rights reserved. This software and/or documentation is licensed by onsemi under
## limited terms and conditions. The terms and conditions pertaining to the software and/or
## documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
## Terms and Conditions of Sale, Section 8 Software”).
##

from threading import Thread
import time
import serial

thread_running = True

# configure the serial connections (the parameters differs on the device you are connecting to)
try:
    ser = serial.Serial(
        port='COM5',
        baudrate=115200,
        timeout=1
    )
except PermissionError or serial.serialutil.SerialException:
    ser.close()
    ser.open()
except:
    print("Serial port could not be opened!")
    exit()

# constantly read serial port waiting for commands
def read_serial():
    global thread_running
    while thread_running:
        out = ''
        while ser.inWaiting() > 0:
            out += ser.read(1).decode("utf-8")
        if out.find("get_firmware_info") != -1:
            ser.write('{"ack":"get_firmware_info","payload":{"return_value":true,"return_string":"commandvalid"}}\n'.encode())
            ser.write('{"notification":{"value":"get_firmware_info","payload":{"api_version":"2.0","active":"application","bootloader":{"version":"1.0.0","date":"20180401_123420"},"application":{"version":"1.0.0","date":"20180401_131410"}}}}\n'.encode())
            print("\nget_firmware_info notification sent")
            print(">> ", end='', flush=True)
        elif out.find("request_platform_id") != -1:
            ser.write('{"ack":"request_platform_id","payload":{"return_value":true,"return_string":"commandvalid"}}\n'.encode())
            ser.write('{"notification":{"value":"platform_id","payload":{"name":"MV MDK","controller_type":1,"platform_id":"a7776e2e-17e0-474d-9784-9b24233dde6f","class_id":"a7776e2e-17e0-474d-9784-9b24233dde6f","board_count":1}}}\n'.encode())
            print("\nrequest_platform_id notification sent")
            print(">> ", end='', flush=True)
        elif out.find('{"cmd":"run","payload":{"value":true}') != -1:
            actual_speeds = [0, 500, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000]
            board_temps = [0, 23, 30, 40, 44, 50, 66, 77, 88, 90, 95]
            input_voltages = [61.9, 62.1, 60.8, 60.2, 59.7, 60.3, 61.6, 62.4, 60.5, 60.1, 59.0, 60.5]
            ser.write('{"notification":{"value":"status_log","payload":{"value":"Starting motor with 500 RPM/s acceleration"}}}\n'.encode())
            for _ in range(1):
                for (actual_speed, board_temp, input_voltage) in zip(actual_speeds, board_temps, input_voltages):
                    ser.write(('{"notification":{"value":"actual_speed","payload":{"value":' + str(actual_speed) + '}}}\n').encode())
                    ser.write(('{"notification":{"value":"board_temp","payload":{"value":' + str(board_temp) + '}}}\n').encode())
                    ser.write(('{"notification":{"value":"input_voltage","payload":{"value":' + str(input_voltage) + '}}}\n').encode())
                    time.sleep(0.1)
            ser.write('{"notification":{"value":"status_log","payload":{"value":"Motor running at target speed of 5000 RPM"}}}\n'.encode())
            print(">> ", end='', flush=True)
        elif out.find('{"cmd":"run","payload":{"value":false}') != -1:
            ser.write(('{"notification":{"value":"actual_speed","payload":{"value":0}}}\n').encode())
            ser.write(('{"notification":{"value":"board_temp","payload":{"value":23}}}\n').encode())
            ser.write(('{"notification":{"value":"input_voltage","payload":{"value":60}}}\n').encode())
            ser.write('{"notification":{"value":"status_log","payload":{"value":"Motor stopped"}}}\n'.encode())
        elif out.find('control_props') != -1:
            ser.write('{"notification":{"value":"status_log","payload":{"value":"User interface requested control and parameter values."}}}\n'.encode())
            demo_config()
        elif out != '':
            print("\ncommand: " + out, end='')
            print(">> ", end='', flush=True)

# wait for notification
def take_input():
    global thread_running
    while 1:
        notification = input(">> ")
        if notification == 'exit':
            thread_running = False
            return
        elif (notification == 'demo_config'):
            demo_config()
        elif (notification == 'state_0'):
            ser.write('{"notification":{"value":"status_log","payload":{"value":"Enable all controls to test control properties."}}}\n'.encode())
            ser.write('{"notification":{"value":"toggle","payload":{"states":[0]}}}\n'.encode())
            ser.write('{"notification":{"value":"slider","payload":{"states":[0]}}}\n'.encode())
            ser.write('{"notification":{"value":"infobox_integer","payload":{"states":[0]}}}\n'.encode())
            ser.write('{"notification":{"value":"infobox_double","payload":{"states":[0]}}}\n'.encode())
            ser.write('{"notification":{"value":"infobox_string","payload":{"states":[0]}}}\n'.encode())
            ser.write('{"notification":{"value":"combobox","payload":{"states":[0]}}}\n'.encode())
            ser.write('{"notification":{"value":"target_speed","payload":{"states":[0]}}}\n'.encode())
            ser.write('{"notification":{"value":"acceleration","payload":{"states":[0]}}}\n'.encode())
            ser.write('{"notification":{"value":"run","payload":{"states":[0]}}}\n'.encode())
            ser.write('{"notification":{"value":"brake","payload":{"states":[0]}}}\n'.encode())
            ser.write('{"notification":{"value":"direction","payload":{"states":[0]}}}\n'.encode())
        elif (notification == 'state_1'):
            ser.write('{"notification":{"value":"status_log","payload":{"value":"Disable all controls to test control properties."}}}\n'.encode())
            ser.write('{"notification":{"value":"toggle","payload":{"states":[1]}}}\n'.encode())
            ser.write('{"notification":{"value":"slider","payload":{"states":[1]}}}\n'.encode())
            ser.write('{"notification":{"value":"infobox_integer","payload":{"states":[1]}}}\n'.encode())
            ser.write('{"notification":{"value":"infobox_double","payload":{"states":[1]}}}\n'.encode())
            ser.write('{"notification":{"value":"infobox_string","payload":{"states":[1]}}}\n'.encode())
            ser.write('{"notification":{"value":"combobox","payload":{"states":[1]}}}\n'.encode())
            ser.write('{"notification":{"value":"target_speed","payload":{"states":[1]}}}\n'.encode())
            ser.write('{"notification":{"value":"acceleration","payload":{"states":[1]}}}\n'.encode())
            ser.write('{"notification":{"value":"run","payload":{"states":[1]}}}\n'.encode())
            ser.write('{"notification":{"value":"brake","payload":{"states":[1]}}}\n'.encode())
            ser.write('{"notification":{"value":"direction","payload":{"states":[1]}}}\n'.encode())
        elif (notification == 'state_2'):
            ser.write('{"notification":{"value":"status_log","payload":{"value":"Disable and gray all controls to test control properties."}}}\n'.encode())
            ser.write('{"notification":{"value":"toggle","payload":{"states":[2]}}}\n'.encode())
            ser.write('{"notification":{"value":"slider","payload":{"states":[2]}}}\n'.encode())
            ser.write('{"notification":{"value":"infobox_integer","payload":{"states":[2]}}}\n'.encode())
            ser.write('{"notification":{"value":"infobox_double","payload":{"states":[2]}}}\n'.encode())
            ser.write('{"notification":{"value":"infobox_string","payload":{"states":[2]}}}\n'.encode())
            ser.write('{"notification":{"value":"combobox","payload":{"states":[2]}}}\n'.encode())
            ser.write('{"notification":{"value":"target_speed","payload":{"states":[2]}}}\n'.encode())
            ser.write('{"notification":{"value":"acceleration","payload":{"states":[2]}}}\n'.encode())
            ser.write('{"notification":{"value":"run","payload":{"states":[2]}}}\n'.encode())
            ser.write('{"notification":{"value":"brake","payload":{"states":[2]}}}\n'.encode())
            ser.write('{"notification":{"value":"direction","payload":{"states":[2]}}}\n'.encode())
        else:
            ser.write((notification + '\n').encode())

def demo_config():
    # time.sleep(0.01) added because UI can't handle the notifications that fast I guess, Strata crashes
    # basic view
    ser.write('{"notification":{"value":"status_log","payload":{"value":"Configuring user interface configured from firmware..."}}}\n'.encode())
    time.sleep(0.01)
    ser.write('{"notification":{"value":"title","payload":{"caption":"Motor Template Title"}}}\n'.encode())
    time.sleep(0.01)
    ser.write('{"notification":{"value":"subtitle","payload":{"caption":"Motor Template Subtitle"}}}\n'.encode())
    time.sleep(0.01)
    ser.write('{"notification":{"value":"actual_speed","payload":{"caption":"Actual Speed","scales":[10000,0,1000],"states":[1],"value":0.0,"values":[],"unit":"RPM"}}}\n'.encode())
    time.sleep(0.01)
    ser.write('{"notification":{"value":"target_speed","payload":{"caption":"Target Speed","scales":[10000,0,10],"states":[0],"value":500,"values":[],"unit":"RPM"}}}\n'.encode())
    time.sleep(0.01)
    ser.write('{"notification":{"value":"acceleration","payload":{"caption":"Acceleration","scales":[1000,0,10],"states":[0],"value":100,"values":[],"unit":"RPM/s"}}}\n'.encode())
    time.sleep(0.01)
    ser.write('{"notification":{"value":"run","payload":{"caption":"Run","scales":[],"states":[0],"value":false,"values":[],"unit":""}}}\n'.encode())
    time.sleep(0.01)
    ser.write('{"notification":{"value":"brake","payload":{"caption":"Brake","scales":[],"states":[0],"value":false,"values":[],"unit":""}}}\n'.encode())
    time.sleep(0.01)
    ser.write('{"notification":{"value":"direction","payload":{"caption":"Direction","scales":[],"states":[0],"value":true,"values":[],"unit":""}}}\n'.encode())
    time.sleep(0.01)
    ser.write('{"notification":{"value":"board_temp","payload":{"caption":"MOSFET Temp","scales":[140,0,10],"states":[1],"value":0.0,"values":[],"unit":"C"}}}\n'.encode())
    time.sleep(0.01)
    ser.write('{"notification":{"value":"input_voltage","payload":{"caption":"Input Voltage","scales":[1000,0,100],"states":[1],"value":0.0,"values":[],"unit":"V"}}}\n'.encode())
    time.sleep(0.01)
    ser.write('{"notification":{"value":"warning_1","payload":{"caption":"OCP","scales":[],"states":[1],"value":false,"values":[],"unit":""}}}\n'.encode())
    time.sleep(0.01)
    ser.write('{"notification":{"value":"warning_2","payload":{"caption":"OTP","scales":[],"states":[1],"value":false,"values":[],"unit":""}}}\n'.encode())
    time.sleep(0.01)
    ser.write('{"notification":{"value":"warning_3","payload":{"caption":"OVP","scales":[],"states":[1],"value":false,"values":[],"unit":""}}}\n'.encode())
    time.sleep(0.01)
    # advanced view
    ser.write('{"notification":{"value":"toggle","payload":{"caption":"Toggle Test","scales":[],"states":[0],"value":false,"values":[],"unit":""}}}\n'.encode())
    time.sleep(0.01)
    ser.write('{"notification":{"value":"slider","payload":{"caption":"Slider Test","scales":[100,0,1],"states":[0],"value":59,"values":[],"unit":"Unit Test"}}}\n'.encode())
    time.sleep(0.01)
    ser.write('{"notification":{"value":"infobox_integer","payload":{"caption":"InfoBox Integer Test","scales":[],"states":[0],"value":99,"values":[],"unit":"Unit Test"}}}\n'.encode())
    time.sleep(0.01)
    ser.write('{"notification":{"value":"infobox_double","payload":{"caption":"InfoBox Double Test","scales":[],"states":[0],"value":99.99,"values":[],"unit":"Unit Test"}}}\n'.encode())
    time.sleep(0.01)
    ser.write('{"notification":{"value":"infobox_string","payload":{"caption":"InfoBox String Test","scales":[],"states":[0],"value":"Fail","values":[],"unit":"Unit Test"}}}\n'.encode())
    time.sleep(0.01)
    # send values before setting value or value will coerce to lowest index of current values
    ser.write('{"notification":{"value":"combobox","payload":{"values":["Item 4","Item 5","Item 6"]}}}\n'.encode())
    time.sleep(0.01)
    ser.write('{"notification":{"value":"combobox","payload":{"caption":"ComboBox Test","scales":[],"states":[0],"value":2,"unit":""}}}\n'.encode())
    time.sleep(0.01)
    ser.write('{"notification":{"value":"advanced_view_tab","payload":{"value":true}}}\n'.encode())
    time.sleep(0.01)
    ser.write('{"notification":{"value":"status_log","payload":{"value":"Done!"}}}\n'.encode())
if __name__ == '__main__':
    t1 = Thread(target=read_serial)
    t2 = Thread(target=take_input)

    t1.start()
    t2.start()

    print("Open Strata or SCI to start platform detection...")

    t2.join() # waits until user type
    thread_running = False
    ser.close()
    exit()