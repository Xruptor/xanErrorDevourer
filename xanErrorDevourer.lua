--[[
	xanErrorDevourer
	Created by Xruptor
	
	This addon will eat up those pesky errors that appear on your screen.
	You can add custom errors in the options menu.
--]]

local ADDON_NAME, private = ...
if type(private) ~= "table" then
	private = {}
end

local _G = _G
local string = string
local table = table
local pairs = pairs
local type = type

local lower = string.lower
local find = string.find
local tinsert = table.insert
local tsort = table.sort

local addon = _G[ADDON_NAME]
if not addon then
	addon = CreateFrame("Frame", ADDON_NAME, UIParent, BackdropTemplateMixin and "BackdropTemplate")
	_G[ADDON_NAME] = addon
end

local L = private.L or {}

local storedBarCount = 0
local prevClickedBar
local errorList = ""
local errorListEmpty = true

local function OnEvent(self, event, ...)
	if event == "ADDON_LOADED" then
		local name = ...
		if name ~= ADDON_NAME then return end
		self:UnregisterEvent("ADDON_LOADED")
		if IsLoggedIn() then
			self:EnableAddon()
		else
			self:RegisterEvent("PLAYER_LOGIN")
		end
		return
	end
	if event == "PLAYER_LOGIN" then
		self:UnregisterEvent("PLAYER_LOGIN")
		self:EnableAddon()
		return
	end
	local handler = self[event]
	if handler then
		return handler(self, event, ...)
	end
end

addon:RegisterEvent("ADDON_LOADED")
addon:SetScript("OnEvent", OnEvent)


local function updateErrorList()
	if not xErrD_DB then
		errorList = ""
		errorListEmpty = true
		return
	end
	local parts = {}
	for k, v in pairs(xErrD_DB) do
		if v and type(k) == "string" then
			parts[#parts + 1] = lower(k)
		end
	end
	if #parts == 0 then
		errorList = ""
		errorListEmpty = true
	else
		errorList = "|" .. table.concat(parts, "|")
		errorListEmpty = false
	end
end

--[[------------------------
	ENABLE
--------------------------]]
	
function addon:EnableAddon()

	--Initialize custom DB
	xErrD_CDB = xErrD_CDB or {}
	xErrD_LOC = xErrD_LOC or {}
	
	--first time DB check
	if xErrD_DB == nil then
		--do a one complete setup
		xErrD_DB = {}
		--standard error list (only do the ones that are on by default)
		for k, v in pairs(xErrD) do
			if k and v then
				xErrD_DB[string.lower(k)] = true
			end
		end
		--localized error list
		for k, v in pairs(xErrD_LOC) do
			if k and v then
				xErrD_DB[string.lower(k)] = true
			end
		end
		local getMeta = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
		local ver = (type(getMeta) == "function" and getMeta(ADDON_NAME, "Version")) or "1.0"
		xErrD_DB.dbver = ver
	end
	
	--update error list
	updateErrorList()
	
	--populate scroll
	addon:DoErrorList()
	
	SLASH_XANERRORDEVOURER1 = "/xed";
	SlashCmdList["XANERRORDEVOURER"] = function()
		addon:DoErrorList()
		addon:Show()
	end
	
	local getMeta = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
	local ver = (type(getMeta) == "function" and getMeta(ADDON_NAME, "Version")) or "1.0"
	DEFAULT_CHAT_FRAME:AddMessage(string.format("|cFF99CC33%s|r [v|cFF20ff20%s|r] loaded:   /xed", ADDON_NAME, ver))
	
end

--Nom-Nom-Nom Errors!
local originalOnEvent = UIErrorsFrame:GetScript("OnEvent")
UIErrorsFrame:SetScript("OnEvent", function(self, event, num, msg, r, g, b, ...)
	if not msg then
		if originalOnEvent then
			return originalOnEvent(self, event, num, msg, r, g, b, ...)
		end
		return
	end
	if not xErrD_DB then
		if originalOnEvent then
			return originalOnEvent(self, event, num, msg, r, g, b, ...)
		end
		return
	end
	local msgLower = lower(msg)
	if xErrD_DB[msgLower] then
		return
	end
	if not errorListEmpty and find(errorList, msgLower, 1, true) then
		return
	end
	if originalOnEvent then
		return originalOnEvent(self, event, num, msg, r, g, b, ...)
	end
end)

--[[------------------------
	OPTIONS
--------------------------]]

addon:SetFrameStrata("HIGH")
addon:SetToplevel(true)
addon:EnableMouse(true)
addon:SetMovable(true)
addon:SetClampedToScreen(true)
addon:SetWidth(380)
addon:SetHeight(570)

addon:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 32,
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
})

