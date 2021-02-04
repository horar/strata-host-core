import QtQuick 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets

SGWidgets.SGAboutWindow {
    appLogoSource: "qrc:/sgimages/on-logo-green.svg"

    additionalAttributionText: {
        return "OpenSSL 1.1.1<br>" +
                "<a href=\'" + urls.licenseUrl + "'>" + urls.licenseUrl + "</a><br>"
    }
}
