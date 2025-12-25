import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets

// Test Bar Widget
Rectangle {
  id: root

  property var pluginApi: null

  // Required properties for bar widgets
  property ShellScreen screen
  property string widgetId: ""
  property string section: ""

  implicitWidth: 140
  implicitHeight: Style.barHeight

  color: Color.mPrimary
  radius: Style.radiusM

  RowLayout {
    anchors.centerIn: parent
    spacing: Style.marginS

    NText {
      text: "test"
      color: Color.mOnPrimary
      pointSize: Style.fontSizeS
      font.weight: Font.Medium
    }
  }
}
