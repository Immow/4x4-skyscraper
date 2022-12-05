---@diagnostic disable: param-type-mismatch

-- FUNCTION TO PRINT TABLES
function tprint (tbl, indent)
	if not indent then indent = 0 end
	local toprint = string.rep(" ", indent) .. "{\r\n"
	indent = indent + 2 
	for k, v in pairs(tbl) do
		toprint = toprint .. string.rep(" ", indent)
		if (type(k) == "number") then
			toprint = toprint .. "[" .. k .. "] = "
		elseif (type(k) == "string") then
			toprint = toprint  .. k ..  "= "   
		end
		if (type(v) == "number") then
			toprint = toprint .. v .. ",\r\n"
		elseif (type(v) == "string") then
			toprint = toprint .. "\"" .. v .. "\",\r\n"
		elseif (type(v) == "table") then
			toprint = toprint .. tprint(v, indent + 2) .. ",\r\n"
		else
			toprint = toprint .. "\"" .. tostring(v) .. "\",\r\n"
		end
	end
	toprint = toprint .. string.rep(" ", indent-2) .. "}"
	return toprint
end

local clues = {0,0,1,2,0,2,0,0,0,3,0,0,0,1,0,0}
local offset = 20
local cellWidth = 50
local cellHeight = 50
local cluesOffset = 30
local font = love.graphics.getFont()

local grid = {}

local function createGrid()
	for y = 1, 4 do
		grid[y] = {}
		for x = 1, 4 do
			local cellX = offset + x * cellWidth
			local cellY = offset + y * cellHeight
			grid[y][x] = {x = cellX, y = cellY, width = cellWidth, height = cellHeight, size = {1,2,3,4}, drawNumber = nil}
		end
	end
end

local function setOthersTo0(n, tile)
	for j = 1, 4 do
		if j ~= n then
			tile.size[j] = 0
		end
	end
end

local function removeNumber()
	for y, columns in ipairs(grid) do
		for x, tile in ipairs(columns) do
			local count = 0
			local foundNumner
			local index
			for i = 1, 4 do
				if grid[y][x].size[i] == 0 then
					count = count + 1
				else
					if foundNumner then break end
					foundNumner = grid[y][x].size[i]
					index = x
				end
				
				if count == 3 and foundNumner then
					for k = 1, 4 do
						if k ~= index then
							grid[y][k].size[foundNumner] = 0
						end
					end
				end
			end
		end
	end

	for y, columns in ipairs(grid) do
		for x, tile in ipairs(columns) do
			local count = 0
			local foundNumner
			local index
			for i = 1, 4 do
				if grid[x][y].size[i] == 0 then
					count = count + 1
				else
					if foundNumner then break end
					foundNumner = grid[x][y].size[i]
					index = x
				end
				
				if count == 3 and foundNumner then
					for k = 1, 4 do
						if k ~= index then
							grid[k][y].size[foundNumner] = 0
						end
					end
				end
			end
		end
	end
end

local function pattern1(i) -- if only 1 scraper is visible then it's the talest scraper
	if clues[i] == 1 then  -- top
		setOthersTo0(4, grid[1][i])
	elseif clues[i+4] == 1 then  -- right
		setOthersTo0(4, grid[i][4])
	elseif clues[i+8] == 1 then  -- bottom
		setOthersTo0(4, grid[4][5-i])
	elseif clues[i+12] == 1 then  -- left
		setOthersTo0(4, grid[5-i][1])
	end
end

local function pattern2(i) -- if clues 1 and 3 are oposite of each other
	if clues[i] == 1 and clues[13-i] == 3 then -- clues top to bottom comparisson
		setOthersTo0(4, grid[1][i])
		setOthersTo0(1, grid[2][i])
		setOthersTo0(3, grid[3][i])
		setOthersTo0(2, grid[4][i])
	elseif clues[i] == 3 and clues[13-i] == 1 then -- clues top to bottom comparisson
		setOthersTo0(2, grid[1][i])
		setOthersTo0(3, grid[2][i])
		setOthersTo0(1, grid[3][i])
		setOthersTo0(4, grid[4][i])
	end

	if clues[i+4] == 1 and clues[17-i] == 3 then -- clues sides comparrison
		setOthersTo0(2, grid[i][1])
		setOthersTo0(3, grid[i][2])
		setOthersTo0(1, grid[i][3])
		setOthersTo0(4, grid[i][4])
	elseif clues[i+4] == 3 and clues[17-i] == 1 then -- clues sides comparrison
		setOthersTo0(4, grid[i][1])
		setOthersTo0(1, grid[i][2])
		setOthersTo0(3, grid[i][3])
		setOthersTo0(2, grid[i][4])
	end
