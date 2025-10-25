local about = {}

function about.show()
  love.window.showMessageBox("About TileMapper", 
    "TileMapper v1.0\n\nA tile-based map editor built with Love2D\n\nFeatures:\n- Visual tile placement\n- Multiple export formats\n- Fullscreen support\n- Multiple Tileset handling", 
    "info")
end

return about
