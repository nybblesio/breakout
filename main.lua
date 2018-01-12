-- breakout development exercise
-- https://nybbles.io

function intersects(hb1, hb2)
    local ax2 = hb1.x + hb1.w
    local ay2 = hb1.y + hb1.h
    local bx2 = hb2.x + hb2.w
    local by2 = hb2.y + hb2.h
    return hb1.x < bx2 and ax2 > hb2.x and hb1.y < by2 and ay2 > hb1.y
end

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

-- xxx: need to implement a floor/min for dt based adjustments
level = { 
    active_background = nil,
    
    pieces = {
        new_piece = function(self, type, x, y, image)
            local piece = {
                type = type,
                
                x = x,
                
                y = y,
                              
                state = "solid",
                
                image = image,
                
                hit_box = function(p)
                    return {x = p.x + 42, y = p.y + 52, w = 69, h = 32}
                end,
            
                update = function(p, dt)
                    for _, ball in ipairs(level.balls) do
                        if intersects(ball:hit_box_piece(), p:hit_box()) then
                            if p.state == "solid" then
                                ball:bounce()
                                p.state = "cracked"
                            elseif p.state == "cracked" then
                                ball:bounce()
                                level.player.score = level.player.score + 100
                                p.state = "destroyed"
                            end
                        end
                            
                    end
                end,
            
                draw = function(p)
                    if p.state == "solid" then
                        love.graphics.draw(p.image.default, p.x, p.y, 0, .3, .3)
                    elseif p.state == "cracked" then
                        love.graphics.draw(p.image.cracked, p.x, p.y, 0, .3, .3)                     
                        love.graphics.draw(particle_system, p.x, p.y)
                    end

                    --local hb = p:hit_box()
                    --love.graphics.rectangle('line', hb.x, hb.y, hb.w, hb.h)
                end,
            }
            table.insert(self, piece)
            return piece
        end,
    },
    
    balls = {
        launch_if_attached = function(self)
            for _, ball in ipairs(level.balls) do
                if ball.state == "attached" then
                    ball.state = "active"
                    ball.dx = love.math.random(385, 690)
                    ball.dy = -love.math.random(400, 725)
                end
            end
        end,
    
        new_ball = function(self, x, y, dx, dy, image)
            local ball = {
                x = x,
                
                y = y,
                
                dx = dx,
                
                dy = dy,
                
                state = "attached",
                
                image = image,
                
                hit_box_bat = function(b)
                    return {x = b.x + 5, y = b.y + 28, w = 22, h = 2}
                end,
            
                hit_box_piece = function(b)
                    return {x = b.x + 12, y = b.y + 15, w = 6, h = 2}
                end,
            
                bounce = function(b)
                    -- xxx: need to vary velocity and direction
                    b.dx = -(b.dx + love.math.random(-125, 125))
                    b.dy = -(b.dy + love.math.random(-75, 75))
                end,
                
                update = function(b, dt)
                    if b.state == "lost" then
                        return
                    elseif b.state == "attached" then
                        b.x = level.player.x + 55
                        b.y = level.player.y + 20
                    else
                        b.x = b.x + (b.dx * dt)
                    
                        if b.x < 5 or b.x > 980 then
                            b.dx = -b.dx
                        end
                        
                        b.y = b.y + (b.dy * dt)
                        
                        if b.y < 5 then
                            b.dy = -b.dy
                        end
                        
                        if b.y > 960 then
                            b.state = "lost"
                            
                            level.player.paddles = level.player.paddles - 1
                            
                            -- xxx: this is temporary
                            b.x = level.player.x
                            b.y = level.player.y
                            b.dx = 0
                            b.dy = 0
                            b.state = "attached"
                        end
                    end
                    
                    local bhb = b:hit_box_bat()
                    local phb = level.player:hit_box()
                    if intersects(phb, bhb) then
                        b:bounce()
                    end 
                end,
           
                draw = function(b, dt)
                    love.graphics.draw(b.image, b.x, b.y, 0, .06, .06)
                    
                    local hbb = b:hit_box_bat()
                    love.graphics.rectangle('line', hbb.x, hbb.y, hbb.w, hbb.h)
                    
                    local hbp = b:hit_box_piece()
                    love.graphics.rectangle('line', hbp.x, hbp.y, hbp.w, hbp.h)
                end,
            }
            table.insert(self, ball)
            return ball
        end,
    },
    
    player = {
        score = 0,
        
        paddles = 3,
        
        x = love.graphics.getWidth() / 2,
        
        y = love.graphics.getHeight() - 100,
        
        active_bat = nil,
        
        hit_box = function(self)
            return {x = self.x + 9, y = self.y + 55, w = 139, h = 30}
        end,
    
        update = function(self, dt)
            self.x = love.mouse.getX()
            
            if self.x < 10 then
                self.x = 10
            elseif self.x > 850 then
                self.x = 850
            end
        end,

        draw = function(self)
            love.graphics.draw(self.active_bat, self.x, self.y, 0, .3, .3)
            local hb = self:hit_box()
            love.graphics.rectangle('line', hb.x, hb.y, hb.w, hb.h)
        end
    },

    update = function(self, dt)
        self.player:update(dt)
        for _, piece in ipairs(self.pieces) do
            piece:update(dt)
        end
        for _, ball in ipairs(self.balls) do
            ball:update(dt)
        end
    end,

    draw = function(self)
        if self.active_background ~= nil then
            love.graphics.draw(self.active_background, 0, 0)  
        end    
        for _, piece in ipairs(self.pieces) do
            piece:draw()
        end
        for _, ball in ipairs(self.balls) do
            ball:draw()
        end
        self.player:draw()
        
        love.graphics.print(string.format("SCORE %05d", self.player.score), 20, 20)
        love.graphics.print(string.format("PADDLES %02d", self.player.paddles), love.graphics.getWidth() - 175, 20)
    end,
}

-- love2d framework callbacks
function love.load()
    if arg[#arg] == "-debug" then 
        require("mobdebug").start() 
    end  

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
    
    game_font = love.graphics.newFont("assets/Tapper.ttf", 14)
    love.graphics.setFont(game_font)
    
    local smoke_image = love.graphics.newImage("assets/smoke.png")
    
    particle_system = love.graphics.newParticleSystem(smoke_image, 32)
    particle_system:setParticleLifetime(2, 5)
    particle_system:setEmissionRate(5)
    particle_system:setSizeVariation(1)
    particle_system:setLinearAcceleration(-20, -20, 20, 20)
    particle_system:setColors(255, 255, 255, 255, 255, 255, 255, 0)
    
    level.active_background = background
    level.player.active_bat = bats.black
    
    -- this is temporary
    level.balls:new_ball(level.player.x, level.player.y, 0, 0, balls.silver)
    
    for y = 1, 10 * 38, 38 do
        for x = 1, 12 * 78, 78 do
            level.pieces:new_piece('brick', x, y, bricks.blue)
        end
    end
end

function love.update(dt)
    particle_system:update(dt)
    timers:update()
    level:update(dt)
end

function love.draw()
    level:draw()
end

-- user input callbacks
function love.mousepressed(x, y, button, istouch)
    if button == 1 then
        level.balls:launch_if_attached()
    end
end

function love.keypressed(key)
end

-- window callbacks
function love.focus(f)
end

function love.quit()
end