end

local function pattern3(i) -- if all scraper is visible
	if clues[i] == 4 then -- clues top to bottom comparisson
		setOthersTo0(1, grid[1][i])
		setOthersTo0(2, grid[2][i])
		setOthersTo0(3, grid[3][i])
		setOthersTo0(4, grid[4][i])
	elseif clues[i+4] == 4 then -- clues sides comparrison
		setOthersTo0(1, grid[i][4])
		setOthersTo0(2, grid[i][3])
		setOthersTo0(3, grid[i][2])
		setOthersTo0(4, grid[i][1])
	elseif clues[i+8] == 4 then -- clues top to bottom comparisson
		setOthersTo0(1, grid[4][5-i])
		setOthersTo0(2, grid[3][5-i])
		setOthersTo0(3, grid[2][5-i])
		setOthersTo0(4, grid[1][5-i])
	elseif clues[i+12] == 4 then -- clues side comparrison
		setOthersTo0(1, grid[5-i][1])
		setOthersTo0(2, grid[5-i][2])
		setOthersTo0(3, grid[5-i][3])
		setOthersTo0(4, grid[5-i][4])
	end
end

local function pattern4(i) -- if two skycrapers are visible first one can't be talest
	if clues[i] == 2 then -- clues top to bottom comparisson
		grid[1][i].size[4] = 0
	elseif clues[i+4] == 2 then -- clues side comparrison
		grid[i][4].size[4] = 0
	elseif clues[i+8] == 2 then -- clues top to bottom comparisson
		grid[4][5-i].size[4] = 0
	elseif clues[i+12] == 2 then -- clues side comparrison
		grid[5-i][1].size[4] = 0
	end
end

local function pattern5() -- if two skycrapers are visible first one can't be talest
	-- for y, columns in ipairs(grid) do
		-- local n1, n2, n3, n4 = 0, 0, 0, 0

		-- local n1T, n2T, n3T, n4T = {}, {}, {}, {}
		-- for x, tile in ipairs(columns) do
		-- 	if tile.size[1] ~= 0 then
		-- 		n1 = n1 + 1
		-- 		n1T = tile
		-- 	elseif tile.size[2] ~= 0 then
		-- 		n2 = n2 + 1
		-- 		n2T = tile
		-- 	elseif tile.size[3] ~= 0 then
		-- 		n3 = n3 + 1
		-- 		n3T = tile
		-- 	elseif tile.size[4] ~= 0 then
		-- 		n4 = n4 + 1
		-- 		n4T = tile
		-- 	end
		-- end

		-- if n1 == 1 then
		-- 	setOthersTo0(1, n1T)
		-- elseif n2 == 1 then
		-- 	setOthersTo0(2, n2T)
		-- elseif n3 == 1 then
		-- 	setOthersTo0(3, n3T)
		-- elseif n4 == 1 then
		-- 	setOthersTo0(4, n4T)
		-- end
	for i = 1, 4 do
		if grid[i][1].size[1] + grid[i][2].size[1] + grid[i][3].size[1] + grid[i][4].size[1] == 1 then
			for j = 1, 4 do
				if grid[i][j].size[1] ~= 0 then
					setOthersTo0(1, grid[i][j])
				end
			end
		end
		if grid[i][1].size[2] + grid[i][2].size[2] + grid[i][3].size[2] + grid[i][4].size[2] == 2 then
			for j = 1, 4 do
				if grid[i][j].size[2] ~= 0 then
					setOthersTo0(2, grid[i][j])
				end
			end
		end
		if grid[i][1].size[3] + grid[i][2].size[3] + grid[i][3].size[3] + grid[i][4].size[3] == 3 then
			for j = 1, 4 do
				if grid[i][j].size[3] ~= 0 then
					setOthersTo0(3, grid[i][j])
				end
			end
		end
		if grid[i][1].size[4] + grid[i][2].size[4] + grid[i][3].size[4] + grid[i][4].size[4] == 4 then
			for j = 1, 4 do
				if grid[i][j].size[4] ~= 0 then
					setOthersTo0(4, grid[i][j])
				end
			end
		end
	end
