import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQml 2.12

import tech.strata.commoncpp 1.0

import "qrc:/js/platform_selection.js" as PlatformSelection

RowLayout {
    Layout.fillWidth: true
    Layout.preferredHeight: 200

    SGSortFilterProxyModel {
        id: sortedModel
        sortEnabled: true
        invokeCustomLessThan: true
        sortAscending: false
        sourceModel: PlatformSelection.platformSelectorModel

        readonly property string timeFormat: "yyyy-MM-ddThh:mm:ss.zzzZ"

        function lessThan(index1, index2) {
            let listing1 = sourceModel.get(index1);
            let listing2 = sourceModel.get(index2);

            let timestamp1 = Date.fromLocaleString(Qt.locale(), listing1.timestamp, timeFormat);
            let timestamp2 = Date.fromLocaleString(Qt.locale(), listing2.timestamp, timeFormat);

            return timestamp1 < timestamp2;
        }
    }

    Repeater {
        id: mostRecentRepeater
        model: sortedModel

        property int topN: 3

        delegate: ColumnLayout {
            visible: index < mostRecentRepeater.topN
            Layout.preferredWidth: 250
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignHCenter

            Text {
                id: name
                Layout.fillWidth: true
                Layout.preferredHeight: 100
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
                wrapMode: Text.WrapAnywhere
                text: model.timestamp
            }
        }
    }
}
