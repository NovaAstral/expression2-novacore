if (E2Lib == nil) then return end

local function IsValidPhysicsObject(physobj)
	return (TypeID( physobj ) == TYPE_PHYSOBJ) and physobj:IsValid()
end

function entity:resizeEntPhys(scale)
	if entity:GetClass() == "prop_ragdoll" then return end -- crashes if you use it on ragdoll

	entity:PhysicsInit(SOLID_VPHYSICS)

	local physobj = entity:GetPhysicsObject()

	if (not IsValidPhysicsObject(physobj)) then return false end

	local physmesh = physobj:GetMeshConvexes()

	if (not istable(physmesh)) or (#physmesh < 1) then return false end

	for convexkey, convex in pairs(physmesh) do

		for poskey, postab in pairs(convex) do

			convex[poskey] = postab.pos * Vector(scale[1], scale[2], scale[3])
		end

	end

	entity:PhysicsInitMultiConvex(physmesh)

	entity:EnableCustomCollisions(true)

	return IsValidPhysicsObject(physobj)
end

if CLIENT then
	
end