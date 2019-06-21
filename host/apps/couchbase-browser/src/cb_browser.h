#ifndef CB_BROWSER_H
#define CB_BROWSER_H

#include <QMainWindow>
#include <QPushButton>
#include <QTextEdit>

#include "SGFleece.h"
#include "SGCouchBaseLite.h"

using namespace std;
using namespace fleece;
using namespace fleece::impl;
using namespace std::placeholders;
using namespace Spyglass;

namespace Ui {
class CB_Browser;
}

class CB_Browser : public QMainWindow
{
    Q_OBJECT

public:
    explicit CB_Browser(QWidget *parent = nullptr);
    ~CB_Browser();
private slots:
    bool onclick_openFile();
private:
    Ui::CB_Browser *ui;
    QPushButton *m_button;
    QTextEdit *textEdit, *textEdit_2, *textEdit_3;
    void updateUI_DBname(const QString database_name);
    void updateUI_fileDirectory(const QString file_path);
    void updateUI_Contents(vector<pair<string,string>> contents);
};

#endif // CB_BROWSER_H
