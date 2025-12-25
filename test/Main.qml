import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Services.Noctalia

Singleton {
    id: root

    property var pluginApi: null
    property bool syncRunning: false
    property string currentTrack: ""
    property string currentArtist: ""
    property string lastLog: ""

    readonly property string syncScript: Settings.configDir + "plugins/test/osdlyrics-sync.py"

    // Main sync process
    Process {
        id: syncProcess
        command: ["python3", syncScript]
        running: pluginApi ? (pluginApi.pluginSettings.enabled || pluginApi.manifest.metadata.defaultSettings.enabled || false) : false

        stdout: StdioCollector {
            onStreamFinished: {
                let output = text.trim()
                if (output) {
                    Logger.d("OSDLyrics", output)
                    root.lastLog = output

                    // Parse track info from logs
                    if (output.includes("Track changed:")) {
                        let parts = output.split("Track changed:")[1].trim().split(" - ")
                        if (parts.length >= 2) {
                            root.currentArtist = parts[0]
                            root.currentTrack = parts[1]
                        }
                    }

                    // Update sync status
                    if (output.includes("Lyrics sent to OSDLyrics")) {
                        root.syncRunning = true
                    }
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text) {
                    Logger.w("OSDLyrics", text.trim())
                    root.lastLog = text.trim()
                }
            }
        }

        onRunningChanged: {
            if (running) {
                Logger.i("OSDLyrics", "Sync process started")
            } else {
                Logger.i("OSDLyrics", "Sync process stopped")
                root.syncRunning = false
            }
        }
    }

    // Check if Python script exists
    Component.onCompleted: {
        Logger.i("OSDLyrics", "Plugin initialized")
        Logger.i("OSDLyrics", "Script path: " + syncScript)
    }
}
