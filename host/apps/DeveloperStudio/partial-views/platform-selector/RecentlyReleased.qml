import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQml 2.12

import tech.strata.commoncpp 1.0

import "qrc:/js/platform_selection.js" as PlatformSelection

RowLayout {
    Layout.fillWidth: true
    Layout.preferredHeight: 100

    SGSortFilterProxyModel {
        id: sortedModel
        sortEnabled: true
        invokeCustomLessThan: true
        sortAscending: false
        sourceModel: PlatformSelection.platformSelectorModel.platformListStatus === "loaded" ? PlatformSelection.platformSelectorModel : null

        readonly property string timeFormat: "yyyy-MM-ddThh:mm:ss.zzzZ"

        function lessThan(index1, index2) {
            let listing1 = sourceModel.get(index1);
            let listing2 = sourceModel.get(index2);

            let timestamp1 = Date.fromLocaleString(Qt.locale(), listing1.timestamp, timeFormat);
            let timestamp2 = Date.fromLocaleString(Qt.locale(), listing2.timestamp, timeFormat);

            return timestamp1 < timestamp2;
        }
    }

    SGSortFilterProxyModel {
        id: lengthModel
        sourceModel: PlatformSelection.platformSelectorModel.platformListStatus === "loaded" ? sortedModel : null
        invokeCustomFilter: true

        property int topN: 3

        function filterAcceptsRow(index) {
            return index < topN
        }
    }

    Repeater {
        id: mostRecentRepeater
        model: lengthModel

        delegate: ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignHCenter

            Text {
                id: name
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                text: model.verbose_name
            }

            Text {
                id: timestamp
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                text: model.timestamp
            }
        }
    }
}
