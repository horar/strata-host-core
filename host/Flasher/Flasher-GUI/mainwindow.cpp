#include "mainwindow.h"
#include <QDebug>
#include <QThread>
#include <QtConcurrent>

#include "ui_mainwindow.h"
MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);
}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::on_selectFile_clicked()
{
    QString fileName = QFileDialog::getOpenFileName(this,
       tr("Open Firmware"), "/", tr("Files (*.bin *.hex)"));

    qDebug() << "filename:" << fileName;
    ui->textEdit->setText(fileName);
}
void MainWindow::startFlashingOnBackground()
{
    // Disable Flash button
    ui->flashButton->setEnabled(false);

    // Update label status
    ui->labelStatus->setText("Status: Flashing is In progress");

    // Initialize the flasher
    Flasher *flasher = new Flasher();
    // Get the file path
    QString file_path = ui->textEdit->toPlainText();

    // status variable to be used to update the label
    QString status;
    bool res = flasher->flash(file_path.toUtf8().data());
    if(res){
        // Cool
        qDebug() << "Flashed";
        status = "Status: Done";
    }else{
        // Bad
        qDebug() << "Something went wrong!";
        status = "Status: Something went wrong. Please try again!";
    }
    delete flasher;

    // Enable the flash button
    ui->flashButton->setEnabled(true);
    // Update the status
    ui->labelStatus->setText(status);
}
void MainWindow::on_flashButton_clicked()
{

    QFuture<void> f1 = QtConcurrent::run(this,&MainWindow::startFlashingOnBackground);
    //f1.waitForFinished();

}
