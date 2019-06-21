#include "cb_browser.h"
#include <QApplication>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    CB_Browser w;
    w.show();
    return a.exec();
}
