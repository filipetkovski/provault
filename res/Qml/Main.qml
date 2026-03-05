import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "Pages"
import "Controls"

ApplicationWindow {
    id: window
    width: applicationResources.screenWidth
    height: applicationResources.screenHeight
    color: applicationResources.transparent
    flags: Qt.Window | Qt.FramelessWindowHint
    visible: true

    Rectangle {
        anchors.fill: parent
        color: applicationResources.backgroundColor
        radius: applicationResources.radius

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: applicationResources.margin
            spacing: applicationResources.spacing

            TopPanel {
                Layout.fillWidth: true
            }

            VaultPage {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }
}
