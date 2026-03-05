import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "../Controls"

Popup {
    id: deleteCredentialsPopup
    width: 460
    height: 200
    anchors.centerIn: parent
    modal: true
    background: Rectangle { color: "transparent" }

    Overlay.modal: Rectangle {
        radius: applicationResources.radius
        color: Qt.rgba(37/255, 40/255, 47/255, 0.5)
    }

    onClosed: deleteCredentialsPopup.close()

    property var index

    Rectangle {
        width: parent.width
        height: parent.height
        color: applicationResources.backgroundColor
        radius: applicationResources.radius
        border.color: applicationResources.secondaryColor
        border.width: 1

        ColumnLayout {
            anchors.centerIn: parent
            spacing: applicationResources.spacing

            QLabel {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Proceed with Caution")
                font.bold: true
                font.pixelSize: 22
            }

            QLabel {
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: 10
                text: qsTr("Do you want to delete this row?")
                font.pixelSize: 18
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                spacing: 20

                QButton {
                    btnText: qsTr("Delete")
                    color: applicationResources.activeButtonColor
                    border.width: 0
                    onBtnClicked: {
                        vaultModel.deleteData(deleteCredentialsPopup.index)
                        deleteCredentialsPopup.close()
                    }
                }

                QButton {
                    btnText: qsTr("Cancel")
                    color: applicationResources.primaryColor
                    onBtnClicked: deleteCredentialsPopup.close()
                }
            }
        }
    }
}

