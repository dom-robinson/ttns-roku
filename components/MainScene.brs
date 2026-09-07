sub init()
    m.player = m.top.findNode("player")
    m.home = m.top.findNode("home")
    m.playerUi = m.top.findNode("playerUi")
    m.list = m.top.findNode("list")
    m.detail = m.top.findNode("detail")
    m.about = m.top.findNode("about")
    m.plans = m.top.findNode("plans")
    m.hint = m.top.findNode("hint")

    m.global.selectedStationId = ReadStationId()
    m.currentScreen = "home"
    m.wantPlay = false

    m.player.observeField("state", "onPlayerState")
    m.home.observeField("action", "onHomeAction")
    m.playerUi.observeField("action", "onPlayerAction")
    m.about.observeField("action", "onAboutAction")
    m.plans.observeField("action", "onPlansAction")
    m.list.observeField("action", "onListAction")
    m.detail.observeField("action", "onDetailAction")
    m.hint.observeField("visible", "onHintVisible")
    m.listItems = []
    m.detailWebUrl = NationalSiteUrl()

    m.home.callFunc("takeFocus")
end sub

sub hideAll()
    m.home.visible = false
    m.playerUi.visible = false
    m.list.visible = false
    m.detail.visible = false
    m.about.visible = false
    m.plans.visible = false
end sub

sub showHome()
    hideAll()
    m.home.visible = true
    m.currentScreen = "home"
    m.home.callFunc("reloadHome")
    m.home.callFunc("takeFocus")
end sub

sub showPlayer()
    hideAll()
    m.playerUi.visible = true
    m.currentScreen = "player"
    m.playerUi.callFunc("takeFocus")
end sub

sub showAbout()
    hideAll()
    m.about.visible = true
    m.currentScreen = "about"
    m.about.callFunc("takeFocus")
end sub

sub showPlans()
    hideAll()
    m.plans.visible = true
    m.currentScreen = "plans"
    m.plans.callFunc("takeFocus")
end sub

sub showList()
    hideAll()
    m.list.visible = true
    m.currentScreen = "list"
    m.list.callFunc("takeFocus")
end sub

sub showDetail()
    hideAll()
    m.detail.visible = true
    m.currentScreen = "detail"
    m.detail.callFunc("takeFocus")
end sub

sub restoreFocusAfterHint()
    if m.currentScreen = "detail"
        m.detail.callFunc("takeFocus")
    else if m.currentScreen = "plans"
        m.plans.callFunc("takeFocus")
    else if m.currentScreen = "about"
        m.about.callFunc("takeFocus")
    else if m.currentScreen = "player"
        m.playerUi.callFunc("takeFocus")
    else if m.currentScreen = "list"
        m.list.callFunc("takeFocus")
    else
        m.home.callFunc("takeFocus")
    end if
end sub

sub onHomeAction()
    action = m.home.action
    if action = "listen"
        station = GetSelectedStation()
        if station.comingSoon = true
            showAbout()
        else
            applyStationToPlayer(true)
            showPlayer()
        end if
    else if action = "web"
        showAbout()
    else if action = "plans"
        showPlans()
    else if action = "gigs"
        openList("gigs")
    else if action = "community"
        openList("community")
    else if action = "station"
        if m.wantPlay = true
            applyStationToPlayer(true)
        end if
    else if action = "exit"
        m.top.exitApp = true
    end if
end sub

sub onPlayerAction()
    action = m.playerUi.action
    if action = "toggle"
        togglePlayback()
    else if action = "home"
        showHome()
    else if action = "prevStation"
        shiftLiveStation(-1)
    else if action = "nextStation"
        shiftLiveStation(1)
    end if
end sub

sub onAboutAction()
    if m.about.action = "home" then showHome()
end sub

sub onPlansAction()
    if m.plans.action = "home"
        showHome()
    end if
end sub

sub onHintVisible()
    if m.hint.visible = false then restoreFocusAfterHint()
end sub

sub shiftLiveStation(direction as Integer)
    currentId = ReadStationId()
    nextId = CycleLiveStationId(currentId, direction)
    if nextId = currentId then return
    WriteStationId(nextId)
    m.global.selectedStationId = nextId
    applyStationToPlayer(m.wantPlay)
end sub

sub applyStationToPlayer(playNow as Boolean)
    station = GetSelectedStation()
    content = CreateObject("roSGNode", "ContentNode")
    content.url = station.streamUrl
    content.streamFormat = "mp3"
    content.title = "TTNS FM"
    m.player.content = content
    m.wantPlay = playNow
    if playNow = true
        m.player.control = "play"
    end if
    m.playerUi.stationLine = station.name
end sub

