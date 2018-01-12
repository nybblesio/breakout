-- breakout development exercise
-- https://nybbles.io

timers = {
  update = function(self)
    for _, t in ipairs(self) do
      t:update()
    end
  end,
  
  start = function(self, duration, callback)
    local timer = {
      expired = false,
      
      duration = duration,
      
      callback = callback,
      
      start_time = love.timer.getTime(),
      
      is_expired = function(t)
        local delta = (love.timer.getTime() - t.start_time) * 1000
        return delta > t.duration
      end,
  
      kill = function(t)
        table.remove(self, t)
      end,
    
      reset = function(t)
        t.expired = false
        t.start_time = love.timer.getTime()
      end,
    
      update = function(t)
        if t.expired then
          return
        end
        if t:is_expired() then
          t.expired = true
          if t.callback ~= nil then
            t:callback()
          end
        end
      end
    }
    table.insert(self, timer)
    return timer
  end
}

level = {    
    pieces = {},
    
    player = {
        x = 480,
        
        y = 850,
        
        active_bat = nil,
        
        update = function(self)
            self.x = love.mouse.getX()
            
            if self.x < 10 then
                self.x = 10
            elseif self.x > 850 then
                self.x = 850
            end
        end,

        draw = function(self)
            love.graphics.draw(self.active_bat, self.x, self.y, 0, .3, .3)
        end
    },

    update = function(self)
        for _, piece in ipairs(self.pieces) do
            piece:update()
        end
        self.player:update()
    end,

    draw = function(self)
        love.graphics.draw(background, 0, 0)  
        for _, piece in ipairs(self.pieces) do
            piece:draw()
        end
        self.player:draw()
    end,
}

-- love2d framework callbacks
function love.load()
    background = love.graphics.newImage("assets/backgrounds/background.jpg")
    
    wall_pieces = {
        brick = love.graphics.newImage("assets/walls/brick.png"),
        brick_blue = love.graphics.newImage("assets/walls/brick_blue.png"),
        brick_pink = love.graphics.newImage("assets/walls/brick_pink_side.png"),
        brick_red = love.graphics.newImage("assets/walls/brick_red.png")
    }
    
    balls = {
        blue = love.graphics.newImage("assets/balls/ball_blue.png"),
        green = love.graphics.newImage("assets/balls/ball_green.png"),
        orange = love.graphics.newImage("assets/balls/ball_orange.png"),
        red = love.graphics.newImage("assets/balls/ball_red.png"),
        silver = love.graphics.newImage("assets/balls/ball_silver.png"),
        yellow = love.graphics.newImage("assets/balls/ball_yellow.png")
    }
    
    power_ups = {
        star = love.graphics.newImage("assets/power-ups/star.png"),
        star_blue = love.graphics.newImage("assets/power-ups/star_blue.png"),
        star_green = love.graphics.newImage("assets/power-ups/star_green.png"),
        star_red = love.graphics.newImage("assets/power-ups/star_red.png")
    }
    
    bricks = {
        blue = {
            default = love.graphics.newImage("assets/bricks/brick_blue_small.png"),
            cracked = love.graphics.newImage("assets/bricks/brick_blue_small_cracked.png")
        },
    
        green = {
            default = love.graphics.newImage("assets/bricks/brick_green_small.png"),
            cracked = love.graphics.newImage("assets/bricks/brick_green_small_cracked.png")
        },
    
        pink = {
            default = love.graphics.newImage("assets/bricks/brick_pink_small.png"),
            cracked = love.graphics.newImage("assets/bricks/brick_pink_small_cracked.png")
        },
        
        violet = {
            default = love.graphics.newImage("assets/bricks/brick_violet_small.png"),
            cracked = love.graphics.newImage("assets/bricks/brick_violet_small_cracked.png")
        },
    
        yellow = {
            default = love.graphics.newImage("assets/bricks/brick_yellow_small.png"),
            cracked = love.graphics.newImage("assets/bricks/brick_yellow_small_cracked.png")
        }
    }
    
    bats = {
        black = love.graphics.newImage("assets/bats/bat_black.png"),
        blue = love.graphics.newImage("assets/bats/bat_blue.png"),
        orange = love.graphics.newImage("assets/bats/bat_orange.png"),
        pink = love.graphics.newImage("assets/bats/bat_pink.png"),
        yellow = love.graphics.newImage("assets/bats/bat_yellow.png")
    }
    
    level.player.active_bat = bats.black
end

function love.update(dt)
    timers:update()
    level:update()
end

function love.draw()
    level:draw()
end

-- user input callbacks
function love.mousepressed(x, y, button, istouch)
end

function love.mousereleased(x, y, button, istouch)
end

function love.keypressed(key)
end

-- window callbacks
function love.focus(f)
end

function love.quit()
end
