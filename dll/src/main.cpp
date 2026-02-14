#include <windows.h>
#include <winhttp.h>
#include <cstring>
#include <string>

#pragma comment(lib, "winhttp.lib")

static const char* EXPECTED_KEY = "UBS-YATF-KXXA-YO06";
static const wchar_t* SERVER_HOST = L"raw.githubusercontent.com";
static const int SERVER_PORT = 443;
static const wchar_t* KEY_FILE_PATH = L"/AHC-Clan/AHC_BlackX/refs/heads/main/AHC_BlackX.txt";

std::string fetchRemoteKey() {
    std::string result;

    HINTERNET hSession = WinHttpOpen(
        L"Mozilla/5.0",
        WINHTTP_ACCESS_TYPE_DEFAULT_PROXY,
        WINHTTP_NO_PROXY_NAME,
        WINHTTP_NO_PROXY_BYPASS, 0
    );
    if (!hSession) return "";

    DWORD protocols = WINHTTP_FLAG_SECURE_PROTOCOL_TLS1_2 | WINHTTP_FLAG_SECURE_PROTOCOL_TLS1_3;
    WinHttpSetOption(hSession, WINHTTP_OPTION_SECURE_PROTOCOLS, &protocols, sizeof(protocols));

    HINTERNET hConnect = WinHttpConnect(
        hSession,
        SERVER_HOST,
        SERVER_PORT,
        0
    );
    if (!hConnect) {
        WinHttpCloseHandle(hSession);
        return "";
    }

    HINTERNET hRequest = WinHttpOpenRequest(
        hConnect,
        L"GET",
        KEY_FILE_PATH,
        NULL,
        WINHTTP_NO_REFERER,
        WINHTTP_DEFAULT_ACCEPT_TYPES,
        WINHTTP_FLAG_SECURE
    );
    if (!hRequest) {
        WinHttpCloseHandle(hConnect);
        WinHttpCloseHandle(hSession);
        return "";
    }

    BOOL bSend = WinHttpSendRequest(hRequest, WINHTTP_NO_ADDITIONAL_HEADERS, 0,
        WINHTTP_NO_REQUEST_DATA, 0, 0, 0);
    if (!bSend) {
        WinHttpCloseHandle(hRequest);
        WinHttpCloseHandle(hConnect);
        WinHttpCloseHandle(hSession);
        return "";
    }

    BOOL bRecv = WinHttpReceiveResponse(hRequest, NULL);
    if (!bRecv) {
        WinHttpCloseHandle(hRequest);
        WinHttpCloseHandle(hConnect);
        WinHttpCloseHandle(hSession);
        return "";
    }

    char buffer[256] = {0};
    DWORD bytesRead = 0;
    if (WinHttpReadData(hRequest, buffer, sizeof(buffer) - 1, &bytesRead)) {
        buffer[bytesRead] = '\0';
        result = buffer;

        // UTF-8 BOM 제거
        if (result.size() >= 3 &&
            (unsigned char)result[0] == 0xEF &&
            (unsigned char)result[1] == 0xBB &&
            (unsigned char)result[2] == 0xBF) {
            result.erase(0, 3);
        }

        while (!result.empty() && (result.back() == '\n' || result.back() == '\r' || result.back() == ' '))
            result.pop_back();
        while (!result.empty() && (result.front() == '\n' || result.front() == '\r' || result.front() == ' '))
            result.erase(result.begin());
    } else {
        result = "";
    }

    WinHttpCloseHandle(hRequest);
    WinHttpCloseHandle(hConnect);
    WinHttpCloseHandle(hSession);
    return result;
}

extern "C" {
    __declspec(dllexport) void __stdcall RVExtensionVersion(char* output, int outputSize) {
        strncpy_s(output, outputSize, "1.0.0", _TRUNCATE);
    }

    __declspec(dllexport) void __stdcall RVExtension(char* output, int outputSize, const char* function) {
        strncpy_s(output, outputSize, "", _TRUNCATE);
    }

    __declspec(dllexport) int __stdcall RVExtensionArgs(char* output, int outputSize,
        const char* function, const char** argv, int argc) {

        if (strcmp(function, "auth") == 0) {
            static bool cached = false;
            static bool authResult = false;

            if (!cached) {
                std::string remoteKey = fetchRemoteKey();
                authResult = (!remoteKey.empty() && remoteKey == EXPECTED_KEY);
                cached = true;
            }

            if (authResult) {
                strncpy_s(output, outputSize, "1", _TRUNCATE);
                return 0;
            }
        }

        strncpy_s(output, outputSize, "0", _TRUNCATE);
        return -1;
    }
}