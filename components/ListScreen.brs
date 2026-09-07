sub init()
    m.top.focusable = true
    m.grid = m.top.findNode("grid")
    m.picker = m.top.findNode("picker")
    m.pickerList = m.top.findNode("pickerList")
    m.pickerTitle = m.top.findNode("pickerTitle")
    m.whenBorder = m.top.findNode("whenBorder")
    m.whenFill = m.top.findNode("whenFill")
    m.whenLabel = m.top.findNode("whenLabel")
    m.facetBorder = m.top.findNode("facetBorder")
    m.facetFill = m.top.findNode("facetFill")
    m.facetLabel = m.top.findNode("facetLabel")
    m.plansBorder = m.top.findNode("plansBorder")
    m.plansFill = m.top.findNode("plansFill")
    m.plansLabel = m.top.findNode("plansLabel")
    m.loadingPane = m.top.findNode("loadingPane")
    m.spinner = m.top.findNode("spinner")
    m.loadingLabel = m.top.findNode("loadingLabel")
    m.loadPulse = m.top.findNode("loadPulse")

    m.allItems = []
    m.shown = []
    m.filterIndex = 0
    m.gridIndex = 0
    m.zone = "filters"
    m.whenId = "all"
    m.facetId = "all"
    m.pickerKind = ""
    m.pickerIndex = 0
    m.whenOptions = [
        { id: "all", label: "All upcoming" },
        { id: "this-week", label: "This week" },
        { id: "next-week", label: "Next week" },
        { id: "this-month", label: "This month" }
    ]
    m.facetOptions = []

    m.grid.focusable = false
    m.pickerList.focusable = false
    m.whenBorder.focusable = false
    m.facetBorder.focusable = false
    m.plansBorder.focusable = false
    wireChipFocus()
    paintFilters()
end sub

function takeFocus() as Boolean
    m.top.visible = true
    if m.picker.visible = true
        holdListFocus()
    else if m.zone = "grid" and m.shown.Count() > 0
        focusGrid()
    else
        focusFirstChip()
    end if
    return true
end function

function beginLoad() as Boolean
    m.allItems = []
    m.shown = []
    m.whenId = "all"
    m.facetId = "all"
    m.filterIndex = 0
    m.zone = "filters"
    layoutFilters()
    wireChipFocus()
    m.grid.content = CreateObject("roSGNode", "ContentNode")
    showLoading()
    focusFirstChip()
    return true
end function

function setItems(items as Object) as Boolean
    if items = invalid then items = []
    m.allItems = items
    m.whenId = "all"
    m.facetId = "all"
    m.filterIndex = 0
    m.gridIndex = 0
    layoutFilters()
    wireChipFocus()
    rebuildFacetOptions()
    applyFilters()
    hideLoading()
    if m.shown.Count() > 0
        focusGrid()
    else
        focusFirstChip()
    end if
    return true
end function

sub showLoading()
    if m.top.kind = "community"
        m.loadingLabel.text = "Loading the community board..."
    else
        m.loadingLabel.text = "Loading gigs..."
    end if
    m.grid.visible = false
    m.loadingPane.visible = true
    m.spinner.control = "start"
    m.loadPulse.control = "start"
end sub

sub hideLoading()
    m.spinner.control = "stop"
    m.loadPulse.control = "stop"
    m.loadingLabel.opacity = 1
    m.loadingPane.visible = false
    m.grid.visible = true
end sub

function getSelectedItem() as Object
    idx = m.top.selectedIndex
    if idx < 0 then return invalid
    if idx >= m.shown.Count() then return invalid
    return m.shown[idx]
end function

sub layoutFilters()
    if m.top.kind = "community"
        m.whenBorder.visible = false
        m.whenFill.visible = false
        m.whenLabel.visible = false
        m.facetBorder.translation = [80, 152]
        m.facetFill.translation = [86, 158]
        m.facetLabel.translation = [80, 152]
        m.facetBorder.width = 900
        m.facetFill.width = 888
        m.facetLabel.width = 900
        m.plansBorder.translation = [1000, 152]
        m.plansFill.translation = [1006, 158]
        m.plansLabel.translation = [1000, 152]
        m.plansBorder.width = 840
        m.plansFill.width = 828
        m.plansLabel.width = 840
    else
        m.whenBorder.visible = true
        m.whenFill.visible = true
        m.whenLabel.visible = true
        m.facetBorder.translation = [600, 152]
        m.facetFill.translation = [606, 158]
        m.facetLabel.translation = [600, 152]
        m.facetBorder.width = 700
        m.facetFill.width = 688
        m.facetLabel.width = 700
        m.plansBorder.translation = [1320, 152]
        m.plansFill.translation = [1326, 158]
        m.plansLabel.translation = [1320, 152]
        m.plansBorder.width = 520
        m.plansFill.width = 508
        m.plansLabel.width = 520
    end if
    wireChipFocus()
end sub

sub wireChipFocus()
    m.whenBorder.focusable = false
    m.facetBorder.focusable = false
    m.plansBorder.focusable = false
    m.grid.focusable = false
    m.pickerList.focusable = false