addon:SetBackdropColor(0,0,0,1)
addon:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

local closeButton = CreateFrame("Button", nil, addon, "UIPanelCloseButton");
closeButton:SetPoint("TOPRIGHT", addon, -15, -8);

local header = addon:CreateFontString("$parentHeaderText", "ARTWORK", "GameFontNormalSmall")
header:SetJustifyH("LEFT")
header:SetFontObject("GameFontNormal")
header:SetPoint("CENTER", addon, "TOP", 0, -20)
header:SetText(ADDON_NAME)

local nomnom = addon:CreateFontString("$parentNomText", "ARTWORK", "GameFontNormalSmall")
nomnom:SetJustifyH("LEFT")
nomnom:SetFontObject("GameFontNormal")
nomnom:SetPoint("CENTER", addon, "TOP", 0, -35)
nomnom:SetText(L.NomNomNom)

local scrollFrame = CreateFrame("ScrollFrame", ADDON_NAME.."_Scroll", addon, "UIPanelScrollFrameTemplate")
local scrollFrame_Child = CreateFrame("frame", ADDON_NAME.."_ScrollChild", scrollFrame, BackdropTemplateMixin and "BackdropTemplate")
scrollFrame:SetPoint("TOPLEFT", 10, -50) 
--scrollbar on the right (x shifts the slider left or right)
scrollFrame:SetPoint("BOTTOMRIGHT", -40, 70) 
scrollFrame:SetScrollChild(scrollFrame_Child)

--hide both frames
scrollFrame:Hide()
addon:Hide()

--Add Error
local addErrorBTN = CreateFrame("Button", ADDON_NAME.."_AddError", addon, "UIPanelButtonTemplate")
addErrorBTN:SetSize(120, 25)
addErrorBTN:SetPoint("BOTTOMLEFT", addon, "BOTTOMLEFT", 20, 15)
addErrorBTN:SetText(L.AddError)
addErrorBTN:SetScript("OnClick", function() StaticPopup_Show("XANERRD_ADDERROR") end)

--Remove Error
local RemErrorBTN = CreateFrame("Button", ADDON_NAME.."_RemoveError", addon, "UIPanelButtonTemplate")
RemErrorBTN:SetSize(120, 25)
RemErrorBTN:SetPoint("BOTTOMRIGHT", addon, "BOTTOMRIGHT", -20, 15)
RemErrorBTN:SetText(L.RemoveError)
RemErrorBTN:SetScript("OnClick", function()
	if prevClickedBar and prevClickedBar.xData and prevClickedBar.xData.val and prevClickedBar.xData.val == 3 then
		--delete the custom entry
		if xErrD_CDB[prevClickedBar.xData.name] then
			xErrD_CDB[prevClickedBar.xData.name] = nil --remove from custom DB
		end
		if xErrD_DB[prevClickedBar.xData.name] then
			xErrD_DB[prevClickedBar.xData.name] = nil --remove from currently active
		end
		--update error list
		updateErrorList()
		--refresh the scroll
		addon:DoErrorList()
	end
end)
RemErrorBTN:Disable()

--add error popup box
StaticPopupDialogs["XANERRD_ADDERROR"] = {
	text = L.InfoCustomAdd,
	button1 = L.Yes,
	button2 = L.No,
	hasEditBox = true,
    hasWideEditBox = true,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1,
	EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
	OnAccept = function (self, data, data2)
		--for backwards compatibility for older clients
		local eb = self.editBox or self.EditBox or self:GetEditBox()
		local text = eb:GetText()
		addon:processAdd(text)
	end,
	whileDead = 1,
	maxLetters = 255,
}

