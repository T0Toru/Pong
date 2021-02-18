
Paddle = Class{}


--[[this function will create our paddle object and set the variables with their respective
values for use, position, dimensioning, et. are defined here]]
function Paddle:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.dy = 0
end

--update paddle values based on their screen movement

function Paddle:update(dt)

    if self.dy < 0 then
        self.y = math.max(0, self.y + self.dy * dt)

    else
        self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy * dt)
    end
end

--draw and show our paddles

function Paddle:render()
    love.graphics.setColor(0, 100, 255)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    love.graphics.setColor(255, 255, 255)
end