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

local function CreateNumericSpinner(labeltext, min, max, tooltip_text)
	local w = TEMPLATES.LabelNumericSpinner(labeltext, min, max, label_width, spinner_width, spinner_height, space_between, nil, nil, narrow_field_nudge, tooltip_text)
	AddListItemBackground(w)
	return w.spinner
end

local function CreateTextSpinner(labeltext, spinnerdata, tooltip_text)
	local w = TEMPLATES.LabelSpinner(labeltext, spinnerdata, label_width, spinner_width, spinner_height, space_between, nil, nil, narrow_field_nudge, nil, nil, tooltip_text)
	AddListItemBackground(w)

	return w.spinner
end

local function MakeSpinnerTooltip(root)
	local spinner_tooltip = root:AddChild(Text(CHATFONT, 25, ""))
	spinner_tooltip:SetPosition(90, -275)
	spinner_tooltip:SetHAlign(ANCHOR_LEFT)
	spinner_tooltip:SetVAlign(ANCHOR_TOP)
	spinner_tooltip:SetRegionSize(800, 80)
	spinner_tooltip:EnableWordWrap(true)

	return spinner_tooltip
end

local function AddSpinnerTooltip(widget, tooltip, tooltipdivider)
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

	if widget.spinner then
		widget.spinner.ongainfocusfn = ongainfocus
	elseif widget.button then
		widget.button.ongainfocus = ongainfocus
	end

	widget.bg.onlosefocus = onlosefocus

	if widget.spinner then
		widget.spinner.onlosefocusfn = onlosefocus
	elseif widget.button then
		widget.button.onlosefocus = onlosefocus
	end
end

local enableDisableOptions = {
    { text = STRINGS.UI.OPTIONS.DISABLED, data = false },
    { text = STRINGS.UI.OPTIONS.ENABLED,  data = true  }
}

local function fovOptions()
	local fovs = {  }

	for fov = _G.LFC.MIN_FOV, _G.LFC.MAX_FOV, 5 do
		table.insert(fovs, { text = tostring(fov), data = fov })
	end
	
	return fovs
end

local FreeCamSettingsTab = Class(Widget, function(self, owner)
    self.owner = owner
    Widget._ctor(self, "FreeCamSettingsTab")

    self.grid = self:AddChild(Grid())
    self.grid:SetPosition(-90, 184, 0)

    self.sensitivitySpinner = CreateNumericSpinner(LFC.SETTINGS.OPTIONS.SENSITIVITY.NAME, 1, 20, LFC.SETTINGS.OPTIONS.SENSITIVITY.TOOLTIP)
    self.sensitivitySpinner.OnChanged = function(_, data)
		self.owner.working[LFC.SETTINGS.OPTIONS.SENSITIVITY.OPTIONS_STR] = data
		self.owner:UpdateMenu()
	end
    self.sensitivitySpinner:Enable()

    self.limitedSpinner = CreateTextSpinner(LFC.SETTINGS.OPTIONS.LIMITED.NAME, enableDisableOptions, LFC.SETTINGS.OPTIONS.LIMITED.TOOLTIP)
    self.limitedSpinner.OnChanged = function(_, data)
		self.owner.working[LFC.SETTINGS.OPTIONS.LIMITED.OPTIONS_STR] = data
		self.owner:UpdateMenu()
	end
    self.limitedSpinner:Enable()

    self.fovSpinner = CreateTextSpinner(LFC.SETTINGS.OPTIONS.FOV.NAME, fovOptions(), LFC.SETTINGS.OPTIONS.FOV.TOOLTIP)
    self.fovSpinner.OnChanged = function(_, data)
		self.owner.working[LFC.SETTINGS.OPTIONS.FOV.OPTIONS_STR] = data
		self.owner:UpdateMenu()
	end
    self.fovSpinner:Enable()

	self.left_spinners_graphics = {}
    table.insert(self.left_spinners_graphics, self.sensitivitySpinner)
    table.insert(self.left_spinners_graphics, self.fovSpinner)
    table.insert(self.left_spinners_graphics, self.limitedSpinner)

	self.grid:UseNaturalLayout()
	self.grid:InitSize(2, #self.left_spinners_graphics, 440, 40)

	local spinner_tooltip = MakeSpinnerTooltip(self)
	local spinner_tooltip_divider = self:AddChild(Image("images/global_redux.xml", "item_divider.tex"))
	spinner_tooltip_divider:SetPosition(90, -225)

	for k, v in ipairs(self.left_spinners_graphics) do
		self.grid:AddItem(v.parent, 1, k)
		AddSpinnerTooltip(v.parent, spinner_tooltip, spinner_tooltip_divider)
	end

    self.focus_forward = self.grid
end)

return FreeCamSettingsTab