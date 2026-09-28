local cloneref = cloneref or clonereference or function(i) return i end
local CoreGui = cloneref(game:GetService("CoreGui"))
local GuiService = cloneref(game:GetService("GuiService"))
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local SoundService = cloneref(game:GetService("SoundService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local TextService = cloneref(game:GetService("TextService"))
local Teams = cloneref(game:GetService("Teams"))
local TweenService = cloneref(game:GetService("TweenService"))
local HttpService = cloneref(game:GetService("HttpService"))
local getgenv = getgenv or function() return shared end
local setclipboard = setclipboard or nil
local protectgui = protectgui or (syn and syn.protect_gui) or function() end
local gethui = gethui or function() return CoreGui end
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Mouse = LocalPlayer:GetMouse()
local BaseURL = "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/"
local CustomImageManager = {}
local CustomImageManagerAssets = {
	TransparencyTexture = { RobloxId = 139785960036434, Path = "LiquidGlass/assets/TransparencyTexture.png", URL = BaseURL .. "assets/TransparencyTexture.png", Id = nil },
	SaturationMap = { RobloxId = 4155801252, Path = "LiquidGlass/assets/SaturationMap.png", URL = BaseURL .. "assets/SaturationMap.png", Id = nil },
	LoadingIcon = { RobloxId = 97544096941083, Path = "LiquidGlass/assets/LoadingIcon.png", URL = BaseURL .. "assets/LoadingIcon.png", Id = nil },
	CheckIcon = { RobloxId = 97682394690683, Path = "LiquidGlass/assets/CheckIcon.png", URL = BaseURL .. "assets/CheckIcon.png", Id = nil },
}
do
	local function RecursiveCreatePath(Path, IsFile)
		if not isfolder or not makefolder then return end
		local Segments = Path:split("/")
		local Traversed = ""
		if IsFile then table.remove(Segments, #Segments) end
		for _, Seg in ipairs(Segments) do
			if not isfolder(Traversed .. Seg) then makefolder(Traversed .. Seg) end
			Traversed = Traversed .. Seg .. "/"
		end
		return Traversed
	end
	function CustomImageManager.AddAsset(AssetName, RobloxAssetId, URL, ForceRedownload)
		if CustomImageManagerAssets[AssetName] ~= nil then error(string.format("Asset %q exists", AssetName)) end
		CustomImageManagerAssets[AssetName] = { RobloxId = RobloxAssetId, Path = string.format("LiquidGlass/custom_assets/%s", AssetName), URL = URL, Id = nil }
		CustomImageManager.DownloadAsset(AssetName, ForceRedownload)
	end
	function CustomImageManager.GetAsset(AssetName)
		if not CustomImageManagerAssets[AssetName] then return nil end
		local Data = CustomImageManagerAssets[AssetName]
		if Data.Id then return Data.Id end
		local AssetID = string.format("rbxassetid://%s", Data.RobloxId)
		if getcustomasset then
			local Success, NewID = pcall(getcustomasset, Data.Path)
			if Success and NewID then AssetID = NewID end
		end
		Data.Id = AssetID
		return AssetID
	end
	function CustomImageManager.DownloadAsset(AssetName, ForceRedownload)
		if not getcustomasset or not writefile or not isfile then return false end
		local Data = CustomImageManagerAssets[AssetName]
		RecursiveCreatePath(Data.Path, true)
		if ForceRedownload ~= true and isfile(Data.Path) then return true end
		local success = pcall(function() writefile(Data.Path, game:HttpGet(Data.URL)) end)
		return success
	end
	for Name, _ in CustomImageManagerAssets do CustomImageManager.DownloadAsset(Name) end
end
local Library = {
	LocalPlayer = LocalPlayer,
	IsRobloxFocused = true,
	DevicePlatform = nil,
	IsMobile = false,
	IsTablet = false,
	ScreenGui = nil,
	Floats = nil,
	Overlay = nil,
	Window = nil,
	WindowContainer = nil,
	SearchText = "",
	Searching = false,
	GlobalSearch = false,
	LastSearchTab = nil,
	ActiveTab = nil,
	Tabs = {},
	TabButtons = {},
	DependencyBoxes = {},
	KeybindFrame = nil,
	KeybindContainer = nil,
	KeybindToggles = {},
	Notifications = {},
	NotifySide = "Right",
	Dialogues = {},
	ActiveDialog = nil,
	ActiveLoading = nil,
	ContextMenus = {},
	Corners = {},
	SpecificCorners = {},
	TweenInfo = TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	SpringInfo = TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	SoftSpringInfo = TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
	TabTransitionInfo = TweenInfo.new(0.38, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	WindowAnimationInfo = TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	DropdownTransitionInfo = TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	KeyPickerTransitionInfo = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	GroupboxTweenInfo = TweenInfo.new(0.36, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	RotatingChevronTweenInfo = TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	NotifyTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	HoverInfo = TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	RippleInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	PulseInInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	PulseOutInfo = TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	TabSwipeOffset = 30,
	TabSwipeFrom = "bottom",
	Animations = { ToggleWindow = true, TabSwitch = true, Groupbox = true, Dropdown = true, KeyPicker = true },
	Toggled = false,
	Unloaded = false,
	Labels = {},
	Buttons = {},
	Toggles = {},
	Options = {},
	ToggleKeybind = Enum.KeyCode.RightControl,
	ShowToggleFrameInKeybinds = true,
	NotifyOnError = false,
	ShowCustomCursor = true,
	ForceCheckbox = false,
	CantDragForced = false,
	DraggableElements = {},
	Signals = {},
	UnloadSignals = {},
	OriginalMinSize = Vector2.new(480, 360),
	MinSize = Vector2.new(480, 360),
	DPIScale = 1,
	CornerRadius = 16,
	HideMode = "max",
	IsLightTheme = false,
	Scheme = {
		BackgroundColor = Color3.fromRGB(18, 18, 26),
		MainColor = Color3.fromRGB(30, 30, 42),
		SurfaceAlt = Color3.fromRGB(38, 38, 52),
		AccentColor = Color3.fromRGB(125, 145, 255),
		AccentGlow = Color3.fromRGB(160, 180, 255),
		OutlineColor = Color3.fromRGB(72, 72, 94),
		Glass = Color3.fromRGB(44, 44, 62),
		FontColor = Color3.new(1, 1, 1),
		Font = Font.fromEnum(Enum.Font.Gotham),
		RedColor = Color3.fromRGB(255, 70, 90),
		DestructiveColor = Color3.fromRGB(230, 50, 70),
		DarkColor = Color3.new(0, 0, 0),
		WhiteColor = Color3.new(1, 1, 1),
		SuccessColor = Color3.fromRGB(80, 210, 130),
		WarningColor = Color3.fromRGB(240, 190, 80),
	},
	Registry = {},
	Scales = {},
	ScalesOffset = {},
	OriginalMouseIconEnabled = UserInputService.MouseIconEnabled,
	ShowCursorBinding = string.sub(tostring({}), 10),
	ImageManager = CustomImageManager,
}
do
	local Success, Platform = pcall(function() return UserInputService:GetPlatform() end)
	Library.DevicePlatform = Success and Platform or nil
	if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
		Library.IsMobile = true
	elseif UserInputService.TouchEnabled and UserInputService.MouseEnabled then
		Library.IsTablet = true
	else
		Library.IsMobile = false
	end
	if Library.IsMobile then
		Library.OriginalMinSize = Vector2.new(320, 480)
		Library.CornerRadius = 20
	else
		Library.OriginalMinSize = Vector2.new(480, 360)
		Library.CornerRadius = 16
	end
end
local Templates = {
	Frame = { BorderSizePixel = 0 },
	ImageLabel = { BackgroundTransparency = 1, BorderSizePixel = 0 },
	ImageButton = { AutoButtonColor = false, BorderSizePixel = 0 },
	ScrollingFrame = { BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = "AccentColor", ScrollBarImageTransparency = 0.5 },
	TextLabel = { BorderSizePixel = 0, FontFace = "Font", RichText = true, TextColor3 = "FontColor", BackgroundTransparency = 1 },
	TextButton = { AutoButtonColor = false, BorderSizePixel = 0, FontFace = "Font", RichText = true, TextColor3 = "FontColor", BackgroundTransparency = 1 },
	TextBox = { BorderSizePixel = 0, FontFace = "Font", PlaceholderColor3 = function() local H, S, V = Library.Scheme.FontColor:ToHSV() return Color3.fromHSV(H, S, V / 2) end, Text = "", TextColor3 = "FontColor", BackgroundTransparency = 1 },
	UIListLayout = { SortOrder = Enum.SortOrder.LayoutOrder },
	UIStroke = { ApplyStrokeMode = Enum.ApplyStrokeMode.Border },
	UICorner = { CornerRadius = UDim.new(0, 16) },
	UIGradient = {},
	UIScale = {},
	UIPadding = {},
}
local function GetSchemeValue(Index)
	if not Index then return nil end
	return Library.Scheme[Index]
end
local function GetTableSize(Table)
	local Size = 0
	for _ in Table do Size += 1 end
	return Size
end
local function StopTween(Tween, Destroy)
	if not Tween then return end
	if Tween.PlaybackState == Enum.PlaybackState.Playing then Tween:Cancel() end
	if Destroy == true then pcall(Tween.Destroy, Tween) end
end
local function Trim(Text) return Text:match("^%s*(.-)%s*$") end
local function Round(Value, Rounding)
	if Rounding == 0 then return math.floor(Value) end
	return tonumber(string.format("%." .. Rounding .. "f", Value))
end
local function IsMouseInput(Input, IncludeM2)
	return Input.UserInputType == Enum.UserInputType.MouseButton1 or (IncludeM2 == true and Input.UserInputType == Enum.UserInputType.MouseButton2) or Input.UserInputType == Enum.UserInputType.Touch
end
local function IsClickInput(Input, IncludeM2)
	return IsMouseInput(Input, IncludeM2) and Input.UserInputState == Enum.UserInputState.Begin and Library.IsRobloxFocused
end
local function IsHoverInput(Input)
	return (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) and Input.UserInputState == Enum.UserInputState.Change
end
local function IsDragInput(Input, IncludeM2)
	return IsMouseInput(Input, IncludeM2) and (Input.UserInputState == Enum.UserInputState.Begin or Input.UserInputState == Enum.UserInputState.Change) and Library.IsRobloxFocused
end
local function FuzzyScore(Text, Search)
	if Search == "" then return true, 0 end
	if Text == "" then return false, 0 end
	local ExactIdx = Text:find(Search, 1, true)
	if ExactIdx then return true, 1e5 - ExactIdx + (Search:len() * 5) end
	local TextLen, SearchLen = Text:len(), Search:len()
	if SearchLen > TextLen then return false, 0 end
	local SearchIdx = 1
	local Score = 0
	local RunLength = 0
	local LastMatchIdx = 0
	for TextIdx = 1, TextLen do
		if SearchIdx > SearchLen then break end
		if Text:sub(TextIdx, TextIdx) == Search:sub(SearchIdx, SearchIdx) then
			RunLength = (LastMatchIdx == TextIdx - 1) and (RunLength + 1) or 1
			Score += 1 + math.min(RunLength - 1, 5) * 3
			LastMatchIdx = TextIdx
			SearchIdx += 1
		end
	end
	if SearchIdx <= SearchLen then return false, 0 end
	return true, Score
end
local function NormalizeSearch(Search) return (Search:gsub("%s+", "")) end
local function TryFuzzyMatch(Text, Search)
	if typeof(Text) ~= "string" or Text == "" then return false end
	return (FuzzyScore(Text:lower(), Search))
end
function Library:AddToRegistry(Instance, Properties)
	Library.Registry[Instance] = Properties
end
function Library:RemoveFromRegistry(Instance)
	Library.Registry[Instance] = nil
end
function Library:UpdateColorsUsingRegistry()
	for Instance, Properties in Library.Registry do
		for Property, Index in Properties do
			local SchemeValue = GetSchemeValue(Index)
			if SchemeValue or typeof(Index) == "function" then
				Instance[Property] = SchemeValue or Index()
			end
		end
	end
end
function Library:GiveSignal(Connection)
	local ConnType = typeof(Connection)
	if Connection and (ConnType == "RBXScriptConnection" or ConnType == "RBXScriptSignal") then
		table.insert(Library.Signals, Connection)
	end
	return Connection
end
function Library:SafeCallback(Func, ...)
	if not (Func and typeof(Func) == "function") then return end
	local Result = table.pack(xpcall(Func, function(Error)
		task.defer(error, debug.traceback(Error, 2))
		if Library.NotifyOnError and Library.Notify then Library:Notify(tostring(Error)) end
		return Error
	end, ...))
	if not Result[1] then return nil end
	return table.unpack(Result, 2, Result.n)
end
function Library:Validate(Table, Template)
	if typeof(Table) ~= "table" then return Template end
	for k, v in Template do
		if typeof(k) == "number" then continue end
		if typeof(v) == "table" then
			Table[k] = Library:Validate(Table[k], v)
		elseif Table[k] == nil then
			Table[k] = v
		end
	end
	return Table
end
local function FillInstance(Table, Instance)
	local ThemeProps = Library.Registry[Instance] or {}
	for key, value in Table do
		if key ~= "Text" then
			local SchemeValue = GetSchemeValue(value)
			if SchemeValue or typeof(value) == "function" then
				ThemeProps[key] = value
				value = SchemeValue or value()
			else
				ThemeProps[key] = nil
			end
		end
		Instance[key] = value
	end
	if GetTableSize(ThemeProps) > 0 then
		Library.Registry[Instance] = ThemeProps
	end
end
local function New(ClassName, Properties)
	local Instance = Instance.new(ClassName)
	if Templates[ClassName] then FillInstance(Templates[ClassName], Instance) end
	FillInstance(Properties, Instance)
	if Properties["Parent"] and not Properties["ZIndex"] then
		pcall(function() Instance.ZIndex = Properties.Parent.ZIndex end)
	end
	return Instance
end
Library.New = New
local function SafeParentUI(Instance, Parent)
	local success = pcall(function()
		if not Parent then Parent = CoreGui end
		local Dest
		if typeof(Parent) == "function" then Dest = Parent() else Dest = Parent end
		Instance.Parent = Dest
	end)
	if not (success and Instance.Parent) then
		pcall(function() Instance.Parent = LocalPlayer:WaitForChild("PlayerGui", 10) end)
	end
end
function Library:ParentUI(UI)
	if Library.HideMode == "player" then SafeParentUI(UI, LocalPlayer:WaitForChild("PlayerGui")) return end
	if Library.HideMode == "core" then SafeParentUI(UI, CoreGui) return end
	pcall(protectgui, UI)
	local success = pcall(function()
		if gethui then UI.Parent = gethui() else UI.Parent = CoreGui end
	end)
	if not success or not UI.Parent then SafeParentUI(UI, CoreGui) end
	if not UI.Parent then SafeParentUI(UI, LocalPlayer:WaitForChild("PlayerGui")) end
end
local function IsValidCustomIcon(Icon)
	return typeof(Icon) == "string" and (Icon:match("^rbxasset://textures/") or Icon:match("roblox%.com/asset/%?id=") or Icon:match("rbxthumb://type="))
end
local function IsCustomAssetIcon(Icon, IncludeAssetId)
	return typeof(Icon) == "string" and (Icon:match("^content://") or Icon:match("^rbxasset://%x+/") or Icon:match("^rbxasset://[^/]+/") or (IncludeAssetId == true and Icon:match("^rbxassetid://")))
end
local FetchIcons = false
local Icons = nil
function Library:GetIcon(IconName)
	if not FetchIcons or not Icons then return nil end
	local Success, Icon = pcall(Icons.GetAsset, IconName)
	if not Success then return nil end
	return Icon
end
function Library:GetCustomIcon(IconName)
	if not IconName then return nil end
	if tonumber(IconName) then IconName = string.format("rbxassetid://%s", tostring(IconName)) end
	if IsCustomAssetIcon(IconName, true) then
		return { Url = IconName, ImageRectOffset = Vector2.zero, ImageRectSize = Vector2.zero }
	elseif IsValidCustomIcon(IconName) then
		return { Url = IconName, ImageRectOffset = Vector2.zero, ImageRectSize = Vector2.zero, Custom = true }
	end
	local Lucide = Library:GetIcon(IconName)
	if Lucide then return Lucide end
	return nil
end
function Library:ApplyLucideIcon(ImageGui, Icon, Rotation)
	if not ImageGui or not Icon then return end
	if not (ImageGui:IsA("ImageLabel") or ImageGui:IsA("ImageButton")) then return end
	ImageGui.Image = Icon.Url or ImageGui.Image
	ImageGui.ImageRectOffset = Icon.ImageRectOffset or ImageGui.ImageRectOffset
	ImageGui.ImageRectSize = Icon.ImageRectSize or ImageGui.ImageRectSize
	ImageGui.Rotation = Rotation or ImageGui.Rotation
end
function Library:AddGlassEffect(Frame, Options)
	Options = Options or {}
	local Radius = Options.CornerRadius or Library.CornerRadius
	local Transparency = Options.Transparency or 0.15
	local StrokeColor = Options.StrokeColor or Library.Scheme.OutlineColor
	local StrokeTransparency = Options.StrokeTransparency or 0.5
	local GradientTop = Options.GradientTop or Library:GetLighterColor(Library.Scheme.Glass)
	local GradientBottom = Options.GradientBottom or Library.Scheme.Glass
	local Corner = New("UICorner", { Parent = Frame })
	Corner.CornerRadius = UDim.new(0, Radius)
	local Stroke = New("UIStroke", { Parent = Frame, Color = StrokeColor, Thickness = 1, Transparency = StrokeTransparency })
	local Grad = New("UIGradient", {
		Parent = Frame,
		Color = ColorSequence.new(GradientTop, GradientBottom),
		Rotation = 135,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.02),
			NumberSequenceKeypoint.new(1, Transparency),
		}),
	})
	return Corner, Stroke, Grad
end
function Library:AddMultiLayerShadow(Frame, Options)
	Options = Options or {}
	local BaseColor = Options.Color or Library.Scheme.DarkColor
	local Layers = Options.Layers or {
		{ Offset = 8, Transparency = 0.85, Expand = 24 },
		{ Offset = 4, Transparency = 0.72, Expand = 12 },
		{ Offset = 2, Transparency = 0.55, Expand = 6 },
	}
	local Radius = Options.CornerRadius or Library.CornerRadius
	local Shadows = {}
	for _, Layer in ipairs(Layers) do
		local Shadow = New("Frame", {
			Name = "Shadow",
			BackgroundColor3 = BaseColor,
			BackgroundTransparency = Layer.Transparency,
			BorderSizePixel = 0,
			Position = UDim2.new(0, -Layer.Offset, 0, -Layer.Offset + (Layer.Offset * 2)),
			Size = UDim2.new(1, Layer.Expand * 2, 1, Layer.Expand * 2),
			ZIndex = Frame.ZIndex - 1,
			Parent = Frame.Parent,
		})
		New("UICorner", { Parent = Shadow, CornerRadius = UDim.new(0, Radius + Layer.Expand / 2) })
		table.insert(Shadows, Shadow)
	end
	return Shadows
end
function Library:AddGlowStroke(Frame, Color)
	local Glow = New("UIStroke", {
		Parent = Frame,
		Color = Color or Library.Scheme.AccentGlow,
		Thickness = 1.2,
		Transparency = 0.82,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
	return Glow
end
function Library:GetBetterColor(Color, Add)
	Add = Add * (Library.IsLightTheme and -4 or 2)
	return Color3.fromRGB(
		math.clamp(Color.R * 255 + Add, 0, 255),
		math.clamp(Color.G * 255 + Add, 0, 255),
		math.clamp(Color.B * 255 + Add, 0, 255)
	)
end
function Library:GetLighterColor(Color, Amount)
	Amount = Amount or 0.1
	local H, S, V = Color:ToHSV()
	return Color3.fromHSV(H, math.max(0, S - Amount), math.min(1, V + Amount))
end
function Library:GetDarkerColor(Color, Amount)
	Amount = Amount or 0.5
	local H, S, V = Color:ToHSV()
	return Color3.fromHSV(H, S, V * Amount)
end
function Library:GetKeyString(KeyCode)
	if KeyCode.EnumType == Enum.KeyCode and KeyCode.Value > 33 and KeyCode.Value < 127 then
		return string.char(KeyCode.Value)
	end
	return KeyCode.Name
end
function Library:GetTextBounds(Text, Font, Size, Width)
	local Params = Instance.new("GetTextBoundsParams")
	Params.Text = Text
	Params.RichText = true
	Params.Font = Font
	Params.Size = Size
	Params.Width = Width or workspace.CurrentCamera.ViewportSize.X - 32
	local Bounds = TextService:GetTextBoundsAsync(Params)
	return Bounds.X, Bounds.Y
end
function Library:MouseIsOverFrame(Frame, MousePos)
	local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize
	return MousePos.X >= AbsPos.X and MousePos.X <= AbsPos.X + AbsSize.X and MousePos.Y >= AbsPos.Y and MousePos.Y <= AbsPos.Y + AbsSize.Y
end
function Library:IsInsideFrame(ParentFrame, Frame)
	local GuiPos, GuiSize = Frame.AbsolutePosition, Frame.AbsoluteSize
	local FramePos, FrameSize = ParentFrame.AbsolutePosition, ParentFrame.AbsoluteSize
	return GuiPos.X >= FramePos.X and GuiPos.X + GuiSize.X <= FramePos.X + FrameSize.X and GuiPos.Y >= FramePos.Y and GuiPos.Y + GuiSize.Y <= FramePos.Y + FrameSize.Y
end
function Library:GetSafeArea()
	local TopLeft, BottomRight = Vector2.zero, Vector2.zero
	pcall(function() TopLeft, BottomRight = GuiService:GetGuiInset() end)
	return TopLeft, BottomRight
end
function Library:CreateRipple(Parent, X, Y, Color)
	Color = Color or Library.Scheme.WhiteColor
	local Ripple = New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color,
		BackgroundTransparency = 0.6,
		BorderSizePixel = 0,
		Position = UDim2.new(0, X, 0, Y),
		Size = UDim2.fromOffset(0, 0),
		ZIndex = (Parent.ZIndex or 1) + 10,
		Parent = Parent,
	})
	New("UICorner", { Parent = Ripple, CornerRadius = UDim.new(1, 0) })
	local MaxSize = math.max(Parent.AbsoluteSize.X, Parent.AbsoluteSize.Y) * 2
	local Tween = TweenService:Create(Ripple, Library.RippleInfo, {
		Size = UDim2.fromOffset(MaxSize, MaxSize),
		BackgroundTransparency = 1,
	})
	Tween:Play()
	Tween.Completed:Connect(function() Ripple:Destroy() end)
end
function Library:Pulse(Instance, ScaleMin, ScaleMax)
	ScaleMin = ScaleMin or 0.92
	ScaleMax = ScaleMax or 1
	local UIScale = Instance:FindFirstChildOfClass("UIScale")
	if not UIScale then UIScale = New("UIScale", { Parent = Instance, Scale = 1 }) end
	local InTween = TweenService:Create(UIScale, Library.PulseInInfo, { Scale = ScaleMin })
	local OutTween = TweenService:Create(UIScale, Library.PulseOutInfo, { Scale = ScaleMax })
	InTween:Play()
	InTween.Completed:Connect(function() OutTween:Play() end)
	return UIScale
end
local ScreenGui = New("ScreenGui", {
	Name = "UI_" .. tostring(math.random(100000000, 999999999)),
	DisplayOrder = 998,
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})
Library:ParentUI(ScreenGui)
Library.ScreenGui = ScreenGui
Library:GiveSignal(ScreenGui.DescendantRemoving:Connect(function(Instance)
	task.defer(function()
		if Instance.Parent and Instance:IsDescendantOf(ScreenGui) then return end
		Library:RemoveFromRegistry(Instance)
	end)
end))
local ModalElement = New("TextButton", {
	BackgroundTransparency = 1,
	Modal = false,
	Size = UDim2.fromScale(0, 0),
	AnchorPoint = Vector2.zero,
	Text = "",
	ZIndex = -999,
	Parent = ScreenGui,
})
Library.ModalElement = ModalElement
local SafeAreaFrame = New("Frame", {
	Name = "SafeArea",
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
	ZIndex = 0,
	Parent = ScreenGui,
})
do
	local TopLeft, BottomRight = Library:GetSafeArea()
	New("UIPadding", {
		Parent = SafeAreaFrame,
		PaddingTop = UDim.new(0, TopLeft.Y),
		PaddingBottom = UDim.new(0, BottomRight.Y),
		PaddingLeft = UDim.new(0, TopLeft.X),
		PaddingRight = UDim.new(0, BottomRight.X),
	})
end
Library.SafeAreaFrame = SafeAreaFrame
local Floats = New("Frame", {
	Name = "Floats",
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
	ZIndex = 10,
	Active = false,
	Parent = ScreenGui,
})
local Overlay = New("Frame", {
	Name = "Overlay",
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
	ZIndex = 20,
	Active = false,
	Parent = ScreenGui,
})
Library.Floats = Floats
Library.Overlay = Overlay
local NotificationArea = New("Frame", {
	Name = "NotificationArea",
	AnchorPoint = Vector2.new(1, 0),
	BackgroundTransparency = 1,
	Position = UDim2.new(1, -12, 0, 12),
	Size = UDim2.new(0, 320, 1, -24),
	ZIndex = 200,
	Parent = SafeAreaFrame,
})
New("UIListLayout", {
	Parent = NotificationArea,
	Padding = UDim.new(0, 10),
	SortOrder = Enum.SortOrder.LayoutOrder,
	VerticalAlignment = Enum.VerticalAlignment.Top,
})
table.insert(Library.Scales, New("UIScale", { Parent = NotificationArea }))
Library.NotificationArea = NotificationArea
local CheckIcon, ArrowIcon, ResizeIcon, KeyIcon, MoveIcon, PopOutIcon, CloseIcon, MinimizeIcon
function Library:SetIconModule(module)
	FetchIcons = true
	Icons = module
	CheckIcon = Library:GetIcon("check")
	ArrowIcon = Library:GetIcon("chevron-up")
	ResizeIcon = Library:GetIcon("move-diagonal-2")
	KeyIcon = Library:GetIcon("key")
	MoveIcon = Library:GetIcon("move")
	PopOutIcon = Library:GetIcon("square-arrow-down-left")
	CloseIcon = Library:GetIcon("x")
	MinimizeIcon = Library:GetIcon("minus")
end
do
	local Success, IconModule = pcall(function()
		local source = game:HttpGet("https://raw.githubusercontent.com/mstudio45/lucide-roblox-direct/refs/heads/main/source.lua")
		local fn = loadstring and loadstring(source) or load(source)
		return fn()
	end)
	if Success and IconModule then Library:SetIconModule(IconModule) end
end
Library.Icons = {
	Check = CheckIcon,
	Arrow = ArrowIcon,
	Resize = ResizeIcon,
	Key = KeyIcon,
	Move = MoveIcon,
	PopOut = PopOutIcon,
	Close = CloseIcon,
	Minimize = MinimizeIcon,
}
Library:GiveSignal(UserInputService.WindowFocused:Connect(function() Library.IsRobloxFocused = true end))
Library:GiveSignal(UserInputService.WindowFocusReleased:Connect(function() Library.IsRobloxFocused = false end))
local Notification = {}
Notification.__index = Notification
function Notification.new(Options)
	local self = setmetatable({}, Notification)
	Options = Options or {}
	self.Title = Options.Title or "Thông báo"
	self.Text = Options.Text or ""
	self.Duration = Options.Duration or 4
	self.Kind = Options.Kind or "info"
	self.Icon = Options.Icon or "bell"
	self.Killed = false
	local KindColors = {
		info = Library.Scheme.AccentColor,
		success = Library.Scheme.SuccessColor,
		warning = Library.Scheme.WarningColor,
		error = Library.Scheme.DestructiveColor,
	}
	local AccentColor = KindColors[self.Kind] or Library.Scheme.AccentColor
	local Holder = New("Frame", {
		Name = "Notification",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 72),
		Parent = Library.NotificationArea,
	})
	self.Holder = Holder
	local Shadow = New("Frame", {
		BackgroundColor3 = Library.Scheme.DarkColor,
		BackgroundTransparency = 0.7,
		BorderSizePixel = 0,
		Position = UDim2.new(0, -3, 0, -3),
		Size = UDim2.new(1, 6, 1, 6),
		ZIndex = Holder.ZIndex - 1,
		Parent = Holder,
	})
	New("UICorner", { Parent = Shadow, CornerRadius = UDim.new(0, 22) })
	local Main = New("Frame", {
		Name = "Main",
		BackgroundColor3 = Library.Scheme.MainColor,
		BackgroundTransparency = 0.1,
		Size = UDim2.fromScale(1, 1),
		ClipsDescendants = true,
		Parent = Holder,
	})
	self.Main = Main
	New("UICorner", { Parent = Main, CornerRadius = UDim.new(0, 20) })
	New("UIStroke", {
		Parent = Main,
		Color = Library.Scheme.OutlineColor,
		Thickness = 1,
		Transparency = 0.55,
	})
	New("UIGradient", {
		Parent = Main,
		Color = ColorSequence.new(Library:GetLighterColor(Library.Scheme.Glass, 0.06), Library.Scheme.Glass),
		Rotation = 135,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.02),
			NumberSequenceKeypoint.new(1, 0.2),
		}),
	})
	local AccentBar = New("Frame", {
		BackgroundColor3 = AccentColor,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 4, 1, -24),
		Position = UDim2.new(0, 10, 0.5, -24 + 12),
		Parent = Main,
	})
	New("UICorner", { Parent = AccentBar, CornerRadius = UDim.new(1, 0) })
	local IconImg = New("ImageLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(24, 24),
		Position = UDim2.new(0, 24, 0, 12),
		ImageColor3 = AccentColor,
		Parent = Main,
	})
	local IconData = Library:GetCustomIcon(self.Icon)
	if IconData then Library:ApplyLucideIcon(IconImg, IconData) end
	New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -100, 0, 20),
		Position = UDim2.new(0, 58, 0, 12),
		Text = self.Title,
		Font = Library.Scheme.Font,
		TextSize = 14,
		TextColor3 = Library.Scheme.FontColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = Main,
	})
	New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -100, 0, 32),
		Position = UDim2.new(0, 58, 0, 32),
		Text = self.Text,
		Font = Library.Scheme.Font,
		TextSize = 12,
		TextColor3 = Library.Scheme.OutlineColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		Parent = Main,
	})
	local CloseBtn = New("TextButton", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(24, 24),
		Position = UDim2.new(1, -32, 0, 12),
		Text = "",
		Parent = Main,
	})
	local CloseIconImg = New("ImageLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(14, 14),
		Position = UDim2.new(0.5, -7, 0.5, -7),
		ImageColor3 = Library.Scheme.OutlineColor,
		Parent = CloseBtn,
	})
	if Library.Icons.Close then Library:ApplyLucideIcon(CloseIconImg, Library.Icons.Close) end
	Holder.Position = UDim2.new(1, 400, 0, 0)
	local TweenIn = TweenService:Create(Holder, Library.NotifyTweenInfo, { Position = UDim2.new(0, 0, 0, 0) })
	TweenIn:Play()
	Library:GiveSignal(CloseBtn.MouseEnter:Connect(function()
		TweenService:Create(CloseIconImg, Library.HoverInfo, { ImageColor3 = Library.Scheme.FontColor }):Play()
	end))
	Library:GiveSignal(CloseBtn.MouseLeave:Connect(function()
		TweenService:Create(CloseIconImg, Library.HoverInfo, { ImageColor3 = Library.Scheme.OutlineColor }):Play()
	end))
	Library:GiveSignal(CloseBtn.MouseButton1Click:Connect(function() self:Kill() end))
	local SwipeStart, SwipeStartPos, Swiping
	Library:GiveSignal(Main.InputBegan:Connect(function(Input)
		if IsClickInput(Input) then
			SwipeStart = Input.Position
			SwipeStartPos = Holder.Position
			Swiping = true
		end
	end))
	Library:GiveSignal(UserInputService.InputChanged:Connect(function(Input)
		if Swiping and IsHoverInput(Input) then
			local Delta = Input.Position - SwipeStart
			if Delta.X > 0 then
				Holder.Position = UDim2.new(SwipeStartPos.X.Scale, SwipeStartPos.X.Offset + Delta.X, SwipeStartPos.Y.Scale, SwipeStartPos.Y.Offset)
			end
		end
	end))
	Library:GiveSignal(UserInputService.InputEnded:Connect(function(Input)
		if Swiping and IsMouseInput(Input) then
			Swiping = false
			local Delta = Input.Position - SwipeStart
			if Delta.X > 80 then
				self:Kill()
			else
				TweenService:Create(Holder, Library.NotifyTweenInfo, { Position = SwipeStartPos }):Play()
			end
		end
	end))
	task.delay(self.Duration, function()
		if not self.Killed then self:Kill() end
	end)
	table.insert(Library.Notifications, self)
	return self
