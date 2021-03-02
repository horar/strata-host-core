import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
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
