#include <windows.h>
#include <winhttp.h>
#include <cstring>
#include <string>

#pragma comment(lib, "winhttp.lib")

static const char* EXPECTED_KEY = "X78-QZ56-EU5M-FYUQ";
static const wchar_t* SERVER_HOST = L"raw.githubusercontent.com";
static const int SERVER_PORT = INTERNET_DEFAULT_HTTPS_PORT;
static const wchar_t* KEY_FILE_PATH = L"/AHC-Clan/AHC_BlackX/refs/heads/main/AHC_BlackX.txt";

std::string fetchRemoteKey() {
    std::string result = "";

    HINTERNET hSession = WinHttpOpen(
        L"Mozilla/5.0",
        WINHTTP_ACCESS_TYPE_DEFAULT_PROXY,
        WINHTTP_NO_PROXY_NAME,
        WINHTTP_NO_PROXY_BYPASS, 0
    );
    if (!hSession) return "";

    HINTERNET hConnect = WinHttpConnect(
        hSession,
        SERVER_HOST,
        SERVER_PORT,
        0
    );
    if (!hConnect) { WinHttpCloseHandle(hSession); return ""; }

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

    if (WinHttpSendRequest(hRequest, WINHTTP_NO_ADDITIONAL_HEADERS, 0,
        WINHTTP_NO_REQUEST_DATA, 0, 0, 0) &&
        WinHttpReceiveResponse(hRequest, NULL)) {

        char buffer[256] = {0};
        DWORD bytesRead = 0;
        if (WinHttpReadData(hRequest, buffer, sizeof(buffer) - 1, &bytesRead)) {
            buffer[bytesRead] = '\0';
            result = buffer;

            // 앞뒤 공백/줄바꿈 제거
            while (!result.empty() && (result.back() == '\n' || result.back() == '\r' || result.back() == ' '))
                result.pop_back();
            while (!result.empty() && (result.front() == '\n' || result.front() == '\r' || result.front() == ' '))
                result.erase(result.begin());
        }
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
            std::string remoteKey = fetchRemoteKey();

            if (!remoteKey.empty() && remoteKey == EXPECTED_KEY) {
                strncpy_s(output, outputSize, "1", _TRUNCATE);
                return 0;
            }
        }

        strncpy_s(output, outputSize, "0", _TRUNCATE);
        return -1;
    }
}
