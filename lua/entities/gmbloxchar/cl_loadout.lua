file.CreateDir("gmblox/gearpresets")

local function makeGearPanel(name, parent)
	local basebtn = vgui.Create("DButton")
	basebtn:SetSize(300, 48)
	basebtn:SetText("")


	local c_base = Color(200, 200, 200)
	local c_brght = Color(225, 225, 225)
	local c_checked = Color(150, 200, 150)
	local c_checked_brght = Color(175, 225, 175)

	local iteminfo = GMBlox.ValidGears[name]

	local copy_lidf = parent.panelidf
	local iconmat = Material(iteminfo.icon, "nocull ignorez smooth")
	function basebtn:Paint(w, h)
		local mod = (copy_lidf % 2) == 1
		local col = (parent.targetItems[name] ~= true) and (mod and c_base or c_brght) or (mod and c_checked or c_checked_brght)

		surface.SetDrawColor(col)
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(iconmat)

		surface.DrawTexturedRect(0, 0, 48, 48)
	end


	function basebtn:DoClick()
		if parent.totalTarget >= 9 and not (parent.targetItems[name] or false) then
			return
		end

		parent.totalTarget = parent.totalTarget + (parent.targetItems[name] and -1 or 1)

		if parent.targetItems[name] then
			parent.targetItems[name] = nil
		else
			parent.targetItems[name] = true
		end
	end

	local nmtext = vgui.Create("DLabel", basebtn)
	nmtext:SetText(name)
	nmtext:SetPos(48 + 8, 8)
	nmtext:SizeToContents()
	nmtext:SetColor(Color(0, 0, 0))

	local desctext = vgui.Create("DLabel", basebtn)
	desctext:SetText(iteminfo.desc)
	desctext:SetPos(48 + 8, 24)
	desctext:SizeToContents()
	desctext:SetColor(Color(0, 0, 0))

	parent.panelidf = parent.panelidf + 1
	return basebtn
end

