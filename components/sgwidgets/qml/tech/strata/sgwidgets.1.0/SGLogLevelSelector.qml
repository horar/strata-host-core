/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.12
import Qt.labs.settings 1.0
import tech.strata.sgwidgets 1.0 as SGWidgets

Loader {
    id: loggerSetupLoader
    sourceComponent: visible ? logLevelComboboxComponent : undefined

    Component {
        id: logLevelComboboxComponent

        SGWidgets.SGComboBox {
            model: ["debug", "info", "warning", "error", "critical", "off"]

            onActivated: {
                if (logLevelSettings.level !== textAt(currentIndex)) {
                    logLevelSettings.level = textAt(currentIndex)
                }
            }

            Component.onCompleted: {
                currentIndex = find(logLevelSettings.level)
            }

            Settings {
                id: logLevelSettings

                category: "log"

                property string level: "debug"
            }
        }
    }
}
