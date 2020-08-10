#pragma once
#include <winsock2.h>
#include <ws2tcpip.h>
#include <stdio.h>
#include "HCS.h"

#pragma comment(lib, "Ws2_32.lib")


HCS::HCS()
{
    WSADATA wsaData;
    int iResult;

    // Initialize Winsock
    iResult = WSAStartup(MAKEWORD(2, 2), &wsaData);
}
int HCS::Connect(PCSTR addr, PCSTR port)
{
    struct addrinfo *result = NULL, hints;

    ZeroMemory(&hints, sizeof(hints));
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_protocol = IPPROTO_TCP;
    

    // Resolve the local address and port to be used by the server
    int iResult = getaddrinfo(addr, port, &hints, &result);
    if (iResult != 0) {
        printf("getaddrinfo failed: %d\n", iResult);
        WSACleanup();
        return 1;

    }
    hcsSocket = socket(result->ai_family, result->ai_socktype, result->ai_protocol);

    iResult = connect(hcsSocket, result->ai_addr, (int)result->ai_addrlen);
    freeaddrinfo(result);
    if (iResult == SOCKET_ERROR) {
        closesocket(hcsSocket);
        hcsSocket = INVALID_SOCKET;
    }
    return iResult;

}

int HCS::Recive(char* buffer, int bufferLen)
{
    return recv(hcsSocket, buffer, bufferLen, 0);
}

int HCS::Send(const char* data)
{
    return send(hcsSocket, data, (int)strlen(data), 0);
}