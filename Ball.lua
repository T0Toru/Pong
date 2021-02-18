--define it as a class 
Ball = Class{}

function Ball:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    --keep track of speed on 'x' and 'y' axis

    self.dy = math.random(2) == 1 and -100 or 100
    self.dx = math.random(2) == 1 and math.random(-100, -120) or math.random(100, 120)
end

--[[check a collision based on whether the rectangles overlapped, returns a true or false argument
we also check the limits of our paddles with their ownselves]]

function Ball:collides(paddle)
    if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then
        return false
    end 

    if self.y > paddle.y + paddle.height or paddle.y > self.y + self.height then
        return false
    end 

    --if none of the above is true, they are overlapping

    return true
end

--place the ball in the middle of the screen again

function Ball:reset()
    self.x = VIRTUAL_WIDTH / 2 - 2
    self.y = VIRTUAL_HEIGHT / 2 - 2
    self.dy = math.random(2) == 1 and -100 or 100
    self.dx = math.random(-50, 50)
end

--apply speed relative to position, scaled by deltaTime

function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

function Ball:render()
    love.graphics.setColor(100, 0, 255)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    love.graphics.setColor(255, 255, 255)
end