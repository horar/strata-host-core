#include "cb_browser.h"
#include "ui_cb_browser.h"
#include "SGFleece.h"
#include "SGCouchBaseLite.h"
#include "databaseinterface.h"

#include <QCoreApplication>
#include <QTextStream>
#include <QFileDialog>
#include <QTextEdit>
#include <QDir>

#include <iostream>

using namespace std;
using namespace fleece;
using namespace fleece::impl;
using namespace std::placeholders;
using namespace Spyglass;

#define DEBUG(...) printf("TEST Couchbase Browser: "); printf(__VA_ARGS__)

CB_Browser::CB_Browser(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::CB_Browser)
{
    ui->setupUi(this);

    connect(ui->m_button,SIGNAL(released()),this,SLOT(onclick_openFile()));
}

CB_Browser::~CB_Browser()
{
    delete ui;
}

bool CB_Browser::onclick_openFile()
{
    const QString file_path =  QFileDialog::getOpenFileName(this,"Open Document",QDir::currentPath(),"All files (*.*)");

    if(file_path.isNull())
    {
        qDebug("Problem finding selected file. Try again.");
        return false;
    }

    DatabaseInterface db(file_path);

    vector<pair<string,string>> body = db.getDocumentContents();

    updateUI_fileDirectory(db.getFilePath());

    updateUI_DBname(db.getDBName());

    updateUI_Contents(db.getDocumentContents());

    return true;
}

void CB_Browser::updateUI_fileDirectory(const QString file_path)
{
    ui->textEdit->setText(file_path);
}

void CB_Browser::updateUI_DBname(const QString database_name)
{
    ui->textEdit_2->setText(database_name);
}

void CB_Browser::updateUI_Contents(vector<pair<string,string>> contents)
{
    for(int i = 0; i < contents.size(); ++i)
        ui->textEdit_3->append(QString::fromStdString(contents.at(i).first) + "\n" + QString::fromStdString(contents.at(i).second) + "\n\n");
}
