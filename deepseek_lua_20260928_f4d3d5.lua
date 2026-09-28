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