local function saveCurrentSelected(tbl, name)
	if name == "" then
		return
	end

	-- sanitize name
	name = string.gsub(name, " ", "_")
	name = string.gsub(name, "<", "_")
	name = string.gsub(name, ">", "_")
	name = string.gsub(name, ":", "_")
	name = string.gsub(name, "\"", "_")
	name = string.gsub(name, "/", "_")
	name = string.gsub(name, "\\", "_")
	name = string.gsub(name, "|", "_")
	name = string.gsub(name, "?", "_")
	name = string.gsub(name, "*", "_")


	local copytbl = {}
	local count = 0

	for k, v in pairs(tbl) do
		if count >= 9 then
			break
		end

		copytbl[#copytbl + 1] = k
		count = count + 1
	end

	local json = util.TableToJSON(copytbl, false)
	file.Write("gmblox/gearpresets/" .. name .. ".txt", json)
end

local function loadFromSave(name, parent)
	if not file.Exists("gmblox/gearpresets/" .. name .. ".txt", "DATA") then
		return
	end

	local json = file.Read("gmblox/gearpresets/" .. name .. ".txt", "DATA")
	if not json then
		return
	end

	local tbl = util.JSONToTable(json)
	if not tbl then
		return
	end
	if #tbl > 9 then -- someones been modifying stuff :/
		for i = 10, #tbl do
			tbl[i] = nil
		end
	end

	parent.targetItems = {}
	for k, v in ipairs(tbl) do
		if not GMBlox.ValidGears[v] then
			continue
		end

		if not GMBlox.IsAllowedLUT[v] then
			continue
		end

		parent.targetItems[v] = true
	end
end

local function removeSave(name)
	if not file.Exists("gmblox/gearpresets/" .. name .. ".txt", "DATA") then
		return
	end
	file.Delete("gmblox/gearpresets/" .. name .. ".txt")
end


local function makePanelPresets(ent, parent, frame)
	local dComboLoad = vgui.Create("DComboBox", parent)
	dComboLoad:SetSize(288, 24)
	dComboLoad:SetText("")
	dComboLoad:SetValue("Saved presets")
	dComboLoad:SetTextColor(Color(0, 0, 0))


	function dComboLoad:RebuildChoices()
		self:Clear()
		for k, v in pairs(file.Find("gmblox/gearpresets/*.txt", "DATA")) do
			local nameNoExt = string.sub(v, 1, -5)

			self:AddChoice(nameNoExt)
		end
	end

	dComboLoad:RebuildChoices()

	local buttonLoadFromSave = vgui.Create("DButton", parent)
	buttonLoadFromSave:SetSize(288, 64)
	buttonLoadFromSave:SetPos(0, 24)
	buttonLoadFromSave:SetText("Load from save")
	buttonLoadFromSave:SetDisabled(true)

	function buttonLoadFromSave:DoClick()
		loadFromSave(dComboLoad:GetValue(), frame)
	end

	local buttonSaveToSave = vgui.Create("DButton", parent)
	buttonSaveToSave:SetSize(288, 64)
	buttonSaveToSave:SetPos(0, 24 + 64)
	buttonSaveToSave:SetText("Save to save")

	function buttonSaveToSave:DoClick()
		Derma_StringRequest("Save preset", "Enter a name for this preset", "", function(text)
			saveCurrentSelected(frame.targetItems, text)
			dComboLoad:RebuildChoices()
		end)
	end

	local buttonRemoveSave = vgui.Create("DButton", parent)
	buttonRemoveSave:SetSize(288, 64)
	buttonRemoveSave:SetPos(0, 24 + 64 * 2)
	buttonRemoveSave:SetText("Remove save")
	buttonRemoveSave:SetDisabled(true)

	function buttonRemoveSave:DoClick()
		Derma_Query("Are you sure you want to remove this save?", "Remove save", "Yes", function()
			removeSave(dComboLoad:GetValue())
			dComboLoad:RebuildChoices()
		end, "No", function() end)
	end


	function dComboLoad:OnSelect(index, value, data)
		buttonLoadFromSave:SetDisabled(false)
		buttonRemoveSave:SetDisabled(false)
	end
end

local function makeLoadoutPrompt(ent)
	local frameLoadout = vgui.Create("DFrame")
	frameLoadout.panelidf = 0
	frameLoadout.targetItems = {}
	frameLoadout.totalTarget = 0

	local dloadout = GetConVar("gmblox_defaultloadout"):GetString()
	if dloadout and dloadout ~= "none" then
		loadFromSave(dloadout, frameLoadout)
	end


	local fw, fh = 800 * .75, 600 * .75
	frameLoadout:SetSize(fw, fh)
	frameLoadout:Center()
	frameLoadout:SetTitle("GMBlox Loadout")
	frameLoadout:MakePopup()


	local scrollPanelGears = vgui.Create("DScrollPanel", frameLoadout)
	scrollPanelGears:SetSize(fw / 2, fh)
	scrollPanelGears:Dock(LEFT)

	for k, v in pairs(GMBlox.DefaultInventory) do
		local gearPanel = makeGearPanel(v, frameLoadout)
		scrollPanelGears:AddItem(gearPanel)

		gearPanel:Dock(TOP)
	end

	local doneButton = vgui.Create("DButton", frameLoadout)
	doneButton:SetSize(fw / 2, 48)
	doneButton:SetText("Done")
	doneButton:Dock(BOTTOM)

	function doneButton:DoClick()
		local copytbl = {}

		for k, v in pairs(frameLoadout.targetItems) do
			copytbl[#copytbl + 1] = k
		end


		saveCurrentSelected(frameLoadout.targetItems, "LastLoadout")

		ent.Inventory = copytbl
		frameLoadout:Remove()

		net.Start("gmblox_promptloadout_sv")
			net.WriteEntity(ent)
		net.SendToServer()
	end



	local presetPanel = vgui.Create("DPanel", frameLoadout)
	presetPanel:SetSize(fw * .48, fh * .825)
	presetPanel:DockMargin(4, 0, 1, 0)
	presetPanel:Dock(RIGHT)
	makePanelPresets(ent, presetPanel, frameLoadout)
end

net.Receive("gmblox_promptloadout", function(len)
	local target = net.ReadEntity()

	if not IsValid(target) then
		return
	end

	makeLoadoutPrompt(target)
end)