end
function Notification:Kill()
	if self.Killed then return end
	self.Killed = true
	local TweenOut = TweenService:Create(self.Holder, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
		Position = UDim2.new(1, 400, 0, 0),
	})
	TweenOut:Play()
	TweenOut.Completed:Connect(function()
		self.Holder:Destroy()
		local Idx = table.find(Library.Notifications, self)
		if Idx then table.remove(Library.Notifications, Idx) end
	end)
end
function Notification:Resize()
	if self.Holder then
		self.Holder.Size = UDim2.new(1, 0, 0, 72)
	end
end
function Library:Notify(Options)
	if typeof(Options) == "string" then Options = { Text = Options } end
	return Notification.new(Options or {})
end
Library.Notification = Notification
local Cursor = {}
Cursor.__index = Cursor
function Cursor.new()
	local self = setmetatable({}, Cursor)
	self.Visible = false
	self.Container = New("Frame", {
		Name = "Cursor",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(24, 24),
		Visible = false,
		ZIndex = 11000,
		Parent = Library.ScreenGui,
	})
	self.Dot = New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Library.Scheme.FontColor,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(10, 10),
		ZIndex = 2,
		Parent = self.Container,
	})
	New("UICorner", { Parent = self.Dot, CornerRadius = UDim.new(1, 0) })
	self.Glow = New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Library.Scheme.AccentColor,
		BackgroundTransparency = 0.7,
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(24, 24),
		ZIndex = 1,
		Parent = self.Container,
	})
	New("UICorner", { Parent = self.Glow, CornerRadius = UDim.new(1, 0) })
	self.CustomImage = New("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(20, 20),
		ZIndex = 3,
		Visible = false,
		Parent = self.Container,
	})
	Library:GiveSignal(RunService.RenderStepped:Connect(function()
		if not Library.ShowCustomCursor then
			if self.Visible then
				self.Visible = false
				self.Container.Visible = false
			end
			return
		end
		if not self.Visible then
			self.Visible = true
			self.Container.Visible = true
		end
		local MousePos = UserInputService:GetMouseLocation()
		self.Container.Position = UDim2.fromOffset(MousePos.X, MousePos.Y)
	end))
	return self
end
function Cursor:SetImage(ImageId)
	if not ImageId or ImageId == "" then
		self.CustomImage.Visible = false
		self.Dot.Visible = true
		return
	end
	local Icon = Library:GetCustomIcon(ImageId)
	if not Icon then return end
	self.CustomImage.Visible = true
	self.Dot.Visible = false
	Library:ApplyLucideIcon(self.CustomImage, Icon)
end
function Cursor:SetSize(Size)
	self.CustomImage.Size = Size
end
function Cursor:Destroy()
	self.Container:Destroy()
end
Library.Cursor = Cursor.new()
local Tooltip = {}
Tooltip.__index = Tooltip
function Tooltip.new(Target, Text)
	local self = setmetatable({}, Tooltip)
	self.Target = Target
	self.Text = Text
	self.Frame = nil
	Library:GiveSignal(Target.MouseEnter:Connect(function() self:Show() end))
	Library:GiveSignal(Target.MouseLeave:Connect(function() self:Hide() end))
	return self
end
function Tooltip:Show()
	if self.Frame then return end
	local MousePos = UserInputService:GetMouseLocation()
	self.Frame = New("Frame", {
		Name = "Tooltip",
		BackgroundColor3 = Library.Scheme.MainColor,
		BackgroundTransparency = 0.05,
		Size = UDim2.fromOffset(0, 28),
		AutomaticSize = Enum.AutomaticSize.X,
		Position = UDim2.fromOffset(MousePos.X + 12, MousePos.Y + 16),
		ZIndex = 12000,
		Parent = Library.ScreenGui,
	})
	New("UICorner", { Parent = self.Frame, CornerRadius = UDim.new(0, 8) })
	New("UIStroke", {
		Parent = self.Frame,
		Color = Library.Scheme.OutlineColor,
		Thickness = 1,
		Transparency = 0.4,
	})
	New("UIPadding", {
		Parent = self.Frame,
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
	})
	New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Text = self.Text,
		Font = Library.Scheme.Font,
		TextSize = 12,
		TextColor3 = Library.Scheme.FontColor,
		Parent = self.Frame,
	})
end
function Tooltip:Hide()
	if self.Frame then
		self.Frame:Destroy()
		self.Frame = nil
	end