sub togglePlayback()
    state = m.player.state
    if state = "playing" or state = "buffering"
        m.wantPlay = false
        m.player.control = "stop"
        m.playerUi.isPlaying = false
        m.playerUi.statusLine = "Paused"
    else
        applyStationToPlayer(true)
    end if
end sub

sub onListAction()
    action = m.list.action
    if action = "open"
        openSelectedItem()
    else if action = "home"
        showHome()
    else if action = "plans"
        showPlans()
    end if
end sub

sub onDetailAction()
    action = m.detail.action
    if action = "web"
        m.hint.titleText = "Open this on your phone"
        m.hint.bodyText = "Tickets, replies, and sign-up stay on the website. Open this address on your phone or laptop."
        m.hint.urlText = m.detailWebUrl
        m.hint.callFunc("present")
    else if action = "back"
        showList()
    end if
end sub

sub openList(kind as String)
    city = CityForListings(GetSelectedStation())
    m.list.kind = kind
    m.list.callFunc("beginLoad")
    if kind = "gigs"
        m.list.heading = "Gigs  -  " + city.name
        m.list.statusLine = "Loading posters and this month's listings..."
        task = CreateObject("roSGNode", "ScheduleTask")
        task.apiBaseUrl = city.apiBaseUrl
        task.days = 14
        task.observeField("ready", "onGigsReady")
        m.gigsTask = task
        task.control = "RUN"
    else
        m.list.heading = "Community  -  " + city.name
        m.list.statusLine = "Loading the local board..."
        task = CreateObject("roSGNode", "CommunityTask")
        task.apiBaseUrl = city.apiBaseUrl
        task.observeField("ready", "onCommunityReady")
        m.communityTask = task
        task.control = "RUN"
    end if
    showList()
end sub

sub onGigsReady()
    task = m.gigsTask
    if task = invalid then return
    if task.ready <> true then return
    events = task.events
    items = []
    if events <> invalid
        for each ev in events
            items.Push({
                id: ev.id,
                kind: "gig",
                title: ev.title,
                subtitle: ev.subtitle,
                body: ev.description,
                imageUrl: ev.imageUrl,
                venue: ev.venue,
                whenIso: ev.whenIso,
                whenLabel: ev.whenLabel,
                categoryId: "",
                webPath: "/"
            })
        end for
    end if
    m.listItems = items
    m.list.callFunc("setItems", items)
    city = CityForListings(GetSelectedStation())
    if task.error <> ""
        m.list.statusLine = task.error
    else if items.Count() = 0
        m.list.statusLine = "No gigs in the next few weeks. Check " + city.siteUrl + " on your phone."
    else
        n = items.Count()
        m.list.statusLine = n.ToStr() + " upcoming  -  When / Venue to filter  -  OK for details"
    end if
end sub

sub onCommunityReady()
    task = m.communityTask
    if task = invalid then return
    if task.ready <> true then return
    items = task.items
    if items = invalid then items = []
    m.listItems = items
    m.list.callFunc("setItems", items)
    city = CityForListings(GetSelectedStation())
    if task.error <> ""
        m.list.statusLine = task.error
    else if items.Count() = 0
        m.list.statusLine = "Nothing on the board just now. Browse " + city.siteUrl + "/community on your phone."
    else
        n = items.Count()
        m.list.statusLine = n.ToStr() + " listings  -  Category to filter  -  post on the website"
    end if
end sub

sub openSelectedItem()
    item = m.list.callFunc("getSelectedItem")
    if item = invalid then return
    city = CityForListings(GetSelectedStation())
    path = TrimText(item.webPath)
    if path = "" then path = "/"
    m.detailWebUrl = city.siteUrl + path
    m.detail.titleText = item.title
    m.detail.metaText = item.subtitle
    m.detail.bodyText = FirstNonEmpty([item.body, "No extra details on the TV app."])
    m.detail.artworkUrl = TrimText(item.imageUrl)
    if item.kind = "gig"
        m.detail.hintText = "To book tickets, open " + city.siteUrl + " on your phone or laptop."
    else
        m.detail.hintText = "To reply, post, or sign up, open " + city.siteUrl + "/community on your phone or laptop."
    end if
    showDetail()
end sub

sub onPlayerState()
    state = m.player.state
    playing = false
    if state = "playing" or state = "buffering" then playing = true
    m.playerUi.isPlaying = playing
    m.global.isPlaying = playing
    if state = "playing"
        m.playerUi.statusLine = "Live"
    else if state = "buffering"
        m.playerUi.statusLine = "Connecting..."
    else if state = "error"
        m.playerUi.statusLine = "Could not start the stream"
    else if m.wantPlay = false
        m.playerUi.statusLine = "Paused"
    end if
end sub
