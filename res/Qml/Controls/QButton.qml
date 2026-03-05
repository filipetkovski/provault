import QtQuick

Rectangle {
    implicitWidth: btnText.implicitWidth + 50; implicitHeight: 32
    width: btnText.width + 50; height: 32
    color: applicationResources.primaryColor
    radius: applicationResources.radius
    border.color: applicationResources.darkGrayColor
    border.width: 1

    property alias btnText: btnText.text
    property alias btnFontSize: btnText.font.pixelSize
    property alias btnTextColor: btnText.color
    property alias btnEnabled: btnMouseArea.enabled

    signal btnClicked

    QLabel {
        id: btnText
        anchors.centerIn: parent
        font.pixelSize: 17
    }

    MouseArea {
        id: btnMouseArea
        anchors.fill: parent
        cursorShape: !btnEnabled ? Qt.ArrowCursor : Qt.PointingHandCursor
        onClicked: btnClicked()
    }
}
