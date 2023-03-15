if (E2Lib == nil) then 
    print("[NovaCore] You need to install wiremod!")
    return
end

E2Lib.RegisterExtension("novacore", true)

print("NovaCore Loaded")

local defaultPrintDelay = 0.3
local defaultMaxPrints = 15
local printDelays = {}

function NaqBoom(pos,yield)
    local naq = ents.Create("gate_nuke")
	naq:Setup(pos,yield)
	naq:Spawn()
	naq:Activate()
end

__e2setcost(10)
e2function void createNaqBoom(vector pos, number yield)
	if(!self.player:IsAdmin()) then return end

	if(game.GetIPAddress() == "98.247.134.234:27020") then -- checks if server is kripalida spacebox #2
		if(self.player:SteamID() != "STEAM_0:0:53930685" and self.player:SteamID() != "STEAM_0:1:53193910") then --nova_astral and kripalida
			self.player:ChatPrint("You do not have permission for this function!")
			return
		else
			NaqBoom(pos,yield)
		end
	else --if not on kipalida spacebox #2 just do the boom
		NaqBoom(pos,yield)
	end
end

--Because matt jeanes chatprint extension is garbage, why the hell doesn't it function exactly like printcolor
__e2setcost(100)
e2function void printColorOther(entity ply,...)
	if(!ply:IsValid()) then return end
	if(!ply:IsPlayer()) then return end

	printColorVarArg(nil, ply, false, typeids, ...)
end

--PrintColor functions because it errors otherwise since wiremod decided to local all their functions
local function getDelaysOrCreate(ply, maxCharges, chargesDelay)
	local printDelay = printDelays[ply]

	if not printDelay then
		-- if the player does not have an entry yet, add it
		printDelay = { numCharges = maxCharges, lastTime = CurTime() }
		printDelays[ply] = printDelay
	end

	return printDelay
end

local function canPrint(ply)
	-- update the console variables just in case
	local maxCharges = ply:GetInfoNum("wire_expression2_print_max", defaultMaxPrints)
	local chargesDelay = ply:GetInfoNum("wire_expression2_print_delay", defaultPrintDelay)

	local printDelay = getDelaysOrCreate(ply, maxCharges, chargesDelay)

	local currentTime = CurTime()
	if printDelay.numCharges < maxCharges then
		-- check if the player "deserves" new charges
		local timePassed = (currentTime - printDelay.lastTime)
		if timePassed > chargesDelay then
			if chargesDelay == 0 then
				printDelay.lastTime = currentTime
				printDelay.numCharges = maxCharges
			else
				local chargesToAdd = math.floor(timePassed / chargesDelay)
				printDelay.lastTime = (currentTime - (timePassed % chargesDelay))
				-- add "semi" charges the player might already have
				printDelay.numCharges = printDelay.numCharges + chargesToAdd
			end
		end
	end
	-- we should clamp his charges for safety
	if printDelay.numCharges > maxCharges then
		printDelay.numCharges = maxCharges
		-- remove the "semi" charges, otherwise the player has too many
		printDelay.lastTime = currentTime
	end

	return printDelay and printDelay.numCharges > 0
end

local function checkDelay(ply)
	if canPrint(ply) then
		local maxCharges = ply:GetInfoNum("wire_expression2_print_max", defaultMaxPrints)
		local chargesDelay = ply:GetInfoNum("wire_expression2_print_delay", defaultPrintDelay)
		local printDelay = getDelaysOrCreate(ply, maxCharges, chargesDelay)
		printDelay.numCharges = printDelay.numCharges - 1
		return true
	end
	return false
end

hook.Add("PlayerDisconnected", "e2_print_delays_player_dc", function(ply) printDelays[ply] = nil end)

local printColor_typeids = {
	n = tostring,
	s = function(text) return string.Left(text,249) end,
	v = function(v) return Color(v[1],v[2],v[3]) end,
	xv4 = function(v) return Color(v[1],v[2],v[3],v[4]) end,
	e = function(e) return IsValid(e) and e:IsPlayer() and e or "" end,
}

local function printColorVarArg(chip, ply, console, typeids, ...)
	if not IsValid(ply) then return end
	if not checkDelay(ply) then return end
	local send_array = { ... }

	local i = 1
	for i,tp in ipairs(typeids) do
		if printColor_typeids[tp] then
			send_array[i] = printColor_typeids[tp](send_array[i])
		else
			send_array[i] = ""
		end
		if i == 256 then break end
		i = i + 1
	end

	net.Start("wire_expression2_printColor")
		net.WriteEntity(chip)
		net.WriteBool(console)
		net.WriteTable(send_array)
	net.Send(ply)
end

local printColor_types = {
	number = tostring,
	string = function(text) return string.Left(text,249) end,
	Vector = function(v) return Color(v[1],v[2],v[3]) end,
	table = function(tbl)
		for i,v in pairs(tbl) do
			if !isnumber(i) then return "" end
			if !isnumber(v) then return "" end
			if i < 1 or i > 4 then return "" end
		end
		return Color(tbl[1] or 0, tbl[2] or 0,tbl[3] or 0,tbl[4])
	end,
	Player = function(e) return IsValid(e) and e:IsPlayer() and e or "" end,
}

local function printColorArray(chip, ply, console, arr)
	if not IsValid(ply) then return end
	if not checkDelay( ply ) then return end

	local send_array = {}

	local i = 1
	for i,tp in ipairs_map(arr,type) do
		if printColor_types[tp] then
			send_array[i] = printColor_types[tp](arr[i])
		else
			send_array[i] = ""
		end
		if i == 256 then break end
		i = i + 1
	end

	net.Start("wire_expression2_printColor")
		net.WriteEntity(chip)
		net.WriteBool(console)
		net.WriteTable(send_array)
	net.Send(ply)
end