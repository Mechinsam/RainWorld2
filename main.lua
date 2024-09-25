-- main.lua
local slugcat
local background
local slugcatNormal
local slugcatPop
local clickCount = 0
local saveFile = "clickcount.txt"
local font
local music
local inputText = ""
local useSofanthiel = false
local showShop = false
local shopButton
local backButton
local priceSlugbomb = 10000
local priceSaint = 100000
local boughtSlugbomb = false
local boughtSaint = false
local shopItems = {}
local musicFinished = false

function love.load()
    -- Загрузка ресурсов
    love.window.setMode(600, 600)
    love.window.setTitle("Rain World 2 (NOT FAKE 100% TRUE)")

    loadResources()

    -- Загрузка сохраненного счётчика нажатий
    if love.filesystem.getInfo(saveFile) then
        local contents = love.filesystem.read(saveFile)
        clickCount = tonumber(contents) or 0
    end

    -- Загрузка шрифта для счётчика
    font = love.graphics.newFont(32)

    -- Загрузка и проигрывание музыки
    playMusic()

    -- Кнопки
    shopButton = {x = 500, y = 500, width = 80, height = 80, image = love.graphics.newImage("assets/shop.png")}
    backButton = {x = 20, y = 20, width = 100, height = 40}

    -- Товары магазина
    table.insert(shopItems, {
        portrait = "assets/slugbomb_portrait.png",
        title = "Artificer",
        description = "Kaboom?",
        price = priceSlugbomb,
        onPurchase = function()
            clickCount = clickCount - priceSlugbomb
            boughtSlugbomb = true
            loadResources()
        end
    })

    table.insert(shopItems, {
        portrait = "assets/saint_portrait.png",
        title = "Saint",
        description = "YOU SHOULD ASCEND URSELF NOW!",
        price = priceSaint,
        onPurchase = function()
            clickCount = clickCount - priceSaint
            boughtSaint = true
            loadResources()
            playAscendMusic()
        end
    })
end

function loadResources()
    if boughtSaint then
        background = love.graphics.newImage("assets/saint.png")
        slugcatNormal = love.graphics.newImage("assets/you.png")
        slugcatPop = love.graphics.newImage("assets/you.png")
    elseif useSofanthiel then
        background = love.graphics.newImage("assets/background.png")
        slugcatNormal = love.graphics.newImage("assets/sofanthiel.png")
        slugcatPop = love.graphics.newImage("assets/sofanthielpop.png")
    else
        background = love.graphics.newImage("assets/background.png")
        if boughtSlugbomb then
            slugcatNormal = love.graphics.newImage("assets/slugbomb.png")
            slugcatPop = love.graphics.newImage("assets/slugbombpop.png")
        else
            slugcatNormal = love.graphics.newImage("assets/slugcat.png")
            slugcatPop = love.graphics.newImage("assets/slugcatpop.png")
        end
    end
    slugcat = slugcatNormal
end

function playMusic()
    if music then
        love.audio.stop(music) -- Останавливаем текущую музыку, если она играет
    end

    if useSofanthiel then
        music = love.audio.newSource("assets/sofanthiel.mp3", "stream")
    elseif boughtSaint then
        music = love.audio.newSource("assets/ascend.mp3", "stream")
        music:setLooping(false) -- Музыка не зацикливается
        music:play()
        music:setVolume(1)
    else
        music = love.audio.newSource("assets/threat.mp3", "stream")
        music:setLooping(true)
        love.audio.play(music)
    end
end

function playAscendMusic()
    if music then
        love.audio.stop(music)
    end
    music = love.audio.newSource("assets/ascend.mp3", "stream")
    music:setLooping(false) -- Музыка не зацикливается
    music:play()
end

function love.update(dt)
    if boughtSaint and not music:isPlaying() then
        love.event.quit() -- Закрытие игры после завершения музыки
    end
end

function love.draw()
    if showShop then
        drawShop()
    else
        -- Рисуем фон и основной экран
        love.graphics.draw(background, 0, 0)

        -- Рисуем картинку slugcat по центру экрана
        love.graphics.draw(slugcat, (love.graphics.getWidth() - slugcat:getWidth()) / 2, (love.graphics.getHeight() - slugcat:getHeight()) / 2)

        -- Рисуем счётчик по центру сверху
        love.graphics.setFont(font)
        love.graphics.printf("Clicks: " .. clickCount, 0, 10, love.graphics.getWidth(), "center")

        -- Рисуем кнопку "Магазин" в правом нижнем углу
        love.graphics.draw(shopButton.image, shopButton.x, shopButton.y, 0, shopButton.width / shopButton.image:getWidth(), shopButton.height / shopButton.image:getHeight())
    end
end

function drawShop()
    -- Рисуем черный экран
    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.clear()

    -- Рисуем товары магазина
    for i, item in ipairs(shopItems) do
        local yOffset = 200 + (i - 1) * 170
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", 50, yOffset, 500, 150)

        -- Рисуем портрет персонажа слева
        local portrait = love.graphics.newImage(item.portrait)
        love.graphics.draw(portrait, 60, yOffset + 10)

        -- Рисуем заголовок и описание
        love.graphics.setColor(0, 0, 0)
        love.graphics.setFont(love.graphics.newFont(24))
        love.graphics.printf(item.title, 180, yOffset + 20, 300)
        love.graphics.setFont(love.graphics.newFont(18))
        love.graphics.printf(item.description, 180, yOffset + 60, 300)

        -- Рисуем цену
        love.graphics.setFont(love.graphics.newFont(24))
        love.graphics.printf("Price: " .. item.price .. " clicks", 350, yOffset + 20, 150)
    end

    -- Рисуем кнопку "Назад"
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", backButton.x, backButton.y, backButton.width, backButton.height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Back", backButton.x, backButton.y + 10, backButton.width, "center")
end

function love.mousepressed(x, y, button, istouch, presses)
    if not showShop then
        if button == 1 then -- Левая кнопка мыши
            if x >= shopButton.x and x <= shopButton.x + shopButton.width and y >= shopButton.y and y <= shopButton.y + shopButton.height then
                showShop = true
            else
                clickCount = clickCount + 1
                slugcat = slugcatPop -- Меняем картинку на другую
            end
        end
    else
        if button == 1 then
            for i, item in ipairs(shopItems) do
                local yOffset = 200 + (i - 1) * 170
                if clickCount >= item.price and x >= 60 and x <= 560 and y >= yOffset and y <= yOffset + 150 then
                    item.onPurchase()
                    showShop = false
                end
            end

            -- Кнопка "Назад"
            if x >= backButton.x and x <= backButton.x + backButton.width and y >= backButton.y and y <= backButton.y + backButton.height then
                showShop = false
            end
        end
    end
end

function love.mousereleased(x, y, button, istouch, presses)
    if not showShop and button == 1 then
        slugcat = slugcatNormal -- Возвращаем оригинальную картинку
    end
end

function love.textinput(text)
    inputText = inputText .. text
    if string.find(inputText, "sofanthiel") then
        useSofanthiel = true
        loadResources()
        playMusic()
    elseif string.find(inputText, "givememymoney") then
        clickCount = clickCount + 100000
    end
end

function love.keypressed(key)
    if key == "backspace" and #inputText > 0 then
        inputText = inputText:sub(1, -2)
    end
end

function love.quit()
    -- Сохраняем счётчик перед выходом
    love.filesystem.write(saveFile, tostring(clickCount))
end
