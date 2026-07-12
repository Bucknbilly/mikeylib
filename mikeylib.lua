local UILibrary = {}
UILibrary.__index = UILibrary
local pl  = game:GetService("Players")
local ui  = game:GetService("UserInputService")
local tw  = game:GetService("TweenService")
local ss  = game:GetService("SoundService")
local db  = game:GetService("Debris")
local hs  = game:GetService("HttpService")
local lp  = pl.LocalPlayer
local cg  = game:GetService("CoreGui")
local guiParent = cg
do
	local ok = pcall(function()
		local sg = Instance.new("ScreenGui")
		sg.Parent = cg
		sg:Destroy()
	end)
	if not ok then
		guiParent = lp:WaitForChild("PlayerGui")
	end
end
local notifQueue      = {}
local notifGap        = 10
local notifBaseY      = 200
local guiCounter      = 0
local activeInstances = {}
local activeSounds    = {}
local globalFlags = {}
local discordCopied = false
local LUCIDE_ICONS = {
	["info"]="rbxassetid://7733960981",["check"]="rbxassetid://7734053495",
	["check-circle"]="rbxassetid://7734058945",["circle-check"]="rbxassetid://7734058945",
	["x"]="rbxassetid://7734101538",["x-circle"]="rbxassetid://7734104884",
	["alert-triangle"]="rbxassetid://7734107759",["triangle-alert"]="rbxassetid://7734107759",
	["circle-alert"]="rbxassetid://7734107759",["bell"]="rbxassetid://7734113874",
	["settings"]="rbxassetid://7734116951",["gear"]="rbxassetid://7734116951",
	["star"]="rbxassetid://7734120475",["heart"]="rbxassetid://7734123157",
	["home"]="rbxassetid://7734125697",["house"]="rbxassetid://7734125697",
	["search"]="rbxassetid://7734128249",["user"]="rbxassetid://7734130800",
	["users"]="rbxassetid://7734133365",["shield"]="rbxassetid://7734136151",
	["lock"]="rbxassetid://7734138712",["unlock"]="rbxassetid://7734141249",
	["eye"]="rbxassetid://7734143806",["eye-off"]="rbxassetid://7734146329",
	["sun"]="rbxassetid://7734148897",["moon"]="rbxassetid://7734151465",
	["download"]="rbxassetid://7734156583",["upload"]="rbxassetid://7734159164",
	["trash"]="rbxassetid://7734161693",["trash-2"]="rbxassetid://7734161693",
	["edit"]="rbxassetid://7734164231",["pencil"]="rbxassetid://7734164231",
	["copy"]="rbxassetid://7734166791",["link"]="rbxassetid://7734171882",
	["external-link"]="rbxassetid://7734174432",["log-out"]="rbxassetid://7734176975",
	["log-in"]="rbxassetid://7734179530",["refresh-cw"]="rbxassetid://7734182069",
	["zap"]="rbxassetid://7734187142",["flag"]="rbxassetid://7734189671",
	["globe"]="rbxassetid://7734199868",["wifi"]="rbxassetid://7734202435",
	["shield-alert"]="rbxassetid://7734296638",["wrench"]="rbxassetid://7734299178",
	["tool"]="rbxassetid://7734299178",["hammer"]="rbxassetid://7734301721",
	["terminal"]="rbxassetid://7734304262",["code"]="rbxassetid://7734306809",
	["github"]="rbxassetid://7734309347",["message-circle"]="rbxassetid://7734314443",
	["message-square"]="rbxassetid://7734317000",["mail"]="rbxassetid://7734319540",
	["send"]="rbxassetid://7734322095",["arrow-right"]="rbxassetid://7734332292",
	["arrow-left"]="rbxassetid://7734329743",["arrow-up"]="rbxassetid://7734324641",
	["arrow-down"]="rbxassetid://7734327198",["chevron-up"]="rbxassetid://7734334843",
	["chevron-down"]="rbxassetid://7734337381",["chevron-left"]="rbxassetid://7734339933",
	["chevron-right"]="rbxassetid://7734342477",["plus"]="rbxassetid://7734345023",
	["minus"]="rbxassetid://7734347566",["wind"]="rbxassetid://7734352651",
	["flame"]="rbxassetid://7734355197",["layers"]="rbxassetid://7734362833",
	["grid"]="rbxassetid://7734365380",["move"]="rbxassetid://7734378104",
	["power"]="rbxassetid://7734390838",["clock"]="rbxassetid://7734418829",
	["calendar"]="rbxassetid://7734423927",["warehouse"]="rbxassetid://7734426469",
	["boxes"]="rbxassetid://7734429012",["badge-info"]="rbxassetid://7734431558",
	["crown"]="rbxassetid://7734411198",["gamepad"]="rbxassetid://7734408649",
	["gamepad-2"]="rbxassetid://7734408649",["sparkles"]="rbxassetid://7734406104",
	["wand-sparkles"]="rbxassetid://7734406104",["locate-fixed"]="rbxassetid://7734403555",
	["target"]="rbxassetid://7734289010",["crosshair"]="rbxassetid://7734291556",
	["book-open"]="rbxassetid://7734243214",["book"]="rbxassetid://7734240659",
	["file-text"]="rbxassetid://7734248295",["file"]="rbxassetid://7734245748",
	["folder"]="rbxassetid://7734250829",["package"]="rbxassetid://7734255923",
	["activity"]="rbxassetid://7734286459",["bar-chart"]="rbxassetid://7734281375",
	["trending-up"]="rbxassetid://7734276285",["key"]="rbxassetid://7734268648",
	["tag"]="rbxassetid://7734263573",["bookmark"]="rbxassetid://7734266103",
	["image"]="rbxassetid://7734222861",["camera"]="rbxassetid://7734220315",
	["video"]="rbxassetid://7734225397",["music"]="rbxassetid://7734227940",
	["volume-2"]="rbxassetid://7734230499",["volume-x"]="rbxassetid://7734233033",
	["mic"]="rbxassetid://7734235572",["headphones"]="rbxassetid://7734238117",
	["discord"]="rbxassetid://7734314443",["map-pin"]="rbxassetid://7734194775",
	["compass"]="rbxassetid://7734197333",["battery"]="rbxassetid://7734207541",
	["monitor"]="rbxassetid://7734212667",["cpu"]="rbxassetid://7734210118",
	["credit-card"]="rbxassetid://7734271186",
}
local function resolveIcon(icon)
	if not icon then return nil end
	if type(icon) == "number" then return "rbxassetid://" .. tostring(icon) end
	if type(icon) ~= "string" then return nil end
	if icon:sub(1,13) == "rbxassetid://" then return icon end
	if LUCIDE_ICONS[icon] then return LUCIDE_ICONS[icon] end
	if tonumber(icon) then return "rbxassetid://" .. icon end
	return nil
end
local _themes      = {}
local _activeTheme = nil
local DEFAULT_THEME = {
	name="Default", accent=Color3.fromRGB(80,200,120),
	background=Color3.fromRGB(10,10,10), surface=Color3.fromRGB(20,20,20),
	border=Color3.fromRGB(60,60,60), text=Color3.fromRGB(255,255,255),
	textDim=Color3.fromRGB(170,170,170), textMuted=Color3.fromRGB(110,110,110),
	toggle=Color3.fromRGB(80,200,120), notifBg=Color3.fromRGB(0,0,0),
}
local function getThemeVal(key)
	local t = _activeTheme or DEFAULT_THEME
	return t[key] or DEFAULT_THEME[key]
end
function UILibrary:addTheme(t)
	if not t or not t.name then return end
	local merged = {}
	for k,v in pairs(DEFAULT_THEME) do merged[k]=v end
	for k,v in pairs(t) do merged[k]=v end
	_themes[merged.name] = merged
end
function UILibrary:setTheme(name)
	if _themes[name] then _activeTheme = _themes[name] end
end
UILibrary:addTheme({name="Dark",    background=Color3.fromRGB(10,10,10),    surface=Color3.fromRGB(20,20,20),    border=Color3.fromRGB(55,55,55),    accent=Color3.fromRGB(80,200,120)})
UILibrary:addTheme({name="Crimson", background=Color3.fromRGB(10,4,4),      surface=Color3.fromRGB(22,7,9),      border=Color3.fromRGB(130,18,32),   accent=Color3.fromRGB(180,20,40),  text=Color3.fromRGB(255,232,232)})
UILibrary:addTheme({name="Slate",   background=Color3.fromRGB(12,15,22),    surface=Color3.fromRGB(20,25,38),    border=Color3.fromRGB(45,60,90),    accent=Color3.fromRGB(50,90,180)})
UILibrary:addTheme({name="Light",   background=Color3.fromRGB(240,240,245), surface=Color3.fromRGB(225,225,230), border=Color3.fromRGB(180,180,190), accent=Color3.fromRGB(50,130,220), text=Color3.fromRGB(20,20,30), textDim=Color3.fromRGB(80,80,100)})
function UILibrary:gradient(stops, options)
	options = options or {}
	local sorted = {}
	for pct,v in pairs(stops) do table.insert(sorted,{pct=tonumber(pct)/100, color=v.Color or Color3.new(1,1,1)}) end
	table.sort(sorted, function(a,b) return a.pct < b.pct end)
	if #sorted < 2 then sorted = {{pct=0,color=Color3.new(1,1,1)},{pct=1,color=Color3.new(1,1,1)}} end
	local kps = {}
	for _,s in ipairs(sorted) do table.insert(kps, ColorSequenceKeypoint.new(math.clamp(s.pct,0,1), s.color)) end
	return {_isGradient=true, sequence=ColorSequence.new(kps), rotation=options.Rotation or 0}
end
local function applyGradientToLabel(label, grad)
	if type(grad)~="table" or not grad._isGradient then return end
	label.TextColor3 = Color3.new(1,1,1)
	local g = Instance.new("UIGradient")
	g.Color = grad.sequence; g.Rotation = grad.rotation or 0; g.Parent = label
end
UILibrary.Request = (syn and syn.request) or request or http_request
	or (fluxus and fluxus.request) or function() return {StatusCode=0,Body=""} end

function UILibrary.fetchDiscord(inviteCode)
	if not inviteCode then return nil end
	inviteCode = inviteCode:match("discord%.gg/([%w%-]+)") or inviteCode:match("discord%.com/invite/([%w%-]+)") or inviteCode
	local url = "https://discord.com/api/v10/invites/" .. inviteCode .. "?with_counts=true&with_expiration=true"
	local ok, result = pcall(function()
		local res = UILibrary.Request({
			Url = url,
			Method = "GET",
			Headers = {
				["User-Agent"] = "Mozilla/5.0",
				["Accept"] = "application/json",
			},
		})
		if not res or res.StatusCode ~= 200 then return nil end
		return game:GetService("HttpService"):JSONDecode(res.Body)
	end)
	if not ok or not result or not result.guild then return nil end
	local guild   = result.guild
	local iconUrl = guild.icon and ("https://cdn.discordapp.com/icons/" .. guild.id .. "/" .. guild.icon .. ".png?size=128") or nil
	return {
		name        = guild.name or "Unknown",
		description = guild.description or "",
		id          = guild.id,
		icon        = iconUrl,
		members     = result.approximate_member_count or 0,
		online      = result.approximate_presence_count or 0,
		inviteCode  = inviteCode,
		inviteUrl   = "https://discord.gg/" .. inviteCode,
		raw         = result,
	}
end
local CONFIG_FOLDER   = "MIKEYWARE_CONFIGS"
local POSITION_FOLDER = "MIKEYWARE_POSITIONS"
local function make(className, props)
	local obj = Instance.new(className)
	for k, v in pairs(props or {}) do
		obj[k] = v
	end
	return obj
end
local function addCorner(parent, radius)
	local c = make("UICorner", { CornerRadius = UDim.new(0, radius or 10) })
	c.Parent = parent
	return c
end
local function tween(obj, goals, duration, style, direction)
	local t = tw:Create(obj, TweenInfo.new(
		duration or 0.25,
		style     or Enum.EasingStyle.Quint,
		direction or Enum.EasingDirection.Out
	), goals)
	t:Play()
	return t
end
local function makeRow(parent, layoutOrder)
	local row = make("Frame", {
		Size                   = UDim2.new(1, 0, 0, 0),
		AutomaticSize          = Enum.AutomaticSize.Y,
		BackgroundColor3       = Color3.fromRGB(20, 20, 20),
		BackgroundTransparency = 0.4,
		BorderSizePixel        = 0,
		LayoutOrder            = layoutOrder or 1,
		Parent                 = parent,
	})
	addCorner(row, 10)
	make("UIPadding", {
		PaddingTop    = UDim.new(0, 5),
		PaddingBottom = UDim.new(0, 5),
		Parent        = row,
	})
	return row
end
local function makeOrderCounter()
	local n = 0
	return function()
		n = n + 1
		return n
	end
end
local function playSound()
	for i = #activeSounds, 1, -1 do
		if not activeSounds[i] or not activeSounds[i].Parent then
			table.remove(activeSounds, i)
		end
	end
	if #activeSounds < 8 then
		local sd = make("Sound", {
			SoundId = "rbxassetid://3023237993",
			Volume  = 0.5,
			Parent  = ss,
		})
		sd:Play()
		table.insert(activeSounds, sd)
		db:AddItem(sd, 5)
		sd.Ended:Connect(function()
			for i = #activeSounds, 1, -1 do
				if activeSounds[i] == sd then
					table.remove(activeSounds, i)
					break
				end
			end
		end)
	end
end
local function reflowNotifs()
	for i, nd in ipairs(notifQueue) do
		local yp = notifBaseY + (i - 1) * (nd.fh + notifGap)
		if nd.frame and nd.frame.Parent then
			tween(nd.frame, { Position = UDim2.new(1, -(nd.fw + 10), 0, yp) }, 0.3)
			nd.ypos = yp
		end
	end
