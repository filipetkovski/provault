import QtQuick

Image {
    property alias btnEnabled: btnMouseArea.enabled

    signal btnClicked

    MouseArea {
        id: btnMouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: btnClicked()
    }
}
