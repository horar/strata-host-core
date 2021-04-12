pragma Singleton

import QtQml 2.8

QtObject {
    id: root
    property LoggingCategory wgCategory: LoggingCategory {
        name: "strata.wg"
    }
}
