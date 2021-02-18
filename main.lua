push = require 'push'

Class = require 'class'

require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    --additional change set new window title


    love.window.setTitle('Pong Dance')

    --initialize our sounds 
    intro = love.audio.newSource("sounds/prelude_int.mp3", "static")
    serve = love.audio.newSource("sounds/spring_sound.mp3", "static")
    pall = love.audio.newSource("sounds/bong_sound.mp3", "static")
    fail = love.audio.newSource("sounds/fail_sound.mp3", "static")
    game = love.audio.newSource("sounds/aquatic_amb.mp3", "static")
    --game = love.audio.newSource("sounds/badaba.mp3", "static")
    victory = love.audio.newSource("sounds/victoryffvii.mp3", "static")


    --set the volume of music in game to hear the sfx
    pall:setVolume(7)
    fail:setVolume(1000)
    game:setVolume(0.15)
    victory:setVolume(0.70) 

    math.randomseed(os.time())

    --initialize our font style 
    smallFont = love.graphics.newFont('font.ttf' , 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)

    bg = love.graphics.newImage("und_background.jpg")

    love.graphics.setFont(smallFont)

    --initialize window 
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT,{

        fullscreen = false,
        resizable = false,
        vsync = true

    })

    --initialize our paddles and ball
    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

    --initialize our pong ball

    ball  = Ball(VIRTUAL_WIDTH/2 - 2, VIRTUAL_HEIGHT/ 2 - 2, 4, 4)

    --initialize score variables
    player1Score = 0
    player2Score = 0

    --define our serving player 
    servingPlayer = 1; 

    gameState = 'start'
    intro:play()

end

--[[This function will run for every frame, dt, delta time in seconds, since 
last frame, is passed]]

function love.update(dt)

    if gameState == 'serve' then
        intro:stop()
        victory:stop()
        if servingPlayer == 1 then 
            ball.dx = math.random(140, 200)
        else
            ball.dx = -math.random(140, 200)
        end
        ball.dy = math.random(-50, 50) --initialize ball speed 

    elseif gameState == 'play' then

        --in this part we detect  the ball collision with the paddles, we reverse the speed if a collision is detected

        if ball:collides(player1) then 
            pall:play()
            ball.dx = - ball.dx * 1.03
            ball.x  = player1.x + 5

            if ball.dy < 0 then 
                ball.dy = - math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
        end

        if ball:collides(player2) then 
            pall:play()
            ball.dx = - ball.dx * 1.03
            ball.x  = player2.x - 4

            if ball.dy < 0 then 
                ball.dy = - math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
        end

        --define upper and lower screen boundaries for our ball 

        if ball.y <= 0 then 
            ball.y = 0
            ball.dy = -ball.dy
        end

        --we need to substract 4 to the virtual resolution to compensate for the size of our ball 

        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
        end

        --[[if we touch either the right or left side of the screen we ought to 
        restore the serve and update the score ]]

        if ball.x < 0 then
            fail:play()
            servingPlayer = 1
            player2Score = player2Score + 1

            --set the score that must be reached in order for the game to finish

            if player2Score == 3 then
                winningPlayer = 2
                gameState = 'done'
                game:stop()
                victory:play()
            else
                gameState = 'serve'

                -- recenter ball to serve
                ball:reset()
            end
        end

        --repeat for player 2

        if ball.x > VIRTUAL_WIDTH then
            fail:play()
            servingPlayer = 2
            player1Score = player1Score + 1
            
            if player1Score == 3 then
                winningPlayer = 1
                gameState = 'done'
                victory:play()
                game:stop()
            else
                gameState = 'serve'
                ball:reset()
            end
        end
    end

    -- player 1 movement
    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED

    elseif love.keyboard.isDown('s') then 
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

     -- player 2 movement
     if love.keyboard.isDown('up') then
        player2.dy = - PADDLE_SPEED

    elseif love.keyboard.isDown('down') then 
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0   
    end

    --update ball if the game is being played
    --scale velocity for framerate independent movement

    if gameState == 'play' then 
        ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)

end

--[[this function will define what each key will do in-game when pressed
each key is assigned a different instruction]]

function love.keypressed(key)

    if key == 'escape' then 
        love.event.quit()
    elseif key == 'enter' or key == 'return' then 
        if gameState == 'start' then
            gameState = 'serve'
            
        elseif gameState == 'serve' then
            gameState = 'play'
            game:play()
            serve:play()

        elseif gameState == 'done' then

            gameState = 'start'
            victory:stop()
            intro:play()
            
            ball:reset()
            --reset scores

            player1Score = 0
            player2Score = 0

            -- check who is serving next turn 

            if winningPlayer == 1 then 
                servingPlayer = 2
            else 
                servingPlayer = 1
            end
        end
    end
end

--function that will allow us to draw elements in screen 

function love.draw()

    --insert our background image

    love.graphics.draw(bg,VIRTUAL_WIDTH - 433, 0, 0, 0.6666, 0.6666)
    --[[for i = 0, love.graphics.getWidth() / bg:getWidth() do
        for j = 0, love.graphics.getHeight() / bg:getHeight() do
            love.graphics.draw(bg, i * bg:getWidth(), j * bg:getHeight())
        end
    end]]

    push:start()

    --love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    --love.graphics.printf('Hello Pong!', 0, 20, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(smallFont)
    displayScore()

    --[[the setColor function will allow us to change the color of individual elements, we need to reset the color after we have
    colored eahc element so that eahc element maintains their color ]]

    if gameState == 'start' then

        love.graphics.setFont(smallFont)
        love.graphics.setColor(100, 0, 200)
        love.graphics.printf('Welcome to P O N G! ---- ポンへようこそ!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to begin the battles!', 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.setColor(255, 255, 255)

    elseif gameState == 'serve' then

        love.graphics.setFont(smallFont)
        love.graphics.setColor(100, 0, 200)
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.setColor(255, 255, 255)

    elseif gameState == 'play' then
    elseif gameState == 'done' then

        love.graphics.setFont(largeFont)
        love.graphics.setColor(100, 0, 200)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
        love.graphics.setColor(255, 255, 255)

    end


    player1:render()
    player2:render()
    ball:render()


    push:apply('end')

end

--draw our score in the screen

function displayScore()

    love.graphics.setFont(scoreFont)
    love.graphics.setColor(0, 100, 200)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30,VIRTUAL_HEIGHT / 3)
    love.graphics.setColor(255, 255, 255)

end