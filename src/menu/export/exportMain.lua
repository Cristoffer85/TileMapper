local export = {}
local lfs = love.filesystem

function export.txt(filePath)
	if type(filePath) ~= "string" then
		error("export.txt: filePath must be a string (file path), not a file handle. Update your export dialog to pass a string path.")
	end
	local f = io.open(filePath, "w")
	if not f then return end
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
	local f = io.open(filePath, "w")
	if not f then return end
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
	local f = io.open(filePath, "w")
	if not f then return end
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
	local tilesetPaths = grid.tilesetPaths or {}
	if #tilesetPaths == 0 then return end
	local filePath = mapFile
	if not filePath or type(filePath) ~= "string" then return end
	-- Always write to the same directory as the map file
	local dir = filePath:match("^(.*)[/\\]") or "."
	local indexPath = dir .. "/tilesetIndex.txt"
	local lines = {}
	for i, path in ipairs(tilesetPaths) do
		local name = path:match("([^/\\]+)$") or path
		table.insert(lines, (i-1) .. "," .. name)
	end
	local content = table.concat(lines, "\n")
	local f = io.open(indexPath, "w")
	if f then
		f:write(content)
		f:close()
	end
end

return export
