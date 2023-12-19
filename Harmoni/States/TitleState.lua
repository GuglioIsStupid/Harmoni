local TitleState = State()

function TitleState:enter()
    songList = love.filesystem.getDirectoryItems("Music")
    randomSong = love.math.random(1,#songList)
    logo = love.graphics.newImage("Images/TITLE/logo.png")
    backgroundFade = {0}

    onTitle = true
    logoYPos = {20}
    titleState = 1
    curScreen = "title"


    H = love.graphics.newImage("Images/TITLE/H.png")
    R = love.graphics.newImage("Images/TITLE/R.png")  -- the notes in the background originally were part of the logo, thats why their file name is letters
    O = love.graphics.newImage("Images/TITLE/O.png")
    I = love.graphics.newImage("Images/TITLE/I.png")

    background = love.graphics.newImage("Music/" .. songList[randomSong] .. "/background.jpg")
    titleSong = love.audio.newSource("Music/" .. songList[randomSong] .. "/audio.mp3", "stream")
    chart = love.filesystem.load("Music/" .. songList[randomSong] .. "/chart.lua")()
    bumpChart = love.filesystem.load("Music/" .. songList[randomSong] .. "/chart.lua")()
    chartRandomXPositions = {}
    speed = 0.6
    for i = 1,#chart do
        table.insert(chartRandomXPositions, love.math.random(0,love.graphics.getWidth()))
    end  
    titleSong:play()
    MusicTime = 0
    logoSize = 1

    curSelection = 1
    buttonWidth = {0,0,0}

end

function TitleState:update(dt)
    MusicTime = MusicTime + (love.timer.getTime() * 1000) - (previousFrameTime or (love.timer.getTime()*1000))
    previousFrameTime = love.timer.getTime() * 1000

    for i = 1,#bumpChart do
        if -(MusicTime - bumpChart[i][1]) < 10 then
            table.remove(bumpChart, i)
            TitleState:logoBump()
            break
        end
    end
    for i = 1,3 do
        if i == curSelection then
            buttonWidth[i] = math.min(15, buttonWidth[i] + 250*dt)
        else
            buttonWidth[i] = math.max(0, buttonWidth[i] - 250*dt)
        end
    end

    logoSize = math.max(logoSize - 0.15*dt, 1)

    if Input:pressed("MenuConfirm") then
        if titleState == 1 then
            TitleState:switchMenu()

        elseif titleState == 2 then
            titleSongLocation = titleSong:tell()
            titleSongNumber = randomSong
            comingFromTitle = true
            onTitle = false
            titleSong:stop()
            State.switch(States.SongSelectState)
        end
    elseif Input:pressed("MenuDown") then
        if curSelection < 3 then
            curSelection = curSelection + 1
        else
            curSelection = 1
        end
    elseif Input:pressed("MenuUp") then
        if curSelection == 1 then
            curSelection = 3
        else
            curSelection = curSelection - 1
        end
    end

    if not titleSong:isPlaying() and onTitle then
        TitleState:PlayMenuMusic()
    end

    printableSpeed = speed *(logoSize+0.7)

end

function scrollTitleButtons(scroll)
    curSelection = curSelection-scroll
    if curSelection > 3 then
        curSelection = 1
    elseif curSelection < 1 then 
        curSelection = 3 
    end
end

function TitleState:switchMenu()
    Timer.tween(1, logoYPos, {-200}, "out-expo")
    titleState = 2
end

function TitleState:PlayMenuMusic()
    if titleSong then
        titleSong:stop()
    end

    randomSong = love.math.random(1,#songList)

    titleSong = love.audio.newSource("Music/" .. songList[randomSong] .. "/audio.mp3", "stream")
    background = love.graphics.newImage("Music/" .. songList[randomSong] .. "/background.jpg")
    titleSong = love.audio.newSource("Music/" .. songList[randomSong] .. "/audio.mp3", "stream")
    chart = love.filesystem.load("Music/" .. songList[randomSong] .. "/chart.lua")()
    bumpChart = love.filesystem.load("Music/" .. songList[randomSong] .. "/chart.lua")()
    chartRandomXPositions = {}
    speed = 0.6
    for i = 1,#chart do
        table.insert(chartRandomXPositions, love.math.random(0,love.graphics.getWidth()))
    end  
    titleSong:play()
    MusicTime = 0
    logoSize = 1
    titleSong:play()



    if backgroundFadeTween then Timer.cancel(backgroundFadeTween) end

    backgroundFadeTween = Timer.tween(0.1, backgroundFade, {1}, "linear", function()
        background = love.graphics.newImage("Music/" .. songList[randomSong] .. "/background.jpg")
        if backgroundFadeTween then Timer.cancel(backgroundFadeTween) end
        backgroundFadeTween = Timer.tween(0.1, backgroundFade, {0})
    end)
end

function TitleState:logoBump()
    logoSize = math.min(logoSize + 0.01, 1.3)
end
--there was never anything here
function TitleState:draw()
    love.graphics.setColor(1,1,1,0.5)

    love.graphics.draw(background, 0, 0, nil, love.graphics.getWidth()/background:getWidth(),love.graphics.getHeight()/background:getHeight())
    
    love.graphics.setColor(0,0,0,backgroundFade[1])
    love.graphics.rectangle("fill", 0,0,love.graphics.getWidth(),love.graphics.getHeight())
    love.graphics.setColor(1,1,1,1)
    love.graphics.translate(0,-100)
    for i = 1,#chart do
        if -(MusicTime - chart[i][1])*speed < love.graphics.getHeight()+100 then
            love.graphics.setColor(1,1,1,0.1)

            
            if chart[i][2] == 1 then
                love.graphics.draw(H, chartRandomXPositions[i], -(MusicTime - chart[i][1])*printableSpeed)
            elseif chart[i][2] == 2 then
                love.graphics.draw(R, chartRandomXPositions[i], -(MusicTime - chart[i][1])*printableSpeed)
            elseif chart[i][2] == 3 then
                love.graphics.draw(O, chartRandomXPositions[i], -(MusicTime - chart[i][1])*printableSpeed)
            elseif chart[i][2] == 4 then
                love.graphics.draw(I, chartRandomXPositions[i], -(MusicTime - chart[i][1])*printableSpeed)
            end

            --]]
            love.graphics.setColor(1,1,1,1)
        end
    end
    love.graphics.translate(love.graphics.getWidth()/2-logo:getWidth()/2,logoYPos[1])


    love.graphics.draw(logo, logo:getWidth()/2, love.graphics.getHeight()/2-logo:getHeight()/2+100, nil, logoSize, math.min(logoSize+((logoSize-1)*3), 1.5), logo:getWidth()/2, logo:getHeight()/2)
    love.graphics.translate(0,logoYPos[1])
    love.graphics.rectangle("line", logo:getWidth()/2-120-buttonWidth[3], 850, 240+(buttonWidth[3]*2), 25)
    love.graphics.setFont(MenuFontExtraSmall)

    love.graphics.printf("Marge Simpson Tiddy Gallery", logo:getWidth()/2-120, 850, 240, "center")
    love.graphics.setFont(MenuFontSmall)


    love.graphics.translate(0,-30)
    love.graphics.rectangle("line", logo:getWidth()/2-120-buttonWidth[2], 850, 240+(buttonWidth[2]*2), 25)
    love.graphics.printf("Options", logo:getWidth()/2-120, 850, 240, "center")



    love.graphics.translate(0,-30)
    love.graphics.rectangle("line", logo:getWidth()/2-120-buttonWidth[1], 850, 240+(buttonWidth[1]*2), 25)
    love.graphics.printf("Play", logo:getWidth()/2-120, 850, 240, "center")


end

return TitleState