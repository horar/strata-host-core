import QtQuick 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets

SGWidgets.SGAboutWindow {
    appLogoSource: "qrc:/images/on-semi-logo-horiz.svg"

    additionalAttributionText: {
        return "OpenSSL 1.1.1<br>" +
                "<a href=\'" + sdsModel.urls.licenseUrl + "'>" + sdsModel.urls.licenseUrl + "</a><br>"
    }
}
