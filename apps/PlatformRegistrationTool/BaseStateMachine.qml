
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