end
Library.Tooltip = Tooltip
local Window = {}
Window.__index = Window
function Window.new(Options)
	local self = setmetatable({}, Window)
	Options = Options or {}
	self.Options = Options
	self.Title = Options.Title or "LiquidGlass"
	self.Icon = Options.Icon or "sparkles"
	self.Size = Options.Size or UDim2.fromOffset(680, 520)
	self.Position = Options.Position or UDim2.new(0.5, -340, 0.5, -260)
	self.MinSize = Options.MinSize or Vector2.new(480, 360)
	self.Resizable = Options.Resizable ~= false
	self.Snapping = Options.Snapping ~= false
	self.SnapDistance = Options.SnapDistance or 28
	self.SnapMargin = Options.SnapMargin or 12
	self.Dragging = false
	self.Minimized = false
	self.SidebarWidth = Options.SidebarWidth or (Library.IsMobile and 56 or 160)
	self.SidebarCompact = Library.IsMobile
	self.Tabs = {}
	self.ActiveTab = nil
	self.Visible = true
	self.Holder = New("Frame", {
		Name = "WindowHolder",
		BackgroundTransparency = 1,
		Position = self.Position,
		Size = self.Size,
		Visible = true,
		Parent = Library.Floats,
	})
	table.insert(Library.DraggableElements, self.Holder)
	self.ShadowHolder = New("Frame", {
		Name = "ShadowHolder",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 0,
		Parent = self.Holder,
	})
	self.Shadows = Library:AddMultiLayerShadow(self.ShadowHolder, {
		Color = Library.Scheme.DarkColor,
		CornerRadius = Library.CornerRadius,
		Layers = {
			{ Offset = 12, Transparency = 0.88, Expand = 36 },
			{ Offset = 6, Transparency = 0.75, Expand = 20 },
			{ Offset = 3, Transparency = 0.55, Expand = 10 },
			{ Offset = 1, Transparency = 0.35, Expand = 4 },
		},
	})
	for _, Shadow in ipairs(self.Shadows) do
		Shadow.Parent = self.ShadowHolder
	end
	self.MainFrame = New("Frame", {
		Name = "MainFrame",
		BackgroundColor3 = Library.Scheme.MainColor,
		BackgroundTransparency = 0.08,
		Size = UDim2.fromScale(1, 1),
		ClipsDescendants = true,
		ZIndex = 1,
		Parent = self.Holder,
	})
	self.GlassCorner, self.GlassStroke, self.GlassGrad = Library:AddGlassEffect(self.MainFrame, {
		CornerRadius = Library.CornerRadius,
		Transparency = 0.06,
	})
	self.GlowStroke = Library:AddGlowStroke(self.MainFrame)
	self.TopBar = New("Frame", {
		Name = "TopBar",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, Library.IsMobile and 56 or 48),
		ZIndex = 2,
		Parent = self.MainFrame,
	})
	self.TopBarHeight = Library.IsMobile and 56 or 48
	self.IconImg = New("ImageLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(24, 24),
		Position = UDim2.new(0, 16, 0.5, -12),
		ImageColor3 = Library.Scheme.AccentColor,
		ZIndex = 3,
		Parent = self.TopBar,
	})
	local IconData = Library:GetCustomIcon(self.Icon)
	if IconData then Library:ApplyLucideIcon(self.IconImg, IconData) end
	self.TitleLabel = New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -180, 1, 0),
		Position = UDim2.new(0, 48, 0, 0),
		Text = self.Title,
		Font = Library.Scheme.Font,
		TextSize = 15,
		TextColor3 = Library.Scheme.FontColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 3,
		Parent = self.TopBar,
	})
	New("Frame", {
		BackgroundColor3 = Library.Scheme.OutlineColor,
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -24, 0, 1),
		Position = UDim2.new(0, 12, 1, -1),
		ZIndex = 3,
		Parent = self.TopBar,
	})
	self.BtnHolder = New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(80, 32),
		Position = UDim2.new(1, -88, 0.5, -16),
		ZIndex = 3,
		Parent = self.TopBar,
	})
	local function TopBtn(IconData, Color, XPos, Callback)
		local Btn = New("TextButton", {
			BackgroundColor3 = Color,
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(32, 32),
			Position = UDim2.fromOffset(XPos, 0),
			Text = "",
			ZIndex = 4,
			Parent = self.BtnHolder,
		})
		New("UICorner", { Parent = Btn, CornerRadius = UDim.new(1, 0) })
		local Img = New("ImageLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(16, 16),
			Position = UDim2.new(0.5, -8, 0.5, -8),
			ImageColor3 = Library.Scheme.OutlineColor,
			ZIndex = 5,
			Parent = Btn,
		})
		if IconData then Library:ApplyLucideIcon(Img, IconData) end
		Library:GiveSignal(Btn.MouseEnter:Connect(function()
			TweenService:Create(Btn, Library.HoverInfo, { BackgroundTransparency = 0.85, BackgroundColor3 = Color }):Play()
			TweenService:Create(Img, Library.HoverInfo, { ImageColor3 = Color }):Play()
		end))
		Library:GiveSignal(Btn.MouseLeave:Connect(function()
			TweenService:Create(Btn, Library.HoverInfo, { BackgroundTransparency = 1 }):Play()
			TweenService:Create(Img, Library.HoverInfo, { ImageColor3 = Library.Scheme.OutlineColor }):Play()
		end))
		Library:GiveSignal(Btn.MouseButton1Click:Connect(function()
			Library:Pulse(Btn, 0.85, 1)
			if Library.IsMobile then
				local MousePos = UserInputService:GetMouseLocation()
				local AbsPos = Btn.AbsolutePosition
				Library:CreateRipple(Btn, MousePos.X - AbsPos.X, MousePos.Y - AbsPos.Y, Color)
			end
			Library:SafeCallback(Callback)
		end))
		return Btn
	end
	TopBtn(Library.Icons.Minimize, Library.Scheme.WarningColor, 0, function() self:Minimize() end)
	TopBtn(Library.Icons.Close, Library.Scheme.DestructiveColor, 40, function() self:Close() end)
	self.Sidebar = New("Frame", {
		Name = "Sidebar",
		BackgroundColor3 = Library.Scheme.BackgroundColor,
		BackgroundTransparency = 0.5,
		Size = UDim2.new(0, self.SidebarWidth, 1, -self.TopBarHeight),
		Position = UDim2.new(0, 0, 0, self.TopBarHeight),
		ZIndex = 2,
		Parent = self.MainFrame,
	})
	New("UICorner", { Parent = self.Sidebar, CornerRadius = UDim.new(0, 0) })
	New("UIListLayout", {
		Parent = self.Sidebar,
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
	})
	New("UIPadding", {
		Parent = self.Sidebar,
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 6),
		PaddingRight = UDim.new(0, 6),
	})
	New("Frame", {
		BackgroundColor3 = Library.Scheme.OutlineColor,
		BackgroundTransparency = 0.6,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 1, 1, -20),
		Position = UDim2.new(1, 0, 0, 10),
		ZIndex = 3,
		Parent = self.Sidebar,
	})
	self.Content = New("Frame", {
		Name = "Content",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -self.SidebarWidth, 1, -self.TopBarHeight),
		Position = UDim2.new(0, self.SidebarWidth, 0, self.TopBarHeight),
		ClipsDescendants = true,
		ZIndex = 2,
		Parent = self.MainFrame,
	})
	self:MakeDraggable()
	if self.Resizable then
		self:MakeResizable()
	end
	self:PlayOpenAnimation()
	Library.Window = self
	Library.WindowContainer = self.Holder
	Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input, GPE)
		if GPE then return end
		if Input.KeyCode == Library.ToggleKeybind then
			self:Toggle()
		end
	end))
	return self
end
function Window:MakeDraggable()
	local DragStart, StartPos
	local Dragging = false
	local ActiveInput
	local SnapGuides = {}
	Library:GiveSignal(self.TopBar.InputBegan:Connect(function(Input)
		if not IsClickInput(Input) then return end
		DragStart = Input.Position
		StartPos = self.Holder.Position
		Dragging = true
		ActiveInput = Input
		Input.Changed:Connect(function()
			if Input.UserInputState == Enum.UserInputState.End then
				Dragging = false
				ActiveInput = nil
			end
		end)
	end))
	Library:GiveSignal(UserInputService.InputChanged:Connect(function(Input)
		if not Dragging or not ActiveInput then return end
		if not IsHoverInput(Input) then return end
		local Delta = Input.Position - DragStart
		local NewX = StartPos.X.Offset + Delta.X
		local NewY = StartPos.Y.Offset + Delta.Y
		if self.Snapping then
			local ViewportSize = workspace.CurrentCamera.ViewportSize
			local TopLeft, BottomRight = Library:GetSafeArea()
			local Margin = self.SnapMargin
			local Distance = self.SnapDistance
			local ElemSize = self.Holder.AbsoluteSize
			local SafeMinX = TopLeft.X + Margin
			local SafeMinY = TopLeft.Y + Margin
			local SafeMaxX = ViewportSize.X - BottomRight.X - Margin
			local SafeMaxY = ViewportSize.Y - BottomRight.Y - Margin
			local TargetsX = {
				Left = SafeMinX,
				Center = SafeMinX + (SafeMaxX - SafeMinX - ElemSize.X) / 2,
				Right = SafeMaxX - ElemSize.X,
			}
			local TargetsY = {
				Top = SafeMinY,
				Center = SafeMinY + (SafeMaxY - SafeMinY - ElemSize.Y) / 2,
				Bottom = SafeMaxY - ElemSize.Y,
			}
			local AbsX = StartPos.X.Scale * ViewportSize.X + NewX
			local AbsY = StartPos.Y.Scale * ViewportSize.Y + NewY
			for Name, Target in TargetsX do
				if math.abs(AbsX - Target) <= Distance then
					NewX = Target - StartPos.X.Scale * ViewportSize.X
					break
				end
			end
			for Name, Target in TargetsY do
				if math.abs(AbsY - Target) <= Distance then
					NewY = Target - StartPos.Y.Scale * ViewportSize.Y
					break
				end
			end
		end
		self.Holder.Position = UDim2.new(StartPos.X.Scale, NewX, StartPos.Y.Scale, NewY)
	end))
end
function Window:MakeResizable()
	local ResizeHandle = New("TextButton", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(28, 28),
		Position = UDim2.new(1, -28, 1, -28),
		Text = "",
		ZIndex = 5,
		Parent = self.MainFrame,
	})
	local ResizeIcon = New("ImageLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(14, 14),
		Position = UDim2.new(0.5, -7, 0.5, -7),
		ImageColor3 = Library.Scheme.OutlineColor,
		ZIndex = 6,
		Parent = ResizeHandle,
	})
	if Library.Icons.Resize then Library:ApplyLucideIcon(ResizeIcon, Library.Icons.Resize) end
	local StartSize, StartPos, Dragging
	Library:GiveSignal(ResizeHandle.InputBegan:Connect(function(Input)
		if not IsClickInput(Input) then return end
		StartPos = Input.Position
		StartSize = self.Holder.Size
		Dragging = true
	end))
	Library:GiveSignal(UserInputService.InputChanged:Connect(function(Input)
		if not Dragging or not IsHoverInput(Input) then return end
		local Delta = Input.Position - StartPos
		local NewW = math.max(self.MinSize.X, StartSize.X.Offset + Delta.X)
		local NewH = math.max(self.MinSize.Y, StartSize.Y.Offset + Delta.Y)
		self.Holder.Size = UDim2.new(StartSize.X.Scale, NewW, StartSize.Y.Scale, NewH)
	end))
	Library:GiveSignal(UserInputService.InputEnded:Connect(function(Input)
		if IsMouseInput(Input) then
			Dragging = false
		end
	end))
end
function Window:PlayOpenAnimation()
	local TargetSize = self.Size
	self.Holder.Size = UDim2.new(TargetSize.X.Scale, TargetSize.X.Offset, TargetSize.Y.Scale, 0)
	self.MainFrame.BackgroundTransparency = 1
	local UIScale = New("UIScale", { Parent = self.Holder, Scale = 0.85 })
	local SizeTween = TweenService:Create(self.Holder, Library.WindowAnimationInfo, { Size = TargetSize })
	local BgTween = TweenService:Create(self.MainFrame, Library.WindowAnimationInfo, { BackgroundTransparency = 0.08 })
	local ScaleTween = TweenService:Create(UIScale, Library.WindowAnimationInfo, { Scale = 1 })
	SizeTween:Play()
	BgTween:Play()
	ScaleTween:Play()
end
function Window:Toggle(Force)
	local Target = Force
	if Target == nil then Target = not self.Visible end
	self.Visible = Target
	Library.Toggled = Target
	if Target then
		self.Holder.Visible = true
		self.Holder.Size = UDim2.new(self.Size.X.Scale, self.Size.X.Offset, self.Size.Y.Scale, 0)
		local UIScale = self.Holder:FindFirstChildOfClass("UIScale") or New("UIScale", { Parent = self.Holder, Scale = 0.85 })
		UIScale.Scale = 0.85
		TweenService:Create(self.Holder, Library.WindowAnimationInfo, { Size = self.Size }):Play()
		TweenService:Create(UIScale, Library.WindowAnimationInfo, { Scale = 1 }):Play()
	else
		local UIScale = self.Holder:FindFirstChildOfClass("UIScale")
		if UIScale then
			TweenService:Create(UIScale, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { Scale = 0.85 }):Play()
		end
		local Tween = TweenService:Create(self.Holder, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
			Size = UDim2.new(self.Size.X.Scale, self.Size.X.Offset, self.Size.Y.Scale, 0),
		})
		Tween:Play()
		Tween.Completed:Connect(function()
			if not self.Visible then
				self.Holder.Visible = false
			end
		end)
	end
	return Target
end
function Window:Minimize()
	self.Minimized = not self.Minimized
	if self.Minimized then
		self.LastSize = self.Holder.Size
		TweenService:Create(self.Holder, Library.SpringInfo, {
			Size = UDim2.new(self.Size.X.Scale, self.Size.X.Offset, self.Size.Y.Scale, self.TopBarHeight),
		}):Play()
	else
		TweenService:Create(self.Holder, Library.SpringInfo, { Size = self.LastSize or self.Size }):Play()
	end
end
function Window:Close()
	self.Visible = false
	local UIScale = self.Holder:FindFirstChildOfClass("UIScale")
	if UIScale then
		TweenService:Create(UIScale, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { Scale = 0.85 }):Play()
	end
	local Tween = TweenService:Create(self.Holder, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
		Size = UDim2.new(self.Size.X.Scale, self.Size.X.Offset, self.Size.Y.Scale, 0),
	})
	Tween:Play()
	Tween.Completed:Connect(function()
		self.Holder.Visible = false
	end)
end
function Window:Destroy()
	self.Holder:Destroy()
	local Idx = table.find(Library.DraggableElements, self.Holder)
	if Idx then table.remove(Library.DraggableElements, Idx) end
	if Library.Window == self then
		Library.Window = nil
		Library.WindowContainer = nil
	end
end
function Library:CreateWindow(Options)
	return Window.new(Options)
