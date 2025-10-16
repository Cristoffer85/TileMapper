function love.conf(t)
    t.accelerometerjoystick = false
 
    t.window.title = "TileMapper"
    t.window.width = 1200
    t.window.height = 700
    t.window.resizable = true
    t.window.fullscreen = false
    t.window.fullscreentype = "desktop"
    
    t.modules.audio = false
    t.modules.joystick = false
    t.modules.physics = false
    t.modules.sound = false
    t.modules.touch = false
    t.modules.video = false
end