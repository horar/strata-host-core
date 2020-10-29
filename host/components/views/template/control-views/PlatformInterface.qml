import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.common 1.0


PlatformInterfaceBase {
    id: platformInterface
    apiVersion: 2

    property alias notifications: notifications
    property alias commands: commands

    /******************************************************************
      * NOTIFICATIONS
    ******************************************************************/

    QtObject {
        id: notifications

    }

    /******************************************************************
      * COMMANDS
    ******************************************************************/

    QtObject {
        id: commands
        // @command my_cmd_simple
        // @property io: bool
        // @property dac: double
        property var my_cmd_simple: ({
            "cmd": "my_cmd_simple",
            "payload": {
                "io": true,
                "dac": 0.5
            },
            update: function (io,dac) {
                this.set(io,dac)
                this.send(this)
            },
            set: function (io,dac) {
                this.payload.io = io
                this.payload.dac = dac
            },
            send: function () { platformInterface.send(this) }
        })

        // @command my_cmd_simple_periodic_update
        // @property run_state: bool
        // @property interval: int
        // @property run_count: int
        property var my_cmd_simple_periodic_update: ({
            "cmd": "my_cmd_simple_periodic_update",
            "payload": {
                "run_state": true,
                "interval": 2000,
                "run_count": -1
            },
            update: function (run_state,interval,run_count) {
                this.set(run_state,interval,run_count)
                this.send(this)
            },
            set: function (run_state,interval,run_count) {
                this.payload.run_state = run_state
                this.payload.interval = interval
                this.payload.run_count = run_count
            },
            send: function () { platformInterface.send(this) }
        })

    }
}
