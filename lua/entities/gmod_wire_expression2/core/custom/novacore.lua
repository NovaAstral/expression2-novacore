if (E2Lib == nil) then 
    print("[NovaCore] You need to install wiremod!")
    return
end

E2Lib.RegisterExtension("novacore", true)

--local NovaCore = {}

--AntCore.turretShoot_enabled = CreateConVar("antcore_turretShoot_enabled","1",FCVAR_ARCHIVE)
--AntCore.turretShoot_persecond = CreateConVar("antcore_turretShoot_persecond","10",FCVAR_ARCHIVE)
--from antcore so I know how making convars work for later

print("NovaCore Loaded")

function NaqBoom(pos,yield)
    local naq = ents.Create("gate_nuke")
	naq:Setup(pos,yield)
	naq:Spawn()
	naq:Activate()
end

__e2setcost(10)
e2function void entity:resizeEntPhys(vector scale) --This function doesn't work properly yet
	if not IsValid(this) or not isOwner(self, this) then return end
	if this:GetClass() == "prop_ragdoll" then return end -- crashes if you use it on ragdoll
	if this:GetClass() == "player" then return end -- Don't resize players, it will also crash the server

	this:resizeEntPhys(scale)
end

__e2setcost(10)
e2function void createNaqBoom(vector pos, number yield)
	if(!self.player:IsAdmin()) then return end
	NaqBoom(pos,yield)
end