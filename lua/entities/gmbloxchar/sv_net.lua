util.AddNetworkString("gmblox_equipgear")
util.AddNetworkString("gmblox_firegear")
util.AddNetworkString("gmblox_changezoom")

util.AddNetworkString("gmblox_changecolour")
util.AddNetworkString("gmblox_changecolour_sv")

util.AddNetworkString("gmblox_exit")
util.AddNetworkString("gmblox_exit_sv")

util.AddNetworkString("gmblox_changehat")
util.AddNetworkString("gmblox_changehat_sv")

util.AddNetworkString("gmblox_promptloadout")
util.AddNetworkString("gmblox_promptloadout_sv")

net.Receive("gmblox_promptloadout_sv", function(len, ply)
	if (ply.nextLoadout or 0) > CurTime() then
		return
	end

	ply.nextLoadout = CurTime() + 1

	local target = net.ReadEntity()

	if not IsValid(target) then
		return
	end

	if target:GetClass() ~= "gmbloxchar" then
		return
	end

	if target.HasLoadout then
		return
	end

	local dist = ply:GetPos():Distance(target:GetPos())
	if dist > 1024 then
		return
	end

	target.HasLoadout = true
	target:BeginControl(ply)
end)


net.Receive("gmblox_changehat", function(len, ply)
	if (ply.nextCustomizeHat or 0) > CurTime() then
		return
	end

	ply.nextCustomizeHat = CurTime() + 1

	local target = net.ReadEntity()
	if not IsValid(target) then
		return
	end

	if target:GetClass() ~= "gmbloxchar" then
		return
	end

	if not IsValid(target:GetController()) then
		return
	end

	if target:GetController() ~= ply then
		return
	end

	local hat = net.ReadString() or "None"
	local face = net.ReadString() or "normal"


	net.Start("gmblox_changehat_sv")
		net.WriteEntity(target)
		net.WriteString(hat)
		net.WriteString(face)
	net.Broadcast()
end)


net.Receive("gmblox_exit", function(len, ply)
	if (ply.nextExitGMBlox or 0) > CurTime() then
		return
	end

	ply.nextExitGMBlox = CurTime() + 1

	local target = net.ReadEntity()

	if not IsValid(target) then
		return
	end

	if target:GetClass() ~= "gmbloxchar" then
		return
	end

	if not IsValid(target:GetController()) then
		return
	end

	if target:GetController() ~= ply then
		return
	end

	target:UnControl()

	net.Start("gmblox_exit_sv")
		net.WriteEntity(target)
	net.Send(ply)
end)

net.Receive("gmblox_changecolour", function(len, ply)
	if (ply.NextChangeColour or 0) > CurTime() then
		return
	end

	ply.NextChangeColour = CurTime() + 1

	local target = net.ReadEntity()

	if not IsValid(target) then
		return
	end

	if target:GetClass() ~= "gmbloxchar" then
		return
	end

	if not IsValid(target:GetController()) then
		return
	end

	if target:GetController() ~= ply then
		return
	end

	local colhead = net.ReadUInt(24)
	local coltorso = net.ReadUInt(24)
	local colleftarm = net.ReadUInt(24)
	local colrightarm = net.ReadUInt(24)
	local colleftleg = net.ReadUInt(24)
	local colrightleg = net.ReadUInt(24)

	if not colhead or not coltorso or not colleftarm or not colrightarm or not colleftleg or not colrightleg then
		return
	end

	net.Start("gmblox_changecolour_sv")
		net.WriteEntity(target)
		net.WriteUInt(colhead, 24)
		net.WriteUInt(coltorso, 24)
		net.WriteUInt(colleftarm, 24)
		net.WriteUInt(colrightarm, 24)
		net.WriteUInt(colleftleg, 24)
		net.WriteUInt(colrightleg, 24)
	net.Broadcast()
end)