end
local function sendNotif(title, subtitle, imageId, persistent)
	local nd = { fh = 0, fw = 0, ypos = 0, frame = nil, _persistent = false, _spawned = false }
	nd.dismiss = function()
		if not nd._spawned then
			nd._dismissed = true
			return
		end
		for i, v in ipairs(notifQueue) do
			if v == nd then
				table.remove(notifQueue, i)
				break
			end
		end
		if nd.frame and nd.frame.Parent then
			local fr = nd.frame
			local t = tween(fr, { Position = UDim2.new(1, 10, 0, nd.ypos) }, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
			t.Completed:Connect(function()
				if fr and fr.Parent then fr:Destroy() end
			end)
		end
		reflowNotifs()
	end
	task.spawn(function()
		local resolvedImage = nil
		if type(imageId) == "table" and imageId.userId then
			local ok, img = pcall(function()
				return pl:GetUserThumbnailAsync(imageId.userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
			end)
			if ok then resolvedImage = img end
		elseif imageId ~= nil and imageId ~= "" then
			resolvedImage = "rbxassetid://" .. tostring(imageId)
		end
		local hasImage = resolvedImage ~= nil
		local fh = hasImage and 105 or 72
		local fw = hasImage and 320 or 280
		nd.fh = fh
		nd.fw = fw
		local notifGui = guiParent:FindFirstChild("MW_NOTIF_GUI")
		if not notifGui then
			notifGui = make("ScreenGui", {
				Name           = "MW_NOTIF_GUI",
				ResetOnSpawn   = false,
				ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
				Parent         = guiParent,
			})
		end
		if nd._dismissed then return end
		table.insert(notifQueue, nd)
		local yp = notifBaseY
		for i = 1, #notifQueue - 1 do
			yp = yp + notifQueue[i].fh + notifGap
		end
		nd.ypos = yp
		local fr = make("Frame", {
			Size                   = UDim2.new(0, fw, 0, fh),
			Position               = UDim2.new(1, 10, 0, yp),
			BackgroundColor3       = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 0.45,
			BorderSizePixel        = 0,
			ClipsDescendants       = true,
			Parent                 = notifGui,
		})
		addCorner(fr, 12)
		nd.frame = fr
		make("TextLabel", {
			Size                   = UDim2.new(1, -12, 0, 16),
			Position               = UDim2.new(0, 10, 0, 8),
			BackgroundTransparency = 1,
			Text                   = title and ("Mikeyware  •  " .. title) or "Mikeyware",
			TextColor3             = Color3.fromRGB(180, 180, 180),
			TextSize               = 11,
			Font                   = Enum.Font.GothamBold,
			TextXAlignment         = Enum.TextXAlignment.Left,
			Parent                 = fr,
		})
		local textOffsetX = hasImage and 60 or 10
		local textOffsetW = hasImage and -65 or -20
		if hasImage then
			make("ImageLabel", {
				Size                   = UDim2.new(0, 38, 0, 38),
				Position               = UDim2.new(0, 12, 0, 34),
				BackgroundTransparency = 1,
				Image                  = resolvedImage,
				ImageColor3            = Color3.fromRGB(255, 255, 255),
				Parent                 = fr,
			})
		end
		make("TextLabel", {
			Size                   = UDim2.new(1, textOffsetW, 0, 22),
			Position               = UDim2.new(0, textOffsetX, 0, hasImage and 30 or 22),
			BackgroundTransparency = 1,
			Text                   = title or "",
			TextColor3             = Color3.fromRGB(255, 255, 255),
			TextSize               = 15,
			Font                   = Enum.Font.GothamBold,
			TextXAlignment         = Enum.TextXAlignment.Left,
			Parent                 = fr,
		})
		make("TextLabel", {
			Size                   = UDim2.new(1, textOffsetW, 0, hasImage and 34 or 22),
			Position               = UDim2.new(0, textOffsetX, 0, hasImage and 54 or 46),
			BackgroundTransparency = 1,
			Text                   = subtitle or "",
			TextColor3             = Color3.fromRGB(200, 200, 200),
			TextSize               = 12,
			Font                   = Enum.Font.Gotham,
			TextXAlignment         = Enum.TextXAlignment.Left,
			TextWrapped            = true,
			Parent                 = fr,
		})
		local dismissBtn = make("TextButton", {
			Size                   = UDim2.new(0, 18, 0, 18),
			Position               = UDim2.new(1, -22, 0, 4),
			BackgroundTransparency = 1,
			Text                   = "×",
			TextColor3             = Color3.fromRGB(140, 140, 140),
			TextSize               = 16,
			Font                   = Enum.Font.GothamBold,
			BorderSizePixel        = 0,
			Parent                 = fr,
		})
		dismissBtn.MouseButton1Click:Connect(function()
			nd.dismiss()
		end)
		playSound()
		tween(fr, { Position = UDim2.new(1, -(fw + 10), 0, yp) }, 0.5, Enum.EasingStyle.Quint)
		nd._spawned = true
		if not persistent then
			task.wait(6)
			nd.dismiss()
		else
			nd._persistent = true
		end
	end)
	return nd
end
local function saveConfig(configName, data)
	local ok = pcall(function()
		if not isfolder(CONFIG_FOLDER) then
			makefolder(CONFIG_FOLDER)
		end
		writefile(CONFIG_FOLDER .. "/" .. configName .. ".json", hs:JSONEncode(data))
	end)
	return ok
end
local function loadConfig(configName)
	local ok, result = pcall(function()
		if not isfolder(CONFIG_FOLDER) then return nil end
		local path = CONFIG_FOLDER .. "/" .. configName .. ".json"
		if not isfile(path) then return nil end
		return hs:JSONDecode(readfile(path))
	end)
	if ok then return result end
	return nil
end
local function savePosition(titleKey, x, y, w, h)
	pcall(function()
		if not isfolder(POSITION_FOLDER) then
			makefolder(POSITION_FOLDER)
		end
		local safeName = titleKey:gsub("[^%w_]", "_")
		writefile(POSITION_FOLDER .. "/" .. safeName .. ".json", hs:JSONEncode({ x = x, y = y, w = w, h = h }))
	end)
end
local function loadPosition(titleKey)
	local ok, result = pcall(function()
		if not isfolder(POSITION_FOLDER) then return nil end
		local safeName = titleKey:gsub("[^%w_]", "_")
		local path = POSITION_FOLDER .. "/" .. safeName .. ".json"
		if not isfile(path) then return nil end
		return hs:JSONDecode(readfile(path))
	end)
	if ok then return result end
	return nil
end
local function showConfirmDialog(screenGui, message, onConfirm, onCancel)
	local overlay = make("Frame", {
		Size                   = UDim2.new(1, 0, 1, 0),
		BackgroundColor3       = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.5,
		BorderSizePixel        = 0,
		ZIndex                 = 995,
		Parent                 = screenGui,
	})
	local box = make("Frame", {
		Size                   = UDim2.new(0, 300, 0, 140),
		Position               = UDim2.new(0.5, -150, 0.5, -70),
		BackgroundColor3       = Color3.fromRGB(14, 14, 14),
		BackgroundTransparency = 0.05,
		BorderSizePixel        = 0,
		ZIndex                 = 996,
		Parent                 = overlay,
	})
	addCorner(box, 12)
	make("UIStroke", { Color = Color3.fromRGB(55, 55, 55), Thickness = 1, Parent = box })
	make("TextLabel", {
		Size                   = UDim2.new(1, -20, 0, 60),
		Position               = UDim2.new(0, 10, 0, 20),
		BackgroundTransparency = 1,
		Text                   = message or "Are you sure?",
		TextColor3             = Color3.fromRGB(220, 220, 220),
		TextSize               = 13,
		Font                   = Enum.Font.Gotham,
		TextXAlignment         = Enum.TextXAlignment.Center,
		TextWrapped            = true,
		ZIndex                 = 997,
		Parent                 = box,
	})
	local btnRow = make("Frame", {
		Size                   = UDim2.new(1, -20, 0, 32),
		Position               = UDim2.new(0, 10, 0, 96),
		BackgroundTransparency = 1,
		ZIndex                 = 997,
		Parent                 = box,
	})
	make("UIListLayout", {
		FillDirection       = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding             = UDim.new(0, 8),
		Parent              = btnRow,
	})
	local confirmBtn = make("TextButton", {
		Size                   = UDim2.new(0, 120, 1, 0),
		BackgroundColor3       = Color3.fromRGB(60, 20, 20),
		BackgroundTransparency = 0.1,
		Text                   = "Confirm",
		TextColor3             = Color3.fromRGB(255, 100, 100),
		TextSize               = 12,
		Font                   = Enum.Font.GothamBold,
		BorderSizePixel        = 0,
		ZIndex                 = 998,
		Parent                 = btnRow,
	})
	addCorner(confirmBtn, 7)
	local cancelBtn = make("TextButton", {
		Size                   = UDim2.new(0, 120, 1, 0),
		BackgroundColor3       = Color3.fromRGB(30, 30, 30),
		BackgroundTransparency = 0.2,
		Text                   = "Cancel",
		TextColor3             = Color3.fromRGB(180, 180, 180),
		TextSize               = 12,
		Font                   = Enum.Font.GothamBold,
		BorderSizePixel        = 0,
		ZIndex                 = 998,
		Parent                 = btnRow,
	})
	addCorner(cancelBtn, 7)
	confirmBtn.MouseButton1Click:Connect(function()
		overlay:Destroy()
		if onConfirm then onConfirm() end
	end)
	cancelBtn.MouseButton1Click:Connect(function()
		overlay:Destroy()
		if onCancel then onCancel() end
	end)
end
function UILibrary.new(title, options)
	options = options or {}
	local hideKey     = options.hideKey or Enum.KeyCode.RightShift
	local discordLink = options.discord or options.discordLink
	local configName  = options.configName
	local obfuscate   = options.obfuscate or false
	local loadingCfg  = options.loadingScreen
	local keySysCfg   = options.keySystem
	if options.theme then UILibrary:setTheme(options.theme) end
	local self       = setmetatable({}, UILibrary)
	self._conns      = {}
	self._closed     = false
	self._listening  = false
	self._toggles    = {}
	self._keybinds   = {}
	self._closeCallbacks = {}
	self._resizePending  = false
	self._userResized    = false
	self._minimized      = false
	self._animating      = false
	self._manualWidth    = 300
	self._manualHeight   = 300
	self._tabs           = {}
	self._activeTab      = nil
	self._activeTweens   = {}
	self._hideKey        = hideKey
	self._orderCounter   = makeOrderCounter()
	self._destroyed      = false
	self._configName     = configName
	self._instanceFlags  = {}
	self._flagRefs       = {}
	self.Flags           = self._instanceFlags
	local function conn(signal, fn)
		local c = signal:Connect(fn)
		table.insert(self._conns, c)
		return c
	end
	self._conn = conn
	local function disconnectAll()
		for _, c in ipairs(self._conns) do
			if c and c.Connected then c:Disconnect() end
		end
		self._conns     = {}
		self._closed    = true
		self._listening = false
		self._destroyed = true
	end
	self._disconnectAll = disconnectAll
	local titleKey = title or "__untitled__"
	self._titleKey       = titleKey
	self._tags           = {}
	self._topbarBtns     = {}
	self._transparency   = 0
	self._transparencyOn = false
	if activeInstances[titleKey] then
		for _, old in ipairs(activeInstances[titleKey]) do
			if not old._closed then
				for _, fn in ipairs(old._closeCallbacks or {}) do pcall(fn) end
				old._disconnectAll()
				if old.screenGui and old.screenGui.Parent then old.screenGui:Destroy() end
			end
		end
		activeInstances[titleKey] = nil
	end
	activeInstances[titleKey] = {}
	table.insert(activeInstances[titleKey], self)
	guiCounter = guiCounter + 1
	local rawName = "MIKEYWARE_LIB_" .. guiCounter .. "_" .. hs:GenerateGUID(false):gsub("-", ""):sub(1, 12)
	local guiName = obfuscate and hs:GenerateGUID(false):gsub("-", "") or rawName
	self.screenGui = make("ScreenGui", {
		Name           = guiName,
		ResetOnSpawn   = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent         = guiParent,
	})
	local savedPos = loadPosition(titleKey)
	local initPos  = savedPos and UDim2.new(0, savedPos.x, 0, savedPos.y) or UDim2.new(0.5, -150, 0.5, -200)
	self.mainFrame = make("Frame", {
		Size                   = UDim2.new(0, 300, 0, 40),
		Position               = initPos,
		BackgroundColor3       = Color3.fromRGB(10, 10, 10),
		BackgroundTransparency = 0.3,
		BorderSizePixel        = 0,
		ClipsDescendants       = false,
		Visible                = false,
		Parent                 = self.screenGui,
	})
	addCorner(self.mainFrame, 14)
	make("UIStroke", {
		Color     = Color3.fromRGB(60, 60, 60),
		Thickness = 1,
		Parent    = self.mainFrame,
	})
	self.titleBar = make("Frame", {
		Size                   = UDim2.new(1, 0, 0, 40),
		BackgroundTransparency = 1,
		Parent                 = self.mainFrame,
	})
	make("TextLabel", {
		Size                   = UDim2.new(1, -80, 1, 0),
		Position               = UDim2.new(0, 14, 0, 0),
		BackgroundTransparency = 1,
		Text                   = "Mikeyware" .. (title and ("  •  " .. title) or ""),
		TextColor3             = Color3.fromRGB(255, 255, 255),
		TextSize               = 13,
		Font                   = Enum.Font.GothamBold,
		TextXAlignment         = Enum.TextXAlignment.Left,
		Parent                 = self.titleBar,
	})
	self._tagRow = make("Frame", {
		Size                   = UDim2.new(0, 0, 0, 22),
		AnchorPoint            = Vector2.new(1, 0.5),
		Position               = UDim2.new(1, -58, 0.5, 0),
		BackgroundTransparency = 1,
		AutomaticSize          = Enum.AutomaticSize.X,
		Parent                 = self.titleBar,
	})
	make("UIListLayout", {
		FillDirection       = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment   = Enum.VerticalAlignment.Center,
		Padding             = UDim.new(0, 4),
		SortOrder           = Enum.SortOrder.LayoutOrder,
		Parent              = self._tagRow,
	})
	self._topbarRow = make("Frame", {
		Size                   = UDim2.new(0, 0, 0, 28),
		AnchorPoint            = Vector2.new(1, 0.5),
		Position               = UDim2.new(1, -58, 0.5, 0),
		BackgroundTransparency = 1,
		AutomaticSize          = Enum.AutomaticSize.X,
		Visible                = false,
		Parent                 = self.titleBar,
	})
	make("UIListLayout", {
		FillDirection       = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment   = Enum.VerticalAlignment.Center,
		Padding             = UDim.new(0, 4),
		SortOrder           = Enum.SortOrder.LayoutOrder,
		Parent              = self._topbarRow,
	})
	self.minimizeBtn = make("TextButton", {
		Size                   = UDim2.new(0, 24, 0, 24),
		Position               = UDim2.new(1, -52, 0.5, -12),
		BackgroundColor3       = Color3.fromRGB(30, 30, 30),
		BackgroundTransparency = 0.4,
		Text                   = "—",
		TextColor3             = Color3.fromRGB(200, 200, 200),
		TextSize               = 11,
		Font                   = Enum.Font.GothamBold,
		BorderSizePixel        = 0,
		Parent                 = self.titleBar,
	})
	addCorner(self.minimizeBtn, 8)
	self.closeBtn = make("TextButton", {
		Size                   = UDim2.new(0, 24, 0, 24),
		Position               = UDim2.new(1, -26, 0.5, -12),
		BackgroundColor3       = Color3.fromRGB(30, 30, 30),
		BackgroundTransparency = 0.4,
		Text                   = "X",
		TextColor3             = Color3.fromRGB(200, 200, 200),
		TextSize               = 11,
		Font                   = Enum.Font.GothamBold,
		BorderSizePixel        = 0,
		Parent                 = self.titleBar,
	})
	addCorner(self.closeBtn, 8)
	self.contentFrame = make("Frame", {
		Size                   = UDim2.new(1, 0, 1, -44),
		Position               = UDim2.new(0, 0, 0, 44),
		BackgroundTransparency = 1,
		ClipsDescendants       = true,
		Parent                 = self.mainFrame,
	})
	self.tabScrollFrame = make("ScrollingFrame", {
		Size                       = UDim2.new(1, -16, 0, 28),
		Position                   = UDim2.new(0, 8, 0, 0),
		BackgroundTransparency     = 1,
		BorderSizePixel            = 0,
		ScrollBarThickness         = 0,
		ScrollingDirection         = Enum.ScrollingDirection.X,
		CanvasSize                 = UDim2.new(0, 0, 0, 0),
		Visible                    = false,
		Parent                     = self.contentFrame,
	})
	self.tabContainer = make("Frame", {
		Size                   = UDim2.new(0, 0, 1, 0),
		AutomaticSize          = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Parent                 = self.tabScrollFrame,
	})
	make("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding       = UDim.new(0, 4),
		SortOrder     = Enum.SortOrder.LayoutOrder,
		Parent        = self.tabContainer,
	})
	self.scrollFrame = make("ScrollingFrame", {
		Size                       = UDim2.new(1, -16, 1, -8),
		Position                   = UDim2.new(0, 8, 0, 4),
		BackgroundTransparency     = 1,
		ScrollBarThickness         = 3,
		ScrollBarImageColor3       = Color3.fromRGB(255, 255, 255),
		ScrollBarImageTransparency = 0.5,
		BorderSizePixel            = 0,
		ScrollingDirection         = Enum.ScrollingDirection.Y,
		CanvasSize                 = UDim2.new(0, 0, 0, 0),
		Parent                     = self.contentFrame,
	})
	self.listLayout = make("UIListLayout", {
		Padding   = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent    = self.scrollFrame,
	})
	make("UIPadding", {
		PaddingTop    = UDim.new(0, 4),
		PaddingBottom = UDim.new(0, 4),
		Parent        = self.scrollFrame,
	})
	local resizeHandle = make("Frame", {
		Size                   = UDim2.new(0, 28, 0, 28),
		Position               = UDim2.new(1, -6, 1, -6),
		BackgroundTransparency = 1,
		BorderSizePixel        = 0,
		ZIndex                 = 10,
		Parent                 = self.mainFrame,
	})
	local rLine1 = make("Frame", {
		Size                   = UDim2.new(0, 16, 0, 2),
		Position               = UDim2.new(0, 0, 1, -8),
		BackgroundColor3       = Color3.fromRGB(120, 120, 120),
		BackgroundTransparency = 0.3,
		BorderSizePixel        = 0,
		ZIndex                 = 11,
		Parent                 = resizeHandle,
	})
	addCorner(rLine1, 1)
	local rLine2 = make("Frame", {
		Size                   = UDim2.new(0, 2, 0, 16),
		Position               = UDim2.new(1, -8, 0, 0),
		BackgroundColor3       = Color3.fromRGB(120, 120, 120),
		BackgroundTransparency = 0.3,
		BorderSizePixel        = 0,
		ZIndex                 = 11,
		Parent                 = resizeHandle,
	})
	addCorner(rLine2, 1)
	local minW, minH      = 200, 100
	local resizeDragging  = false
	local resizeOrigin    = nil
	local resizeStartSize = nil
	conn(resizeHandle.InputBegan, function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			resizeDragging  = true
			resizeOrigin    = inp.Position
			resizeStartSize = self.mainFrame.AbsoluteSize
			self._userResized = true
		end
	end)
	conn(resizeHandle.MouseEnter, function()
		tween(rLine1, { BackgroundTransparency = 0 }, 0.1)
		tween(rLine2, { BackgroundTransparency = 0 }, 0.1)
	end)
	conn(resizeHandle.MouseLeave, function()
		tween(rLine1, { BackgroundTransparency = 0.3 }, 0.1)
		tween(rLine2, { BackgroundTransparency = 0.3 }, 0.1)
	end)
	local screenBounds = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
	conn(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), function()
		screenBounds = workspace.CurrentCamera.ViewportSize
	end)
	conn(ui.InputChanged, function(inp)
		if resizeDragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
			local delta = inp.Position - resizeOrigin
			local maxW  = screenBounds.X - self.mainFrame.AbsolutePosition.X - 10
			local maxH  = screenBounds.Y - self.mainFrame.AbsolutePosition.Y - 10
			local newW  = math.clamp(resizeStartSize.X + delta.X, minW, maxW)
			if self._minimized then
				self._manualWidth  = newW
				self.mainFrame.Size = UDim2.new(0, newW, 0, 40)
			else
				local newH = math.clamp(resizeStartSize.Y + delta.Y, minH, maxH)
				self._manualWidth  = newW
				self._manualHeight = newH
				self.mainFrame.Size = UDim2.new(0, newW, 0, newH)
				self:_updateScroll()
			end
		end
	end)
	conn(ui.InputEnded, function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			resizeDragging = false
		end
	end)
	local dragActive   = false
	local dragOrigin   = nil
	local dragStartPos = nil
	conn(self.titleBar.InputBegan, function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			dragActive   = true
			dragOrigin   = inp.Position
			dragStartPos = self.mainFrame.Position
		end
	end)
	conn(ui.InputChanged, function(inp)
		if dragActive and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
			local delta = inp.Position - dragOrigin
			self.mainFrame.Position = UDim2.new(
				dragStartPos.X.Scale, dragStartPos.X.Offset + delta.X,
				dragStartPos.Y.Scale, dragStartPos.Y.Offset + delta.Y
			)
		end
	end)
	conn(ui.InputEnded, function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			dragActive = false
		end
	end)
	conn(self.minimizeBtn.MouseButton1Click, function() self:minimize() end)
	conn(self.closeBtn.MouseButton1Click, function()
		local ap = self.mainFrame.AbsolutePosition
		local as = self.mainFrame.AbsoluteSize
		local saveW = self._minimized and self._manualWidth  or as.X
		local saveH = self._minimized and self._manualHeight or as.Y
		savePosition(self._titleKey, ap.X, ap.Y, saveW, saveH)
		for _, fn in ipairs(self._closeCallbacks) do pcall(fn) end
		if activeInstances[self._titleKey] then
			for i, v in ipairs(activeInstances[self._titleKey]) do
				if v == self then table.remove(activeInstances[self._titleKey], i) break end
			end
			if #activeInstances[self._titleKey] == 0 then activeInstances[self._titleKey] = nil end
		end
		disconnectAll()
		if self.screenGui and self.screenGui.Parent then self.screenGui:Destroy() end
	end)
	conn(self.minimizeBtn.MouseEnter, function() tween(self.minimizeBtn, { BackgroundTransparency = 0.1, TextColor3 = Color3.fromRGB(255, 255, 255) }, 0.15) end)
	conn(self.minimizeBtn.MouseLeave, function() tween(self.minimizeBtn, { BackgroundTransparency = 0.4, TextColor3 = Color3.fromRGB(200, 200, 200) }, 0.15) end)
	conn(self.closeBtn.MouseEnter,    function() tween(self.closeBtn, { BackgroundTransparency = 0.1, TextColor3 = Color3.fromRGB(255, 255, 255) }, 0.15) end)
	conn(self.closeBtn.MouseLeave,    function() tween(self.closeBtn, { BackgroundTransparency = 0.4, TextColor3 = Color3.fromRGB(200, 200, 200) }, 0.15) end)
	conn(ui.InputBegan, function(inp, gp)
		if gp then return end
		if self._closed then return end
		if inp.KeyCode == self._hideKey then
			self.mainFrame.Visible = not self.mainFrame.Visible
		end
		if not self._listening then
			for _, kb in pairs(self._keybinds) do
				if inp.KeyCode == kb.keyCode then pcall(kb.callback) end
			end
		end
	end)
	conn(self.listLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		self:_scheduleResize()
	end)
	self:_updateScroll()
	local function revealMain()
		self.mainFrame.Visible = true
		if savedPos and savedPos.w and savedPos.w > 0 and savedPos.h and savedPos.h > 40 then
			self._manualWidth  = savedPos.w
			self._manualHeight = savedPos.h
			self._userResized  = true
			self.mainFrame.Size = UDim2.new(0, savedPos.w, 0, savedPos.h)
			self:_updateScroll()
		end
		if discordLink and not discordCopied then
			discordCopied = true
			pcall(function()
				if setclipboard then setclipboard(discordLink) end
			end)
			sendNotif("Discord", "Invite link copied to clipboard!", "discord", false)
		end
		if configName then
			self:loadConfig()
		end
		sendNotif("Mikeyware", "Loaded! Press RightShift to toggle.", "check-circle", false)
	end
	if discordLink then
		local _discordData   = nil
		local _discordPara   = nil
		local _discordFetched = false

		local function buildDiscordPanel()
			if _discordPara then return end
			task.spawn(function()
				local data = UILibrary.fetchDiscord(discordLink)
				_discordData = data
				if data then
					_discordPara = self:addParagraph(data.name, (data.description ~= "" and data.description .. "\n" or "") ..
						"Members: " .. tostring(data.members) .. "  •  Online: " .. tostring(data.online), {
						Image    = data.icon,
						ImageSize = 42,
						Buttons  = {
							{
								Title = "Join Discord",
								Callback = function()
									pcall(function() if setclipboard then setclipboard(data.inviteUrl) end end)
									self:notify("Discord", "Invite link copied!", "discord")
								end,
							},
							{
								Title = "Refresh",
								Variant = "Secondary",
								Callback = function()
									local fresh = UILibrary.fetchDiscord(discordLink)
									if fresh and _discordPara then
										_discordPara.setBody((fresh.description ~= "" and fresh.description .. "\n" or "") ..
											"Members: " .. tostring(fresh.members) .. "  •  Online: " .. tostring(fresh.online))
									end
								end,
							},
						},
					})
				else
					self:addParagraph("Discord", "Could not fetch server info.", { Image = "triangle-alert" })
				end
			end)
		end

		self:addTopbarButton("discord", "discord", function()
			pcall(function() if setclipboard then setclipboard(discordLink) end end)
			self:notify("Discord", "Invite link copied to clipboard!", "discord")
			if not _discordFetched then
				_discordFetched = true
				buildDiscordPanel()
			end
		end)

		self.fetchDiscord = function()
			return UILibrary.fetchDiscord(discordLink)
		end
		self.getDiscordData = function()
			return _discordData
		end
	end
	if keySysCfg and keySysCfg.validator then
		local ksGui = make("ScreenGui", {
			Name = "MikeywareKeySystem", ResetOnSpawn = false,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			DisplayOrder = 999, Parent = guiParent,
		})
		local ksOverlay = make("Frame", {
			Size = UDim2.new(1,0,1,0), BackgroundColor3 = Color3.fromRGB(0,0,0),
			BackgroundTransparency = 0.45, BorderSizePixel = 0, Parent = ksGui,
		})
		local ksBox = make("Frame", {
			Size = UDim2.new(0,320,0,180), Position = UDim2.new(0.5,-160,0.5,-90),
			BackgroundColor3 = Color3.fromRGB(12,12,14), BackgroundTransparency = 0.05,
			BorderSizePixel = 0, Parent = ksOverlay,
		})
		addCorner(ksBox, 12)
		make("UIStroke", {Color=Color3.fromRGB(60,60,60), Thickness=1, Parent=ksBox})
		make("TextLabel", {
			Size=UDim2.new(1,-20,0,24), Position=UDim2.new(0,10,0,12),
			BackgroundTransparency=1, Text=keySysCfg.title or "Key Required",
			TextColor3=Color3.fromRGB(255,255,255), TextSize=15, Font=Enum.Font.GothamBold,
			TextXAlignment=Enum.TextXAlignment.Center, Parent=ksBox,
		})
		make("TextLabel", {
			Size=UDim2.new(1,-20,0,16), Position=UDim2.new(0,10,0,38),
			BackgroundTransparency=1, Text=keySysCfg.subtitle or "Enter the key to continue",
			TextColor3=Color3.fromRGB(140,140,140), TextSize=11, Font=Enum.Font.Gotham,
			TextXAlignment=Enum.TextXAlignment.Center, Parent=ksBox,
		})
		local ksInput = make("TextBox", {
			Size=UDim2.new(1,-24,0,32), Position=UDim2.new(0,12,0,70),
			BackgroundColor3=Color3.fromRGB(20,20,20), BackgroundTransparency=0.2,
			Text="", PlaceholderText="Enter key...",
			TextColor3=Color3.fromRGB(255,255,255), PlaceholderColor3=Color3.fromRGB(100,100,100),
			TextSize=12, Font=Enum.Font.Gotham, BorderSizePixel=0,
			ClearTextOnFocus=false, Parent=ksBox,
		})
		addCorner(ksInput, 6)
		local ksStatus = make("TextLabel", {
			Size=UDim2.new(1,-20,0,16), Position=UDim2.new(0,10,0,110),
			BackgroundTransparency=1, Text="",
			TextColor3=Color3.fromRGB(255,80,80), TextSize=10, Font=Enum.Font.Gotham,
			TextXAlignment=Enum.TextXAlignment.Center, Parent=ksBox,
		})
		local ksConfirm = make("TextButton", {
			Size=UDim2.new(1,-24,0,30), Position=UDim2.new(0,12,0,136),
			BackgroundColor3=Color3.fromRGB(40,100,40), BackgroundTransparency=0.15,
			Text="Confirm", TextColor3=Color3.fromRGB(255,255,255),
			TextSize=12, Font=Enum.Font.GothamBold, BorderSizePixel=0, Parent=ksBox,
		})
		addCorner(ksConfirm, 7)
		local function tryKey()
			local ok, result = pcall(keySysCfg.validator, ksInput.Text)
			if ok and result then
				ksGui:Destroy()
				local lsEnabled = loadingCfg and (loadingCfg.enabled ~= false)
				if lsEnabled then
					local lsDuration  = loadingCfg.duration   or 1.2
					local lsBgColor   = loadingCfg.bgColor    or Color3.fromRGB(8, 8, 10)
					local lsBarColor  = loadingCfg.barColor   or getThemeVal("accent")
					local lsTitleColor= loadingCfg.titleColor or Color3.fromRGB(255, 255, 255)
					local lsSubColor  = loadingCfg.subtitleColor or Color3.fromRGB(140, 140, 140)
					local lsTitleSize = loadingCfg.titleSize  or 26
					local lsSubSize   = loadingCfg.subtitleSize or 13
					local lsLogoId    = loadingCfg.logo
					local lsGui = make("ScreenGui", {
						Name="MikeywareLoading", ResetOnSpawn=false,
						ZIndexBehavior=Enum.ZIndexBehavior.Sibling, DisplayOrder=998, Parent=guiParent,
					})
					local lsFrame = make("Frame", {
						Size=UDim2.new(1,0,1,0), BackgroundColor3=lsBgColor,
						BackgroundTransparency=0, BorderSizePixel=0, Parent=lsGui,
					})
					local yBase = loadingCfg.logo and 0.38 or 0.4
					if lsLogoId then
						make("ImageLabel", {
							Size=UDim2.new(0,64,0,64), Position=UDim2.new(0.5,-32,0,0),
							AnchorPoint=Vector2.new(0,0),
							BackgroundTransparency=1,
							Image=resolveIcon(lsLogoId) or tostring(lsLogoId),
							Parent=lsFrame,
						}).Position = UDim2.new(0.5,-32,yBase,-80)
					end
					make("TextLabel", {
						Size=UDim2.new(1,0,0,40), Position=UDim2.new(0,0,yBase,0),
						BackgroundTransparency=1, Text=loadingCfg.title or (title or "Loading..."),
						TextColor3=lsTitleColor, TextSize=lsTitleSize, Font=Enum.Font.GothamBold,
						TextXAlignment=Enum.TextXAlignment.Center, Parent=lsFrame,
					})
					make("TextLabel", {
						Size=UDim2.new(1,0,0,22), Position=UDim2.new(0,0,yBase,46),
						BackgroundTransparency=1, Text=loadingCfg.subtitle or "Please wait...",
						TextColor3=lsSubColor, TextSize=lsSubSize, Font=Enum.Font.Gotham,
						TextXAlignment=Enum.TextXAlignment.Center, Parent=lsFrame,
					})
					local lsTrack = make("Frame", {
						Size=UDim2.new(0,220,0,4), Position=UDim2.new(0.5,-110,yBase,80),
						BackgroundColor3=Color3.fromRGB(35,35,35), BorderSizePixel=0, Parent=lsFrame,
					})
					addCorner(lsTrack, 2)
					local lsFill = make("Frame", {
						Size=UDim2.new(0,0,1,0), BackgroundColor3=lsBarColor,
						BorderSizePixel=0, Parent=lsTrack,
					})
					addCorner(lsFill, 2)
					task.spawn(function()
						tween(lsFill, {Size=UDim2.new(1,0,1,0)}, lsDuration, Enum.EasingStyle.Quint)
						task.wait(lsDuration + 0.1)
						revealMain()
						tween(lsFrame, {BackgroundTransparency=1}, 0.4)
						task.wait(0.45)
						lsGui:Destroy()
					end)
				else
					revealMain()
				end
			else
				ksStatus.Text = "Invalid key. Try again."
				tween(ksInput, {BackgroundColor3=Color3.fromRGB(40,10,10)}, 0.1)
				task.delay(0.4, function() tween(ksInput, {BackgroundColor3=Color3.fromRGB(20,20,20)}, 0.2) end)
			end
		end
		conn(ksConfirm.MouseButton1Click, tryKey)
		conn(ksInput.FocusLost, function(enter) if enter then tryKey() end end)
		return self
	end
	local lsEnabled = loadingCfg and (loadingCfg.enabled ~= false)
	if lsEnabled then
		local lsDuration   = loadingCfg.duration      or 1.2
		local lsBgColor    = loadingCfg.bgColor        or Color3.fromRGB(8, 8, 10)
		local lsBarColor   = loadingCfg.barColor       or getThemeVal("accent")
		local lsTitleColor = loadingCfg.titleColor     or Color3.fromRGB(255, 255, 255)
		local lsSubColor   = loadingCfg.subtitleColor  or Color3.fromRGB(140, 140, 140)
		local lsTitleSize  = loadingCfg.titleSize      or 26
		local lsSubSize    = loadingCfg.subtitleSize   or 13
		local lsLogoId     = loadingCfg.logo
		local lsGui = make("ScreenGui", {
			Name="MikeywareLoading", ResetOnSpawn=false,
			ZIndexBehavior=Enum.ZIndexBehavior.Sibling, DisplayOrder=998, Parent=guiParent,
		})
		local lsFrame = make("Frame", {
			Size=UDim2.new(1,0,1,0), BackgroundColor3=lsBgColor,
			BackgroundTransparency=0, BorderSizePixel=0, Parent=lsGui,
		})
		local yBase = lsLogoId and 0.38 or 0.4
		if lsLogoId then
			local logoImg = make("ImageLabel", {
				Size=UDim2.new(0,64,0,64),
				AnchorPoint=Vector2.new(0.5,0),
				BackgroundTransparency=1,
				Image=resolveIcon(lsLogoId) or tostring(lsLogoId),
				Parent=lsFrame,
			})
			logoImg.Position = UDim2.new(0.5,0,yBase,-80)
		end
		make("TextLabel", {
			Size=UDim2.new(1,0,0,40), Position=UDim2.new(0,0,yBase,0),
			BackgroundTransparency=1, Text=loadingCfg.title or (title or "Loading..."),
			TextColor3=lsTitleColor, TextSize=lsTitleSize, Font=Enum.Font.GothamBold,
			TextXAlignment=Enum.TextXAlignment.Center, Parent=lsFrame,
		})
		make("TextLabel", {
			Size=UDim2.new(1,0,0,22), Position=UDim2.new(0,0,yBase,46),
			BackgroundTransparency=1, Text=loadingCfg.subtitle or "Please wait...",
			TextColor3=lsSubColor, TextSize=lsSubSize, Font=Enum.Font.Gotham,
			TextXAlignment=Enum.TextXAlignment.Center, Parent=lsFrame,
		})
		local lsTrack = make("Frame", {
			Size=UDim2.new(0,220,0,4), Position=UDim2.new(0.5,-110,yBase,80),
			BackgroundColor3=Color3.fromRGB(35,35,35), BorderSizePixel=0, Parent=lsFrame,
		})
		addCorner(lsTrack, 2)
		local lsFill = make("Frame", {
			Size=UDim2.new(0,0,1,0), BackgroundColor3=lsBarColor,
			BorderSizePixel=0, Parent=lsTrack,
		})
		addCorner(lsFill, 2)
		task.spawn(function()
			tween(lsFill, {Size=UDim2.new(1,0,1,0)}, lsDuration, Enum.EasingStyle.Quint)
			task.wait(lsDuration + 0.1)
			revealMain()
			tween(lsFrame, {BackgroundTransparency=1}, 0.4)
			task.wait(0.45)
			lsGui:Destroy()
		end)
		return self
	end
	revealMain()
	return self
