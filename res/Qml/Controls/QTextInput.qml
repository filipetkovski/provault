import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: root
    implicitWidth: 320
    implicitHeight: 36
    radius: applicationResources.radius
    clip: true
    color: applicationResources.backgroundColor
    border.color: applicationResources.darkGrayColor
    border.width: 1

    property alias text: textInput.text
    property alias echoMode: textInput.echoMode
    property alias placeholderText: placeholderText.text
    property string textFieldType: "NORMAL"
    property bool isPassHide: true

    MouseArea {
        anchors { fill: parent; rightMargin: 34 }
        enabled: false
        cursorShape: Qt.IBeamCursor
    }

    TextInput {
        id: textInput
        clip: true
        anchors { left: parent.left; leftMargin: 14; right: parent.right; rightMargin: eyeVisible.visible ?  eyeVisible.width + 7 : 14; verticalCenter: parent.verticalCenter }
        verticalAlignment: Text.AlignVCenter
        echoMode: TextInput.Normal
        font.pixelSize: 17
        color: "#FFFFFF"
    }

    Text {
        id: placeholderText
        anchors { left: parent.left; leftMargin: 14; right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
        color: applicationResources.grayColor
        font.pixelSize: 16
        visible: textInput.text === ""
    }

    Rectangle {
        id: eyeVisible
        width: 35; height: parent.height - 2
        radius: applicationResources.radius
        anchors { right: root.right; rightMargin: 7; top: parent.top; topMargin: 1 }
        visible: root.textFieldType === "PASSWORD"
        color: "transparent"

        QImgButton {
            anchors.centerIn: parent
            source: root.isPassHide ? "qrc:/res/Img/eye.svg" : "qrc:/res/Img/disable-eye.svg"
            onBtnClicked: {
                root.isPassHide = !root.isPassHide
                root.echoMode = root.isPassHide ? TextInput.Password : TextInput.Normal
            }
        }
    }
}
