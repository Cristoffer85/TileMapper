local export = {}

function export.txt(file)
	if grid.multiTilesetMode then
		export.txtMultiTileset(file)
	else
		export.txtSingleTileset(file)
	end
end

function export.txtSingleTileset(file)
	for i = 1, #grid.map-1 do
		file:write(tostring(table.concat(grid.map[i], ","))..",\n")
	end
	file:write(tostring(table.concat(grid.map[#grid.map], ","))..",")
end

function export.txtMultiTileset(file)
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
			file:write(table.concat(line, ",") .. ",\n")
		else
			file:write(table.concat(line, ",") .. ",")
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

function export.lua(file)
	file:write("local map = {\n")
	for row = 1, #grid.map do
		local line = {}
		for col = 1, #grid.map[row] do
			local tileId = grid.map[row][col]
			if grid.multiTilesetMode then
				if tileId == 0 then
					table.insert(line, '"0:0"')
				else
					local tilesetIndex, localTileId = export.findTilesetForTile(tileId)
					table.insert(line, '"' .. tilesetIndex .. ':' .. localTileId .. '"')
				end
			else
				table.insert(line, tostring(tileId))
			end
		end
		if row < #grid.map then
			file:write("  {" .. table.concat(line, ", ") .. "},\n")
		else
			file:write("  {" .. table.concat(line, ", ") .. "}\n")
		end
	end
	file:write("}\nreturn map")
end

function export.json(file)
	file:write("{\n\"map\" : [\n")
	for row = 1, #grid.map do
		local line = {}
		for col = 1, #grid.map[row] do
			local tileId = grid.map[row][col]
			if grid.multiTilesetMode then
				if tileId == 0 then
					table.insert(line, '\"0:0\"')
				else
					local tilesetIndex, localTileId = export.findTilesetForTile(tileId)
					table.insert(line, '\"' .. tilesetIndex .. ':' .. localTileId .. '\"')
				end
			else
				table.insert(line, tostring(tileId))
			end
		end
		if row < #grid.map then
			file:write("    [" .. table.concat(line, ", ") .. "],\n")
		else
			file:write("    [" .. table.concat(line, ", ") .. "]\n")
		end
	end
	file:write("]\n}")
end

return export
