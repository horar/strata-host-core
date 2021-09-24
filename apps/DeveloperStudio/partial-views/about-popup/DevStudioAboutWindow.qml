/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets

SGWidgets.SGAboutWindow {
    appLogoSource: "qrc:/images/on-semi-logo-horiz.svg"

    additionalAttributionText: {
        return "OpenSSL 1.1.1<br>" +
                "<a href=\'" + sdsModel.urls.licenseUrl + "'>" + sdsModel.urls.licenseUrl + "</a><br>"
    }
}