end sub

sub holdListFocus()
    m.top.setFocus(true)
end sub

sub clearCardFocus()
    if m.global <> invalid then m.global.listFocusIndex = -1
end sub

sub focusFirstChip()
    m.zone = "filters"
    m.filterIndex = 0
    clearCardFocus()
    holdListFocus()
    paintFilters()
end sub

sub focusChipByIndex()
    m.zone = "filters"
    clearCardFocus()
    holdListFocus()
    paintFilters()
end sub

sub focusGrid()
    if m.shown.Count() < 1
        focusFirstChip()
        return
    end if
    m.zone = "grid"
    if m.gridIndex < 0 then m.gridIndex = 0
    if m.gridIndex >= m.shown.Count() then m.gridIndex = 0
    paintFilters()
    syncGridCursor()
    holdListFocus()
end sub

sub syncGridCursor()
    idx = m.gridIndex
    if idx < 0 then idx = 0
    lastIdx = m.shown.Count() - 1
    if lastIdx >= 0 and idx > lastIdx then idx = lastIdx
    m.gridIndex = idx
    m.grid.jumpToItem = idx
    if m.global <> invalid then m.global.listFocusIndex = idx
end sub

sub moveGrid(dx as Integer, dy as Integer)
    cols = 5
    count = m.shown.Count()
    if count < 1 then return
    idx = m.gridIndex
    if idx < 0 then idx = 0
    if dy < 0 and idx < cols
        focusChipByIndex()
        return
    end if
    idx = idx + dx + (dy * cols)
    if idx < 0 then idx = 0
    if idx > count - 1 then idx = count - 1
    m.gridIndex = idx
    syncGridCursor()
end sub

function lastFilterIndex() as Integer
    if m.top.kind = "community" then return 1
    return 2
end function

function currentFilterKind() as String
    if m.top.kind = "community"
        if m.filterIndex = 0 then return "facet"
        return "plans"
    end if
    if m.filterIndex = 0 then return "when"
    if m.filterIndex = 1 then return "facet"
    return "plans"
end function

sub rebuildFacetOptions()
    options = []
    if m.top.kind = "community"
        options.Push({ id: "all", label: "All" })
        options.Push({ id: "acts", label: "Acts and DJs" })
        options.Push({ id: "directory", label: "Directory" })
        options.Push({ id: "services", label: "Services" })
        options.Push({ id: "kit_for_sale", label: "Kit for sale" })
        options.Push({ id: "kit_wanted", label: "Kit wanted" })
        options.Push({ id: "artists_wanted", label: "Artists wanted" })
        options.Push({ id: "gig_request", label: "Request an Act / DJ" })
    else
        options.Push({ id: "all", label: "All venues" })
        seen = {}
        names = []
        for each item in m.allItems
            venue = TrimText(item.venue)
            if venue <> "" and seen[venue] = invalid
                seen[venue] = true
                names.Push(venue)
            end if
        end for
        names.Sort()
        for each venue in names
            options.Push({ id: venue, label: venue })
        end for
    end if
    m.facetOptions = options
end sub

sub applyFilters()
    filtered = []
    for each item in m.allItems
        if itemMatches(item) = true then filtered.Push(item)
    end for
    shown = filtered
    if shown.Count() > 40
        slim = []
        for i = 0 to 39
            slim.Push(shown[i])
        end for
        shown = slim
    end if
    m.shown = shown
    root = CreateObject("roSGNode", "ContentNode")
    i = 0
    for each item in shown
        node = root.createChild("ContentNode")
        node.title = FirstNonEmpty([item.title, "Untitled"])
        venue = TrimText(item.venue)
        whenLabel = TrimText(item.whenLabel)
        if venue <> ""
            node.description = venue
        else
            node.description = TrimText(item.subtitle)
        end if
        if whenLabel <> ""
            node.ShortDescriptionLine1 = whenLabel
        else
            node.ShortDescriptionLine1 = TrimText(item.category)
        end if
        posterUrl = SafeHttpUrl(TrimText(item.imageUrl))
        if posterUrl <> "" then node.HDPosterUrl = posterUrl
        node.addFields({ gridIndex: i })
        i = i + 1
    end for
    m.grid.content = root
    paintFilterLabels()
end sub

function itemMatches(item as Object) as Boolean
    if m.top.kind = "community"
        if m.facetId <> "all"
            if TrimText(item.categoryId) <> m.facetId then return false
        end if
        return true
    end if
    if WhenMatchesFilter(TrimText(item.whenIso), m.whenId) <> true then return false
    if m.facetId <> "all"
        if TrimText(item.venue) <> m.facetId then return false
    end if
    return true
end function

sub paintFilterLabels()
    m.whenLabel.text = "When  -  " + WhenFilterLabel(m.whenId)
    facetName = "All venues"
    if m.top.kind = "community" then facetName = "All"
    for each opt in m.facetOptions
        if opt.id = m.facetId then facetName = opt.label
    end for
    if m.top.kind = "community"
        m.facetLabel.text = "Category  -  " + facetName
    else
        m.facetLabel.text = "Venue  -  " + facetName
    end if