end
function UILibrary:saveConfig()
	if not self._configName then return false end
	local data = {}
	for flag, val in pairs(self._instanceFlags) do
		data[flag] = val
	end
	return saveConfig(self._configName, data)
end
function UILibrary:loadConfig()
	if not self._configName then return false end
	local data = loadConfig(self._configName)
	if not data then return false end
	for flag in pairs(self._instanceFlags) do
		self._instanceFlags[flag] = nil
	end
	for flag, val in pairs(data) do
		self._instanceFlags[flag] = val
	end
	self:applyFlags()
	return data
end
function UILibrary:applyFlags()
	for flag, setter in pairs(self._flagRefs) do
		local val = self._instanceFlags[flag]
		if val ~= nil then
			pcall(setter, val)
		end
	end
end
function UILibrary:_registerFlag(flag, setter)
	if flag and setter then self._flagRefs[flag] = setter end
end
function UILibrary:_scheduleResize()
	if self._resizePending then return end
	self._resizePending = true
	task.defer(function()
		self._resizePending = false
		if self._destroyed then return end
		if not self.mainFrame or not self.mainFrame.Parent then return end
		if self._minimized then return end
		self:resize()
	end)
end
function UILibrary:_updateTabScroll()
	if not self.tabContainer or not self.tabScrollFrame then return end
	local contentW = self.tabContainer.AbsoluteSize.X
	self.tabScrollFrame.CanvasSize = UDim2.new(0, contentW, 0, 0)
end
function UILibrary:_updateScroll()
	if not self.scrollFrame or not self.scrollFrame:IsA("ScrollingFrame") then return end
	local tabOffset   = self.tabScrollFrame.Visible and 34 or 0
	local contentSize = self._activeTab
		and self._activeTab.listLayout.AbsoluteContentSize.Y + 8
		or  self.listLayout.AbsoluteContentSize.Y + 8
	self.scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentSize)
	if tabOffset > 0 then
		self.scrollFrame.Size     = UDim2.new(1, -16, 1, -(tabOffset + 8))
		self.scrollFrame.Position = UDim2.new(0, 8, 0, tabOffset)
	else
		self.scrollFrame.Size     = UDim2.new(1, -16, 1, -8)
		self.scrollFrame.Position = UDim2.new(0, 8, 0, 4)
	end
end
function UILibrary:resize()
	if self._minimized then return end
	if not self.scrollFrame or not self.scrollFrame:IsA("ScrollingFrame") then return end
	self:_updateScroll()
	if self._userResized then return end
	local tabOffset   = self.tabScrollFrame.Visible and 34 or 0
	local contentSize = self._activeTab
		and self._activeTab.listLayout.AbsoluteContentSize.Y + 8
		or  self.listLayout.AbsoluteContentSize.Y + 8
	local targetH = math.min(contentSize + tabOffset, 460)
	local finalH  = math.max(40 + math.max(targetH, 20), 60)
	local curSize = self.mainFrame.Size
	if math.abs(curSize.Y.Offset - finalH) > 0.5 then
		for _, t in ipairs(self._activeTweens) do pcall(function() t:Cancel() end) end
		self._activeTweens = {}
		local t = tween(self.mainFrame, { Size = UDim2.new(0, curSize.X.Offset, 0, finalH) }, 0.2)
		table.insert(self._activeTweens, t)
		t.Completed:Connect(function()
			for i, v in ipairs(self._activeTweens) do
				if v == t then table.remove(self._activeTweens, i) break end
			end
		end)
	end
end
function UILibrary:minimize()
	if self._animating then return end
	self._animating = true
	if not self._minimized then
		self._minimized = true
		self.minimizeBtn.Text = "+"
		local cw = self.mainFrame.AbsoluteSize.X
		if not self._userResized then
			self._manualWidth  = cw
			self._manualHeight = self.mainFrame.AbsoluteSize.Y
		end
		for _, t in ipairs(self._activeTweens) do pcall(function() t:Cancel() end) end
		self._activeTweens = {}
		local t = tween(self.mainFrame, { Size = UDim2.new(0, cw, 0, 40) }, 0.3)
		t.Completed:Connect(function()
			if self._minimized then
				self.contentFrame.Visible = false
			end
			self._animating = false
		end)
	else
		self._minimized = false
		self.minimizeBtn.Text = "—"
		self.contentFrame.Visible = true
		for _, t in ipairs(self._activeTweens) do pcall(function() t:Cancel() end) end
		self._activeTweens = {}
		if self._userResized then
			self:_updateScroll()
			local t = tween(self.mainFrame, { Size = UDim2.new(0, self._manualWidth, 0, self._manualHeight) }, 0.3)
			t.Completed:Connect(function()
				self:_updateScroll()
				self._animating = false
			end)
		else
			local tabOffset   = self.tabScrollFrame.Visible and 34 or 0
			local contentSize = self._activeTab
				and self._activeTab.listLayout.AbsoluteContentSize.Y + 8
				or  self.listLayout.AbsoluteContentSize.Y + 8
			local finalH = math.max(40 + math.max(math.min(contentSize + tabOffset, 460), 20), 60)
			local curW   = self.mainFrame.AbsoluteSize.X
			local t = tween(self.mainFrame, { Size = UDim2.new(0, curW, 0, finalH) }, 0.3)
			t.Completed:Connect(function()
				self:_updateScroll()
				self._animating = false
			end)
		end
	end
end
function UILibrary:destroy(skipConfirm, onDone)
	if skipConfirm then
		local ap = self.mainFrame.AbsolutePosition
		local as = self.mainFrame.AbsoluteSize
		local saveW = self._minimized and self._manualWidth  or as.X
		local saveH = self._minimized and self._manualHeight or as.Y
		savePosition(self._titleKey, ap.X, ap.Y, saveW, saveH)
		for _, fn in ipairs(self._closeCallbacks) do pcall(fn) end
		self._disconnectAll()
		if self.screenGui and self.screenGui.Parent then self.screenGui:Destroy() end
		if onDone then onDone() end
	else
		showConfirmDialog(self.screenGui, "Are you sure you want to close Mikeyware?", function()
			local ap = self.mainFrame.AbsolutePosition
			local as = self.mainFrame.AbsoluteSize
			local saveW = self._minimized and self._manualWidth  or as.X
			local saveH = self._minimized and self._manualHeight or as.Y
			savePosition(self._titleKey, ap.X, ap.Y, saveW, saveH)
			for _, fn in ipairs(self._closeCallbacks) do pcall(fn) end
			self._disconnectAll()
			if self.screenGui and self.screenGui.Parent then self.screenGui:Destroy() end
			if onDone then onDone() end
		end, nil)
	end
end
function UILibrary:_getTarget()
	if self._activeTab then
		return self._activeTab.frame, self._activeTab.listLayout, self._activeTab.orderCounter()
	end
	return self.scrollFrame, self.listLayout, self._orderCounter()
end
function UILibrary:addTab(name, icon)
	local tabData = {
		name         = name,
		lib          = self,
		items        = {},
		orderCounter = makeOrderCounter(),
	}
	local iconUrl = resolveIcon(icon)
	local btnText = iconUrl and ("  " .. name .. "  ") or (icon and (icon .. "  " .. name) or ("  " .. name .. "  "))
	local btn = make("TextButton", {
		Size                   = UDim2.new(0, 0, 1, 0),
		AutomaticSize          = Enum.AutomaticSize.X,
		BackgroundColor3       = Color3.fromRGB(30, 30, 30),
		BackgroundTransparency = 0.4,
		Text                   = btnText,
		TextColor3             = Color3.fromRGB(160, 160, 160),
		TextSize               = 11,
		Font                   = Enum.Font.Gotham,
		BorderSizePixel        = 0,
		LayoutOrder            = #self._tabs + 1,
		Parent                 = self.tabContainer,
	})
	addCorner(btn, 8)
	tabData.btn = btn
	if iconUrl then
		make("ImageLabel", {
			Size = UDim2.new(0,12,0,12),
			Position = UDim2.new(0,5,0.5,-6),
			BackgroundTransparency = 1,
			Image = iconUrl,
			ImageColor3 = Color3.fromRGB(160,160,160),
			Parent = btn,
		})
	end
	tabData.select = function()
		self:switchTab(tabData)
	end
	tabData.frame = make("Frame", {
		Size                   = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
		Visible                = false,
		Parent                 = self.scrollFrame,
	})
	tabData.listLayout = make("UIListLayout", {
		Padding   = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent    = tabData.frame,
	})
	make("UIPadding", {
		PaddingTop    = UDim.new(0, 2),
		PaddingBottom = UDim.new(0, 4),
		Parent        = tabData.frame,
	})
	self._conn(tabData.listLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		if self._destroyed then return end
		if self._minimized then return end
		self:_scheduleResize()
		tabData.frame.Size = UDim2.new(1, 0, 0, tabData.listLayout.AbsoluteContentSize.Y + 8)
	end)
	self._conn(self.tabContainer:GetPropertyChangedSignal("AbsoluteSize"), function()
		self:_updateTabScroll()
	end)
	table.insert(self._tabs, tabData)
	self.tabScrollFrame.Visible = #self._tabs > 1
	if self.tabScrollFrame.Visible then
		self.scrollFrame.Parent = self.contentFrame
		self.listLayout.Parent  = nil
	end
	self._conn(btn.MouseButton1Click, function()
		self:switchTab(tabData)
	end)
	if #self._tabs == 1 then self:switchTab(tabData) end
	self:_updateTabScroll()
	if not self._minimized then
		self:resize()
	end
	return tabData
end
function UILibrary:switchTab(tabData)
	for _, other in pairs(self._tabs) do
		other.frame.Visible = false
		tween(other.btn, { BackgroundTransparency = 0.6, TextColor3 = Color3.fromRGB(140, 140, 140) }, 0.15)
	end
	tabData.frame.Visible = true
	tween(tabData.btn, { BackgroundTransparency = 0.1, TextColor3 = Color3.fromRGB(255, 255, 255) }, 0.15)
	self._activeTab = tabData
	self:_updateScroll()
	if not self._minimized then
		self:resize()
	end
end
function UILibrary:addButton(name, callback, options)
	options = options or {}
	local cooldown  = options.cooldown or 0
	local disabled  = options.disabled or false
	local iconUrl   = resolveIcon(options.icon or options.Image)
	local parent, _, layoutOrder = self:_getTarget()
	local row = makeRow(parent, layoutOrder)
	local btn = make("TextButton", {
		Size                   = UDim2.new(1, -16, 0, 0),
		AutomaticSize          = Enum.AutomaticSize.Y,
		Position               = UDim2.new(0, 8, 0, 0),
		BackgroundColor3       = Color3.fromRGB(35, 35, 35),
		BackgroundTransparency = disabled and 0.6 or 0.3,
		Text                   = name,
		TextColor3             = disabled and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(255, 255, 255),
		TextSize               = 12,
		Font                   = Enum.Font.Gotham,
		BorderSizePixel        = 0,
		TextWrapped            = true,
		TextXAlignment         = Enum.TextXAlignment.Center,
		Active                 = not disabled,
		Parent                 = row,
	})
	make("UIPadding", {
		PaddingTop    = UDim.new(0, 7),
		PaddingBottom = UDim.new(0, 7),
		PaddingLeft   = UDim.new(0, 8),
		PaddingRight  = UDim.new(0, 8),
		Parent        = btn,
	})
	addCorner(btn, 8)
	if iconUrl then
		btn.Text = "      " .. name
		make("ImageLabel", {
			Size = UDim2.new(0,14,0,14),
			Position = UDim2.new(0,10,0.5,-7),
			BackgroundTransparency = 1,
			Image = iconUrl,
			ImageColor3 = disabled and Color3.fromRGB(100,100,100) or Color3.fromRGB(255,255,255),
			ZIndex = 2,
			Parent = btn,
		})
	end
	local _disabled   = disabled
	local _onCooldown = false
	local function setDisabled(val)
		_disabled = val
		btn.Active = not val
		tween(btn, {
			BackgroundTransparency = val and 0.6 or 0.3,
			TextColor3             = val and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(255, 255, 255),
		}, 0.15)
	end
	self._conn(btn.MouseEnter, function()
		if not _disabled and not _onCooldown then tween(btn, { BackgroundTransparency = 0.05 }, 0.1) end
	end)
	self._conn(btn.MouseLeave, function()
		if not _disabled and not _onCooldown then tween(btn, { BackgroundTransparency = 0.3 }, 0.1) end
	end)
	self._conn(btn.MouseButton1Click, function()
		if _disabled or _onCooldown then return end
		tween(btn, { BackgroundTransparency = 0.3 }, 0.1)
		if callback then pcall(callback) end
		if cooldown > 0 then
			_onCooldown = true
			local originalText = btn.Text
			btn.Active = false
			tween(btn, { BackgroundTransparency = 0.55, TextColor3 = Color3.fromRGB(120, 120, 120) }, 0.1)
			task.spawn(function()
				local endTime = tick() + cooldown
				while tick() < endTime do
					local remaining = math.ceil(endTime - tick())
					btn.Text = originalText .. " (" .. remaining .. ")"
					task.wait(0.1)
				end
				btn.Text = originalText
				btn.Active = not _disabled
				_onCooldown = false
				tween(btn, {
					BackgroundTransparency = _disabled and 0.6 or 0.3,
					TextColor3             = _disabled and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(255, 255, 255),
				}, 0.15)
			end)
		end
	end)
	if self._activeTab then table.insert(self._activeTab.items, row) end
	if not self._minimized then self:resize() end
	return {
		setText     = function(text) btn.Text = text end,
		getText     = function()     return btn.Text end,
		setDisabled = setDisabled,
		isDisabled  = function()     return _disabled end,
	}
end
function UILibrary:addToggle(name, default, callback, flag)
	local parent, _, layoutOrder = self:_getTarget()
	local row   = makeRow(parent, layoutOrder)
	local state = default or false
	if flag then self._instanceFlags[flag] = state end
	local inner = make("Frame", {
		Size                   = UDim2.new(1, 0, 0, 0),
		AutomaticSize          = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent                 = row,
	})
	make("UIPadding", {
		PaddingLeft  = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		Parent       = inner,
	})
	make("UIListLayout", {
		FillDirection     = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder         = Enum.SortOrder.LayoutOrder,
		Parent            = inner,
	})
	make("TextLabel", {
		Size                   = UDim2.new(1, -60, 0, 26),
		AutomaticSize          = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Text                   = name,
		TextColor3             = Color3.fromRGB(220, 220, 220),
		TextSize               = 12,
		Font                   = Enum.Font.Gotham,
		TextXAlignment         = Enum.TextXAlignment.Left,
		TextWrapped            = true,
		LayoutOrder            = 1,
		Parent                 = inner,
	})
	local track = make("Frame", {
		Size             = UDim2.new(0, 36, 0, 20),
		BackgroundColor3 = state and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(60, 60, 60),
		BorderSizePixel  = 0,
		LayoutOrder      = 2,
		Parent           = inner,
	})
	addCorner(track, 10)
	local knob = make("Frame", {
		Size             = UDim2.new(0, 14, 0, 14),
		Position         = UDim2.new(0, state and 19 or 3, 0.5, -7),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel  = 0,
		Parent           = track,
	})
	addCorner(knob, 7)
	local _disabled = false
	local function updateVisual(val)
		tween(track, { BackgroundColor3 = val and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(60, 60, 60) }, 0.15)
		tween(knob,  { Position = UDim2.new(0, val and 19 or 3, 0.5, -7) }, 0.15)
	end
	local function setValue(val, fire)
		state = val
		if flag then self._instanceFlags[flag] = val end
		updateVisual(val)
		if fire and callback then pcall(callback, val) end
	end
	self._conn(track.InputBegan, function(inp)
		if _disabled then return end
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			setValue(not state, true)
		end
	end)
	if self._activeTab then table.insert(self._activeTab.items, row) end
	if not self._minimized then self:resize() end
	local obj = {}
	setmetatable(obj, {
		__index = function(_, k)
			if k == "Value" then return state end
		end,
		__newindex = function(_, k, v)
			if k == "Value" then setValue(v, false) else rawset(obj, k, v) end
		end,
	})
	obj.set         = function(v, silent) setValue(v, not silent) end
	obj.get         = function() return state end
	obj.setDisabled = function(val)
		_disabled = val
		tween(track, { BackgroundTransparency = val and 0.5 or 0 }, 0.15)
		tween(knob,  { BackgroundTransparency = val and 0.5 or 0 }, 0.15)
	end
	self._toggles[name] = obj
	if flag then self._flagRefs[flag] = function(v) obj.set(v, true) end end
	return obj
