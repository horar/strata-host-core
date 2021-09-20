#ifndef SGCSVUTILS_H
#define SGCSVUTILS_H
#include <QObject>
#include <QVariant>

class SGCSVUtils: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString outputPath READ outputPath WRITE setOutputPath NOTIFY outputPathChanged)
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

    Q_INVOKABLE QVariant importFromFile(QString folderPath);
    Q_INVOKABLE void appendRow(QVariant data);
    Q_INVOKABLE QVariant getData();
    Q_INVOKABLE void setData(QVariant data);
    Q_INVOKABLE void clear();

signals:
    void outputPathChanged();

private:
    QVariantList data_;
    QString outputPath_;
};

#endif // SGCSVUTILS_H
