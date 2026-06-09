import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.models.quickToggles
import qs.modules.common.functions
import qs.modules.common.widgets

Item {
    id: root

    // Info to be passed to by repeaterestou
    required property int buttonIndex
    required property var buttonData
    required property real baseCellWidth
    required property real baseCellHeight
    required property real cellSpacing
    required property int cellSize

    readonly property bool isWide: Layout.columnSpan > 1
    readonly property bool isTall: Layout.rowSpan > 1
    readonly property bool expandedSize: isWide

    // Signals
    signal openMenu

    // Declared in specific toggles
    property QuickToggleModel toggleModel
    property string name: toggleModel?.name ?? ""
    property string statusText: (toggleModel?.hasStatusText) ? (toggleModel?.statusText || (root.toggled ? Translation.tr("Active") : Translation.tr("Inactive"))) : ""
    property string tooltipText: toggleModel?.tooltipText ?? ""
    property string buttonIcon: toggleModel?.icon ?? "close"
    property bool available: toggleModel?.available ?? true
    property bool toggled: toggleModel?.toggled ?? false
    property var mainAction: toggleModel?.mainAction ?? null
    property var altAction: toggleModel?.hasMenu ? (() => root.openMenu()) : (toggleModel?.altAction ?? null)

    // Edit mode state
    property bool editMode: false
    property bool isUnused: false // injected by delegate chooser
    property bool isDragging: false
    property real dragAbsX: 0
    property real dragAbsY: 0
    property int pageIndex: 0

    // Sizing shenanigans
    Layout.columnSpan: root.buttonData.sizeW ?? root.buttonData.size ?? 1
    Layout.rowSpan: root.buttonData.sizeH ?? 1
    Layout.preferredWidth: root.implicitWidth
    Layout.preferredHeight: root.implicitHeight
    Layout.fillWidth: false
    Layout.fillHeight: false

    property real baseWidth: root.baseCellWidth * Layout.columnSpan + cellSpacing * (Layout.columnSpan - 1)
    property real baseHeight: root.baseCellHeight * Layout.rowSpan + cellSpacing * (Layout.rowSpan - 1)

    implicitWidth: baseWidth
    implicitHeight: baseHeight
    
    // Ghost block visibility when dragging
    Rectangle {
        anchors.fill: parent
        radius: Appearance.rounding.normal
        color: Appearance.colors.colSurfaceContainer
        border.color: Appearance.colors.colOutlineVariant
        border.width: 1
        visible: root.isDragging
        opacity: 0.5
    }

    GroupButton {
        id: visualButton
        
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

        enableImplicitWidthAnimation: !root.editMode && visualButton.mouseArea.containsMouse
        enableImplicitHeightAnimation: !root.editMode && visualButton.mouseArea.containsMouse

        enabled: root.available || root.editMode
        padding: 6
        horizontalPadding: padding
        verticalPadding: padding

        colBackground: Appearance.colors.colLayer2
        colBackgroundToggled: (root.altAction && root.expandedSize) ? Appearance.colors.colLayer2 : Appearance.colors.colPrimary
        colBackgroundToggledHover: (root.altAction && root.expandedSize) ? Appearance.colors.colLayer2Hover : Appearance.colors.colPrimaryHover
        colBackgroundToggledActive: (root.altAction && root.expandedSize) ? Appearance.colors.colLayer2Active : Appearance.colors.colPrimaryActive
        readonly property int fullRadius: Config.options.appearance.sharpMode ? Appearance.rounding.full : height / 2
        buttonRadius: (root.toggled || root.isTall) ? Appearance.rounding.large : fullRadius
        buttonRadiusPressed: Appearance.rounding.normal
        property color colText: (root.toggled && !(root.altAction && root.expandedSize) && enabled) ? Appearance.colors.colOnPrimary : ColorUtils.transparentize(Appearance.colors.colOnLayer2, enabled ? 0 : 0.7)
        property color colIcon: root.expandedSize ? ((root.toggled) ? Appearance.colors.colOnPrimary : Appearance.colors.colOnLayer3) : colText

        toggled: root.toggled
        altAction: root.altAction

        onClicked: {
            if (root.expandedSize && root.altAction)
                root.altAction();
            else
                root.mainAction();
        }

        contentItem: Loader {
            id: contentItemLoader
            anchors.fill: parent
            sourceComponent: (root.isWide && root.isTall) ? ios2x2Layout : standardLayout
        }

    Component {
        id: ios2x2Layout
        ColumnLayout {
            spacing: 0
            anchors {
                fill: parent
                leftMargin: visualButton.horizontalPadding + 10
                rightMargin: visualButton.horizontalPadding + 10
                topMargin: visualButton.verticalPadding + 4
                bottomMargin: visualButton.verticalPadding + 4
            }

            // Top section: Icon aligned to top-left
            MouseArea {
                id: iosIconMouseArea
                hoverEnabled: true
                acceptedButtons: root.altAction ? Qt.LeftButton : Qt.NoButton
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                Layout.preferredWidth: 38
                Layout.preferredHeight: 38
                cursorShape: Qt.PointingHandCursor

                onClicked: root.mainAction()

                Rectangle {
                    id: iosIconBackground
                    anchors.fill: parent
                    radius: width / 2
                    color: {
                        if (root.toggled) {
                            return root.altAction ? Appearance.colors.colPrimary : Appearance.colors.colPrimary;
                        } else {
                            return Appearance.colors.colLayer3;
                        }
                    }

                    Behavior on color {
                        animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
                    }

                    MaterialSymbol {
                        anchors.centerIn: parent
                        fill: root.toggled ? 1 : 0
                        iconSize: 22
                        color: root.toggled ? Appearance.colors.colOnPrimary : Appearance.colors.colOnLayer3
                        text: root.buttonIcon
                    }

                    // Hover/Press state layer
                    Loader {
                        anchors.fill: parent
                        active: root.altAction
                        sourceComponent: Rectangle {
                            radius: iosIconBackground.radius
                            color: ColorUtils.transparentize(visualButton.colIcon, iosIconMouseArea.containsPress ? 0.88 : iosIconMouseArea.containsMouse ? 0.95 : 1)
                            Behavior on color {
                                animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
                            }
                        }
                    }
                }
            }

            // Spacer
            Item {
                Layout.fillHeight: true
            }

            // Bottom section: Text aligned to bottom-left
            Column {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
                spacing: 0

                StyledText {
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    font.pixelSize: Appearance.font.pixelSize.small
                    font.weight: 600
                    color: visualButton.colText
                    elide: Text.ElideRight
                    text: root.name
                }

                StyledText {
                    visible: root.statusText !== ""
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    font {
                        pixelSize: Appearance.font.pixelSize.smaller
                        weight: 400
                    }
                    color: ColorUtils.transparentize(visualButton.colText, 0.3)
                    elide: Text.ElideRight
                    text: root.statusText
                }
            }
        }
    }

    Component {
        id: standardLayout
        RowLayout {
            spacing: root.isWide ? 10 : 4
            anchors {
                centerIn: root.isWide ? undefined : parent
                fill: root.isWide ? parent : undefined
                leftMargin: visualButton.horizontalPadding
                rightMargin: visualButton.horizontalPadding
            }

            // Icon
            MouseArea {
                id: iconMouseArea
                hoverEnabled: true
                acceptedButtons: (root.isWide && root.altAction) ? Qt.LeftButton : Qt.NoButton
                Layout.alignment: root.isWide ? Qt.AlignVCenter : Qt.AlignCenter
                Layout.fillHeight: root.isWide
                Layout.topMargin: root.isWide ? visualButton.verticalPadding : 0
                Layout.bottomMargin: root.isWide ? visualButton.verticalPadding : 0
                
                Layout.preferredWidth: (root.isWide && !root.toggled && !root.isTall) ? (root.baseCellHeight - visualButton.verticalPadding * 2) : (root.isWide ? (root.baseCellHeight - visualButton.verticalPadding * 2) : -1)
                Layout.preferredHeight: (!root.isWide && root.isTall) ? (root.baseHeight - visualButton.verticalPadding * 2) : -1

                implicitWidth: root.baseCellHeight - visualButton.verticalPadding * 2
                implicitHeight: root.baseCellHeight - visualButton.verticalPadding * 2
                cursorShape: Qt.PointingHandCursor

                onClicked: root.mainAction()

                Rectangle {
                    id: iconBackground
                    anchors.fill: parent
                    radius: {
                        if (root.isTall && !root.isWide) return Appearance.rounding.full;
                        if (root.isWide && !root.isTall && !root.toggled) return visualButton.radius - visualButton.verticalPadding;
                        return visualButton.radius - visualButton.verticalPadding;
                    }
                    color: {
                        const baseColor = root.toggled ? Appearance.colors.colPrimary : Appearance.colors.colLayer3;
                        const transparentizeAmount = (root.altAction && root.isWide) ? 0 : (root.toggled ? 0 : 1);
                        if (!root.toggled && root.isWide) return "transparent"; // fix the inactive circle background
                        return ColorUtils.transparentize(baseColor, transparentizeAmount);
                    }

                    Behavior on radius {
                        animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
                    }
                    Behavior on color {
                        animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
                    }

                    MaterialSymbol {
                        anchors.centerIn: parent
                        fill: root.toggled ? 1 : 0
                        iconSize: root.isWide ? 22 : 24
                        color: visualButton.colIcon
                        text: root.buttonIcon
                    }

                    // State layer
                    Loader {
                        anchors.fill: parent
                        active: (root.isWide && root.altAction)
                        sourceComponent: Rectangle {
                            radius: iconBackground.radius
                            color: ColorUtils.transparentize(visualButton.colIcon, iconMouseArea.containsPress ? 0.88 : iconMouseArea.containsMouse ? 0.95 : 1)
                            Behavior on color {
                                animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
                            }
                        }
                    }
                }
            }

            // Text column for expanded size
            Loader {
                Layout.alignment: root.isTall ? Qt.AlignTop : Qt.AlignVCenter
                Layout.topMargin: root.isTall ? visualButton.verticalPadding * 1.5 : 0
                Layout.leftMargin: 0 // Keep consistent spacing across toggles
                Layout.fillWidth: true
                visible: root.isWide
                active: visible
                sourceComponent: Column {
                    spacing: -2

                    StyledText {
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        font.pixelSize: Appearance.font.pixelSize.smallie
                        font.weight: 600
                        color: visualButton.colText
                        elide: Text.ElideRight
                        text: root.name
                    }

                    StyledText {
                        visible: root.statusText !== ""
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        font {
                            pixelSize: Appearance.font.pixelSize.smaller
                            weight: 100
                        }
                        color: visualButton.colText
                        elide: Text.ElideRight
                        text: root.statusText
                    }
                }
            }
        }
    }

        // Expose drag state to edit border
        property real editDragX: 0
        property real editDragY: 0
        property bool editingRight: false
        property bool editingBottom: false

        MouseArea { // Blocking MouseArea for edit interactions
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

            // list<var> returns a copy — MUST deep-clone, mutate, reassign
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
                        // Not in this page — add it
                        page.push({ type: buttonType, sizeW: 1, sizeH: 1, size: 1 });
                    } else {
                        // Already in this page — remove it
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
                            page[i].size = newW; // legacy compatibility
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

        Rectangle {
            id: editBorder
            anchors.fill: parent
            anchors.rightMargin: visualButton.editingRight ? -visualButton.editDragX : 0
            anchors.bottomMargin: visualButton.editingBottom ? -visualButton.editDragY : 0
            visible: root.editMode && !root.isUnused && !root.isDragging
            color: "transparent"
            border.color: Appearance.colors.colPrimary
            border.width: 2
            radius: visualButton.radius

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
                        if (newSizeW !== (root.buttonData.sizeW ?? root.buttonData.size ?? 1)) {
                            editModeInteraction.setSize(newSizeW, root.buttonData.sizeH ?? 1);
                        }
                    }
                }
            }

            Rectangle {
                id: bottomDragHandle
                height: 8
                width: 24
                radius: 4
                color: Appearance.colors.colPrimary
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: -height / 2

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -10
                    cursorShape: Qt.SizeVerCursor
                    preventStealing: true
                    property real pressAbsY: 0
                    onPressed: event => {
                        var absPos = visualButton.mapFromItem(bottomDragHandle, event.x, event.y);
                        pressAbsY = absPos.y;
                        visualButton.editingBottom = true;
                    }
                    onPositionChanged: event => {
                        var absPos = visualButton.mapFromItem(bottomDragHandle, event.x, event.y);
                        var dy = absPos.y - pressAbsY;
                        var currentH = root.buttonData.sizeH ?? 1;
                        visualButton.editDragY = Math.max(-root.baseCellHeight * (currentH - 1), Math.min(dy, root.baseCellHeight * (8 - currentH)));
                    }
                    onReleased: event => {
                        visualButton.editingBottom = false;
                        var currentH = root.buttonData.sizeH ?? 1;
                        var deltaRows = root.baseCellHeight > 0 ? Math.round(visualButton.editDragY / root.baseCellHeight) : 0;
                        var newSizeH = currentH + deltaRows;
                        if (isNaN(newSizeH)) newSizeH = currentH;
                        newSizeH = Math.max(1, Math.min(8, newSizeH));
                        
                        visualButton.editDragY = 0;
                        if (newSizeH !== (root.buttonData.sizeH ?? 1)) {
                            editModeInteraction.setSize(root.buttonData.sizeW ?? root.buttonData.size ?? 1, newSizeH);
                        }
                    }
                }
            }
        }

        Rectangle {
            id: unusedHoverOverlay
            anchors.fill: parent
            radius: visualButton.radius
            color: ColorUtils.transparentize(Appearance.colors.colLayer0, 0.2)
            visible: root.isUnused && editModeInteraction.containsMouse
            
            MaterialSymbol {
                anchors.centerIn: parent
                text: "add"
                iconSize: 28
                color: Appearance.colors.colOnLayer0
            }
        }

        StyledToolTip {
            extraVisibleCondition: root.tooltipText !== ""
            text: root.tooltipText
        }
    }
}
