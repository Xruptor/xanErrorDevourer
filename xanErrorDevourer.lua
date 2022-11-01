--[[
	xanErrorDevourer
	Created by Xruptor
	
	This addon will eat up those pesky errors that appear on your screen.
	You can add custom errors in the options menu.
--]]

local ADDON_NAME, addon = ...
if not _G[ADDON_NAME] then
	_G[ADDON_NAME] = CreateFrame("Frame", ADDON_NAME, UIParent, BackdropTemplateMixin and "BackdropTemplate")
end
addon = _G[ADDON_NAME]

local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

local storedBarCount = 0
local prevClickedBar
local errorList = ""

local debugf = tekDebug and tekDebug:GetFrame(ADDON_NAME)
local function Debug(...)
    if debugf then debugf:AddMessage(string.join(", ", tostringall(...))) end
end

addon:RegisterEvent("ADDON_LOADED")
addon:SetScript("OnEvent", function(self, event, ...)
	if event == "ADDON_LOADED" or event == "PLAYER_LOGIN" then
		if event == "ADDON_LOADED" then
			local arg1 = ...
			if arg1 and arg1 == ADDON_NAME then
				self:UnregisterEvent("ADDON_LOADED")
				self:RegisterEvent("PLAYER_LOGIN")
			end
			return
		end
		if IsLoggedIn() then
			self:EnableAddon(event, ...)
			self:UnregisterEvent("PLAYER_LOGIN")
		end
		return
	end
	if self[event] then
		return self[event](self, event, ...)
	end
end)


local function updateErrorList()
	errorList = ""
	for k, v in pairs(xErrD_DB) do
		errorList = errorList.."|"..string.lower(k)
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
	
	local ver = GetAddOnMetadata(ADDON_NAME,"Version") or '1.0'
	DEFAULT_CHAT_FRAME:AddMessage(string.format("|cFF99CC33%s|r [v|cFF20ff20%s|r] loaded:   /xed", ADDON_NAME, ver or "1.0"))
	
end

--Nom-Nom-Nom Errors!
local originalOnEvent = UIErrorsFrame:GetScript("OnEvent")
UIErrorsFrame:SetScript("OnEvent", function(self, event, num, msg, r, g, b, ...)

	--only allow errors that aren't in our list
	if msg then
	
		--check out DB
		if xErrD_DB[string.lower(msg)] then
			return
		end
		--check with find in string
		if errorList and string.find(errorList, string.lower(msg)) then
			return
		end
		
		--return original
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
addErrorBTN = CreateFrame("Button", ADDON_NAME.."_AddError", addon, "UIPanelButtonTemplate")
addErrorBTN:SetWidth(120)
addErrorBTN:SetHeight(25)
addErrorBTN:SetPoint("BOTTOMLEFT", addon, "BOTTOMLEFT", 20, 15)
addErrorBTN:SetText(L.AddError)
addErrorBTN:SetScript("OnClick", function() StaticPopup_Show("XANERRD_ADDERROR") end)

--Remove Error
RemErrorBTN = CreateFrame("Button", ADDON_NAME.."_RemoveError", addon, "UIPanelButtonTemplate")
RemErrorBTN:SetWidth(120)
RemErrorBTN:SetHeight(25)
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
		local text = self.editBox:GetText()
		addon:processAdd(text)
	end,
	whileDead = 1,
	maxLetters = 255,
}

