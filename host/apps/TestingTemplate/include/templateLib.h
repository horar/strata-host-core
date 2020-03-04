#ifndef TEMPLATE_LIB_H
#define TEMPLATE_LIB_H

#include <QObject>

class templateLib : public QObject
{
    Q_OBJECT
private:
    int m_value;
public:
    templateLib(/* args */);
    ~templateLib();
    bool returnBool(bool state);
    int getValue();

public slots:
    void setValue(int value);

signals:
    void valueChanged(int newValue);
};

#endif // TEMPLATE_LIB_H