end
Library.Window = Window
local Tab = {}
Tab.__index = Tab
function Window:CreateTab(Options)
	Options = Options or {}
	local self_ = setmetatable({}, Tab)
	self_.Window = self
	self_.Name = Options.Name or "Tab"
	self_.Description = Options.Description or ""
	self_.IconName = Options.Icon or "circle"
	self_.Icon = Library:GetCustomIcon(self_.IconName)
	self_.Groupboxes = {}
	self_.Tabboxes = {}
	self_.Elements = {}
	self_.Active = false
	self_.ButtonHeight = Library.IsMobile and 44 or 40
	local Button = New("TextButton", {
		Name = "TabButton_" .. self_.Name,
		BackgroundColor3 = Library.Scheme.SurfaceAlt,
		BackgroundTransparency = 0.55,
		Size = UDim2.new(1, 0, 0, self_.ButtonHeight),
		Text = "",
		ZIndex = 4,
		Parent = self.Sidebar,
	})
	self_.Button = Button
	New("UICorner", { Parent = Button, CornerRadius = UDim.new(0, 12) })
	local ButtonStroke = New("UIStroke", {
		Parent = Button,
		Color = Library.Scheme.OutlineColor,
		Thickness = 1,
		Transparency = 0.65,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
	self_.ButtonStroke = ButtonStroke
	local ButtonIcon = New("ImageLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(20, 20),
		Position = UDim2.new(0, Library.IsMobile and 0 or 14, 0.5, -10),
		AnchorPoint = Library.IsMobile and Vector2.new(0.5, 0.5) or Vector2.new(0, 0.5),
		ImageColor3 = Library.Scheme.OutlineColor,
		ZIndex = 5,
		Parent = Button,
	})
	if Library.IsMobile then
		ButtonIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
	end
	self_.ButtonIcon = ButtonIcon
	if self_.Icon then Library:ApplyLucideIcon(ButtonIcon, self_.Icon) end
	local ButtonLabel = New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -50, 1, 0),
		Position = UDim2.new(0, 42, 0, 0),
		Text = self_.Name,
		Font = Library.Scheme.Font,
		TextSize = 13,
		TextColor3 = Library.Scheme.OutlineColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		Visible = not Library.IsMobile,
		ZIndex = 5,
		Parent = Button,
	})
	self_.ButtonLabel = ButtonLabel
	local Page = New("ScrollingFrame", {
		Name = "Page_" .. self_.Name,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -20, 1, -20),
		Position = UDim2.new(0, 10, 0, 10),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Library.Scheme.AccentColor,
		ScrollBarImageTransparency = 0.55,
		Visible = false,
		ZIndex = 3,
		Parent = self.Content,
	})
	self_.Page = Page
	New("UIListLayout", {
		Parent = Page,
		Padding = UDim.new(0, 10),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	New("UIPadding", {
		Parent = Page,
		PaddingTop = UDim.new(0, 4),
		PaddingBottom = UDim.new(0, 12),
		PaddingLeft = UDim.new(0, 4),
		PaddingRight = UDim.new(0, 4),
	})
	Library:GiveSignal(Button.MouseEnter:Connect(function()
		if not self_.Active then
			TweenService:Create(Button, Library.HoverInfo, { BackgroundTransparency = 0.15 }):Play()
			TweenService:Create(ButtonIcon, Library.HoverInfo, { ImageColor3 = Library.Scheme.AccentColor }):Play()
			if not Library.IsMobile then
				TweenService:Create(ButtonLabel, Library.HoverInfo, { TextColor3 = Library.Scheme.FontColor }):Play()
			end
		end
	end))
	Library:GiveSignal(Button.MouseLeave:Connect(function()
		if not self_.Active then
			TweenService:Create(Button, Library.HoverInfo, { BackgroundTransparency = 0.55 }):Play()
			TweenService:Create(ButtonIcon, Library.HoverInfo, { ImageColor3 = Library.Scheme.OutlineColor }):Play()
			if not Library.IsMobile then
				TweenService:Create(ButtonLabel, Library.HoverInfo, { TextColor3 = Library.Scheme.OutlineColor }):Play()
			end
		end
	end))
	Library:GiveSignal(Button.MouseButton1Click:Connect(function()
		Library:Pulse(Button, 0.9, 1)
		if Library.IsMobile then
			local MousePos = UserInputService:GetMouseLocation()
			local AbsPos = Button.AbsolutePosition
			Library:CreateRipple(Button, MousePos.X - AbsPos.X, MousePos.Y - AbsPos.Y, Library.Scheme.WhiteColor)
		end
		self:SelectTab(self_)
	end))
	table.insert(self.Tabs, self_)
	table.insert(Library.Tabs, self_)
	table.insert(Library.TabButtons, Button)
	if not self.ActiveTab then
		self:SelectTab(self_)
	end
	return self_
end
function Window:SelectTab(Tab_)
	if self.ActiveTab == Tab_ then return end
	for _, T in ipairs(self.Tabs) do
		if T == Tab_ then
			T.Active = true
			T.Page.Visible = true
			TweenService:Create(T.Button, Library.SpringInfo, {
				BackgroundColor3 = Library.Scheme.AccentColor,
				BackgroundTransparency = 0.15,
			}):Play()
			TweenService:Create(T.ButtonIcon, Library.SpringInfo, { ImageColor3 = Library.Scheme.WhiteColor }):Play()
			TweenService:Create(T.ButtonStroke, Library.HoverInfo, {
				Color = Library.Scheme.AccentGlow,
				Transparency = 0.1,
			}):Play()
			if not Library.IsMobile then
				TweenService:Create(T.ButtonLabel, Library.SpringInfo, { TextColor3 = Library.Scheme.WhiteColor }):Play()
			end
			T.Page.Position = UDim2.new(0, 10, 0, 30)
			TweenService:Create(T.Page, Library.TabTransitionInfo, {
				Position = UDim2.new(0, 10, 0, 10),
			}):Play()
		else
			T.Active = false
			T.Page.Visible = false
			TweenService:Create(T.Button, Library.HoverInfo, {
				BackgroundColor3 = Library.Scheme.SurfaceAlt,
				BackgroundTransparency = 0.55,
			}):Play()
			TweenService:Create(T.ButtonIcon, Library.HoverInfo, { ImageColor3 = Library.Scheme.OutlineColor }):Play()
			TweenService:Create(T.ButtonStroke, Library.HoverInfo, {
				Color = Library.Scheme.OutlineColor,
				Transparency = 0.65,
			}):Play()
			if not Library.IsMobile then
				TweenService:Create(T.ButtonLabel, Library.HoverInfo, { TextColor3 = Library.Scheme.OutlineColor }):Play()
			end
		end
	end
	self.ActiveTab = Tab_
	Library.ActiveTab = Tab_
end
function Tab:Select()
	self.Window:SelectTab(self)
end
local Groupbox = {}
Groupbox.__index = Groupbox
function Tab:AddGroupbox(Options)
	Options = Options or {}
	local self_ = setmetatable({}, Groupbox)
	self_.Tab = self
	self_.Name = Options.Name or "Groupbox"
	self_.IconName = Options.Icon or Options.IconName
	self_.Icon = self_.IconName and Library:GetCustomIcon(self_.IconName) or nil
	self_.Visible = Options.Visible ~= false
	self_.Collapsed = Options.Collapsed or false
	self_.DisableCollapsing = Options.DisableCollapsing or false
	self_.Elements = {}
	self_.DependencyBoxes = {}
	local Holder = New("Frame", {
		Name = "GroupboxHolder_" .. self_.Name,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Visible = self_.Visible,
		ZIndex = 3,
		Parent = self.Page,
	})
	self_.Holder = Holder
	local Main = New("Frame", {
		Name = "Main",
		BackgroundColor3 = Library.Scheme.MainColor,
		BackgroundTransparency = 0.22,
		Size = UDim2.new(1, 0, 0, 42),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 4,
		Parent = Holder,
	})
	self_.Main = Main
	self_.GlassCorner, self_.GlassStroke, self_.GlassGrad = Library:AddGlassEffect(Main, {
		CornerRadius = 14,
		Transparency = 0.1,
	})
	local Header = New("TextButton", {
		Name = "Header",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 42),
		Text = "",
		ZIndex = 5,
		Parent = Main,
	})
	self_.Header = Header
	local HeaderIcon = New("ImageLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(18, 18),
		Position = UDim2.new(0, 16, 0.5, -9),
		ImageColor3 = Library.Scheme.AccentColor,
		Visible = self_.Icon ~= nil,
		ZIndex = 6,
		Parent = Header,
	})
	if self_.Icon then Library:ApplyLucideIcon(HeaderIcon, self_.Icon) end
	self_.HeaderIcon = HeaderIcon
	local HeaderLabel = New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -100, 1, 0),
		Position = UDim2.new(0, self_.Icon and 42 or 16, 0, 0),
		Text = self_.Name,
		Font = Library.Scheme.Font,
		TextSize = 14,
		TextColor3 = Library.Scheme.FontColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 6,
		Parent = Header,
	})
	local Chevron = New("ImageLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(18, 18),
		Position = UDim2.new(1, -32, 0.5, -9),
		ImageColor3 = Library.Scheme.OutlineColor,
		Visible = not self_.DisableCollapsing,
		ZIndex = 6,
		Parent = Header,
	})
	if Library.Icons.Arrow then
		Library:ApplyLucideIcon(Chevron, Library.Icons.Arrow)
		Chevron.Rotation = 180
	end
	self_.Chevron = Chevron
	local Content = New("Frame", {
		Name = "Content",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Position = UDim2.new(0, 0, 0, 42),
		Visible = not self_.Collapsed,
		ZIndex = 5,
		Parent = Main,
	})
	self_.Content = Content
	New("UIListLayout", {
		Parent = Content,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	New("UIPadding", {
		Parent = Content,
		PaddingTop = UDim.new(0, 6),
		PaddingBottom = UDim.new(0, 12),
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
	})
	Library:GiveSignal(Header.MouseEnter:Connect(function()
		if not self_.DisableCollapsing then
			TweenService:Create(Chevron, Library.HoverInfo, { ImageColor3 = Library.Scheme.FontColor }):Play()
		end
	end))
	Library:GiveSignal(Header.MouseLeave:Connect(function()
		if not self_.DisableCollapsing then
			TweenService:Create(Chevron, Library.HoverInfo, { ImageColor3 = Library.Scheme.OutlineColor }):Play()
		end
	end))
	if not self_.DisableCollapsing then
		Library:GiveSignal(Header.MouseButton1Click:Connect(function()
			self_:SetCollapsed(not self_.Collapsed)
			if Library.IsMobile then
				local MousePos = UserInputService:GetMouseLocation()
				local AbsPos = Header.AbsolutePosition
				Library:CreateRipple(Header, MousePos.X - AbsPos.X, MousePos.Y - AbsPos.Y, Library.Scheme.AccentColor)
			end
		end))
	end
	table.insert(self.Groupboxes, self_)
	return self_
end
function Groupbox:SetCollapsed(Collapsed)
	self.Collapsed = Collapsed
	if self.Content then
		self.Content.Visible = not Collapsed
		if self.Chevron then
			local TargetRotation = Collapsed and 90 or 180
			TweenService:Create(self.Chevron, Library.RotatingChevronTweenInfo, { Rotation = TargetRotation }):Play()
		end
	end
end
function Groupbox:Toggle()
	self:SetCollapsed(not self.Collapsed)
end
function Groupbox:SetVisible(Visible)
	self.Visible = Visible
	if self.Holder then
		self.Holder.Visible = Visible
	end
end
local SectionHeader = {}
SectionHeader.__index = SectionHeader
function Tab:AddSection(Options)
	Options = Options or {}
	local self_ = setmetatable({}, SectionHeader)
	self_.Name = Options.Name or "Section"
	self_.IconName = Options.Icon
	local Holder = New("Frame", {
		Name = "Section_" .. self_.Name,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 28),
		ZIndex = 3,
		Parent = self.Page,
	})
	self_.Holder = Holder
	local IconImg = New("ImageLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(16, 16),
		Position = UDim2.new(0, 0, 0.5, -8),
		ImageColor3 = Library.Scheme.AccentColor,
		Visible = self_.IconName ~= nil,
		ZIndex = 4,
		Parent = Holder,
	})
	if self_.IconName then
		local IconData = Library:GetCustomIcon(self_.IconName)
		if IconData then Library:ApplyLucideIcon(IconImg, IconData) end
	end
	New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -30, 1, 0),
		Position = UDim2.new(0, self_.IconName and 24 or 0, 0, 0),
		Text = string.upper(self_.Name),
		Font = Library.Scheme.Font,
		TextSize = 11,
		TextColor3 = Library.Scheme.OutlineColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 4,
		Parent = Holder,
	})
	New("Frame", {
		BackgroundColor3 = Library.Scheme.OutlineColor,
		BackgroundTransparency = 0.6,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -2),
		ZIndex = 4,
		Parent = Holder,
	})
	return self_
end
local Divider = {}
Divider.__index = Divider
function Tab:AddDivider(Options)
	Options = Options or {}
	local self_ = setmetatable({}, Divider)
	local Holder = New("Frame", {
		Name = "Divider",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, Options.Height or 12),
		ZIndex = 3,
		Parent = self.Page,
	})
	self_.Holder = Holder
	if not Options.Hidden then
		New("Frame", {
			BackgroundColor3 = Library.Scheme.OutlineColor,
			BackgroundTransparency = 0.55,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(1, 0, 0, 1),
			ZIndex = 4,
			Parent = Holder,
		})
	end
	return self_
end
Library.Tab = Tab
Library.Groupbox = Groupbox
Library.SectionHeader = SectionHeader
Library.Divider = Divider
function Groupbox:AddLabel(Options)
	Options = Options or {}
	local Holder = New("Frame", {
		Name = "Label",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 22),
		ZIndex = 6,
		Parent = self.Content,
	})
	local Label = New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Text = Options.Text or "Label",
		Font = Library.Scheme.Font,
		TextSize = Options.Size or 13,
		TextColor3 = Options.Color or Library.Scheme.FontColor,
		TextXAlignment = Options.Alignment or Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		RichText = true,
		ZIndex = 7,
		Parent = Holder,
	})
	local Element = {
		Type = "Label",
		Holder = Holder,
		Text = Label.Text,
		Instance = Label,
		Set = function(_, Text)
			Label.Text = Text
		end,
		Get = function() return Label.Text end,
		Destroy = function()
			Holder:Destroy()
		end,
	}
	table.insert(self.Elements, Element)
	return Element
end
function Groupbox:AddParagraph(Options)
	Options = Options or {}
	local Holder = New("Frame", {
		Name = "Paragraph",
		BackgroundColor3 = Library.Scheme.BackgroundColor,
		BackgroundTransparency = 0.5,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 6,
		Parent = self.Content,
	})
	New("UICorner", { Parent = Holder, CornerRadius = UDim.new(0, 10) })
	New("UIStroke", {
		Parent = Holder,
		Color = Library.Scheme.OutlineColor,
		Thickness = 1,
		Transparency = 0.6,
	})
	New("UIPadding", {
		Parent = Holder,
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
	})
	local Layout = New("UIListLayout", {
		Parent = Holder,
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	if Options.Title then
		New("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 18),
			Text = Options.Title,
			Font = Library.Scheme.Font,
			TextSize = 13,
			TextColor3 = Library.Scheme.FontColor,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 7,
			Parent = Holder,
		})
	end
	local Body = New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = Options.Text or "Paragraph",
		Font = Library.Scheme.Font,
		TextSize = 12,
		TextColor3 = Library.Scheme.OutlineColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		ZIndex = 7,
		Parent = Holder,
	})
	local Element = {
		Type = "Paragraph",
		Holder = Holder,
		Text = Body.Text,
		Instance = Body,
		Set = function(_, Text)
			Body.Text = Text
		end,
		Get = function() return Body.Text end,
		Destroy = function()
			Holder:Destroy()
		end,
	}
	table.insert(self.Elements, Element)
	return Element
end
function Groupbox:AddButton(Options)
	Options = Options or {}
	local self_ = {}
	local Holder = New("TextButton", {
		Name = "Button_" .. (Options.Text or "Button"),
		BackgroundColor3 = Library.Scheme.SurfaceAlt,
		BackgroundTransparency = 0.4,
		Size = UDim2.new(1, 0, 0, Library.IsMobile and 44 or 40),
		Text = "",
		AutoButtonColor = false,
		ZIndex = 6,
		Parent = self.Content,
	})
	New("UICorner", { Parent = Holder, CornerRadius = UDim.new(0, 10) })
	local Stroke = New("UIStroke", {
		Parent = Holder,
		Color = Library.Scheme.OutlineColor,
		Thickness = 1,
		Transparency = 0.65,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
	New("UIGradient", {
		Parent = Holder,
		Color = ColorSequence.new(Library:GetLighterColor(Library.Scheme.SurfaceAlt, 0.03), Library.Scheme.SurfaceAlt),
		Rotation = 135,
	})
	local IconImg = New("ImageLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(18, 18),
		Position = UDim2.new(0, 14, 0.5, -9),
		ImageColor3 = Library.Scheme.AccentColor,
		Visible = Options.Icon ~= nil,
		ZIndex = 7,
		Parent = Holder,
	})
	if Options.Icon then
		local IconData = Library:GetCustomIcon(Options.Icon)
		if IconData then Library:ApplyLucideIcon(IconImg, IconData) end
	end
	local Label = New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -50, 1, 0),
		Position = UDim2.new(0, Options.Icon and 40 or 16, 0, 0),
		Text = Options.Text or "Button",
		Font = Library.Scheme.Font,
		TextSize = 13,
		TextColor3 = Library.Scheme.FontColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 7,
		Parent = Holder,
	})
	self_.Instance = Holder
	self_.Stroke = Stroke
	self_.Label = Label
	Library:GiveSignal(Holder.MouseEnter:Connect(function()
		TweenService:Create(Holder, Library.HoverInfo, { BackgroundTransparency = 0.15 }):Play()
		TweenService:Create(Stroke, Library.HoverInfo, { Color = Library.Scheme.AccentColor, Transparency = 0.2 }):Play()
	end))
	Library:GiveSignal(Holder.MouseLeave:Connect(function()
		TweenService:Create(Holder, Library.HoverInfo, { BackgroundTransparency = 0.4 }):Play()
		TweenService:Create(Stroke, Library.HoverInfo, { Color = Library.Scheme.OutlineColor, Transparency = 0.65 }):Play()
	end))
	Library:GiveSignal(Holder.MouseButton1Click:Connect(function()
		Library:Pulse(Holder, 0.94, 1)
		if Library.IsMobile then
			local MousePos = UserInputService:GetMouseLocation()
			local AbsPos = Holder.AbsolutePosition
			Library:CreateRipple(Holder, MousePos.X - AbsPos.X, MousePos.Y - AbsPos.Y, Library.Scheme.AccentColor)
		end
		Library:SafeCallback(Options.Callback)
	end))
	self_.Set = function(_, Text)
		Label.Text = Text
	end
	self_.Get = function() return Label.Text end
	self_.Destroy = function() Holder:Destroy() end
	table.insert(self.Elements, { Type = "Button", Holder = Holder, Text = Label.Text, Visible = true, Instance = Holder })
	return self_
end
function Groupbox:AddToggle(Options)
	Options = Options or {}
	local Value = Options.Default or false
	local Holder = New("TextButton", {
		Name = "Toggle_" .. (Options.Text or "Toggle"),
		BackgroundColor3 = Library.Scheme.SurfaceAlt,
		BackgroundTransparency = 0.4,
		Size = UDim2.new(1, 0, 0, Library.IsMobile and 48 or 42),
		Text = "",
		AutoButtonColor = false,
		ZIndex = 6,
		Parent = self.Content,
	})
	New("UICorner", { Parent = Holder, CornerRadius = UDim.new(0, 10) })
	local Stroke = New("UIStroke", {
		Parent = Holder,
		Color = Library.Scheme.OutlineColor,
		Thickness = 1,
		Transparency = 0.65,
	})
	local Label = New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -80, 1, 0),
		Position = UDim2.new(0, 16, 0, 0),
		Text = Options.Text or "Toggle",
		Font = Library.Scheme.Font,
		TextSize = 13,
		TextColor3 = Library.Scheme.FontColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 7,
		Parent = Holder,
	})
	local SwitchSize = UDim2.fromOffset(46, 26)
	local Switch = New("Frame", {
		BackgroundColor3 = Library.Scheme.OutlineColor,
		BackgroundTransparency = 0.3,
		Size = SwitchSize,
		Position = UDim2.new(1, -SwitchSize.X.Offset - 14, 0.5, -SwitchSize.Y.Offset / 2),
		ZIndex = 7,
		Parent = Holder,
	})
	New("UICorner", { Parent = Switch, CornerRadius = UDim.new(1, 0) })
	local Knob = New("Frame", {
		BackgroundColor3 = Library.Scheme.WhiteColor,
		Size = UDim2.fromOffset(20, 20),
		Position = UDim2.new(0, 3, 0.5, -10),
		ZIndex = 8,
		Parent = Switch,
	})
	New("UICorner", { Parent = Knob, CornerRadius = UDim.new(1, 0) })
	New("UIStroke", {
		Parent = Knob,
		Color = Library.Scheme.DarkColor,
		Thickness = 1,
		Transparency = 0.85,
	})
	local function SetValue(NewValue, FireCallback)
		Value = NewValue
		if Value then
			TweenService:Create(Switch, Library.SpringInfo, {
				BackgroundColor3 = Library.Scheme.AccentColor,
				BackgroundTransparency = 0.05,
			}):Play()
			TweenService:Create(Knob, Library.SpringInfo, {
				Position = UDim2.new(1, -23, 0.5, -10),
			}):Play()
			TweenService:Create(Stroke, Library.HoverInfo, {
				Color = Library.Scheme.AccentGlow,
				Transparency = 0.3,
			}):Play()
		else
			TweenService:Create(Switch, Library.HoverInfo, {
				BackgroundColor3 = Library.Scheme.OutlineColor,
				BackgroundTransparency = 0.3,
			}):Play()
			TweenService:Create(Knob, Library.SpringInfo, {
				Position = UDim2.new(0, 3, 0.5, -10),
			}):Play()
			TweenService:Create(Stroke, Library.HoverInfo, {
				Color = Library.Scheme.OutlineColor,
				Transparency = 0.65,
			}):Play()
		end
		if FireCallback then
			Library:SafeCallback(Options.Callback, Value)
			Library:SafeCallback(Options.Changed, Value)
		end
	end
	if Value then
		Switch.BackgroundColor3 = Library.Scheme.AccentColor
		Switch.BackgroundTransparency = 0.05
		Knob.Position = UDim2.new(1, -23, 0.5, -10)
	end
	Library:GiveSignal(Holder.MouseEnter:Connect(function()
		TweenService:Create(Holder, Library.HoverInfo, { BackgroundTransparency = 0.15 }):Play()
	end))
	Library:GiveSignal(Holder.MouseLeave:Connect(function()
		TweenService:Create(Holder, Library.HoverInfo, { BackgroundTransparency = 0.4 }):Play()
	end))
	Library:GiveSignal(Holder.MouseButton1Click:Connect(function()
		if Options.Disabled then return end
		if Library.IsMobile then
			local MousePos = UserInputService:GetMouseLocation()
			local AbsPos = Holder.AbsolutePosition
			Library:CreateRipple(Holder, MousePos.X - AbsPos.X, MousePos.Y - AbsPos.Y, Library.Scheme.AccentColor)
		end
		SetValue(not Value, true)
	end))
	local Toggle = {
		Type = "Toggle",
		Holder = Holder,
		Text = Options.Text,
		Value = Value,
		Visible = true,
		Set = function(_, NewValue)
			SetValue(NewValue, true)
		end,
		Get = function() return Value end,
		SetValue = function(_, NewValue)
			SetValue(NewValue, false)
		end,
		Destroy = function()
			Holder:Destroy()
		end,
	}
	table.insert(self.Elements, Toggle)
	table.insert(Library.Toggles, Toggle)
	table.insert(Library.Options, Toggle)
	return Toggle
