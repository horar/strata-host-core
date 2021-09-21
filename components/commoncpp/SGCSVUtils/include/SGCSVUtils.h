#ifndef SGCSVUTILS_H
#define SGCSVUTILS_H
#include <QObject>
#include <QVariant>
#include <QVariantList>
#include <QDateTime>

class SGCSVUtils: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString outputPath READ outputPath WRITE setOutputPath NOTIFY outputPathChanged)
    Q_PROPERTY(QString fileName READ fileName WRITE setFileName NOTIFY fileNameChanged)
public:
    explicit SGCSVUtils(QObject *parent = nullptr);
    virtual ~SGCSVUtils();

    QString outputPath() const
    {
        return outputPath_;
    }

    void setOutputPath(QString outputPath)
    {
        if (outputPath_ != outputPath) {
            outputPath_ = outputPath;
        }
    }

    QString fileName() const {
        return fileName_;
    }

    void setFileName(QString fileName)
    {
        if (fileName_ != fileName) {
            fileName_ = fileName;
        }
    }

    Q_INVOKABLE QVariant importFromFile(QString folderPath);
    Q_INVOKABLE void appendRow(QVariantList data);
    Q_INVOKABLE QVariantList getData();
    Q_INVOKABLE void setData(QVariantList data);
    Q_INVOKABLE void clear();

signals:
    void outputPathChanged();
    void fileNameChanged();

private:
    QVariantList data_;
    QString outputPath_;
    QString fileName_ = QString("Output"+QDateTime::currentDateTime().toString("dd.MM.yyyy")+"-"+QDateTime::currentDateTime().toString("hh:mm:ss t") + ".csv");
};

#endif // SGCSVUTILS_H
