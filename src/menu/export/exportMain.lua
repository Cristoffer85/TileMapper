-- Global debug log for on-screen display
_G.exportDebugLog = _G.exportDebugLog or {}
local function logExportDebug(msg)
	table.insert(_G.exportDebugLog, tostring(msg))
	if #_G.exportDebugLog > 20 then table.remove(_G.exportDebugLog, 1) end
end
local export = {}
local lfs = love.filesystem

function export.txt(filePath)
	if type(filePath) ~= "string" then
		error("export.txt: filePath must be a string (file path), not a file handle. Update your export dialog to pass a string path.")
	end
	logExportDebug("[Export] export.txt called. filePath=" .. tostring(filePath))
	local f = io.open(filePath, "w")
	if not f then
		logExportDebug("[Export] Failed to open map file for writing: " .. tostring(filePath))
		return
	end
	export.txtMultiTileset(f)
	f:close()
	export.writeTilesetIndexFile(filePath)
	grid.isDirty = false
end

function export.txtMultiTileset(f)
	for row = 1, #grid.map do
		local line = {}
		for col = 1, #grid.map[row] do
			local tileId = grid.map[row][col]
			if tileId == 0 then
				table.insert(line, "0:0")
			else
				local tilesetIndex, localTileId = export.findTilesetForTile(tileId)
				table.insert(line, tilesetIndex .. ":" .. localTileId)
			end
		end
		if row < #grid.map then
			f:write(table.concat(line, ",") .. ",\n")
		else
			f:write(table.concat(line, ",") .. ",")
		end
	end
end

function export.findTilesetForTile(globalTileId)
	if not grid.tilesets or #grid.tilesets == 0 then
		return 0, globalTileId
	end
	for i, tileset in ipairs(grid.tilesets) do
		local nextStartId = (i < #grid.tilesets) and grid.tilesets[i + 1].startTileId or math.huge
		if globalTileId >= tileset.startTileId and globalTileId < nextStartId then
			local localTileId = globalTileId - tileset.startTileId + 1
			return i - 1, localTileId
		end
	end
	return 0, globalTileId
end

function export.lua(filePath)
	if type(filePath) ~= "string" then
		error("export.lua: filePath must be a string (file path), not a file handle. Update your export dialog to pass a string path.")
	end
	logExportDebug("[Export] export.lua called. filePath=" .. tostring(filePath))
	local f = io.open(filePath, "w")
	if not f then
		logExportDebug("[Export] Failed to open map file for writing: " .. tostring(filePath))
		return
	end
	f:write("local map = {\n")
	for row = 1, #grid.map do
		local line = {}
		for col = 1, #grid.map[row] do
			local tileId = grid.map[row][col]
			if tileId == 0 then
				table.insert(line, '"0:0"')
			else
				local tilesetIndex, localTileId = export.findTilesetForTile(tileId)
				table.insert(line, '"' .. tilesetIndex .. ':' .. localTileId .. '"')
			end
		end
		if row < #grid.map then
			f:write("  {" .. table.concat(line, ", ") .. "},\n")
		else
			f:write("  {" .. table.concat(line, ", ") .. "}\n")
		end
	end
	f:write("}\nreturn map")
	f:close()
	export.writeTilesetIndexFile(filePath)
	grid.isDirty = false
end

function export.json(filePath)
	if type(filePath) ~= "string" then
		error("export.json: filePath must be a string (file path), not a file handle. Update your export dialog to pass a string path.")
	end
	logExportDebug("[Export] export.json called. filePath=" .. tostring(filePath))
	local f = io.open(filePath, "w")
	if not f then
		logExportDebug("[Export] Failed to open map file for writing: " .. tostring(filePath))
		return
	end
	f:write("{\n\"map\" : [\n")
	for row = 1, #grid.map do
		local line = {}
		for col = 1, #grid.map[row] do
			local tileId = grid.map[row][col]
			if tileId == 0 then
				table.insert(line, '\"0:0\"')
			else
				local tilesetIndex, localTileId = export.findTilesetForTile(tileId)
				table.insert(line, '\"' .. tilesetIndex .. ':' .. localTileId .. '\"')
			end
		end
		if row < #grid.map then
			f:write("    [" .. table.concat(line, ", ") .. "],\n")
		else
			f:write("    [" .. table.concat(line, ", ") .. "]\n")
		end
	end
	f:write("]\n}")
	f:close()
	export.writeTilesetIndexFile(filePath)
	grid.isDirty = false
end

-- Helper: Write tilesetIndex.txt to the same directory as the exported map file
function export.writeTilesetIndexFile(mapFile)
	logExportDebug("[Export] writeTilesetIndexFile called. type=" .. type(mapFile) .. ", tostring=" .. tostring(mapFile))
	local tilesetPaths = grid.tilesetPaths or {}
	if #tilesetPaths == 0 then
		logExportDebug("[Export] No tileset paths found, not writing tilesetIndex.txt")
		return
	end
	logExportDebug("[Export] tilesetPaths: " .. table.concat(tilesetPaths, ", "))
	local filePath = mapFile
	if not filePath or type(filePath) ~= "string" then
		logExportDebug("[Export] Could not determine map file path for tilesetIndex.txt export")
		return
	end
	logExportDebug("[Export] Map file path: " .. tostring(filePath))
	-- Always write to the same directory as the map file
	local dir = filePath:match("^(.*)[/\\]") or "."
	local indexPath = dir .. "/tilesetIndex.txt"
	logExportDebug("[Export] Will write tilesetIndex.txt to: " .. tostring(indexPath))
	local lines = {}
	for i, path in ipairs(tilesetPaths) do
		local name = path:match("([^/\\]+)$") or path
		table.insert(lines, (i-1) .. "," .. name)
	end
	local content = table.concat(lines, "\n")
	logExportDebug("[Export] tilesetIndex.txt content: " .. content)
	local f = io.open(indexPath, "w")
	if f then
		f:write(content)
		f:close()
		logExportDebug("[Export] tilesetIndex.txt written successfully.")
	else
		logExportDebug("[Export] Failed to open tilesetIndex.txt for writing: " .. tostring(indexPath))
	end
end

return export
