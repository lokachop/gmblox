
function ENT:ToggleShiftLock()
	self.ShLockOn = not self.ShLockOn

	if not self.ShLockOn then
		self.HSetupShLock = false

		net.Start("gmblox_changezoom")
			net.WriteEntity(self)
			net.WriteFloat(self.ZmMult)
		net.SendToServer()
	else

		net.Start("gmblox_changezoom")
			net.WriteEntity(self)
			net.WriteFloat(0)
		net.SendToServer()
	end
end

function ENT:KeyCheckShiftLock()
	if LocalPlayer() ~= self:GetController() then
		return
	end


	if input.IsKeyDown(KEY_LSHIFT) and not (self.HShiftLocked or false) then
		self:ToggleShiftLock()
		self.HShiftLocked = true
	elseif not input.IsKeyDown(KEY_LSHIFT) and (self.HShiftLocked or false) then
		self.HShiftLocked = false
	end
end

function ENT:HandleCamLock()
	if LocalPlayer() ~= self:GetController() then
		return
	end

	if self.ShLockOn and not self.HSetupShLock then
		self.HSetupShLock = true


		RememberCursorPosition()
		gui.EnableScreenClicker(false)
		return
	end

	if self.ShLockOn then
		return
	end

	if input.IsMouseDown(MOUSE_RIGHT) then
		if not (self.HasSavedPos or false) then
			RememberCursorPosition()
			self.HasSavedPos = true
		end
		gui.EnableScreenClicker(false)
	elseif self.ZmMult > 0 then
		if self.HasSavedPos then
			RestoreCursorPosition()
			self.HasSavedPos = false
		end

		gui.EnableScreenClicker(true)
	end

end


function ENT:MakeShiftlockButton()
	local buttonShL = vgui.Create("DButton")
	self.ActiveButtons["shlbutton"] = buttonShL

	buttonShL:SetSize(149, 30)
	buttonShL:SetPos(0, ScrH() - 81) -- ontop of menu button

	buttonShL:SetText("")

	self.NoClickZones["shlbutton"] = {
		x = buttonShL:GetX(),
		y = buttonShL:GetY(),
		w = buttonShL:GetWide(),
		h = buttonShL:GetTall(),
	}

	local t_shl_off = Material("gmblox/vgui/mouseLock_off.png", "nocull ignorez")
	local t_shl_off_h = Material("gmblox/vgui/mouseLock_off_ovr.png", "nocull ignorez")
	local t_shl_on = Material("gmblox/vgui/mouseLock_on.png", "nocull ignorez")
	local t_shl_on_h = Material("gmblox/vgui/mouseLock_on_ovr.png", "nocull ignorez")

	local e_ref = self
	function buttonShL:Paint(w, h)
		local hovered = self:IsHovered()
		local mat = e_ref.ShLockOn and (hovered and t_shl_on_h or t_shl_on) or (hovered and t_shl_off_h or t_shl_off)

		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(mat)
		surface.DrawTexturedRect(0, 0, w, h)
	end

	function buttonShL:DoClick()
		e_ref:ToggleShiftLock()
	end
end