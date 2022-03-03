/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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
    property LoggingCategory devStudioUtilityCategory: LoggingCategory {
        name: "strata.devstudio.utility"
    }
    property LoggingCategory devStudioRestClientCategory: LoggingCategory {
        name: "strata.devstudio.restClient"
    }
}
