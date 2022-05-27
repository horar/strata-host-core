#pragma once

#include <QObject>
#include <QAbstractListModel>


//fake stuff

class SciPlatformBaseTest: public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(SciPlatformBaseTest)

public:
    SciPlatformBaseTest(QObject *parent = nullptr)
        : QObject(parent) {
    }

    ~SciPlatformBaseTest() {};


    virtual void run() = 0;

    QString name() {
        return name_;
    };

    void setEnabled(bool enabled) {
        enabled_ = enabled;
    }

    bool enabled() {
        return enabled_;
    }

signals:
    void infoStatus(QString text);
    void warningStatus(QString text);
    void errorStatus(QString text);

    void finished(bool success);

protected:
     QString name_;


private:
    bool enabled_ = true;

};

class PlatformTest1: public SciPlatformBaseTest {
    Q_OBJECT
    Q_DISABLE_COPY(PlatformTest1)

public:

    PlatformTest1(QObject *parent = nullptr)
        : SciPlatformBaseTest(parent)
    {
        name_ = "test1";
    };

    void run() override {
        emit warningStatus("some warning text");

        emit infoStatus("some info text");
        emit infoStatus("some more info text");
        emit infoStatus("some more and more info text");

        emit finished(true);
    }
};

class PlatformTest2: public SciPlatformBaseTest {
    Q_OBJECT
    Q_DISABLE_COPY(PlatformTest2)

public:

    PlatformTest2(QObject *parent = nullptr)
        : SciPlatformBaseTest(parent)
    {
        name_ = "Test2";
    };

    void run() override {
        emit errorStatus("some error text");


        emit finished(false);
    }
};

class PlatformTest3: public SciPlatformBaseTest {
    Q_OBJECT
    Q_DISABLE_COPY(PlatformTest3)

public:

    PlatformTest3(QObject *parent = nullptr)
        : SciPlatformBaseTest(parent)
    {
        name_ = "Test3";
    };

    void run() override {
        emit finished(true);
    }
};

class PlatformTest4: public SciPlatformBaseTest {
    Q_OBJECT
    Q_DISABLE_COPY(PlatformTest4)

public:

    PlatformTest4(QObject *parent = nullptr)
        : SciPlatformBaseTest(parent)
    {
        name_ = "Test4";
    };

    void run() override {
        emit warningStatus("some warning text");
        emit warningStatus("some serious warning text");
        emit warningStatus("some warning text again");
        emit finished(true);
    }
};

//end fake stuff


class SciPlatformTestMessageModel;

class SciPlatformTestModel: public QAbstractListModel
{
    Q_OBJECT
    Q_DISABLE_COPY(SciPlatformTestModel)

public:

    enum ModelRole {
        NameRole = Qt::UserRole + 1,
        EnabledRole,
    };

    explicit SciPlatformTestModel(SciPlatformTestMessageModel *messageModel, QObject *parent = nullptr);
    virtual ~SciPlatformTestModel() override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;


    Q_INVOKABLE void setEnabled(int row, bool enabled);

    Q_INVOKABLE void runTests();

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

private slots:

    void infoStatusHandler(QString text);
    void warningStatusHandler(QString text);
    void errorStatusHandler(QString text);
    void finishedHandler(bool success);

private:

    void runNextTest();


    struct TestItem {
        QString name;
        bool enabled = false;
    };

    QList<SciPlatformBaseTest*> data_;
    SciPlatformTestMessageModel *messageModel_;

    int activeTestIndex_;

};
