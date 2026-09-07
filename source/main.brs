sub Main(args as Dynamic)
    screen = CreateObject("roSGScreen")
    port = CreateObject("roMessagePort")
    screen.SetMessagePort(port)

    contentId = AssocLookup(args, "contentId")
    mediaType = AssocLookup(args, "mediaType")

    m.global = screen.GetGlobalNode()
    m.global.addFields({
        selectedStationId: "",
        isPlaying: false,
        nowPlayingTitle: "TTNS FM",
        listFocusIndex: -1,
        chatFocusIndex: -1,
        planFocusIndex: 0,
        launchContentId: contentId,
        launchMediaType: mediaType
    })

    scene = screen.CreateScene("MainScene")
    screen.Show()
    scene.ObserveField("exitApp", port)

    input = CreateObject("roInput")
    input.SetMessagePort(port)
    StartMemoryMonitor(port)

    while true
        msg = wait(0, port)
        msgType = type(msg)
        if msgType = "roSGScreenEvent"
            if msg.IsScreenClosed() then return
        else if msgType = "roSGNodeEvent"
            if msg.GetField() = "exitApp" and msg.GetData() = true then return
        else if msgType = "roInputEvent"
            if msg.IsInput()
                info = msg.GetInfo()
                scene.inputContentId = AssocLookup(info, "contentId")
                scene.inputMediaType = AssocLookup(info, "mediaType")
                tick = scene.inputTick
                scene.inputTick = tick + 1
            end if
        else if msgType = "roAppMemoryNotificationEvent"
            ' Roku asked us to subscribe. Dropping chat later if this ever gets noisy.
        else if msgType = "roDeviceInfoEvent"
            ' Legacy low-memory path on older chipsets.
        end if
    end while
end sub
