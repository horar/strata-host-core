pragma Singleton

import QtQml 2.8

QtObject {
    id: root
    property LoggingCategory prtCategory: LoggingCategory {
        name: "strata.prt"
    }
}
