# expression2-novacore
Random functions for Expression2 that I've made

createNaqBoom(vector pos,number yield) - Creates a Naquadah Bomb explosion from Carter's Addon Pack (if you have it) at pos and with yield. You must be an admin to use it.

createDakaraWave(vector pos, table immuneents, table classtargets, number radius) - Creates a Dakara Wave from Carter's Addon Pack (if you have it) at pos, with immune entities, targets, and radius. (Does not properly work, is only visual). You must be an admin to use it.

createSatBlast(vector pos) - Creates an AG3 Satellite/Mk2 Naquadah Generator Blast from Carter's Addon Pack (if you have it) at pos. You must be an admin to use it.

entSpawn(string class,vector pos,angle ang) - Spawns an entity with class at pos with angle. You must be an admin to use it (as it has no safety checks)

mathApproach(number current,number target,number change) - Approaches the current number to the target number with change amount (look up math.approach on gmod wiki if you dont know how this works)

mathApproachAngle(number currentAng, number targetAng, number rate) - Approaches the current angle to the target angle with change amount (look up math.ApproachAngle on gmod wiki if you dont know how this works)

mathLerpVector(number fraction,vector from, vector to) - Lerps from a vector to a target vector using a fraction (Look up LerpVector on gmod wiki if you dont know how this works)

mathLerpAngle(number fraction,angle angStart,angle angEnd) - Lerps from an angle to a target angle using a fraction (Look up LerpAngle on gmod wiki if you dont know how this works)

setEntityValue(entity ent,string value,number nval) - Sets the string value of an entity (Probably doesn't work!). You must be an admin to use this.

entDelete(entity ent) - Deletes entity. You must be either the creator of the entity, or an admin to use this.

printColorOther(entity ply,array) - Prints to ply using the same arguments as E2's default printColor()
