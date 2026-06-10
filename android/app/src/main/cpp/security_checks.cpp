#include <jni.h>
#include <string>
#include <fstream>
#include <cctype>

extern "C" JNIEXPORT jboolean JNICALL
Java_com_laqta_laqta_SecurityBridge_nativeAntiDebug(JNIEnv*, jobject) {
    std::ifstream status("/proc/self/status");
    std::string line;
    while (std::getline(status, line)) {
        if (line.rfind("TracerPid:", 0) == 0) {
            for (char c : line.substr(10)) {
                if (std::isdigit(static_cast<unsigned char>(c)) && c != '0') {
                    return JNI_TRUE;
                }
            }
            return JNI_FALSE;
        }
    }
    return JNI_FALSE;
}

extern "C" JNIEXPORT jstring JNICALL
Java_com_laqta_laqta_SecurityBridge_nativeScanMaps(JNIEnv* env, jobject) {
    std::ifstream maps("/proc/self/maps");
    std::string line;
    while (std::getline(maps, line)) {
        std::string lower = line;
        for (char& c : lower) {
            c = static_cast<char>(::tolower(c));
        }
        if (lower.find("frida") != std::string::npos ||
            lower.find("xposed") != std::string::npos ||
            lower.find("substrate") != std::string::npos ||
            lower.find("zygote_injected") != std::string::npos) {
            return env->NewStringUTF(lower.substr(0, 96).c_str());
        }
    }
    return env->NewStringUTF("");
}
