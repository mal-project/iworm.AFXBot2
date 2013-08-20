#include <windows.h>
#include <stdio.h>
#include <stdarg.h>
#include <winsock2.h>

#pragma comment(lib,"ws2_32.lib")
#pragma comment(lib,"user32.lib")

#define MAX_CONNECTIONS 16

void ReportError(char * fmtstr, ...)
{
	char msg_caller[256];
    char msg_gle[256];
    va_list v1;
    va_start(v1,fmtstr);
    wvsprintf(msg_caller,fmtstr,v1);
	FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM|FORMAT_MESSAGE_IGNORE_INSERTS,0,GetLastError(),MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),msg_gle,256,0);
    printf("ERROR: %s\nGetLastError() reports: %s",msg_caller,msg_gle);
    va_end(v1);
}

INT main(INT ac,PCHAR *av)
{
    #define ERRCLEANUP(...) { ReportError(__VA_ARGS__); goto cleanup; }

    CHAR buff[256];

    DWORD dwRet;
    INT nRet;

    sockaddr_in sa_in;
    sockaddr_in sa_rem;
    WSADATA wd;
    SOCKET so,rso;

    printf("initializing winsock\n");
    if(WSAStartup(0x0202,&wd))
        ERRCLEANUP("WSAStartup")

    printf("creating server socket\n");
    if((so=socket(AF_INET,SOCK_STREAM,IPPROTO_TCP))==INVALID_SOCKET)
        ERRCLEANUP("socket")

    sa_in.sin_family=AF_INET;
    sa_in.sin_addr.s_addr=inet_addr("127.0.0.1");
    sa_in.sin_port=htons(1337);

    printf("binding\n");
    if(bind(so,(SOCKADDR *)&sa_in,sizeof(sa_in))==SOCKET_ERROR)
        ERRCLEANUP("bind")

    printf("setting listen mode\n");
    if(listen(so,MAX_CONNECTIONS)==SOCKET_ERROR)
        ERRCLEANUP("listen")

    while(1)
    {
        printf("accepting new connections\n");
        nRet=sizeof(sa_rem);
        if((rso=accept(so,(sockaddr *)&sa_rem,&nRet))==INVALID_SOCKET)
            ERRCLEANUP("accept")

        printf("connection accepted, sending message\n");
        strcpy(buff,"welcome message\n");
        if((nRet=send(rso,buff,strlen(buff),0))==SOCKET_ERROR)
            ERRCLEANUP("send")

        while(1)
        {
            nRet=recv(rso,buff,64,0);
    
            if(nRet==0)
            {
                printf("connection closed\n");
                closesocket(rso);
                break;
            }
            else if(nRet==SOCKET_ERROR)
                ERRCLEANUP("recv")
            else 
            {
                buff[nRet]=0;
                printf("recv'd: %s\n",buff);
            }
        }
    }
    
    cleanup:
    WSACleanup();
    return 0;
}
