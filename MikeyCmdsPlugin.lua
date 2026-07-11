-- mikeyware_cmds.lua
-- Mikeyware command plugin — prefix: ' (tick)
-- Port of Infinite Yield commands. Load standalone or via addPlugin.

if not game:IsLoaded() then game.Loaded:Wait() end

-- ── services ──────────────────────────────────────────────────────────────────
local Players        = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService     = game:GetService("RunService")
local TweenService   = game:GetService("TweenService")
local HttpService    = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local StarterGui     = game:GetService("StarterGui")
local GuiService     = game:GetService("GuiService")
local Lighting       = game:GetService("Lighting")
local SoundService   = game:GetService("SoundService")
local Teams          = game:GetService("Teams")
local PathfindingService = game:GetService("PathfindingService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local CoreGui        = game:GetService("CoreGui")
local TextChatService = game:GetService("TextChatService")

local lp   = Players.LocalPlayer
local cam  = workspace.CurrentCamera

-- ── globals ───────────────────────────────────────────────────────────────────
local PREFIX       = "'"
local cmds         = {}
local aliases      = {}
local customAlias  = {}
local cmdHistory   = {}
local lastCmds     = {}
local loops        = {}       -- active loop threads
local lastBreakTime = 0
local tweenSpeed   = 1
local cargs        = {}

-- ── helpers ───────────────────────────────────────────────────────────────────
local function isNum(v)  return tonumber(v) ~= nil end
local function lower(s)  return tostring(s):lower() end
local function split(s, d)
	d = d or " "
	local t = {}
	for w in (s .. d):gmatch("([^" .. d .. "]*)" .. d) do
		if w ~= "" then t[#t+1] = w end
	end
	return t
end
local function getstring(start, args)
	return table.concat(args, " ", start)
end
local function findInTable(t, v)
	for _, x in pairs(t) do if x == v then return true end end
	return false
end
local function getRoot(char)
	if not char then return nil end
	return char:FindFirstChild("HumanoidRootPart")
		or char:FindFirstChild("Torso")
		or char:FindFirstChild("UpperTorso")
end
local function r15(speaker)
	local char = speaker.Character
	return char and char:FindFirstChild("UpperTorso") ~= nil
end
local function notify(title, text, duration)
	-- try to use mikeylib notify if available, else fallback
	pcall(function()
		local gui = CoreGui:FindFirstChild("MW_NOTIF_GUI") or lp.PlayerGui:FindFirstChild("MW_NOTIF_GUI")
		-- mikeylib notify is global via the lib instance; we fire it via a bindable if available
	end)
	-- simple fallback StarterGui notification
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title    = tostring(title),
			Text     = tostring(text),
			Duration = duration or 6,
		})
	end)
end
local function chatMessage(str)
	pcall(function()
		if TextChatService.ChatVersion == Enum.ChatVersion.LegacyChatService then
			game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(str, "All")
		else
			TextChatService.TextChannels.RBXGeneral:SendAsync(str)
		end
	end)
end
local function toClipboard(txt)
	pcall(function()
		if setclipboard then setclipboard(tostring(txt))
		elseif toclipboard then toclipboard(tostring(txt)) end
	end)
end
local function breakVelocity()
	local v3 = Vector3.new(0,0,0)
	for _, v in ipairs(lp.Character:GetDescendants()) do
		if v:IsA("BasePart") then v.Velocity = v3; v.RotVelocity = v3 end
	end
end

