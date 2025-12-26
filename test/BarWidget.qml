import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets

// OSDLyrics Sync Bar Widget
Rectangle {
  id: root

  property var pluginApi: null

  // Required properties for bar widgets
  property ShellScreen screen
  property string widgetId: ""
  property string section: ""

  implicitWidth: 200
  implicitHeight: Style.barHeight

  color: Main.syncRunning ? Color.mPrimary : Color.mSurfaceVariant
  radius: Style.radiusM

  RowLayout {
    anchors.centerIn: parent
    spacing: Style.marginS

    // Status icon
    NText {
      text: Main.syncRunning ? "♪" : "♫"
      color: Color.mOnPrimary
      pointSize: Style.fontSizeM
      font.weight: Font.Bold
    }

    // Track info
    NText {
      text: {
        if (Main.currentTrack && Main.currentArtist) {
          return Main.currentArtist + " - " + Main.currentTrack
        } else if (Main.syncRunning) {
          return "OSD Lyrics"
        } else {
          return "No Track"
        }
      }
      color: Color.mOnPrimary
      pointSize: Style.fontSizeS
      font.weight: Font.Medium
      Layout.maximumWidth: 180
      elide: Text.ElideRight
    }
  }

  // Tooltip
  MouseArea {
    anchors.fill: parent
    hoverEnabled: true

    ToolTip.visible: containsMouse
    ToolTip.text: Main.lastLog || "OSDLyrics Sync Plugin"
    ToolTip.delay: 500
  }
}
