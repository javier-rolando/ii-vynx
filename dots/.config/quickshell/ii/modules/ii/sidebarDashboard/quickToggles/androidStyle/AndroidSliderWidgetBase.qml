import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import qs.services
import qs.modules.common
import qs.modules.common.models.quickToggles
import qs.modules.common.functions
import qs.modules.common.widgets

Item {
    id: root

    required property int buttonIndex
    required property var buttonData
    required property real baseCellWidth
    required property real baseCellHeight
    required property real cellSpacing
    required property int cellSize

    property bool editMode: false
    property bool isUnused: false
    property bool isDragging: false
    property real dragAbsX: 0
    property real dragAbsY: 0
    property int pageIndex: 0

    property string tooltipText: ""

    property string materialSymbol: ""
    property string secondaryMaterialSymbol: ""
    property real sliderValue: 0
    signal moved(real value)
    
    // For specific toggles to handle right-click actions if they want
    signal openMenu

    Layout.columnSpan: root.buttonData.sizeW ?? root.buttonData.size ?? 4
    Layout.rowSpan: root.buttonData.sizeH ?? 1
    Layout.preferredWidth: root.implicitWidth
    Layout.preferredHeight: root.implicitHeight
    Layout.fillWidth: false
    Layout.fillHeight: false

    property real baseWidth: root.baseCellWidth * Layout.columnSpan + cellSpacing * (Layout.columnSpan - 1)
    property real baseHeight: root.baseCellHeight * Layout.rowSpan + cellSpacing * (Layout.rowSpan - 1)

    implicitWidth: baseWidth
    implicitHeight: baseHeight
    
    Rectangle {
        anchors.fill: parent
        radius: Appearance.rounding.large
        color: Appearance.colors.colSurfaceContainer
        border.color: Appearance.colors.colOutlineVariant
        border.width: 1
        visible: root.isDragging
        opacity: 0.5
    }

    Item {
        id: visualButton
        property bool hovered: editModeInteraction.containsMouse
        
        parent: root.pageIndex === -1 ? root : (root.parent ? root.parent.parent : root)
        
        x: root.isDragging ? dragAbsX : (root.pageIndex === -1 ? 0 : (root.parent ? root.parent.x + root.x : root.x))
        y: root.isDragging ? dragAbsY : (root.pageIndex === -1 ? 0 : (root.parent ? root.parent.y + root.y : root.y))
        
        Behavior on x {
            enabled: !root.isDragging
            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(visualButton)
        }
        Behavior on y {
            enabled: !root.isDragging
            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(visualButton)
        }
        
        width: root.width
        height: root.height

        scale: root.isDragging ? 1.05 : 1.0
        opacity: {
            if (root.isUnused) return 0.5;
            if (root.editMode && !root.isDragging) return 0.9;
            if (root.isDragging) return 0.95;
            return 1.0;
        }
        z: root.isDragging ? 99 : 1
        
        Behavior on scale {
            animation: Appearance.animation.clickBounce.numberAnimation.createObject(visualButton)
        }
        Behavior on opacity {
            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(visualButton)
        }

            StyledSlider {
                id: quickSlider
                anchors.fill: parent
                configuration: StyledSlider.Configuration.M
                stopIndicatorValues: []
                dividerValues: root.secondaryMaterialSymbol.length > 0 ? [secondaryIcon.iconLocation] : []
                value: root.sliderValue
                onMoved: root.moved(value)
                
                // To prevent flickable dragging when using slider
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.RightButton
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: root.openMenu()
                }

            MaterialSymbol {
                id: icon
                property bool nearFull: quickSlider.value >= 0.82
                anchors {
                    verticalCenter: quickSlider.verticalCenter
                    right: nearFull ? quickSlider.handle.right : quickSlider.right
                    rightMargin: nearFull ? 14 : 8
                }
                iconSize: 20
                color: nearFull ? Appearance.colors.colOnPrimary : Appearance.colors.colOnSecondaryContainer
                text: root.materialSymbol

                Behavior on color {
                    animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
                }
                Behavior on anchors.rightMargin {
                    animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                }
            }

            MaterialSymbol {
                id: secondaryIcon
                visible: root.secondaryMaterialSymbol.length > 0
                property real iconLocation: 0.3
                property bool nearIcon: iconLocation - quickSlider.value <= 0.1 && iconLocation - quickSlider.value > (quickSlider.handleWidth + 8 - 14) / quickSlider.effectiveDraggingWidth
                anchors {
                    verticalCenter: quickSlider.verticalCenter
                    right: nearIcon ? quickSlider.handle.right : quickSlider.right
                    rightMargin: nearIcon ? 14 : (1 - iconLocation) * quickSlider.effectiveDraggingWidth + quickSlider.rightPadding + 8
                }
                iconSize: 20
                color: quickSlider.value >= iconLocation - 0.1 ? Appearance.colors.colOnPrimary : Appearance.colors.colOnSecondaryContainer
                text: root.secondaryMaterialSymbol

                Behavior on color {
                    animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
                }
            }
        }

        // --- Edit Mode Logic ---
        property real editDragX: 0
        property real editDragY: 0
        property bool editingRight: false
        property bool editingBottom: false

        MouseArea {
            id: editModeInteraction
            visible: root.editMode
            anchors.fill: parent
            cursorShape: root.isDragging ? Qt.ClosedHandCursor : Qt.OpenHandCursor
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton
            
            property real pressAbsX: 0
            property real pressAbsY: 0
            property real initialVisualX: 0
            property real initialVisualY: 0

            function mutatePages(mutatorFn) {
                var cloned = JSON.parse(JSON.stringify(Config.options.sidebar.quickToggles.android.pages));
                mutatorFn(cloned);
                Config.options.sidebar.quickToggles.android.pages = cloned;
            }

            function toggleEnabled() {
                const buttonType = root.buttonData.type;
                const pi = root.pageIndex;

                mutatePages(function(pages) {
                    if (pi < 0 || pi >= pages.length) return;
                    var page = pages[pi];
                    var existingIdx = -1;
                    for (var i = 0; i < page.length; i++) {
                        if (page[i].type === buttonType) { existingIdx = i; break; }
                    }
                    if (existingIdx === -1) {
                        page.push({ type: buttonType, sizeW: 4, sizeH: 1, size: 4 });
                    } else {
                        page.splice(existingIdx, 1);
                    }
                });
            }

            function setSize(newW, newH) {
                const buttonType = root.buttonData.type;
                const pi = root.pageIndex;
                mutatePages(function(pages) {
                    if (pi < 0 || pi >= pages.length) return;
                    var page = pages[pi];
                    for (var i = 0; i < page.length; i++) {
                        if (page[i].type === buttonType) {
                            page[i].sizeW = newW;
                            page[i].sizeH = newH;
                            page[i].size = newW;
                            return;
                        }
                    }
                });
            }
            
            function checkForSwap(gridX, gridY) {
                if (!root.parent) return;
                var layout = root.parent;
                for (var i = 0; i < layout.children.length; i++) {
                    var sibling = layout.children[i];
                    if (sibling === root || !sibling.visible) continue;
                    
                    if (gridX >= sibling.x && gridX < sibling.x + sibling.width &&
                        gridY >= sibling.y && gridY < sibling.y + sibling.height) {
                        
                        if (sibling.buttonData && sibling.buttonData.type) {
                            var targetType = sibling.buttonData.type;
                            var myType = root.buttonData.type;
                            
                            mutatePages(function(pages) {
                                var page = pages[root.pageIndex];
                                if (!page) return;
                                
                                var myIdx = -1;
                                var targetIdx = -1;
                                for (var j = 0; j < page.length; j++) {
                                    if (page[j].type === myType) myIdx = j;
                                    if (page[j].type === targetType) targetIdx = j;
                                }
                                
                                if (myIdx !== -1 && targetIdx !== -1 && myIdx !== targetIdx) {
                                    var temp = page[myIdx];
                                    page[myIdx] = page[targetIdx];
                                    page[targetIdx] = temp;
                                }
                            });
                            break;
                        }
                    }
                }
            }

            onPressed: event => {
                var absPos = visualButton.parent.mapFromItem(editModeInteraction, event.x, event.y);
                pressAbsX = absPos.x;
                pressAbsY = absPos.y;
                initialVisualX = visualButton.x;
                initialVisualY = visualButton.y;
                root.isDragging = false;
            }
            
            onPositionChanged: event => {
                if (pressed) {
                    var absPos = visualButton.parent.mapFromItem(editModeInteraction, event.x, event.y);
                    var dx = absPos.x - pressAbsX;
                    var dy = absPos.y - pressAbsY;
                    
                    if (!root.isDragging && (Math.abs(dx) > 4 || Math.abs(dy) > 4)) {
                        root.isDragging = true;
                    }
                    
                    if (root.isDragging) {
                        root.dragAbsX = initialVisualX + dx;
                        root.dragAbsY = initialVisualY + dy;
                        
                        var centerX = root.dragAbsX + visualButton.width / 2;
                        var centerY = root.dragAbsY + visualButton.height / 2;
                        
                        var gridPos = root.parent.mapFromItem(visualButton.parent, centerX, centerY);
                        checkForSwap(gridPos.x, gridPos.y);
                    }
                }
            }

            onReleased: event => {
                if (root.isDragging) {
                    root.isDragging = false;
                } else {
                    if (!visualButton.editingRight && !visualButton.editingBottom)
                        toggleEnabled();
                }
            }
        }

        // Edit Border and Resize Handles
        Rectangle {
            id: editBorder
            anchors.fill: parent
            anchors.rightMargin: visualButton.editingRight ? -visualButton.editDragX : 0
            anchors.bottomMargin: visualButton.editingBottom ? -visualButton.editDragY : 0
            visible: root.editMode && !root.isUnused && !root.isDragging
            color: "transparent"
            border.color: Appearance.colors.colPrimary
            border.width: 2
            radius: Appearance.rounding.large

            Rectangle {
                id: rightDragHandle
                width: 8
                height: 24
                radius: 4
                color: Appearance.colors.colPrimary
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: -width / 2

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -10
                    cursorShape: Qt.SizeHorCursor
                    preventStealing: true
                    property real pressAbsX: 0
                    onPressed: event => {
                        var absPos = visualButton.mapFromItem(rightDragHandle, event.x, event.y);
                        pressAbsX = absPos.x;
                        visualButton.editingRight = true;
                    }
                    onPositionChanged: event => {
                        var absPos = visualButton.mapFromItem(rightDragHandle, event.x, event.y);
                        var dx = absPos.x - pressAbsX;
                        var currentW = root.buttonData.sizeW ?? 4;
                        visualButton.editDragX = Math.max(-root.baseCellWidth * (currentW - 1), Math.min(dx, root.baseCellWidth * (8 - currentW)));
                    }
                    onReleased: event => {
                        visualButton.editingRight = false;
                        var currentW = root.buttonData.sizeW ?? 4;
                        var deltaColumns = root.baseCellWidth > 0 ? Math.round(visualButton.editDragX / root.baseCellWidth) : 0;
                        var newSizeW = currentW + deltaColumns;
                        if (isNaN(newSizeW)) newSizeW = currentW;
                        newSizeW = Math.max(1, Math.min(8, newSizeW)); 
                        
                        visualButton.editDragX = 0;
                        if (newSizeW !== currentW) {
                            var currentH = root.buttonData.sizeH ?? 1;
                            editModeInteraction.setSize(newSizeW, currentH);
                        }
                    }
                }
            }
            
            // Sliders typically only support height 1, so no bottomDragHandle for now
        }

        Rectangle {
            id: unusedHoverOverlay
            anchors.fill: parent
            radius: Appearance.rounding.large
            color: ColorUtils.transparentize(Appearance.colors.colLayer0, 0.5)
            visible: root.isUnused && editModeInteraction.containsMouse
            
            MaterialSymbol {
                anchors.centerIn: parent
                text: "add"
                iconSize: 28
                color: Appearance.colors.colOnLayer0
            }
        }

        StyledToolTip {
            extraVisibleCondition: root.editMode && root.tooltipText !== ""
            text: root.tooltipText
        }
    }
}
