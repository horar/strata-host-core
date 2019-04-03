#!/usr/bin/env python2

import json
import sys, os, getopt


try:
    from serial import Serial
    from serial.tools import list_ports, miniterm
except:
    print "pyserial library not found. Please, install it : LINUX/MAC pip install pyserial , WIN python -m pip install pyserial"

    
from timeit import default_timer as timer
from time import sleep


#-------------------------------------------------------------------------------------------------------------------------------


class Verbose:
    
    NONE, ERROR, WARNING, INFO, DEBUG = range(0,5)
    LEVELS = ( NONE, ERROR, WARNING, INFO, DEBUG )
    
    def __init__(self, verboseLevel = 0):
        self.__level = Verbose.NONE
        
        if verboseLevel in Verbose.LEVELS:
            self.__level = verboseLevel
    
    def error(self, info):
        if Verbose.ERROR <= self.__level:
            print "ERR : " , info
                    
    def warning(self, info):
        if Verbose.WARNING <= self.__level:
            print "WRN : " , info

    def info(self, info):
        if Verbose.INFO <= self.__level:
            print "INF : " , info
                                 
    def debug(self, info):
        if Verbose.DEBUG <= self.__level:
            print "DBG : " , info  
            
            
class MeasurementScenarion:
    
    def __init__(self, measurementFile = "", platformSerial = None, verbose = Verbose(Verbose.ERROR)):
        self.__filename = measurementFile
        self.__platformSerial = platformSerial
        self.__verbose = verbose
        self.__scenario = None
        self.__result = {}
    
    
    def process(self):
        
        if False == self.__parse():
            return False
        
        if None == self.__platformSerial:
            return False
        
        self.__result = {}
        
        for transaction in self.__scenario["transactions"]:

            transactionResult = []
            self.__result[transaction["name"]] = transactionResult
            
            delaySec = float(transaction["delay"])

            for iteration in range(0, transaction["iteration_count"]):
                
                sleep(delaySec)
                
                ackRef = transaction["ack"]
                notificationRef = transaction["notification"]

                iterationResult = {} 
                transactionResult.append(iterationResult)
                startTime = timer()
                
                # cmd
                self.__platformSerial.sendCmd(transaction["cmd"])            
                
                # ack
                ackOut = self.__platformSerial.receiveAck()
                                        
                if None != ackOut:
                    iterationResult["ack"] = [ True, timer() - startTime]
                    
                    if ackRef != ackOut:
                        self.__verbose.warning("Transaction " + transaction["name"] + "[" + str(iteration) + "] : message = " + json.dumps(ackOut))
                        iterationResult["ack"][0] = False
                
                    elif ackOut["payload"]["return_value"]:
                        # notify
                        notificationOut = self.__platformSerial.receiveNotification(notificationRef["notification"]["value"])
        
                        if None != notificationOut:
                            iterationResult["notification"] = [ True, timer() - startTime ]
                            
                            if notificationRef != notificationOut:
                                self.__verbose.warning("Transaction " + transaction["name"] + "[" + str(iteration) + "] : message = " + json.dumps(notificationOut))
                                iterationResult["notification"][0] = False
                        
                self.__verbose.info("Transaction " + transaction["name"] + "[" + str(iteration) + "] OK")
                    
        return True
        
    def report(self, rawMeasurement = False):
        
        if rawMeasurement:
            print json.dumps(self.__result, indent=True)
        
        for name, transaction in self.__result.items():
        
            ackTime, ackCount, ackOK, ackERR, = 0, 0, 0, 0
            notificationTime, notificationCount, notificationOK, notificationERR = 0, 0, 0, 0            
            
            for iteration in transaction:

                if iteration.has_key("ack"):            
                    ackTime += iteration["ack"][1]
                    ackCount += 1
                    if iteration["ack"][0]:
                        ackOK += 1
                    else:
                        ackERR += 1

                if iteration.has_key("notification"):
                    notificationTime += iteration["notification"][1]
                    notificationCount += 1
                    if iteration["notification"][0]:
                        notificationOK += 1
                    else:
                        notificationERR += 1
                                             
            ackAvgTime = 0.0
            if ackCount > 0:
                ackAvgTime = ackTime / ackCount
                                 
            notificationAvgTime = 0.0
            if notificationCount > 0:
                notificationAvgTime = notificationTime / notificationCount - ackAvgTime
                            
            print "Transaction : ", name 
            print "Avg. ACK    time : %6f sec, count(iterations/received/correct) : ( %d[100%%]/%d[%4.2f%%]/%d[%4.2f%%])" \
                % ( ackAvgTime, len(transaction), ackCount, 100.0 * ackCount / len(transaction), ackOK, 100.0 * ackOK / len(transaction))
            print "Avg. NOTIFY time : %6f sec, count(iterations/received/correct) : ( %d[100%%]/%d[%4.2f%%]/%d[%4.2f%%])" \
                % (notificationAvgTime, len(transaction), notificationCount, 100.0 * notificationCount / len(transaction), notificationOK,  100.0 * notificationOK / len(transaction))

    def __parse(self, measurementFile = ""):
        if "" == measurementFile:
            measurementFile = self.__filename
            
        try:    
            fd = open(measurementFile)
        except:
            self.__verbose.error("Parsing a file : <" + measurementFile + ">")
            return False
        
        if fd.closed:
            return False
        
        try:
            self.__scenario = json.load(fd)
        except:
            self.__verbose.error("Parsing a file : <" + measurementFile + ">")
            return False
        
        fd.close()
        
        return True