end sub

sub paintFilters()
    m.whenBorder.color = "0x2A2A2AFF"
    m.facetBorder.color = "0x2A2A2AFF"
    m.plansBorder.color = "0x2A2A2AFF"
    m.whenFill.color = "0x161616FF"
    m.facetFill.color = "0x161616FF"
    m.plansFill.color = "0x161616FF"
    m.whenLabel.color = "0xF6F7F4FF"
    m.facetLabel.color = "0xF6F7F4FF"
    m.plansLabel.color = "0xF6F7F4FF"
    if m.zone <> "filters" then return
    kind = currentFilterKind()
    if kind = "when"
        m.whenBorder.color = "0x00FF00FF"
        m.whenFill.color = "0x1C2A16FF"
        m.whenLabel.color = "0x00FF00FF"
    else if kind = "facet"
        m.facetBorder.color = "0x00FF00FF"
        m.facetFill.color = "0x1C2A16FF"
        m.facetLabel.color = "0x00FF00FF"
    else
        m.plansBorder.color = "0x00FF00FF"
        m.plansFill.color = "0x1C2A16FF"
        m.plansLabel.color = "0x00FF00FF"
    end if
end sub

sub openPicker(kind as String)
    options = m.whenOptions
    title = "When"
    currentId = m.whenId
    if kind = "facet"
        options = m.facetOptions
        currentId = m.facetId
        if m.top.kind = "community"
            title = "Category"
        else
            title = "Venue"
        end if
    end if
    root = CreateObject("roSGNode", "ContentNode")
    jump = 0
    i = 0
    for each opt in options
        node = root.createChild("ContentNode")
        node.title = opt.label
        if opt.id = currentId then jump = i
        i = i + 1
    end for
    m.pickerKind = kind
    m.pickerIndex = jump
    m.pickerTitle.text = title
    m.pickerList.content = root
    m.picker.visible = true
    syncPickerCursor()
    holdListFocus()
end sub

function pickerCount() as Integer
    if m.pickerKind = "when" then return m.whenOptions.Count()
    return m.facetOptions.Count()
end function

sub syncPickerCursor()
    lastIdx = pickerCount() - 1
    if lastIdx < 0 then return
    if m.pickerIndex < 0 then m.pickerIndex = 0
    if m.pickerIndex > lastIdx then m.pickerIndex = lastIdx
    m.pickerList.jumpToItem = m.pickerIndex
    m.pickerList.itemFocused = m.pickerIndex
end sub

sub movePicker(direction as Integer)
    m.pickerIndex = m.pickerIndex + direction
    syncPickerCursor()
end sub

sub applyPickerChoice()
    idx = m.pickerIndex
    if m.pickerKind = "when"
        if idx >= 0 and idx < m.whenOptions.Count()
            chosen = m.whenOptions[idx]
            m.whenId = chosen.id
        end if
    else
        if idx >= 0 and idx < m.facetOptions.Count()
            chosen = m.facetOptions[idx]
            m.facetId = chosen.id
        end if
    end if
    applyFilters()
    m.gridIndex = 0
end sub

sub closePicker()
    m.picker.visible = false
    m.pickerKind = ""
    if m.shown.Count() > 0
        focusGrid()
    else
        focusChipByIndex()
    end if
end sub

sub moveFilter(direction as Integer)
    m.filterIndex = m.filterIndex + direction
    lastIdx = lastFilterIndex()
    if m.filterIndex < 0 then m.filterIndex = 0
    if m.filterIndex > lastIdx then m.filterIndex = lastIdx
    focusChipByIndex()
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    if m.picker.visible = true
        if key = "back"
            closePicker()
            return true
        else if key = "up"
            movePicker(-1)
            return true
        else if key = "down"
            movePicker(1)
            return true
        else if key = "OK" or key = "play"
            applyPickerChoice()
            closePicker()
            return true
        end if
        return true
    end if
    if key = "back"
        m.top.action = "home"
        return true
    end if
    if key = "rewind"
        if m.zone = "grid"
            focusChipByIndex()
        else
            moveFilter(-1)
        end if
        return true
    else if key = "fastforward"
        if m.zone = "grid"
            focusChipByIndex()
        else
            moveFilter(1)
        end if
        return true
    end if
    if m.zone = "grid"
        if key = "up"
            moveGrid(0, -1)
            return true
        else if key = "down"
            moveGrid(0, 1)
            return true
        else if key = "left"
            moveGrid(-1, 0)
            return true
        else if key = "right"
            moveGrid(1, 0)
            return true
        else if key = "OK" or key = "play"
            m.top.selectedIndex = m.gridIndex
            m.top.action = "open"
            return true
        end if
        return true
    end if
    if key = "right"
        moveFilter(1)
        return true
    else if key = "left"
        moveFilter(-1)
        return true
    else if key = "down"
        focusGrid()
        return true
    else if key = "OK" or key = "play"
        kind = currentFilterKind()
        if kind = "plans"
            m.top.action = "plans"
        else
            openPicker(kind)
        end if
        return true
    end if
    return false
end function