function addon:DoErrorList()
	scrollFrame_Child:SetPoint("TOPLEFT")
	scrollFrame_Child:SetSize(scrollFrame:GetWidth(), scrollFrame:GetHeight())
	
	local previousBar
	local buildList = {}
	
	--first lets collect all the known items
	--standard error list
	for k in pairs(xErrD) do
		tinsert(buildList, { name=lower(k), val=1 } )
	end
	--localized error list
	for k in pairs(xErrD_LOC) do
		tinsert(buildList, { name=lower(k), val=2 } )
	end
	--custom db
	for k in pairs(xErrD_CDB) do
		tinsert(buildList, { name=lower(k), val=3 } )
	end
	
	--sort it based on where the list is coming from
	tsort(buildList, function(a,b) return (a.val < b.val) end)
	
	local total = #buildList
	for barCount=1, total do
		
		--store the bar counts for future use
		if barCount > storedBarCount then storedBarCount = barCount end
		
		local barSlot = _G["xED_Bar"..barCount]
		if not barSlot then
			barSlot = CreateFrame("button", "xED_Bar"..barCount, scrollFrame_Child, BackdropTemplateMixin and "BackdropTemplate")
			barSlot:EnableMouse(true)
			barSlot:SetBackdrop({
				bgFile = "Interface\\Buttons\\WHITE8x8",
			})
			barSlot:SetBackdropColor(0,0,0,0)
			barSlot:SetScript("OnClick", function(self)
				if prevClickedBar then
					prevClickedBar:SetBackdropColor(0,0,0,0)
				end
				prevClickedBar = self
				self:SetBackdropColor(0,1,0,0.25)
				if self.xData and self.xData.val and self.xData.val == 3 then
					RemErrorBTN:Enable()
				else
					RemErrorBTN:Disable()
				end
			end)
		end
		
		if barCount==1 then
			barSlot:SetPoint("TOPLEFT",scrollFrame_Child, "TOPLEFT", 10, -10)
			barSlot:SetPoint("BOTTOMRIGHT",scrollFrame_Child, "TOPRIGHT", -10, -30)
		else
			barSlot:SetPoint("TOPLEFT", previousBar, "BOTTOMLEFT", 0, 0)
			barSlot:SetPoint("BOTTOMRIGHT", previousBar, "BOTTOMRIGHT", 0, -20)
		end

		--store previous bar to position correctly for next one ;)
		previousBar = barSlot

		--store the data
		barSlot.xData = buildList[barCount]
		
		--check button stuff
		local bar_chk = _G["xED_BarChk"..barCount]
		if not bar_chk then
			bar_chk = CreateFrame("CheckButton", "xED_BarChk"..barCount, barSlot, "InterfaceOptionsCheckButtonTemplate")
			bar_chk:SetPoint("LEFT", 4, 0)
			bar_chk:SetScript("OnClick", function(self)
				local checked = self:GetChecked()
				if self.xData and self.xData.name and xErrD_DB then
					if checked then
						xErrD_DB[self.xData.name] = true
					else
						if xErrD_DB[self.xData.name] then xErrD_DB[self.xData.name] = nil end
					end
					updateErrorList()
				end
				self:GetParent():Click()
			end)
		end
		
		--change text color depending on where the entry came from
		local barText = bar_chk.Text or _G[bar_chk:GetName().."Text"]
		if buildList[barCount].val == 1 then
			--standard list
			barText:SetText("|cFFFFFFFF"..buildList[barCount].name.."|r")
		elseif buildList[barCount].val == 2 then
			--localizard list
			barText:SetText("|cFF61F200"..buildList[barCount].name.."|r")
		else
			--custom list
			barText:SetText("|cFFFF9933"..buildList[barCount].name.."|r")
		end
		barText:SetFontObject("GameFontNormal")
        
		--store the data
		bar_chk.xData = buildList[barCount]
		
		--set if checked or not
		if xErrD_DB and xErrD_DB[buildList[barCount].name] then
			bar_chk:SetChecked(true)
		else
			bar_chk:SetChecked(false)
        end
		
		--show them if hidden
		barSlot:Show()
		bar_chk:Show()
	end
	
	--hide the unused bars (if some custom ones were removed)
	if total < storedBarCount then
		for q=total+1, storedBarCount do
			if _G["xED_Bar"..q] then _G["xED_Bar"..q]:Hide() end
			if _G["xED_BarChk"..q] then _G["xED_BarChk"..q]:Hide() end
		end
	end
	
	--show the scroll frame
	scrollFrame:Show()
end

--[[------------------------
	ADD/REMOVE CUSTOM ERROR
--------------------------]]

function addon:processAdd(err)
	if not err then return end
	if not xErrD_CDB then return end
	
	local trim = strtrim or function(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end
	err = trim(err)
	if err == "" then return end
	err = lower(err) --force to lowercase
	if xErrD_CDB[err] then return end --don't add the same darn error twice
	
	xErrD_CDB[err] = true --lets add it to the custom DB
	xErrD_DB[err] = true --lets automatically enable it
	
	--update error list
	updateErrorList()
	
	--refresh the scroll
	addon:DoErrorList()
end
