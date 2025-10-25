local controls = {}

function controls.show()
  love.window.showMessageBox("Controls", 
    "Mouse Controls:\n- Left Click: Place tile\n- Right Click: Erase\n- Mouse Wheel: Zoom (map area) or Scroll (tileset area)\n\nKeyboard:\n- F11 or Alt+Enter: Toggle fullscreen\n- WASD: Move camera\n- Ctrl +/-: Zoom in/out\n\nMenu: Use the menu bar above", 
    "info")
end

return controls
