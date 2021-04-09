pragma Singleton

import QtQml 2.8

QtObject {
    id: root
    property LoggingCategory logviewerCategory: LoggingCategory {
        name: "strata.logviewer"
    }
}
