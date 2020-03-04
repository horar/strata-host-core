#include "templateLib.h"

templateLib::templateLib(/* args */)
{
    m_value = 0;
}

templateLib::~templateLib()
{
}

bool templateLib::returnBool(bool state) {
    return state;
}

int templateLib::getValue() {
    return m_value;
}

void templateLib::setValue(int value) {
    if(value != m_value) {
        m_value = value;
        emit valueChanged(value);
    }
}
