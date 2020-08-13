#pragma once
#include <winsock2.h>

#pragma comment(lib, "Ws2_32.lib")

class HCS
{
public:
    HCS();
    int Connect(PCSTR addr, PCSTR port);
    int Recive(char* buffer, int bufferLen);
    int Send(const char* data);

private:
    SOCKET hcsSocket = INVALID_SOCKET;
};