end
function UILibrary:addCheckbox(name, default, callback, flag)
	local parent, _, layoutOrder = self:_getTarget()
	local row   = makeRow(parent, layoutOrder)
	local state = default or false
	if flag then self._instanceFlags[flag] = state end
	local inner = make("Frame", {
		Size                   = UDim2.new(1, 0, 0, 0),
		AutomaticSize          = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent                 = row,
	})
	make("UIPadding", {
		PaddingLeft  = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		Parent       = inner,
	})
	make("UIListLayout", {
		FillDirection     = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder         = Enum.SortOrder.LayoutOrder,
		Parent            = inner,
	})
	local box = make("Frame", {
		Size             = UDim2.new(0, 18, 0, 18),
		BackgroundColor3 = state and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(40, 40, 40),
		BorderSizePixel  = 0,
		LayoutOrder      = 1,
		Parent           = inner,
	})
	addCorner(box, 5)
	make("UIStroke", { Color = Color3.fromRGB(80, 80, 80), Thickness = 1, Parent = box })
	local checkmark = make("TextLabel", {
		Size                   = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text                   = "✓",
		TextColor3             = Color3.fromRGB(255, 255, 255),
		TextSize               = 12,
		Font                   = Enum.Font.GothamBold,
		TextXAlignment         = Enum.TextXAlignment.Center,
		TextTransparency       = state and 0 or 1,
		Parent                 = box,
	})
	make("TextLabel", {
		Size                   = UDim2.new(1, -26, 0, 26),
		AutomaticSize          = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Text                   = name,
		TextColor3             = Color3.fromRGB(220, 220, 220),
		TextSize               = 12,
		Font                   = Enum.Font.Gotham,
		TextXAlignment         = Enum.TextXAlignment.Left,
		TextWrapped            = true,
		LayoutOrder            = 2,
		Parent                 = inner,
	})
	make("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = inner:FindFirstChildWhichIsA("TextLabel") })
	local _disabled = false
	local clickBtn = make("TextButton", {
		Size                   = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text                   = "",
		Parent                 = row,
	})
	local function setValue(val, fire)
		state = val
		if flag then self._instanceFlags[flag] = val end
		tween(box, { BackgroundColor3 = val and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(40, 40, 40) }, 0.15)
		tween(checkmark, { TextTransparency = val and 0 or 1 }, 0.1)
		if fire and callback then pcall(callback, val) end
	end
	self._conn(clickBtn.MouseButton1Click, function()
		if _disabled then return end
		setValue(not state, true)
	end)
	if self._activeTab then table.insert(self._activeTab.items, row) end
	if not self._minimized then self:resize() end
	if flag then self:_registerFlag(flag, function(v) local s = {set=function(vv,si) setValue(vv, not si) end}; s.set(v,true) end) end
	return {
		set         = function(v, silent) setValue(v, not silent) end,
		get         = function() return state end,
		setDisabled = function(val)
			_disabled = val
			tween(box, { BackgroundTransparency = val and 0.5 or 0 }, 0.15)
		end,
	}
end
function UILibrary:addRadioGroup(name, options, default, callback, flag)
	if not options or #options == 0 then options = { "Option 1" } end
	local parent, _, layoutOrder = self:_getTarget()
	local row     = makeRow(parent, layoutOrder)
	local selected = default or options[1]
	if flag then self._instanceFlags[flag] = selected end
	local inner = make("Frame", {
		Size                   = UDim2.new(1, 0, 0, 0),
		AutomaticSize          = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent                 = row,
	})
	make("UIListLayout", {
		Padding   = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent    = inner,
	})
	make("UIPadding", {
		PaddingLeft  = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		PaddingTop   = UDim.new(0, 2),
		Parent       = inner,
	})
	if name and name ~= "" then
		make("TextLabel", {
			Size                   = UDim2.new(1, 0, 0, 18),
			BackgroundTransparency = 1,
			Text                   = name,
			TextColor3             = Color3.fromRGB(160, 160, 160),
			TextSize               = 10,
			Font                   = Enum.Font.GothamBold,
			TextXAlignment         = Enum.TextXAlignment.Left,
			LayoutOrder            = 0,
			Parent                 = inner,
		})
	end
	local radioButtons = {}
	local function setSelected(val, fire)
		selected = val
		if flag then self._instanceFlags[flag] = val end
		for _, rb in pairs(radioButtons) do
			local isActive = rb.value == val
			tween(rb.dot, { BackgroundColor3 = isActive and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(40, 40, 40) }, 0.15)
			tween(rb.dot, { Size = isActive and UDim2.new(0, 10, 0, 10) or UDim2.new(0, 6, 0, 6) }, 0.15)
			rb.label.TextColor3 = isActive and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(180, 180, 180)
		end
		if fire and callback then pcall(callback, val) end
	end
	for i, opt in ipairs(options) do
		local optRow = make("Frame", {
			Size                   = UDim2.new(1, 0, 0, 26),
			BackgroundTransparency = 1,
			LayoutOrder            = i,
			Parent                 = inner,
		})
		make("UIListLayout", {
			FillDirection     = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding           = UDim.new(0, 8),
			Parent            = optRow,
		})
		local ring = make("Frame", {
			Size             = UDim2.new(0, 16, 0, 16),
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderSizePixel  = 0,
			LayoutOrder      = 1,
			Parent           = optRow,
		})
		addCorner(ring, 8)
		make("UIStroke", { Color = Color3.fromRGB(80, 80, 80), Thickness = 1, Parent = ring })
		local isActive = opt == selected
		local dot = make("Frame", {
			Size             = isActive and UDim2.new(0, 10, 0, 10) or UDim2.new(0, 6, 0, 6),
			AnchorPoint      = Vector2.new(0.5, 0.5),
			Position         = UDim2.new(0.5, 0, 0.5, 0),
			BackgroundColor3 = isActive and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(40, 40, 40),
			BorderSizePixel  = 0,
			Parent           = ring,
		})
		addCorner(dot, 6)
		local label = make("TextLabel", {
			Size                   = UDim2.new(1, -28, 1, 0),
			BackgroundTransparency = 1,
			Text                   = tostring(opt),
			TextColor3             = isActive and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(180, 180, 180),
			TextSize               = 12,
			Font                   = Enum.Font.Gotham,
			TextXAlignment         = Enum.TextXAlignment.Left,
			LayoutOrder            = 2,
			Parent                 = optRow,
		})
		local clickBtn = make("TextButton", {
			Size                   = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text                   = "",
			Parent                 = optRow,
		})
		table.insert(radioButtons, { value = opt, dot = dot, label = label })
		self._conn(clickBtn.MouseButton1Click, function()
			setSelected(opt, true)
		end)
	end
	if self._activeTab then table.insert(self._activeTab.items, row) end
	if not self._minimized then self:resize() end
	if flag then self:_registerFlag(flag, function(v) setSelected(v, false) end) end
	return {
		get = function() return selected end,
		set = function(v, silent) setSelected(v, not silent) end,
	}
end
function UILibrary:addSlider(name, min, max, default, step, callback, flag)
	if type(step) == "function" then callback = step step = 1 end
	step = (type(step) == "number" and step > 0) and step or 1
	if min >= max then return { set = function() end, get = function() return min end } end
	local range        = max - min
	local steps        = math.round(range / step)
	local correctedMax = min + steps * step
	local parent, _, layoutOrder = self:_getTarget()
	local row     = makeRow(parent, layoutOrder)
	local current = min + math.round((math.clamp(default or min, min, correctedMax) - min) / step) * step
	if flag then self._instanceFlags[flag] = current end
	local inner = make("Frame", {
		Size                   = UDim2.new(1, 0, 0, 0),
		AutomaticSize          = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent                 = row,
	})
	make("UIListLayout", {
		Padding   = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent    = inner,
	})
	local headerRow = make("Frame", {
		Size                   = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		LayoutOrder            = 1,
		Parent                 = inner,
	})
	make("UIPadding", {
		PaddingLeft  = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		Parent       = headerRow,
	})
	make("TextLabel", {
		Size                   = UDim2.new(1, -60, 1, 0),
		BackgroundTransparency = 1,
		Text                   = name,
		TextColor3             = Color3.fromRGB(220, 220, 220),
		TextSize               = 12,
		Font                   = Enum.Font.Gotham,
		TextXAlignment         = Enum.TextXAlignment.Left,
		TextWrapped            = true,
		Parent                 = headerRow,
	})
	local valueLabel = make("TextLabel", {
		Size                   = UDim2.new(0, 55, 1, 0),
		Position               = UDim2.new(1, -55, 0, 0),
		BackgroundTransparency = 1,
		Text                   = tostring(current),
		TextColor3             = Color3.fromRGB(160, 160, 160),
		TextSize               = 11,
		Font                   = Enum.Font.Gotham,
		TextXAlignment         = Enum.TextXAlignment.Right,
		Parent                 = headerRow,
	})
	local sliderRow = make("Frame", {
		Size                   = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		LayoutOrder            = 2,
		Parent                 = inner,
	})
	make("UIPadding", {
		PaddingLeft  = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		Parent       = sliderRow,
	})
	local track = make("Frame", {
		Size             = UDim2.new(1, 0, 0, 6),
		Position         = UDim2.new(0, 0, 0.5, -3),
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
		BorderSizePixel  = 0,
		Parent           = sliderRow,
	})
	addCorner(track, 3)
	local function getProgress(val)
		return (val - min) / (correctedMax - min)
	end
	local fill = make("Frame", {
		Size             = UDim2.new(getProgress(current), 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(80, 200, 120),
		BorderSizePixel  = 0,
		Parent           = track,
	})
	addCorner(fill, 3)
	local knob = make("Frame", {
		Size             = UDim2.new(0, 14, 0, 14),
		AnchorPoint      = Vector2.new(0.5, 0.5),
		Position         = UDim2.new(getProgress(current), 0, 0.5, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel  = 0,
		ZIndex           = 3,
		Parent           = track,
	})
	addCorner(knob, 7)
	local _disabled = false
	local function snapValue(raw)
		return math.clamp(min + math.round((raw - min) / step) * step, min, correctedMax)
	end
	local function applyValue(x)
		if _disabled then return end
		local ratio   = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		local snapped = snapValue(min + ratio * (correctedMax - min))
		current = snapped
		if flag then self._instanceFlags[flag] = snapped end
		local p = getProgress(snapped)
		fill.Size       = UDim2.new(p, 0, 1, 0)
		knob.Position   = UDim2.new(p, 0, 0.5, 0)
		valueLabel.Text = tostring(snapped)
		if callback then pcall(callback, snapped) end
	end
	local sliderDragging = false
	self._conn(ui.InputChanged, function(inp)
		if sliderDragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
			applyValue(inp.Position.X)
		end
	end)
	self._conn(ui.InputEnded, function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			sliderDragging = false
		end
	end)
	self._conn(track.InputBegan, function(inp)
		if _disabled then return end
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			sliderDragging = true
			applyValue(inp.Position.X)
		end
	end)
	if self._activeTab then table.insert(self._activeTab.items, row) end
	if not self._minimized then self:resize() end
	if flag then self:_registerFlag(flag, function(v) local snapped = snapValue(v); current=snapped; local p=getProgress(snapped); fill.Size=UDim2.new(p,0,1,0); knob.Position=UDim2.new(p,0,0.5,0); valueLabel.Text=tostring(snapped); self._instanceFlags[flag]=snapped end) end
	return {
		set = function(v)
			current = snapValue(v)
			if flag then self._instanceFlags[flag] = current end
			local p = getProgress(current)
			fill.Size       = UDim2.new(p, 0, 1, 0)
			knob.Position   = UDim2.new(p, 0, 0.5, 0)
			valueLabel.Text = tostring(current)
		end,
		get         = function() return current end,
		setDisabled = function(val)
			_disabled = val
			tween(track, { BackgroundTransparency = val and 0.5 or 0 }, 0.15)
			tween(knob,  { BackgroundTransparency = val and 0.5 or 0 }, 0.15)
			tween(fill,  { BackgroundTransparency = val and 0.5 or 0 }, 0.15)
		end,
	}
end
function UILibrary:addTextBox(name, placeholder, maxLength, callback, options)
	if type(maxLength) == "function" then callback = maxLength maxLength = 200 end
	maxLength = maxLength or 200
	options = options or {}
	local liveCallback = options.liveCallback
	local flag         = options.flag
	local disabled     = options.disabled or false
	local parent, _, layoutOrder = self:_getTarget()
	local row = makeRow(parent, layoutOrder)
	local inner = make("Frame", {
		Size                   = UDim2.new(1, 0, 0, 0),
		AutomaticSize          = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent                 = row,
	})
	make("UIListLayout", {
		Padding   = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent    = inner,
	})
	make("UIPadding", {
		PaddingLeft  = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
		Parent       = inner,
	})
	make("TextLabel", {
		Size                   = UDim2.new(1, 0, 0, 16),
		BackgroundTransparency = 1,
		Text                   = name,
		TextColor3             = Color3.fromRGB(200, 200, 200),
		TextSize               = 11,
		Font                   = Enum.Font.Gotham,
		TextXAlignment         = Enum.TextXAlignment.Left,
		TextWrapped            = true,
		AutomaticSize          = Enum.AutomaticSize.Y,
		LayoutOrder            = 1,
		Parent                 = inner,
	})
	local box = make("TextBox", {
		Size                   = UDim2.new(1, 0, 0, 26),
		BackgroundColor3       = Color3.fromRGB(15, 15, 15),
		BackgroundTransparency = disabled and 0.5 or 0.3,
		PlaceholderText        = placeholder or "",
		Text                   = "",
		TextColor3             = disabled and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(255, 255, 255),
		PlaceholderColor3      = Color3.fromRGB(100, 100, 100),
		TextSize               = 11,
		Font                   = Enum.Font.Gotham,
		BorderSizePixel        = 0,
		ClearTextOnFocus       = false,
		TextEditable           = not disabled,
		LayoutOrder            = 2,
		Parent                 = inner,
	})
	addCorner(box, 6)
	local _disabled = disabled
	self._conn(box:GetPropertyChangedSignal("Text"), function()
		if #box.Text > maxLength then box.Text = box.Text:sub(1, maxLength) end
		if flag then self._instanceFlags[flag] = box.Text end
		if liveCallback then pcall(liveCallback, box.Text) end
	end)
	self._conn(box.FocusLost, function(enterPressed)
		if enterPressed and callback then pcall(callback, box.Text) end
	end)
	if self._activeTab then table.insert(self._activeTab.items, row) end
	if not self._minimized then self:resize() end
	if flag and options and options.flag then self:_registerFlag(options.flag, function(v) box.Text=tostring(v):sub(1,maxLength); self._instanceFlags[options.flag]=box.Text end) end
	return {
		get   = function()  return box.Text end,
		set   = function(v)
			box.Text = tostring(v):sub(1, maxLength)
			if flag then self._instanceFlags[flag] = box.Text end
		end,
		clear = function()  box.Text = "" end,
		setDisabled = function(val)
			_disabled = val
			box.TextEditable           = not val
			box.BackgroundTransparency = val and 0.5 or 0.3
			box.TextColor3             = val and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(255, 255, 255)
		end,
	}
end
function UILibrary:addDropdown(name, options, default, callback, flag)
	if not options or #options == 0 then options = { "" } end
	local parent, _, layoutOrder = self:_getTarget()
	local row            = makeRow(parent, layoutOrder)
	local isOpen         = false
	local selected       = default or options[1]
	local currentOptions = { table.unpack(options) }
	if flag then self._instanceFlags[flag] = selected end
	local inner = make("Frame", {
		Size                   = UDim2.new(1, 0, 0, 0),
		AutomaticSize          = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent                 = row,
	})
	make("UIPadding", {
		PaddingLeft  = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		Parent       = inner,
	})
	make("UIListLayout", {
		FillDirection     = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder         = Enum.SortOrder.LayoutOrder,
		Parent            = inner,
	})
	make("TextLabel", {
		Size                   = UDim2.new(0.5, 0, 0, 26),
		AutomaticSize          = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Text                   = name,
		TextColor3             = Color3.fromRGB(220, 220, 220),
		TextSize               = 12,
		Font                   = Enum.Font.Gotham,
		TextXAlignment         = Enum.TextXAlignment.Left,
		TextWrapped            = true,
		LayoutOrder            = 1,
		Parent                 = inner,
	})
	local dropBtn = make("TextButton", {
		Size                   = UDim2.new(0.5, -8, 0, 24),
		BackgroundColor3       = Color3.fromRGB(30, 30, 30),
		BackgroundTransparency = 0.3,
		Text                   = tostring(selected) .. " ▾",
		TextColor3             = Color3.fromRGB(220, 220, 220),
		TextSize               = 11,
		Font                   = Enum.Font.Gotham,
		BorderSizePixel        = 0,
		TextTruncate           = Enum.TextTruncate.AtEnd,
		LayoutOrder            = 2,
		Parent                 = inner,
	})
	addCorner(dropBtn, 7)
	local panel = make("Frame", {
		Size                   = UDim2.new(0, 140, 0, 0),
		BackgroundColor3       = Color3.fromRGB(18, 18, 18),
		BackgroundTransparency = 0.1,
		BorderSizePixel        = 0,
		ZIndex                 = 500,
		Visible                = false,
		Parent                 = self.screenGui,
	})
	addCorner(panel, 8)
	make("UIStroke", {
		Color     = Color3.fromRGB(50, 50, 50),
		Thickness = 1,
		Parent    = panel,
	})
	local panelLayout = make("UIListLayout", {
		Padding   = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent    = panel,
	})
	make("UIPadding", {
		PaddingTop    = UDim.new(0, 4),
		PaddingBottom = UDim.new(0, 4),
		PaddingLeft   = UDim.new(0, 4),
		PaddingRight  = UDim.new(0, 4),
		Parent        = panel,
	})
	local function updatePanelPosition()
		local ap     = dropBtn.AbsolutePosition
		local as     = dropBtn.AbsoluteSize
		local vp     = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
		local panelH = panel.AbsoluteSize.Y
		local yBelow = ap.Y + as.Y + 2
		local yAbove = ap.Y - panelH - 2
		local finalY = (yBelow + panelH > vp.Y) and yAbove or yBelow
		local finalX = math.clamp(ap.X, 4, vp.X - 144)
		panel.Position = UDim2.new(0, finalX, 0, finalY)
	end
	self._conn(panelLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		if not panel.Parent then return end
		local vp       = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
		local contentH = panelLayout.AbsoluteContentSize.Y + 8
		local maxH     = vp.Y - 20
		panel.Size = UDim2.new(0, 140, 0, math.min(contentH, math.max(maxH, 30)))
		if isOpen then updatePanelPosition() end
	end)
	local optionConns   = {}
	local optionConnSet = {}
	local function closePanel()
		isOpen        = false
		panel.Visible = false
	end
	local _disabled = false
	local function buildOption(index, value)
		local optBtn = make("TextButton", {
			Size                   = UDim2.new(1, 0, 0, 24),
			BackgroundColor3       = Color3.fromRGB(30, 30, 30),
			BackgroundTransparency = 0.5,
			Text                   = value,
			TextColor3             = Color3.fromRGB(220, 220, 220),
			TextSize               = 11,
			Font                   = Enum.Font.Gotham,
			BorderSizePixel        = 0,
			ZIndex                 = 501,
			LayoutOrder            = index,
			Parent                 = panel,
		})
		addCorner(optBtn, 6)
		local function reg(c)
			table.insert(optionConns, c)
			optionConnSet[c] = true
			table.insert(self._conns, c)
		end
		reg(optBtn.MouseEnter:Connect(function() tween(optBtn, { BackgroundTransparency = 0.1 }, 0.1) end))
		reg(optBtn.MouseLeave:Connect(function() tween(optBtn, { BackgroundTransparency = 0.5 }, 0.1) end))
		reg(optBtn.MouseButton1Click:Connect(function()
			selected      = value
			if flag then self._instanceFlags[flag] = value end
			dropBtn.Text  = tostring(value) .. " ▾"
			closePanel()
			if callback then pcall(callback, value) end
		end))
	end
	for i, v in ipairs(currentOptions) do buildOption(i, v) end
	self._conn(dropBtn.MouseButton1Click, function()
		if _disabled then return end
		if self._minimized then return end
		if isOpen then
			closePanel()
		else
			isOpen        = true
			updatePanelPosition()
			panel.Visible = true
		end
	end)
	self._conn(dropBtn:GetPropertyChangedSignal("AbsolutePosition"), function()
		if isOpen then
			if self._minimized then
				closePanel()
			else
				updatePanelPosition()
			end
		end
	end)
	if self._activeTab then table.insert(self._activeTab.items, row) end
	if not self._minimized then self:resize() end
	if flag then self:_registerFlag(flag, function(v) selected=v; self._instanceFlags[flag]=v; dropBtn.Text=tostring(v)..' u25BE' end) end
	return {
		get = function() return selected end,
		set = function(v)
			selected     = v
			if flag then self._instanceFlags[flag] = v end
			dropBtn.Text = tostring(v) .. " ▾"
		end,
		setDisabled = function(val)
			_disabled = val
			tween(dropBtn, { BackgroundTransparency = val and 0.6 or 0.3 }, 0.15)
			dropBtn.Active = not val
		end,
		refresh = function(newOptions)
			if not newOptions or #newOptions == 0 then newOptions = { "" } end
			currentOptions = { table.unpack(newOptions) }
			local valid = {}
			for _, v in ipairs(currentOptions) do valid[v] = true end
			if not valid[selected] then
				selected = currentOptions[1]
				if flag then self._instanceFlags[flag] = selected end
				dropBtn.Text = tostring(selected) .. " ▾"
			end
			for _, c in ipairs(optionConns) do
				if c and c.Connected then c:Disconnect() end
			end
			for i = #self._conns, 1, -1 do
				if optionConnSet[self._conns[i]] then table.remove(self._conns, i) end
			end
			optionConns   = {}
			optionConnSet = {}
			for _, ch in pairs(panel:GetChildren()) do
				if ch:IsA("TextButton") then ch:Destroy() end
			end
			for i, v in ipairs(currentOptions) do buildOption(i, v) end
		end,
		destroy = function()
			closePanel()
			for _, c in ipairs(optionConns) do
				if c and c.Connected then c:Disconnect() end
			end
			for i = #self._conns, 1, -1 do
				if optionConnSet[self._conns[i]] then table.remove(self._conns, i) end
			end
			optionConns   = {}
			optionConnSet = {}
			panel:Destroy()
		end,
	}
end
function UILibrary:addMultiDropdown(name, options, defaults, callback, flag)
	if not options or #options == 0 then options = { "" } end
	defaults = defaults or {}
	local parent, _, layoutOrder = self:_getTarget()
	local row           = makeRow(parent, layoutOrder)
	local isOpen        = false
	local selected      = {}
	for _, v in ipairs(defaults) do selected[v] = true end
	local currentOptions = { table.unpack(options) }
	local function getSelectedList()
		local list = {}
		for _, opt in ipairs(currentOptions) do
			if selected[opt] then table.insert(list, opt) end
		end
		return list
	end
	local function updateBtnText()
		local list = getSelectedList()
		if #list == 0 then
			return "None ▾"
		elseif #list == 1 then
			return list[1] .. " ▾"
		else
			return list[1] .. " +" .. (#list - 1) .. " ▾"
		end
	end
	if flag then self._instanceFlags[flag] = getSelectedList() end
	local inner = make("Frame", {
		Size                   = UDim2.new(1, 0, 0, 0),
		AutomaticSize          = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent                 = row,
	})
	make("UIPadding", {
		PaddingLeft  = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		Parent       = inner,
	})
	make("UIListLayout", {
		FillDirection     = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder         = Enum.SortOrder.LayoutOrder,
		Parent            = inner,
	})
	make("TextLabel", {
		Size                   = UDim2.new(0.5, 0, 0, 26),
		AutomaticSize          = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Text                   = name,
		TextColor3             = Color3.fromRGB(220, 220, 220),
		TextSize               = 12,
		Font                   = Enum.Font.Gotham,
		TextXAlignment         = Enum.TextXAlignment.Left,
		TextWrapped            = true,
		LayoutOrder            = 1,
		Parent                 = inner,
	})
	local dropBtn = make("TextButton", {
		Size                   = UDim2.new(0.5, -8, 0, 24),
		BackgroundColor3       = Color3.fromRGB(30, 30, 30),
		BackgroundTransparency = 0.3,
		Text                   = updateBtnText(),
		TextColor3             = Color3.fromRGB(220, 220, 220),
		TextSize               = 11,
		Font                   = Enum.Font.Gotham,
		BorderSizePixel        = 0,
		TextTruncate           = Enum.TextTruncate.AtEnd,
		LayoutOrder            = 2,
		Parent                 = inner,
	})
	addCorner(dropBtn, 7)
	local panel = make("Frame", {
		Size                   = UDim2.new(0, 160, 0, 0),
		BackgroundColor3       = Color3.fromRGB(18, 18, 18),
		BackgroundTransparency = 0.1,
		BorderSizePixel        = 0,
		ZIndex                 = 500,
		Visible                = false,
		Parent                 = self.screenGui,
	})
	addCorner(panel, 8)
	make("UIStroke", { Color = Color3.fromRGB(50, 50, 50), Thickness = 1, Parent = panel })
	local panelLayout = make("UIListLayout", {
		Padding   = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent    = panel,
	})
	make("UIPadding", {
		PaddingTop    = UDim.new(0, 4),
		PaddingBottom = UDim.new(0, 4),
		PaddingLeft   = UDim.new(0, 4),
		PaddingRight  = UDim.new(0, 4),
		Parent        = panel,
	})
	local function updatePanelPosition()
		local ap     = dropBtn.AbsolutePosition
		local as     = dropBtn.AbsoluteSize
		local vp     = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
		local panelH = panel.AbsoluteSize.Y
		local yBelow = ap.Y + as.Y + 2
		local yAbove = ap.Y - panelH - 2
		local finalY = (yBelow + panelH > vp.Y) and yAbove or yBelow
		local finalX = math.clamp(ap.X, 4, vp.X - 164)
		panel.Position = UDim2.new(0, finalX, 0, finalY)
	end
	self._conn(panelLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		if not panel.Parent then return end
		local vp       = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
		local contentH = panelLayout.AbsoluteContentSize.Y + 8
		panel.Size     = UDim2.new(0, 160, 0, math.min(contentH, vp.Y - 20))
		if isOpen then updatePanelPosition() end
	end)
	local checkFrames   = {}
	local optionConns   = {}
	local optionConnSet = {}
	local function rebuildOptions()
		for _, c in ipairs(optionConns) do
			if c and c.Connected then c:Disconnect() end
		end
		for i = #self._conns, 1, -1 do
			if optionConnSet[self._conns[i]] then table.remove(self._conns, i) end
		end
		optionConns   = {}
		optionConnSet = {}
		checkFrames   = {}
		for _, ch in pairs(panel:GetChildren()) do
			if ch:IsA("Frame") or ch:IsA("TextButton") then ch:Destroy() end
		end
		for i, value in ipairs(currentOptions) do
			local optRow = make("Frame", {
				Size                   = UDim2.new(1, 0, 0, 26),
				BackgroundColor3       = Color3.fromRGB(28, 28, 28),
				BackgroundTransparency = 0.3,
				BorderSizePixel        = 0,
				ZIndex                 = 501,
				LayoutOrder            = i,
				Parent                 = panel,
			})
			addCorner(optRow, 5)
			local isChecked = selected[value] == true
			local cb = make("Frame", {
				Size             = UDim2.new(0, 14, 0, 14),
				Position         = UDim2.new(0, 6, 0.5, -7),
				BackgroundColor3 = isChecked and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(40, 40, 40),
				BorderSizePixel  = 0,
				ZIndex           = 502,
				Parent           = optRow,
			})
			addCorner(cb, 3)
			local checkTick = make("TextLabel", {
				Size                   = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text                   = "✓",
				TextColor3             = Color3.fromRGB(255, 255, 255),
				TextSize               = 10,
				Font                   = Enum.Font.GothamBold,
				TextXAlignment         = Enum.TextXAlignment.Center,
				TextTransparency       = isChecked and 0 or 1,
				ZIndex                 = 503,
				Parent                 = cb,
			})
			make("TextLabel", {
				Size                   = UDim2.new(1, -28, 1, 0),
				Position               = UDim2.new(0, 26, 0, 0),
				BackgroundTransparency = 1,
				Text                   = tostring(value),
				TextColor3             = Color3.fromRGB(220, 220, 220),
				TextSize               = 11,
				Font                   = Enum.Font.Gotham,
				TextXAlignment         = Enum.TextXAlignment.Left,
				ZIndex                 = 502,
				Parent                 = optRow,
			})
			local clickBtn = make("TextButton", {
				Size                   = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text                   = "",
				ZIndex                 = 504,
				Parent                 = optRow,
			})
			table.insert(checkFrames, { value = value, box = cb, tick = checkTick })
			local function reg(c)
				table.insert(optionConns, c)
				optionConnSet[c] = true
				table.insert(self._conns, c)
			end
			reg(clickBtn.MouseButton1Click:Connect(function()
				selected[value] = not selected[value]
				local nowChecked = selected[value]
				tween(cb, { BackgroundColor3 = nowChecked and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(40, 40, 40) }, 0.12)
				tween(checkTick, { TextTransparency = nowChecked and 0 or 1 }, 0.1)
				dropBtn.Text = updateBtnText()
				if flag then self._instanceFlags[flag] = getSelectedList() end
				if callback then pcall(callback, getSelectedList()) end
			end))
		end
	end
	rebuildOptions()
	self._conn(dropBtn.MouseButton1Click, function()
		if self._minimized then return end
		if isOpen then
			isOpen        = false
			panel.Visible = false
		else
			isOpen        = true
			updatePanelPosition()
			panel.Visible = true
		end
	end)
	self._conn(dropBtn:GetPropertyChangedSignal("AbsolutePosition"), function()
		if isOpen then
			if self._minimized then
				isOpen        = false
				panel.Visible = false
			else
				updatePanelPosition()
			end
		end
	end)
	if self._activeTab then table.insert(self._activeTab.items, row) end
	if not self._minimized then self:resize() end
	if flag then self:_registerFlag(flag, function(v) if type(v)=='table' then selected={}; for _,x in ipairs(v) do selected[x]=true end; self._instanceFlags[flag]=v; dropBtn.Text=updateBtnText(); rebuildOptions() end end) end
	return {
		get     = getSelectedList,
		set     = function(list)
			selected = {}
			for _, v in ipairs(list) do selected[v] = true end
			if flag then self._instanceFlags[flag] = list end
			dropBtn.Text = updateBtnText()
			rebuildOptions()
		end,
		refresh = function(newOptions)
			currentOptions = newOptions or {}
			rebuildOptions()
		end,
	}
end
function UILibrary:addColorPicker(name, defaultColor, callback, flag)
	defaultColor = defaultColor or Color3.fromRGB(255, 255, 255)
	local parent, _, layoutOrder = self:_getTarget()
	local row    = makeRow(parent, layoutOrder)
	local isOpen = false
	local h, s, v = Color3.toHSV(defaultColor)
	local currentColor = defaultColor
	if flag then self._instanceFlags[flag] = currentColor end
	local inner = make("Frame", {
		Size                   = UDim2.new(1, 0, 0, 0),
		AutomaticSize          = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent                 = row,
	})
	make("UIPadding", {
		PaddingLeft  = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		Parent       = inner,
	})
	make("UIListLayout", {
		FillDirection     = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder         = Enum.SortOrder.LayoutOrder,
		Parent            = inner,
	})
	make("TextLabel", {
		Size                   = UDim2.new(1, -60, 0, 28),
		BackgroundTransparency = 1,
		Text                   = name,
		TextColor3             = Color3.fromRGB(220, 220, 220),
		TextSize               = 12,
		Font                   = Enum.Font.Gotham,
		TextXAlignment         = Enum.TextXAlignment.Left,
		TextWrapped            = true,
		LayoutOrder            = 1,
		Parent                 = inner,
	})
	local preview = make("TextButton", {
		Size                   = UDim2.new(0, 42, 0, 22),
		BackgroundColor3       = currentColor,
		BorderSizePixel        = 0,
		Text                   = "",
		LayoutOrder            = 2,
		Parent                 = inner,
	})
	addCorner(preview, 6)
	make("UIStroke", { Color = Color3.fromRGB(80, 80, 80), Thickness = 1, Parent = preview })
	local pickerPanel = make("Frame", {
		Size                   = UDim2.new(0, 220, 0, 210),
		BackgroundColor3       = Color3.fromRGB(16, 16, 16),
		BackgroundTransparency = 0.05,
		BorderSizePixel        = 0,
		ZIndex                 = 500,
		Visible                = false,
		Parent                 = self.screenGui,
	})
	addCorner(pickerPanel, 10)
	make("UIStroke", { Color = Color3.fromRGB(55, 55, 55), Thickness = 1, Parent = pickerPanel })
	local function updatePickerPosition()
		local ap = preview.AbsolutePosition
		local as = preview.AbsoluteSize
		local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
		local px = math.clamp(ap.X, 4, vp.X - 224)
		local py = ap.Y + as.Y + 4
		if py + 210 > vp.Y then py = ap.Y - 214 end
		pickerPanel.Position = UDim2.new(0, px, 0, py)
	end
	local svCanvas = make("ImageLabel", {
		Size                   = UDim2.new(0, 190, 0, 120),
		Position               = UDim2.new(0, 15, 0, 14),
		Image                  = "rbxassetid://4155801252",
		BackgroundColor3       = Color3.fromHSV(h, 1, 1),
		BorderSizePixel        = 0,
		ZIndex                 = 501,
		Parent                 = pickerPanel,
	})
	addCorner(svCanvas, 5)
	local svCursor = make("Frame", {
		Size             = UDim2.new(0, 10, 0, 10),
		AnchorPoint      = Vector2.new(0.5, 0.5),
		Position         = UDim2.new(s, 0, 1 - v, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel  = 0,
		ZIndex           = 502,
		Parent           = svCanvas,
	})
	addCorner(svCursor, 5)
	make("UIStroke", { Color = Color3.fromRGB(0, 0, 0), Thickness = 1.5, Parent = svCursor })
	local hueBar = make("ImageLabel", {
		Size             = UDim2.new(0, 190, 0, 14),
		Position         = UDim2.new(0, 15, 0, 142),
		Image            = "rbxassetid://4155806578",
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel  = 0,
		ZIndex           = 501,
		Parent           = pickerPanel,
	})
	addCorner(hueBar, 4)
	local hueCursor = make("Frame", {
		Size             = UDim2.new(0, 6, 1, 2),
		AnchorPoint      = Vector2.new(0.5, 0.5),
		Position         = UDim2.new(h, 0, 0.5, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel  = 0,
		ZIndex           = 502,
		Parent           = hueBar,
	})
	addCorner(hueCursor, 3)
	make("UIStroke", { Color = Color3.fromRGB(0, 0, 0), Thickness = 1, Parent = hueCursor })
	local hexInput = make("TextBox", {
		Size                   = UDim2.new(0, 100, 0, 22),
		Position               = UDim2.new(0, 15, 0, 166),
		BackgroundColor3       = Color3.fromRGB(25, 25, 25),
		BackgroundTransparency = 0.2,
		Text                   = string.format("#%02X%02X%02X", math.floor(currentColor.R * 255), math.floor(currentColor.G * 255), math.floor(currentColor.B * 255)),
		TextColor3             = Color3.fromRGB(220, 220, 220),
		PlaceholderColor3      = Color3.fromRGB(100, 100, 100),
		TextSize               = 11,
		Font                   = Enum.Font.Gotham,
		BorderSizePixel        = 0,
		ClearTextOnFocus       = false,
		ZIndex                 = 501,
		Parent                 = pickerPanel,
	})
	addCorner(hexInput, 5)
	local colorPreviewSmall = make("Frame", {
		Size             = UDim2.new(0, 60, 0, 22),
		Position         = UDim2.new(0, 125, 0, 166),
		BackgroundColor3 = currentColor,
		BorderSizePixel  = 0,
		ZIndex           = 501,
		Parent           = pickerPanel,
	})
	addCorner(colorPreviewSmall, 5)
	make("UIStroke", { Color = Color3.fromRGB(60, 60, 60), Thickness = 1, Parent = colorPreviewSmall })
	local closePickerBtn = make("TextButton", {
		Size                   = UDim2.new(1, -18, 0, 16),
		Position               = UDim2.new(0, 9, 1, -20),
		BackgroundColor3       = Color3.fromRGB(35, 35, 35),
		BackgroundTransparency = 0.3,
		Text                   = "Close",
		TextColor3             = Color3.fromRGB(160, 160, 160),
		TextSize               = 10,
		Font                   = Enum.Font.Gotham,
		BorderSizePixel        = 0,
		ZIndex                 = 501,
		Parent                 = pickerPanel,
	})
	addCorner(closePickerBtn, 4)
	local function applyColor(newH, newS, newV)
		h = math.clamp(newH, 0, 1)
		s = math.clamp(newS, 0, 1)
		v = math.clamp(newV, 0, 1)
		currentColor = Color3.fromHSV(h, s, v)
		if flag then self._instanceFlags[flag] = currentColor end
		svCanvas.BackgroundColor3         = Color3.fromHSV(h, 1, 1)
		svCursor.Position                  = UDim2.new(s, 0, 1 - v, 0)
		hueCursor.Position                 = UDim2.new(h, 0, 0.5, 0)
		preview.BackgroundColor3           = currentColor
		colorPreviewSmall.BackgroundColor3 = currentColor
		hexInput.Text = string.format("#%02X%02X%02X",
			math.floor(currentColor.R * 255),
			math.floor(currentColor.G * 255),
			math.floor(currentColor.B * 255))
		if callback then pcall(callback, currentColor) end
	end
	local svDragging  = false
	local hueDragging = false
	local _disabled   = false
	self._conn(svCanvas.InputBegan, function(inp)
		if _disabled then return end
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			svDragging = true
			local rx = math.clamp((inp.Position.X - svCanvas.AbsolutePosition.X) / svCanvas.AbsoluteSize.X, 0, 1)
			local ry = math.clamp((inp.Position.Y - svCanvas.AbsolutePosition.Y) / svCanvas.AbsoluteSize.Y, 0, 1)
			applyColor(h, rx, 1 - ry)
		end
	end)
	self._conn(hueBar.InputBegan, function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			hueDragging = true
			local rx = math.clamp((inp.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
			applyColor(rx, s, v)
		end
	end)
	self._conn(ui.InputChanged, function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
			if svDragging then
				local rx = math.clamp((inp.Position.X - svCanvas.AbsolutePosition.X) / svCanvas.AbsoluteSize.X, 0, 1)
				local ry = math.clamp((inp.Position.Y - svCanvas.AbsolutePosition.Y) / svCanvas.AbsoluteSize.Y, 0, 1)
				applyColor(h, rx, 1 - ry)
			elseif hueDragging then
				local rx = math.clamp((inp.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
				applyColor(rx, s, v)
			end
		end
	end)
	self._conn(ui.InputEnded, function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			svDragging  = false
			hueDragging = false
		end
	end)
	self._conn(hexInput.FocusLost, function(enter)
		if enter then
			local hex = hexInput.Text:gsub("#", "")
			if #hex == 6 then
				local ok, r, g, b = pcall(function()
					return tonumber("0x" .. hex:sub(1, 2)),
					       tonumber("0x" .. hex:sub(3, 4)),
					       tonumber("0x" .. hex:sub(5, 6))
				end)
				if ok and r and g and b then
					local newColor = Color3.fromRGB(r, g, b)
					local nh, ns, nv = Color3.toHSV(newColor)
					applyColor(nh, ns, nv)
				end
			end
		end
	end)
	self._conn(preview.MouseButton1Click, function()
		if _disabled then return end
		if self._minimized then return end
		if isOpen then
			isOpen              = false
			pickerPanel.Visible = false
		else
			isOpen              = true
			updatePickerPosition()
			pickerPanel.Visible = true
		end
	end)
	self._conn(closePickerBtn.MouseButton1Click, function()
		isOpen              = false
		pickerPanel.Visible = false
	end)
	self._conn(preview:GetPropertyChangedSignal("AbsolutePosition"), function()
		if isOpen then
			if self._minimized then
				isOpen              = false
				pickerPanel.Visible = false
			else
				updatePickerPosition()
			end
		end
	end)
	if self._activeTab then table.insert(self._activeTab.items, row) end
	if not self._minimized then self:resize() end
	if flag then self:_registerFlag(flag, function(v) if typeof(v)=='Color3' then local nh,ns,nv=Color3.toHSV(v); applyColor(nh,ns,nv) end end) end
	return {
		get = function() return currentColor end,
		set = function(color)
			local nh, ns, nv = Color3.toHSV(color)
			applyColor(nh, ns, nv)
		end,
		setDisabled = function(val)
			_disabled = val
			tween(preview, { BackgroundTransparency = val and 0.5 or 0 }, 0.15)
			if val and isOpen then isOpen = false; pickerPanel.Visible = false end
		end,
		destroy = function()
			isOpen = false
			pickerPanel:Destroy()
		end,
	}
end
function UILibrary:addKeybind(name, defaultKey, callback)
	local parent, _, layoutOrder = self:_getTarget()
	local row         = makeRow(parent, layoutOrder)
	local currentKey  = defaultKey
	local isListening = false
	local listenConn  = nil
	local inner = make("Frame", {
		Size                   = UDim2.new(1, 0, 0, 0),
		AutomaticSize          = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent                 = row,
	})
	make("UIPadding", {
		PaddingLeft  = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		Parent       = inner,
	})
	make("UIListLayout", {
		FillDirection     = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder         = Enum.SortOrder.LayoutOrder,
		Parent            = inner,
	})
	make("TextLabel", {
		Size                   = UDim2.new(1, -90, 0, 26),
		AutomaticSize          = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Text                   = name,
		TextColor3             = Color3.fromRGB(220, 220, 220),
		TextSize               = 12,
		Font                   = Enum.Font.Gotham,
		TextXAlignment         = Enum.TextXAlignment.Left,
		TextWrapped            = true,
		LayoutOrder            = 1,
		Parent                 = inner,
	})
	local keyBtn = make("TextButton", {
		Size                   = UDim2.new(0, 76, 0, 24),
		BackgroundColor3       = Color3.fromRGB(30, 30, 30),
		BackgroundTransparency = 0.3,
		Text                   = currentKey and currentKey.Name or "None",
		TextColor3             = currentKey and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(160, 160, 160),
		TextSize               = 11,
		Font                   = Enum.Font.Gotham,
		BorderSizePixel        = 0,
		LayoutOrder            = 2,
		Parent                 = inner,
	})
	addCorner(keyBtn, 7)
	local function registerKey(keyCode)
		currentKey           = keyCode
		self._keybinds[name] = { keyCode = keyCode, callback = callback or function() end }
	end
	local function clearKey()
		currentKey           = nil
		keyBtn.Text          = "None"
		keyBtn.TextColor3    = Color3.fromRGB(160, 160, 160)
		self._keybinds[name] = nil
	end
	local function removeListenConn()
		if listenConn then
			if listenConn.Connected then listenConn:Disconnect() end
			local target = listenConn
			listenConn   = nil
			for i = #self._conns, 1, -1 do
				if self._conns[i] == target then table.remove(self._conns, i) break end
			end
		end
	end
	local function stopListening()
		isListening       = false
		self._listening   = false
		removeListenConn()
		keyBtn.Text       = currentKey and currentKey.Name or "None"
		keyBtn.TextColor3 = currentKey and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(160, 160, 160)
	end
	self._conn(keyBtn.MouseButton1Click, function()
		if self._closed then return end
		if isListening then stopListening() clearKey() return end
		removeListenConn()
		isListening       = true
		self._listening   = true
		keyBtn.Text       = "..."
		keyBtn.TextColor3 = Color3.fromRGB(255, 200, 60)
		listenConn = ui.InputBegan:Connect(function(inp, gp)
			if gp then return end
			if self._closed then stopListening() return end
			if inp.KeyCode ~= Enum.KeyCode.Unknown then
				isListening       = false
				self._listening   = false
				removeListenConn()
				registerKey(inp.KeyCode)
				keyBtn.Text       = inp.KeyCode.Name
				keyBtn.TextColor3 = Color3.fromRGB(80, 200, 120)
			end
		end)
		table.insert(self._conns, listenConn)
	end)
	if defaultKey then registerKey(defaultKey) end
	if self._activeTab then table.insert(self._activeTab.items, row) end
	if not self._minimized then self:resize() end
	return {
		get = function() return currentKey end,
		set = function(v)
			currentKey        = v
			keyBtn.Text       = v and v.Name or "None"
			keyBtn.TextColor3 = v and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(160, 160, 160)
			if v then registerKey(v) else clearKey() end
		end,
	}
end
function UILibrary:addHoldButton(name, keyCode, holdDuration, onActive, onInactive)
	holdDuration = holdDuration or 1
	local parent, _, layoutOrder = self:_getTarget()
	local row          = makeRow(parent, layoutOrder)
	local isHolding    = false
	local isActive     = false
	local holdThread   = nil
	local mouseHolding = false
	local keyHolding   = false
	local inner = make("Frame", {
		Size                   = UDim2.new(1, 0, 0, 0),
		AutomaticSize          = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent                 = row,
	})
	make("UIPadding", {
		PaddingLeft  = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		Parent       = inner,
	})
	make("UIListLayout", {
		Padding   = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent    = inner,
	})
	local topRow = make("Frame", {
		Size                   = UDim2.new(1, 0, 0, 26),
		BackgroundTransparency = 1,
		LayoutOrder            = 1,
		Parent                 = inner,
	})
	make("UIListLayout", {
		FillDirection     = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder         = Enum.SortOrder.LayoutOrder,
		Parent            = topRow,
	})
	make("TextLabel", {
		Size                   = UDim2.new(1, -90, 1, 0),
		BackgroundTransparency = 1,
		Text                   = name,
		TextColor3             = Color3.fromRGB(220, 220, 220),
		TextSize               = 12,
		Font                   = Enum.Font.Gotham,
		TextXAlignment         = Enum.TextXAlignment.Left,
		TextWrapped            = true,
		LayoutOrder            = 1,
		Parent                 = topRow,
	})
	local keyLabel = make("TextLabel", {
		Size                   = UDim2.new(0, 82, 1, 0),
		BackgroundTransparency = 1,
		Text                   = keyCode and ("[" .. keyCode.Name .. "]") or "[Hold]",
		TextColor3             = Color3.fromRGB(120, 120, 120),
		TextSize               = 10,
		Font                   = Enum.Font.Gotham,
		TextXAlignment         = Enum.TextXAlignment.Right,
		LayoutOrder            = 2,
		Parent                 = topRow,
	})
	local barBg = make("Frame", {
		Size             = UDim2.new(1, 0, 0, 6),
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
		BorderSizePixel  = 0,
		LayoutOrder      = 2,
		Parent           = inner,
	})
	addCorner(barBg, 3)
	local barFill = make("Frame", {
		Size             = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(80, 200, 120),
		BorderSizePixel  = 0,
		Parent           = barBg,
	})
	addCorner(barFill, 3)
	local statusLabel = make("TextLabel", {
		Size                   = UDim2.new(1, 0, 0, 14),
		BackgroundTransparency = 1,
		Text                   = "Inactive",
		TextColor3             = Color3.fromRGB(120, 120, 120),
		TextSize               = 10,
		Font                   = Enum.Font.Gotham,
		TextXAlignment         = Enum.TextXAlignment.Left,
		LayoutOrder            = 3,
		Parent                 = inner,
	})
	local holdBtn = make("TextButton", {
		Size                   = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text                   = "",
		ZIndex                 = 5,
		Parent                 = row,
	})
	local function stopHold()
		if holdThread then task.cancel(holdThread) holdThread = nil end
		isHolding = false
		isActive  = false
		tween(barFill, { Size = UDim2.new(0, 0, 1, 0) }, 0.2)
		if statusLabel and statusLabel.Parent then
			statusLabel.Text       = "Inactive"
			statusLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
		end
		if onInactive then pcall(onInactive) end
	end
	local function startHold()
		if isHolding then return end
		isHolding = true
		isActive  = true
		if statusLabel and statusLabel.Parent then
			statusLabel.Text       = "Active"
			statusLabel.TextColor3 = Color3.fromRGB(80, 200, 120)
		end
		if onActive then pcall(onActive) end
		holdThread = task.spawn(function()
			local startTime = tick()
			while isHolding do
				local p = math.clamp((tick() - startTime) / holdDuration, 0, 1)
				if barFill and barFill.Parent then barFill.Size = UDim2.new(p, 0, 1, 0) end
				task.wait()
			end
		end)
	end
	self._conn(holdBtn.InputBegan, function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			mouseHolding = true
			startHold()
		end
	end)
	self._conn(holdBtn.InputEnded, function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			mouseHolding = false
			if not keyHolding then stopHold() end
		end
	end)
	if keyCode then
		keyLabel.Text = "[" .. keyCode.Name .. "] or [Hold]"
		self._conn(ui.InputBegan, function(inp, gp)
			if gp then return end
			if self._closed then return end
			if self._listening then return end
			if inp.KeyCode == keyCode then keyHolding = true startHold() end
		end)
		self._conn(ui.InputEnded, function(inp)
			if inp.KeyCode == keyCode then
				keyHolding = false
				if not mouseHolding then stopHold() end
			end
		end)
	end
	if self._activeTab then table.insert(self._activeTab.items, row) end
	if not self._minimized then self:resize() end
	return {
		isActive  = function() return isActive end,
		setActive = function(val)
			isActive = val
			if isActive then
				if barFill    and barFill.Parent    then barFill.Size         = UDim2.new(1, 0, 1, 0) end
				if statusLabel and statusLabel.Parent then
					statusLabel.Text       = "Active"
					statusLabel.TextColor3 = Color3.fromRGB(80, 200, 120)
				end
			else
				if barFill    and barFill.Parent    then tween(barFill, { Size = UDim2.new(0, 0, 1, 0) }, 0.2) end
				if statusLabel and statusLabel.Parent then
					statusLabel.Text       = "Inactive"
					statusLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
				end
			end
		end,
	}
end
function UILibrary:addSection(name, icon)
	local parent, _, layoutOrder = self:_getTarget()
	local iconUrl = resolveIcon(icon)
	local sectionFrame = make("Frame", {
		Size                   = UDim2.new(1, 0, 0, 22),
		BackgroundTransparency = 1,
		LayoutOrder            = layoutOrder,
		Parent                 = parent,
	})
	if iconUrl then
		make("ImageLabel", {
			Size = UDim2.new(0,12,0,12),
			Position = UDim2.new(0.5,-40,0.5,-6),
			BackgroundTransparency = 1,
			Image = iconUrl,
			ImageColor3 = Color3.fromRGB(120,120,120),
			Parent = sectionFrame,
		})
	end
	make("TextLabel", {
		Size                   = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text                   = name,
		TextColor3             = Color3.fromRGB(120, 120, 120),
		TextSize               = 10,
		Font                   = Enum.Font.GothamSemibold,
		TextXAlignment         = Enum.TextXAlignment.Center,
		TextYAlignment         = Enum.TextYAlignment.Center,
		BorderSizePixel        = 0,
		Parent                 = sectionFrame,
	})
	if self._activeTab then table.insert(self._activeTab.items, sectionFrame) end
	if not self._minimized then self:resize() end
	return sectionFrame
end
function UILibrary:addSeparator()
	local parent, _, layoutOrder = self:_getTarget()
	local sep = make("Frame", {
		Size                   = UDim2.new(1, 0, 0, 10),
		BackgroundTransparency = 1,
		LayoutOrder            = layoutOrder,
		Parent                 = parent,
	})
	make("Frame", {
		Size             = UDim2.new(1, -16, 0, 1),
		Position         = UDim2.new(0, 8, 0.5, 0),
		BackgroundColor3 = Color3.fromRGB(45, 45, 45),
		BorderSizePixel  = 0,
		Parent           = sep,
	})
	if self._activeTab then table.insert(self._activeTab.items, sep) end
	if not self._minimized then self:resize() end
	return sep
end
function UILibrary:addLabel(text)
	local parent, _, layoutOrder = self:_getTarget()
	local labelFrame = make("Frame", {
		Size                   = UDim2.new(1, 0, 0, 0),
		AutomaticSize          = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder            = layoutOrder,
		Parent                 = parent,
	})
	make("UIPadding", {
		PaddingLeft   = UDim.new(0, 10),
		PaddingRight  = UDim.new(0, 10),
		PaddingTop    = UDim.new(0, 4),
		PaddingBottom = UDim.new(0, 4),
		Parent        = labelFrame,
	})
	local textLabel = make("TextLabel", {
		Size                   = UDim2.new(1, 0, 0, 0),
		AutomaticSize          = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Text                   = text,
		TextColor3             = Color3.fromRGB(170, 170, 170),
		TextSize               = 11,
		Font                   = Enum.Font.Gotham,
		TextXAlignment         = Enum.TextXAlignment.Left,
		TextWrapped            = true,
		RichText               = true,
		Parent                 = labelFrame,
	})
	if self._activeTab then table.insert(self._activeTab.items, labelFrame) end
	if not self._minimized then self:resize() end
	return {
		set = function(v) textLabel.Text = v end,
		get = function()  return textLabel.Text end,
	}
end
function UILibrary:addParagraph(title, body, opts)
	if type(body) == "table" then opts = body; body = opts.Desc or opts.body or "" end
	opts = opts or {}
	local imageId   = opts.Image   or opts.image
	local imageSize = opts.ImageSize or opts.imageSize or 36
	local tintColor = opts.Color   or opts.color
	local buttons   = opts.Buttons or opts.buttons
	local parent, _, layoutOrder = self:_getTarget()
	local row = makeRow(parent, layoutOrder)
	local inner = make("Frame", {
		Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1, Parent = row,
	})
	make("UIListLayout", { Padding=UDim.new(0,4), SortOrder=Enum.SortOrder.LayoutOrder, Parent=inner })
	make("UIPadding", { PaddingLeft=UDim.new(0,10), PaddingRight=UDim.new(0,10), PaddingTop=UDim.new(0,6), PaddingBottom=UDim.new(0,6), Parent=inner })
	if imageId then
		local imgUrl = resolveIcon(imageId) or tostring(imageId)
		local imgRow = make("Frame", {
			Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
			BackgroundTransparency=1, LayoutOrder=0, Parent=inner,
		})
		make("UIListLayout", { FillDirection=Enum.FillDirection.Horizontal,
			VerticalAlignment=Enum.VerticalAlignment.Top,
			Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder, Parent=imgRow })
		local imgSize = tonumber(imageSize) or 36
		local imgLbl = make("ImageLabel", {
			Size=UDim2.new(0,imgSize,0,imgSize), BackgroundTransparency=1,
			Image=imgUrl, LayoutOrder=1, Parent=imgRow,
		})
		addCorner(imgLbl, 6)
		local textCol = make("Frame", {
			Size=UDim2.new(1,-(imgSize+8),0,0), AutomaticSize=Enum.AutomaticSize.Y,
			BackgroundTransparency=1, LayoutOrder=2, Parent=imgRow,
		})
		make("UIListLayout", { Padding=UDim.new(0,3), SortOrder=Enum.SortOrder.LayoutOrder, Parent=textCol })
		local titleLabel2 = make("TextLabel", {
			Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
			BackgroundTransparency=1, Text=title or "",
			TextColor3=Color3.fromRGB(240,240,240), TextSize=13,
			Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left,
			TextWrapped=true, RichText=true, LayoutOrder=1, Parent=textCol,
		})
		local bodyLabel2 = make("TextLabel", {
			Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
			BackgroundTransparency=1, Text=body or "",
			TextColor3=Color3.fromRGB(170,170,170), TextSize=11,
			Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left,
			TextWrapped=true, RichText=true, LayoutOrder=2, Parent=textCol,
		})
		if tintColor == "Red" then
			titleLabel2.TextColor3 = Color3.fromRGB(255,80,80)
			bodyLabel2.TextColor3  = Color3.fromRGB(220,60,60)
		elseif typeof(tintColor) == "Color3" then
			titleLabel2.TextColor3 = tintColor
		end
		if buttons and #buttons > 0 then
			local btnRow = make("Frame", {
				Size=UDim2.new(1,0,0,26), BackgroundTransparency=1,
				LayoutOrder=3, Parent=textCol,
			})
			make("UIListLayout", { FillDirection=Enum.FillDirection.Horizontal,
				Padding=UDim.new(0,6), SortOrder=Enum.SortOrder.LayoutOrder, Parent=btnRow })
			for i, bd in ipairs(buttons) do
				local isSecondary = bd.Variant == "Secondary"
				local b = make("TextButton", {
					Size=UDim2.new(0,0,1,0), AutomaticSize=Enum.AutomaticSize.X,
					BackgroundColor3=isSecondary and Color3.fromRGB(40,40,40) or Color3.fromRGB(50,100,50),
					BackgroundTransparency=0.25, Text=bd.Title or ("Button "..i),
					TextColor3=Color3.fromRGB(255,255,255), TextSize=10,
					Font=Enum.Font.GothamBold, BorderSizePixel=0,
					LayoutOrder=i, Parent=btnRow,
				})
				addCorner(b, 5)
				make("UIPadding",{PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8),Parent=b})
				self._conn(b.MouseButton1Click, function() if bd.Callback then pcall(bd.Callback) end end)
			end
		end
		if self._activeTab then table.insert(self._activeTab.items, row) end
		if not self._minimized then self:resize() end
		return {
			setTitle = function(v) titleLabel2.Text = v end,
			setBody  = function(v) bodyLabel2.Text  = v end,
			SetTitle = function(_, v) titleLabel2.Text = v end,
			SetDesc  = function(_, v) bodyLabel2.Text  = v end,
			getTitle = function() return titleLabel2.Text end,
			getBody  = function() return bodyLabel2.Text  end,
		}
	end
	local titleLabel = make("TextLabel", {
		Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
		BackgroundTransparency=1, Text=title or "",
		TextColor3=Color3.fromRGB(240,240,240), TextSize=13,
		Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left,
		TextWrapped=true, RichText=true, LayoutOrder=1, Parent=inner,
	})
	local bodyLabel = make("TextLabel", {
		Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
		BackgroundTransparency=1, Text=body or "",
		TextColor3=Color3.fromRGB(170,170,170), TextSize=11,
		Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left,
		TextWrapped=true, RichText=true, LayoutOrder=2, Parent=inner,
	})
	if tintColor == "Red" then
		titleLabel.TextColor3 = Color3.fromRGB(255,80,80)
		bodyLabel.TextColor3  = Color3.fromRGB(220,60,60)
	elseif typeof(tintColor) == "Color3" then
		titleLabel.TextColor3 = tintColor
	end
	if buttons and #buttons > 0 then
		local btnRow = make("Frame", {
			Size=UDim2.new(1,0,0,26), BackgroundTransparency=1,
			LayoutOrder=3, Parent=inner,
		})
		make("UIListLayout", { FillDirection=Enum.FillDirection.Horizontal,
			Padding=UDim.new(0,6), SortOrder=Enum.SortOrder.LayoutOrder, Parent=btnRow })
		for i, bd in ipairs(buttons) do
			local isSecondary = bd.Variant == "Secondary"
			local b = make("TextButton", {
				Size=UDim2.new(0,0,1,0), AutomaticSize=Enum.AutomaticSize.X,
				BackgroundColor3=isSecondary and Color3.fromRGB(40,40,40) or Color3.fromRGB(50,100,50),
				BackgroundTransparency=0.25, Text=bd.Title or ("Button "..i),
				TextColor3=Color3.fromRGB(255,255,255), TextSize=10,
				Font=Enum.Font.GothamBold, BorderSizePixel=0,
				LayoutOrder=i, Parent=btnRow,
			})
			addCorner(b, 5)
			make("UIPadding",{PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8),Parent=b})
			self._conn(b.MouseButton1Click, function() if bd.Callback then pcall(bd.Callback) end end)
		end
	end
	if self._activeTab then table.insert(self._activeTab.items, row) end
	if not self._minimized then self:resize() end
	return {
		setTitle = function(v) titleLabel.Text = v end,
		setBody  = function(v) bodyLabel.Text  = v end,
		SetTitle = function(_, v) titleLabel.Text = v end,
		SetDesc  = function(_, v) bodyLabel.Text  = v end,
		getTitle = function() return titleLabel.Text end,
		getBody  = function() return bodyLabel.Text  end,
	}
end
function UILibrary:addStatus(name, initialValue)
	local parent, _, layoutOrder = self:_getTarget()
	local row = makeRow(parent, layoutOrder)
	local inner = make("Frame", {
		Size                   = UDim2.new(1, 0, 0, 0),
		AutomaticSize          = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent                 = row,
	})
	make("UIPadding", {
		PaddingLeft  = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		Parent       = inner,
	})
	make("UIListLayout", {
		FillDirection     = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder         = Enum.SortOrder.LayoutOrder,
		Parent            = inner,
	})
	make("TextLabel", {
		Size                   = UDim2.new(0.5, 0, 0, 26),
		AutomaticSize          = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Text                   = name,
		TextColor3             = Color3.fromRGB(170, 170, 170),
		TextSize               = 11,
		Font                   = Enum.Font.Gotham,
		TextXAlignment         = Enum.TextXAlignment.Left,
		TextWrapped            = true,
		LayoutOrder            = 1,
		Parent                 = inner,
	})
	local valueLabel = make("TextLabel", {
		Size                   = UDim2.new(0.5, 0, 0, 26),
		AutomaticSize          = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Text                   = initialValue or "—",
		TextColor3             = Color3.fromRGB(80, 200, 120),
		TextSize               = 11,
		Font                   = Enum.Font.GothamBold,
		TextXAlignment         = Enum.TextXAlignment.Right,
		TextWrapped            = true,
		LayoutOrder            = 2,
		Parent                 = inner,
	})
	if self._activeTab then table.insert(self._activeTab.items, row) end
	if not self._minimized then self:resize() end
	return {
		set = function(v, color)
			valueLabel.Text = tostring(v)
			if color then valueLabel.TextColor3 = color end
		end,
		get = function() return valueLabel.Text end,
	}
end
function UILibrary:addProgressBar(name, initialValue)
	initialValue = math.clamp(initialValue or 0, 0, 100)
	local parent, _, layoutOrder = self:_getTarget()
	local row     = makeRow(parent, layoutOrder)
	local current = initialValue
	local inner = make("Frame", {
		Size                   = UDim2.new(1, 0, 0, 0),
		AutomaticSize          = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent                 = row,
	})
	make("UIListLayout", {
		Padding   = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent    = inner,
	})
	make("UIPadding", {
		PaddingLeft  = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		PaddingTop   = UDim.new(0, 4),
		Parent       = inner,
	})
	local headerRow = make("Frame", {
		Size                   = UDim2.new(1, 0, 0, 16),
		BackgroundTransparency = 1,
		LayoutOrder            = 1,
		Parent                 = inner,
	})
	make("TextLabel", {
		Size                   = UDim2.new(0.7, 0, 1, 0),
		BackgroundTransparency = 1,
		Text                   = name,
		TextColor3             = Color3.fromRGB(200, 200, 200),
		TextSize               = 11,
		Font                   = Enum.Font.Gotham,
		TextXAlignment         = Enum.TextXAlignment.Left,
		Parent                 = headerRow,
	})
	local pctLabel = make("TextLabel", {
		Size                   = UDim2.new(0.3, 0, 1, 0),
		Position               = UDim2.new(0.7, 0, 0, 0),
		BackgroundTransparency = 1,
		Text                   = tostring(math.floor(current)) .. "%",
		TextColor3             = Color3.fromRGB(140, 140, 140),
		TextSize               = 10,
		Font                   = Enum.Font.Gotham,
		TextXAlignment         = Enum.TextXAlignment.Right,
		Parent                 = headerRow,
	})
	local track = make("Frame", {
		Size             = UDim2.new(1, 0, 0, 8),
		BackgroundColor3 = Color3.fromRGB(35, 35, 35),
		BorderSizePixel  = 0,
		LayoutOrder      = 2,
		Parent           = inner,
	})
	addCorner(track, 4)
	local fill = make("Frame", {
		Size             = UDim2.new(initialValue / 100, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(80, 200, 120),
		BorderSizePixel  = 0,
		Parent           = track,
	})
	addCorner(fill, 4)
	if self._activeTab then table.insert(self._activeTab.items, row) end
	if not self._minimized then self:resize() end
	return {
		set = function(value, color)
			current = math.clamp(value, 0, 100)
			tween(fill, { Size = UDim2.new(current / 100, 0, 1, 0) }, 0.2)
			pctLabel.Text = tostring(math.floor(current)) .. "%"
			if color then tween(fill, { BackgroundColor3 = color }, 0.2) end
		end,
		get = function() return current end,
	}
end
function UILibrary:addPlayerList(labelOrCallback, callback)
	local toggleMode     = false
	local actionLabel    = "Select"
	local actionCallback = nil
	if type(labelOrCallback) == "function" then
		actionCallback = labelOrCallback
		toggleMode     = true
	elseif type(labelOrCallback) == "string" then
		actionLabel    = labelOrCallback
		actionCallback = callback
	end
	local parent, _, layoutOrder = self:_getTarget()
	local wrapper = make("Frame", {
		Size                   = UDim2.new(1, 0, 0, 0),
		AutomaticSize          = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder            = layoutOrder,
		Parent                 = parent,
	})
	make("UIListLayout", {
		Padding   = UDim.new(0, 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent    = wrapper,
	})
	local header = make("Frame", {
		Size                   = UDim2.new(1, 0, 0, 28),
		BackgroundTransparency = 1,
		LayoutOrder            = 1,
		Parent                 = wrapper,
	})
	make("UIPadding", {
		PaddingLeft  = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
		Parent       = header,
	})
	make("UIListLayout", {
		FillDirection     = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder         = Enum.SortOrder.LayoutOrder,
		Parent            = header,
	})
	local countLabel = make("TextLabel", {
		Size                   = UDim2.new(1, -58, 1, 0),
		BackgroundTransparency = 1,
		Text                   = "Players  •  " .. #pl:GetPlayers(),
		TextColor3             = Color3.fromRGB(140, 140, 140),
		TextSize               = 10,
		Font                   = Enum.Font.GothamBold,
		TextXAlignment         = Enum.TextXAlignment.Left,
		LayoutOrder            = 1,
		Parent                 = header,
	})
	local refreshBtn = make("TextButton", {
		Size                   = UDim2.new(0, 54, 0, 20),
		BackgroundColor3       = Color3.fromRGB(30, 30, 30),
		BackgroundTransparency = 0.3,
		Text                   = "↻ Refresh",
		TextColor3             = Color3.fromRGB(160, 160, 160),
		TextSize               = 10,
		Font                   = Enum.Font.Gotham,
		BorderSizePixel        = 0,
		LayoutOrder            = 2,
		Parent                 = header,
	})
	addCorner(refreshBtn, 6)
	local listFrame = make("Frame", {
		Size                   = UDim2.new(1, 0, 0, 0),
		AutomaticSize          = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder            = 2,
		Parent                 = wrapper,
	})
	make("UIListLayout", {
		Padding   = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent    = listFrame,
	})
	make("UIPadding", {
		PaddingTop    = UDim.new(0, 2),
		PaddingBottom = UDim.new(0, 2),
		Parent        = listFrame,
	})
	local libRef         = self
	local selectedPlayer = nil
	local cardMap        = {}
	local pendingThumbs  = {}
	local buildConns     = {}
	local buildConnsSet  = {}
	local function buildList()
		for _, c in ipairs(buildConns) do
			if c and c.Connected then c:Disconnect() end
		end
		for i = #libRef._conns, 1, -1 do
			if buildConnsSet[libRef._conns[i]] then table.remove(libRef._conns, i) end
		end
		buildConns    = {}
		buildConnsSet = {}
		local function bConn(signal, fn)
			local c = signal:Connect(fn)
			table.insert(buildConns, c)
			buildConnsSet[c] = true
			table.insert(libRef._conns, c)
			return c
		end
		for _, pending in ipairs(pendingThumbs) do pending.cancelled = true end
		pendingThumbs  = {}
		selectedPlayer = nil
		cardMap        = {}
		for _, ch in pairs(listFrame:GetChildren()) do
			if not ch:IsA("UIListLayout") and not ch:IsA("UIPadding") then ch:Destroy() end
		end
		local players = pl:GetPlayers()
		countLabel.Text = "Players  •  " .. #players
		for idx, player in ipairs(players) do
			local card = make("Frame", {
				Size                   = UDim2.new(1, 0, 0, 52),
				BackgroundColor3       = Color3.fromRGB(20, 20, 20),
				BackgroundTransparency = 0.4,
				BorderSizePixel        = 0,
				LayoutOrder            = idx,
				Parent                 = listFrame,
			})
			addCorner(card, 10)
			cardMap[player] = card
			local thumbImg = make("ImageLabel", {
				Size                   = UDim2.new(0, 38, 0, 38),
				Position               = UDim2.new(0, 8, 0.5, -19),
				BackgroundColor3       = Color3.fromRGB(30, 30, 30),
				BackgroundTransparency = 0.5,
				BorderSizePixel        = 0,
				Image                  = "",
				Parent                 = card,
			})
			addCorner(thumbImg, 8)
			local textRight = (not toggleMode and actionCallback) and -134 or -58
			make("TextLabel", {
				Size           = UDim2.new(1, textRight, 0, 18),
				Position       = UDim2.new(0, 54, 0, 8),
				BackgroundTransparency = 1,
				Text           = player.DisplayName,
				TextColor3     = Color3.fromRGB(240, 240, 240),
				TextSize       = 12,
				Font           = Enum.Font.GothamBold,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate   = Enum.TextTruncate.AtEnd,
				Parent         = card,
			})
			make("TextLabel", {
				Size           = UDim2.new(1, textRight, 0, 14),
				Position       = UDim2.new(0, 54, 0, 28),
				BackgroundTransparency = 1,
				Text           = "@" .. player.Name,
				TextColor3     = Color3.fromRGB(110, 110, 110),
				TextSize       = 10,
				Font           = Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate   = Enum.TextTruncate.AtEnd,
				Parent         = card,
			})
			if toggleMode then
				local clickBtn = make("TextButton", {
					Size                   = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text                   = "",
					Parent                 = card,
				})
				bConn(clickBtn.MouseButton1Click, function()
					if selectedPlayer and cardMap[selectedPlayer] and cardMap[selectedPlayer].Parent then
						tween(cardMap[selectedPlayer], { BackgroundColor3 = Color3.fromRGB(20, 20, 20), BackgroundTransparency = 0.4 }, 0.15)
					end
					if selectedPlayer == player then
						selectedPlayer = nil
						if actionCallback then pcall(actionCallback, player, false) end
					else
						selectedPlayer = player
						tween(card, { BackgroundColor3 = Color3.fromRGB(20, 80, 30), BackgroundTransparency = 0.25 }, 0.15)
						if actionCallback then pcall(actionCallback, player, true) end
					end
				end)
			else
				if actionCallback then
					local actBtn = make("TextButton", {
						Size                   = UDim2.new(0, 68, 0, 26),
						Position               = UDim2.new(1, -76, 0.5, -13),
						BackgroundColor3       = Color3.fromRGB(35, 35, 35),
						BackgroundTransparency = 0.2,
						Text                   = actionLabel,
						TextColor3             = Color3.fromRGB(220, 220, 220),
						TextSize               = 11,
						Font                   = Enum.Font.Gotham,
						BorderSizePixel        = 0,
						Parent                 = card,
					})
					addCorner(actBtn, 7)
					bConn(actBtn.MouseEnter,        function() tween(actBtn, { BackgroundTransparency = 0.0,  TextColor3 = Color3.fromRGB(255, 255, 255) }, 0.1) end)
					bConn(actBtn.MouseLeave,        function() tween(actBtn, { BackgroundTransparency = 0.2,  TextColor3 = Color3.fromRGB(220, 220, 220) }, 0.1) end)
					bConn(actBtn.MouseButton1Click, function() pcall(actionCallback, player) end)
				end
			end
			local thumbEntry = { cancelled = false }
			table.insert(pendingThumbs, thumbEntry)
			task.spawn(function()
				local ok, img = pcall(function()
					return pl:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
				end)
				if not thumbEntry.cancelled and ok and thumbImg and thumbImg.Parent then
					pcall(function() thumbImg.Image = img end)
				end
			end)
		end
		libRef:resize()
	end
	buildList()
	self._conn(refreshBtn.MouseEnter,        function() tween(refreshBtn, { BackgroundTransparency = 0.05, TextColor3 = Color3.fromRGB(200, 200, 200) }, 0.1) end)
	self._conn(refreshBtn.MouseLeave,        function() tween(refreshBtn, { BackgroundTransparency = 0.3,  TextColor3 = Color3.fromRGB(160, 160, 160) }, 0.1) end)
	self._conn(refreshBtn.MouseButton1Click, function() buildList() end)
	if self._activeTab then table.insert(self._activeTab.items, wrapper) end
	if not self._minimized then self:resize() end
	return {
		refresh     = buildList,
		getSelected = function() return selectedPlayer end,
	}
end
function UILibrary:onClose(fn)
	table.insert(self._closeCallbacks, fn)
end
function UILibrary:onDestroy(fn)
	table.insert(self._closeCallbacks, fn)
end
UILibrary.OnDestroy = UILibrary.onDestroy
function UILibrary:addTag(opts)
	opts = opts or {}
	local tagText  = opts.Title or opts.title or ""
	local tagColor = opts.Color or opts.color or Color3.fromRGB(60,60,60)
	local iconName = opts.Icon  or opts.icon
	local pill = make("Frame", {
		Size             = UDim2.new(0, 0, 0, 18),
		AutomaticSize    = Enum.AutomaticSize.X,
		BackgroundColor3 = type(tagColor) == "userdata" and tagColor or Color3.fromRGB(60,60,60),
		BackgroundTransparency = 0.25,
		BorderSizePixel  = 0,
		LayoutOrder      = #self._tags + 1,
		Parent           = self._tagRow,
	})
	addCorner(pill, 9)
	local xOff = 6
	if iconName then
		local iconUrl = resolveIcon(iconName)
		if iconUrl then
			make("ImageLabel", {
				Size = UDim2.new(0,12,0,12), Position = UDim2.new(0,5,0.5,-6),
				BackgroundTransparency = 1, Image = iconUrl,
				ImageColor3 = Color3.fromRGB(255,255,255), Parent = pill,
			})
			xOff = 20
		end
	end
	local lbl = make("TextLabel", {
		Size = UDim2.new(0,0,1,0), AutomaticSize = Enum.AutomaticSize.X,
		Position = UDim2.fromOffset(xOff, 0),
		BackgroundTransparency = 1,
		Text = tagText, TextColor3 = Color3.fromRGB(255,255,255),
		TextSize = 9, Font = Enum.Font.GothamBold, Parent = pill,
	})
	make("UIPadding", {PaddingRight=UDim.new(0,6), Parent=pill})
	if type(tagColor) == "table" and tagColor._isGradient then
		applyGradientToLabel(lbl, tagColor)
	end
	table.insert(self._tags, pill)
	return { frame = pill, setTitle = function(t) lbl.Text = t end }
end
function UILibrary:addTopbarButton(id, iconName, callback, order)
	self._topbarRow.Visible = true
	local iconUrl = resolveIcon(iconName) or resolveIcon("gear")
	local btn = make("TextButton", {
		Size = UDim2.new(0,24,0,24),
		BackgroundColor3 = Color3.fromRGB(30,30,30),
		BackgroundTransparency = 0.4,
		Text = "", BorderSizePixel = 0,
		LayoutOrder = order or (#self._topbarBtns + 1),
		Parent = self._topbarRow,
	})
	addCorner(btn, 7)
	make("ImageLabel", {
		Size = UDim2.new(0,14,0,14), Position = UDim2.new(0.5,-7,0.5,-7),
		BackgroundTransparency = 1, Image = iconUrl,
		ImageColor3 = Color3.fromRGB(180,180,180), Parent = btn,
	})
	self._conn(btn.MouseEnter, function()
		tween(btn, {BackgroundTransparency=0.1}, 0.12)
	end)
	self._conn(btn.MouseLeave, function()
		tween(btn, {BackgroundTransparency=0.4}, 0.12)
	end)
	self._conn(btn.MouseButton1Click, function()
		if callback then pcall(callback) end
	end)
	self._topbarBtns[id] = btn
	return btn
end
UILibrary.CreateTopbarButton = UILibrary.addTopbarButton
function UILibrary:setTransparency(val)
	self._transparency = math.clamp(val or 0, 0, 0.95)
	if self._transparencyOn then
		tween(self.mainFrame, {BackgroundTransparency = self._transparency}, 0.2)
	end
end
function UILibrary:toggleTransparency(enabled)
	self._transparencyOn = enabled
	local target = enabled and self._transparency or 0.3
	tween(self.mainFrame, {BackgroundTransparency = target}, 0.2)
end
UILibrary.ToggleTransparency = UILibrary.toggleTransparency
function UILibrary:addConnection(signal, fn)
	return self._conn(signal, fn)
end
function UILibrary:notify(title, subtitle, imageId, persistent)
	local _title, _body, _image, _persist = title, subtitle, imageId, persistent
	if type(title) == "table" then
		local t = title
		_title   = t.Title   or t.title
		_body    = t.Content or t.Body or t.body or t.subtitle
		_persist = t.persistent or (t.Duration and t.Duration == 0) or false
		local ico = t.Icon or t.icon or t.Image or t.image
		_image = resolveIcon(ico) or ico
	else
		_image = resolveIcon(imageId) or imageId
	end
	return sendNotif(_title, _body, _image, _persist)
end
function UILibrary:confirm(message, onConfirm, onCancel)
	showConfirmDialog(self.screenGui, message, onConfirm, onCancel)
end
local HUD_CLICK_SOUND = "rbxassetid://94859356677805"
local HUD_HOVER_SOUND = "rbxassetid://94859356677805"
local HUD_CONFIG_KEY  = "MW_HUD_CONFIG"
local HUD_THEMES = {
	Crimson = {
		bar        = Color3.fromRGB(22, 7, 7),
		barStroke  = Color3.fromRGB(130, 18, 32),
		accent     = Color3.fromRGB(180, 20, 40),
		accentHot  = Color3.fromRGB(215, 35, 58),
		accentDim  = Color3.fromRGB(80, 10, 18),
		text       = Color3.fromRGB(255, 232, 232),
		textDim    = Color3.fromRGB(175, 135, 140),
		textMuted  = Color3.fromRGB(110, 75, 80),
		green      = Color3.fromRGB(75, 215, 105),
		yellow     = Color3.fromRGB(225, 195, 55),
		red        = Color3.fromRGB(255, 75, 75),
		panelBg    = Color3.fromRGB(13, 4, 4),
		rowBg      = Color3.fromRGB(24, 7, 9),
		rowInner   = Color3.fromRGB(16, 4, 6),
		tabActive  = Color3.fromRGB(155, 16, 32),
		tabInactive= Color3.fromRGB(35, 10, 13),
		scrollBar  = Color3.fromRGB(180, 20, 40),
		pfpRing    = Color3.fromRGB(180, 20, 40),
		divider    = Color3.fromRGB(130, 18, 32),
		subtext    = Color3.fromRGB(200, 50, 70),
		border     = Color3.fromRGB(130, 18, 32),
	},
	Dark = {
		bar        = Color3.fromRGB(14, 14, 14),
		barStroke  = Color3.fromRGB(55, 55, 55),
		accent     = Color3.fromRGB(60, 60, 60),
		accentHot  = Color3.fromRGB(90, 90, 90),
		accentDim  = Color3.fromRGB(30, 30, 30),
		text       = Color3.fromRGB(240, 240, 240),
		textDim    = Color3.fromRGB(170, 170, 170),
		textMuted  = Color3.fromRGB(110, 110, 110),
		green      = Color3.fromRGB(75, 215, 105),
		yellow     = Color3.fromRGB(225, 195, 55),
		red        = Color3.fromRGB(255, 75, 75),
		panelBg    = Color3.fromRGB(10, 10, 10),
		rowBg      = Color3.fromRGB(20, 20, 20),
		rowInner   = Color3.fromRGB(13, 13, 13),
		tabActive  = Color3.fromRGB(55, 55, 55),
		tabInactive= Color3.fromRGB(22, 22, 22),
		scrollBar  = Color3.fromRGB(80, 80, 80),
		pfpRing    = Color3.fromRGB(80, 200, 120),
		divider    = Color3.fromRGB(50, 50, 50),
		subtext    = Color3.fromRGB(80, 200, 120),
		border     = Color3.fromRGB(55, 55, 55),
	},
	Slate = {
		bar        = Color3.fromRGB(18, 22, 30),
		barStroke  = Color3.fromRGB(45, 60, 90),
		accent     = Color3.fromRGB(50, 90, 180),
		accentHot  = Color3.fromRGB(70, 120, 220),
		accentDim  = Color3.fromRGB(25, 40, 80),
		text       = Color3.fromRGB(230, 235, 255),
		textDim    = Color3.fromRGB(150, 165, 200),
		textMuted  = Color3.fromRGB(90, 105, 140),
		green      = Color3.fromRGB(75, 215, 105),
		yellow     = Color3.fromRGB(225, 195, 55),
		red        = Color3.fromRGB(255, 75, 75),
		panelBg    = Color3.fromRGB(12, 15, 22),
		rowBg      = Color3.fromRGB(20, 25, 38),
		rowInner   = Color3.fromRGB(13, 16, 26),
		tabActive  = Color3.fromRGB(45, 85, 170),
		tabInactive= Color3.fromRGB(22, 28, 42),
		scrollBar  = Color3.fromRGB(50, 90, 180),
		pfpRing    = Color3.fromRGB(70, 120, 220),
		divider    = Color3.fromRGB(45, 60, 90),
		subtext    = Color3.fromRGB(70, 120, 220),
		border     = Color3.fromRGB(45, 60, 90),
	},
}
local function hudPlaySound(id, vol)
	local sd = Instance.new("Sound")
	sd.SoundId            = id
	sd.Volume             = vol or 0.35
	sd.RollOffMaxDistance = 0
	sd.Parent             = ss
	sd:Play()
	db:AddItem(sd, 4)
end
function UILibrary.addHUD(options)
	local existingHud = guiParent:FindFirstChild("MW_HUD_GUI")
	if existingHud then existingHud:Destroy() end
	options = options or {}
	local baseTheme = HUD_THEMES[options.theme] or HUD_THEMES.Crimson
	local C = {}
	for k, v in pairs(baseTheme) do C[k] = v end
	if type(options.theme) == "table" then
		for k, v in pairs(options.theme) do C[k] = v end
	end
	local pos = options.position or "BelowChat"
	local hudCfg = {}
	pcall(function()
		if isfolder(CONFIG_FOLDER) then
			local p = CONFIG_FOLDER .. "/" .. HUD_CONFIG_KEY .. ".json"
			if isfile(p) then hudCfg = hs:JSONDecode(readfile(p)) end
		end
	end)
	local clickSoundOn = hudCfg.clickSoundOn ~= false
	local hoverSoundOn = hudCfg.hoverSoundOn ~= false
	local hoverAssetId = hudCfg.hoverAssetId or HUD_HOVER_SOUND
	local function saveHudCfg()
		pcall(function()
			if not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end
			writefile(CONFIG_FOLDER .. "/" .. HUD_CONFIG_KEY .. ".json", hs:JSONEncode({
				clickSoundOn = clickSoundOn,
				hoverSoundOn = hoverSoundOn,
				hoverAssetId = hoverAssetId,
			}))
		end)
	end
	local function doClick() if clickSoundOn then hudPlaySound(HUD_CLICK_SOUND, 0.35) end end
	local function doHover() if hoverSoundOn then hudPlaySound(hoverAssetId, 0.2)    end end
	local hudGui = make("ScreenGui", {
		Name            = "MW_HUD_GUI",
		ResetOnSpawn    = false,
		ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
		Parent          = guiParent,
	})
	local BAR_W, BAR_H = 520, 40
	local MARGIN       = 14
	local function getBarPosition(collapsed)
		local h = collapsed and 0 or BAR_H
		if pos == "BelowChat"   then return UDim2.new(0, MARGIN, 0, 160) end
		if pos == "BottomLeft"  then return UDim2.new(0, MARGIN, 1, -(h + MARGIN)) end
		if pos == "BottomRight" then return UDim2.new(1, -(BAR_W + MARGIN), 1, -(h + MARGIN)) end
		if pos == "TopRight"    then return UDim2.new(1, -(BAR_W + MARGIN), 0, MARGIN) end
		return UDim2.new(0, MARGIN, 0, MARGIN)
	end
	local bar = make("Frame", {
		Size             = UDim2.new(0, 520, 0, BAR_H),
		Position         = getBarPosition(false),
		BackgroundColor3 = C.bar,
		BackgroundTransparency = 0.06,
		BorderSizePixel  = 0,
		ClipsDescendants = false,
		Parent           = hudGui,
	})
	addCorner(bar, 20)
	make("UIStroke", { Color = C.barStroke, Thickness = 1, Parent = bar })
	local barShadow = make("ImageLabel", {
		Size             = UDim2.new(0, 1, 0, 80),
		Position         = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		Image            = "rbxassetid://8992584561",
		ImageColor3      = C.barStroke,
		ImageTransparency = 0.55,
		BorderSizePixel  = 0,
		ZIndex           = 0,
		Parent           = hudGui,
	})
	game:GetService("RunService").RenderStepped:Connect(function()
		if not bar.Parent then return end
		local ap = bar.AbsolutePosition
		local as = bar.AbsoluteSize
		barShadow.Size     = UDim2.new(0, as.X + 80, 0, 80)
		barShadow.Position = UDim2.new(0, ap.X - 40, 0, ap.Y + as.Y - 20)
	end)
	local barLayout = make("UIListLayout", {
		FillDirection       = Enum.FillDirection.Horizontal,
		VerticalAlignment   = Enum.VerticalAlignment.Center,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		Padding             = UDim.new(0, 0),
		SortOrder           = Enum.SortOrder.LayoutOrder,
		Parent              = bar,
	})
	make("UIPadding", {
		PaddingLeft   = UDim.new(0, 10),
		PaddingRight  = UDim.new(0, 10),
		PaddingTop    = UDim.new(0, 4),
		PaddingBottom = UDim.new(0, 4),
		Parent        = bar,
	})
	local dividerOrder = 0
	local function makeDivider()
		dividerOrder = dividerOrder + 1
		local d = make("Frame", {
			Size             = UDim2.new(0, 1, 0, 20),
			BackgroundColor3 = C.divider,
			BackgroundTransparency = 0.35,
			BorderSizePixel  = 0,
			LayoutOrder      = dividerOrder * 10 + 5,
			Parent           = bar,
		})
		local function spacer(lo)
			make("Frame", {
				Size = UDim2.new(0, 8, 1, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = lo,
				Parent = bar,
			})
		end
		spacer(dividerOrder * 10 + 4)
		spacer(dividerOrder * 10 + 6)
		return d
	end
	local dragActive, dragOrigin, dragStart = false, nil, nil
	bar.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			dragActive = true
			dragOrigin = inp.Position
			dragStart  = bar.Position
		end
	end)
	ui.InputChanged:Connect(function(inp)
		if dragActive and inp.UserInputType == Enum.UserInputType.MouseMovement then
			local d = inp.Position - dragOrigin
			bar.Position = UDim2.new(
				dragStart.X.Scale, dragStart.X.Offset + d.X,
				dragStart.Y.Scale, dragStart.Y.Offset + d.Y
			)
		end
	end)
	ui.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			dragActive = false
		end
	end)
	local playerSection = make("Frame", {
		Size             = UDim2.new(0, 155, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel  = 0,
		LayoutOrder      = 10,
		Parent           = bar,
	})
	make("UIListLayout", {
		FillDirection     = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding           = UDim.new(0, 6),
		Parent            = playerSection,
	})
	local PFP_SIZE = 28
	local pfpImg = make("ImageLabel", {
		Size             = UDim2.new(0, PFP_SIZE, 0, PFP_SIZE),
		BackgroundColor3 = C.accentDim,
		BackgroundTransparency = 0.2,
		BorderSizePixel  = 0,
		Image            = "",
		LayoutOrder      = 1,
		Parent           = playerSection,
	})
	addCorner(pfpImg, PFP_SIZE / 2)
	make("UIStroke", { Color = C.pfpRing, Thickness = 1.2, Parent = pfpImg })
	task.spawn(function()
		local ok, img = pcall(function()
			return pl:GetUserThumbnailAsync(lp.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
		end)
		if ok and pfpImg and pfpImg.Parent then pfpImg.Image = img end
	end)
	local nameCol = make("Frame", {
		Size             = UDim2.new(0, 120, 1, 0),
		BackgroundTransparency = 1,
		LayoutOrder      = 2,
		Parent           = playerSection,
	})
	make("UIListLayout", {
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding           = UDim.new(0, 1),
		Parent            = nameCol,
	})
	make("UIPadding", { PaddingTop = UDim.new(0,4), PaddingBottom = UDim.new(0,4), Parent = nameCol })
	make("TextLabel", {
		Size = UDim2.new(1,0,0,16), BackgroundTransparency = 1,
		Text = lp.DisplayName, TextColor3 = C.text,
		TextSize = 14, Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = nameCol,
	})
	make("TextLabel", {
		Size = UDim2.new(1,0,0,13), BackgroundTransparency = 1,
		Text = "@" .. lp.Name, TextColor3 = C.subtext,
		TextSize = 11, Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = nameCol,
	})
	local clockLabel = make("TextLabel", {
		Size = UDim2.new(1,0,0,11), BackgroundTransparency = 1,
		Text = "", TextColor3 = C.textMuted,
		TextSize = 10, Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left, Parent = nameCol,
	})
	task.spawn(function()
		while hudGui and hudGui.Parent do
			local hh = tonumber(os.date("%H")) or 0
			local mm = os.date("%M")
			local sfx = hh >= 12 and "PM" or "AM"
			hh = hh % 12; if hh == 0 then hh = 12 end
			if clockLabel and clockLabel.Parent then
				clockLabel.Text = hh .. ":" .. mm .. " " .. sfx
			end
			task.wait(5)
		end
	end)
	makeDivider()
	local statsFrame = make("Frame", {
		Size             = UDim2.new(0, 220, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel  = 0,
		LayoutOrder      = 20,
		Parent           = bar,
	})
	make("UIListLayout", {
		FillDirection     = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding           = UDim.new(0, 12),
		Parent            = statsFrame,
	})
	local function makeStatChip(dotColor, initText)
		local chip = make("Frame", {
			Size = UDim2.new(0,0,0,22), AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1, Parent = statsFrame,
		})
		make("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 5), Parent = chip,
		})
		local dot = make("Frame", {
			Size = UDim2.new(0,6,0,6), BackgroundColor3 = dotColor,
			BorderSizePixel = 0, Parent = chip,
		})
		addCorner(dot, 3)
		local lbl = make("TextLabel", {
			Size = UDim2.new(0,0,1,0), AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1, Text = initText,
			TextColor3 = C.text, TextSize = 10, Font = Enum.Font.GothamBold,
			Parent = chip,
		})
		return lbl, dot
	end
	local fpsLabel,  fpsDot  = makeStatChip(C.green,    "FPS —")
	local pingLabel, pingDot = makeStatChip(C.green,    "PING —")
	local execLabel, _       = makeStatChip(C.textMuted, "—")
	local execName = "Script"
	pcall(function() if identifyexecutor then execName = identifyexecutor() end end)
	execLabel.Text       = execName
	execLabel.TextColor3 = C.textDim
	local gameLabel, _ = makeStatChip(C.textMuted, "—")
	gameLabel.TextColor3 = C.textDim
	task.spawn(function()
		local ok, name = pcall(function()
			return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
		end)
		if ok and name and gameLabel and gameLabel.Parent then
			if #name > 20 then name = name:sub(1, 18) .. ".." end
			gameLabel.Text = name
		end
	end)
	local fpsCount, lastFpsTick = 0, tick()
	local fpsCon = game:GetService("RunService").RenderStepped:Connect(function()
		fpsCount = fpsCount + 1
		local now = tick()
		if now - lastFpsTick >= 0.5 then
			local fps = math.round(fpsCount / (now - lastFpsTick))
			local fc  = fps >= 55 and C.green or fps >= 30 and C.yellow or C.red
			fpsLabel.Text           = "FPS " .. fps
			fpsLabel.TextColor3     = fc
			fpsDot.BackgroundColor3 = fc
			fpsCount    = 0
			lastFpsTick = now
		end
	end)
	local pingCon = game:GetService("RunService").Heartbeat:Connect(function()
		local ok, p = pcall(function()
			return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
		end)
		if not ok then return end
		local pi = math.round(p)
		local pc = pi <= 80 and C.green or pi <= 150 and C.yellow or C.red
		pingLabel.Text           = "PING " .. pi .. "ms"
		pingLabel.TextColor3     = pc
		pingDot.BackgroundColor3 = pc
	end)
	makeDivider()
	local iconRow = make("Frame", {
		Size             = UDim2.new(0, 80, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel  = 0,
		LayoutOrder      = 30,
		Parent           = bar,
	})
	make("UIListLayout", {
		FillDirection       = Enum.FillDirection.Horizontal,
		VerticalAlignment   = Enum.VerticalAlignment.Center,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		Padding             = UDim.new(0, 5),
		Parent              = iconRow,
	})
	local function makeIconBtn(assetId)
		local canvas = make("Frame", {
			Size             = UDim2.new(0, 30, 0, 30),
			BackgroundTransparency = 1,
			BorderSizePixel  = 0,
			ClipsDescendants = false,
			Parent           = iconRow,
		})
		local glow = make("ImageLabel", {
			Size             = UDim2.new(1, 36, 1, 36),
			Position         = UDim2.new(0, -18, 0, -13),
			BackgroundTransparency = 1,
			Image            = "rbxassetid://8992230903",
			ImageColor3      = C.accent,
			ImageTransparency = 1,
			BorderSizePixel  = 0,
			ZIndex           = 0,
			Parent           = canvas,
		})
		local btn = make("TextButton", {
			Size             = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = C.rowInner,
			BackgroundTransparency = 0.1,
			Text             = "",
			BorderSizePixel  = 0,
			ZIndex           = 1,
			Parent           = canvas,
		})
		addCorner(btn, 8)
		make("UIStroke", { Color = C.textDim, Thickness = 1, Transparency = 0.75, Parent = btn })
		local img = make("ImageLabel", {
			Size             = UDim2.new(0, 18, 0, 18),
			Position         = UDim2.new(0.5, -9, 0.5, -9),
			BackgroundTransparency = 1,
			Image            = "rbxassetid://" .. assetId,
			ImageColor3      = C.textDim,
			BorderSizePixel  = 0,
			ZIndex           = 2,
			Parent           = btn,
		})
		btn.MouseEnter:Connect(function()
			doHover()
			tween(btn,  { BackgroundTransparency = 0.0, BackgroundColor3 = C.accent }, 0.12)
			tween(img,  { ImageColor3 = C.text }, 0.12)
			tween(glow, { ImageTransparency = 0.6 }, 0.15)
		end)
		btn.MouseLeave:Connect(function()
			tween(btn,  { BackgroundTransparency = 0.1, BackgroundColor3 = C.rowInner }, 0.12)
			tween(img,  { ImageColor3 = C.textDim }, 0.12)
			tween(glow, { ImageTransparency = 1 }, 0.15)
		end)
		btn.MouseButton1Click:Connect(doClick)
		return btn, img, glow
	end
	local serverBrowserBtn, sbImg, sbGlow = makeIconBtn("8992259774")
	local settingsBtn,      stImg, stGlow = makeIconBtn("8992031056")
	local terminalBtn,      tmImg, tmGlow = makeIconBtn("8992030918")
	local CMD_W, CMD_H_OPEN = 320, 220
	local cmdPanel = make("Frame", {
		Size             = UDim2.new(0, CMD_W, 0, CMD_H_OPEN),
		Position         = UDim2.new(0, 14, 0, 60),
		BackgroundColor3 = C.panelBg,
		BackgroundTransparency = 0.04,
		BorderSizePixel  = 0,
		Visible          = false,
		ZIndex           = 60,
		Parent           = hudGui,
	})
	addCorner(cmdPanel, 12)
	make("UIStroke", { Color = C.barStroke, Thickness = 1.2, Parent = cmdPanel })
	make("ImageLabel", {
		Size = UDim2.new(1, 100, 0, 100), Position = UDim2.new(0, -50, 1, -30),
		BackgroundTransparency = 1, Image = "rbxassetid://8992584561",
		ImageColor3 = C.barStroke, ImageTransparency = 0.55,
		BorderSizePixel = 0, ZIndex = 59, Parent = cmdPanel,
	})
	local inputRow = make("Frame", {
		Size             = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = C.rowBg,
		BackgroundTransparency = 0.0,
		BorderSizePixel  = 0,
		ZIndex           = 61,
		Parent           = cmdPanel,
	})
	addCorner(inputRow, 12)
	make("Frame", {
		Size = UDim2.new(1,0,0.5,0), Position = UDim2.new(0,0,0.5,0),
		BackgroundColor3 = C.rowBg, BorderSizePixel = 0, ZIndex = 61, Parent = inputRow,
	})
	make("UIStroke", { Color = C.barStroke, Thickness = 1, Transparency = 0.5, Parent = inputRow })
	make("TextLabel", {
		Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1, Text = ">",
		TextColor3 = C.accent, TextSize = 14, Font = Enum.Font.Code,
		ZIndex = 62, Parent = inputRow,
	})
	local cmdInput = make("TextBox", {
		Size             = UDim2.new(1, -36, 1, 0),
		Position         = UDim2.new(0, 28, 0, 0),
		BackgroundTransparency = 1,
		Text             = "",
		PlaceholderText  = "type a command...",
		TextColor3       = C.text,
		PlaceholderColor3 = C.textMuted,
		TextSize         = 12,
		Font             = Enum.Font.Gotham,
		BorderSizePixel  = 0,
		ClearTextOnFocus = false,
		TextXAlignment   = Enum.TextXAlignment.Left,
		ZIndex           = 62,
		Parent           = inputRow,
	})
	local suggestScroll = make("ScrollingFrame", {
		Size             = UDim2.new(1, 0, 1, -40),
		Position         = UDim2.new(0, 0, 0, 38),
		BackgroundTransparency = 1,
		BorderSizePixel  = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = C.scrollBar,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize       = UDim2.new(0,0,0,0),
		ZIndex           = 61,
		Parent           = cmdPanel,
	})
	local suggestLayout = make("UIListLayout", {
		Padding   = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent    = suggestScroll,
	})
	make("UIPadding", { PaddingLeft=UDim.new(0,6), PaddingRight=UDim.new(0,6), PaddingTop=UDim.new(0,4), Parent=suggestScroll })
	local topSuggestion = nil
	local function buildSuggestions(text)
		for _, c in pairs(suggestScroll:GetChildren()) do
			if c:IsA("TextButton") then c:Destroy() end
		end
		topSuggestion = nil
		if text == "" then return end
		local cmdList = _G.MWCmds and _G.MWCmds._cmdNames or {}
		local lo = 0
		for _, name in ipairs(cmdList) do
			if name:lower():sub(1, #text) == text:lower() then
				lo = lo + 1
				if lo > 12 then break end
				if topSuggestion == nil then topSuggestion = name end
				local btn = make("TextButton", {
					Size             = UDim2.new(1, 0, 0, 24),
					BackgroundColor3 = lo == 1 and C.accentDim or C.rowBg,
					BackgroundTransparency = 0.0,
					Text             = "",
					BorderSizePixel  = 0,
					LayoutOrder      = lo,
					ZIndex           = 62,
					Parent           = suggestScroll,
				})
				addCorner(btn, 6)
				local dot = make("Frame", {
					Size = UDim2.new(0,4,0,4), Position = UDim2.new(0,8,0.5,-2),
					BackgroundColor3 = lo == 1 and C.accent or C.textMuted,
					BorderSizePixel = 0, ZIndex = 63, Parent = btn,
				})
				addCorner(dot, 2)
				make("TextLabel", {
					Size = UDim2.new(1,-20,1,0), Position = UDim2.new(0,18,0,0),
					BackgroundTransparency = 1,
					Text = name,
					TextColor3 = lo == 1 and C.text or C.textDim,
					TextSize = 11, Font = lo == 1 and Enum.Font.GothamBold or Enum.Font.Gotham,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 63, Parent = btn,
				})
				btn.MouseEnter:Connect(function()
					tween(btn, { BackgroundColor3 = C.accentDim }, 0.1)
				end)
				btn.MouseLeave:Connect(function()
					tween(btn, { BackgroundColor3 = lo==1 and C.accentDim or C.rowBg }, 0.1)
				end)
				local capName = name
				btn.MouseButton1Click:Connect(function()
					cmdInput.Text = capName .. " "
					cmdInput:CaptureFocus()
					cmdInput.CursorPosition = #cmdInput.Text + 1
				end)
			end
		end
	end
	cmdInput:GetPropertyChangedSignal("Text"):Connect(function()
		local txt = cmdInput.Text
		if txt:sub(1,1) == "'" then txt = txt:sub(2) end
		local word = txt:match("^(%S*)") or ""
		buildSuggestions(word)
	end)
	ui.InputBegan:Connect(function(inp, gp)
		if gp then return end
		if inp.KeyCode == Enum.KeyCode.Tab and cmdInput:IsFocused() and topSuggestion then
			cmdInput.Text = topSuggestion .. " "
			cmdInput.CursorPosition = #cmdInput.Text + 1
		end
	end)
	cmdInput.FocusLost:Connect(function(enter)
		if not enter then return end
		local txt = cmdInput.Text:gsub("^%s+",""):gsub("%s+$","")
		if txt == "" then return end
		if txt:sub(1,1) == "'" then txt = txt:sub(2) end
		if _G.MWCmds then
			_G.MWCmds.execCmd(txt, nil, true)
		end
		cmdInput.Text = ""
		buildSuggestions("")
	end)
	terminalBtn.MouseButton1Click:Connect(function()
		if cmdPanel.Visible then
			cmdPanel.Visible = false
		else
			sbPanel.Visible  = false
			setPanel.Visible = false
			local barAP = bar.AbsolutePosition
			local barAS = bar.AbsoluteSize
			cmdPanel.Position = UDim2.new(0, barAP.X, 0, barAP.Y + barAS.Y + 10)
			cmdPanel.Visible = true
			cmdInput:CaptureFocus()
		end
	end)
	bar:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		if cmdPanel.Visible then
			local barAP = bar.AbsolutePosition
			local barAS = bar.AbsoluteSize
			cmdPanel.Position = UDim2.new(0, barAP.X, 0, barAP.Y + barAS.Y + 10)
		end
	end)
	local collapsed   = false
	local isBottom    = (pos == "BottomLeft" or pos == "BottomRight")
	local arrowDown   = not isBottom
	local collapseBtn = make("TextButton", {
		Size             = UDim2.new(0, 48, 0, 12),
		AnchorPoint      = Vector2.new(0.5, 0),
		Position         = isBottom and UDim2.new(0.5, 0, 0, -15) or UDim2.new(0.5, 0, 1, 3),
		BackgroundColor3 = C.accentDim,
		BackgroundTransparency = 0.25,
		Text             = isBottom and "v" or "^",
		TextColor3       = C.textMuted,
		TextSize         = 9,
		Font             = Enum.Font.GothamBold,
		BorderSizePixel  = 0,
		Parent           = bar,
	})
	addCorner(collapseBtn, 6)
	collapseBtn.MouseButton1Click:Connect(function()
		doClick()
		collapsed = not collapsed
		if collapsed then
			tween(bar, { Size = UDim2.new(0, 520, 0, 0) }, 0.2)
			collapseBtn.Text  = isBottom and "^" or "v"
		else
			tween(bar, { Size = UDim2.new(0, 520, 0, BAR_H) }, 0.2)
			collapseBtn.Text  = isBottom and "v" or "^"
		end
	end)
	local SB_W, SB_H = 440, 340
	local sbPanel = make("Frame", {
		Size             = UDim2.new(0, SB_W, 0, SB_H),
		Position         = UDim2.new(0, 14, 0, 60),
		BackgroundColor3 = C.panelBg,
		BackgroundTransparency = 0.04,
		BorderSizePixel  = 0,
		Visible          = false,
		ZIndex           = 50,
		Parent           = hudGui,
	})
	addCorner(sbPanel, 12)
	make("UIStroke", { Color = C.border, Thickness = 1.2, Parent = sbPanel })
	make("ImageLabel", {
		Size = UDim2.new(1, 100, 0, 100), Position = UDim2.new(0, -50, 1, -30),
		BackgroundTransparency = 1, Image = "rbxassetid://8992584561",
		ImageColor3 = C.barStroke, ImageTransparency = 0.55,
		BorderSizePixel = 0, ZIndex = 49, Parent = sbPanel,
	})
	local sbTitle = make("Frame", {
		Size             = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = C.accent,
		BackgroundTransparency = 0.15,
		BorderSizePixel  = 0,
		ZIndex           = 51,
		Parent           = sbPanel,
	})
	addCorner(sbTitle, 12)
	make("Frame", { Size = UDim2.new(1,0,0.5,0), Position = UDim2.new(0,0,0.5,0), BackgroundColor3 = C.accent, BackgroundTransparency = 0.15, BorderSizePixel = 0, ZIndex = 51, Parent = sbTitle })
	make("TextLabel", {
		Size = UDim2.new(1,-80,1,0), Position = UDim2.new(0,12,0,0),
		BackgroundTransparency = 1, Text = "🌐  SERVER BROWSER",
		TextColor3 = C.text, TextSize = 12, Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 52, Parent = sbTitle,
	})
	local sbClose = make("TextButton", {
		Size = UDim2.new(0,24,0,24), Position = UDim2.new(1,-28,0.5,-12),
		BackgroundColor3 = C.accentDim, BackgroundTransparency = 0.2,
		Text = "✕", TextColor3 = C.text, TextSize = 11, Font = Enum.Font.GothamBold,
		BorderSizePixel = 0, ZIndex = 52, Parent = sbTitle,
	})
	addCorner(sbClose, 6)
	sbClose.MouseButton1Click:Connect(function() doClick() sbPanel.Visible = false end)
	local sbTopBar = make("Frame", {
		Size = UDim2.new(1,-16,0,26), Position = UDim2.new(0,8,0,42),
		BackgroundTransparency = 1, ZIndex = 51, Parent = sbPanel,
	})
	local sbStatus = make("TextLabel", {
		Size = UDim2.new(0.5,0,1,0), BackgroundTransparency = 1,
		Text = "Ready", TextColor3 = C.textDim, TextSize = 10,
		Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 52, Parent = sbTopBar,
	})
	local sbCount = make("TextLabel", {
		Size = UDim2.new(0.25,0,1,0), Position = UDim2.new(0.5,0,0,0),
		BackgroundTransparency = 1, Text = "", TextColor3 = C.accentHot,
		TextSize = 10, Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 52, Parent = sbTopBar,
	})
	local sbRefresh = make("TextButton", {
		Size = UDim2.new(0,80,0,22), Position = UDim2.new(1,-80,0.5,-11),
		BackgroundColor3 = C.accent, BackgroundTransparency = 0.2,
		Text = "🔄 Refresh", TextColor3 = C.text, TextSize = 10,
		Font = Enum.Font.GothamBold, BorderSizePixel = 0, ZIndex = 52, Parent = sbTopBar,
	})
	addCorner(sbRefresh, 6)
	sbRefresh.MouseEnter:Connect(function() tween(sbRefresh, { BackgroundColor3 = C.accentHot }, 0.1) end)
	sbRefresh.MouseLeave:Connect(function() tween(sbRefresh, { BackgroundColor3 = C.accent }, 0.1) end)
	local sbTabBar = make("Frame", {
		Size = UDim2.new(1,-16,0,24), Position = UDim2.new(0,8,0,74),
		BackgroundColor3 = C.panelBg, BackgroundTransparency = 0.0,
		BorderSizePixel = 0, ZIndex = 51, Parent = sbPanel,
	})
	addCorner(sbTabBar, 8)
	make("UIStroke", { Color = C.border, Thickness = 1, Parent = sbTabBar })
	local SB_TABS = { "All", "Low Ping", "Most Players", "Few Players" }
	local sbActiveTab = "All"
	local sbTabBtns = {}
	local tabW4 = 1 / #SB_TABS
	local function setSbTab(name)
		sbActiveTab = name
		for _, t in pairs(sbTabBtns) do
			if t.name == name then
				tween(t.btn, { BackgroundColor3 = C.tabActive }, 0.12)
				t.lbl.TextColor3 = C.text
			else
				tween(t.btn, { BackgroundColor3 = C.tabInactive }, 0.12)
				t.lbl.TextColor3 = C.textMuted
			end
		end
	end
	for i, tabName in ipairs(SB_TABS) do
		local btn = make("TextButton", {
			Size = UDim2.new(tabW4, -2, 1, 0),
			Position = UDim2.new(tabW4*(i-1), 1, 0, 0),
			BackgroundColor3 = i==1 and C.tabActive or C.tabInactive,
			Text = "", BorderSizePixel = 0, ZIndex = 52, Parent = sbTabBar,
		})
		addCorner(btn, 6)
		local lbl = make("TextLabel", {
			Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1,
			Text = tabName, TextColor3 = i==1 and C.text or C.textMuted,
			TextSize = 9, Font = Enum.Font.GothamBold, ZIndex = 53, Parent = btn,
		})
		table.insert(sbTabBtns, { name = tabName, btn = btn, lbl = lbl })
		btn.MouseButton1Click:Connect(function()
			doClick()
			setSbTab(tabName)
			task.spawn(function() sbRenderServers() end)
		end)
	end
	make("Frame", {
		Size = UDim2.new(1,-16,0,1), Position = UDim2.new(0,8,0,103),
		BackgroundColor3 = C.border, BackgroundTransparency = 0.4,
		BorderSizePixel = 0, ZIndex = 51, Parent = sbPanel,
	})
	local sbScroll = make("ScrollingFrame", {
		Size = UDim2.new(1,-16,1,-108), Position = UDim2.new(0,8,0,106),
		BackgroundTransparency = 1, BorderSizePixel = 0,
		ScrollBarThickness = 3, ScrollBarImageColor3 = C.scrollBar,
		ScrollBarImageTransparency = 0.3,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(0,0,0,0),
		ZIndex = 51, Parent = sbPanel,
	})
	make("UIListLayout", { Padding = UDim.new(0,2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = sbScroll })
	local sbAllServers = {}
	local function sbPingColor(p)
		return p <= 80 and C.green or p <= 150 and C.yellow or C.red
	end
	local function sbBuildRow(idx, server)
		local isCurrent = server.id == game.JobId
		local playing   = server.playing or 0
		local maxP      = math.max(server.maxPlayers or 1, 1)
		local ping      = server.ping or math.random(40,200)
		local isFull    = playing >= maxP
		local fillPct   = playing / maxP
		local row = make("Frame", {
			Size             = UDim2.new(1,0,0,36),
			BackgroundColor3 = isCurrent and C.accentDim or C.rowBg,
			BackgroundTransparency = 0.0,
			BorderSizePixel  = 0, LayoutOrder = idx, ZIndex = 52, Parent = sbScroll,
		})
		addCorner(row, 8)
		make("UIStroke", {
			Color = isCurrent and C.accent or C.barStroke,
			Thickness = 1, Transparency = isCurrent and 0.3 or 0.7,
			Parent = row,
		})
		local fillBg = make("Frame", {
			Size = UDim2.new(fillPct, 0, 1, 0),
			BackgroundColor3 = C.rowInner,
			BackgroundTransparency = 0.0, BorderSizePixel = 0, ZIndex = 52, Parent = row,
		})
		addCorner(fillBg, 8)
		local statusBar = make("Frame", {
			Size = UDim2.new(0,2,0.5,0), Position = UDim2.new(0,0,0.25,0),
			BackgroundColor3 = isCurrent and C.accent or sbPingColor(ping),
			BorderSizePixel = 0, ZIndex = 53, Parent = row,
		})
		addCorner(statusBar, 1)
		make("TextLabel", {
			Size = UDim2.new(0,22,1,0), Position = UDim2.new(0,6,0,0),
			BackgroundTransparency = 1, Text = string.format("%02d", idx),
			TextColor3 = C.textMuted, TextSize = 9, Font = Enum.Font.GothamBold,
			ZIndex = 53, Parent = row,
		})
		make("TextLabel", {
			Size = UDim2.new(0,70,1,0), Position = UDim2.new(0,30,0,0),
			BackgroundTransparency = 1, Text = playing .. "/" .. maxP,
			TextColor3 = isFull and C.red or C.text,
			TextSize = 13, Font = Enum.Font.GothamBold, ZIndex = 53, Parent = row,
		})
		local pingStr = ping <= 80 and ("🟢 "..ping.."ms") or ping <= 150 and ("🟡 "..ping.."ms") or ("🔴 "..ping.."ms")
		make("TextLabel", {
			Size = UDim2.new(0,90,1,0), Position = UDim2.new(0,106,0,0),
			BackgroundTransparency = 1, Text = pingStr,
			TextColor3 = sbPingColor(ping), TextSize = 10, Font = Enum.Font.GothamBold,
			ZIndex = 53, Parent = row,
		})
		make("TextLabel", {
			Size = UDim2.new(0,80,1,0), Position = UDim2.new(0,202,0,0),
			BackgroundTransparency = 1, Text = server.id:sub(1,7) .. "..",
			TextColor3 = C.textMuted, TextSize = 9, Font = Enum.Font.Code,
			ZIndex = 53, Parent = row,
		})
		local joinBtn = make("TextButton", {
			Size = UDim2.new(0,60,0,24), Position = UDim2.new(1,-64,0.5,-12),
			BackgroundColor3 = isCurrent and C.accentDim or isFull and Color3.fromRGB(60,10,10) or C.accent,
			BackgroundTransparency = 0.15,
			Text = isCurrent and "✅ HERE" or isFull and "FULL" or "JOIN",
			TextColor3 = isCurrent and C.green or isFull and C.red or C.text,
			TextSize = 10, Font = Enum.Font.GothamBold, BorderSizePixel = 0,
			Active = not isCurrent and not isFull, ZIndex = 53, Parent = row,
		})
		addCorner(joinBtn, 5)
		if not isCurrent and not isFull then
			joinBtn.MouseEnter:Connect(function() tween(joinBtn, { BackgroundColor3 = C.accentHot }, 0.1) end)
			joinBtn.MouseLeave:Connect(function() tween(joinBtn, { BackgroundColor3 = C.accent }, 0.1) end)
			joinBtn.MouseButton1Click:Connect(function()
				doClick()
				joinBtn.Text = "⏳"
				sbStatus.Text = "🚀 Joining #" .. idx
				task.wait(0.3)
				game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, server.id, lp)
			end)
		end
	end
	function sbRenderServers()
		for _, c in ipairs(sbScroll:GetChildren()) do
			if not c:IsA("UIListLayout") then c:Destroy() end
		end
		local filtered = {}
		for _, s in ipairs(sbAllServers) do
			local playing = s.playing or 0
			local maxP    = math.max(s.maxPlayers or 1, 1)
			local ping    = s.ping or 999
			if sbActiveTab == "All" then
				table.insert(filtered, s)
			elseif sbActiveTab == "Low Ping" then
				if ping <= 80 then table.insert(filtered, s) end
			elseif sbActiveTab == "Most Players" then
				if playing / maxP >= 0.5 then table.insert(filtered, s) end
			elseif sbActiveTab == "Few Players" then
				if playing / maxP < 0.25 then table.insert(filtered, s) end
			end
		end
		if sbActiveTab == "Low Ping" then
			table.sort(filtered, function(a,b) return (a.ping or 999) < (b.ping or 999) end)
		elseif sbActiveTab == "Most Players" then
			table.sort(filtered, function(a,b) return (a.playing or 0) > (b.playing or 0) end)
		elseif sbActiveTab == "Few Players" then
			table.sort(filtered, function(a,b) return (a.playing or 0) < (b.playing or 0) end)
		else
			table.sort(filtered, function(a,b)
				if a.id == game.JobId then return true end
				if b.id == game.JobId then return false end
				return (a.playing or 0) > (b.playing or 0)
			end)
		end
		if #filtered == 0 then
			make("TextLabel", {
				Size = UDim2.new(1,0,0,50), BackgroundTransparency = 1,
				Text = "No servers found for this filter.",
				TextColor3 = C.textMuted, TextSize = 11, Font = Enum.Font.Gotham,
				ZIndex = 52, Parent = sbScroll,
			})
		end
		for i, s in ipairs(filtered) do sbBuildRow(i, s) end
		sbCount.Text = #filtered .. "/" .. #sbAllServers
	end
	local function sbLoadServers()
		sbAllServers = {}
		sbStatus.Text = "⏳ Loading..."
		sbStatus.TextColor3 = C.yellow
		sbCount.Text  = ""
		sbRefresh.Text = "⏳ ..."
		sbRefresh.Active = false
		for _, c in ipairs(sbScroll:GetChildren()) do
			if not c:IsA("UIListLayout") then c:Destroy() end
		end
		local seen = {}
		local function fetchPage(sort, maxPg)
			local cursor = ""
			local pages  = 0
			repeat
				local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=" .. sort .. "&limit=100" .. (cursor ~= "" and "&cursor=" .. cursor or "")
				local ok, result = pcall(function() return hs:JSONDecode(game:HttpGet(url)) end)
				if not ok or not result or not result.data then break end
				for _, s in ipairs(result.data) do
					if not seen[s.id] then
						seen[s.id] = true
						table.insert(sbAllServers, s)
					end
				end
				cursor = result.nextPageCursor or ""
				pages  = pages + 1
				task.wait(0.1)
			until cursor == "" or pages >= maxPg
		end
		fetchPage("Desc", 3)
		fetchPage("Asc",  3)
		if not seen[game.JobId] then
			table.insert(sbAllServers, 1, {
				id = game.JobId, playing = #pl:GetPlayers(),
				maxPlayers = pl.MaxPlayers, ping = 50,
			})
		end
		sbStatus.Text = "✅ Loaded"
		sbStatus.TextColor3 = C.green
		sbRefresh.Text = "🔄 Refresh"
		sbRefresh.Active = true
		sbRenderServers()
	end
	sbRefresh.MouseButton1Click:Connect(function()
		doClick()
		task.spawn(sbLoadServers)
	end)
	serverBrowserBtn.MouseButton1Click:Connect(function()
		if sbPanel.Visible then
			sbPanel.Visible = false
		else
			sbPanel.Visible = true
			if #sbAllServers == 0 then task.spawn(sbLoadServers) end
		end
	end)
	local SET_W, SET_H = 280, 220
	local setPanel = make("Frame", {
		Size             = UDim2.new(0, SET_W, 0, SET_H),
		Position         = UDim2.new(0, 14, 0, 60),
		BackgroundColor3 = C.panelBg,
		BackgroundTransparency = 0.04,
		BorderSizePixel  = 0,
		Visible          = false,
		ZIndex           = 50,
		Parent           = hudGui,
	})
	addCorner(setPanel, 12)
	make("UIStroke", { Color = C.border, Thickness = 1.2, Parent = setPanel })
	make("ImageLabel", {
		Size = UDim2.new(1, 100, 0, 100), Position = UDim2.new(0, -50, 1, -30),
		BackgroundTransparency = 1, Image = "rbxassetid://8992584561",
		ImageColor3 = C.barStroke, ImageTransparency = 0.55,
		BorderSizePixel = 0, ZIndex = 49, Parent = setPanel,
	})
	local setTitle = make("Frame", {
		Size = UDim2.new(1,0,0,36),
		BackgroundColor3 = C.accent, BackgroundTransparency = 0.15,
		BorderSizePixel = 0, ZIndex = 51, Parent = setPanel,
	})
	addCorner(setTitle, 12)
	make("Frame", { Size = UDim2.new(1,0,0.5,0), Position = UDim2.new(0,0,0.5,0), BackgroundColor3 = C.accent, BackgroundTransparency = 0.15, BorderSizePixel = 0, ZIndex = 51, Parent = setTitle })
	make("TextLabel", {
		Size = UDim2.new(1,-44,1,0), Position = UDim2.new(0,12,0,0),
		BackgroundTransparency = 1, Text = "⚙️  SETTINGS",
		TextColor3 = C.text, TextSize = 12, Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 52, Parent = setTitle,
	})
	local setClose = make("TextButton", {
		Size = UDim2.new(0,24,0,24), Position = UDim2.new(1,-28,0.5,-12),
		BackgroundColor3 = C.accentDim, BackgroundTransparency = 0.2,
		Text = "✕", TextColor3 = C.text, TextSize = 11, Font = Enum.Font.GothamBold,
		BorderSizePixel = 0, ZIndex = 52, Parent = setTitle,
	})
	addCorner(setClose, 6)
	setClose.MouseButton1Click:Connect(function() doClick() setPanel.Visible = false end)
	local setContent = make("Frame", {
		Size = UDim2.new(1,-16,1,-44), Position = UDim2.new(0,8,0,44),
		BackgroundTransparency = 1, ZIndex = 51, Parent = setPanel,
	})
	make("UIListLayout", {
		Padding = UDim.new(0,8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = setContent,
	})
	make("UIPadding", { PaddingTop = UDim.new(0,8), Parent = setContent })
	local function setSection(text, order)
		local lbl = make("TextLabel", {
			Size = UDim2.new(1,0,0,14), BackgroundTransparency = 1,
			Text = text, TextColor3 = C.textMuted, TextSize = 9,
			Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = order, ZIndex = 52, Parent = setContent,
		})
		return lbl
	end
	local function setToggleRow(labelText, initVal, order, onChange)
		local row = make("Frame", {
			Size = UDim2.new(1,0,0,28),
			BackgroundColor3 = C.rowBg, BackgroundTransparency = 0.0,
			BorderSizePixel = 0, LayoutOrder = order, ZIndex = 52, Parent = setContent,
		})
		addCorner(row, 8)
		make("UIStroke", { Color = C.barStroke, Thickness = 1, Transparency = 0.65, Parent = row })
		make("TextLabel", {
			Size = UDim2.new(1,-52,1,0), Position = UDim2.new(0,10,0,0),
			BackgroundTransparency = 1, Text = labelText,
			TextColor3 = C.text, TextSize = 11, Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 53, Parent = row,
		})
		local track = make("Frame", {
			Size = UDim2.new(0,34,0,18), Position = UDim2.new(1,-42,0.5,-9),
			BackgroundColor3 = initVal and C.accent or Color3.fromRGB(50,50,50),
			BorderSizePixel = 0, ZIndex = 53, Parent = row,
		})
		addCorner(track, 9)
		local knob = make("Frame", {
			Size = UDim2.new(0,13,0,13),
			Position = initVal and UDim2.new(0,18,0.5,-6.5) or UDim2.new(0,3,0.5,-6.5),
			BackgroundColor3 = Color3.fromRGB(255,255,255), BorderSizePixel = 0,
			ZIndex = 54, Parent = track,
		})
		addCorner(knob, 7)
		local state = initVal
		local clickBtn = make("TextButton", {
			Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "",
			ZIndex = 55, Parent = row,
		})
		clickBtn.MouseButton1Click:Connect(function()
			doClick()
			state = not state
			tween(track, { BackgroundColor3 = state and C.accent or Color3.fromRGB(50,50,50) }, 0.15)
			tween(knob,  { Position = state and UDim2.new(0,18,0.5,-6.5) or UDim2.new(0,3,0.5,-6.5) }, 0.15)
			if onChange then onChange(state) end
			saveHudCfg()
		end)
		return row
	end
	setSection("SOUNDS", 1)
	setToggleRow("Click Sound", clickSoundOn, 2, function(val)
		clickSoundOn = val
	end)
	setToggleRow("Hover Sound", hoverSoundOn, 3, function(val)
		hoverSoundOn = val
	end)
	local hoverRow = make("Frame", {
		Size = UDim2.new(1,0,0,44),
		BackgroundColor3 = C.rowBg, BackgroundTransparency = 0.0,
		BorderSizePixel = 0, LayoutOrder = 4, ZIndex = 52, Parent = setContent,
	})
	addCorner(hoverRow, 8)
	make("UIStroke", { Color = C.barStroke, Thickness = 1, Transparency = 0.65, Parent = hoverRow })
	make("TextLabel", {
		Size = UDim2.new(1,-10,0,16), Position = UDim2.new(0,10,0,4),
		BackgroundTransparency = 1, Text = "Hover Sound Asset ID",
		TextColor3 = C.text, TextSize = 10, Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 53, Parent = hoverRow,
	})
	local hoverInput = make("TextBox", {
		Size = UDim2.new(1,-16,0,22), Position = UDim2.new(0,8,0,20),
		BackgroundColor3 = C.rowInner, BackgroundTransparency = 0.0,
		Text = hoverAssetId:gsub("rbxassetid://",""),
		PlaceholderText = "asset id...",
		TextColor3 = C.text, PlaceholderColor3 = C.textMuted,
		TextSize = 10, Font = Enum.Font.Gotham, BorderSizePixel = 0,
		ClearTextOnFocus = false, ZIndex = 53, Parent = hoverRow,
	})
	addCorner(hoverInput, 5)
	make("UIStroke", { Color = C.border, Thickness = 1, Parent = hoverInput })
	hoverInput.FocusLost:Connect(function()
		local raw = hoverInput.Text:match("%d+")
		if raw then
			hoverAssetId = "rbxassetid://" .. raw
			saveHudCfg()
		end
	end)
	local saveLabel = make("TextLabel", {
		Size = UDim2.new(1,0,0,14), BackgroundTransparency = 1,
		Text = "", TextColor3 = C.green, TextSize = 9,
		Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Center,
		LayoutOrder = 5, ZIndex = 52, Parent = setContent,
	})
	settingsBtn.MouseButton1Click:Connect(function()
		if setPanel.Visible then
			setPanel.Visible = false
		else
			sbPanel.Visible = false
			local barAP = bar.AbsolutePosition
			local barAS = bar.AbsoluteSize
			setPanel.Position = UDim2.new(0, barAP.X + barAS.X - SET_W, 0, barAP.Y + barAS.Y + 10)
			setPanel.Visible = true
		end
	end)
	serverBrowserBtn.MouseButton1Click:Connect(function()
		if sbPanel.Visible then return end
		local barAP = bar.AbsolutePosition
		local barAS = bar.AbsoluteSize
		sbPanel.Position = UDim2.new(0, barAP.X, 0, barAP.Y + barAS.Y + 10)
	end)
	hudGui.AncestryChanged:Connect(function()
		if not hudGui.Parent then
			pcall(function() fpsCon:Disconnect() end)
			pcall(function() pingCon:Disconnect() end)
		end
	end)
	return hudGui
end
function UILibrary:addHStack()
	local parent, _, layoutOrder = self:_getTarget()
	local wrapper = make("Frame", {
		Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1, LayoutOrder = layoutOrder, Parent = parent,
	})
	make("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		Padding = UDim.new(0,6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = wrapper,
	})
	if self._activeTab then table.insert(self._activeTab.items, wrapper) end
	local function makeColumn()
		local col = make("Frame", {
			Size = UDim2.new(0.5,-3,0,0), AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1, Parent = wrapper,
		})
		make("UIListLayout", {
			Padding = UDim.new(0,6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = col,
		})
		local proxy = setmetatable({}, {
			__index = function(_, k)
				if type(UILibrary[k]) == "function" then
					return function(_, ...)
						local savedTab  = self._activeTab
						local savedScroll = self.scrollFrame
						self.scrollFrame = col
						self._activeTab  = nil
						local result = UILibrary[k](self, ...)
						self.scrollFrame = savedScroll
						self._activeTab  = savedTab
						return result
					end
				end
			end
		})
		return proxy
	end
	local left  = makeColumn()
	local right = makeColumn()
	if not self._minimized then self:resize() end
	return { left = left, right = right, frame = wrapper }
end
function UILibrary:addVStack()
	local parent, _, layoutOrder = self:_getTarget()
	local col = make("Frame", {
		Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1, LayoutOrder = layoutOrder, Parent = parent,
	})
	make("UIListLayout", { Padding=UDim.new(0,6), SortOrder=Enum.SortOrder.LayoutOrder, Parent=col })
	if self._activeTab then table.insert(self._activeTab.items, col) end
	local proxy = setmetatable({}, {
		__index = function(_, k)
			if type(UILibrary[k]) == "function" then
				return function(_, ...)
					local savedTab = self._activeTab
					local savedScroll = self.scrollFrame
					self.scrollFrame = col
					self._activeTab  = nil
					local result = UILibrary[k](self, ...)
					self.scrollFrame = savedScroll
					self._activeTab  = savedTab
					return result
				end
			end
		end
	})
	if not self._minimized then self:resize() end
	return proxy
end
function UILibrary:addViewport(instance, options)
	options = options or {}
	local h = options.height or 120
	local parent, _, layoutOrder = self:_getTarget()
	local row = makeRow(parent, layoutOrder)
	local vpFrame = make("ViewportFrame", {
		Size = UDim2.new(1,-16,0,h),
		Position = UDim2.fromOffset(8,4),
		BackgroundColor3 = Color3.fromRGB(12,12,14),
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
		LightColor = Color3.fromRGB(220,220,220),
		LightDirection = Vector3.new(-1,-2,-1),
		Parent = row,
	})
	addCorner(vpFrame, 8)
	if instance then
		local cloned = instance:Clone()
		cloned.Parent = vpFrame
		task.defer(function()
			local cam = Instance.new("Camera")
			cam.Parent = vpFrame
			vpFrame.CurrentCamera = cam
			local bb = cloned:IsA("Model") and cloned:GetBoundingBox() or CFrame.new(cloned.Position)
			local size = cloned:IsA("Model") and (cloned:GetExtentsSize().Magnitude or 4) or 4
			cam.CFrame = CFrame.new((typeof(bb)=="CFrame" and bb or bb).Position + Vector3.new(size,size,size)*0.85, (typeof(bb)=="CFrame" and bb or bb).Position)
		end)
	end
	if options.interactive then
		local spinning = false
		local lastX    = 0
		local cam      = vpFrame.CurrentCamera
		vpFrame.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 then spinning=true; lastX=inp.Position.X end
		end)
		vpFrame.InputEnded:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 then spinning=false end
		end)
		vpFrame.InputChanged:Connect(function(inp)
			if spinning and inp.UserInputType == Enum.UserInputType.MouseMovement and cam then
				local dx = inp.Position.X - lastX; lastX = inp.Position.X
				cam.CFrame = CFrame.Angles(0, math.rad(dx*0.5), 0) * cam.CFrame
			end
		end)
	end
	if self._activeTab then table.insert(self._activeTab.items, row) end
	if not self._minimized then self:resize() end
	return { frame = vpFrame }
end
return UILibrary
