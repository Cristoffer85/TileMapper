local import = {}

function import.txt(file)
	grid.map = {}
	local isMultiTilesetFormat = false
	-- Check first line to determine format
	local firstLine = file:read("*line")
	if firstLine and string.find(firstLine, ":") then
		isMultiTilesetFormat = true
	end
	file:seek("set", 0)
	if isMultiTilesetFormat then
		import.txtMultiTileset(file)
	else
		import.txtSingleTileset(file)
	end
	grid.width = #grid.map[1] or 0
	grid.height = #grid.map
	action.resetPos.f()
end

function import.txtSingleTileset(file)
	for line in file:lines() do
		local contentFolder = line
		contentFolder = string.gsub(contentFolder, " ", "")
		if string.find(contentFolder, ",") ~= nil then
			grid.map[#grid.map+1] = {}
			local regex = "(%d+)%p"
			local j = true
			while j do
				local result = string.match(contentFolder, regex)
				if result ~= nil then
					contentFolder = string.gsub(contentFolder, regex, "", 1)
					grid.map[#grid.map][#grid.map[#grid.map]+1] = tonumber(result)
				else
					j = false
				end
			end
		end
	end
end

function import.txtMultiTileset(file)
	for line in file:lines() do
		local contentFolder = line
		contentFolder = string.gsub(contentFolder, " ", "")
		if string.find(contentFolder, ",") ~= nil then
			grid.map[#grid.map+1] = {}
			local regex = "(%d+):(%d+)%p"
			local j = true
			while j do
				local tilesetIndex, localTileId = string.match(contentFolder, regex)
				if tilesetIndex ~= nil and localTileId ~= nil then
					contentFolder = string.gsub(contentFolder, regex, "", 1)
					local globalTileId = import.convertToGlobalTileId(tonumber(tilesetIndex), tonumber(localTileId))
					grid.map[#grid.map][#grid.map[#grid.map]+1] = globalTileId
				else
					j = false
				end
			end
		end
	end
end

function import.convertToGlobalTileId(tilesetIndex, localTileId)
	if localTileId == 0 then
		return 0
	end
	if not grid.tilesets or not grid.tilesets[tilesetIndex + 1] then
		return localTileId
	end
	local tileset = grid.tilesets[tilesetIndex + 1]
	return tileset.startTileId + localTileId - 1
end

function import.lua(file)
	grid.map = {}
	for line in file:lines() do
		local contentFolder = line
		contentFolder = string.gsub(contentFolder, " ", "")
		contentFolder = string.gsub(contentFolder, "{", "")
		contentFolder = string.gsub(contentFolder, "^}$", "")
		contentFolder = string.gsub(contentFolder, "}", ",")
		contentFolder = string.gsub(contentFolder, ",,", ",")
		if string.find(contentFolder, ",") ~= nil then
			grid.map[#grid.map+1] = {}
			local regexMulti = "(%d+):(%d+)%p"
			local regexSingle = "(%d+)%p"
			local j = true
			while j do
				local tilesetIndex, localTileId = string.match(contentFolder, regexMulti)
				if tilesetIndex ~= nil and localTileId ~= nil then
					contentFolder = string.gsub(contentFolder, regexMulti, "", 1)
					local globalTileId = import.convertToGlobalTileId(tonumber(tilesetIndex), tonumber(localTileId))
					grid.map[#grid.map][#grid.map[#grid.map]+1] = globalTileId
				else
					local result = string.match(contentFolder, regexSingle)
					if result ~= nil then
						contentFolder = string.gsub(contentFolder, regexSingle, "", 1)
						grid.map[#grid.map][#grid.map[#grid.map]+1] = tonumber(result)
					else
						j = false
					end
				end
			end
		end
	end
	grid.width = #grid.map[#grid.map]
	grid.height = #grid.map
	action.resetPos.f()
end

function import.json(file)
	grid.map = {}
	for line in file:lines() do
		local contentFolder = line
		contentFolder = string.gsub(contentFolder, " ", "")
		contentFolder = string.gsub(contentFolder, "{", "")
		contentFolder = string.gsub(contentFolder, "}", "")
		contentFolder = string.gsub(contentFolder, "%[", "")
		contentFolder = string.gsub(contentFolder, "%]%]", ",")
		contentFolder = string.gsub(contentFolder, "%]", "")
		contentFolder = string.gsub(contentFolder, '\"map\"', "")
		contentFolder = string.gsub(contentFolder, ":", "")
		contentFolder = string.gsub(contentFolder, " ", "")
		if string.find(contentFolder, ",") ~= nil then
			grid.map[#grid.map+1] = {}
			local regexMulti = "(%d+):(%d+)%p"
			local regexSingle = "(%d+)%p"
			local j = true
			while j do
				local tilesetIndex, localTileId = string.match(contentFolder, regexMulti)
				if tilesetIndex ~= nil and localTileId ~= nil then
					contentFolder = string.gsub(contentFolder, regexMulti, "", 1)
					local globalTileId = import.convertToGlobalTileId(tonumber(tilesetIndex), tonumber(localTileId))
					grid.map[#grid.map][#grid.map[#grid.map]+1] = globalTileId
				else
					local result = string.match(contentFolder, regexSingle)
					if result ~= nil then
						contentFolder = string.gsub(contentFolder, regexSingle, "", 1)
						grid.map[#grid.map][#grid.map[#grid.map]+1] = tonumber(result)
					else
						j = false
					end
				end
			end
		end
	end
	grid.width = #grid.map[#grid.map]
	grid.height = #grid.map
	action.resetPos.f()
end

return import