net.Receive("gmblox_equipgear", function(len, ply)
	if (ply.NextGearChange or 0) > CurTime() then
		return
	end
	ply.NextGearChange = CurTime() + 0.05

	local gear = net.ReadString()
	if gear == nil then
		return
	end


	if #gear > 64 then
		return
	end

	local target = net.ReadEntity()
	if not IsValid(target) then
		return
	end

	if target:GetClass() ~= "gmbloxchar" then
		return
	end

	if not IsValid(target:GetController()) then
		return
	end

	if target:GetController() ~= ply then
		return
	end

	if not GMBlox.IsAllowedLUT[gear] then
		return
	end

	local gearData = GMBlox.ValidGears[gear]
	if not gearData then
		return
	end

	local currgear = target:GetActiveGear()
	if currgear and GMBlox.ValidGears[currgear] and GMBlox.ValidGears[currgear].svUnequip then
		pcall(GMBlox.ValidGears[currgear].svUnequip, target)
	end

	target:SetGearState(0)

	if gear == target:GetActiveGear() then
		target:SetActiveGear("")
		return
	end

	target:SetGearOffset(Vector(0, 0, 0))
	target:SetGearAngle(Angle(0, 0, 0))

	target:SetActiveGear(gear)

	if gearData.equipSound then
		ply:EmitSound(gearData.equipSound)
	end

	if gearData.svEquip then
		local fine, err = pcall(gearData.svEquip, target)
		if not fine then
			print("Error in gear \"" .. gear .. "\" equip: " .. err)
		end
	end
end)

function DoDoubleFire(target, gear)
	local gearData = GMBlox.ValidGears[gear]
	if not gearData then
		return
	end

	if not gearData.svDoubleFire then
		return
	end

	if CurTime() < (target.NextFires[gear .. "_d"] or 0) then
		return
	end

	if CurTime() - (target.LastDbFire or 0) > 0.3 then
		target.DbFires = 0
		target.LastDbFire = CurTime()
		return
	end

	if (target.DbFires or 0) < 2 then
		target.LastDbFire = CurTime()

		target.DbFires = (target.DbFires or 0) + 1
		return
	end


	local fine, err = pcall(gearData.svDoubleFire, target)
	if not fine then
		print("Error in gear \"" .. gear .. "\" double fire: " .. err)
	end

	if err then
		return
	end

	target.NextFires[gear .. "_d"] = CurTime() + gearData.useCooldownDoubleFire

	if not gearData.svDoubleFireFinished then
		return
	end

	timer.Simple(gearData.useCooldownDoubleFire, function()
		if not IsValid(target) then
			return
		end

		local fine2, err2 = pcall(gearData.svDoubleFireFinished, target)
		if not fine2 then
			print("Error in gear \"" .. gear .. "\" double fire finished: " .. err2)
		end

		target.DbFires = 0
	end)
end



net.Receive("gmblox_firegear", function(len, ply)
	local gear = net.ReadString()
	if gear == nil then
		return
	end

	if #gear > 64 then
		return
	end

	local target = net.ReadEntity()
	if not IsValid(target) then
		return
	end

	if target:GetClass() ~= "gmbloxchar" then
		return
	end

	if not IsValid(target:GetController()) then
		return
	end

	if target:GetController() ~= ply then
		return
	end

	if gear ~= target:GetActiveGear() then
		return
	end

	if not GMBlox.IsAllowedLUT[gear] then
		return
	end

	if target:GetHealthRoblox() <= 0 then
		return
	end

	if not GMBlox then
		return
	end

	local gearData = GMBlox.ValidGears[gear]

	if not gearData then
		return
	end

	DoDoubleFire(target, gear)

	if CurTime() < (target.NextFires[gear] or 0) then
		return
	end

	local pos = net.ReadVector()
	if not pos then
		return
	end

	local diff = (target:GetPos() - pos)
	local diff_norm = diff:GetNormalized()
	local shootpos = (target:GetPos() + -diff_norm * 48)


	local fine, ret = pcall(gearData.svCallback, target, pos, shootpos, diff_norm)

	if not fine then
		print("[GMBlox] Error in callback for gear \"" .. gear .. "\": " .. ret)
		return
	end

	if ret then
		return
	end

	timer.Simple(gearData.useCooldown, function()
		local fine2, err = pcall(gearData.svFinishedCallback, target)
		if not fine2 then
			print("[GMBlox] Error in callback for gear \"" .. gear .. "\": " .. err)
		end
	end)

	target.NextFires[gear] = CurTime() + gearData.useCooldown
end)

-- no ratelimit!
-- people change zoom VERY fast
net.Receive("gmblox_changezoom", function(len, ply)
	local target = net.ReadEntity()
	if not IsValid(target) then
		return
	end

	if target:GetClass() ~= "gmbloxchar" then
		return
	end

	if not IsValid(target:GetController()) then
		return
	end

	if target:GetController() ~= ply then
		return
	end

	local zoom = net.ReadFloat()
	if zoom == nil then
		return
	end

	target.InternZoom = zoom
end)
