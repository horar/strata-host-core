#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QFileDialog>
#include "Flasher.h"

namespace Ui {
class MainWindow;
}

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = 0);
    ~MainWindow();

private slots:
    void on_selectFile_clicked();

    void on_flashButton_clicked();

private:
    Ui::MainWindow *ui;
    void startFlashingOnBackground();
};

#endif // MAINWINDOW_H
