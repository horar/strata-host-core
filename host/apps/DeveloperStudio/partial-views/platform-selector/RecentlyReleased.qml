import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0

import tech.strata.commoncpp 1.0
import tech.strata.theme 1.0
import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0

import "qrc:/js/platform_selection.js" as PlatformSelection
import "qrc:/js/platform_filters.js" as Filters

Rectangle {
    id: recentlyReleased
    implicitHeight: recentRow.implicitHeight + 40
    implicitWidth: recentRow.implicitWidth + 40
    color: Theme.strataGreen
    radius: 10
    visible: lengthModel.count > 0

    RowLayout {
        id: recentRow
        anchors {
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
        }
        width: parent.width - 40
        spacing: 30

        SGSortFilterProxyModel {
            id: sortedModel
            sortEnabled: true
            invokeCustomLessThan: true
            sortAscending: false
            sourceModel: PlatformSelection.platformSelectorModel.platformListStatus === "loaded" ? PlatformSelection.platformSelectorModel : null
            invokeCustomFilter: true

            readonly property string timeFormat: "yyyy-MM-ddThh:mm:ss.zzzZ"

            function lessThan(index1, index2) {
                let listing1 = sourceModel.get(index1);
                let listing2 = sourceModel.get(index2);

                let timestamp1 = Date.fromLocaleString(Qt.locale(), listing1.timestamp, timeFormat);
                let timestamp2 = Date.fromLocaleString(Qt.locale(), listing2.timestamp, timeFormat);

                return timestamp1 < timestamp2;
            }

            function filterAcceptsRow(index) {
                // ensure visible platforms are not 'unlisted'
                // ensure visible platforms are not "coming soon" (match logic in PlatformImage.qml)
                let item = sourceModel.get(index)
                return item.available.unlisted === false && (item.available.order || item.available.documents)
            }
        }

        SGSortFilterProxyModel {
            id: lengthModel
            sourceModel: PlatformSelection.platformSelectorModel.platformListStatus === "loaded" ? sortedModel : null
            invokeCustomFilter: true

            property int topN: 3

            function filterAcceptsRow(index) {
                // take the top N (3) sorted indices from sortedModel
                return index < topN
            }
        }

        SGText {
            color: "white"
            text: "Recently<br>Released"
            fontSizeMultiplier: 1.3
            font.family: Fonts.franklinGothicBold
            Layout.fillWidth: false
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            font.capitalization: Font.AllUppercase
        }

        Rectangle {
            color: "white"
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            opacity: .5
        }

        Repeater {
            id: mostRecentRepeater
            model: lengthModel

            delegate: MouseArea {
                id: mouse
                implicitHeight: column.implicitHeight
                implicitWidth: column.implicitWidth
                Layout.fillWidth: true
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked:  {
                    Filters.clearActiveFilters()

                    // do not set filters if filter controls not visible due to small window size
                    if (leftFilters.responsiveVisible && rightFilters.responsiveVisible) {
                        // filter on all of this platform's category filters to find all similar ones
                        for (let j = 0; j < model.filters.count; j++){
                            let filterName = model.filters.get(j).filterName
                            if (Filters.mapping.hasOwnProperty(filterName)) {
                                if (Filters.mapping[filterName].type === "category" && Filters.mapping[filterName].inUse === true) {
                                    Filters.categoryFilters.push(filterName)
                                    Filters.utility.categoryFiltersChanged()
                                }
                            }
                        }
                    }

                    PlatformSelection.platformSelectorModel.currentIndex = platformSelectorListView.listview.count-1 // go to end of list so next selection appears at top of view
                    let originalIndex = sortedModel.mapIndexToSource(index) // get base model index
                    PlatformSelection.platformSelectorModel.currentIndex = platformSelectorListView.model.mapIndexFromSource(originalIndex)
                }

                Rectangle {
                    height: parent.height + 20
                    width: parent.width + 20
                    anchors {
                        centerIn: parent
                    }
                    color: Qt.darker(recentlyReleased.color)
                    radius: recentlyReleased.radius
                    opacity: .25
                    visible: mouse.containsMouse
                }

                ColumnLayout {
                    id: column
                    spacing: 15
                    width: mouse.width

                    Item {
                        Layout.fillWidth: true
                        implicitHeight: imageContainer.implicitHeight
                        implicitWidth: imageContainer.implicitWidth

                        DropShadow {
                            id: dropShadow
                            implicitWidth: imageContainer.width
                            implicitHeight: imageContainer.height
                            horizontalOffset: 1
                            verticalOffset: 3
                            radius: 10.0
                            samples: radius*2
                            color: "#88000000"
                            source: imageContainer
                            cached: true
                        }

                        PlatformImage {
                            id: imageContainer
                            width: Math.min(implicitWidth, parent.width)
                            sourceWidth: 120
                        }
                    }

                    SGText {
                        id: name
                        color: "white"
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: imageContainer.implicitWidth
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        text: model.verbose_name  //model.timestamp
                        font.family: Fonts.franklinGothicBook
                        elide: Text.ElideRight
                        maximumLineCount: 4
                    }
                }
            }
        }
    }
}
