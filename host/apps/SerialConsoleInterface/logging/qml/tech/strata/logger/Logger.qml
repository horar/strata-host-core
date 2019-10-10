pragma Singleton

import QtQml 2.8

QtObject {
    id: root
    property LoggingCategory sciCategory: LoggingCategory {
        name: "strata.sci"
    }
}
