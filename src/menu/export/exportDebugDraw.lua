-- Draws the export debug log on screen (bottom left)
return function()
    if not _G.exportDebugLog or #_G.exportDebugLog == 0 then return end
    love.graphics.setColor(1, 1, 0, 0.8)
    local y = love.graphics.getHeight() - 18 * math.min(20, #_G.exportDebugLog)
    for i, msg in ipairs(_G.exportDebugLog) do
        love.graphics.print(msg, 8, y + (i-1)*18)
    end
    love.graphics.setColor(1, 1, 1, 1)
end