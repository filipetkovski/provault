import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    implicitHeight: 48

    RowLayout {
        height: 35
        spacing: applicationResources.spacing

        QLabel {
            Layout.preferredWidth: 25
            Layout.fillHeight: true
            font.pixelSize: 20
            text: qsTr("#")
        }

        QLabel {
            Layout.preferredWidth: 300
            Layout.fillHeight: true
            font.pixelSize: 20
            text: qsTr("TITLE")
        }

        QLabel {
            Layout.fillWidth: true
            Layout.fillHeight: true
            font.pixelSize: 20
            text: qsTr("USERNAME")
        }
    }

    RowLayout {
        width: parent.width
        anchors.bottom: parent.bottom
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 2
            color: applicationResources.darkGrayColor
        }
    }
}
