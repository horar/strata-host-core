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

        // @notification: my_cmd_simple_periodic
        // @property adc_read: double
        // @property io_read: bool
        property QtObject my_cmd_simple_periodic: QtObject {
            property double adc_read: 0.0
            property bool io_read: false
        }

        // @notification: my_cmd_complex_periodic
        // @property bool_array: var
        // @property bool_array_rval: var
        // @property bool_vector: var
        // @property float_array_3dec: var
        // @property float_array_rval_4dec: var
        // @property float_vector_5dec: var
        // @property int_array: var
        // @property int_array_rval: var
        // @property int_vector: var
        // @property single_bool: bool
        // @property single_bool_rval: bool
        // @property single_float_1dec: double
        // @property single_float_rval_2dec: double
        // @property single_int: int
        // @property single_int_rval: int
        // @property single_string: string
        // @property string_array: var
        // @property string_array_rval: var
        // @property string_literal: string
        // @property string_vector: var
        property QtObject my_cmd_complex_periodic: QtObject {
            property bool single_bool: false
            property bool single_bool_rval: false
            property double single_float_1dec: 0.0
            property double single_float_rval_2dec: 0.0
            property int single_int: 0
            property int single_int_rval: 0
            property string single_string: ""
            property string string_literal: ""

            // @property bool_array_0: bool
            // @property bool_array_1: bool
            // @property bool_array_2: bool
            property QtObject bool_array: QtObject {
                property bool bool_array_0: false
                property bool bool_array_1: false
                property bool bool_array_2: false
            }

            // @property bool_array_rval_0: bool
            // @property bool_array_rval_1: bool
            // @property bool_array_rval_2: bool
            property QtObject bool_array_rval: QtObject {
                property bool bool_array_rval_0: false
                property bool bool_array_rval_1: false
                property bool bool_array_rval_2: false
            }

            // @property bool_vector_0: bool
            // @property bool_vector_1: bool
            // @property bool_vector_2: bool
            property QtObject bool_vector: QtObject {
                property bool bool_vector_0: false
                property bool bool_vector_1: false
                property bool bool_vector_2: false
            }

            // @property float_array_3dec_0: double
            // @property float_array_3dec_1: double
            // @property float_array_3dec_2: double
            property QtObject float_array_3dec: QtObject {
                property double float_array_3dec_0: 0.0
                property double float_array_3dec_1: 0.0
                property double float_array_3dec_2: 0.0
            }

            // @property float_array_rval_4dec_0: double
            // @property float_array_rval_4dec_1: double
            // @property float_array_rval_4dec_2: double
            property QtObject float_array_rval_4dec: QtObject {
                property double float_array_rval_4dec_0: 0.0
                property double float_array_rval_4dec_1: 0.0
                property double float_array_rval_4dec_2: 0.0
            }

            // @property float_vector_5dec_0: double
            // @property float_vector_5dec_1: double
            // @property float_vector_5dec_2: double
            property QtObject float_vector_5dec: QtObject {
                property double float_vector_5dec_0: 0.0
                property double float_vector_5dec_1: 0.0
                property double float_vector_5dec_2: 0.0
            }

            // @property int_array_0: int
            // @property int_array_1: int
            // @property int_array_2: int
            property QtObject int_array: QtObject {
                property int int_array_0: 0
                property int int_array_1: 0
                property int int_array_2: 0
            }

            // @property int_array_rval_0: int
            // @property int_array_rval_1: int
            // @property int_array_rval_2: int
            // @property int_array_rval_3: int
            // @property int_array_rval_4: int
            property QtObject int_array_rval: QtObject {
                property int int_array_rval_0: 0
                property int int_array_rval_1: 0
                property int int_array_rval_2: 0
                property int int_array_rval_3: 0
                property int int_array_rval_4: 0
            }

            // @property int_vector_0: int
            // @property int_vector_1: int
            // @property int_vector_2: int
            property QtObject int_vector: QtObject {
                property int int_vector_0: 0
                property int int_vector_1: 0
                property int int_vector_2: 0
            }

            // @property string_array_0: string
            // @property string_array_1: string
            // @property string_array_2: string
            property QtObject string_array: QtObject {
                property string string_array_0: ""
                property string string_array_1: ""
                property string string_array_2: ""
            }

            // @property string_array_rval_0: string
            // @property string_array_rval_1: string
            // @property string_array_rval_2: string
            property QtObject string_array_rval: QtObject {
                property string string_array_rval_0: ""
                property string string_array_rval_1: ""
                property string string_array_rval_2: ""
            }

            // @property string_vector_0: string
            // @property string_vector_1: string
            // @property string_vector_2: string
            property QtObject string_vector: QtObject {
                property string string_vector_0: ""
                property string string_vector_1: ""
                property string string_vector_2: ""
            }
        }

    }

    /******************************************************************
      * COMMANDS
    ******************************************************************/

    QtObject {
        id: commands
        // @command my_cmd_simple
        // @property dac: double
        // @property io: bool
        property var my_cmd_simple: ({
            "cmd": "my_cmd_simple",
            "payload": {
                "dac": 0.0,
                "io": false
            },
            update: function (dac,io) {
                this.set(dac,io)
                this.send(this)
            },
            set: function (dac,io) {
                this.payload.dac = dac
                this.payload.io = io
            },
            send: function () { platformInterface.send(this) }
        })

        // @command my_cmd_simple_periodic_update
        // @property interval: int
        // @property run_count: int
        // @property run_state: bool
        property var my_cmd_simple_periodic_update: ({
            "cmd": "my_cmd_simple_periodic_update",
            "payload": {
                "interval": 0,
                "run_count": 0,
                "run_state": false
            },
            update: function (interval,run_count,run_state) {
                this.set(interval,run_count,run_state)
                this.send(this)
            },
            set: function (interval,run_count,run_state) {
                this.payload.interval = interval
                this.payload.run_count = run_count
                this.payload.run_state = run_state
            },
            send: function () { platformInterface.send(this) }
        })

        // @command my_cmd_complex
        // @property my_bool: bool
        // @property my_bools: list of size 2
        // @property my_float: double
        // @property my_floats: list of size 2
        // @property my_int: int
        // @property my_ints: list of size 2
        // @property my_string: string
        // @property my_strings: list of size 2
        property var my_cmd_complex: ({
            "cmd": "my_cmd_complex",
            "payload": {
                "my_bool": false,
                "my_bools": [false, false],
                "my_float": 0.0,
                "my_floats": [0.0, 0.0],
                "my_int": 0,
                "my_ints": [0, 0],
                "my_string": "",
                "my_strings": ["", ""]
            },
            update: function (my_bool,my_bools,my_float,my_floats,my_int,my_ints,my_string,my_strings) {
                this.set(my_bool,my_bools,my_float,my_floats,my_int,my_ints,my_string,my_strings)
                this.send(this)
            },
            set: function (my_bool,my_bools,my_float,my_floats,my_int,my_ints,my_string,my_strings) {
                this.payload.my_bool = my_bool
                this.payload.my_bools = my_bools
                this.payload.my_float = my_float
                this.payload.my_floats = my_floats
                this.payload.my_int = my_int
                this.payload.my_ints = my_ints
                this.payload.my_string = my_string
                this.payload.my_strings = my_strings
            },
            send: function () { platformInterface.send(this) }
        })

        // @command my_cmd_i2c
        property var my_cmd_i2c: ({
            "cmd": "my_cmd_i2c",
            update: function () {
                this.send(this)
            },
            send: function () { platformInterface.send(this) }
        })

    }
}
