/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */

import QtQml.StateMachine 1.12 as DSM

/* This component is to share functionality between various mode state machines */

DSM.StateMachine {

    function resolveJLinkInfoStatus(outputInfo) {
        var status = "J-Link\n"
        if (outputInfo.hasOwnProperty("lib_version")
                && outputInfo.hasOwnProperty("lib_date")) {
            status += "host library: " + stateWaitForJLink.outputInfo["lib_version"]
            status += " compiled " + stateWaitForJLink.outputInfo["lib_date"] + "\n"
        }

        if (outputInfo.hasOwnProperty("emulator_fw_version")
                && outputInfo.hasOwnProperty("emulator_fw_date")) {
            status += "emulator firmware: " + outputInfo["emulator_fw_version"]
            status += " compiled " + outputInfo["emulator_fw_date"]
        }

        return status
    }
}