end
Library.Groupbox = Groupbox
function Groupbox:AddInput(Options)
	Options = Options or {}
	local Value = Options.Default or ""
	local Holder = New("Frame", {
		Name = "Input_" .. (Options.Text or "Input"),
		BackgroundColor3 = Library.Scheme.SurfaceAlt,
		BackgroundTransparency = 0.4,
		Size = UDim2.new(1, 0, 0, Library.IsMobile and 48 or 42),
		ZIndex = 6,
		Parent = self.Content,
	})
	New("UICorner", { Parent = Holder, CornerRadius = UDim.new(0, 10) })
	local Stroke = New("UIStroke", {
		Parent = Holder,
		Color = Library.Scheme.OutlineColor,
		Thickness = 1,
		Transparency = 0.65,
	})
	local Label = New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0.4, -20, 1, 0),
		Position = UDim2.new(0, 16, 0, 0),
		Text = Options.Text or "Input",
		Font = Library.Scheme.Font,
		TextSize = 13,
		TextColor3 = Library.Scheme.FontColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 7,
		Parent = Holder,
	})
	local Box = New("TextBox", {
		BackgroundColor3 = Library.Scheme.BackgroundColor,
		BackgroundTransparency = 0.4,
		Size = UDim2.new(0.6, -30, 1, -14),
		Position = UDim2.new(0.4, 4, 0, 7),
		Text = tostring(Value),
		PlaceholderText = Options.Placeholder or "Nhập...",
		PlaceholderColor3 = Library.Scheme.OutlineColor,
		Font = Library.Scheme.Font,
		TextSize = 13,
		TextColor3 = Library.Scheme.FontColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = Options.ClearTextOnFocus ~= false,
		ZIndex = 7,
		Parent = Holder,
	})
	New("UICorner", { Parent = Box, CornerRadius = UDim.new(0, 8) })
	New("UIPadding", {
		Parent = Box,
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
	})
	local BoxStroke = New("UIStroke", {
		Parent = Box,
		Color = Library.Scheme.OutlineColor,
		Thickness = 1,
		Transparency = 0.5,
	})
	Library:GiveSignal(Box.Focused:Connect(function()
		TweenService:Create(BoxStroke, Library.HoverInfo, {
			Color = Library.Scheme.AccentColor,
			Transparency = 0.1,
		}):Play()
		TweenService:Create(Holder, Library.HoverInfo, { BackgroundTransparency = 0.15 }):Play()
	end))
	Library:GiveSignal(Box.FocusLost:Connect(function(EnterPressed)
		TweenService:Create(BoxStroke, Library.HoverInfo, {
			Color = Library.Scheme.OutlineColor,
			Transparency = 0.5,
		}):Play()
		TweenService:Create(Holder, Library.HoverInfo, { BackgroundTransparency = 0.4 }):Play()
		local NewText = Box.Text
		if Options.Numeric then
			local Num = tonumber(NewText:match("[-%d%.]+") or "")
			if Num then
				NewText = tostring(Num)
			else
				NewText = tostring(Value)
			end
			Box.Text = NewText
		end
		if not Options.AllowEmpty and NewText == "" then
			NewText = Options.EmptyReset or "---"
			Box.Text = NewText
		end
		if Options.VerifyValue then
			local ok, result = pcall(Options.VerifyValue, NewText)
			if ok and result ~= nil then
				NewText = result
				Box.Text = NewText
			end
		end
		Value = NewText
		Library:SafeCallback(Options.Callback, Value, EnterPressed)
		Library:SafeCallback(Options.Changed, Value)
		if EnterPressed and Options.Finished then
			Library:SafeCallback(Options.Finished, Value)
		end
	end))
	local Element = {
		Type = "Input",
		Holder = Holder,
		Text = Options.Text,
		Value = Value,
		Visible = true,
		Set = function(_, NewText)
			Box.Text = tostring(NewText)
			Value = NewText
			Library:SafeCallback(Options.Callback, Value, false)
		end,
		Get = function() return Value end,
		SetValue = function(_, NewText)
			Box.Text = tostring(NewText)
			Value = NewText
		end,
		Destroy = function()
			Holder:Destroy()
		end,
	}
	table.insert(self.Elements, Element)
	table.insert(Library.Options, Element)
	return Element
end
function Groupbox:AddSlider(Options)
	Options = Options or {}
	local Min = Options.Min or 0
	local Max = Options.Max or 100
	local Value = Options.Default or Min
	local Rounding = Options.Rounding or 0
	local Prefix = Options.Prefix or ""
	local Suffix = Options.Suffix or ""
	local Holder = New("Frame", {
		Name = "Slider_" .. (Options.Text or "Slider"),
		BackgroundColor3 = Library.Scheme.SurfaceAlt,
		BackgroundTransparency = 0.4,
		Size = UDim2.new(1, 0, 0, Library.IsMobile and 68 or 62),
		ZIndex = 6,
		Parent = self.Content,
	})
	New("UICorner", { Parent = Holder, CornerRadius = UDim.new(0, 10) })
	New("UIStroke", {
		Parent = Holder,
		Color = Library.Scheme.OutlineColor,
		Thickness = 1,
		Transparency = 0.65,
	})
	New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -120, 0, 20),
		Position = UDim2.new(0, 16, 0, 8),
		Text = Options.Text or "Slider",
		Font = Library.Scheme.Font,
		TextSize = 13,
		TextColor3 = Library.Scheme.FontColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 7,
		Parent = Holder,
	})
	local ValueBox = New("TextBox", {
		BackgroundColor3 = Library.Scheme.BackgroundColor,
		BackgroundTransparency = 0.4,
		Size = UDim2.fromOffset(72, 22),
		Position = UDim2.new(1, -88, 0, 6),
		Text = Prefix .. tostring(Value) .. Suffix,
		Font = Library.Scheme.Font,
		TextSize = 12,
		TextColor3 = Library.Scheme.AccentColor,
		TextXAlignment = Enum.TextXAlignment.Center,
		ClearTextOnFocus = false,
		ZIndex = 7,
		Parent = Holder,
	})
	New("UICorner", { Parent = ValueBox, CornerRadius = UDim.new(0, 6) })
	local ValueBoxStroke = New("UIStroke", {
		Parent = ValueBox,
		Color = Library.Scheme.OutlineColor,
		Thickness = 1,
		Transparency = 0.5,
	})
	local TrackFrame = New("Frame", {
		BackgroundColor3 = Library.Scheme.BackgroundColor,
		BackgroundTransparency = 0.3,
		Size = UDim2.new(1, -32, 0, 6),
		Position = UDim2.new(0, 16, 1, -22),
		ZIndex = 7,
		Parent = Holder,
	})
	New("UICorner", { Parent = TrackFrame, CornerRadius = UDim.new(1, 0) })
	local TrackStroke = New("UIStroke", {
		Parent = TrackFrame,
		Color = Library.Scheme.OutlineColor,
		Thickness = 1,
		Transparency = 0.7,
	})
	local Fill = New("Frame", {
		BackgroundColor3 = Library.Scheme.AccentColor,
		Size = UDim2.new((Value - Min) / (Max - Min), 0, 1, 0),
		ZIndex = 8,
		Parent = TrackFrame,
	})
	New("UICorner", { Parent = Fill, CornerRadius = UDim.new(1, 0) })
	New("UIGradient", {
		Parent = Fill,
		Color = ColorSequence.new(Library.Scheme.AccentColor, Library.Scheme.AccentGlow),
	})
	local Knob = New("Frame", {
		BackgroundColor3 = Library.Scheme.WhiteColor,
		Size = UDim2.fromOffset(16, 16),
		Position = UDim2.new((Value - Min) / (Max - Min), -8, 0.5, -8),
		ZIndex = 9,
		Parent = TrackFrame,
	})
	New("UICorner", { Parent = Knob, CornerRadius = UDim.new(1, 0) })
	New("UIStroke", {
		Parent = Knob,
		Color = Library.Scheme.AccentColor,
		Thickness = 2,
	})
	local function SetValue(NewValue, FireCallback)
		NewValue = math.clamp(NewValue, Min, Max)
		NewValue = Round(NewValue, Rounding)
		Value = NewValue
		local Alpha = (NewValue - Min) / (Max - Min)
		TweenService:Create(Fill, Library.HoverInfo, { Size = UDim2.new(Alpha, 0, 1, 0) }):Play()
		TweenService:Create(Knob, Library.HoverInfo, { Position = UDim2.new(Alpha, -8, 0.5, -8) }):Play()
		if not ValueBox:IsFocused() then
			ValueBox.Text = Prefix .. tostring(Value) .. Suffix
		end
		if FireCallback then
			Library:SafeCallback(Options.Callback, Value)
			Library:SafeCallback(Options.Changed, Value)
		end
	end
	local Dragging = false
	local ActiveInput = nil
	local function UpdateFromX(X)
		local Rel = (X - TrackFrame.AbsolutePosition.X) / TrackFrame.AbsoluteSize.X
		Rel = math.clamp(Rel, 0, 1)
		SetValue(Min + Rel * (Max - Min), true)
	end
	Library:GiveSignal(TrackFrame.InputBegan:Connect(function(Input)
		if not IsClickInput(Input) then return end
		Dragging = true
		ActiveInput = Input
		UpdateFromX(Input.Position.X)
		Input.Changed:Connect(function()
			if Input.UserInputState == Enum.UserInputState.End then
				Dragging = false
				ActiveInput = nil
			end
		end)
	end))
	Library:GiveSignal(UserInputService.InputChanged:Connect(function(Input)
		if not Dragging or not ActiveInput then return end
		if not IsHoverInput(Input) then return end
		UpdateFromX(Input.Position.X)
	end))
	Library:GiveSignal(UserInputService.InputEnded:Connect(function(Input)
		if IsMouseInput(Input) then
			Dragging = false
			ActiveInput = nil
		end
	end))
	Library:GiveSignal(ValueBox.Focused:Connect(function()
		TweenService:Create(ValueBoxStroke, Library.HoverInfo, {
			Color = Library.Scheme.AccentColor,
			Transparency = 0.1,
		}):Play()
	end))
	Library:GiveSignal(ValueBox.FocusLost:Connect(function()
		TweenService:Create(ValueBoxStroke, Library.HoverInfo, {
			Color = Library.Scheme.OutlineColor,
			Transparency = 0.5,
		}):Play()
		local Num = tonumber(ValueBox.Text:match("[-%d%.]+") or "")
		if Num then
			SetValue(Num, true)
		else
			ValueBox.Text = Prefix .. tostring(Value) .. Suffix
		end
	end))
	local Element = {
		Type = "Slider",
		Holder = Holder,
		Text = Options.Text,
		Value = Value,
		Visible = true,
		Set = function(_, NewValue)
			SetValue(NewValue, true)
		end,
		Get = function() return Value end,
		SetValue = function(_, NewValue)
			SetValue(NewValue, false)
		end,
		Destroy = function()
			Holder:Destroy()
		end,
	}
	table.insert(self.Elements, Element)
	table.insert(Library.Options, Element)
	return Element
end
Library.Groupbox = Groupbox
function Groupbox:AddDropdown(Options)
	Options = Options or {}
	local Values = Options.Values or {}
	local Multi = Options.Multi or false
	local Selected = {}
	local SelectedCount = 0
	local Expanded = false
	local MaxVisible = Options.MaxVisibleDropdownItems or 8
	local ItemHeight = Library.IsMobile and 40 or 34
	local Holder = New("Frame", {
		Name = "Dropdown_" .. (Options.Text or "Dropdown"),
		BackgroundColor3 = Library.Scheme.SurfaceAlt,
		BackgroundTransparency = 0.4,
		Size = UDim2.new(1, 0, 0, Library.IsMobile and 48 or 42),
		ClipsDescendants = true,
		ZIndex = 6,
		Parent = self.Content,
	})
	New("UICorner", { Parent = Holder, CornerRadius = UDim.new(0, 10) })
	local HolderStroke = New("UIStroke", {
		Parent = Holder,
		Color = Library.Scheme.OutlineColor,
		Thickness = 1,
		Transparency = 0.65,
	})
	local Header = New("TextButton", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, Library.IsMobile and 48 or 42),
		Text = "",
		AutoButtonColor = false,
		ZIndex = 7,
		Parent = Holder,
	})
	local Label = New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0.5, -20, 1, 0),
		Position = UDim2.new(0, 16, 0, 0),
		Text = Options.Text or "Dropdown",
		Font = Library.Scheme.Font,
		TextSize = 13,
		TextColor3 = Library.Scheme.FontColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 8,
		Parent = Header,
	})
	local ValueLabel = New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0.5, -40, 1, 0),
		Position = UDim2.new(0.5, -20, 0, 0),
		Text = "Chưa chọn",
		Font = Library.Scheme.Font,
		TextSize = 12,
		TextColor3 = Library.Scheme.AccentColor,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 8,
		Parent = Header,
	})
	local Chevron = New("ImageLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(16, 16),
		Position = UDim2.new(1, -28, 0.5, -8),
		ImageColor3 = Library.Scheme.OutlineColor,
		ZIndex = 8,
		Parent = Header,
	})
	if Library.Icons.Arrow then
		Library:ApplyLucideIcon(Chevron, Library.Icons.Arrow)
		Chevron.Rotation = 180
	end
	local ScrollContainer = New("ScrollingFrame", {
		Name = "Items",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -12, 0, 0),
		Position = UDim2.new(0, 6, 0, Library.IsMobile and 48 or 42),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Library.Scheme.AccentColor,
		ScrollBarImageTransparency = 0.5,
		Visible = false,
		ZIndex = 7,
		Parent = Holder,
	})
	New("UIListLayout", {
		Parent = ScrollContainer,
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	New("UIPadding", {
		Parent = ScrollContainer,
		PaddingTop = UDim.new(0, 4),
		PaddingBottom = UDim.new(0, 8),
	})
	local ItemButtons = {}
	local function RefreshValueLabel()
		if SelectedCount == 0 then
			ValueLabel.Text = "Chưa chọn"
		elseif SelectedCount == 1 then
			for _, Name in pairs(Selected) do
				ValueLabel.Text = Name
				break
			end
		else
			ValueLabel.Text = tostring(SelectedCount) .. " đã chọn"
		end
	end
	local function CreateItem(Value)
		local ItemBtn = New("TextButton", {
			BackgroundColor3 = Library.Scheme.BackgroundColor,
			BackgroundTransparency = 0.5,
			Size = UDim2.new(1, -4, 0, ItemHeight),
			Text = "",
			AutoButtonColor = false,
			ZIndex = 8,
			Parent = ScrollContainer,
		})
		New("UICorner", { Parent = ItemBtn, CornerRadius = UDim.new(0, 8) })
		local ItemLabel = New("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -40, 1, 0),
			Position = UDim2.new(0, 12, 0, 0),
			Text = tostring(Value),
			Font = Library.Scheme.Font,
			TextSize = 12,
			TextColor3 = Library.Scheme.FontColor,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 9,
			Parent = ItemBtn,
		})
		local CheckIconImg = New("ImageLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(16, 16),
			Position = UDim2.new(1, -28, 0.5, -8),
			ImageColor3 = Library.Scheme.AccentColor,
			Visible = false,
			ZIndex = 9,
			Parent = ItemBtn,
		})
		if Library.Icons.Check then
			Library:ApplyLucideIcon(CheckIconImg, Library.Icons.Check)
		else
			CheckIconImg.Image = CustomImageManager.GetAsset("CheckIcon")
		end
		ItemButtons[Value] = { Button = ItemBtn, Check = CheckIconImg, Label = ItemLabel }
		Library:GiveSignal(ItemBtn.MouseEnter:Connect(function()
			TweenService:Create(ItemBtn, Library.HoverInfo, { BackgroundTransparency = 0.15 }):Play()
		end))
		Library:GiveSignal(ItemBtn.MouseLeave:Connect(function()
			TweenService:Create(ItemBtn, Library.HoverInfo, { BackgroundTransparency = 0.5 }):Play()
		end))
		Library:GiveSignal(ItemBtn.MouseButton1Click:Connect(function()
			if not Multi then
				for k, data in pairs(ItemButtons) do
					Selected[k] = nil
					data.Check.Visible = false
				end
				Selected[Value] = Value
				SelectedCount = 1
				CheckIconImg.Visible = true
				Library:SafeCallback(Options.Callback, Value)
				Library:SafeCallback(Options.Changed, Value)
			else
				if Selected[Value] then
					Selected[Value] = nil
					SelectedCount -= 1
					CheckIconImg.Visible = false
				else
					Selected[Value] = Value
					SelectedCount += 1
					CheckIconImg.Visible = true
				end
				local Result = {}
				for _, v in pairs(Selected) do table.insert(Result, v) end
				Library:SafeCallback(Options.Callback, Result)
				Library:SafeCallback(Options.Changed, Result)
			end
			RefreshValueLabel()
		end))
	end
	for _, Value in ipairs(Values) do
		CreateItem(Value)
	end
	local function ToggleExpanded()
		Expanded = not Expanded
		local Items = ScrollContainer:GetChildren()
		local ItemCount = 0
		for _, child in ipairs(Items) do
			if child:IsA("TextButton") then ItemCount += 1 end
		end
		local VisibleCount = math.min(ItemCount, MaxVisible)
		local TargetHeight = VisibleCount * (ItemHeight + 4) + 12
		local TotalHeight = (Library.IsMobile and 48 or 42) + (Expanded and TargetHeight or 0)
		TweenService:Create(Holder, Library.SpringInfo, { Size = UDim2.new(1, 0, 0, TotalHeight) }):Play()
		TweenService:Create(ScrollContainer, Library.SpringInfo, {
			Size = UDim2.new(1, -12, 0, Expanded and TargetHeight or 0),
		}):Play()
		TweenService:Create(Chevron, Library.SpringInfo, {
			Rotation = Expanded and 0 or 180,
		}):Play()
		TweenService:Create(HolderStroke, Library.HoverInfo, {
			Color = Expanded and Library.Scheme.AccentColor or Library.Scheme.OutlineColor,
			Transparency = Expanded and 0.2 or 0.65,
		}):Play()
		ScrollContainer.Visible = Expanded
	end
	Library:GiveSignal(Header.MouseButton1Click:Connect(function()
		ToggleExpanded()
		if Library.IsMobile then
			local MousePos = UserInputService:GetMouseLocation()
			local AbsPos = Header.AbsolutePosition
			Library:CreateRipple(Header, MousePos.X - AbsPos.X, MousePos.Y - AbsPos.Y, Library.Scheme.AccentColor)
		end
	end))
	local Element = {
		Type = "Dropdown",
		Holder = Holder,
		Text = Options.Text,
		Values = Values,
		Visible = true,
		Get = function()
			local Result = {}
			for _, v in pairs(Selected) do table.insert(Result, v) end
			return Multi and Result or Result[1]
		end,
		Set = function(_, NewValue)
			for k, data in pairs(ItemButtons) do
				Selected[k] = nil
				data.Check.Visible = false
			end
			SelectedCount = 0
			if typeof(NewValue) == "table" then
				for _, v in ipairs(NewValue) do
					if ItemButtons[v] then
						Selected[v] = v
						SelectedCount += 1
						ItemButtons[v].Check.Visible = true
					end
				end
			elseif ItemButtons[NewValue] then
				Selected[NewValue] = NewValue
				SelectedCount = 1
				ItemButtons[NewValue].Check.Visible = true
			end
			RefreshValueLabel()
		end,
		Destroy = function()
			Holder:Destroy()
		end,
	}
	table.insert(self.Elements, Element)
	table.insert(Library.Options, Element)
	return Element
