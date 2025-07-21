local Widget = require("widgets/widget")
local Grid = require("widgets/grid")
local Text = require("widgets/text")
local Image = require("widgets/image")

local TEMPLATES = require("widgets/redux/templates")

local label_width = 200
local spinner_width = 220
local spinner_height = 36
local narrow_field_nudge = -50
local space_between = 5

local function AddListItemBackground(w)
	local total_width = label_width + spinner_width + space_between
	w.bg = w:AddChild(TEMPLATES.ListItemBackground(total_width + 15, spinner_height + 5))
	w.bg:SetPosition(-40, 0)
	w.bg:MoveToBack()
end

local function CreateNumericSpinner(labeltext, values, tooltip_text)
	local spinnerdata = {  }
	for i = values[1], values[2], values[3] do
		table.insert(spinnerdata, { text = tostring(i), data = i })
	end

	local w = TEMPLATES.LabelSpinner(labeltext, spinnerdata, label_width, spinner_width, spinner_height, space_between, nil, nil, narrow_field_nudge, nil, nil, tooltip_text)
	AddListItemBackground(w)
	return w.spinner
end

local function CreateTextSpinner(labeltext, spinnerdata, tooltip_text)
	local w = TEMPLATES.LabelSpinner(labeltext, spinnerdata, label_width, spinner_width, spinner_height, space_between, nil, nil, narrow_field_nudge, nil, nil, tooltip_text)
	AddListItemBackground(w)

	return w.spinner
end

local function MakeTooltip(root)
	local w = root:AddChild(Text(CHATFONT, 25, ""))
	w:SetPosition(90, -275)
	w:SetHAlign(ANCHOR_LEFT)
	w:SetVAlign(ANCHOR_TOP)
	w:SetRegionSize(800, 80)
	w:EnableWordWrap(true)

	return w
end

local function AddSpinnerTooltip(widget, type, tooltip, tooltipdivider)
	tooltipdivider:Hide()

	local function ongainfocus()
		if tooltip and widget.tooltip_text then
			tooltip:SetString(widget.tooltip_text)
			tooltipdivider:Show()
		end
	end
	
	local function onlosefocus()
		if widget.parent and not widget.parent.focus then
			tooltip:SetString("")
			tooltipdivider:Hide()
		end
	end

	widget.bg.ongainfocus = ongainfocus
	widget.bg.onlosefocus = onlosefocus

	if type == LFC.SETTING_TYPES.SPINNER or type == LFC.SETTING_TYPES.NUM_SPINNER then
		widget.spinner.ongainfocusfn = ongainfocus
		widget.spinner.onlosefocusfn = onlosefocus
	end
end

local LFCSettingsTab = Class(Widget, function(self, owner)
    self.owner = owner
    Widget._ctor(self, "LFCSettingsTab")

    self.grid = self:AddChild(Grid())
    self.grid:SetPosition(-90, 184, 0)

	self.left_column = {  }
	self.right_column = {  }
	for name, setting in pairs(LFC.MOD_SETTINGS.SETTINGS) do
		local widget_name = ""
		if setting.TYPE == LFC.SETTING_TYPES.SPINNER then
			widget_name = string.lower(setting.ID).."_spinner"
			self[widget_name] = CreateTextSpinner(setting.NAME, setting.VALUES, setting.TOOLTIP)
			self[widget_name].OnChanged = function(_, data)
				self.owner.working[setting.ID] = data
				self.owner:UpdateMenu()
			end
		end
		
		if setting.TYPE == LFC.SETTING_TYPES.NUM_SPINNER then
			widget_name = string.lower(setting.ID).."_spinner"
			self[widget_name] = CreateNumericSpinner(setting.NAME, setting.VALUES, setting.TOOLTIP)
			self[widget_name].OnChanged = function(_, data)
				self.owner.working[setting.ID] = data
				self.owner:UpdateMenu()
			end
			self[widget_name].min = setting.VALUES[1]
			self[widget_name].step = setting.VALUES[3]
		end

		if widget_name ~= "" then
			self[widget_name]:Enable()
			self[widget_name].type = setting.TYPE
			self[widget_name].setting_id = setting.ID
			table.insert(setting.COLUMN == 1 and self.left_column or self.right_column, self[widget_name])
		else
			LFC.modprint(LFC.WARN, "Potentially invalid mod setting type detected! Check your environment file!", "Setting name - "..name, "Setting type - "..setting.TYPE)
		end
	end

	self.grid:UseNaturalLayout()
	self.grid:InitSize(2, #self.left_column, 440, 40)

	local spinner_tooltip = MakeTooltip(self)
	local spinner_tooltip_divider = self:AddChild(Image("images/global_redux.xml", "item_divider.tex"))
	spinner_tooltip_divider:SetPosition(90, -225)

	for k, v in ipairs(self.left_column) do
		self.grid:AddItem(v.parent, 1, k)
		AddSpinnerTooltip(v.parent, v.type, spinner_tooltip, spinner_tooltip_divider)
	end

	for k, v in ipairs(self.right_column) do
		self.grid:AddItem(v.parent, 2, k)
		AddSpinnerTooltip(v.parent, v.type, spinner_tooltip, spinner_tooltip_divider)
	end

    self.focus_forward = self.grid
end)

return LFCSettingsTab