end

local function patterns() -- if it's [13 - i] or [17 - i] then we invert what we compare against.
	for i = 1, 4 do
		pattern1(i)
		pattern2(i)
		pattern3(i)
		pattern4(i)
		removeNumber()
	end
	pattern5()
end

local function drawClues(x, y, tile)
	if y == 1  and clues[x] ~= 0 then -- top 1 2 3 4
		local textWidth = font:getWidth(tostring(clues[x]))
		love.graphics.print(clues[x], tile.x + tile.width / 2 - textWidth / 2, tile.y - cluesOffset)
	end

	if x == 4 and clues[y + 4] ~= 0 then -- right 5 6 7 8
		local textHeight = font:getHeight()
		love.graphics.print(clues[y + 4], tile.x + tile.width + cluesOffset, tile.y + tile.height / 2 - textHeight / 2 )
	end

	if y == 4 and clues[13 - x] ~= 0 then -- bottom 9 10 11 12 (inverten)
		local textWidth = font:getWidth(tostring(clues[x]))
		love.graphics.print(clues[13 - x], tile.x + tile.width / 2 - textWidth / 2, tile.y + tile.height + cluesOffset)
	end
	
	if x == 1 and clues[17 - y] ~= 0 then -- left 13 14 15 16 (inverten)
		local textHeight = font:getHeight()
		love.graphics.print(clues[17 - y], tile.x - cluesOffset, tile.y + tile.height / 2 - textHeight / 2)
	end
end

function love.load()
	createGrid()
end

local function onlyOneLeft()
	for y, columns in ipairs(grid) do
		for x, tile in ipairs(columns) do
			local count = 0
			local number = nil
			for i = 1, 4 do
				if tile.size[i] == 0 then
					count = count + 1
				else
					number = tile.size[i]
				end
			end
			if count == 3 then
				tile.drawNumber = number
			end
		end
	end
end

local function shouldWeDrawIt(tile, pos)
	if tile.size[pos] ~= 0 then
		return tostring(tile.size[pos])
	else
		return ""
	end
end

local function drawTileNumbers(tile)
	local t1 = shouldWeDrawIt(tile, 1)
	local t2 = shouldWeDrawIt(tile, 2)
	local t3 = shouldWeDrawIt(tile, 3)
	local t4 = shouldWeDrawIt(tile, 4)

	love.graphics.rectangle("line", tile.x, tile.y, tile.width, tile.height)
	if not tile.drawNumber then
		love.graphics.print(t1, tile.x + tile.width / 4, tile.y + tile.height / 4)
		love.graphics.print(t2, tile.x + tile.width / 2, tile.y + tile.height / 4)
		love.graphics.print(t3, tile.x + tile.width / 4, tile.y + tile.height / 2)
		love.graphics.print(t4, tile.x + tile.width / 2, tile.y + tile.height / 2)
	else
		local textWidth, textHeight = font:getWidth(tostring(tile.drawNumber)), font:getHeight()
		love.graphics.print(tile.drawNumber, tile.x + tile.width / 2 - textWidth / 2, tile.y + tile.height / 2 - textHeight / 2)
	end
end

function love.keypressed(key,scancode,isrepeat)
	if key == "space" then
		patterns()
		onlyOneLeft()
	end
end

function love.draw()
	for y, columns in ipairs(grid) do
		for x, tile in ipairs(columns) do
			drawTileNumbers(tile)
			drawClues(x, y, tile)
		end
	end
end

function love.update()
end