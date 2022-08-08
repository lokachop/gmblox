function ENT:RebuildActiveGear()
	if IsValid(self.GearCSModel) then
		self.GearCSModel:Remove()
	end

	local gear = self:GetActiveGear()
	if gear == "" then
		return
	end


	local gearData = GMBlox.ValidGears[gear]
	local mdl = gearData.model
	if mdl == "" then
		return
	end

	local offpos = gearData.modelOffset + Vector(-6, 18, 16) + self:GetGearOffset()
	local offang = gearData.angleOffset + self:GetGearAngle()
	local offmat = gearData.material

	self.GearCSModel = ClientsideModel(mdl, RENDERGROUP_OPAQUE)

	if offmat ~= "" then
		self.GearCSModel:SetMaterial(offmat)
	end

	self:OffsetAndParentCSModel(self.GearCSModel, offpos, offang)
end


local function inrange(x, y, w, h, x2, y2)
	return x <= x2 and x2 <= x + w and y <= y2 and y2 <= y + h
end

function ENT:HandleFiring()
	if LocalPlayer() ~= self:GetController() then
		return
	end

	if self:GetActiveGear() == "" then
		return
	end

	if not GMBlox then
		return
	end

	local gearName = self:GetActiveGear()
	local gearData = GMBlox.ValidGears[gearName]

	if not gearData then
		return
	end

	if input.IsMouseDown(MOUSE_LEFT) then
		local mx, my = input.GetCursorPos()

		for k, v in pairs(self.NoClickZones) do
			if inrange(v.x, v.y, v.w, v.h, mx, my) then
				return
			end
		end


		local tr = util.TraceLine({
			start = self:GetController():GetShootPos(),
			endpos = self:GetController():GetShootPos() + (gui.ScreenToVector(mx, my) * 10000),
			filter = {self, self:GetController()},
		})


		if CurTime() > (self.NextFires[gearName] or 0) then
			local fine, ret = pcall(gearData.clCallback, self, tr)
			if not fine then
				print("[GMBLOX] Error in firing callback for " .. gearName .. ": " .. ret)
				return
			end

			if ret then
				return
			end

			timer.Simple(gearData.useCooldown - 0.2, function()
				if not IsValid(self) then
					return
				end

				pcall(gearData.clFinishedCallback, self)
			end)

			self.NextFires[gearName] = CurTime() + gearData.useCooldown
		end

		net.Start("gmblox_firegear")
			net.WriteString(gearName)
			net.WriteEntity(self)
			net.WriteVector(tr.HitPos)
		net.SendToServer()
	end
end

function ENT:EquipGear(name)
	local currGear = self:GetActiveGear()
	local currGearData = GMBlox.ValidGears[currGear]
	if currGearData and currGearData.clUnequip then
		local fine, err = pcall(currGearData.clUnequip, self)
		if not fine then
			print("[GMBLOX] Error in clUnequip for " .. currGear .. ": " .. err)
		end
	end


	net.Start("gmblox_equipgear")
		net.WriteString(name)
		net.WriteEntity(self)
	net.SendToServer()

	self:RebuildActiveGear()
end

function ENT:CallGearOnEquip()
	local gear = self:GetActiveGear()
	if not gear then
		return
	end

	local gearData = GMBlox.ValidGears[gear]

	if not gearData or not gearData.clEquip then
		return
	end

	local fine, err = pcall(gearData.clEquip, self)

	if not fine then
		print("[GMBLOX] Error in equip callback for " .. gear .. ": " .. err)
	end
end


function ENT:HandleQuickSwitch()
	if LocalPlayer() ~= self:GetController() then
		return
	end


	local pressed = false
	for i = 1, 10 do
		local isDown = input.IsKeyDown(i)
		local idx = math.Clamp(i - 1, 1, 10)

		if isDown then
			pressed = true
		end

		if self.Inventory[idx] and isDown and not self.HasSwitched then
			self:EquipGear(self.Inventory[idx])
			self.HasSwitched = true
		end
	end

	if not pressed then
		self.HasSwitched = false
	end
end

function ENT:GearThink()
	local gear = self:GetActiveGear()
	if not gear then
		return
	end

	if self.LastGearOffset ~= self:GetGearOffset() or self.LastGearAngle ~= self:GetGearAngle() then
		self.LastGearOffset = self:GetGearOffset()
		self.LastGearAngle = self:GetGearAngle()

		self:RebuildActiveGear()
	end


	local gearData = GMBlox.ValidGears[gear]
	if not gearData or not gearData.clThinkCallback then
		return
	end

	local fine, err = pcall(gearData.clThinkCallback, self)

	if not fine then
		print("[GMBLOX] Error in gear think callback for " .. gear .. ": " .. err)
	end
end