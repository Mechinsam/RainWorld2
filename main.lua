-- main.lua
local slugcat
local background
local slugcatNormal
local slugcatPop
local clickCount = 0
local saveFile = "clickcount.txt"
local font
local music

function love.load()
    -- Загрузка ресурсов
    love.window.setMode(600, 600)
    love.window.setTitle("Rain World 2 (NOT FAKE 100% TRUE)")

    background = love.graphics.newImage("assets/background.png")
    slugcatNormal = love.graphics.newImage("assets/slugcat.png")
    slugcatPop = love.graphics.newImage("assets/slugcatpop.png")
    slugcat = slugcatNormal

    -- Загрузка сохраненного счётчика нажатий
    if love.filesystem.getInfo(saveFile) then
        local contents = love.filesystem.read(saveFile)
        clickCount = tonumber(contents) or 0
    end

    -- Загрузка шрифта для счётчика
    font = love.graphics.newFont(32)

    -- Загрузка и проигрывание музыки
    music = love.audio.newSource("assets/threat.mp3", "stream")
    music:setLooping(true)
    love.audio.play(music)
end

function love.draw()
    -- Рисуем фон
    love.graphics.draw(background, 0, 0)

    -- Рисуем картинку slugcat по центру экрана
    love.graphics.draw(slugcat, (love.graphics.getWidth() - slugcat:getWidth()) / 2, (love.graphics.getHeight() - slugcat:getHeight()) / 2)

    -- Рисуем счётчик по центру сверху
    love.graphics.setFont(font)
    love.graphics.printf("Clicks: " .. clickCount, 0, 10, love.graphics.getWidth(), "center")
end

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then -- Левая кнопка мыши
        clickCount = clickCount + 1
        slugcat = slugcatPop -- Меняем картинку на другую
    end
end

function love.mousereleased(x, y, button, istouch, presses)
    if button == 1 then
        slugcat = slugcatNormal -- Возвращаем оригинальную картинку
    end
end

function love.quit()
    -- Сохраняем счётчик перед выходом
    love.filesystem.write(saveFile, tostring(clickCount))
end
