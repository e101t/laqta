# Deep SecurityBridge Verification — Beyond logcat

Scope: get behavioral proof (positive or negative) that `SecurityBridge`'s native
`nativeAntiDebug`/`nativeScanMaps` functions actually execute at runtime, since the
prior real-device pass (`audit_reports/14_real_device_dynamic_verification.md`) found
zero logcat output from this layer and could only rely on Agent 8's static call-chain
trace. Three escalating black-box methods attempted, against the same already-installed
app, no source/rebuild/reinstall involved.

## Pre-checks

```
$ adb shell "su -c id"
su: inaccessible or not found

$ adb shell "which su"
(empty)

$ adb shell pm list packages | grep -i "magisk|supersu|superuser|kinguser|kingo"
(no matches)

$ adb shell pidof com.laqta.laqta
22205
```

**Device is not rooted.** No `su` binary, no root-management package installed. App was
running with PID `22205` at test time.

## Method 1 — `/proc/<pid>/maps`

```
$ adb shell cat /proc/22205/maps
cat: /proc/22205/maps: Permission denied
```

**Result: PERMISSION DENIED.** Expected on a non-rooted device — Android's `hidepid`
restriction blocks the `shell` user from reading another app's `/proc/<pid>/maps` since
Android 7+, independent of whether `run-as` would otherwise be allowed. Not informative
about `SecurityBridge` specifically — this is a platform-level restriction that would
apply to inspecting any app's memory maps this way, security-relevant or not.

## Method 2 — jdb / JDWP attach

```
$ adb jdwp
(zero PIDs listed, command left running with no output — stopped after confirming empty)
```

No process exposes a JDWP transport at all — consistent with `android:debuggable="false"`
for this release build (confirmed at the manifest level by `audit_reports/13...`'s direct
AAB manifest dump, which shows no debuggable attribute override). Continued anyway per the
task's instructions to attempt the actual attach and observe the failure mode:

```
$ adb forward tcp:8700 jdwp:22205
8700

$ jdb -connect "com.sun.jdi.SocketAttach:hostname=localhost,port=8700"
java.io.IOException: handshake failed - connection prematurely closed
Fatal error: Unable to attach to target VM.
```

**Result: jdb attach FAILED.** Failure mode: **standard release-build JDWP-disabled
behavior (expected)** — the TCP port forward itself succeeds (adb's port-forwarding layer
doesn't care whether anything real is behind it), but the JDWP handshake fails
immediately because the target process never started a JDWP server thread in the first
place (no debuggable flag). This is *not* an active rejection triggered by
`nativeAntiDebug` — it's indistinguishable from what would happen on literally any
non-debuggable release-build Android app, debug-detection code or not. Cleaned up with
`adb forward --remove tcp:8700`.

## Method 3 — root + Frida hook

**SKIPPED.** Device confirmed not rooted in the pre-check (no `su`, no root-management
app). Frida server requires root on the target device; Frida Gadget injection would
require rebuilding/repackaging the APK, which is out of scope for this read-only pass.

## Free secondary test (root-detection on a rooted device)

**NOT APPLICABLE.** This specific test device (the same Samsung SM-G975F from the prior
real-device pass) is not rooted, so there is no root state for `nativeScanMaps()` to
detect, and no behavioral comparison (rooted vs. non-rooted launch) can be made on this
hardware.

---

## Required Output Format

```
1. Device rooted: NO — `su -c id` returned "inaccessible or not found"; `which su` empty; no magisk/supersu/superuser/kinguser/kingo packages installed
2. Method 1 (/proc/<pid>/maps): ATTEMPTED — libsecurity.so found mapped: PERMISSION DENIED (hidepid restriction on non-rooted device, expected, uninformative either way)
3. Method 2 (jdb attach): ATTEMPTED
   - jdb attached successfully: NO
   - Failure mode: release-build JDWP disabled (expected) — adb jdwp lists zero debuggable PIDs, port-forward succeeds at the TCP level but the JDWP handshake fails immediately ("connection prematurely closed") because no JDWP server exists in the target process at all. This is indistinguishable from any non-debuggable app and is NOT evidence of an active anti-debug rejection.
4. Method 3 (root + Frida hook): SKIPPED — reason: device not rooted (confirmed in pre-check)
5. Free secondary test (root-detection on rooted device): NOT APPLICABLE — test device is not rooted
6. Overall conclusion: STILL UNCONFIRMED. None of the three methods produced a positive or negative behavioral signal about whether nativeAntiDebug/nativeScanMaps actually execute — Method 1 was blocked by an unrelated OS permission wall, Method 2 failed in a way that's expected regardless of SecurityBridge's behavior (no JDWP transport exists to even test against), and Method 3 could not be attempted at all on this non-rooted hardware. This remains an open verification gap: getting definitive runtime proof would require either a rooted test device (to run Frida hooks per the task's hook.js, or to get the free root-detection behavioral comparison) or a debug/instrumented build with verbose native logging enabled. Agent 8's static call-chain trace (Dart → MethodChannel → Kotlin handler → JNI → libsecurity.so exports, all confirmed present and wired with file/line citations) remains the best available evidence that this code path exists and is invoked; this pass neither strengthens nor contradicts that — it only confirms the limits of black-box testing against this specific non-rooted device.
```

## Note for the backlog

This is not a new security finding — it is a **testing-infrastructure gap**: dynamic
verification of `SecurityBridge` is not achievable with the tools/device available in
this session. If runtime confirmation of the native anti-debug/root-detection layer is
required before shipping (rather than relying on the static trace), the practical paths
are: (a) get access to a rooted test device for a Frida-based hook test (script already
provided in the task prompt, ready to run), or (b) request a debug/staging build variant
with `android:debuggable="true"` and verbose `Log.d` calls added temporarily inside
`SecurityBridge.kt`'s native-call wrappers, purely for one-time verification, never
shipped to production.
