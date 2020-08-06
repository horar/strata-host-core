/****************************************************************************
**
** Copyright (C) 2017 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of the FOO module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:GPL-EXCEPT$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3 as published by the Free Software
** Foundation with exceptions as appearing in the file LICENSE.GPL3-EXCEPT
** included in the packaging of this file. Please review the following
** information to ensure the GNU General Public License requirements will
** be met: https://www.gnu.org/licenses/gpl-3.0.html.
**
** $QT_END_LICENSE$
**
****************************************************************************/


function Component()
{
}

Component.prototype.createOperations = function()
{
    // call default implementation to actually install the content
    component.createOperations();

    if (systemInfo.productType === "windows") {
        if(installer.value("add_start_menu_shortcut") == "true") {
            var strata_ds_shortcut_dst1 = installer.value("StartMenuDir") + "\\Strata Developer Studio.lnk";
            component.addOperation("CreateShortcut", installer.value("TargetDir") + "/Strata Developer Studio.exe", strata_ds_shortcut_dst1,
                                    "workingDirectory=" + installer.value("TargetDir"), "description=Open Strata Developer Studio");
        }
        if(installer.value("add_desktop_shortcut") == "true") {
            var strata_ds_shortcut_dst2 = installer.value("DesktopDir") + "\\Strata Developer Studio.lnk";
            component.addOperation("CreateShortcut", installer.value("TargetDir") + "/Strata Developer Studio.exe", strata_ds_shortcut_dst2,
                                    "workingDirectory=" + installer.value("TargetDir"), "description=Open Strata Developer Studio");
        }
     }
}
