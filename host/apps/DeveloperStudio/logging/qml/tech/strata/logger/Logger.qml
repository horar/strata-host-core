pragma Singleton

import QtQml 2.8

QtObject {
    id: root
    property LoggingCategory devStudioCategory: LoggingCategory {
        name: "strata.devstudio"
    }
    property LoggingCategory devStudioNavigationControlCategory: LoggingCategory {
        name: "strata.devstudio.navigationControl"
    }
    property LoggingCategory devStudioPlatformSelectionCategory: LoggingCategory {
        name: "strata.devstudio.platformSelection"
    }
    property LoggingCategory devStudioPlatformModelCategory: LoggingCategory {
        name: "strata.devstudio.platformModel"
    }
    property LoggingCategory devStudioLoginCategory: LoggingCategory {
        name: "strata.devstudio.login"
    }
    property LoggingCategory devStudioHelpCategory: LoggingCategory {
        name: "strata.devstudio.help"
    }
    property LoggingCategory devStudioFeedbackCategory: LoggingCategory {
        name: "strata.devstudio.feedback"
    }
    property LoggingCategory devStudioCorePlatformInterfaceCategory: LoggingCategory {
        name: "strata.devstudio.platIf.core"
    }
    property LoggingCategory devStudioRestClientCategory: LoggingCategory {
        name: "strata.devstudio.restClient"
    }
}
