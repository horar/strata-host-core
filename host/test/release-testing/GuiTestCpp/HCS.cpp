#include <winsock2.h>
#include <ws2tcpip.h>
#include <stdio.h>

#pragma comment(lib, "Ws2_32.lib")

class HCS
{
public:
    HCS()
    {
        WSADATA wsaData;
        int iResult;

        // Initialize Winsock
        iResult = WSAStartup(MAKEWORD(2, 2), &wsaData);
    }
    int Connect(PCSTR addr, PCSTR port)
    {
        struct addrinfo *result = NULL, *ptr = NULL, hints;
        SOCKADDR_IN ServerAddr, ThisSenderInfo;



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
        sendSocket = socket(result->ai_family, result->ai_socktype, result->ai_protocol);

        iResult = connect(sendSocket, ptr->ai_addr, (int)ptr->ai_addrlen);
        if (iResult == SOCKET_ERROR) {
            closesocket(sendSocket);
            sendSocket = INVALID_SOCKET;
        }


    }


private:
    SOCKET sendSocket;
};