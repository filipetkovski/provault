import QtQuick
import QtQuick.Layouts

Item {
    property alias pageLoader: pageLoader
    property alias pagePopupLoader: pagePopupLoader

    function licenseCheck() {
        var productType = licenseModel.productType

        if(pageLoader.item.settingsModel.title === "Shield")
            return !(productType == 2 || productType == 0)
        else if(pageLoader.item.settingsModel.title === "Cloak")
            return !(productType == 2 || productType == 1)
        else if(pageLoader.item.settingsModel.title === "VPN")
            return !(productType == 2 || productType == 1)
        return false
    }

    function showAlert(message, color) {
        alert.visible = true
        alert.alertMessage.text = message
        alert.alertMessage.color = color
        alertMessageTimer.start()
    }

    Connections {
        target: licenseModel
        function onDialogStarted() {
            customLoader.pagePopupLoader.sourceComponent = licenseDialogPopupComponent
            customLoader.pagePopupLoader.item.open()
        }
        function onValidationFinished() { showAlert(licenseModel.licenseMessage, licenseModel.messageColor ? applicationResources.secondaryColor : applicationResources.warningColor) }
        function onUpdateReleased() { showAlert("NEW VERSION RELEASED", applicationResources.secondaryColor) }
    }

    Connections {
        target: vaultModel
        function onAlertTriggered(message) { showAlert(message, applicationResources.secondaryColor) }
    }

    Connections {
        target: window
        function onComponentCompleted() { showAlert(licenseModel.licenseMessage, licenseModel.messageColor ? applicationResources.secondaryColor : applicationResources.warningColor) }
        function onLicenseDialogFinished() { showAlert(licenseModel.licenseMessage, licenseModel.messageColor ? applicationResources.secondaryColor : applicationResources.warningColor) }
    }

    Timer {
        id: alertMessageTimer
        interval: 3000
        running: false
        repeat: false
        onTriggered: alert.visible = false
    }

    QAlert {
        id: alert
        anchors { top: parent.top; topMargin: 7; right: parent.right; rightMargin: 15 }
    }

    ColumnLayout {
        id: page
        anchors.fill: parent

        QHeader {
            id: customHeader
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
            Layout.leftMargin: 15
            Layout.rightMargin: 15
            Layout.bottomMargin: 35
            title: pageLoader.item.settingsModel.title.toUpperCase()
            subtitle: pageLoader.item.settingsModel.subtitle
        }

        Loader {
            id: pageLoader
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: 15
            Layout.rightMargin: 15
            Layout.bottomMargin: 10
            Component.onCompleted: {
                pageLoader.setSource( "qrc:/res/Qml/Pages/DashboardPage.qml", {
                    "settingsModel": applicationResources.getSetting("Dashboard"),
                    "shieldDeviceModel": applicationResources.shieldModel.deviceModel,
                    "shieldNetworkModel": applicationResources.shieldModel.networkModel,
                    "cloakDeviceModel": applicationResources.cloakModel.deviceModel,
                    "cloakNetworkModel": applicationResources.cloakModel.networkModel
                })
            }
        }
    }

    Rectangle {
        id: licenseBlock
        anchors { fill: page; topMargin: customHeader.height + 25 }
        color: Qt.rgba(0.184, 0.204, 0.224, 0.9)
        visible: licenseCheck()

        MouseArea {
            anchors.fill: parent
            enabled: true
        }

        QButton {
            anchors.centerIn: parent
            btnText: qsTr("Purchase")
            color: applicationResources.activeButtonColor
            border.width: 0
            onBtnClicked: {
                customLoader.pageLoader.setSource("qrc:/res/Qml/Pages/SettingsPage.qml", {
                    "settingsModel": applicationResources.getSetting("Settings")
                })
            }
        }
    }

    Loader {
        id: pagePopupLoader
        anchors.fill: page
    }
}