class PlatformSerial:
    
    def __init__(self, serialPort, baudRate, timeoutInSec, verbose = Verbose(Verbose.ERROR)):
        self.__serial = Serial(serialPort, baudRate, timeout = timeoutInSec)
        self.__timeoutInSec = timeoutInSec
        self.__verbose = verbose
 
    def __del__(self):
        self.__serial.close()
        
    def sendCmd(self, message):
        self.__verbose.debug("SEND: " + str(message))
        self.__serial.write(json.dumps(message) + os.linesep)
        self.__serial.flush()
        
    def receiveAck(self):
        return self.__receive("ack")
    
    def receiveNotification(self, notificationName):
        message = self.__receive("notification")
        if None != message and message["notification"].has_key("value") and message["notification"]["value"] == notificationName:
            return message
        
        return None
    
    def __receive(self, messageType):
        timeStop = timer() + self.__timeoutInSec

        while timer() < timeStop:
            try:    
                message = json.loads(self.__serial.readline())
            except:
                continue
            
            if message.has_key(messageType):
                self.__verbose.debug("RECV: " + str(message)) 
                return message
    
        return None
    
    
#-------------------------------------------------------------------------------------------------------------------------------

def help():
    print "psu (platfrom serial utility) usage :"
    print "  psu [s:p:rv:t:] or [scenario=, port=, raw, verbose=, timeout=]' <command>"
    print "  Commands:"
    print "     help         :  print this help"
    print "     ports        :  print all available serial ports"
    print "     terminal     :  open simple serial terminal, mandatory switches: -p"
    print "     measurement  :  do measurement according to a scenario, mandatory switches: -p , optional switches: -s -r -v -t"
    print "  Switches:"
    print "     -s or --scenario :  path + filename of measurement scenario(JSON), default : 'measurement.json'"
    print "     -p or --port     :  serial port that a platform device is connected to"
    print "     -r or --raw      :  report measurement statistic + raw measurement data"
    print "     -v or --verbose  :  verbose level : 0 = NONE, 1 = ERROR, 2 = WARNING, 3 = INFO, 4 = DEBUG, default : 0"
    print "     -t or --timeout  :  timeout for reading form serial port, default : 3 sec"
    print "  Measurement scenario file(JSON):"
    print "     The scenario consists of a few transactions."
    print "     The transaction has a unique name, max. number of iterations and delay in seconds between iterations."
    print "     The each iteration is sequence of 3 messages:"
    print "         -->     cmd     "
    print "         <--     ack     "
    print "         <-- notification"
    print "     Example of file:"
    print "        \"transactions\" : ["                                                                                      
    print "        {"
    print "        \"name\" : \"platformId1\","
    print "        \"iteration_count\" : 10,"
    print "        \"delay\" : 0.01,"
    print "        \"cmd\" : {\"cmd\":\"request_platform_id\"},"
    print "        \"ack\" : {\"ack\":\"request_platform_id\",\"payload\":{\"return_value\":true,\"return_string\":\"command valid\"}},"
    print "        \"notification\" : {\"notification\":{\"value\":\"platform_id\",\"payload\":{...\"}}}"
    print "        },"
    print "        { ... }, ..."
    print "        ]"
    print "     }"
    print " More info : https://ons-sec.atlassian.net/wiki/spaces/SPYG/pages/623968370/Platform+Serial+Utilities+PSU"
    return True

def ports():
    
    ports = list_ports.comports()
    print "Ports:"
    for port in ports:
        print port.device
        
    return True


def terminal(portDevice, baudRate):

    # hack due to miniterm initialization issue : it always reads command line parameters.
    sysArgv = sys.argv
    sys.argv = ['dummy.py']
    miniterm.main(portDevice, baudRate, 1, 1)
    sysArgv = sys.argv
    
    return True
    
        
def measurement(scenarioFile, portDevice, baudRate, timeoutSec, rawMeasurement, verboseLevel):
    
    verbose = Verbose(verboseLevel)
    try:
        platformSerial = PlatformSerial(portDevice, baudRate, timeoutSec, verbose)
    except:
        verbose.error("Serial link initialization")
        return False
    
    measurement = MeasurementScenarion(scenarioFile, platformSerial, verbose)
    if measurement.process():
        measurement.report(rawMeasurement)
        return True
    
    return False
    
    
    
if __name__ == "__main__":
    
    try:
        switches, arguments = getopt.getopt(sys.argv[1:],"s:p:rv:t:",["scenario=", "port=", "raw", "verbose=", "timeout="])
    except getopt.GetoptError:
        help();
        sys.exit(1)
    
    scenarioFile = "measurement.json"
    portDevice = ""
    rawMeasurement = False
    verboseLevel = Verbose.NONE
    timeoutSec = 3      # default value 3 sec
    
    baudRate = 115200   # default value
                    
    for switchName, switchArgument in switches:
        if switchName in ("-s", "--scenario"):
            scenarioFile = switchArgument
            
        elif switchName in ("-p", "--port"):
            portDevice = switchArgument           
             
        elif switchName in ("-r", "--raw"):
            rawMeasurement = True
                                
        elif switchName in ("-v", "--verbose"):
            verboseLevel = int(switchArgument)  
                                           
        elif switchName in ("-t", "--timeout"):
            timeoutSec = float(switchArgument)
    
    success = False
    
    if len(arguments) > 0:
        
        if arguments[0] == "ports":
            success = ports()
            
        elif arguments[0] == "terminal":
            success = terminal(portDevice, baudRate)
            
        elif arguments[0] == "measurement":
            success = measurement(scenarioFile, portDevice, baudRate, timeoutSec, rawMeasurement, verboseLevel)
            
        else:
            success = help()            
    else:
        success = help()
    
    sys.exit(0) if success else sys.exit(1)
    
