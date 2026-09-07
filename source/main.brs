sub Main(args as Dynamic)
    screen = CreateObject("roSGScreen")
    port = CreateObject("roMessagePort")
    screen.SetMessagePort(port)

    m.global = screen.GetGlobalNode()
    m.global.addFields({
        selectedStationId: "",
        isPlaying: false,
        nowPlayingTitle: "TTNS FM",
        listFilterTick: 0,
        chatLeaveTick: 0,
        chatToggleTick: 0,
        planPickTick: 0,
        planPickIndex: 0
    })

    scene = screen.CreateScene("MainScene")
    screen.Show()
    scene.ObserveField("exitApp", port)

    while true
        msg = wait(0, port)
        msgType = type(msg)
        if msgType = "roSGScreenEvent"
            if msg.IsScreenClosed() then return
        else if msgType = "roSGNodeEvent"
            if msg.GetField() = "exitApp" and msg.GetData() = true then return
        end if
    end while
end sub
