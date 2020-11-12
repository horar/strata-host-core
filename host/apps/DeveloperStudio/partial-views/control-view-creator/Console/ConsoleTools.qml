import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0

Item {
    ListView {
        model: ["Enable Color"]
        delegate: SGCheckBox {
            id: checkBox
            text: modelData
        }
    }
}
