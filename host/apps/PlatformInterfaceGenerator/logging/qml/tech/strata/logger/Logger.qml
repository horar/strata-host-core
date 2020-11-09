pragma Singleton

import QtQml 2.8

QtObject {
    id: root
    property LoggingCategory pigCategory: LoggingCategory {
        name: "strata.platformInterfaceGenerator"
    }
}