end
function Groupbox:AddKeyPicker(Options)
	Options = Options or {}
	local CurrentKey = Options.Default or "None"
	local Mode = Options.Mode or "Toggle"
	local Listening = false
	local Holding = false
	local Toggled = false
	local Holder = New("Frame", {
		Name = "KeyPicker_" .. (Options.Text or "KeyPicker"),
		BackgroundColor3 = Library.Scheme.SurfaceAlt,
		BackgroundTransparency = 0.4,
		Size = UDim2.new(1, 0, 0, Library.IsMobile and 48 or 42),
		ZIndex = 6,
		Parent = self.Content,
	})
	New("UICorner", { Parent = Holder, CornerRadius = UDim.new(0, 10) })
	New("UIStroke", {
		Parent = Holder,
		Color = Library.Scheme.OutlineColor,
		Thickness = 1,
		Transparency = 0.65,
	})
	New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0.5, -20, 1, 0),
		Position = UDim2.new(0, 16, 0, 0),
		Text = Options.Text or "Keybind",
		Font = Library.Scheme.Font,
		TextSize = 13,
		TextColor3 = Library.Scheme.FontColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 7,
		Parent = Holder,
	})
	local KeyBtn = New("TextButton", {
		BackgroundColor3 = Library.Scheme.BackgroundColor,
		BackgroundTransparency = 0.3,
		Size = UDim2.fromOffset(80, Library.IsMobile and 34 or 28),
		Position = UDim2.new(1, -94, 0.5, Library.IsMobile and -17 or -14),
		Text = CurrentKey,
		Font = Library.Scheme.Font,
		TextSize = 12,
		TextColor3 = Library.Scheme.AccentColor,
		AutoButtonColor = false,
		ZIndex = 7,
		Parent = Holder,
	})
	New("UICorner", { Parent = KeyBtn, CornerRadius = UDim.new(0, 6) })
	local KeyBtnStroke = New("UIStroke", {
		Parent = KeyBtn,
		Color = Library.Scheme.OutlineColor,
		Thickness = 1,
		Transparency = 0.5,
	})
	Library:GiveSignal(KeyBtn.MouseEnter:Connect(function()
		if not Listening then
			TweenService:Create(KeyBtn, Library.HoverInfo, { BackgroundTransparency = 0.15 }):Play()
		end
	end))
	Library:GiveSignal(KeyBtn.MouseLeave:Connect(function()
		if not Listening then
			TweenService:Create(KeyBtn, Library.HoverInfo, { BackgroundTransparency = 0.3 }):Play()
		end
	end))
	Library:GiveSignal(KeyBtn.MouseButton1Click:Connect(function()
		Listening = not Listening
		if Listening then
			KeyBtn.Text = "..."
			TweenService:Create(KeyBtnStroke, Library.HoverInfo, {
				Color = Library.Scheme.AccentColor,
				Transparency = 0.1,
			}):Play()
		else
			KeyBtn.Text = CurrentKey
			TweenService:Create(KeyBtnStroke, Library.HoverInfo, {
				Color = Library.Scheme.OutlineColor,
				Transparency = 0.5,
			}):Play()
		end
	end))
	Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input, GPE)
		if GPE then return end
		if Listening and Input.UserInputType == Enum.UserInputType.Keyboard then
			Listening = false
			CurrentKey = Library:GetKeyString(Input.KeyCode)
			KeyBtn.Text = CurrentKey
			TweenService:Create(KeyBtnStroke, Library.HoverInfo, {
				Color = Library.Scheme.OutlineColor,
				Transparency = 0.5,
			}):Play()
			Library:SafeCallback(Options.ChangedCallback, CurrentKey)
			Library:SafeCallback(Options.Changed, CurrentKey)
		elseif not Listening and Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == CurrentKey then
			if Mode == "Toggle" then
				Toggled = not Toggled
				Library:SafeCallback(Options.Callback, Toggled)
			elseif Mode == "Hold" then
				Holding = true
				Library:SafeCallback(Options.Callback, true)
			else
				Library:SafeCallback(Options.Callback, true)
			end
			Library:SafeCallback(Options.Clicked)
		end
	end))
	Library:GiveSignal(UserInputService.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == CurrentKey then
			if Mode == "Hold" and Holding then
				Holding = false
				Library:SafeCallback(Options.Callback, false)
			end
		end
	end))
	local Element = {
		Type = "KeyPicker",
		Holder = Holder,
		Text = Options.Text,
		Visible = true,
		Get = function() return CurrentKey end,
		Set = function(_, NewKey)
			CurrentKey = NewKey
			KeyBtn.Text = NewKey
		end,
		GetMode = function() return Mode end,
		SetMode = function(_, NewMode)
			Mode = NewMode
		end,
		GetState = function() return Toggled end,
		Destroy = function()
			Holder:Destroy()
		end,
	}
	table.insert(self.Elements, Element)
	table.insert(Library.Options, Element)
	return Element
end
Library.Groupbox = Groupbox
function Groupbox:AddColorPicker(Options)
	Options = Options or {}
	local Color = Options.Default or Color3.fromRGB(125, 145, 255)
	local H, S, V = Color:ToHSV()
	local Hue = H
	local Sat = S
	local Val = V
	local Expanded = false
	local PanelHeight = Library.IsMobile and 220 or 200
	local Holder = New("Frame", {
		Name = "ColorPicker_" .. (Options.Text or "Color"),
		BackgroundColor3 = Library.Scheme.SurfaceAlt,
		BackgroundTransparency = 0.4,
		Size = UDim2.new(1, 0, 0, Library.IsMobile and 48 or 42),
		ClipsDescendants = true,
		ZIndex = 6,
		Parent = self.Content,
	})
	New("UICorner", { Parent = Holder, CornerRadius = UDim.new(0, 10) })
	local HolderStroke = New("UIStroke", {
		Parent = Holder,
		Color = Library.Scheme.OutlineColor,
		Thickness = 1,
		Transparency = 0.65,
	})
	local Header = New("TextButton", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, Library.IsMobile and 48 or 42),
		Text = "",
		AutoButtonColor = false,
		ZIndex = 7,
		Parent = Holder,
	})
	New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0.6, -20, 1, 0),
		Position = UDim2.new(0, 16, 0, 0),
		Text = Options.Text or "Color",
		Font = Library.Scheme.Font,
		TextSize = 13,
		TextColor3 = Library.Scheme.FontColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 8,
		Parent = Header,
	})
	local Swatch = New("Frame", {
		BackgroundColor3 = Color,
		Size = UDim2.fromOffset(48, 24),
		Position = UDim2.new(1, -60, 0.5, -12),
		ZIndex = 8,
		Parent = Header,
	})
	New("UICorner", { Parent = Swatch, CornerRadius = UDim.new(0, 6) })
	New("UIStroke", {
		Parent = Swatch,
		Color = Library.Scheme.OutlineColor,
		Thickness = 1,
		Transparency = 0.4,
	})
	local Panel = New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -24, 0, PanelHeight),
		Position = UDim2.new(0, 12, 0, Library.IsMobile and 52 or 46),
		ZIndex = 7,
		Parent = Holder,
	})
	local SVFrame = New("Frame", {
		BackgroundColor3 = Color3.fromHSV(Hue, 1, 1),
		Size = UDim2.new(1, 0, 0, 110),
		ZIndex = 8,
		Parent = Panel,
	})
	New("UICorner", { Parent = SVFrame, CornerRadius = UDim.new(0, 8) })
	New("UIGradient", {
		Parent = SVFrame,
		Color = ColorSequence.new(Color3.new(1, 1, 1)),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 1),
		}),
		Rotation = 0,
	})
	local SVBlack = New("Frame", {
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 8,
		Parent = SVFrame,
	})
	New("UICorner", { Parent = SVBlack, CornerRadius = UDim.new(0, 8) })
	local SVBlackGrad = New("UIGradient", {
		Parent = SVBlack,
		Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.new(0, 0, 0)),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(1, 0),
		}),
		Rotation = 90,
	})
	local Cursor = New("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1),
		Size = UDim2.fromOffset(12, 12),
		Position = UDim2.new(Sat, -6, 1 - Val, -6),
		ZIndex = 10,
		Parent = SVFrame,
	})
	New("UICorner", { Parent = Cursor, CornerRadius = UDim.new(1, 0) })
	New("UIStroke", {
		Parent = Cursor,
		Color = Color3.new(0, 0, 0),
		Thickness = 2,
	})
	local HueBar = New("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1),
		Size = UDim2.new(1, 0, 0, 16),
		Position = UDim2.new(0, 0, 0, 120),
		ZIndex = 8,
		Parent = Panel,
	})
	New("UICorner", { Parent = HueBar, CornerRadius = UDim.new(1, 0) })
	New("UIGradient", {
		Parent = HueBar,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(1 / 6, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(2 / 6, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(3 / 6, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(4 / 6, Color3.fromRGB(0, 0, 255)),
			ColorSequenceKeypoint.new(5 / 6, Color3.fromRGB(255, 0, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
		}),
		Rotation = 0,
	})
	local HueCursor = New("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1),
		Size = UDim2.new(0, 4, 1, 4),
		Position = UDim2.new(Hue, -2, 0.5, -10),
		ZIndex = 10,
		Parent = HueBar,
	})
	New("UICorner", { Parent = HueCursor, CornerRadius = UDim.new(1, 0) })
	New("UIStroke", {
		Parent = HueCursor,
		Color = Color3.new(0, 0, 0),
		Thickness = 1.5,
	})
	local HexBox = New("TextBox", {
		BackgroundColor3 = Library.Scheme.BackgroundColor,
		BackgroundTransparency = 0.3,
		Size = UDim2.fromOffset(110, 26),
		Position = UDim2.new(0, 0, 0, 144),
		Text = string.format("#%02X%02X%02X", Color.R * 255, Color.G * 255, Color.B * 255),
		Font = Library.Scheme.Font,
		TextSize = 12,
		TextColor3 = Library.Scheme.AccentColor,
		TextXAlignment = Enum.TextXAlignment.Center,
		ClearTextOnFocus = false,
		ZIndex = 8,
		Parent = Panel,
	})
	New("UICorner", { Parent = HexBox, CornerRadius = UDim.new(0, 6) })
	New("UIStroke", {
		Parent = HexBox,
		Color = Library.Scheme.OutlineColor,
		Thickness = 1,
		Transparency = 0.5,
	})
	local RGBLabel = New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -120, 0, 26),
		Position = UDim2.new(0, 120, 0, 144),
		Text = string.format("%d, %d, %d", Color.R * 255, Color.G * 255, Color.B * 255),
		Font = Library.Scheme.Font,
		TextSize = 11,
		TextColor3 = Library.Scheme.OutlineColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 8,
		Parent = Panel,
	})
	local function UpdateColor(FireCallback)
		Color = Color3.fromHSV(Hue, Sat, Val)
		Swatch.BackgroundColor3 = Color
		SVFrame.BackgroundColor3 = Color3.fromHSV(Hue, 1, 1)
		HexBox.Text = string.format("#%02X%02X%02X", Color.R * 255, Color.G * 255, Color.B * 255)
		RGBLabel.Text = string.format("%d, %d, %d", Color.R * 255, Color.G * 255, Color.B * 255)
		if FireCallback then
			Library:SafeCallback(Options.Callback, Color)
			Library:SafeCallback(Options.Changed, Color)
		end
	end
	local function TrackDrag(Frame, OnMove)
		local DragStart = false
		local ActiveInput
		Library:GiveSignal(Frame.InputBegan:Connect(function(Input)
			if not IsClickInput(Input) then return end
			DragStart = true
			ActiveInput = Input
			OnMove(Input.Position)
			Input.Changed:Connect(function()
				if Input.UserInputState == Enum.UserInputState.End then
					DragStart = false
					ActiveInput = nil
				end
			end)
		end))
		Library:GiveSignal(UserInputService.InputChanged:Connect(function(Input)
			if DragStart and ActiveInput and IsHoverInput(Input) then
				OnMove(Input.Position)
			end
		end))
	end
	TrackDrag(SVFrame, function(Pos)
		local RelX = math.clamp((Pos.X - SVFrame.AbsolutePosition.X) / SVFrame.AbsoluteSize.X, 0, 1)
		local RelY = math.clamp((Pos.Y - SVFrame.AbsolutePosition.Y) / SVFrame.AbsoluteSize.Y, 0, 1)
		Sat = RelX
		Val = 1 - RelY
		Cursor.Position = UDim2.new(Sat, -6, 1 - Val, -6)
		UpdateColor(true)
	end)
	TrackDrag(HueBar, function(Pos)
		Hue = math.clamp((Pos.X - HueBar.AbsolutePosition.X) / HueBar.AbsoluteSize.X, 0, 1)
		HueCursor.Position = UDim2.new(Hue, -2, 0.5, -10)
		UpdateColor(true)
	end)
	Library:GiveSignal(HexBox.FocusLost:Connect(function()
		local Hex = HexBox.Text:gsub("#", "")
		local R = tonumber(Hex:sub(1, 2), 16)
		local G = tonumber(Hex:sub(3, 4), 16)
		local B = tonumber(Hex:sub(5, 6), 16)
		if R and G and B then
			Color = Color3.fromRGB(R, G, B)
			Hue, Sat, Val = Color:ToHSV()
			Swatch.BackgroundColor3 = Color
			SVFrame.BackgroundColor3 = Color3.fromHSV(Hue, 1, 1)
			Cursor.Position = UDim2.new(Sat, -6, 1 - Val, -6)
			HueCursor.Position = UDim2.new(Hue, -2, 0.5, -10)
			UpdateColor(true)
		else
			UpdateColor(false)
		end
	end))
	Library:GiveSignal(Header.MouseButton1Click:Connect(function()
		Expanded = not Expanded
		local TargetHeight = (Library.IsMobile and 48 or 42) + (Expanded and PanelHeight + 8 or 0)
		TweenService:Create(Holder, Library.SpringInfo, { Size = UDim2.new(1, 0, 0, TargetHeight) }):Play()
		TweenService:Create(HolderStroke, Library.HoverInfo, {
			Color = Expanded and Library.Scheme.AccentColor or Library.Scheme.OutlineColor,
			Transparency = Expanded and 0.2 or 0.65,
		}):Play()
	end))
	local Element = {
		Type = "ColorPicker",
		Holder = Holder,
		Text = Options.Text,
		Visible = true,
		Get = function() return Color end,
		Set = function(_, NewColor)
			Color = NewColor
			Hue, Sat, Val = NewColor:ToHSV()
			Swatch.BackgroundColor3 = NewColor
			SVFrame.BackgroundColor3 = Color3.fromHSV(Hue, 1, 1)
			Cursor.Position = UDim2.new(Sat, -6, 1 - Val, -6)
			HueCursor.Position = UDim2.new(Hue, -2, 0.5, -10)
			HexBox.Text = string.format("#%02X%02X%02X", NewColor.R * 255, NewColor.G * 255, NewColor.B * 255)
		end,
		Destroy = function()
			Holder:Destroy()
		end,
	}
	table.insert(self.Elements, Element)
	table.insert(Library.Options, Element)
	return Element
