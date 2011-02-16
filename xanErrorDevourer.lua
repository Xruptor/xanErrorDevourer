--[[
	xanErrorDevourer
	Created by Xruptor
	
	This addon will eat up those pesky errors that appear on your screen.
	You can add custom errors in the options menu.
--]]

local storedBarCount = 0
local prevClickedBar

local xED_Frame = CreateFrame("frame","xanErrorDevourer",UIParent)
xED_Frame:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)

--[[------------------------
	ENABLE
--------------------------]]
	
function xED_Frame:PLAYER_LOGIN()

	local ver = tonumber(GetAddOnMetadata("xanErrorDevourer","Version")) or 'Unknown'
	
	--Initialize custom DB
	xErrD_CDB = xErrD_CDB or {}
	
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
	
	--populate scroll
	xED_Frame:DoErrorList()
	
	xED_Frame:UnregisterEvent("PLAYER_LOGIN")
	xED_Frame.PLAYER_LOGIN = nil
	
	SLASH_XANERRORDEVOURER1 = "/xed";
	SlashCmdList["XANERRORDEVOURER"] = function()
		if xanErrorDevourer then
			xanErrorDevourer:DoErrorList()
			xanErrorDevourer:Show()
		end
	end
	
	DEFAULT_CHAT_FRAME:AddMessage("|cFF99CC33xanErrorDevourer|r [v|cFFDF2B2B"..ver.."|r] loaded   /xed")
end

--Nom-Nom-Nom Errors!
local originalOnEvent = UIErrorsFrame:GetScript("OnEvent")
UIErrorsFrame:SetScript("OnEvent", function(self, event, msg, r, g, b, ...)
	--only allow errors that aren't in our list
	if msg and not xErrD_DB[string.lower(msg)] then
		return originalOnEvent(self, event, msg, r, g, b, ...)
	end
end)

--[[------------------------
	OPTIONS
--------------------------]]

xED_Frame:SetFrameStrata("HIGH")
xED_Frame:SetToplevel(true)
xED_Frame:EnableMouse(true)
xED_Frame:SetMovable(true)
xED_Frame:SetClampedToScreen(true)
xED_Frame:SetWidth(380)
xED_Frame:SetHeight(570)

xED_Frame:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 32,
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
})

xED_Frame:SetBackdropColor(0,0,0,1)
xED_Frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

local closeButton = CreateFrame("Button", nil, xED_Frame, "UIPanelCloseButton");
closeButton:SetPoint("TOPRIGHT", xED_Frame, -15, -8);

local header = xED_Frame:CreateFontString("$parentHeaderText", "ARTWORK", "GameFontNormalSmall")
header:SetJustifyH("LEFT")
header:SetFontObject("GameFontNormal")
header:SetPoint("CENTER", xED_Frame, "TOP", 0, -20)
header:SetText("xanErrorDevourer")

local nomnom = xED_Frame:CreateFontString("$parentNomText", "ARTWORK", "GameFontNormalSmall")
nomnom:SetJustifyH("LEFT")
nomnom:SetFontObject("GameFontNormal")
nomnom:SetPoint("CENTER", xED_Frame, "TOP", 0, -35)
nomnom:SetText("|cFF99CC33Nom-Nom-Nom Errors!|r")

local scrollFrame = CreateFrame("ScrollFrame", "xanErrorDevourer_Scroll", xED_Frame, "UIPanelScrollFrameTemplate")
local scrollFrame_Child = CreateFrame("frame", "xanErrorDevourer_ScrollChild", scrollFrame)
scrollFrame:SetPoint("TOPLEFT", 10, -50) 
--scrollbar on the right (x shifts the slider left or right)
scrollFrame:SetPoint("BOTTOMRIGHT", -40, 70) 
scrollFrame:SetScrollChild(scrollFrame_Child)

--hide both frames
scrollFrame:Hide()
xED_Frame:Hide()

--Add Error
addErrorBTN = CreateFrame("Button", "xanErrorDevourer_AddError", xED_Frame, "UIPanelButtonTemplate")
addErrorBTN:SetWidth(120)
addErrorBTN:SetHeight(25)
addErrorBTN:SetPoint("BOTTOMLEFT", xED_Frame, "BOTTOMLEFT", 20, 15)
addErrorBTN:SetText("Add Error")
addErrorBTN:SetScript("OnClick", function() StaticPopup_Show("XANERRD_ADDERROR") end)

--Remove Error
RemErrorBTN = CreateFrame("Button", "xanErrorDevourer_RemoveError", xED_Frame, "UIPanelButtonTemplate")
RemErrorBTN:SetWidth(120)
RemErrorBTN:SetHeight(25)
RemErrorBTN:SetPoint("BOTTOMRIGHT", xED_Frame, "BOTTOMRIGHT", -20, 15)
RemErrorBTN:SetText("Remove Error")
RemErrorBTN:SetScript("OnClick", function()
	if prevClickedBar and prevClickedBar.xData and prevClickedBar.xData.val and prevClickedBar.xData.val == 3 then
		--delete the custom entry
		if xErrD_CDB[prevClickedBar.xData.name] then
			xErrD_CDB[prevClickedBar.xData.name] = nil --remove from custom DB
		end
		if xErrD_DB[prevClickedBar.xData.name] then
			xErrD_DB[prevClickedBar.xData.name] = nil --remove from currently active
		end
		--refresh the scroll
		xED_Frame:DoErrorList()
	end
end)
RemErrorBTN:Disable()

--add error popup box
StaticPopupDialogs["XANERRD_ADDERROR"] = {
	text = "Please type the error exactly!  (Including Punctuation)",
	button1 = "Yes",
	button2 = "No",
	hasEditBox = true,
    hasWideEditBox = true,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1,
	EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
	OnAccept = function (self, data, data2)
		local text = self.editBox:GetText()
		xED_Frame:processAdd(text)
	end,
	whileDead = 1,
	maxLetters = 255,
}

function xED_Frame:DoErrorList()
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
		
		local barSlot = _G["xED_Bar"..barCount] or CreateFrame("button", "xED_Bar"..barCount, scrollFrame_Child)
		
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
		local bar_chk = _G["xED_BarChk"..barCount] or CreateFrame("CheckButton", "xED_BarChk"..barCount, barSlot, "OptionsCheckButtonTemplate")
		
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
			local checked = (self:GetChecked() and true or false)
			self:SetChecked(checked or true and false)
			checked = self:GetChecked() and true or false
			
			--update the DB
			if self.xData and self.xData.name and xErrD_DB then
				if checked then
					xErrD_DB[self.xData.name] = true
				else
					--delete it if it exsists
					if xErrD_DB[self.xData.name] then xErrD_DB[self.xData.name] = nil end
				end
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

function xED_Frame:processAdd(err)
	if not err then return end
	if not xErrD_CDB then return end
	
	err = string.lower(err) --force to lowercase
	if xErrD_CDB[err] then return end --don't add the same darn error twice
	
	xErrD_CDB[err] = true --lets add it to the custom DB
	xErrD_DB[err] = true --lets automatically enable it
	
	--refresh the scroll
	xED_Frame:DoErrorList()
end

--[[------------------------
	INITIALIZE
--------------------------]]

if IsLoggedIn() then xED_Frame:PLAYER_LOGIN() else xED_Frame:RegisterEvent("PLAYER_LOGIN") end