function addon:DoErrorList()
	scrollFrame_Child:SetPoint("TOPLEFT")
	scrollFrame_Child:SetWidth(scrollFrame:GetWidth())
	scrollFrame_Child:SetHeight(scrollFrame:GetHeight())
	
	local previousBar
	local buildList = {}
	
	--first lets collect all the known items
	--standard error list
	for k, v in pairs(xErrD) do
		table.insert(buildList, { name=string.lower(k), val=1 } )
	end
	--localized error list
	for k, v in pairs(xErrD_LOC) do
		table.insert(buildList, { name=string.lower(k), val=2 } )
	end
	--custom db
	for k, v in pairs(xErrD_CDB) do
		table.insert(buildList, { name=string.lower(k), val=3 } )
	end
	
	--sort it based on where the list is coming from
	table.sort(buildList, function(a,b) return (a.val < b.val) end)
	
	for barCount=1, table.getn(buildList) do
		
		--store the bar counts for future use
		if barCount > storedBarCount then storedBarCount = barCount end
		
		local barSlot = _G["xED_Bar"..barCount] or CreateFrame("button", "xED_Bar"..barCount, scrollFrame_Child, BackdropTemplateMixin and "BackdropTemplate")
		
		if barCount==1 then
			barSlot:SetPoint("TOPLEFT",scrollFrame_Child, "TOPLEFT", 10, -10)
			barSlot:SetPoint("BOTTOMRIGHT",scrollFrame_Child, "TOPRIGHT", -10, -30)
		else
			barSlot:SetPoint("TOPLEFT", previousBar, "BOTTOMLEFT", 0, 0)
			barSlot:SetPoint("BOTTOMRIGHT", previousBar, "BOTTOMRIGHT", 0, -20)
		end

		barSlot:EnableMouse(true)
		barSlot:SetBackdrop({
			bgFile = "Interface\\Buttons\\WHITE8x8",
		})
        barSlot:SetBackdropColor(0,0,0,0)
		--barSlot:SetScript("OnEnter", function(self) self:SetBackdropColor(0,1,0,0.25) end)
		--barSlot:SetScript("OnLeave", function(self) self:SetBackdropColor(0,0,0,0) end)
		
		--store previous bar to position correctly for next one ;)
		previousBar = barSlot

		--store the data
		barSlot.xData = buildList[barCount]
		
		--set as current clicked bar for removal if clicked
		barSlot:SetScript("OnClick", function(self)
			if prevClickedBar then
				prevClickedBar:SetBackdropColor(0,0,0,0)
			end
			prevClickedBar = self
			self:SetBackdropColor(0,1,0,0.25)
			--enable or disable remove button based on val
			if self.xData and self.xData.val and self.xData.val == 3 then
				RemErrorBTN:Enable()
			else
				RemErrorBTN:Disable()
			end
		end)
		
		--check button stuff
		local bar_chk = _G["xED_BarChk"..barCount] or CreateFrame("CheckButton", "xED_BarChk"..barCount, barSlot, "InterfaceOptionsCheckButtonTemplate")
		
		--change text color depending on where the entry came from
		if buildList[barCount].val == 1 then
			--standard list
			_G["xED_BarChk"..barCount.."Text"]:SetText("|cFFFFFFFF"..buildList[barCount].name.."|r")
		elseif buildList[barCount].val == 2 then
			--localizard list
			_G["xED_BarChk"..barCount.."Text"]:SetText("|cFF61F200"..buildList[barCount].name.."|r")
		else
			--custom list
			_G["xED_BarChk"..barCount.."Text"]:SetText("|cFFFF9933"..buildList[barCount].name.."|r")
		end
		_G["xED_BarChk"..barCount.."Text"]:SetFontObject("GameFontNormal")
        
		--store the data
		bar_chk.xData = buildList[barCount]
		
        bar_chk:SetPoint("LEFT", 4, 0)
		--bar_chk:SetScript("OnEnter", function() barSlot:SetBackdropColor(0,1,0,0.25) end)
		--bar_chk:SetScript("OnLeave", function() barSlot:SetBackdropColor(0,0,0,0) end)
		
		--set if checked or not
		if xErrD_DB and xErrD_DB[buildList[barCount].name] then
			bar_chk:SetChecked(true)
		else
			bar_chk:SetChecked(false)
        end
		
		bar_chk:SetScript("OnClick", function(self)
			local checked = self:GetChecked()
			
			--update the DB
			if self.xData and self.xData.name and xErrD_DB then
				if checked then
					xErrD_DB[self.xData.name] = true
				else
					--delete it if it exsists
					if xErrD_DB[self.xData.name] then xErrD_DB[self.xData.name] = nil end
				end
				--update error list
				updateErrorList()
			end
			--highlight the bar ;)
			self:GetParent():Click()
		end)
		
		--show them if hidden
		barSlot:Show()
		bar_chk:Show()
	end
	
	--hide the unused bars (if some custom ones were removed)
	if table.getn(buildList) < storedBarCount then
		for q=table.getn(buildList)+1, storedBarCount do
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
	
	err = string.lower(err) --force to lowercase
	if xErrD_CDB[err] then return end --don't add the same darn error twice
	
	xErrD_CDB[err] = true --lets add it to the custom DB
	xErrD_DB[err] = true --lets automatically enable it
	
	--update error list
	updateErrorList()
	
	--refresh the scroll
	addon:DoErrorList()
end
