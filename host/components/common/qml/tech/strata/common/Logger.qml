pragma Singleton

import QtQml 2.8

QtObject {

    readonly property LoggingCategory pdwCategory: LoggingCategory {
        name: "strata.common.pdw"
    }
}
