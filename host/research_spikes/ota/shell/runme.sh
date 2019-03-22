#
# Sample build setup script for macOS
#
# http://doc.qt.io/qtinstallerframework/ifw-overview.html
#
#
# config file:
# http://doc.qt.io/qtinstallerframework/ifw-globalconfig.html
#
# package:
# http://doc.qt.io/qtinstallerframework/ifw-component-description.html
#
#
# (c) 2019, Lubomir Carik
#

echo Entering setup folder...
cd setup

rm -f *.exe

echo Generating offline installer...
binarycreator --offline-only -c config/config.xml -p packages sds-setup
echo ...done

echo Generating online installer...
binarycreator --online-only  -c config/config.xml -p packages sds-setup-online.app
echo ...done

#rm -rf pub/repository/demo
echo Generating repository, update new components...
repogen --update-new-components -p packages pub/repository/demo
echo ...done

echo Finished...
cd ..
