pragma Singleton

import QtQml 2.8

QtObject {
    id: root
    property LoggingCategory cdcCategory: LoggingCategory {
        name: "strata.cdc"
    }
}