end
Library.Groupbox = Groupbox
function Groupbox:AddColorPicker(Options)
	Options = Options or {}
	local Color = Options.Default or Color3.fromRGB(125, 145, 255)
	local H, S, V = Color:ToHSV()
	local Hue = H
	local Sat = S
	local Val = V
	local Expanded = false
	local PanelHeight = Library.IsMobile and 220 or 200
	local Holder = New("Frame", {
		Name = "ColorPicker_" .. (Options.Text or "Color"),
		BackgroundColor3 = Library.Scheme.SurfaceAlt,
		BackgroundTransparency = 0.4,
		Size = UDim2.new(1, 0, 0, Library.IsMobile and 48 or 42),
		ClipsDescendants = true,
		ZIndex = 6,
		Parent = self.Content,
	})
	New("UICorner", { Parent = Holder, CornerRadius = UDim.new(0, 10) })
	local HolderStroke = New("UIStroke", {
		Parent = Holder,
		Color = Library.Scheme.OutlineColor,
		Thickness = 1,
		Transparency = 0.65,
	})
	local Header = New("TextButton", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, Library.IsMobile and 48 or 42),
		Text = "",
		AutoButtonColor = false,
		ZIndex = 7,
		Parent = Holder,
	})
	New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0.6, -20, 1, 0),
		Position = UDim2.new(0, 16, 0, 0),
		Text = Options.Text or "Color",
		Font = Library.Scheme.Font,
		TextSize = 13,
		TextColor3 = Library.Scheme.FontColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 8,
		Parent = Header,
	})
	local Swatch = New("Frame", {
		BackgroundColor3 = Color,
		Size = UDim2.fromOffset(48, 24),
		Position = UDim2.new(1, -60, 0.5, -12),
		ZIndex = 8,
		Parent = Header,
	})
	New("UICorner", { Parent = Swatch, CornerRadius = UDim.new(0, 6) })
	New("UIStroke", {
		Parent = Swatch,
		Color = Library.Scheme.OutlineColor,
		Thickness = 1,
		Transparency = 0.4,
	})
	local Panel = New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -24, 0, PanelHeight),
		Position = UDim2.new(0, 12, 0, Library.IsMobile and 52 or 46),
		ZIndex = 7,
		Parent = Holder,
	})
	local SVFrame = New("Frame", {
		BackgroundColor3 = Color3.fromHSV(Hue, 1, 1),
		Size = UDim2.new(1, 0, 0, 110),
		ZIndex = 8,
		Parent = Panel,
	})
	New("UICorner", { Parent = SVFrame, CornerRadius = UDim.new(0, 8) })
	New("UIGradient", {
		Parent = SVFrame,
		Color = ColorSequence.new(Color3.new(1, 1, 1)),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 1),
		}),
		Rotation = 0,
	})
	local SVBlack = New("Frame", {
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 8,
		Parent = SVFrame,
	})
	New("UICorner", { Parent = SVBlack, CornerRadius = UDim.new(0, 8) })
	local SVBlackGrad = New("UIGradient", {
		Parent = SVBlack,
		Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.new(0, 0, 0)),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(1, 0),
		}),
		Rotation = 90,
	})
	local Cursor = New("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1),
		Size = UDim2.fromOffset(12, 12),
		Position = UDim2.new(Sat, -6, 1 - Val, -6),
		ZIndex = 10,
		Parent = SVFrame,
	})
	New("UICorner", { Parent = Cursor, CornerRadius = UDim.new(1, 0) })
	New("UIStroke", {
		Parent = Cursor,
		Color = Color3.new(0, 0, 0),
		Thickness = 2,
	})
	local HueBar = New("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1),
		Size = UDim2.new(1, 0, 0, 16),
		Position = UDim2.new(0, 0, 0, 120),
		ZIndex = 8,
		Parent = Panel,
	})
	New("UICorner", { Parent = HueBar, CornerRadius = UDim.new(1, 0) })
	New("UIGradient", {
		Parent = HueBar,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(1 / 6, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(2 / 6, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(3 / 6, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(4 / 6, Color3.fromRGB(0, 0, 255)),
			ColorSequenceKeypoint.new(5 / 6, Color3.fromRGB(255, 0, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
		}),
		Rotation = 0,
	})
	local HueCursor = New("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1),
		Size = UDim2.new(0, 4, 1, 4),
		Position = UDim2.new(Hue, -2, 0.5, -10),
		ZIndex = 10,
		Parent = HueBar,
	})
	New("UICorner", { Parent = HueCursor, CornerRadius = UDim.new(1, 0) })
	New("UIStroke", {
		Parent = HueCursor,
		Color = Color3.new(0, 0, 0),
		Thickness = 1.5,
	})
	local HexBox = New("TextBox", {
		BackgroundColor3 = Library.Scheme.BackgroundColor,
		BackgroundTransparency = 0.3,
		Size = UDim2.fromOffset(110, 26),
		Position = UDim2.new(0, 0, 0, 144),
		Text = string.format("#%02X%02X%02X", Color.R * 255, Color.G * 255, Color.B * 255),
		Font = Library.Scheme.Font,
		TextSize = 12,
		TextColor3 = Library.Scheme.AccentColor,
		TextXAlignment = Enum.TextXAlignment.Center,
		ClearTextOnFocus = false,
		ZIndex = 8,
		Parent = Panel,
	})
	New("UICorner", { Parent = HexBox, CornerRadius = UDim.new(0, 6) })
	New("UIStroke", {
		Parent = HexBox,
		Color = Library.Scheme.OutlineColor,
		Thickness = 1,
		Transparency = 0.5,
	})
	local RGBLabel = New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -120, 0, 26),
		Position = UDim2.new(0, 120, 0, 144),
		Text = string.format("%d, %d, %d", Color.R * 255, Color.G * 255, Color.B * 255),
		Font = Library.Scheme.Font,
		TextSize = 11,
		TextColor3 = Library.Scheme.OutlineColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 8,
		Parent = Panel,
	})
	local function UpdateColor(FireCallback)
		Color = Color3.fromHSV(Hue, Sat, Val)
		Swatch.BackgroundColor3 = Color
		SVFrame.BackgroundColor3 = Color3.fromHSV(Hue, 1, 1)
		HexBox.Text = string.format("#%02X%02X%02X", Color.R * 255, Color.G * 255, Color.B * 255)
		RGBLabel.Text = string.format("%d, %d, %d", Color.R * 255, Color.G * 255, Color.B * 255)
		if FireCallback then
			Library:SafeCallback(Options.Callback, Color)
			Library:SafeCallback(Options.Changed, Color)
		end
	end
	local function TrackDrag(Frame, OnMove)
		local DragStart = false
		local ActiveInput
		Library:GiveSignal(Frame.InputBegan:Connect(function(Input)
			if not IsClickInput(Input) then return end
			DragStart = true
			ActiveInput = Input
			OnMove(Input.Position)
			Input.Changed:Connect(function()
				if Input.UserInputState == Enum.UserInputState.End then
					DragStart = false
					ActiveInput = nil
				end
			end)
		end))
		Library:GiveSignal(UserInputService.InputChanged:Connect(function(Input)
			if DragStart and ActiveInput and IsHoverInput(Input) then
				OnMove(Input.Position)
			end
		end))
	end
	TrackDrag(SVFrame, function(Pos)
		local RelX = math.clamp((Pos.X - SVFrame.AbsolutePosition.X) / SVFrame.AbsoluteSize.X, 0, 1)
		local RelY = math.clamp((Pos.Y - SVFrame.AbsolutePosition.Y) / SVFrame.AbsoluteSize.Y, 0, 1)
		Sat = RelX
		Val = 1 - RelY
		Cursor.Position = UDim2.new(Sat, -6, 1 - Val, -6)
		UpdateColor(true)
	end)
	TrackDrag(HueBar, function(Pos)
		Hue = math.clamp((Pos.X - HueBar.AbsolutePosition.X) / HueBar.AbsoluteSize.X, 0, 1)
		HueCursor.Position = UDim2.new(Hue, -2, 0.5, -10)
		UpdateColor(true)
	end)
	Library:GiveSignal(HexBox.FocusLost:Connect(function()
		local Hex = HexBox.Text:gsub("#", "")
		local R = tonumber(Hex:sub(1, 2), 16)
		local G = tonumber(Hex:sub(3, 4), 16)
		local B = tonumber(Hex:sub(5, 6), 16)
		if R and G and B then
			Color = Color3.fromRGB(R, G, B)
			Hue, Sat, Val = Color:ToHSV()
			Swatch.BackgroundColor3 = Color
			SVFrame.BackgroundColor3 = Color3.fromHSV(Hue, 1, 1)
			Cursor.Position = UDim2.new(Sat, -6, 1 - Val, -6)
			HueCursor.Position = UDim2.new(Hue, -2, 0.5, -10)
			UpdateColor(true)
		else
			UpdateColor(false)
		end
	end))
	Library:GiveSignal(Header.MouseButton1Click:Connect(function()
		Expanded = not Expanded
		local TargetHeight = (Library.IsMobile and 48 or 42) + (Expanded and PanelHeight + 8 or 0)
		TweenService:Create(Holder, Library.SpringInfo, { Size = UDim2.new(1, 0, 0, TargetHeight) }):Play()
		TweenService:Create(HolderStroke, Library.HoverInfo, {
			Color = Expanded and Library.Scheme.AccentColor or Library.Scheme.OutlineColor,
			Transparency = Expanded and 0.2 or 0.65,
		}):Play()
	end))
	local Element = {
		Type = "ColorPicker",
		Holder = Holder,
		Text = Options.Text,
		Visible = true,
		Get = function() return Color end,
		Set = function(_, NewColor)
			Color = NewColor
			Hue, Sat, Val = NewColor:ToHSV()
			Swatch.BackgroundColor3 = NewColor
			SVFrame.BackgroundColor3 = Color3.fromHSV(Hue, 1, 1)
			Cursor.Position = UDim2.new(Sat, -6, 1 - Val, -6)
			HueCursor.Position = UDim2.new(Hue, -2, 0.5, -10)
			HexBox.Text = string.format("#%02X%02X%02X", NewColor.R * 255, NewColor.G * 255, NewColor.B * 255)
		end,
		Destroy = function()
			Holder:Destroy()
		end,
	}
	table.insert(self.Elements, Element)
	table.insert(Library.Options, Element)
	return Element
end
Library.Groupbox = Groupbox
local Dialog = {}
Dialog.__index = Dialog
function Library:CreateDialog(Options)
	Options = Options or {}
	local self = setmetatable({}, Dialog)
	self.Title = Options.Title or "Dialog"
	self.Description = Options.Description or ""
	self.AutoDismiss = Options.AutoDismiss ~= false
	self.OutsideClickDismiss = Options.OutsideClickDismiss ~= false
	self.FooterButtons = Options.FooterButtons or {}
	self.Closed = false
	local Blocker = New("TextButton", {
		Name = "DialogBlocker",
		BackgroundColor3 = Library.Scheme.DarkColor,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Text = "",
		AutoButtonColor = false,
		ZIndex = 300,
		Parent = Library.ScreenGui,
	})
	self.Blocker = Blocker
	local Frame = New("Frame", {
		Name = "Dialog",
		BackgroundColor3 = Library.Scheme.MainColor,
		BackgroundTransparency = 0.05,
		Size = UDim2.fromOffset(400, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Position = UDim2.new(0.5, -200, 0.5, -100),
		ZIndex = 301,
		Parent = Blocker,
	})
	self.Frame = Frame
	Library:AddGlassEffect(Frame, { CornerRadius = 20, Transparency = 0.05 })
	Library:AddMultiLayerShadow(Frame, {
		Color = Library.Scheme.DarkColor,
		CornerRadius = 20,
	})
	Library:AddGlowStroke(Frame)
	New("UIPadding", {
		Parent = Frame,
		PaddingTop = UDim.new(0, 20),
		PaddingBottom = UDim.new(0, 20),
		PaddingLeft = UDim.new(0, 22),
		PaddingRight = UDim.new(0, 22),
	})
	New("UIListLayout", {
		Parent = Frame,
		Padding = UDim.new(0, 12),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	local TitleLabel = New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 24),
		Text = self.Title,
		Font = Library.Scheme.Font,
		TextSize = 16,
		TextColor3 = Library.Scheme.FontColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 302,
		Parent = Frame,
	})
	local DescLabel = New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = self.Description,
		Font = Library.Scheme.Font,
		TextSize = 13,
		TextColor3 = Library.Scheme.OutlineColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		ZIndex = 302,
		Parent = Frame,
	})
	if #self.FooterButtons > 0 then
		local BtnHolder = New("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 40),
			ZIndex = 302,
			Parent = Frame,
		})
		New("UIListLayout", {
			Parent = BtnHolder,
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 8),
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			SortOrder = Enum.SortOrder.LayoutOrder,
		})
		for _, btnData in ipairs(self.FooterButtons) do
			local Btn = New("TextButton", {
				BackgroundColor3 = btnData.Color or Library.Scheme.SurfaceAlt,
				BackgroundTransparency = 0.2,
				Size = UDim2.fromOffset(100, 36),
				Text = btnData.Title or "Button",
				Font = Library.Scheme.Font,
				TextSize = 13,
				TextColor3 = Library.Scheme.FontColor,
				AutoButtonColor = false,
				ZIndex = 303,
				Parent = BtnHolder,
			})
			New("UICorner", { Parent = Btn, CornerRadius = UDim.new(0, 10) })
			New("UIStroke", {
				Parent = Btn,
				Color = Library.Scheme.OutlineColor,
				Thickness = 1,
				Transparency = 0.5,
			})
			Library:GiveSignal(Btn.MouseEnter:Connect(function()
				TweenService:Create(Btn, Library.HoverInfo, { BackgroundTransparency = 0 }):Play()
			end))
			Library:GiveSignal(Btn.MouseLeave:Connect(function()
				TweenService:Create(Btn, Library.HoverInfo, { BackgroundTransparency = 0.2 }):Play()
			end))
			Library:GiveSignal(Btn.MouseButton1Click:Connect(function()
				Library:Pulse(Btn, 0.94, 1)
				Library:SafeCallback(btnData.Callback)
				if btnData.Dismiss ~= false then
					self:Close()
				end
			end))
		end
	end
	Blocker.BackgroundTransparency = 1
	TweenService:Create(Blocker, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.5,
	}):Play()
	Frame.Size = UDim2.fromOffset(400, 0)
	Frame.Position = UDim2.new(0.5, -200, 0.5, -80)
	local TargetY = -Frame.AbsoluteSize.Y / 2
	Frame.Position = UDim2.new(0.5, -200, 0.5, -100)
	local UIScale = New("UIScale", { Parent = Frame, Scale = 0.85 })
	TweenService:Create(UIScale, Library.SpringInfo, { Scale = 1 }):Play()
	if self.OutsideClickDismiss then
		Library:GiveSignal(Blocker.MouseButton1Click:Connect(function()
			self:Close()
		end))
	end
	table.insert(Library.Dialogues, self)
	Library.ActiveDialog = self
	return self
end
function Dialog:Close()
	if self.Closed then return end
	self.Closed = true
	local UIScale = self.Frame:FindFirstChildOfClass("UIScale")
	if UIScale then
		TweenService:Create(UIScale, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { Scale = 0.85 }):Play()
	end
	TweenService:Create(self.Blocker, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
		BackgroundTransparency = 1,
	}):Play()
	task.wait(0.3)
	self.Blocker:Destroy()
	local Idx = table.find(Library.Dialogues, self)
	if Idx then table.remove(Library.Dialogues, Idx) end
	if Library.ActiveDialog == self then
		Library.ActiveDialog = Library.Dialogues[#Library.Dialogues]
	end
end
Library.Dialog = Dialog
local Loading = {}
Loading.__index = Loading
function Library:CreateLoading(Options)
	Options = Options or {}
	local self = setmetatable({}, Loading)
	self.Title = Options.Title or "Đang tải..."
	self.Text = Options.Text or ""
	self.Steps = Options.Steps or 5
	self.CurrentStep = 0
	self.Closed = false
	local Blocker = New("TextButton", {
		Name = "LoadingBlocker",
		BackgroundColor3 = Library.Scheme.DarkColor,
		BackgroundTransparency = 0.4,
		Size = UDim2.fromScale(1, 1),
		Text = "",
		AutoButtonColor = false,
		ZIndex = 400,
		Parent = Library.ScreenGui,
	})
	self.Blocker = Blocker
	local Frame = New("Frame", {
		Name = "Loading",
		BackgroundColor3 = Library.Scheme.MainColor,
		BackgroundTransparency = 0.05,
		Size = UDim2.fromOffset(340, 180),
		Position = UDim2.new(0.5, -170, 0.5, -90),
		ZIndex = 401,
		Parent = Blocker,
	})
	self.Frame = Frame
	Library:AddGlassEffect(Frame, { CornerRadius = 20, Transparency = 0.05 })
	Library:AddMultiLayerShadow(Frame, {
		Color = Library.Scheme.DarkColor,
		CornerRadius = 20,
	})
	Library:AddGlowStroke(Frame)
	New("UIPadding", {
		Parent = Frame,
		PaddingTop = UDim.new(0, 24),
		PaddingBottom = UDim.new(0, 24),
		PaddingLeft = UDim.new(0, 24),
		PaddingRight = UDim.new(0, 24),
	})
	local SpinnerHolder = New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(48, 48),
		Position = UDim2.new(0.5, -24, 0, 0),
		ZIndex = 402,
		Parent = Frame,
	})
	local SpinnerImg = New("ImageLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Image = CustomImageManager.GetAsset("LoadingIcon"),
		ImageColor3 = Library.Scheme.AccentColor,
		ZIndex = 403,
		Parent = SpinnerHolder,
	})
	local SpinConnection = RunService.RenderStepped:Connect(function()
		if self.Closed then return end
		SpinnerImg.Rotation = (SpinnerImg.Rotation + 6) % 360
	end)
	self.SpinConnection = SpinConnection
	local TitleLabel = New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 22),
		Position = UDim2.new(0, 0, 0, 60),
		Text = self.Title,
		Font = Library.Scheme.Font,
		TextSize = 15,
		TextColor3 = Library.Scheme.FontColor,
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 402,
		Parent = Frame,
	})
	local TextLabel = New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		Position = UDim2.new(0, 0, 0, 84),
		Text = self.Text,
		Font = Library.Scheme.Font,
		TextSize = 12,
		TextColor3 = Library.Scheme.OutlineColor,
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 402,
		Parent = Frame,
	})
	local ProgressTrack = New("Frame", {
		BackgroundColor3 = Library.Scheme.BackgroundColor,
		BackgroundTransparency = 0.4,
		Size = UDim2.new(1, 0, 0, 6),
		Position = UDim2.new(0, 0, 1, -6),
		ZIndex = 402,
		Parent = Frame,
	})
	New("UICorner", { Parent = ProgressTrack, CornerRadius = UDim.new(1, 0) })
	local ProgressFill = New("Frame", {
		BackgroundColor3 = Library.Scheme.AccentColor,
		Size = UDim2.new(0, 0, 1, 0),
		ZIndex = 403,
		Parent = ProgressTrack,
	})
	New("UICorner", { Parent = ProgressFill, CornerRadius = UDim.new(1, 0) })
	New("UIGradient", {
		Parent = ProgressFill,
		Color = ColorSequence.new(Library.Scheme.AccentColor, Library.Scheme.AccentGlow),
	})
	self.ProgressFill = ProgressFill
	self.TitleLabel = TitleLabel
	self.TextLabel = TextLabel
	Frame.Size = UDim2.fromOffset(0, 0)
	local UIScale = New("UIScale", { Parent = Frame, Scale = 0.85 })
	TweenService:Create(UIScale, Library.SpringInfo, { Scale = 1 }):Play()
	TweenService:Create(Frame, Library.SpringInfo, { Size = UDim2.fromOffset(340, 180) }):Play()
	table.insert(Library.ContextMenus, self)
	Library.ActiveLoading = self
	return self
end
function Loading:SetStep(Current, Total)
	Current = Current or self.CurrentStep + 1
	Total = Total or self.Steps
	self.CurrentStep = Current
	self.Steps = Total
	local Alpha = math.clamp(Current / Total, 0, 1)
	TweenService:Create(self.ProgressFill, Library.SpringInfo, { Size = UDim2.new(Alpha, 0, 1, 0) }):Play()
end
function Loading:SetText(Text)
	self.Text = Text
	self.TextLabel.Text = Text
end
function Loading:SetTitle(Title)
	self.Title = Title
	self.TitleLabel.Text = Title
end
function Loading:Close()
	if self.Closed then return end
	self.Closed = true
	if self.SpinConnection then self.SpinConnection:Disconnect() end
	local UIScale = self.Frame:FindFirstChildOfClass("UIScale")
	if UIScale then
		TweenService:Create(UIScale, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { Scale = 0.85 }):Play()
	end
	TweenService:Create(self.Frame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
		Size = UDim2.fromOffset(0, 0),
	}):Play()
	TweenService:Create(self.Blocker, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
		BackgroundTransparency = 1,
	}):Play()
	task.wait(0.35)
	self.Blocker:Destroy()
	local Idx = table.find(Library.ContextMenus, self)
	if Idx then table.remove(Library.ContextMenus, Idx) end
	if Library.ActiveLoading == self then
		Library.ActiveLoading = nil
	end