-- ── getPlayer engine (IY-style) ───────────────────────────────────────────────
local function getPlayersByName(name)
	local found, len = {}, #name
	for _, v in pairs(Players:GetPlayers()) do
		if name:sub(1,1) == "@" then
			if lower(v.Name):sub(1, len-1) == name:sub(2):lower() then
				found[#found+1] = v
			end
		else
			if lower(v.Name):sub(1,len) == lower(name) or lower(v.DisplayName):sub(1,len) == lower(name) then
				found[#found+1] = v
			end
		end
	end
	return found
end

local SpecialPlayerCases = {
	["all"]       = function(sp) return Players:GetPlayers() end,
	["others"]    = function(sp)
		local r = {}
		for _, v in pairs(Players:GetPlayers()) do
			if v ~= sp then r[#r+1] = v end
		end
		return r
	end,
	["me"]        = function(sp) return {sp} end,
	["random"]    = function(sp)
		local p = Players:GetPlayers()
		return {p[math.random(1,#p)]}
	end,
	["nearest"]   = function(sp, _, list)
		local low, found = math.huge, nil
		local root = sp.Character and getRoot(sp.Character)
		if not root then return end
		for _, pl in pairs(list) do
			if pl ~= sp and pl.Character then
				local d = pl:DistanceFromCharacter(root.Position)
				if d < low then low = d; found = pl end
			end
		end
		return found and {found}
	end,
	["farthest"]  = function(sp, _, list)
		local high, found = 0, nil
		local root = sp.Character and getRoot(sp.Character)
		if not root then return end
		for _, pl in pairs(list) do
			if pl ~= sp and pl.Character then
				local d = pl:DistanceFromCharacter(root.Position)
				if d > high then high = d; found = pl end
			end
		end
		return found and {found}
	end,
	["friends"]   = function(sp)
		local r = {}
		for _, v in pairs(Players:GetPlayers()) do
			if v ~= sp and v:IsFriendsWith(sp.UserId) then r[#r+1] = v end
		end
		return r
	end,
	["nonfriends"] = function(sp)
		local r = {}
		for _, v in pairs(Players:GetPlayers()) do
			if v ~= sp and not v:IsFriendsWith(sp.UserId) then r[#r+1] = v end
		end
		return r
	end,
	["allies"]    = function(sp)
		local r = {}
		for _, v in pairs(Players:GetPlayers()) do
			if v.Team == sp.Team then r[#r+1] = v end
		end
		return r
	end,
	["enemies"]   = function(sp)
		local r = {}
		for _, v in pairs(Players:GetPlayers()) do
			if v.Team ~= sp.Team then r[#r+1] = v end
		end
		return r
	end,
	["alive"]     = function(sp)
		local r = {}
		for _, v in pairs(Players:GetPlayers()) do
			local h = v.Character and v.Character:FindFirstChildOfClass("Humanoid")
			if h and h.Health > 0 then r[#r+1] = v end
		end
		return r
	end,
	["dead"]      = function(sp)
		local r = {}
		for _, v in pairs(Players:GetPlayers()) do
			local h = v.Character and v.Character:FindFirstChildOfClass("Humanoid")
			if not h or h.Health <= 0 then r[#r+1] = v end
		end
		return r
	end,
	["bacons"]    = function(sp)
		local r = {}
		for _, v in pairs(Players:GetPlayers()) do
			if v.Character and (v.Character:FindFirstChild("Pal Hair") or v.Character:FindFirstChild("Kate Hair")) then
				r[#r+1] = v
			end
		end
		return r
	end,
}
-- regex patterns
local RegexCases = {
	{ pat = "^#(%d+)$", fn = function(sp, m, list)
		local n, r, pool = tonumber(m[1]), {}, {table.unpack(list)}
		for i = 1, n do
			if #pool == 0 then break end
			local idx = math.random(1, #pool)
			r[#r+1] = pool[idx]; table.remove(pool, idx)
		end
		return r
	end },
	{ pat = "^%%(.+)$", fn = function(sp, m)
		local r = {}
		for _, v in pairs(Players:GetPlayers()) do
			if v.Team and lower(v.Team.Name):sub(1, #m[1]) == lower(m[1]) then r[#r+1] = v end
		end
		return r
	end },
	{ pat = "^rad(%d+)$", fn = function(sp, m)
		local r, radius = {}, tonumber(m[1])
		local root = sp.Character and getRoot(sp.Character)
		if not root then return r end
		for _, v in pairs(Players:GetPlayers()) do
			if v.Character and getRoot(v.Character) then
				if (getRoot(v.Character).Position - root.Position).Magnitude <= radius then r[#r+1] = v end
			end
		end
		return r
	end },
	{ pat = "^age(%d+)$", fn = function(sp, m)
		local r, age = {}, tonumber(m[1])
		for _, v in pairs(Players:GetPlayers()) do
			if v.AccountAge <= age then r[#r+1] = v end
		end
		return r
	end },
	{ pat = "^group(%d+)$", fn = function(sp, m)
		local r = {}
		for _, v in pairs(Players:GetPlayers()) do
			if v:IsInGroup(tonumber(m[1])) then r[#r+1] = v end
		end
		return r
	end },
}

local function onlyIn(tab, matches)
	local set, r = {}, {}
	for _, v in pairs(matches) do set[v.Name] = true end
	for _, v in pairs(tab) do if set[v.Name] then r[#r+1] = v end end
	return r
end
local function removeFrom(tab, matches)
	local set, r = {}, {}
	for _, v in pairs(matches) do set[v.Name] = true end
	for _, v in pairs(tab) do if not set[v.Name] then r[#r+1] = v end end
	return r
end
local function resolveToken(name, sp, initial)
	local sc = SpecialPlayerCases[lower(name)]
	if sc then return onlyIn(initial, sc(sp, nil, initial) or {}) end
	for _, rc in ipairs(RegexCases) do
		local m = {lower(name):match(rc.pat)}
		if #m > 0 then return onlyIn(initial, rc.fn(sp, m, initial) or {}) end
	end
	return onlyIn(initial, getPlayersByName(name))
end

local function getPlayer(list, speaker)
	speaker = speaker or lp
	if not list then return {speaker} end
	local nameList = split(tostring(list), ",")
	local found = {}
	for _, name in pairs(nameList) do
		if name:sub(1,1) ~= "+" and name:sub(1,1) ~= "-" then name = "+" .. name end
		local i, current = 1, Players:GetPlayers()
		while i <= #name do
			local op = name:sub(i,i)
			i = i + 1
			local j = i
			while j <= #name and name:sub(j,j) ~= "+" and name:sub(j,j) ~= "-" do j = j + 1 end
			local token = name:sub(i, j-1)
			i = j
			if op == "+" then
				current = resolveToken(token, speaker, current)
			else
				local toRemove = resolveToken(token, speaker, Players:GetPlayers())
				current = removeFrom(current, toRemove)
			end
		end
		for _, v in pairs(current) do
			if not findInTable(found, v) then found[#found+1] = v end
		end
	end
	return found
end

-- ── command registry ──────────────────────────────────────────────────────────
local function addcmd(name, als, fn)
	cmds[#cmds+1] = { name = lower(name), aliases = als or {}, fn = fn }
end
local function findCmd(name)
	name = lower(name)
	for _, c in pairs(cmds) do
		if c.name == name then return c end
		for _, a in pairs(c.aliases) do if lower(a) == name then return c end end
	end
	return customAlias[name]
end

-- ── execCmd ───────────────────────────────────────────────────────────────────
local function execCmd(str, speaker, store)
	speaker = speaker or lp
	str = str:gsub("%s+$", "")
	task.spawn(function()
		str = str:gsub("\\\\", "%%BSLASH%%")
		local chunks = split(str, "\\")
		for _, chunk in ipairs(chunks) do
			chunk = chunk:gsub("%%BSLASH%%", "\\")
			-- loop syntax: 5^1^cmd or inf^0.5^cmd
			local times, delay_, body = nil, 0, chunk
			local n, rest = chunk:match("^(%d+)%^(.+)$")
			if n then
				times = tonumber(n)
				local d, b = rest:match("^([%d%.]+)%^(.+)$")
				if d then delay_ = tonumber(d) or 0; body = b else body = rest end
			else
				local inf, rest2 = chunk:match("^(inf)%^(.+)$")
				if inf then
					times = math.huge
					local d, b = rest2:match("^([%d%.]+)%^(.+)$")
					if d then delay_ = tonumber(d) or 0; body = b else body = rest2 end
				end
			end
			-- !cmd repeats last args
			if body:sub(1,1) == "!" then
				local cn = split(body:sub(2))[1]
				if cn and lastCmds[cn] then body = lastCmds[cn] end
			end
			local args2 = split(body)
			local cmdName = args2[1]
			if not cmdName then return end
			table.remove(args2, 1)
			local cmd = findCmd(cmdName)
			if not cmd then return end
			cargs = args2
			if store ~= false then
				if cmdHistory[1] ~= str then table.insert(cmdHistory, 1, str) end
				if #cmdHistory > 50 then table.remove(cmdHistory) end
				lastCmds[lower(cmdName)] = body
			end
			local startTime = tick()
			local count = 0
			local running = true
			if times then
				local t = task.spawn(function()
					while running and (times == math.huge or count < times) and lastBreakTime < startTime do
						pcall(cmd.fn, args2, speaker)
						count = count + 1
						if delay_ > 0 then task.wait(delay_) end
					end
				end)
				loops[#loops+1] = { thread = t, stop = function() running = false end, time = startTime }
			else
				pcall(cmd.fn, args2, speaker)
			end
		end
	end)
end

-- ── input listener ────────────────────────────────────────────────────────────
-- Wire into the HUD command bar if it exists, otherwise create a minimal one
task.spawn(function()
	task.wait(1) -- let HUD initialize
	-- look for the Mikeyware HUD cmdbar textbox
	local cmdBox = nil
	local hudGui = CoreGui:FindFirstChild("MW_HUD_GUI")
		or (lp.PlayerGui and lp.PlayerGui:FindFirstChild("MW_HUD_GUI"))
	if hudGui then
		cmdBox = hudGui:FindFirstChild("MW_CmdBox", true)
	end
	-- if no cmdbox in HUD, just listen via chat prefix
	UserInputService.InputBegan:Connect(function(inp, gp)
		if gp then return end
		if inp.KeyCode == Enum.KeyCode.Return or inp.KeyCode == Enum.KeyCode.KeypadEnter then
			-- handled by textbox FocusLost
		end
	end)
end)

-- also intercept chat prefix
TextChatService.MessageReceived:Connect(function(msg)
	if msg.TextSource and msg.TextSource.UserId == lp.UserId then
		local txt = msg.Text or ""
		if txt:sub(1, #PREFIX) == PREFIX then
			execCmd(txt:sub(#PREFIX+1), lp, true)
		end
	end
end)
-- legacy chat
pcall(function()
	lp.Chatted:Connect(function(msg)
		if msg:sub(1, #PREFIX) == PREFIX then
			execCmd(msg:sub(#PREFIX+1), lp, true)
		end
	end)
end)

-- ── expose for external use ───────────────────────────────────────────────────
local function getCmdNames()
	local names = {}
	for _, c in pairs(cmds) do
		names[#names+1] = c.name
		for _, a in pairs(c.aliases) do names[#names+1] = a end
	end
	table.sort(names)
	return names
end

_G.MWCmds = {
	addcmd    = addcmd,
	execCmd   = execCmd,
	getPlayer = getPlayer,
	notify    = notify,
	setPrefix = function(p) PREFIX = p end,
	_cmdNames = getCmdNames(), -- populated after all addcmd calls below
}


-- ══════════════════════════════════════════════════════════════════════════════
-- MOVEMENT
-- ══════════════════════════════════════════════════════════════════════════════

local FLYING = false
local flySpeed = 1
local vflySpeed = 1
local Clip = true
local QEfly = true
local noclipConn = nil
local flyKeyDown, flyKeyUp

local function sFLY(vfly)
	FLYING = true
	local char = lp.Character
	local T = getRoot(char)
	if not T then return end
	local CTRL = {F=0,B=0,L=0,R=0,Q=0,E=0}
	local BG = Instance.new("BodyGyro"); BG.P=9e4; BG.MaxTorque=Vector3.new(9e9,9e9,9e9); BG.Parent=T
	local BV = Instance.new("BodyVelocity"); BV.Velocity=Vector3.new(); BV.MaxForce=Vector3.new(9e9,9e9,9e9); BV.Parent=T
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then hum.PlatformStand = true end
	flyKeyDown = UserInputService.InputBegan:Connect(function(inp, gp)
		if gp then return end
		if inp.KeyCode==Enum.KeyCode.W then CTRL.F=1 elseif inp.KeyCode==Enum.KeyCode.S then CTRL.B=1
		elseif inp.KeyCode==Enum.KeyCode.A then CTRL.L=1 elseif inp.KeyCode==Enum.KeyCode.D then CTRL.R=1
		elseif QEfly and inp.KeyCode==Enum.KeyCode.Q then CTRL.Q=1
		elseif QEfly and inp.KeyCode==Enum.KeyCode.E then CTRL.E=1 end
	end)
	flyKeyUp = UserInputService.InputEnded:Connect(function(inp)
		if inp.KeyCode==Enum.KeyCode.W then CTRL.F=0 elseif inp.KeyCode==Enum.KeyCode.S then CTRL.B=0
		elseif inp.KeyCode==Enum.KeyCode.A then CTRL.L=0 elseif inp.KeyCode==Enum.KeyCode.D then CTRL.R=0
		elseif inp.KeyCode==Enum.KeyCode.Q then CTRL.Q=0
		elseif inp.KeyCode==Enum.KeyCode.E then CTRL.E=0 end
	end)
	local conn; conn = RunService.RenderStepped:Connect(function()
		if not FLYING then conn:Disconnect(); BG:Destroy(); BV:Destroy(); return end
		local cf = cam.CoordinateFrame
		local spd = (vfly and vflySpeed or flySpeed) * 50
		BG.CFrame = cf
		BV.Velocity = ((cf.LookVector*(CTRL.F-CTRL.B) + cf.RightVector*(CTRL.R-CTRL.L)) * spd)
			+ Vector3.new(0, (CTRL.E-CTRL.Q)*spd, 0)
	end)
end

local function NOFLY()
	FLYING = false
	if flyKeyDown then flyKeyDown:Disconnect() end
	if flyKeyUp   then flyKeyUp:Disconnect()   end
	local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum.PlatformStand = false end
	pcall(function() cam.CameraType = Enum.CameraType.Custom end)
end

addcmd("fly",{},function(args,sp)
	NOFLY(); task.wait()
	if args[1] and isNum(args[1]) then flySpeed = tonumber(args[1]) end
	sFLY(false); notify("Fly","Enabled")
end)
addcmd("unfly",{"nofly"},function() NOFLY(); notify("Fly","Disabled") end)
addcmd("togglefly",{},function() if FLYING then execCmd("unfly") else execCmd("fly") end end)
addcmd("flyspeed",{"flysp"},function(args) if isNum(args[1]) then flySpeed=tonumber(args[1]) end end)
addcmd("vfly",{"vehiclefly"},function(args,sp)
	NOFLY(); task.wait()
	if args[1] and isNum(args[1]) then vflySpeed=tonumber(args[1]) end
	sFLY(true); notify("Vehicle Fly","Enabled")
end)
addcmd("unvfly",{"unvehiclefly","novfly","novehiclefly"},function() NOFLY(); notify("Vehicle Fly","Disabled") end)
addcmd("vflyspeed",{"vehicleflyspeed"},function(args) if isNum(args[1]) then vflySpeed=tonumber(args[1]) end end)
addcmd("qefly",{},function(args)
	QEfly = (args[1] ~= "false")
end)

-- cframefly
local CFspeed = 50
local CFloop = nil
addcmd("cfly",{"cframefly"},function(args,sp)
	if args[1] and isNum(args[1]) then CFspeed=tonumber(args[1]) end
	local hum = sp.Character:FindFirstChildOfClass("Humanoid")
	hum.PlatformStand = true
	local Head = sp.Character:WaitForChild("Head"); Head.Anchored = true
	if CFloop then CFloop:Disconnect() end
	CFloop = RunService.Heartbeat:Connect(function(dt)
		local md = sp.Character:FindFirstChildOfClass("Humanoid").MoveDirection * (CFspeed * dt)
		local hcf = Head.CFrame
		local ccf = cam.CFrame
		local pos = ccf.Position
		Head.CFrame = CFrame.new(hcf.Position) * (ccf - pos) * CFrame.new(
			CFrame.new(pos, Vector3.new(hcf.Position.X, pos.Y, hcf.Position.Z)):VectorToObjectSpace(md))
	end)
	notify("CFrame Fly","Enabled")
end)
addcmd("uncfly",{"uncframefly"},function(args,sp)
	if CFloop then CFloop:Disconnect(); CFloop=nil end
	local hum = sp.Character and sp.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum.PlatformStand=false end
	local Head = sp.Character and sp.Character:FindFirstChild("Head")
	if Head then Head.Anchored=false end
	notify("CFrame Fly","Disabled")
end)
addcmd("cflyspeed",{"cframeflyspeed"},function(args) if isNum(args[1]) then CFspeed=tonumber(args[1]) end end)

-- noclip
addcmd("noclip",{},function(args,sp)
	Clip = false
	noclipConn = RunService.Stepped:Connect(function()
		if Clip then noclipConn:Disconnect(); return end
		if sp.Character then
			for _, v in pairs(sp.Character:GetDescendants()) do
				if v:IsA("BasePart") then v.CanCollide = false end
			end
		end
	end)
	notify("Noclip","Enabled")
end)
addcmd("clip",{"unnoclip"},function()
	Clip = true; notify("Noclip","Disabled")
end)
addcmd("togglenoclip",{},function() if Clip then execCmd("noclip") else execCmd("clip") end end)

-- speed / walkspeed
addcmd("speed",{"ws","walkspeed"},function(args,sp)
	local s = tonumber(args[1]) or 16
	local hum = sp.Character and sp.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum.WalkSpeed = s end
end)
addcmd("loopspeed",{"loopws"},function(args,sp)
	local s = tonumber(args[1]) or 16
	local hum = sp.Character:FindFirstChildOfClass("Humanoid")
	local conn; conn = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function() hum.WalkSpeed=s end)
	hum.WalkSpeed = s
end)
addcmd("unloopspeed",{"unloopws"},function(args,sp)
	-- disconnect is handled by breakloops; just reset speed
	local hum = sp.Character and sp.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum.WalkSpeed = 16 end
end)

-- jump
addcmd("jumppower",{"jp","jpower"},function(args,sp)
	local j = tonumber(args[1]) or 50
	local hum = sp.Character and sp.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		if hum.UseJumpPower then hum.JumpPower=j else hum.JumpHeight=j end
	end
end)
addcmd("infjump",{"infinitejump"},function(args,sp)
	UserInputService.JumpRequest:Connect(function()
		local hum = sp.Character and sp.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
	end)
	notify("Inf Jump","Enabled")
end)
addcmd("uninfjump",{"uninfinitejump"},function() notify("Inf Jump","Disabled — rejoin to fully reset") end)
addcmd("flyjump",{},function(args,sp)
	UserInputService.JumpRequest:Connect(function()
		local hum = sp.Character and sp.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
	end)
end)
addcmd("autojump",{"ajump"},function(args,sp)
	RunService.RenderStepped:Connect(function()
		local char = sp.Character; if not char then return end
		local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
		local root = getRoot(char); if not root then return end
		local hit = workspace:FindPartOnRay(Ray.new(root.Position - Vector3.new(0,1.5,0), root.CFrame.LookVector*3), char)
		if hit then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
	end)
end)

-- gravity
addcmd("gravity",{"grav"},function(args)
	workspace.Gravity = tonumber(args[1]) or 196.2
end)

-- hipheight
addcmd("hipheight",{"hheight"},function(args,sp)
	local hum = sp.Character and sp.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum.HipHeight = tonumber(args[1]) or 0 end
end)

-- maxslopeangle
addcmd("maxslopeangle",{"msa"},function(args,sp)
	local hum = sp.Character and sp.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum.MaxSlopeAngle = tonumber(args[1]) or 89 end
end)

-- float / platform
local Floating = false
local floatName = "MW_Float_" .. tostring(math.random(1000,9999))
addcmd("float",{"platform"},function(args,sp)
	Floating = true
	local char = sp.Character; if not char or not getRoot(char) then return end
	local Float = Instance.new("Part")
	Float.Name = floatName; Float.Parent = char
	Float.Transparency = 1; Float.Size = Vector3.new(2,0.2,1.5)
	Float.Anchored = true
	Float.CFrame = getRoot(char).CFrame * CFrame.new(0,-3.1,0)
	local conn; conn = RunService.Heartbeat:Connect(function()
		if not char:FindFirstChild(floatName) then conn:Disconnect(); return end
		Float.CFrame = getRoot(char).CFrame * CFrame.new(0,-3.1,0)
	end)
	notify("Float","Enabled")
end)
addcmd("unfloat",{"nofloat","noplatform","unplatform"},function(args,sp)
	Floating = false
	local char = sp.Character
	if char and char:FindFirstChild(floatName) then char:FindFirstChild(floatName):Destroy() end
	notify("Float","Disabled")
end)

-- swim
local swimming = false
local oldGrav = workspace.Gravity
addcmd("swim",{},function(args,sp)
	oldGrav = workspace.Gravity; workspace.Gravity = 0
	swimming = true
	local hum = sp.Character and sp.Character:FindFirstChildOfClass("Humanoid")
	RunService.Heartbeat:Connect(function()
		if not swimming then return end
		local root = getRoot(sp.Character)
		if root and hum then
			root.Velocity = hum.MoveDirection * 16
		end
	end)
	notify("Swim","Enabled")
end)
addcmd("unswim",{"noswim"},function()
	swimming = false; workspace.Gravity = oldGrav
	notify("Swim","Disabled")
end)
addcmd("toggleswim",{},function() if swimming then execCmd("unswim") else execCmd("swim") end end)

-- sit / lay / sitwalk / nosit
addcmd("sit",{},function(args,sp)
	local hum = sp.Character and sp.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum.Sit = true end
end)
addcmd("lay",{"laydown"},function(args,sp)
	local hum = sp.Character and sp.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum.Sit=true; task.wait(0.1); hum.RootPart.CFrame = hum.RootPart.CFrame * CFrame.Angles(math.pi*0.5,0,0) end
end)
addcmd("nosit",{},function(args,sp)
	local hum = sp.Character and sp.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false) end
end)
addcmd("unnosit",{},function(args,sp)
	local hum = sp.Character and sp.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true) end
end)

-- spin
addcmd("spin",{},function(args,sp)
	local root = getRoot(sp.Character); if not root then return end
	for _, v in pairs(root:GetChildren()) do if v.Name=="MW_Spin" then v:Destroy() end end
	local bav = Instance.new("BodyAngularVelocity"); bav.Name="MW_Spin"
	bav.MaxTorque = Vector3.new(0,math.huge,0)
	bav.AngularVelocity = Vector3.new(0, tonumber(args[1]) or 20, 0)
	bav.Parent = root
end)
addcmd("unspin",{},function(args,sp)
	local root = getRoot(sp.Character); if not root then return end
	for _, v in pairs(root:GetChildren()) do if v.Name=="MW_Spin" then v:Destroy() end end
end)

-- anchor
addcmd("anchor",{},function(args,sp)
	local root = getRoot(sp.Character); if root then root.Anchored=true end
end)
addcmd("unanchor",{},function(args,sp)
	local root = getRoot(sp.Character); if root then root.Anchored=false end
end)

-- tpwalk
local tpwalkConn = nil
addcmd("tpwalk",{"teleportwalk"},function(args,sp)
	if tpwalkConn then tpwalkConn:Disconnect() end
	local spd = tonumber(args[1]) or 1
	tpwalkConn = RunService.Heartbeat:Connect(function(dt)
		local hum = sp.Character and sp.Character:FindFirstChildOfClass("Humanoid")
		if hum and hum.MoveDirection.Magnitude > 0 then
			sp.Character:TranslateBy(hum.MoveDirection * spd * dt * 10)
		end
	end)
end)
addcmd("untpwalk",{"unteleportwalk"},function()
	if tpwalkConn then tpwalkConn:Disconnect(); tpwalkConn=nil end
end)

-- platformstand / stun
addcmd("stun",{"platformstand"},function(args,sp)
	local hum = sp.Character and sp.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum.PlatformStand=true end
end)
addcmd("unstun",{"nostun","unplatformstand"},function(args,sp)
	local hum = sp.Character and sp.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum.PlatformStand=false end
end)

-- norotate
addcmd("norotate",{"noautorotate"},function(args,sp)
	local hum = sp.Character and sp.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum.AutoRotate=false end
end)
addcmd("unnorotate",{"autorotate"},function(args,sp)
	local hum = sp.Character and sp.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum.AutoRotate=true end
end)

-- breakvelocity
addcmd("breakvelocity",{},function(args,sp) breakVelocity() end)
addcmd("breakloops",{"break"},function() lastBreakTime=tick(); notify("Loops","All loops stopped") end)

-- wallwalk
addcmd("wallwalk",{"walkonwalls"},function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/wallwalker.lua"))()
end)

-- trip
addcmd("trip",{},function(args,sp)
	local hum = sp.Character and sp.Character:FindFirstChildOfClass("Humanoid")
	local root = getRoot(sp.Character)
	if hum and root then
		hum:ChangeState(Enum.HumanoidStateType.FallingDown)
		root.Velocity = root.CFrame.LookVector * 30
	end
end)

-- antivoid
local antivoidConn = nil
addcmd("antivoid",{},function(args,sp)
	if antivoidConn then antivoidConn:Disconnect() end
	local destroyH = workspace.FallenPartsDestroyHeight
	antivoidConn = RunService.Stepped:Connect(function()
		local root = getRoot(sp.Character)
		if root and root.Position.Y <= destroyH + 25 then
			root.Velocity = root.Velocity + Vector3.new(0,250,0)
		end
	end)
	notify("Antivoid","Enabled")
end)
addcmd("unantivoid",{"noantivoid"},function()
	if antivoidConn then antivoidConn:Disconnect(); antivoidConn=nil end
	notify("Antivoid","Disabled")
end)

-- fakeout
addcmd("fakeout",{},function(args,sp)
	local root = getRoot(sp.Character); if not root then return end
	local old = root.CFrame
	local dh = workspace.FallenPartsDestroyHeight
	workspace.FallenPartsDestroyHeight = 1/0
	root.CFrame = CFrame.new(0, dh-25, 0)
	task.wait(1)
	root.CFrame = old
	workspace.FallenPartsDestroyHeight = dh
end)


-- ══════════════════════════════════════════════════════════════════════════════
-- TELEPORT & WAYPOINTS
-- ══════════════════════════════════════════════════════════════════════════════

local tweenSpd = 1
local WayPoints = {}

addcmd("tweenspeed",{"tspeed"},function(args) tweenSpd=tonumber(args[1]) or 1 end)

addcmd("goto",{"to"},function(args,sp)
	for _, v in pairs(getPlayer(args[1],sp)) do
		if v.Character then
			local root = getRoot(sp.Character)
			if root then root.CFrame = getRoot(v.Character).CFrame + Vector3.new(3,1,0) end
		end
	end
	breakVelocity()
end)
addcmd("tweengoto",{"tgoto","tweento"},function(args,sp)
	for _, v in pairs(getPlayer(args[1],sp)) do
		if v.Character then
			TweenService:Create(getRoot(sp.Character), TweenInfo.new(tweenSpd, Enum.EasingStyle.Linear),
				{CFrame = getRoot(v.Character).CFrame + Vector3.new(3,1,0)}):Play()
		end
	end
end)
addcmd("tppos",{"tpposition"},function(args,sp)
	if #args < 3 then return end
	getRoot(sp.Character).CFrame = CFrame.new(tonumber(args[1]),tonumber(args[2]),tonumber(args[3]))
end)
addcmd("ttppos",{"tweentpposition"},function(args,sp)
	if #args < 3 then return end
	TweenService:Create(getRoot(sp.Character), TweenInfo.new(tweenSpd, Enum.EasingStyle.Linear),
		{CFrame = CFrame.new(tonumber(args[1]),tonumber(args[2]),tonumber(args[3]))}):Play()
end)
addcmd("offset",{},function(args,sp)
	sp.Character:TranslateBy(Vector3.new(tonumber(args[1]) or 0, tonumber(args[2]) or 0, tonumber(args[3]) or 0))
end)
addcmd("toffset",{"tweenoffset"},function(args,sp)
	local root = getRoot(sp.Character)
	local pos = root.Position + Vector3.new(tonumber(args[1]) or 0,tonumber(args[2]) or 0,tonumber(args[3]) or 0)
	TweenService:Create(root, TweenInfo.new(tweenSpd, Enum.EasingStyle.Linear), {CFrame=CFrame.new(pos)}):Play()
end)
addcmd("thru",{},function(args,sp)
	local root = getRoot(sp.Character); local n = tonumber(args[1]) or 5
	local pos = root.CFrame.Position + root.CFrame.LookVector * n
	root.CFrame = CFrame.new(pos, pos + root.CFrame.LookVector)
end)
addcmd("cbring",{"clientbring"},function(args,sp)
	for _, v in pairs(getPlayer(args[1],sp)) do
		if v.Character then
			local hum = v.Character:FindFirstChildOfClass("Humanoid")
			if hum then hum.Sit=false; task.wait(0.1) end
			getRoot(v.Character).CFrame = getRoot(sp.Character).CFrame + Vector3.new(3,1,0)
		end
	end
end)
local loopGotoTarget = nil
addcmd("loopgoto",{},function(args,sp)
	loopGotoTarget = nil
	for _, v in pairs(getPlayer(args[1],sp)) do
		local dist = tonumber(args[2]) or 3
		local delay_ = tonumber(args[3]) or 0
		loopGotoTarget = v
		task.spawn(function()
			repeat
				if v.Character then
					getRoot(sp.Character).CFrame = getRoot(v.Character).CFrame + Vector3.new(dist,1,0)
				end
				task.wait(math.max(delay_, 0.05))
			until loopGotoTarget ~= v
		end)
	end
end)
addcmd("unloopgoto",{"noloopgoto"},function() loopGotoTarget=nil end)

local loopBring = {}
addcmd("loopbring",{},function(args,sp)
	for _, v in pairs(getPlayer(args[1],sp)) do
		local dist = tonumber(args[2]) or 3
		local delay_ = tonumber(args[3]) or 0
		loopBring[v.Name] = true
		task.spawn(function()
			repeat
				if v.Character and sp.Character then
					getRoot(v.Character).CFrame = getRoot(sp.Character).CFrame + Vector3.new(dist,1,0)
				end
				task.wait(math.max(delay_,0.05))
			until not loopBring[v.Name]
		end)
	end
end)
addcmd("unloopbring",{"noloopbring"},function(args,sp)
	for _, v in pairs(getPlayer(args[1],sp)) do loopBring[v.Name]=false end
end)

addcmd("pulsetp",{"ptp"},function(args,sp)
	for _, v in pairs(getPlayer(args[1],sp)) do
		if v.Character then
			local old = getRoot(sp.Character).CFrame
			getRoot(sp.Character).CFrame = getRoot(v.Character).CFrame + Vector3.new(3,1,0)
			task.wait(tonumber(args[2]) or 1)
			getRoot(sp.Character).CFrame = old
		end
	end
end)

addcmd("mouseteleport",{"mousetp"},function(args,sp)
	local mouse = lp:GetMouse()
	local root = getRoot(sp.Character)
	if root and mouse.Hit then
		root.CFrame = CFrame.new(mouse.Hit.X, mouse.Hit.Y+3, mouse.Hit.Z, select(4,root.CFrame:components()))
	end
end)

addcmd("tptool",{"teleporttool"},function(args,sp)
	local tool = Instance.new("Tool"); tool.Name="Teleport Tool"
	tool.RequiresHandle=false; tool.Parent=sp:FindFirstChildOfClass("Backpack")
	tool.Activated:Connect(function()
		local mouse = lp:GetMouse(); local root = getRoot(sp.Character)
		if root and mouse.Hit then root.CFrame = CFrame.new(mouse.Hit.X,mouse.Hit.Y+3,mouse.Hit.Z) end
	end)
end)

-- waypoints
addcmd("setwaypoint",{"swp","swp","savepos"},function(args,sp)
	local name = getstring(1,args)
	local root = getRoot(sp.Character); if not root then return end
	local pos = root.Position
	WayPoints[#WayPoints+1] = {name=name, pos=pos}
	notify("Waypoint","Created: "..name)
end)
addcmd("waypoint",{"wp","loadpos"},function(args,sp)
	local name = lower(getstring(1,args))
	for _, w in pairs(WayPoints) do
		if lower(w.name) == name then
			getRoot(sp.Character).CFrame = CFrame.new(w.pos)
		end
	end
end)
addcmd("tweenwaypoint",{"twp"},function(args,sp)
	local name = lower(getstring(1,args))
	for _, w in pairs(WayPoints) do
		if lower(w.name) == name then
			TweenService:Create(getRoot(sp.Character), TweenInfo.new(tweenSpd, Enum.EasingStyle.Linear),
				{CFrame=CFrame.new(w.pos)}):Play()
		end
	end
end)
addcmd("deletewaypoint",{"dwp","deletepos"},function(args,sp)
	local name = lower(getstring(1,args))
	for i = #WayPoints,1,-1 do
		if lower(WayPoints[i].name) == name then table.remove(WayPoints,i) end
	end
	notify("Waypoint","Deleted: "..getstring(1,args))
end)
addcmd("clearwaypoints",{"cwp"},function()
	WayPoints={}; notify("Waypoints","Cleared all")
end)
addcmd("waypoints",{"wps"},function()
	local names = {}
	for _, w in pairs(WayPoints) do names[#names+1] = w.name end
	notify("Waypoints", #names > 0 and table.concat(names,", ") or "None")
end)

-- walkto / follow
local walktoActive = false
addcmd("walkto",{"follow"},function(args,sp)
	walktoActive = true
	for _, v in pairs(getPlayer(args[1],sp)) do
		task.spawn(function()
			repeat
				local hum = sp.Character and sp.Character:FindFirstChildOfClass("Humanoid")
				if hum and v.Character then hum:MoveTo(getRoot(v.Character).Position) end
				task.wait(0.1)
			until not walktoActive
		end)
	end
end)
addcmd("unwalkto",{"unfollow","nowalkto"},function() walktoActive=false end)

-- orbit
local orbitConn1, orbitConn2 = nil, nil
addcmd("orbit",{},function(args,sp)
	if orbitConn1 then orbitConn1:Disconnect() end
	if orbitConn2 then orbitConn2:Disconnect() end
	for _, v in pairs(getPlayer(args[1],sp)) do
		local rot, spd, dist = 0, tonumber(args[2]) or 0.2, tonumber(args[3]) or 6
		orbitConn1 = RunService.Heartbeat:Connect(function()
			rot = rot + spd
			pcall(function()
				getRoot(sp.Character).CFrame = CFrame.new(getRoot(v.Character).Position)
					* CFrame.Angles(0, math.rad(rot), 0) * CFrame.new(dist,0,0)
			end)
		end)
		orbitConn2 = RunService.RenderStepped:Connect(function()
			pcall(function()
				getRoot(sp.Character).CFrame = CFrame.new(getRoot(sp.Character).Position,
					getRoot(v.Character).Position)
			end)
		end)
		notify("Orbit","Orbiting "..v.Name)
	end
end)
addcmd("unorbit",{},function()
	if orbitConn1 then orbitConn1:Disconnect() end
	if orbitConn2 then orbitConn2:Disconnect() end
	notify("Orbit","Stopped")
end)

-- headsit
local headsitConn = nil
addcmd("headsit",{},function(args,sp)
	if headsitConn then headsitConn:Disconnect() end
	for _, v in pairs(getPlayer(args[1],sp)) do
		sp.Character:FindFirstChildOfClass("Humanoid").Sit = true
		headsitConn = RunService.Heartbeat:Connect(function()
			pcall(function()
				getRoot(sp.Character).CFrame = getRoot(v.Character).CFrame * CFrame.new(0,1.6,0.4)
			end)
		end)
	end
end)

-- scare
addcmd("scare",{"spook"},function(args,sp)
	for _, v in pairs(getPlayer(args[1],sp)) do
		local old = getRoot(sp.Character).CFrame
		local troot = getRoot(v.Character)
		if troot then
			getRoot(sp.Character).CFrame = troot.CFrame + troot.CFrame.LookVector*2
			task.wait(0.5)
			getRoot(sp.Character).CFrame = old
		end
	end
end)

-- freeze / thaw
addcmd("freeze",{"fr"},function(args,sp)
	for _, v in pairs(getPlayer(args[1],sp)) do
		if v.Character then
			for _, p in pairs(v.Character:GetDescendants()) do
				if p:IsA("BasePart") then p.Anchored=true end
			end
		end
	end
end)
addcmd("thaw",{"unfr","unfreeze"},function(args,sp)
	for _, v in pairs(getPlayer(args[1],sp)) do
		if v.Character then
			for _, p in pairs(v.Character:GetDescendants()) do
				if p:IsA("BasePart") then p.Anchored=false end
			end
		end
	end
end)

-- flashback
local lastDeath = nil
addcmd("flashback",{"diedtp"},function(args,sp)
	if lastDeath then getRoot(sp.Character).CFrame = lastDeath end
end)
-- track death position
task.spawn(function()
	local function hookDeath(char)
		local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5)
		if hum then
			hum.Died:Connect(function()
				local root = getRoot(char)
				if root then lastDeath = root.CFrame end
			end)
		end
	end
	if lp.Character then hookDeath(lp.Character) end
	lp.CharacterAdded:Connect(hookDeath)
end)

-- walltp
local walltpConn = nil
addcmd("walltp",{},function(args,sp)
	local torso = sp.Character and (sp.Character:FindFirstChild("UpperTorso") or sp.Character:FindFirstChild("Torso"))
	if not torso then return end
	walltpConn = torso.Touched:Connect(function(hit)
		local root = getRoot(sp.Character)
		if hit:IsA("BasePart") and hit.Position.Y > root.Position.Y then
			root.CFrame = CFrame.new(hit.Position + Vector3.new(0,3,0))
		end
	end)
	notify("Walltp","Enabled")
end)
addcmd("nowalltp",{"unwalltp"},function()
	if walltpConn then walltpConn:Disconnect(); walltpConn=nil end
	notify("Walltp","Disabled")
end)

-- respawn / refresh / reset / god
local function doRespawn(sp)
	local char = sp.Character
	local newChar = Instance.new("Model"); newChar.Parent=workspace
	sp.Character = newChar; task.wait()
	sp.Character = char; newChar:Destroy()
end

addcmd("respawn",{},function(args,sp) doRespawn(sp) end)
addcmd("reset",{},function(args,sp)
	local hum = sp.Character and sp.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum:ChangeState(Enum.HumanoidStateType.Dead) end
end)
addcmd("refresh",{"re"},function(args,sp)
	local root = getRoot(sp.Character)
	local pos = root and root.CFrame
	doRespawn(sp)
	if pos then
		sp.CharacterAdded:Wait()
		task.wait(0.3)
		local newRoot = getRoot(sp.Character)
		if newRoot then newRoot.CFrame = pos end
	end
end)
addcmd("god",{},function(args,sp)
	local char = sp.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	local newHum = hum:Clone()
	newHum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
	newHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	hum:Destroy()
	newHum.Parent = char
	newHum.Health = newHum.MaxHealth
	notify("God","Enabled")
end)


-- ══════════════════════════════════════════════════════════════════════════════
-- CHARACTER APPEARANCE
-- ══════════════════════════════════════════════════════════════════════════════

-- invisible
local invisRunning = false
addcmd("invisible",{"invis"},function(args,sp)
	if invisRunning then return end
	invisRunning = true
	local char = sp.Character; char.Archivable=true
	local clone = char:Clone(); clone.Parent=game:GetService("Lighting")
	local function hideParts(c)
		for _, v in pairs(c:GetDescendants()) do
			if v:IsA("BasePart") then v.Transparency = v.Name=="HumanoidRootPart" and 1 or 0.5 end
		end
	end
	hideParts(clone)
	sp.Character = clone; task.wait(0.1); sp.Character = char
	clone:Destroy(); invisRunning = false
	notify("Invisible","You are now invisible to others")
end)
addcmd("visible",{"vis","uninvisible"},function(args,sp)
	invisRunning = false
	notify("Visible","You are now visible")
end)

-- nolimbs / noarms / nolegs
addcmd("nolimbs",{"rlimbs"},function(args,sp)
	local c = sp.Character; if not c then return end
	for _, v in pairs(c:GetChildren()) do
		if v:IsA("BasePart") and (v.Name:find("Arm") or v.Name:find("Leg") or v.Name:find("Hand") or v.Name:find("Foot")) then
			v:Destroy()
		end
	end
end)
addcmd("noarms",{"rarms"},function(args,sp)
	for _, v in pairs(sp.Character:GetChildren()) do
		if v:IsA("BasePart") and v.Name:find("Arm") then v:Destroy() end
	end
end)
addcmd("nolegs",{"rlegs"},function(args,sp)
	for _, v in pairs(sp.Character:GetChildren()) do
		if v:IsA("BasePart") and v.Name:find("Leg") then v:Destroy() end
	end
end)

-- hats
addcmd("drophats",{"drophat"},function(args,sp)
	local hum = sp.Character:FindFirstChildOfClass("Humanoid")
	if hum then for _, a in pairs(hum:GetAccessories()) do a.Parent=workspace end end
end)
addcmd("nohats",{"deletehats","rhats"},function(args,sp)
	local hum = sp.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum:RemoveAccessories() end
end)
addcmd("blockhats",{},function(args,sp)
	local hum = sp.Character:FindFirstChildOfClass("Humanoid")
	if hum then for _, a in pairs(hum:GetAccessories()) do
		local m = a:FindFirstChildOfClass("SpecialMesh"); if m then m:Destroy() end
	end end
end)
addcmd("blockhead",{},function(args,sp)
	local head = sp.Character:FindFirstChild("Head")
	if head then local m = head:FindFirstChildOfClass("SpecialMesh"); if m then m:Destroy() end end
end)

-- naked / noface
addcmd("naked",{},function(args,sp)
	for _, v in pairs(sp.Character:GetDescendants()) do
		if v:IsA("Clothing") or v:IsA("ShirtGraphic") then v:Destroy() end
	end
end)
addcmd("noface",{"removeface"},function(args,sp)
	for _, v in pairs(sp.Character:GetDescendants()) do
		if v:IsA("Decal") and v.Name=="face" then v:Destroy() end
	end
end)

-- blockhead / creeper
addcmd("creeper",{},function(args,sp)
	local c = sp.Character
	local head = c:FindFirstChild("Head")
	if head then local m=head:FindFirstChildOfClass("SpecialMesh"); if m then m:Destroy() end end
	local la = c:FindFirstChild("Left Arm") or c:FindFirstChild("LeftUpperArm")
	local ra = c:FindFirstChild("Right Arm") or c:FindFirstChild("RightUpperArm")
	if la then la:Destroy() end; if ra then ra:Destroy() end
	local hum = c:FindFirstChildOfClass("Humanoid"); if hum then hum:RemoveAccessories() end
end)

-- nobgui / noname
addcmd("nobgui",{"nobillboardgui","noname"},function(args,sp)
	for _, v in pairs(sp.Character:GetDescendants()) do
		if v:IsA("BillboardGui") or v:IsA("SurfaceGui") then v:Destroy() end
	end
end)

-- nilchar / unnilchar
addcmd("nilchar",{},function(args,sp)
	if sp.Character then sp.Character.Parent=nil end
end)
addcmd("unnilchar",{"nonilchar"},function(args,sp)
	if sp.Character then sp.Character.Parent=workspace end
end)

-- clearcharappearance
addcmd("clearchar",{"clearcharappearance","clrchar"},function(args,sp)
	sp:ClearCharacterAppearance()
end)

-- strengthen / weaken
addcmd("strengthen",{},function(args,sp)
	local density = tonumber(args[1]) or 100
	for _, v in pairs(sp.Character:GetDescendants()) do
		if v:IsA("BasePart") then v.CustomPhysicalProperties = PhysicalProperties.new(density,0.3,0.5) end
	end
end)
addcmd("weaken",{},function(args,sp)
	for _, v in pairs(sp.Character:GetDescendants()) do
		if v:IsA("BasePart") then v.CustomPhysicalProperties = PhysicalProperties.new(0,0.3,0.5) end
	end
end)
addcmd("unweaken",{"unstrengthen"},function(args,sp)
	for _, v in pairs(sp.Character:GetDescendants()) do
		if v:IsA("BasePart") then v.CustomPhysicalProperties = PhysicalProperties.new(0.7,0.3,0.5) end
	end
end)

-- deletevelocity
addcmd("deletevelocity",{"dv","removeforces"},function(args,sp)
	for _, v in pairs(sp.Character:GetDescendants()) do
		if v:IsA("BodyVelocity") or v:IsA("BodyGyro") or v:IsA("BodyForce") or v:IsA("BodyAngularVelocity") then
			v:Destroy()
		end
	end
end)

-- noroot
addcmd("noroot",{"removeroot","rroot"},function(args,sp)
	local char = sp.Character; if not char then return end
	char.Parent=nil
	local hrp = getRoot(char); if hrp then hrp:Destroy() end
	char.Parent=workspace
end)

-- split (R15 only)
addcmd("split",{},function(args,sp)
	if r15(sp) then
		local w = sp.Character.UpperTorso:FindFirstChild("Waist")
		if w then w:Destroy() end
	else notify("Split","Requires R15") end
end)

-- chardelete
addcmd("chardelete",{"cd"},function(args,sp)
	local name = lower(getstring(1,args))
	for _, v in pairs(sp.Character:GetDescendants()) do
		if lower(v.Name) == name then v:Destroy() end
	end
end)

-- ══════════════════════════════════════════════════════════════════════════════
-- ANIMATIONS
-- ══════════════════════════════════════════════════════════════════════════════

local function loadAnim(sp, id, speed, looped)
	local anim = Instance.new("Animation")
	anim.AnimationId = "rbxassetid://"..tostring(id):match("%d+") or tostring(id)
	local hum = sp.Character:FindFirstChildOfClass("Humanoid")
	local track = hum:LoadAnimation(anim)
	track.Priority = Enum.AnimationPriority.Action
	if looped then track.Looped = true end
	track:Play()
	if speed then track:AdjustSpeed(tonumber(speed) or 1) end
	return track
end

addcmd("animation",{"anim"},function(args,sp)
	pcall(loadAnim, sp, args[1], args[2], false)
end)
addcmd("emote",{"em"},function(args,sp)
	pcall(loadAnim, sp, args[1], args[2], false)
end)
addcmd("dance",{},function(args,sp)
	local dances = r15(sp)
		and {"3333432454","4555808220","4049037604","4555782893"}
		or  {"27789359","30196114","248263260","45834924","33796059"}
	pcall(loadAnim, sp, dances[math.random(1,#dances)], 1, true)
end)
addcmd("spasm",{},function(args,sp)
	pcall(loadAnim, sp, "33796059", 99, true)
end)
addcmd("headthrow",{},function(args,sp)
	pcall(loadAnim, sp, "35154961", 1, false)
end)
addcmd("noanim",{},function(args,sp)
	local a = sp.Character:FindFirstChild("Animate"); if a then a.Disabled=true end
end)
addcmd("reanim",{},function(args,sp)
	local a = sp.Character:FindFirstChild("Animate"); if a then a.Disabled=false end
end)
addcmd("animspeed",{},function(args,sp)
	local spd = tonumber(args[1]) or 1
	local hum = sp.Character:FindFirstChildOfClass("Humanoid")
	for _, t in pairs(hum:GetPlayingAnimationTracks()) do t:AdjustSpeed(spd) end
end)
addcmd("stopanims",{"stopanimations"},function(args,sp)
	local hum = sp.Character:FindFirstChildOfClass("Humanoid")
	for _, t in pairs(hum:GetPlayingAnimationTracks()) do t:Stop() end
end)
addcmd("refreshanims",{"refreshanimations"},function(args,sp)
	local a = sp.Character:FindFirstChild("Animate")
	local hum = sp.Character:FindFirstChildOfClass("Humanoid")
	if a and hum then
		a.Disabled=true
		for _, t in pairs(hum:GetPlayingAnimationTracks()) do t:Stop() end
		a.Disabled=false
	end
end)
addcmd("freezeanims",{},function(args,sp)
	local hum = sp.Character:FindFirstChildOfClass("Humanoid")
	for _, t in pairs(hum:GetPlayingAnimationTracks()) do t:AdjustSpeed(0) end
end)
addcmd("unfreezeanims",{},function(args,sp)
	local hum = sp.Character:FindFirstChildOfClass("Humanoid")
	for _, t in pairs(hum:GetPlayingAnimationTracks()) do t:AdjustSpeed(1) end
end)
addcmd("copyanim",{"copyanimation","copyemote"},function(args,sp)
	for _, v in pairs(getPlayer(args[1],sp)) do
		if v.Character then
			local hum1 = sp.Character:FindFirstChildOfClass("Humanoid")
			local hum2 = v.Character:FindFirstChildOfClass("Humanoid")
			for _, t in pairs(hum1:GetPlayingAnimationTracks()) do t:Stop() end
			for _, t in pairs(hum2:GetPlayingAnimationTracks()) do
				pcall(function()
					local track = hum1:LoadAnimation(t.Animation)
					track:Play(0.1,1,t.Speed)
					track.TimePosition = t.TimePosition
				end)
			end
		end
	end
end)

-- ══════════════════════════════════════════════════════════════════════════════
-- TOOLS
-- ══════════════════════════════════════════════════════════════════════════════

addcmd("btools",{},function(args,sp)
	for i=1,4 do
		local t=Instance.new("HopperBin"); t.BinType=i
		t.Parent=sp:FindFirstChildOfClass("Backpack")
	end
	notify("Btools","Given")
end)
addcmd("f3x",{},function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/refs/heads/main/f3x.lua"))()
end)
addcmd("tools",{"gears"},function(args,sp)
	local bp = sp:FindFirstChildOfClass("Backpack")
	local function copy(inst)
		for _, v in pairs(inst:GetChildren()) do
			if v:IsA("Tool") or v:IsA("HopperBin") then v:Clone().Parent=bp end
			copy(v)
		end
	end
	copy(game:GetService("Lighting")); copy(game:GetService("ReplicatedStorage"))
	notify("Tools","Copied from ReplicatedStorage and Lighting")
end)
addcmd("notools",{"rtools","deletetools","removetools"},function(args,sp)
	for _, v in pairs(sp:FindFirstChildOfClass("Backpack"):GetChildren()) do
		if v:IsA("Tool") or v:IsA("HopperBin") then v:Destroy() end
	end
	for _, v in pairs(sp.Character:GetChildren()) do
		if v:IsA("Tool") or v:IsA("HopperBin") then v:Destroy() end
	end
end)
addcmd("copytools",{},function(args,sp)
	for _, v in pairs(getPlayer(args[1],sp)) do
		for _, t in pairs(v:FindFirstChildOfClass("Backpack"):GetChildren()) do
			if t:IsA("Tool") or t:IsA("HopperBin") then t:Clone().Parent=sp:FindFirstChildOfClass("Backpack") end
		end
	end
end)
addcmd("droptools",{"droptool"},function(args,sp)
	for _, v in pairs(sp:FindFirstChildOfClass("Backpack"):GetChildren()) do
		if v:IsA("Tool") then v.Parent=sp.Character end
	end
	task.wait()
	for _, v in pairs(sp.Character:GetChildren()) do
		if v:IsA("Tool") then v.Parent=workspace end
	end
end)
addcmd("droppabletools",{},function(args,sp)
	for _, v in pairs(sp:FindFirstChildOfClass("Backpack"):GetChildren()) do
		if v:IsA("Tool") then v.CanBeDropped=true end
	end
end)
addcmd("equiptools",{},function(args,sp)
	for _, v in pairs(sp:FindFirstChildOfClass("Backpack"):GetChildren()) do
		if v:IsA("Tool") then v.Parent=sp.Character end
	end
end)
addcmd("unequiptools",{},function(args,sp)
	local hum = sp.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum:UnequipTools() end
end)
addcmd("dst",{"deleteselectedtool"},function(args,sp)
	for _, v in pairs(sp.Character:GetChildren()) do
		if v:IsA("Tool") or v:IsA("HopperBin") then v:Destroy() end
	end
end)
addcmd("grabtools",{},function(args,sp)
	local hum = sp.Character:FindFirstChildOfClass("Humanoid")
	workspace.ChildAdded:Connect(function(child)
		if child:IsA("BackpackItem") and child:FindFirstChild("Handle") then
			hum:EquipTool(child)
		end
	end)
	notify("Grabtools","Enabled")
end)

local currentToolSize, currentGripPos = nil, nil
addcmd("reach",{},function(args,sp)
	execCmd("unreach")
	task.wait()
	for _, v in pairs(sp.Character:GetDescendants()) do
		if v:IsA("Tool") then
			currentToolSize = v.Handle.Size
			currentGripPos  = v.GripPos
			v.Handle.Size   = Vector3.new(0.5,0.5, tonumber(args[1]) or 60)
			v.GripPos       = Vector3.new(0,0,0)
			v.Handle.Massless = true
			sp.Character:FindFirstChildOfClass("Humanoid"):UnequipTools()
		end
	end
end)
addcmd("unreach",{"noreach"},function(args,sp)
	for _, v in pairs(sp.Character:GetDescendants()) do
		if v:IsA("Tool") and currentToolSize then
			v.Handle.Size = currentToolSize
			v.GripPos = currentGripPos
		end
	end
end)
addcmd("grippos",{},function(args,sp)
	for _, v in pairs(sp.Character:GetDescendants()) do
		if v:IsA("Tool") then
			v.Parent = sp:FindFirstChildOfClass("Backpack")
			v.GripPos = Vector3.new(tonumber(args[1]) or 0, tonumber(args[2]) or 0, tonumber(args[3]) or 0)
			v.Parent = sp.Character
		end
	end
end)
addcmd("usetools",{},function(args,sp)
	local n = tonumber(args[1]) or 1
	local d = tonumber(args[2]) or 0
	for _, v in pairs(sp:FindFirstChildOfClass("Backpack"):GetChildren()) do
		v.Parent = sp.Character
		task.spawn(function()
			for _ = 1, n do v:Activate(); if d>0 then task.wait(d) end end
			v.Parent = sp:FindFirstChildOfClass("Backpack")
		end)
	end
end)


-- ══════════════════════════════════════════════════════════════════════════════
-- ESP / VISUAL
-- ══════════════════════════════════════════════════════════════════════════════

local espEnabled  = false
local chamsEnabled = false
local espTransparency = 0.3

local function makeESP(plr, teamLogic)
	task.spawn(function()
		local folder = Instance.new("Folder")
		folder.Name = plr.Name .. "_ESP"
		folder.Parent = CoreGui
		repeat task.wait(1) until plr.Character and getRoot(plr.Character)
		for _, v in pairs(plr.Character:GetChildren()) do
			if v:IsA("BasePart") then
				local box = Instance.new("BoxHandleAdornment")
				box.Name = plr.Name
				box.Parent = folder
				box.Adornee = v
				box.AlwaysOnTop = true
				box.ZIndex = 10
				box.Size = v.Size
				box.Transparency = espTransparency
				if teamLogic then
					box.Color = plr.TeamColor == lp.TeamColor and BrickColor.new("Bright green") or BrickColor.new("Bright red")
				else
					box.Color = plr.TeamColor
				end
			end
		end
		if plr.Character:FindFirstChild("Head") then
			local bb = Instance.new("BillboardGui")
			bb.Name = plr.Name
			bb.Parent = folder
			bb.Adornee = plr.Character.Head
			bb.Size = UDim2.new(0,100,0,150)
			bb.StudsOffset = Vector3.new(0,1,0)
			bb.AlwaysOnTop = true
			local lbl = Instance.new("TextLabel")
			lbl.Parent = bb
			lbl.BackgroundTransparency = 1
			lbl.Position = UDim2.new(0,0,0,-50)
			lbl.Size = UDim2.new(1,0,1,0)
			lbl.Font = Enum.Font.GothamBold
			lbl.TextSize = 14
			lbl.TextColor3 = Color3.new(1,1,1)
			lbl.TextStrokeTransparency = 0
			lbl.ZIndex = 10
			RunService.RenderStepped:Connect(function()
				if not plr.Character or not getRoot(plr.Character) then return end
				local dist = math.floor((getRoot(lp.Character).Position - getRoot(plr.Character).Position).Magnitude)
				local hum = plr.Character:FindFirstChildOfClass("Humanoid")
				lbl.Text = plr.Name .. " | " .. (hum and math.floor(hum.Health) or "?") .. "hp | " .. dist .. "st"
			end)
		end
		plr.CharacterAdded:Connect(function()
			if espEnabled then
				folder:Destroy()
				makeESP(plr, teamLogic)
			end
		end)
	end)
end

addcmd("esp",{},function(args,sp)
	if chamsEnabled then return notify("ESP","Disable chams first") end
	espEnabled = true
	for _, v in pairs(Players:GetPlayers()) do
		if v ~= lp then makeESP(v, false) end
	end
	notify("ESP","Enabled")
end)
addcmd("espteam",{},function(args,sp)
	if chamsEnabled then return notify("ESP","Disable chams first") end
	espEnabled = true
	for _, v in pairs(Players:GetPlayers()) do
		if v ~= lp then makeESP(v, true) end
	end
	notify("ESP Team","Enabled")
end)
addcmd("noesp",{"unesp","unespteam"},function()
	espEnabled = false
	for _, v in pairs(CoreGui:GetChildren()) do
		if v.Name:sub(-4) == "_ESP" then v:Destroy() end
	end
	notify("ESP","Disabled")
end)
addcmd("esptransparency",{},function(args)
	espTransparency = tonumber(args[1]) or 0.3
end)

addcmd("chams",{},function(args,sp)
	if espEnabled then return notify("Chams","Disable ESP first") end
	chamsEnabled = true
	for _, v in pairs(Players:GetPlayers()) do
		if v ~= lp then makeESP(v, false) end
	end
	notify("Chams","Enabled")
end)
addcmd("nochams",{"unchams"},function()
	chamsEnabled = false
	for _, v in pairs(CoreGui:GetChildren()) do
		if v.Name:sub(-5) == "_CHMS" then v:Destroy() end
	end
	notify("Chams","Disabled")
end)

addcmd("locate",{},function(args,sp)
	for _, v in pairs(getPlayer(args[1],sp)) do makeESP(v,false) end
end)
addcmd("nolocate",{"unlocate"},function(args,sp)
	for _, v in pairs(getPlayer(args[1],sp)) do
		local f = CoreGui:FindFirstChild(v.Name.."_LC")
		if f then f:Destroy() end
	end
end)

-- xray
local xrayEnabled = false
addcmd("xray",{},function()
	xrayEnabled = true
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") and not v.Parent:FindFirstChildOfClass("Humanoid") then
			v.LocalTransparencyModifier = 0.5
		end
	end
end)
addcmd("unxray",{"noxray"},function()
	xrayEnabled = false
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") then v.LocalTransparencyModifier = 0 end
	end
end)
addcmd("togglexray",{},function()
	if xrayEnabled then execCmd("unxray") else execCmd("xray") end
end)
addcmd("loopxray",{},function()
	RunService.RenderStepped:Connect(function()
		if not xrayEnabled then return end
		for _, v in pairs(workspace:GetDescendants()) do
			if v:IsA("BasePart") and not v.Parent:FindFirstChildOfClass("Humanoid") then
				v.LocalTransparencyModifier = 0.5
			end
		end
	end)
	xrayEnabled = true
end)

-- hitbox
addcmd("hitbox",{},function(args,sp)
	for _, v in pairs(getPlayer(args[1],sp)) do
		local root = getRoot(v.Character)
		if root then
			local s = tonumber(args[2]) or 5
			root.Size = Vector3.new(s,s,s)
			root.Transparency = tonumber(args[3]) or 0.5
			root.CanCollide = false
		end
	end
end)
addcmd("hitboxes",{},function()
	settings():GetService("RenderSettings").ShowBoundingBoxes = true
end)
addcmd("unhitboxes",{},function()
	settings():GetService("RenderSettings").ShowBoundingBoxes = false
end)
addcmd("headsize",{},function(args,sp)
	for _, v in pairs(getPlayer(args[1],sp)) do
		local head = v.Character and v.Character:FindFirstChild("Head")
		if head then
			local s = tonumber(args[2]) or 1
			head.Size = Vector3.new(s*2, s, s)
		end
	end
end)


-- ══════════════════════════════════════════════════════════════════════════════
-- CAMERA
-- ══════════════════════════════════════════════════════════════════════════════

local viewing = nil
addcmd("view",{"spectate"},function(args,sp)
	for _, v in pairs(getPlayer(args[1],sp)) do
		viewing = v
		cam.CameraSubject = v.Character
		notify("Spectate","Viewing "..v.Name)
	end
end)
addcmd("unview",{"unspectate"},function(args,sp)
	viewing = nil
	cam.CameraSubject = sp.Character
	notify("Spectate","Stopped viewing")
end)

addcmd("firstp",{},function(args,sp) sp.CameraMode="LockFirstPerson" end)
addcmd("thirdp",{},function(args,sp) sp.CameraMode="Classic" end)
addcmd("fov",{},function(args) cam.FieldOfView = tonumber(args[1]) or 70 end)
addcmd("maxzoom",{},function(args,sp) sp.CameraMaxZoomDistance = tonumber(args[1]) or 400 end)
addcmd("minzoom",{},function(args,sp) sp.CameraMinZoomDistance = tonumber(args[1]) or 0.5 end)
addcmd("fixcam",{"restorecam"},function(args,sp)
	cam:remove(); task.wait(0.1)
	cam.CameraSubject = sp.Character:FindFirstChildOfClass("Humanoid")
	cam.CameraType = Enum.CameraType.Custom
end)
addcmd("lookat",{},function(args,sp)
	for _, v in pairs(getPlayer(args[1],sp)) do
		if v.Character and v.Character:FindFirstChild("Head") then
			cam.CFrame = CFrame.new(cam.CFrame.Position, v.Character.Head.CFrame.Position)
		end
	end
end)
addcmd("gotocam",{"gotocamera"},function(args,sp)
	getRoot(sp.Character).CFrame = cam.CFrame
end)
addcmd("tgotocam",{"tweengotocam"},function(args,sp)
	TweenService:Create(getRoot(sp.Character), TweenInfo.new(tweenSpd, Enum.EasingStyle.Linear),
		{CFrame = cam.CFrame}):Play()
end)
addcmd("freecam",{"fc"},function()
	notify("Freecam","Use WASD + mouse to move. Type 'unfreecam' to exit")
	-- lightweight freecam
	local oldSubject = cam.CameraSubject
	cam.CameraType = Enum.CameraType.Scriptable
	local conn; conn = RunService.RenderStepped:Connect(function(dt)
		if not _G.MWFC then conn:Disconnect(); cam.CameraType=Enum.CameraType.Custom; cam.CameraSubject=oldSubject; return end
		local spd = 20 * dt
		local cf = cam.CFrame
		local move = Vector3.new(
			(UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.A) and 1 or 0),
			(UserInputService:IsKeyDown(Enum.KeyCode.E) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.Q) and 1 or 0),
			(UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0)
		) * spd
		cam.CFrame = cf * CFrame.new(move)
	end)
	_G.MWFC = true
end)
addcmd("unfreecam",{"unfc","nofc"},function()
	_G.MWFC = false; notify("Freecam","Disabled")
end)
addcmd("freecamspeed",{"fcspeed"},function(args) end) -- speed handled inline above

-- ══════════════════════════════════════════════════════════════════════════════
-- LIGHTING
-- ══════════════════════════════════════════════════════════════════════════════

local origLighting = {
	Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime,
	FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart,
	GlobalShadows = Lighting.GlobalShadows, Ambient = Lighting.Ambient,
	OutdoorAmbient = Lighting.OutdoorAmbient,
}
addcmd("fullbright",{"fb"},function()
	Lighting.Brightness=2; Lighting.ClockTime=14; Lighting.FogEnd=100000
	Lighting.GlobalShadows=false; Lighting.OutdoorAmbient=Color3.fromRGB(128,128,128)
end)
addcmd("loopfullbright",{"loopfb"},function()
	RunService.RenderStepped:Connect(function()
		Lighting.Brightness=2; Lighting.ClockTime=14; Lighting.FogEnd=100000
		Lighting.GlobalShadows=false
	end)
end)
addcmd("day",{},function() Lighting.ClockTime=14 end)
addcmd("night",{},function() Lighting.ClockTime=0 end)
addcmd("nofog",{},function()
	Lighting.FogEnd=100000; Lighting.FogStart=100000
	for _, v in pairs(Lighting:GetDescendants()) do if v:IsA("Atmosphere") then v:Destroy() end end
end)
addcmd("brightness",{},function(args) Lighting.Brightness=tonumber(args[1]) or 2 end)
addcmd("ambient",{},function(args)
	local c = Color3.new(tonumber(args[1]) or 0, tonumber(args[2]) or 0, tonumber(args[3]) or 0)
	Lighting.Ambient=c; Lighting.OutdoorAmbient=c
end)
addcmd("globalshadows",{"gshadows"},function() Lighting.GlobalShadows=true end)
addcmd("unglobalshadows",{"nogshadows"},function() Lighting.GlobalShadows=false end)
addcmd("restorelighting",{"rlighting"},function()
	for k, v in pairs(origLighting) do Lighting[k]=v end
	notify("Lighting","Restored")
end)
addcmd("light",{},function(args,sp)
	local root = getRoot(sp.Character); if not root then return end
	local pl = Instance.new("PointLight"); pl.Range=tonumber(args[1]) or 30
	pl.Brightness=tonumber(args[2]) or 5; pl.Parent=root
end)
addcmd("nolight",{"unlight"},function(args,sp)
	for _, v in pairs(sp.Character:GetDescendants()) do
		if v:IsA("PointLight") then v:Destroy() end
	end
end)

-- ══════════════════════════════════════════════════════════════════════════════
-- CHAT
-- ══════════════════════════════════════════════════════════════════════════════

local spamming = false
local spamSpeed = 1
addcmd("chat",{"say"},function(args,sp) chatMessage(getstring(1,args)) end)
addcmd("spam",{},function(args,sp)
	spamming=true
	local msg = getstring(1,args)
	task.spawn(function()
		repeat chatMessage(msg); task.wait(spamSpeed) until not spamming
	end)
end)
addcmd("unspam",{"nospam"},function() spamming=false end)
addcmd("spamspeed",{},function(args) spamSpeed=tonumber(args[1]) or 1 end)
addcmd("whisper",{"pm"},function(args,sp)
	for _, v in pairs(getPlayer(args[1],sp)) do
		chatMessage("/w "..v.Name.." "..getstring(2,args))
	end
end)
addcmd("bubblechat",{},function()
	local bcc = TextChatService:FindFirstChildOfClass("BubbleChatConfiguration")
	if bcc then bcc.Enabled=true end
end)
addcmd("unbubblechat",{"nobubblechat"},function()
	local bcc = TextChatService:FindFirstChildOfClass("BubbleChatConfiguration")
	if bcc then bcc.Enabled=false end
end)
addcmd("chatwindow",{},function()
	local cwc = TextChatService:FindFirstChildOfClass("ChatWindowConfiguration")
	if cwc then cwc.Enabled=true end
end)
addcmd("unchatwindow",{"nochatwindow"},function()
	local cwc = TextChatService:FindFirstChildOfClass("ChatWindowConfiguration")
	if cwc then cwc.Enabled=false end
end)
addcmd("muteallvcs",{"muteallvoices"},function()
	pcall(function() game:GetService("VoiceChatInternal"):SubscribePauseAll(true) end)
end)
addcmd("unmuteallvcs",{"unmuteallvoices"},function()
	pcall(function() game:GetService("VoiceChatInternal"):SubscribePauseAll(false) end)
end)
addcmd("mutevc",{},function(args,sp)
	for _, v in pairs(getPlayer(args[1],sp)) do
		pcall(function() game:GetService("VoiceChatInternal"):SubscribePause(v.UserId,true) end)
	end
end)
addcmd("unmutevc",{},function(args,sp)
	for _, v in pairs(getPlayer(args[1],sp)) do
		pcall(function() game:GetService("VoiceChatInternal"):SubscribePause(v.UserId,false) end)
	end
end)

-- ══════════════════════════════════════════════════════════════════════════════
-- SERVER / GAME
-- ══════════════════════════════════════════════════════════════════════════════

addcmd("rejoin",{"rj"},function()
	TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, lp)
end)
addcmd("serverhop",{"shop"},function()
	local ok, body = pcall(function()
		return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true"))
	end)
	if ok and body and body.data then
		for _, s in pairs(body.data) do
			if s.id ~= game.JobId then
				TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, lp)
				return
			end
		end
	end
	notify("Serverhop","No server found")
end)
addcmd("gameteleport",{"gametp"},function(args)
	TeleportService:Teleport(tonumber(args[1]))
end)
addcmd("antiidle",{"antiafk"},function()
	if getconnections then
		for _, c in pairs(getconnections(lp.Idled)) do pcall(function() c:Disconnect() end) end
	else
		lp.Idled:Connect(function()
			game:GetService("VirtualUser"):CaptureController()
			game:GetService("VirtualUser"):ClickButton2(Vector2.new())
		end)
	end
	notify("Anti Idle","Enabled")
end)
addcmd("autorejoin",{"autorj"},function()
	GuiService.ErrorMessageChanged:Connect(function() execCmd("rejoin") end)
	notify("Auto Rejoin","Enabled")
end)
addcmd("jobid",{},function()
	toClipboard("roblox://placeId="..game.PlaceId.."&gameInstanceId="..game.JobId)
	notify("Job ID",game.JobId)
end)
addcmd("notifyjobid",{},function()
	notify("Job ID / Place ID", game.JobId.." / "..game.PlaceId)
end)
addcmd("copyplaceid",{"placeid"},function() toClipboard(game.PlaceId); notify("Place ID","Copied") end)
addcmd("copygameid",{"gameid"},function() toClipboard(game.GameId); notify("Game ID","Copied") end)
addcmd("noprompts",{},function() CoreGui.PurchasePromptApp.Enabled=false end)
addcmd("showprompts",{},function() CoreGui.PurchasePromptApp.Enabled=true end)
addcmd("clearerror",{},function() GuiService:ClearError() end)
addcmd("exit",{},function() game:Shutdown() end)
addcmd("savegame",{"saveplace"},function()
	if saveinstance then saveinstance(); notify("Save","Done") else notify("Save","Not supported by this executor") end
end)
addcmd("antilag",{"boostfps","lowgraphics"},function()
	Lighting.GlobalShadows=false; Lighting.FogEnd=9e9
	settings().Rendering.QualityLevel=1
	for _, v in pairs(game:GetDescendants()) do
		if v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Lifetime=NumberRange.new(0)
		elseif v:IsA("BasePart") then v.CastShadow=false end
	end
	notify("Anti Lag","Applied")
end)
addcmd("volume",{"vol"},function(args)
	UserSettings():GetService("UserGameSettings").MasterVolume = (tonumber(args[1]) or 5)/10
end)
addcmd("norender",{},function() RunService:Set3dRenderingEnabled(false) end)
addcmd("render",{},function() RunService:Set3dRenderingEnabled(true) end)
addcmd("screenshot",{"scrnshot"},function() CoreGui:TakeScreenshot() end)
addcmd("record",{"rec"},function() CoreGui:ToggleRecording() end)
addcmd("cancelteleport",{"canceltp"},function() TeleportService:TeleportCancel() end)

-- ══════════════════════════════════════════════════════════════════════════════
-- UI / COREGUI
-- ══════════════════════════════════════════════════════════════════════════════

addcmd("enable",{},function(args)
	local t = args[1] and args[1]:lower()
	if t=="reset" then StarterGui:SetCore("ResetButtonCallback",true)
	elseif t=="all" then StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All,true)
	else pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType[t],true) end) end
end)
addcmd("disable",{},function(args)
	local t = args[1] and args[1]:lower()
	if t=="reset" then StarterGui:SetCore("ResetButtonCallback",false)
	elseif t=="all" then StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All,false)
	else pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType[t],false) end) end
end)
addcmd("console",{},function()
	StarterGui:SetCore("DevConsoleVisible",true)
end)
addcmd("explorer",{"dex"},function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
end)
addcmd("remotespy",{"rspy"},function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua"))()
end)
addcmd("notify",{},function(args) notify("Notification", getstring(1,args)) end)

-- ══════════════════════════════════════════════════════════════════════════════
-- WORKSPACE
-- ══════════════════════════════════════════════════════════════════════════════

addcmd("delete",{"remove"},function(args)
	local n = lower(getstring(1,args))
	for _, v in pairs(workspace:GetDescendants()) do if lower(v.Name)==n then v:Destroy() end end
end)
addcmd("deleteclass",{"dc"},function(args)
	local n = lower(getstring(1,args))
	for _, v in pairs(workspace:GetDescendants()) do if lower(v.ClassName)==n then v:Destroy() end end
end)
addcmd("lockws",{"lockworkspace"},function()
	for _, v in pairs(workspace:GetDescendants()) do if v:IsA("BasePart") then v.Locked=true end end
end)
addcmd("unlockws",{"unlockworkspace"},function()
	for _, v in pairs(workspace:GetDescendants()) do if v:IsA("BasePart") then v.Locked=false end end
end)
addcmd("removeterrain",{"rterrain","noterrain"},function()
	workspace:FindFirstChildOfClass("Terrain"):Clear()
end)
addcmd("destroyheight",{"dh"},function(args)
	workspace.FallenPartsDestroyHeight = tonumber(args[1]) or -500
end)
addcmd("gotopart",{"topart"},function(args,sp)
	local n = lower(getstring(1,args))
	for _, v in pairs(workspace:GetDescendants()) do
		if lower(v.Name)==n and v:IsA("BasePart") then getRoot(sp.Character).CFrame=v.CFrame end
	end
end)
addcmd("gotomodel",{"tomodel"},function(args,sp)
	local n = lower(getstring(1,args))
	for _, v in pairs(workspace:GetDescendants()) do
		if lower(v.Name)==n and v:IsA("Model") then
			pcall(function() getRoot(sp.Character).CFrame=v:GetModelCFrame() end)
		end
	end
end)
addcmd("bringpart",{},function(args,sp)
	local n = lower(getstring(1,args))
	for _, v in pairs(workspace:GetDescendants()) do
		if lower(v.Name)==n and v:IsA("BasePart") then v.CFrame=getRoot(sp.Character).CFrame end
	end
end)
addcmd("noclickdetectorlimits",{"nocdlimits"},function()
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("ClickDetector") then v.MaxActivationDistance=math.huge end
	end
end)
addcmd("fireclickdetectors",{"firecd"},function(args)
	if not fireclickdetector then return notify("Error","fireclickdetector not supported") end
	local n = args[1] and lower(getstring(1,args))
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("ClickDetector") then
			if not n or lower(v.Name)==n or lower(v.Parent.Name)==n then
				pcall(fireclickdetector, v)
			end
		end
	end
end)
addcmd("nopplimits",{"noproximitypromptlimits"},function()
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("ProximityPrompt") then v.MaxActivationDistance=math.huge end
	end
end)
addcmd("firepp",{"fireproximityprompts"},function(args)
	if not fireproximityprompt then return notify("Error","fireproximityprompt not supported") end
	local n = args[1] and lower(getstring(1,args))
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("ProximityPrompt") then
			if not n or lower(v.Name)==n or lower(v.Parent.Name)==n then
				pcall(fireproximityprompt, v)
			end
		end
	end
end)

-- ══════════════════════════════════════════════════════════════════════════════
-- PLAYER INFO
-- ══════════════════════════════════════════════════════════════════════════════

addcmd("age",{},function(args,sp)
	for _, v in pairs(getPlayer(args[1],sp)) do
		notify("Age", v.Name.."'s age: "..v.AccountAge.." days")
	end
end)
addcmd("userid",{"id"},function(args,sp)
	for _, v in pairs(getPlayer(args[1],sp)) do notify("User ID",v.Name..": "..v.UserId) end
end)
addcmd("copyid",{"copyuserid"},function(args,sp)
	for _, v in pairs(getPlayer(args[1],sp)) do toClipboard(v.UserId) end
end)
addcmd("copyname",{"copyuser"},function(args,sp)
	for _, v in pairs(getPlayer(args[1],sp)) do toClipboard(v.Name) end
end)
addcmd("inspect",{"examine"},function(args,sp)
	for _, v in pairs(getPlayer(args[1],sp)) do
		GuiService:InspectPlayerFromUserId(v.UserId)
	end
end)
addcmd("friend",{},function(args,sp)
	for _, v in pairs(getPlayer(args[1],sp)) do pcall(function() sp:RequestFriendship(v) end) end
end)
addcmd("unfriend",{},function(args,sp)
	for _, v in pairs(getPlayer(args[1],sp)) do pcall(function() sp:RevokeFriendship(v) end) end
end)

-- ══════════════════════════════════════════════════════════════════════════════
-- MISC
-- ══════════════════════════════════════════════════════════════════════════════

addcmd("addalias",{},function(args,sp)
	if #args<2 then return end
	local cmd = findCmd(lower(args[1]))
	if cmd then
		customAlias[lower(args[2])] = cmd
		aliases[#aliases+1] = {cmd=args[1], alias=args[2]}
		notify("Alias","Added '"..args[2].."' -> "..args[1])
	end
end)
addcmd("removealias",{},function(args,sp)
	if #args<1 then return end
	customAlias[lower(args[1])] = nil
	notify("Alias","Removed "..args[1])
end)
addcmd("notifyping",{"ping"},function(args,sp)
	notify("Ping", math.round(sp:GetNetworkPing()*1000).."ms")
end)
addcmd("setprefix",{},function(args)
	if args[1] then PREFIX=args[1]; notify("Prefix","Set to: "..PREFIX) end
end)

-- fling
local flinging = false
addcmd("fling",{},function(args,sp)
	flinging = true
	execCmd("noclip")
	for _, v in pairs(sp.Character:GetDescendants()) do
		if v:IsA("BasePart") then v.CustomPhysicalProperties=PhysicalProperties.new(100,0.3,0.5) end
	end
	local bav = Instance.new("BodyAngularVelocity")
	bav.Name="MW_Fling"; bav.Parent=getRoot(sp.Character)
	bav.AngularVelocity=Vector3.new(0,99999,0); bav.MaxTorque=Vector3.new(0,math.huge,0); bav.P=math.huge
	task.spawn(function()
		repeat bav.AngularVelocity=Vector3.new(0,99999,0); task.wait(0.2)
		bav.AngularVelocity=Vector3.new(0,0,0); task.wait(0.1) until not flinging
	end)
end)
addcmd("unfling",{"nofling"},function(args,sp)
	flinging=false; execCmd("clip")
	local root = getRoot(sp.Character)
	if root then for _, v in pairs(root:GetChildren()) do if v.Name=="MW_Fling" then v:Destroy() end end end
end)

-- loopoof
local oofing = false
addcmd("loopoof",{},function()
	oofing=true
	task.spawn(function()
		repeat
			for _, v in pairs(Players:GetPlayers()) do
				if v.Character and v.Character:FindFirstChild("Head") then
					for _, s in pairs(v.Character.Head:GetChildren()) do
						if s:IsA("Sound") then s.Playing=true end
					end
				end
			end
			task.wait(0.1)
		until not oofing
	end)
end)
addcmd("unloopoof",{},function() oofing=false end)

-- muteboombox
addcmd("muteboombox",{},function(args,sp)
	for _, v in pairs(getPlayer(args[1],sp)) do
		if v.Character then
			for _, s in pairs(v.Character:GetDescendants()) do
				if s:IsA("Sound") and s.Playing then s.Playing=false end
			end
		end
	end
end)
addcmd("unmuteboombox",{},function(args,sp)
	for _, v in pairs(getPlayer(args[1],sp)) do
		if v.Character then
			for _, s in pairs(v.Character:GetDescendants()) do
				if s:IsA("Sound") then s.Playing=true end
			end
		end
	end
end)

-- autoclick
local autoclicking = false
addcmd("autoclick",{},function(args)
	if not mouse1press or not mouse1release then
		return notify("Autoclick","Not supported by this executor")
	end
	autoclicking=true
	local cd=tonumber(args[1]) or 0.1; local rd=tonumber(args[2]) or 0.05
	task.spawn(function()
		repeat mouse1press(); task.wait(cd); mouse1release(); task.wait(rd) until not autoclicking
	end)
	notify("Autoclick","Enabled")
end)
addcmd("unautoclick",{"noautoclick"},function() autoclicking=false end)

notify("Mikeyware Cmds","Loaded — prefix: "..PREFIX)

-- refresh the name list now that all commands are registered
if _G.MWCmds then _G.MWCmds._cmdNames = getCmdNames() end
