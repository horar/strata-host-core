import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import Qt.labs.settings 1.0

RowLayout {
    Label {
        text: qsTr("Log level:")
    }

    Loader {
        id: loggerSetupLoader
        sourceComponent: visible ? logLevelComboboxComponent : undefined

        Component {
            id: logLevelComboboxComponent

            ComboBox {
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
}