end
Library.Loading = Loading
local ContextMenu = {}
ContextMenu.__index = ContextMenu
function Library:CreateContextMenu(Target, Options)
	Options = Options or {}
	local self = setmetatable({}, ContextMenu)
	self.Target = Target
	self.Options = Options
	self.Items = Options.Items or {}
	local Menu = New("Frame", {
		Name = "ContextMenu",
		BackgroundColor3 = Library.Scheme.MainColor,
		BackgroundTransparency = 0.05,
		Size = UDim2.fromOffset(180, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Position = UDim2.fromOffset(0, 0),
		Visible = false,
		ZIndex = 500,
		Parent = Library.ScreenGui,
	})
	self.Menu = Menu
	Library:AddGlassEffect(Menu, { CornerRadius = 14, Transparency = 0.05 })
	Library:AddMultiLayerShadow(Menu, {
		Color = Library.Scheme.DarkColor,
		CornerRadius = 14,
		Layers = {
			{ Offset = 8, Transparency = 0.85, Expand = 20 },
			{ Offset = 4, Transparency = 0.7, Expand = 10 },
		},
	})
	New("UIPadding", {
		Parent = Menu,
		PaddingTop = UDim.new(0, 6),
		PaddingBottom = UDim.new(0, 6),
		PaddingLeft = UDim.new(0, 6),
		PaddingRight = UDim.new(0, 6),
	})
	New("UIListLayout", {
		Parent = Menu,
		Padding = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	for _, item in ipairs(self.Items) do
		local ItemBtn = New("TextButton", {
			BackgroundColor3 = Library.Scheme.SurfaceAlt,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 34),
			Text = "",
			AutoButtonColor = false,
			ZIndex = 501,
			Parent = Menu,
		})
		New("UICorner", { Parent = ItemBtn, CornerRadius = UDim.new(0, 8) })
		if item.Icon then
			local IconImg = New("ImageLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(16, 16),
				Position = UDim2.new(0, 10, 0.5, -8),
				ImageColor3 = Library.Scheme.AccentColor,
				ZIndex = 502,
				Parent = ItemBtn,
			})
			local IconData = Library:GetCustomIcon(item.Icon)
			if IconData then Library:ApplyLucideIcon(IconImg, IconData) end
		end
		New("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -40, 1, 0),
			Position = UDim2.new(0, item.Icon and 34 or 12, 0, 0),
			Text = item.Title or "Item",
			Font = Library.Scheme.Font,
			TextSize = 12,
			TextColor3 = Library.Scheme.FontColor,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 502,
			Parent = ItemBtn,
		})
		Library:GiveSignal(ItemBtn.MouseEnter:Connect(function()
			TweenService:Create(ItemBtn, Library.HoverInfo, {
				BackgroundTransparency = 0.5,
				BackgroundColor3 = Library.Scheme.AccentColor,
			}):Play()
		end))
		Library:GiveSignal(ItemBtn.MouseLeave:Connect(function()
			TweenService:Create(ItemBtn, Library.HoverInfo, {
				BackgroundTransparency = 1,
				BackgroundColor3 = Library.Scheme.SurfaceAlt,
			}):Play()
		end))
		Library:GiveSignal(ItemBtn.MouseButton1Click:Connect(function()
			self:Close()
			Library:SafeCallback(item.Callback)
		end))
	end
	local HoldTime = 0.4
	local HoldTimer = nil
	local MousePos = nil
	Library:GiveSignal(Target.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton2 or Input.UserInputType == Enum.UserInputType.Touch then
			MousePos = Input.Position
			if Input.UserInputType == Enum.UserInputType.Touch then
				HoldTimer = task.delay(HoldTime, function()
					if MousePos then
						self:Show(MousePos)
					end
				end)
			else
				self:Show(MousePos)
			end
		end
	end))
	Library:GiveSignal(Target.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.Touch then
			if HoldTimer then
				task.cancel(HoldTimer)
				HoldTimer = nil
			end
			MousePos = nil
		end
	end))
	Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input, GPE)
		if GPE then return end
		if Menu.Visible and Input.UserInputType == Enum.UserInputType.MouseButton1 then
			local MouseLoc = UserInputService:GetMouseLocation()
			if not Library:MouseIsOverFrame(Menu, MouseLoc) then
				self:Close()
			end
		end
	end))
	table.insert(Library.ContextMenus, self)
	return self
end
function ContextMenu:Show(Position)
	self.Menu.Visible = true
	self.Menu.Position = UDim2.fromOffset(Position.X, Position.Y)
	local UIScale = self.Menu:FindFirstChildOfClass("UIScale") or New("UIScale", { Parent = self.Menu, Scale = 0.85 })
	UIScale.Scale = 0.85
	TweenService:Create(UIScale, Library.SpringInfo, { Scale = 1 }):Play()
end
function ContextMenu:Close()
	self.Menu.Visible = false
end
Library.ContextMenu = ContextMenu
local Loading = {}
Loading.__index = Loading
function Library:CreateLoading(Options)
	Options = Options or {}
	local self = setmetatable({}, Loading)
	self.Title = Options.Title or "Đang tải..."
	self.Text = Options.Text or ""
	self.Steps = Options.Steps or 5
	self.CurrentStep = 0
	self.Closed = false
	local Blocker = New("TextButton", {
		Name = "LoadingBlocker",
		BackgroundColor3 = Library.Scheme.DarkColor,
		BackgroundTransparency = 0.4,
		Size = UDim2.fromScale(1, 1),
		Text = "",
		AutoButtonColor = false,
		ZIndex = 400,
		Parent = Library.ScreenGui,
	})
	self.Blocker = Blocker
	local Frame = New("Frame", {
		Name = "Loading",
		BackgroundColor3 = Library.Scheme.MainColor,
		BackgroundTransparency = 0.05,
		Size = UDim2.fromOffset(0, 0),
		Position = UDim2.new(0.5, -170, 0.5, -90),
		ZIndex = 401,
		Parent = Blocker,
	})
	self.Frame = Frame
	Library:AddGlassEffect(Frame, { CornerRadius = 20, Transparency = 0.05 })
	Library:AddMultiLayerShadow(Frame, {
		Color = Library.Scheme.DarkColor,
		CornerRadius = 20,
	})
	Library:AddGlowStroke(Frame)
	New("UIPadding", {
		Parent = Frame,
		PaddingTop = UDim.new(0, 24),
		PaddingBottom = UDim.new(0, 24),
		PaddingLeft = UDim.new(0, 24),
		PaddingRight = UDim.new(0, 24),
	})
	local SpinnerHolder = New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(48, 48),
		Position = UDim2.new(0.5, -24, 0, 0),
		ZIndex = 402,
		Parent = Frame,
	})
	local SpinnerImg = New("ImageLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Image = CustomImageManager.GetAsset("LoadingIcon"),
		ImageColor3 = Library.Scheme.AccentColor,
		ZIndex = 403,
		Parent = SpinnerHolder,
	})
	self.SpinConnection = RunService.RenderStepped:Connect(function()
		if self.Closed then return end
		SpinnerImg.Rotation = (SpinnerImg.Rotation + 6) % 360
	end)
	local TitleLabel = New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 22),
		Position = UDim2.new(0, 0, 0, 60),
		Text = self.Title,
		Font = Library.Scheme.Font,
		TextSize = 15,
		TextColor3 = Library.Scheme.FontColor,
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 402,
		Parent = Frame,
	})
	local TextLabel = New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		Position = UDim2.new(0, 0, 0, 84),
		Text = self.Text,
		Font = Library.Scheme.Font,
		TextSize = 12,
		TextColor3 = Library.Scheme.OutlineColor,
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 402,
		Parent = Frame,
	})
	local ProgressTrack = New("Frame", {
		BackgroundColor3 = Library.Scheme.BackgroundColor,
		BackgroundTransparency = 0.4,
		Size = UDim2.new(1, 0, 0, 6),
		Position = UDim2.new(0, 0, 1, -6),
		ZIndex = 402,
		Parent = Frame,
	})
	New("UICorner", { Parent = ProgressTrack, CornerRadius = UDim.new(1, 0) })
	local ProgressFill = New("Frame", {
		BackgroundColor3 = Library.Scheme.AccentColor,
		Size = UDim2.new(0, 0, 1, 0),
		ZIndex = 403,
		Parent = ProgressTrack,
	})
	New("UICorner", { Parent = ProgressFill, CornerRadius = UDim.new(1, 0) })
	New("UIGradient", {
		Parent = ProgressFill,
		Color = ColorSequence.new(Library.Scheme.AccentColor, Library.Scheme.AccentGlow),
	})
	self.ProgressFill = ProgressFill
	self.TitleLabel = TitleLabel
	self.TextLabel = TextLabel
	local UIScale = New("UIScale", { Parent = Frame, Scale = 0.85 })
	TweenService:Create(UIScale, Library.SpringInfo, { Scale = 1 }):Play()
	TweenService:Create(Frame, Library.SpringInfo, { Size = UDim2.fromOffset(340, 180) }):Play()
	table.insert(Library.ContextMenus, self)
	Library.ActiveLoading = self
	return self
end
function Loading:SetStep(Current, Total)
	Current = Current or self.CurrentStep + 1
	Total = Total or self.Steps
	self.CurrentStep = Current
	self.Steps = Total
	local Alpha = math.clamp(Current / Total, 0, 1)
	TweenService:Create(self.ProgressFill, Library.SpringInfo, { Size = UDim2.new(Alpha, 0, 1, 0) }):Play()
end
function Loading:SetText(Text)
	self.Text = Text
	self.TextLabel.Text = Text
end
function Loading:SetTitle(Title)
	self.Title = Title
	self.TitleLabel.Text = Title
end
function Loading:Close()
	if self.Closed then return end
	self.Closed = true
	if self.SpinConnection then self.SpinConnection:Disconnect() end
	local UIScale = self.Frame:FindFirstChildOfClass("UIScale")
	if UIScale then
		TweenService:Create(UIScale, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { Scale = 0.85 }):Play()
	end
	TweenService:Create(self.Frame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
		Size = UDim2.fromOffset(0, 0),
	}):Play()
	TweenService:Create(self.Blocker, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
		BackgroundTransparency = 1,
	}):Play()
	task.wait(0.35)
	self.Blocker:Destroy()
	local Idx = table.find(Library.ContextMenus, self)
	if Idx then table.remove(Library.ContextMenus, Idx) end
	if Library.ActiveLoading == self then
		Library.ActiveLoading = nil
	end
end
Library.Loading = Loading
local ContextMenu = {}
ContextMenu.__index = ContextMenu
function Library:CreateContextMenu(Target, Options)
	Options = Options or {}
	local self = setmetatable({}, ContextMenu)
	self.Target = Target
	self.Options = Options
	self.Items = Options.Items or {}
	local Menu = New("Frame", {
		Name = "ContextMenu",
		BackgroundColor3 = Library.Scheme.MainColor,
		BackgroundTransparency = 0.05,
		Size = UDim2.fromOffset(180, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Position = UDim2.fromOffset(0, 0),
		Visible = false,
		ZIndex = 500,
		Parent = Library.ScreenGui,
	})
	self.Menu = Menu
	Library:AddGlassEffect(Menu, { CornerRadius = 14, Transparency = 0.05 })
	Library:AddMultiLayerShadow(Menu, {
		Color = Library.Scheme.DarkColor,
		CornerRadius = 14,
		Layers = {
			{ Offset = 8, Transparency = 0.85, Expand = 20 },
			{ Offset = 4, Transparency = 0.7, Expand = 10 },
		},
	})
	New("UIPadding", {
		Parent = Menu,
		PaddingTop = UDim.new(0, 6),
		PaddingBottom = UDim.new(0, 6),
		PaddingLeft = UDim.new(0, 6),
		PaddingRight = UDim.new(0, 6),
	})
	New("UIListLayout", {
		Parent = Menu,
		Padding = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	for _, item in ipairs(self.Items) do
		local ItemBtn = New("TextButton", {
			BackgroundColor3 = Library.Scheme.SurfaceAlt,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 34),
			Text = "",
			AutoButtonColor = false,
			ZIndex = 501,
			Parent = Menu,
		})
		New("UICorner", { Parent = ItemBtn, CornerRadius = UDim.new(0, 8) })
		if item.Icon then
			local IconImg = New("ImageLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(16, 16),
				Position = UDim2.new(0, 10, 0.5, -8),
				ImageColor3 = Library.Scheme.AccentColor,
				ZIndex = 502,
				Parent = ItemBtn,
			})
			local IconData = Library:GetCustomIcon(item.Icon)
			if IconData then Library:ApplyLucideIcon(IconImg, IconData) end
		end
		New("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -40, 1, 0),
			Position = UDim2.new(0, item.Icon and 34 or 12, 0, 0),
			Text = item.Title or "Item",
			Font = Library.Scheme.Font,
			TextSize = 12,
			TextColor3 = Library.Scheme.FontColor,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 502,
			Parent = ItemBtn,
		})
		Library:GiveSignal(ItemBtn.MouseEnter:Connect(function()
			TweenService:Create(ItemBtn, Library.HoverInfo, {
				BackgroundTransparency = 0.5,
				BackgroundColor3 = Library.Scheme.AccentColor,
			}):Play()
		end))
		Library:GiveSignal(ItemBtn.MouseLeave:Connect(function()
			TweenService:Create(ItemBtn, Library.HoverInfo, {
				BackgroundTransparency = 1,
				BackgroundColor3 = Library.Scheme.SurfaceAlt,
			}):Play()
		end))
		Library:GiveSignal(ItemBtn.MouseButton1Click:Connect(function()
			self:Close()
			Library:SafeCallback(item.Callback)
		end))
	end
	local HoldTimer = nil
	local HoldPos = nil
	Library:GiveSignal(Target.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton2 or Input.UserInputType == Enum.UserInputType.Touch then
			HoldPos = Input.Position
			if Input.UserInputType == Enum.UserInputType.Touch then
				HoldTimer = task.delay(0.4, function()
					if HoldPos then self:Show(HoldPos) end
				end)
			else
				self:Show(HoldPos)
			end
		end
	end))
	Library:GiveSignal(Target.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.Touch then
			if HoldTimer then
				task.cancel(HoldTimer)
				HoldTimer = nil
			end
			HoldPos = nil
		end
	end))
	Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input, GPE)
		if GPE then return end
		if Menu.Visible and Input.UserInputType == Enum.UserInputType.MouseButton1 then
			local MouseLoc = UserInputService:GetMouseLocation()
			if not Library:MouseIsOverFrame(Menu, MouseLoc) then
				self:Close()
			end
		end
	end))
	table.insert(Library.ContextMenus, self)
	return self
end
function ContextMenu:Show(Position)
	self.Menu.Visible = true
	self.Menu.Position = UDim2.fromOffset(Position.X, Position.Y)
	local UIScale = self.Menu:FindFirstChildOfClass("UIScale") or New("UIScale", { Parent = self.Menu, Scale = 0.85 })
	UIScale.Scale = 0.85
	TweenService:Create(UIScale, Library.SpringInfo, { Scale = 1 }):Play()
end
function ContextMenu:Close()
	self.Menu.Visible = false
end
Library.ContextMenu = ContextMenu
function Library:SaveConfig(Name)
	Name = Name or "default"
	if not writefile or not isfolder then return false end
	local ConfigFolder = "LiquidGlass/configs"
	if not isfolder("LiquidGlass") then makefolder("LiquidGlass") end
	if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
	local Data = {}
	for _, Option in ipairs(Library.Options) do
		if Option.Text and Option.Get then
			local Value = Option:Get()
			if typeof(Value) == "Color3" then
				Data[Option.Text] = { R = Value.R, G = Value.G, B = Value.B, __type = "Color3" }
			elseif typeof(Value) == "EnumItem" then
				Data[Option.Text] = { Name = Value.Name, EnumType = tostring(Value.EnumType), __type = "EnumItem" }
			elseif typeof(Value) == "table" then
				Data[Option.Text] = { Value = Value, __type = "Table" }
			else
				Data[Option.Text] = { Value = Value, __type = typeof(Value) }
			end
		end
	end
	local Success, Encoded = pcall(function()
		if HttpService and HttpService.JSONEncode then
			return HttpService:JSONEncode(Data)
		end
		return nil
	end)
	if not Success or not Encoded then return false end
	local Path = string.format("%s/%s.json", ConfigFolder, Name)
	local WriteSuccess = pcall(function()
		writefile(Path, Encoded)
	end)
	return WriteSuccess
end
function Library:LoadConfig(Name)
	Name = Name or "default"
	if not readfile or not isfile then return false end
	local Path = string.format("LiquidGlass/configs/%s.json", Name)
	if not isfile(Path) then return false end
	local Content = readfile(Path)
	local Success, Data = pcall(function()
		if HttpService and HttpService.JSONDecode then
			return HttpService:JSONDecode(Content)
		end
		return nil
	end)
	if not Success or not Data then return false end
	for _, Option in ipairs(Library.Options) do
		if Option.Text and Data[Option.Text] and Option.Set then
			local Entry = Data[Option.Text]
			local Value = Entry.Value
			if Entry.__type == "Color3" then
				Value = Color3.new(Entry.R, Entry.G, Entry.B)
			elseif Entry.__type == "EnumItem" then
				pcall(function()
					Value = Enum[Entry.EnumType][Entry.Name]
				end)
			end
			if Value ~= nil then
				Library:SafeCallback(function()
					Option:Set(Value)
				end)
			end
		end
	end
	return true
end
function Library:ListConfigs()
	if not listfiles or not isfolder then return {} end
	local Folder = "LiquidGlass/configs"
	if not isfolder(Folder) then return {} end
	local Configs = {}
	local Success = pcall(function()
		for _, File in ipairs(listfiles(Folder)) do
			local Name = File:match("([^/\\]+)%.json$")
			if Name then table.insert(Configs, Name) end
		end
	end)
	if not Success then return {} end
	return Configs
end
function Library:DeleteConfig(Name)
	if not delfile then return false end
	local Path = string.format("LiquidGlass/configs/%s.json", Name)
	if not isfile(Path) then return false end
	return pcall(function() delfile(Path) end)
end
function Library:SetTheme(SchemeTable)
	for Key, Value in SchemeTable do
		if Library.Scheme[Key] ~= nil then
			Library.Scheme[Key] = Value
		end
	end
	Library:UpdateColorsUsingRegistry()
end
function Library:SetDPI(DPI)
	Library.DPIScale = DPI / 100
	for _, UIScale in Library.Scales do
		UIScale.Scale = Library.DPIScale - (tonumber(Library.ScalesOffset[UIScale]) or 0)
	end
end
function Library:Unload()
	if Library.Unloaded then return end
	Library.Unloaded = true
	for _, Signal in Library.Signals do
		pcall(function()
			if Signal and Signal.Disconnect then
				Signal:Disconnect()
			end
		end)
	end
	Library.Signals = {}
	for _, Signal in Library.UnloadSignals do
		pcall(function()
			if Signal and Signal.Disconnect then
				Signal:Disconnect()
			end
		end)
	end
	Library.UnloadSignals = {}
	if Library.ScreenGui then
		Library.ScreenGui:Destroy()
	end
	Library.ScreenGui = nil
	Library.Floats = nil
	Library.Overlay = nil
	Library.Window = nil
	Library.WindowContainer = nil
	Library.Tabs = {}
	Library.TabButtons = {}
	Library.Options = {}
	Library.Notifications = {}
	Library.Registry = {}
	Library.Scales = {}
	Library.ScalesOffset = {}
	Library.DraggableElements = {}
	Library.Corners = {}
	Library.SpecificCorners = {}
end
function Library:AddUnloadSignal(Signal)
	if Signal then
		table.insert(Library.UnloadSignals, Signal)
	end
	return Signal
end
function Library:SetToggleKeybind(KeyCode)
	Library.ToggleKeybind = KeyCode
end
function Library:GetToggleKeybind()
	return Library.ToggleKeybind
end
function Library:SetNotifySide(Side)
	Library.NotifySide = Side
	if Library.NotificationArea then
		if Side == "Left" then
			Library.NotificationArea.AnchorPoint = Vector2.new(0, 0)
			Library.NotificationArea.Position = UDim2.new(0, 12, 0, 12)
		else
			Library.NotificationArea.AnchorPoint = Vector2.new(1, 0)
			Library.NotificationArea.Position = UDim2.new(1, -12, 0, 12)
		end
	end
end
function Library:SetHideMode(Mode)
	Library.HideMode = Mode
end
Library.LoadedAt = os.time()
Library.Version = "1.0.0"
Library:GiveSignal(UserInputService.WindowFocused:Connect(function()
	Library.IsRobloxFocused = true
end))
Library:GiveSignal(UserInputService.WindowFocusReleased:Connect(function()
	Library.IsRobloxFocused = false
end))
return Library
local LG = loadstring(readfile("LiquidGlass.lua"))()
local Window = LG:CreateWindow({ Title = "Test", Icon = "home" })
local Tab = Window:CreateTab({ Name = "Main", Icon = "home" })
local Group = Tab:AddGroupbox({ Name = "Group", Icon = "settings" })
Group:AddButton({ Text = "Click", Callback = function() LG:Notify({ Title = "OK", Text = "Clicked" }) end })
