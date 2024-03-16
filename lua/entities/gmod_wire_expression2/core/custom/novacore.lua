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

function DakWave(pos,immuneents,classtargets,radius)
	local wave = ents.Create("dakara_wave")

	wave:Setup(pos,immuneents,classtargets,false,radius)
	wave:Spawn()
	wave:Activate()
	wave:EmitSound("dakara/dakara_release_energy.wav", 511, math.random(98, 102))
end

function SatBlast(pos)
	local sat = ents.Create("sat_blast_wave")
	sat:SetPos(pos)
	sat:Spawn()
	sat:Activate()
end

function SpawnEnt(class,pos,ang,ply)
	local ent = ents.Create(class)
	ent:SetCreator(ply)
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:Spawn()

	undo.Create("E2 Spawned Entity")
	undo.AddEntity(ent)
	undo.SetPlayer(ply)
	undo.Finish()
	return ent
end

local function validWirelink(self, ent)
	if not IsValid(ent) then return false end
	if not ent.extended then return false end
	if(not isOwner(self,this) or not self.player:IsAdmin()) then return false end
	return true
end

__e2setcost(10)
e2function void createNaqBoom(vector pos, number yield)
	if(!self.player:IsAdmin()) then return end

	NaqBoom(pos,yield)
end

__e2setcost(10)
e2function void createDakaraWave(vector pos, table immuneents, table classtargets, number radius)
	if(!self.player:IsAdmin()) then return end

	DakWave(pos,immuneents,classtargets,radius)
end

__e2setcost(10)
e2function void createSatBlast(vector pos)
	if(!self.player:IsAdmin()) then return end

	SatBlast(pos)
end

__e2setcost(10)
e2function entity entSpawn(string class,vector pos,angle ang)
	if(!self.player:IsAdmin()) then return end

	return SpawnEnt(class,pos,ang,self.player)
end

__e2setcost(1)
e2function number mathApproach(number current,number target,number change)
	return math.Approach(current,target,change)
end

__e2setcost(3)
e2function number mathApproachAngle(number currentAng, number targetAng, number rate)
	return math.ApproachAngle(currentAng,targetAng,rate)
end

__e2setcost(3)
e2function vector mathLerpVector(number fraction,vector from, vector to)
	return LerpVector(fraction,from,to)
end

__e2setcost(3)
e2function angle mathLerpAngle(number fraction,angle angStart,angle angEnd)
	return LerpAngle(fraction,angStart,angEnd)
end

__e2setcost(10)
e2function void entity:setEntityValue(string value,number nval) --This probably doesn't even work
	if(!self.player:IsAdmin()) then return end -- Never undo this! A player could cause really really bad things with this!
	
	if(this:IsValid()) then
		this.value = nval
	end
end

__e2setcost(10)
e2function void entity:entDelete()
	if(this:IsValid()) then
		if(self.player == this:GetCreator() or self.player:IsAdmin()) then
			this:Remove()
		end
	end
end

__e2setcost(10)
e2function void entity:entSetPos(vector vec)
	if(this:IsValid()) then
		if(self.player == this:GetCreator() or self.player:IsAdmin()) then
			this:SetPos(vec)
		end
	end
end

__e2setcost(10)
e2function void entity:entPhysPos(vector vec)
	if(this:IsValid()) then
		local phys = this:GetPhysicsObject()

		if(phys:IsValid()) then
			if(self.player == this:GetCreator() or self.player:IsAdmin()) then
				phys:SetPos(vec)
			end
		end
	end
end

__e2setcost(10)
e2function void entity:dhdPressButton(string button, number buttonsmode)
	if(IsValid(this)) then
		if(isOwner(self,this) or self.player:IsAdmin()) then
			if(this:GetNWBool("ButtonsMode") == true and buttonsmode == 1) then
				this:ButtonMode(button)
			else
				this:PressButton(button)
				this:SetBusy(0)
			end
		end
	end
end

__e2setcost(10)
e2function void entity:dhdPressButton(number button, number buttonsmode)
	if(IsValid(this)) then
		if not validWirelink(self, this) then return end

		if not this.Inputs then return end
		if not this.Inputs["Press Button"] then return end
		if not this.Inputs["Buttons Mode"] then return end

		if(isOwner(self,this) or self.player:IsAdmin()) then
			local v = button

			if(v >= 1 and v < 256) then
				local symbols = "A-Z1-9@#!*"

				if(GetConVar("stargate_group_system"):GetBool()) then
					symbols = "A-Z0-9@#*"
				end

				local char = string.char(v):upper()

				if(v >= 128 and v <= 137) then -- numpad 0-9
					char = string.char(v-80):upper() 
				elseif(v==139) then -- numpad *
					char = string.char(42):upper()
				end

				if(buttonsmode == 0 and v == StarGate.KeysConst[KEY_ENTER]) then -- Enter Key
					this:PressButton("DIAL",nil,true)
				elseif(buttonsmode == 0 and v == StarGate.KeysConst[KEY_BACKSPACE]) then -- Backspace key
					local e = self:FindGate()
					if not IsValid(e) then return end
					if (GetConVar("stargate_dhd_close_incoming"):GetInt()==0 and e.IsOpen and not e.Outbound) then return end -- if incoming, then we can do nothign
					if (e.IsOpen) then
						e:AbortDialling()
					elseif (e.NewActive and #this.DialledAddress > 0) then
						this:PressButton(this.DialledAddress[table.getn(this.DialledAddress)],nil,true)
					end
				elseif(buttonsmode == 0 and char:find("["..symbols.."]")) then -- Only alphanumerical and the @, #
					this:PressButton(char,nil,true)
				elseif(this:GetNWBool("ButtonsMode") == true and buttonsmode == 1 and char:find("["..symbols.."]")) then
					this:ButtonMode(char)
				end
			end

			if(buttonsmode == 0) then
				this:SetBusy(0)
			end
		end
	end
end

__e2setcost(10)
e2function string entity:getBoneName(number index)
	return this:GetBoneName(index)
end

__e2setcost(10)
e2function entity entity:getBoneParent(number index)
	return this:GetBoneParent(bone)
end

__e2setcost(10)
e2function table entity:getBoneChilds(number index)
	return this:GetBoneChilds(bone)
end

__e2setcost(10)
e2function entity entity:getBonePos(number bone)
	local matrix = entity:GetBoneMatrix(0)
	return matrix:GetTranslation()
end

__e2setcost(10)
e2function entity entity:getBoneAng(number bone)
	local matrix = entity:GetBoneMatrix(0)
	return matrix:GetAngles()
end


--printcolor e2 function is after this because code reasons
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

--Because matt jeanes chatprint extension is old and doesnt work very well
__e2setcost(100)
e2function void printColorOther(entity ply,...)
	if(ply == nil) then return end
	if(!ply:IsValid()) then return end
	if(!ply:IsPlayer()) then return end

	printColorVarArg(self, ply, false, typeids, ...)
end