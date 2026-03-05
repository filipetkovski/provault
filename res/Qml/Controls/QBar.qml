import QtQuick
import QtQuick.Layouts

Item {
    id: root
    implicitHeight: 42

    property alias tabTitle1: btn1.btnText
    property alias tabTitle2: btn2.btnText
    property alias tabTitle3: btn3.btnText
    property var tabSource1
    property var tabSource2
    property var tabSource3
    property var profile

    function changeTab(newTab) {
        if(newTab !== selectedTab)
            selectedTab = newTab

        if(applicationResources.shieldModel.deviceModel.isModelChanged() || applicationResources.cloakModel.deviceModel.isModelChanged())
            openRegistryPopup()
        if(applicationResources.shieldModel.networkModel.modelChanged || applicationResources.cloakModel.networkModel.modelChanged)
            openAddressPopup()
        else
            openNewTab()
    }

    function openRegistryPopup() {
        customLoader.pagePopupLoader.sourceComponent = saveRegistryBeforeExitComponent
        customLoader.pagePopupLoader.item.open()
        customLoader.pagePopupLoader.item.deviceModel = deviceModel
        customLoader.pagePopupLoader.item.modelType = modelType
        customLoader.pagePopupLoader.item.profile = registriesPageLoader.item.checkedRadio
        customLoader.pagePopupLoader.item.onClosed.connect(function() {
            openNewTab()
        })
    }

    function openAddressPopup() {
        customLoader.pagePopupLoader.sourceComponent = saveAddressBeforeExitComponent
        customLoader.pagePopupLoader.item.open()
        customLoader.pagePopupLoader.item.networkModel = networkModel
        customLoader.pagePopupLoader.item.onClosed.connect(function() {
            openNewTab()
        })
    }

    function openNewTab() {
        switch (selectedTab) {
            case 0:
                if(profile !== undefined)
                    registriesPageLoader.setSource(tabSource1, {"deviceProfile": profile})
                else
                    registriesPageLoader.source = tabSource1
                break
            case 1: registriesPageLoader.source = tabSource2; break
            case 2: registriesPageLoader.source = tabSource3; break
        }
    }

    RowLayout {
        height: 37
        spacing: 50

        QButton {
            id: btn1
            Layout.alignment: Qt.AlignLeft | Qt.AlingBottom
            color: applicationResources.backgroundColor
            border.width: 0
            btnFontSize: 20
            onBtnClicked: changeTab(0)
        }

        QButton {
            id: btn2
            Layout.alignment: Qt.AlignRight | Qt.AlingBottom
            color: applicationResources.backgroundColor
            btnFontSize: 20
            border.width: 0
            onBtnClicked: changeTab(1)
        }

        QButton {
            id: btn3
            Layout.alignment: Qt.AlignRight | Qt.AlingBottom
            color: applicationResources.backgroundColor
            btnFontSize: 20
            border.width: 0
            onBtnClicked: changeTab(2)
        }
    }

    RowLayout {
        width: parent.width; height: 5
        anchors.bottom: parent.bottom
        spacing: 0

        Rectangle {
            implicitWidth: btn1.width
            implicitHeight: selectedTab == 0 ? 5 : 1
            color: selectedTab == 0 ? applicationResources.secondaryColor : applicationResources.darkGrayColor

            Behavior on implicitHeight {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Rectangle {
            implicitWidth: 50
            implicitHeight: 1
            color: applicationResources.darkGrayColor
        }

        Rectangle {
            implicitWidth: btn2.width
            implicitHeight: selectedTab == 1 ? 5 : 1
            color: selectedTab == 1 ? applicationResources.secondaryColor : applicationResources.darkGrayColor

            Behavior on implicitHeight {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Rectangle {
            implicitWidth: 50
            implicitHeight: 1
            color: applicationResources.darkGrayColor
        }

        Rectangle {
            implicitWidth: btn3.width
            implicitHeight: selectedTab == 2 ? 5 : 1
            color: selectedTab == 2 ? applicationResources.secondaryColor : applicationResources.darkGrayColor

            Behavior on implicitHeight {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1
            color: applicationResources.darkGrayColor
        }
    }
}
