local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local P = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local VIM = game:GetService("VirtualInputManager")
local VU = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local Collection = game:GetService("CollectionService")
local Pathfinding = game:GetService("PathfindingService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local LP = P.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

local env = getgenv and getgenv() or _G

local ISLAND_ORDER = {"starter","jungle","desert","snow","volcano","fossil"}
local ISLAND_DISPLAY = {"Starter","Jungle","Desert","Snow","Volcano","Fossil"}
local ISLAND_LABELS = {starter="Starter", jungle="Jungle", desert="Desert", snow="Snow", volcano="Volcano", fossil="Fossil"}
local ISLAND_IDS = {starter="island_starter", jungle="island_jungle", desert="island_desert", snow="island_snow", volcano="island_volcano", fossil="island_fossil"}
local REVERSE_ISLAND = {}
for k, v in pairs(ISLAND_IDS) do REVERSE_ISLAND[v] = k end

local MAIN_PARTS = {"HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso", "Head"}
local FISH_CAPACITY = 50

local Fish = {
    dead = false,
    running = false,
    farm = false,
    paused = false,
    firstPullDone = false,
    lastState = nil,
    lastCast = 0,
    lastSkill = 0,
    lastEquip = 0,
}

local SellBusy = false
local Tweening = false

local st = {
    fish=false, skill=false, bypass=false,
    sell=false, autoSellFull=false, useWalk=false,
    speed=36, speedOn=false,
    fakename=false, esp=false,
    bossEsp1=true, bossEsp2=true,
    liteGfx=false, autoLock=false,
    lockRarity={Legendary=true, Mythical=true, Divine=true},
    skillOrder={1,2,1,3},
    sellInt=300, island="starter", teleMode="fast",
    customName="DNHub 3.0",
    tagColorR=0.7, tagColorG=0.4, tagColorB=1.0, tagRainbow=false,
    autoBoss=false, bossReturn=true,
    tpMode="Instant", flySpeed=70, flyPin=3, tpCooldown=12,
    antiAfk=true, antiAfkInterval=50, antiAfkKey="F13",
    castHold=0.65, tapHold=0.045, firstPullTarget=0.96,
    qteDelay=0.2, skillSpacing=0.35, equipDelay=0.35,
    sellTravelMode="Tween", returnAfterSell=true,
    uiTheme="Dark", uiAccent="",
    graphicsLite=false,
    -- New features from FishingMaster
    autoRoll=false, rollType="Skill Master", rollMulti="x1",
    autoBuyRod=false, buyRodName="Stone Rod",
    autoIsland=false, autoIslandTarget="Starter",
    teleportToNPC=false, teleportTarget="Fish Merchant - Starter Island",
    playerMode=false, instantWarp=true,
    visualRodSkin="Default", visualAura="Default",
    boatType="Truck",
    autoQuest=false, questRodName="Crimson Bead Rod",
    autoUnlock=false,
}

local island = st.island
local sellInt = st.sellInt
local customName = st.customName
local uiS = {L=nil,R=nil,U=nil}

local Client, Catalog
pcall(function()
    local sd = RS:FindFirstChild("Stardust")
    if sd then
        local c = sd:FindFirstChild("Client")
        if c then Client = require(c) end
    end
    local data = RS:FindFirstChild("Data")
    local cat = data and data:FindFirstChild("Catalog")
    if cat then Catalog = require(cat) end
end)

local RarityPriority = {Common=1,Uncommon=2,Rare=3,Epic=4,Legendary=5,Mythical=6,Divine=7,Secret=8,Exotic=9,Huge=10}
local RarityEnums, SellEnums, FishingConfig, PullBarMath, FishStorageRules
pcall(function()
    local data = RS:FindFirstChild("Data")
    local enums = data and data:FindFirstChild("Enums")
    local cfg = data and data:FindFirstChild("Config")
    if enums then
        local r = enums:FindFirstChild("RarityEnums")
        local s = enums:FindFirstChild("SellEnums")
        if r then RarityEnums = require(r) end
        if s then SellEnums = require(s) end
    end
    if cfg then
        local f = cfg:FindFirstChild("FishingConfig")
        if f then FishingConfig = require(f) end
    end
    local shared = RS:FindFirstChild("Shared")
    local lib = shared and shared:FindFirstChild("Lib")
    if lib then
        local p = lib:FindFirstChild("PullBarMath")
        if p then PullBarMath = require(p) end
        local fs = lib:FindFirstChild("FishStorageRules")
        if fs then FishStorageRules = require(fs) end
    end
end)

local function getController(name)
    if Client and type(Client.GetController) == "function" then
        local ok, c = pcall(function() return Client.GetController(name) end)
        if ok then return c end
    end
    return nil
end

local function fetchProfile()
    local data = getController("PlayerDataV2Controller")
    if not data then return nil end
    local ok, profile = pcall(function() return data:Fetch() end)
    if ok and type(profile) == "table" then return profile end
    ok, profile = pcall(function() return data:Fetch(LP) end)
    if ok and type(profile) == "table" then return profile end
    return nil
end

local function heldRodId()
    local c = LP.Character
    if not c then return nil end
    for _, child in ipairs(c:GetChildren()) do
        if child:IsA("Tool") and Catalog and Catalog.Rod and Catalog.Rod.GetById and Catalog.Rod.GetById(child.Name) then
            return child.Name
        end
    end
    return nil
end

local function rodScore(rodId)
    if not (Catalog and Catalog.Rod and Catalog.Rod.GetById) then return nil end
    local cat = Catalog.Rod.GetById(rodId)
    if not cat then return nil end
    local dmg, luck = 0, 0
    for _, s in ipairs(cat.stats or {}) do
        if s.stat == "attackDamage" then dmg += s.value or 0
        elseif s.stat == "luck" then luck += s.value or 0 end
    end
    local rarity = RarityPriority[cat.rarity] or 0
    return dmg * 1e6 + luck * 1e3 + (cat.skillSlots or 0) * 10 + rarity
end

local function bestRodId(profile)
    local bestId, bestScore
    for rodId in pairs(profile.Rods or {}) do
        local s = rodScore(rodId)
        if s and (not bestScore or s > bestScore) then bestId, bestScore = rodId, s end
    end
    return bestId
end

local function hasRodTool(rodId)
    local bp = LP:FindFirstChildOfClass("Backpack")
    return bp ~= nil and bp:FindFirstChild(rodId) ~= nil
end

local function equipRod(rodId)
    local backpack = getController("BackpackController")
    local held = getController("HeldToolController")
    if not backpack or not held or not held:IsInputEnabled() then return false end
    local predicted = held:PredictEquipByName(rodId)
    backpack.EquipByName:Fire(rodId, predicted)
    return true
end

local function equipAnyRod()
    local profile = fetchProfile()
    if type(profile) ~= "table" or type(profile.Rods) ~= "table" then return false end
    local best = bestRodId(profile)
    if not best or not hasRodTool(best) then return false end
    return equipRod(best)
end

local function isRodItem(item)
    return string.lower(item.Name):find("rod") ~= nil
end

local function countFishInBackpack()
    local bp = LP:FindFirstChildOfClass("Backpack")
    if not bp then return 0, 0, 0 end
    local total, fish, rods = 0, 0, 0
    for _, item in ipairs(bp:GetChildren()) do
        total = total + 1
        if isRodItem(item) then
            rods = rods + 1
        else
            fish = fish + 1
        end
    end
    return fish, total, rods
end

local function isSatchelFull()
    local fish = countFishInBackpack()
    return fish >= FISH_CAPACITY
end

local SKILL_SLOTS = 4
local SlotPhase = {}
local SkillCycle = {index = 1}

local function markSlotCasting(slotName, skillId)
    local entry = SlotPhase[slotName]
    if type(entry) ~= "table" then return end
    entry.phase = "Casting"
    entry.remaining = 0
    local skill = skillId and Catalog and Catalog.Skill and Catalog.Skill.GetById and Catalog.Skill.GetById(skillId)
    entry.localReadyAt = os.clock() + (skill and (skill.cooldown or 0) or 0)
end

local function slotReady(slotName)
    local entry = SlotPhase[slotName]
    if type(entry) ~= "table" then return true end
    if entry.phase == "Ready" then return true end
    if entry.localReadyAt and os.clock() >= entry.localReadyAt then return true end
    return false
end

local function equippedSkillIds()
    local profile = fetchProfile()
    if not profile then return {} end
    local rodId = profile.RodEquip
    local entry = rodId and profile.Rods and profile.Rods[rodId]
    local slots = entry and entry.BookSlots
    local out = {}
    if type(slots) ~= "table" then return out end
    for i = 1, SKILL_SLOTS do
        local sid = slots["Slot"..i]
        if type(sid) == "string" and sid ~= "" then out[i] = sid end
    end
    return out
end

local function useSkill(idx)
    local kb = getController("KeybindsController")
    local bind = kb and kb.Keys and kb.Keys["Slot"..idx]
    local cb = bind and bind.callback
    if type(cb) ~= "function" then return false end
    cb(false)
    markSlotCasting("Slot"..idx, equippedSkillIds()[idx])
    return true
end

local function castSkill()
    local ids = equippedSkillIds()
    local order = st.skillOrder
    if type(order) ~= "table" or #order == 0 then
        order = {1,2,3,4}
    end
    local total = #order
    for attempt = 1, total do
        local slot = order[SkillCycle.index]
        SkillCycle.index = SkillCycle.index + 1
        if SkillCycle.index > total then
            SkillCycle.index = 1
        end
        if slot and ids[slot] and slotReady("Slot"..slot) then
            if useSkill(slot) then return true end
        end
    end
    return false
end

local function saveState()
    local c = LP.Character
    if not c then return nil end
    local h = c:FindFirstChild("HumanoidRootPart")
    local hu = c:FindFirstChildOfClass("Humanoid")
    if not h or not hu then return nil end
    local s = {cframe=h.CFrame,vel=h.AssemblyLinearVelocity,ang=h.AssemblyAngularVelocity,rv=h.RotVelocity,ar=hu.AutoRotate,ps=hu.PlatformStand,ws=hu.WalkSpeed,jp=hu.JumpPower,hs=hu:GetState(),cc={}}
    for _, name in ipairs(MAIN_PARTS) do
        local p = c:FindFirstChild(name)
        if p and p:IsA("BasePart") then
            s.cc[p] = p.CanCollide
        end
    end
    return s
end

local function hardRestore(savedCharacter, saved)
    local cur = LP.Character
    if cur then
        if saved and saved.cc then
            for p, cc in pairs(saved.cc) do
                if p and p.Parent then
                    pcall(function() p.CanCollide = cc end)
                end
            end
        end
        local curHu = cur:FindFirstChildOfClass("Humanoid")
        if curHu then
            if saved then
                curHu.AutoRotate = saved.ar
                curHu.PlatformStand = saved.ps
                curHu.WalkSpeed = saved.ws
                curHu.JumpPower = saved.jp
                pcall(function() curHu:ChangeState(saved.hs) end)
            else
                curHu.AutoRotate = true
                curHu.PlatformStand = false
                curHu.WalkSpeed = 16
                curHu.JumpPower = 50
            end
        end
    end
end

local function tweenTo(cf, spd)
    spd = spd or 40
    if Tweening then
        local timeout = tick() + 15
        while Tweening and tick() < timeout do task.wait(0.05) end
        if Tweening then Tweening = false end
    end
    Tweening = true
    local ok, err = pcall(function()
        local c = LP.Character
        if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart")
        local hu = c:FindFirstChildOfClass("Humanoid")
        if not h or not hu then return end
        local savedCharacter = c
        local saved = saveState()
        hu.AutoRotate = false
        hu.PlatformStand = true
        hu:ChangeState(Enum.HumanoidStateType.Physics)
        local sCF = h.CFrame
        local sR = sCF - sCF.Position
        local sP = sCF.Position
        local tP = cf.Position
        local dist = (tP - sP).Magnitude
        if dist < 1 then
            h.CFrame = CFrame.new(tP) * sR
            hardRestore(savedCharacter, saved)
            return
        end
        local nc = RunService.Stepped:Connect(function()
            local cur = LP.Character
            if cur and cur == savedCharacter then
                for _, name in ipairs(MAIN_PARTS) do
                    local p = cur:FindFirstChild(name)
                    if p and p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
        local dur = dist / spd
        local stk = tick()
        while tick() - stk < dur do
            local c2 = LP.Character
            if not c2 or c2 ~= savedCharacter then break end
            local h2 = c2:FindFirstChild("HumanoidRootPart")
            if not h2 then break end
            local a = math.clamp((tick() - stk) / dur, 0, 1)
            h2.CFrame = CFrame.new(sP:Lerp(tP, a)) * sR
            h2.AssemblyLinearVelocity = Vector3.zero
            h2.AssemblyAngularVelocity = Vector3.zero
            h2.RotVelocity = Vector3.zero
            task.wait(0.03)
        end
        if nc then nc:Disconnect() nc = nil end
        local c3 = LP.Character
        if c3 and c3 == savedCharacter then
            local h3 = c3:FindFirstChild("HumanoidRootPart")
            if h3 then h3.CFrame = CFrame.new(tP) * sR end
        end
        hardRestore(savedCharacter, saved)
        task.wait(0.05)
        hardRestore(savedCharacter, saved)
        task.wait(0.15)
        hardRestore(savedCharacter, saved)
    end)
    Tweening = false
end

local function dismissLootPopup()
    local f = getController("FishingController")
    if f then
        local ok = pcall(function()
            if type(f.DismissLoot) == "function" then f:DismissLoot() return true end
            if type(f.SkipLoot) == "function" then f:SkipLoot() return true end
            if type(f.CloseLoot) == "function" then f:CloseLoot() return true end
        end)
        if ok then return true end
    end
    local keywords = {"skip", "continue", "close", "dismiss", "confirm", "ok", "next"}
    local found = false
    for _, g in ipairs(PG:GetChildren()) do
        if g:IsA("ScreenGui") and g.Enabled then
            for _, d in ipairs(g:GetDescendants()) do
                if d:IsA("TextButton") or d:IsA("ImageButton") then
                    local n = string.lower(d.Name)
                    for _, kw in ipairs(keywords) do
                        if n:find(kw) then
                            pcall(function()
                                for _, conn in ipairs(getconnections(d.Activated) or {}) do conn:Fire() end
                                for _, conn in ipairs(getconnections(d.MouseButton1Click) or {}) do conn:Fire() end
                            end)
                            found = true
                            break
                        end
                    end
                end
                if found then break end
            end
        end
        if found then break end
    end
    return found
end

local function walkTo(goal, stopAt, timeout, alive)
    local c = LP.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    local r = c and c:FindFirstChild("HumanoidRootPart")
    if not (h and r) or h.Health <= 0 then return false end
    if alive and not alive() then return false end
    local deadline = os.clock() + (timeout or 25)
    local waypoints = {{Position = goal}}
    pcall(function()
        local path = Pathfinding:CreatePath({AgentCanJump=true, WaypointSpacing=6})
        path:ComputeAsync(r.Position, goal)
        if path.Status == Enum.PathStatus.Success then
            local pts = path:GetWaypoints()
            if #pts > 0 then waypoints = pts end
        end
    end)
    local wi = 1
    local lastPos = r.Position
    local still = 0
    h:MoveTo(waypoints[wi].Position)
    while os.clock() < deadline do
        task.wait(0.1)
        local live = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not live or LP.Character ~= c or h.Health <= 0 or (alive and not alive()) then break end
        if (live.Position - goal).Magnitude <= (stopAt or 2) then
            h:MoveTo(live.Position)
            return true
        end
        if wi < #waypoints and (live.Position - waypoints[wi].Position).Magnitude <= 3 then
            wi += 1
            h:MoveTo(waypoints[wi].Position)
        end
        if (live.Position - lastPos).Magnitude < 0.3 then
            still += 0.1
        else
            still = 0
            lastPos = live.Position
        end
        if still >= 0.8 then
            still = 0
            h:MoveTo(waypoints[wi].Position)
        end
    end
    if h.Parent then h:MoveTo(r.Position) end
    return false
end

local function vis(i)
    if not i.Visible or i.AbsoluteSize.X<=0 or i.AbsoluteSize.Y<=0 then return false end
    local p = i.Parent
    while p and p~=game do
        if p:IsA("ScreenGui") and not p.Enabled then return false end
        if p:IsA("GuiObject") and (not p.Visible or p.AbsoluteSize.X<=0 or p.AbsoluteSize.Y<=0) then return false end
        if p:IsA("CanvasGroup") and p.GroupTransparency>=1 then return false end
        p = p.Parent
    end
    return true
end

local function sKey(k)
    pcall(function()
        VIM:SendKeyEvent(true, k, false, game)
        task.wait(0.05)
        VIM:SendKeyEvent(false, k, false, game)
    end)
end

local function scanMini()
    local tg
    for _, g in ipairs(PG:GetChildren()) do
        if g:IsA("ScreenGui") and g.Name=="ReelCounterGui" then tg=g break end
    end
    if not tg then return end
    local f = {L=false,R=false,U=false}
    pcall(function()
        for _, d in ipairs(tg:GetDescendants()) do
            if d:IsA("GuiObject") and vis(d) then
                if d.Name=="Left" then f.L=true
                elseif d.Name=="Right" then f.R=true
                elseif d.Name=="Up" then f.U=true end
            end
        end
    end)
    local n = tick()
    if f.L then if not uiS.L then uiS.L=n end if n-uiS.L>=st.qteDelay then sKey(Enum.KeyCode.A) uiS.L=nil end else uiS.L=nil end
    if f.R then if not uiS.R then uiS.R=n end if n-uiS.R>=st.qteDelay then sKey(Enum.KeyCode.D) uiS.R=nil end else uiS.R=nil end
    if f.U then if not uiS.U then uiS.U=n end if n-uiS.U>=st.qteDelay then sKey(Enum.KeyCode.W) uiS.U=nil end else uiS.U=nil end
end

local function lastHandler(sig)
    local fn
    if not getconnections then return nil end
    for _, c in ipairs(getconnections(sig)) do fn = c.Function end
    return fn
end

local function press(action)
    local fn = action and lastHandler(action.Pressed)
    if fn then fn() end
end

local function release(action)
    local fn = action and lastHandler(action.Released)
    if fn then fn() end
end

local function tap(action, hold)
    press(action)
    task.wait(hold or st.tapHold)
    release(action)
end

local function findNPC()
    local c = LP.Character
    if not c or not c:FindFirstChild("HumanoidRootPart") then return nil end
    local mp = c.HumanoidRootPart.Position
    local best, bd = nil, math.huge
    for _, o in ipairs(workspace:GetDescendants()) do
        local lower = string.lower(o.Name)
        if lower:find("fish_seller") or lower:find("fishmerchant") or lower:find("npcfishseller") or lower:find("nana") or lower:find("seller") then
            local p
            if o:IsA("Model") then p = o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart")
            elseif o:IsA("BasePart") then p = o end
            if p and o:FindFirstChildWhichIsA("ProximityPrompt", true) then
                local d = (mp - p.Position).Magnitude
                if d < bd then bd = d best = p end
            end
        end
    end
    return best
end

local function sellAll()
    local sell = getController("SellController")
    if not sell then return false, 0, 0 end
    local ok, status, coin, count = pcall(function() return sell:SellAll() end)
    if not ok then return false, 0, 0 end
    return true, coin or 0, count or 0
end

local function doSellFull()
    if SellBusy then return false end
    SellBusy = true
    local wasFarming = Fish.farm
    if wasFarming then Fish.paused = true end
    task.wait(0.8)
    local c = LP.Character
    if not c or not c:FindFirstChild("HumanoidRootPart") then
        SellBusy = false
        if wasFarming then Fish.paused = false end
        return false
    end
    local oldCF = c.HumanoidRootPart.CFrame
    local npc = findNPC()
    for _ = 1, 15 do
        if npc then break end
        task.wait(0.3)
        npc = findNPC()
    end
    if not npc then
        WindUI:Notify({Title="Sell Fish", Content="No fish seller found", Duration=3})
        SellBusy = false
        if wasFarming then Fish.paused = false end
        return false
    end
    Tweening = false
    task.wait(0.1)
    local standPos = npc.Position + Vector3.new(0, 3, 5)
    local mode = st.sellTravelMode or "Tween"
    if mode == "Walk" then walkTo(standPos, 3, 30, function() return true end)
    elseif mode == "Instant" then
        local root = c and c:FindFirstChild("HumanoidRootPart")
        if root then root.CFrame = CFrame.new(standPos) task.wait(0.4) end
    else tweenTo(CFrame.new(standPos)) end
    local waitDeadline = tick() + 12
    while Tweening and tick() < waitDeadline do task.wait(0.05) end
    task.wait(0.6)
    local ok, coin, count = sellAll()
    if not ok then
        local pkt = RS:FindFirstChild("Stardust") and RS.Stardust:FindFirstChild("Packages") and RS.Stardust.Packages:FindFirstChild("Packet") and RS.Stardust.Packages.Packet:FindFirstChild("RemoteEvent")
        if pkt and type(buffer)=="table" then
            local cnt = 0
            local function sp(op, pl)
                cnt = (cnt+1)%256
                local b = buffer.create(2+(pl and #pl or 0))
                buffer.writeu8(b, 0, string.byte(op))
                buffer.writeu8(b, 1, cnt)
                if pl then for i=1,#pl do buffer.writeu8(b, 1+i, pl[i]) end end
                pcall(function() pkt:FireServer(b) end)
            end
            sp("c",{0x41}) task.wait(0.2)
            sp("c",{0x42,0x01}) task.wait(0.2)
            sp("c",{0x43}) task.wait(0.2)
            sp("f",{0x4A}) task.wait(0.2)
            sp("c",{0x4B}) task.wait(0.2)
            sp("\\",{0x4C}) task.wait(0.2)
            sp("c",{0x4D,0x01}) task.wait(0.2)
            sp("c",{0x4E}) task.wait(0.5)
        end
    end
    if st.returnAfterSell then
        local c2 = LP.Character
        if c2 and c2:FindFirstChild("HumanoidRootPart") then
            Tweening = false
            task.wait(0.1)
            if mode == "Walk" then walkTo(oldCF.Position, 3, 30, function() return true end)
            elseif mode == "Instant" then
                local root2 = c2:FindFirstChild("HumanoidRootPart")
                if root2 then root2.CFrame = oldCF task.wait(0.4) end
            else
                tweenTo(oldCF)
                local waitBack = tick() + 12
                while Tweening and tick() < waitBack do task.wait(0.05) end
            end
        end
    end
    task.wait(0.3)
    if wasFarming then Fish.paused = false end
    WindUI:Notify({Title="Sell Fish", Content= ok and ("Sold! +"..tostring(coin)) or "Sold!", Duration=2})
    SellBusy = false
    return true
end

local function startSell()
    task.spawn(function()
        while st.sell do
            for i=sellInt,1,-1 do if not st.sell then break end task.wait(1) end
            if not st.sell then break end
            doSellFull()
            task.wait(1)
        end
    end)
end

local autoFullTask = nil
local function startAutoFull()
    if autoFullTask then return end
    autoFullTask = task.spawn(function()
        while st.autoSellFull do
            task.wait(2)
            if not st.autoSellFull then break end
            if SellBusy then continue end
            local fish = countFishInBackpack()
            if fish >= FISH_CAPACITY then
                WindUI:Notify({Title="Sell Fish", Content=("Bag full (%d/%d)"):format(fish, FISH_CAPACITY), Duration=2})
                doSellFull()
                task.wait(3)
            end
        end
        autoFullTask = nil
    end)
end

local function applySpeed(v)
    st.speed = v
    local c = LP.Character
    if st.speedOn and c then
        local hu = c:FindFirstChildOfClass("Humanoid")
        if hu and hu.Health > 0 then hu.WalkSpeed = v end
    end
end

local function enableSpeed(on)
    st.speedOn = on
    local c = LP.Character
    if c then
        local hu = c:FindFirstChildOfClass("Humanoid")
        if hu and hu.Health > 0 then hu.WalkSpeed = on and st.speed or 16 end
    end
end

local function runFishLoop()
    Fish.running = true
    Fish.dead = false
    while not Fish.dead do
        if not Fish.farm then task.wait(0.2) continue end
        if Fish.paused then task.wait(0.1) continue end
        if Tweening then task.wait(0.1) continue end
        if SellBusy then task.wait(0.1) continue end
        if not LP.Character then task.wait(0.2) continue end
        if not heldRodId() and os.clock() - Fish.lastEquip >= st.equipDelay then
            Fish.lastEquip = os.clock()
            if equipAnyRod() then task.wait(st.equipDelay) end
        end
        local f = getController("FishingController")
        if not f then task.wait(0.25) continue end
        local ok, state = pcall(function() return f:GetState() end)
        if not ok then task.wait(0.1) continue end
        if state ~= Fish.lastState then
            if state == "FirstPull" then Fish.firstPullDone = false
            elseif state == "Caught" then
                task.spawn(function()
                    task.wait(0.15)
                    for i = 1, 5 do
                        if not Fish.farm then break end
                        local done = dismissLootPopup()
                        if done then break end
                        task.wait(0.3)
                    end
                end)
            end
            Fish.lastState = state
        end
        if state == "Idling" then
            if os.clock() - Fish.lastCast >= 0.7 then
                Fish.lastCast = os.clock()
                local ctx = RS:FindFirstChild("Inputs")
                local fc = ctx and ctx:FindFirstChild("FishingContext")
                local action = fc and fc:FindFirstChild("FishingPrimary")
                if action then tap(action, st.castHold) end
            else task.wait(0.05) end
        elseif state == "FirstPull" then
            local okV, value = pcall(function() return f:GetPullBarValue() end)
            if okV and not Fish.firstPullDone and value >= st.firstPullTarget then
                Fish.firstPullDone = true
                local ctx = RS:FindFirstChild("Inputs")
                local fc = ctx and ctx:FindFirstChild("FishingContext")
                local action = fc and fc:FindFirstChild("FishingPrimary")
                if action then tap(action, st.tapHold) end
            else task.wait() end
        elseif state == "Reeling" then
            if st.skill and os.clock() - Fish.lastSkill >= st.skillSpacing and LP:GetAttribute("IsUsingSkill") ~= true then
                if castSkill() then Fish.lastSkill = os.clock() end
            end
            local okAuto, isAuto = pcall(function() return f:IsAutoSession() end)
            if okAuto and isAuto then task.wait(0.05)
            else
                local ctx = RS:FindFirstChild("Inputs")
                local fc = ctx and ctx:FindFirstChild("FishingContext")
                local action = fc and fc:FindFirstChild("FishingPrimary")
                if action then tap(action, st.tapHold) end
            end
        else task.wait(0.05) end
    end
    Fish.running = false
end

local minigameTask
local function startFish()
    Fish.farm = true
    Fish.paused = false
    if not Fish.running then task.spawn(runFishLoop) end
    if not minigameTask then
        minigameTask = task.spawn(function()
            while st.bypass or st.fish do
                scanMini()
                task.wait(0.05)
            end
            minigameTask = nil
        end)
    end
end

local function stopFish()
    Fish.farm = false
    Fish.paused = false
end

local LockState = {sent={}, busy=false, at=0}

local function getRarityList()
    local rarities = {}
    local seen = {}
    pcall(function()
        if Catalog and Catalog.Fish and Catalog.Fish.GetAll then
            for _, e in pairs(Catalog.Fish.GetAll()) do
                if type(e) == "table" and type(e.rarity) == "string" then
                    if not seen[e.rarity] then
                        seen[e.rarity] = true
                        table.insert(rarities, e.rarity)
                    end
                end
            end
        end
    end)
    if #rarities == 0 then
        rarities = {"Common","Uncommon","Rare","Epic","Legendary","Mythical","Divine","Huge"}
    end
    table.sort(rarities, function(a,b)
        return (RarityPriority[a] or 99) < (RarityPriority[b] or 99)
    end)
    return rarities
end

local function autoLockPass()
    if LockState.busy then return end
    LockState.busy = true
    task.spawn(function()
        local profile = fetchProfile()
        local fishes = profile and profile.Inventory and profile.Inventory.Fishes
        if type(fishes) ~= "table" then LockState.busy=false return end
        local sell = getController("SellController")
        if not sell then LockState.busy=false return end
        local wantRarity = {}
        local hasAny = false
        if type(st.lockRarity) == "table" then
            for r, v in pairs(st.lockRarity) do
                if v == true then
                    wantRarity[r] = true
                    hasAny = true
                end
            end
        end
        if not hasAny then LockState.busy=false return end
        local rarityOf = {}
        pcall(function()
            if Catalog and Catalog.Fish and Catalog.Fish.GetAll then
                for _, e in pairs(Catalog.Fish.GetAll()) do
                    if type(e)=="table" then rarityOf[e.id or e.Id] = e.rarity end
                end
            end
        end)
        local queue = {}
        local now = os.clock()
        for uid, fish in pairs(fishes) do
            if type(fish)=="table" and fish.locked ~= true then
                local r = fish.rarity or rarityOf[fish.fishId]
                if r and wantRarity[r] then
                    if not LockState.sent[uid] or now - LockState.sent[uid] > 20 then
                        table.insert(queue, uid)
                    end
                end
            end
        end
        for i = 1, math.min(#queue, 12) do
            local uid = queue[i]
            LockState.sent[uid] = now
            pcall(function() sell:ToggleLock(uid) end)
            task.wait(0.15)
        end
        LockState.busy = false
        LockState.at = os.clock()
    end)
end

local LiteBackup = nil

local function setLite(want)
    local L = Lighting
    if want then
        if not LiteBackup then
            LiteBackup = {effects={},shadows=L.GlobalShadows,diffuse=L.EnvironmentDiffuseScale,specular=L.EnvironmentSpecularScale,atmos={},clouds={}}
            for _, e in ipairs(L:GetChildren()) do
                if e:IsA("PostEffect") then LiteBackup.effects[e.Name] = e.Enabled end
                if e:IsA("Atmosphere") then LiteBackup.atmos = {density=e.Density,offset=e.Offset,haze=e.Haze,glare=e.Glare} end
                if e:IsA("Clouds") then LiteBackup.clouds = {cover=e.Cover,density=e.Density} end
            end
        end
        pcall(function()
            L.GlobalShadows=false
            L.EnvironmentDiffuseScale=0
            L.EnvironmentSpecularScale=0
        end)
        for _, e in ipairs(L:GetChildren()) do
            if e:IsA("PostEffect") then pcall(function() e.Enabled=false end)
            elseif e:IsA("Atmosphere") then pcall(function() e.Density=0 e.Offset=0 e.Haze=0 e.Glare=0 end)
            elseif e:IsA("Clouds") then pcall(function() e.Cover=0 e.Density=0 end) end
        end
        task.spawn(function()
            for _, inst in ipairs(workspace:GetDescendants()) do
                pcall(function()
                    if inst:IsA("ParticleEmitter") then inst.Enabled=false inst.Rate=0
                    elseif inst:IsA("Beam") or inst:IsA("Trail") then inst.Enabled=false
                    elseif inst:IsA("PointLight") or inst:IsA("SurfaceLight") or inst:IsA("SpotLight") then inst.Enabled=false
                    elseif inst:IsA("Highlight") and inst.Name ~= "DNHubBossEsp" and inst.Name ~= "DNHubNameTag" then inst.Enabled=false
                    elseif inst:IsA("Fire") or inst:IsA("Smoke") or inst:IsA("Sparkles") then inst.Enabled=false end
                end)
                task.wait()
            end
        end)
        st.liteGfx = true
    else
        if LiteBackup then
            pcall(function()
                L.GlobalShadows = LiteBackup.shadows
                L.EnvironmentDiffuseScale = LiteBackup.diffuse
                L.EnvironmentSpecularScale = LiteBackup.specular
            end)
            for _, e in ipairs(L:GetChildren()) do
                if e:IsA("PostEffect") and LiteBackup.effects[e.Name] ~= nil then
                    pcall(function() e.Enabled = LiteBackup.effects[e.Name] end)
                elseif e:IsA("Atmosphere") and next(LiteBackup.atmos) then
                    pcall(function()
                        e.Density = LiteBackup.atmos.density
                        e.Offset = LiteBackup.atmos.offset
                        e.Haze = LiteBackup.atmos.haze
                        e.Glare = LiteBackup.atmos.glare
                    end)
                elseif e:IsA("Clouds") and next(LiteBackup.clouds) then
                    pcall(function()
                        e.Cover = LiteBackup.clouds.cover
                        e.Density = LiteBackup.clouds.density
                    end)
                end
            end
            LiteBackup = nil
        end
        st.liteGfx = false
    end
end

local function findIsland(n)
    local t = "island_"..n
    for _, o in ipairs(workspace:GetDescendants()) do if o.Name:lower()==t then return o end end
end

local function findSpawn(i)
    if not i then return nil end
    for _, d in ipairs(i:GetDescendants()) do if d:IsA("SpawnLocation") then return d end end
    for _, d in ipairs(i:GetDescendants()) do if d:IsA("BasePart") and d.Name:lower():find("spawn") then return d end end
    if i:IsA("Model") and i.PrimaryPart then return i.PrimaryPart end
    for _, d in ipairs(i:GetChildren()) do if d:IsA("BasePart") then return d end end
end

local function teleIsland(n)
    local i = findIsland(n)
    if not i then WindUI:Notify({Title="Teleport", Content="Not found: "..n, Duration=3}) return end
    local sp = findSpawn(i)
    if not sp then WindUI:Notify({Title="Teleport", Content="No spawn", Duration=3}) return end
    tweenTo(CFrame.new(sp.Position + Vector3.new(0,5,0)))
    task.wait(0.3)
end

local espF, espC
local function clearESP()
    if espF then pcall(function() espF:Destroy() end) espF=nil end
    if espC then pcall(function() espC:Disconnect() end) espC=nil end
end

local function startESP()
    clearESP()
    espF = Instance.new("Folder") espF.Name="DNHub_ESP" espF.Parent=workspace
    for _, name in ipairs(ISLAND_ORDER) do
        local isl = findIsland(name)
        if isl then
            local part = findSpawn(isl)
            if part then
                local lb = Instance.new("BillboardGui")
                lb.Size = UDim2.new(0,200,0,40)
                lb.StudsOffset = Vector3.new(0,20,0)
                lb.AlwaysOnTop = true
                lb.Adornee = part
                lb.Parent = espF
                local tx = Instance.new("TextLabel")
                tx.Size = UDim2.new(1,0,1,0)
                tx.BackgroundTransparency = 1
                tx.Text = ISLAND_LABELS[name] or isl.Name
                tx.TextColor3 = Color3.fromRGB(255,255,255)
                tx.TextStrokeColor3 = Color3.fromRGB(0,0,0)
                tx.TextStrokeTransparency = 0
                tx.TextSize = 18
                tx.Font = Enum.Font.GothamBold
                tx.Parent = lb
            end
        end
    end
end

local function stopESP() clearESP() end

local BossEspActive = nil
local ActiveBoss = {part=nil, id=nil, meta=nil}

local function bossFxActive(region)
    local fx = region and region:FindFirstChild("BossSpawnerFX")
    return fx ~= nil and fx:GetAttribute("BossSpawnerFXActive")==true
end

local function bossRegionMeta(id)
    if not (Catalog and Catalog.BossRegion and Catalog.BossRegion.GetById) then return nil end
    local ok, entry = pcall(function() return Catalog.BossRegion.GetById(id) end)
    if not ok or type(entry) ~= "table" then return nil end
    local slot = tonumber(id:match("_(%d+)$")) or 1
    return {id = id, name = tostring(entry.name or id), islandId = entry.fallbackIslandId, slot = slot}
end

local function clearBossEsp()
    if BossEspActive and BossEspActive.gui then
        pcall(function() BossEspActive.gui:Destroy() end)
    end
    BossEspActive = nil
end

local function findActiveBossRegion()
    for _, inst in ipairs(Collection:GetTagged("BossRegion")) do
        if inst:IsA("BasePart") and inst:IsDescendantOf(workspace) then
            if bossFxActive(inst) then
                local id = inst:GetAttribute("bossRegionId")
                if type(id) == "string" then return inst, id end
            end
        end
    end
    return nil, nil
end

local function bossEsp()
    if not (st.bossEsp1 or st.bossEsp2 or st.autoBoss) then
        clearBossEsp()
        ActiveBoss.part = nil
        ActiveBoss.id = nil
        ActiveBoss.meta = nil
        return
    end
    local part, id = findActiveBossRegion()
    if not part or not id then
        clearBossEsp()
        ActiveBoss.part = nil
        ActiveBoss.id = nil
        ActiveBoss.meta = nil
        return
    end
    local meta = bossRegionMeta(id)
    if not meta then
        clearBossEsp()
        ActiveBoss.part = nil
        ActiveBoss.id = nil
        ActiveBoss.meta = nil
        return
    end
    local want = (meta.slot == 1 and st.bossEsp1) or (meta.slot == 2 and st.bossEsp2) or st.autoBoss
    if not want then
        clearBossEsp()
        ActiveBoss.part = nil
        ActiveBoss.id = nil
        ActiveBoss.meta = nil
        return
    end
    ActiveBoss.part = part
    ActiveBoss.id = id
    ActiveBoss.meta = meta
    if BossEspActive and BossEspActive.id ~= id then clearBossEsp() end
    if not BossEspActive or not BossEspActive.gui or not BossEspActive.gui.Parent then
        local gui = Instance.new("BillboardGui")
        gui.Name = "DNHubBossEsp"
        gui.Adornee = part
        gui.AlwaysOnTop = true
        gui.MaxDistance = 8000
        gui.Size = UDim2.fromOffset(200, 60)
        gui.StudsOffsetWorldSpace = Vector3.new(0, 8, 0)
        gui.Parent = PG
        local box = Instance.new("Frame")
        box.Size = UDim2.fromScale(1, 1)
        box.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
        box.BackgroundTransparency = 0.2
        box.BorderSizePixel = 0
        box.Parent = gui
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)
        local num = Instance.new("TextLabel")
        num.Name = "Number"
        num.Size = UDim2.fromOffset(56, 0)
        num.Position = UDim2.fromOffset(4, 0)
        num.BackgroundTransparency = 1
        num.Font = Enum.Font.GothamBold
        num.TextSize = 38
        num.Text = tostring(meta.slot)
        num.TextColor3 = Color3.fromRGB(255, 95, 95)
        num.Parent = box
        local lbl = Instance.new("TextLabel")
        lbl.Name = "Text"
        lbl.Size = UDim2.new(1, -62, 1, 0)
        lbl.Position = UDim2.fromOffset(60, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextColor3 = Color3.fromRGB(235, 235, 240)
        lbl.TextWrapped = true
        lbl.Text = meta.name .. "\n" .. tostring(meta.islandId or "?")
        lbl.Parent = box
        BossEspActive = {gui = gui, part = part, id = id, num = num, lbl = lbl}
    end
    if BossEspActive.gui.Adornee ~= part then BossEspActive.gui.Adornee = part end
    if BossEspActive.lbl then
        pcall(function()
            BossEspActive.lbl.Text = meta.name .. "\n" .. tostring(meta.islandId or "?")
        end)
    end
end

local function stopBossEsp()
    clearBossEsp()
    ActiveBoss.part = nil
    ActiveBoss.id = nil
    ActiveBoss.meta = nil
end

local function teleToBoss()
    local part = ActiveBoss.part
    if not part or not part.Parent then
        WindUI:Notify({Title="Boss", Content="No active boss", Duration=3})
        return
    end
    WindUI:Notify({Title="Boss", Content="Tweening to boss "..tostring(ActiveBoss.meta and ActiveBoss.meta.name or "?"), Duration=2})
    tweenTo(CFrame.new(part.Position + Vector3.new(0, 8, 0)))
    task.wait(0.3)
end

local BossStepState = {holding=false, engaged=nil, bank=nil, bankFor=nil, bankAt=-math.huge, fails=0, last=nil, at=0, step="Idle"}

local function bossGround(islandId)
    local waterY = 3
    pcall(function()
        if Catalog and Catalog.Island and Catalog.Island.GetWaterY then
            waterY = tonumber(Catalog.Island.GetWaterY(islandId)) or 3
        end
    end)
    local exclude = {}
    for _, plr in ipairs(P:GetPlayers()) do
        if plr.Character then table.insert(exclude, plr.Character) end
    end
    for _, inst in ipairs(Collection:GetTagged("IslandRegion")) do table.insert(exclude, inst) end
    for _, inst in ipairs(Collection:GetTagged("BossRegion")) do table.insert(exclude, inst) end
    local rays = RaycastParams.new()
    rays.FilterType = Enum.RaycastFilterType.Exclude
    rays.FilterDescendantsInstances = exclude
    rays.RespectCanCollide = true
    rays.IgnoreWater = false
    local lift = 3
    pcall(function()
        local humanoid = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.RigType == Enum.HumanoidRigType.R6 then
            local leg = humanoid.Parent and humanoid.Parent:FindFirstChild("Left Leg")
            lift = 3 + ((leg and leg.Size.Y) or 2)
        end
    end)
    local cast = FishingConfig and FishingConfig.Cast or {}
    local minCast = tonumber(cast.BaitMinDist) or 30
    local maxCast = tonumber(cast.BaitMaxDist) or 60
    local server = tonumber(cast.ServerMaxDistance) or 80
    return {rays=rays, waterY=waterY, lift=lift, minCast=minCast, maxCast=math.min(maxCast, server-2)}
end

local function bossDryGround(hit, ctx)
    if not hit or hit.Normal.Y < 0.75 then return false end
    if hit.Instance.Material == Enum.Material.Water then return false end
    if hit.Position.Y <= ctx.waterY + 0.25 then return false end
    if hit.Instance:IsA("Terrain") then return true end
    if hit.Instance:IsA("BasePart") then return hit.Instance.CanCollide and hit.Instance.Anchored end
    return false
end

local function bossSupportAt(point, ctx)
    local hit = workspace:Raycast(point + Vector3.new(0,1,0), Vector3.new(0, -(ctx.lift+2), 0), ctx.rays)
    if not bossDryGround(hit, ctx) then return false end
    return math.abs(point.Y - hit.Position.Y - ctx.lift) <= 1.5
end

local function bossTargetValid(region, waterPoint, ctx)
    if not region.Parent then return false end
    local local3 = region.CFrame:PointToObjectSpace(waterPoint)
    local half = region.Size * 0.5
    if math.abs(local3.X) > half.X - 0.1 then return false end
    if math.abs(local3.Y) > half.Y then return false end
    if math.abs(local3.Z) > half.Z - 0.1 then return false end
    return workspace:Raycast(waterPoint + Vector3.new(0,100,0), Vector3.new(0,-100,0), ctx.rays) == nil
end

local function bossScanBank(region, islandId, alive)
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root or typeof(region) ~= "Instance" then return nil end
    local ctx = bossGround(islandId)
    local half = region.Size * 0.5
    local function scanAlive()
        return LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") == root
            and region:IsDescendantOf(workspace) and alive()
    end
    if not scanAlive() then return nil, true end
    local rays, sliceAt, cancelled = 0, os.clock(), false
    ctx.cast = function(origin, direction)
        if cancelled then return nil end
        if rays >= 48 or os.clock() - sliceAt >= 0.002 then
            task.wait()
            rays, sliceAt = 0, os.clock()
            if not scanAlive() then cancelled = true return nil end
        end
        rays += 1
        return workspace:Raycast(origin, direction, ctx.rays)
    end
    local waters = {}
    local function addWater(x, z)
        if cancelled or #waters >= 40 then return end
        local world = region.CFrame:PointToWorldSpace(Vector3.new(x, 0, z))
        local point = Vector3.new(world.X, ctx.waterY, world.Z)
        if bossTargetValid(region, point, ctx) then table.insert(waters, point) end
    end
    local fx = region:FindFirstChild("BossSpawnerFX")
    if typeof(fx) == "Instance" then
        local local3 = region.CFrame:PointToObjectSpace(fx.Position)
        addWater(math.clamp(local3.X, -half.X+1, half.X-1), math.clamp(local3.Z, -half.Z+1, half.Z-1))
    end
    local spanX = math.max(half.X - 2, 0)
    local spanZ = math.max(half.Z - 2, 0)
    local stepsX = math.clamp(math.ceil(region.Size.X / 22), 2, 12)
    local stepsZ = math.clamp(math.ceil(region.Size.Z / 22), 2, 12)
    for i = 0, stepsX do
        local x = -spanX + 2 * spanX * i / stepsX
        addWater(x, -spanZ) addWater(x, spanZ)
    end
    for i = 1, stepsZ - 1 do
        local z = -spanZ + 2 * spanZ * i / stepsZ
        addWater(-spanX, z) addWater(spanX, z)
    end
    for i = -1, 1, 2 do
        for j = -1, 1, 2 do
            addWater(i * half.X * 0.5, j * half.Z * 0.5)
        end
    end
    if cancelled then return nil, true end
    if #waters == 0 then return nil end
    local ranges = { ctx.minCast + 2, (ctx.minCast + ctx.maxCast) * 0.5, ctx.maxCast - 2 }
    local best, bestScore = nil, math.huge
    for _, water in ipairs(waters) do
        for _, range in ipairs(ranges) do
            for step = 0, 11 do
                if cancelled then return nil, true end
                local angle = step * math.pi / 6
                local hit = ctx.cast(
                    water + Vector3.new(math.cos(angle)*range, 120, math.sin(angle)*range),
                    Vector3.new(0, -124, 0)
                )
                if bossDryGround(hit, ctx) then
                    local stand = hit.Position + Vector3.new(0, ctx.lift + 0.1, 0)
                    local reach = (stand - water).Magnitude
                    if reach >= ctx.minCast and reach <= ctx.maxCast then
                        local solid = true
                        for _, offset in ipairs({Vector3.new(1.2,0,0), Vector3.new(-1.2,0,0), Vector3.new(0,0,1.2), Vector3.new(0,0,-1.2)}) do
                            if not bossSupportAt(stand + offset, ctx) then solid = false break end
                        end
                        if solid and bossSupportAt(stand, ctx) then
                            if ctx.cast(hit.Position + Vector3.new(0,0.3,0), Vector3.new(0,120,0)) == nil then
                                local score = (root.Position - stand).Magnitude + math.abs(reach - ranges[2]) * 2
                                if score < bestScore then
                                    bestScore = score
                                    best = CFrame.lookAt(stand, Vector3.new(water.X, stand.Y, water.Z))
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if cancelled or not scanAlive() then return nil, true end
    return best
end

local function bossStep()
    local store = BossStepState
    if not st.autoBoss then
        if store.holding then
            store.holding = false
            store.engaged = nil
            store.step = "Idle"
            WindUI:Notify({Title="Boss", Content="Auto boss disabled", Duration=3})
        end
        return
    end
    local part = ActiveBoss.part
    if not part or not part.Parent then
        if store.holding then
            store.holding = false
            store.engaged = nil
            store.step = "Idle"
            WindUI:Notify({Title="Boss", Content="Boss gone", Duration=3})
        end
        return
    end
    if not store.holding then
        store.holding = true
        store.engaged = ActiveBoss.id
        store.bank = nil
        store.bankFor = nil
        store.bankAt = -math.huge
        store.fails = 0
        store.step = "Found boss " .. tostring(ActiveBoss.meta and ActiveBoss.meta.name or "?")
        WindUI:Notify({Title="Boss", Content=store.step, Duration=4})
    end
    if store.engaged ~= ActiveBoss.id then
        store.engaged = ActiveBoss.id
        store.bank = nil
        store.bankFor = nil
        store.bankAt = -math.huge
        store.fails = 0
    end
    if not Fish.farm then
        store.step = "Enable Auto Fish"
        return
    end
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then store.step = "No character" return end
    local stale = store.bank == nil or store.bankFor ~= part or os.clock() - store.bankAt >= 20
    if stale then
        store.step = "Scanning dry bank..."
        local found, cancelled = bossScanBank(part, ActiveBoss.meta and ActiveBoss.meta.islandId, function() return st.autoBoss end)
        if cancelled then return end
        if not found then
            store.fails = (store.fails or 0) + 1
            store.step = store.fails >= 3 and "No dry spot" or "No dry spot yet"
            return
        end
        store.fails = 0
        store.bankAt = os.clock()
        store.bank = found
        store.bankFor = part
    end
    local bank = store.bank
    if not bank then return end
    local distance = (root.Position - bank.Position).Magnitude
    if distance > 4 then
        store.step = ("Flying to boss, %d studs"):format(math.floor(distance+0.5))
        tweenTo(bank, 60)
        return
    end
    store.step = "Fighting boss " .. tostring(ActiveBoss.meta and ActiveBoss.meta.name or "?")
    local face = Vector3.new(part.Position.X, root.Position.Y, part.Position.Z)
    pcall(function() root.CFrame = CFrame.lookAt(root.Position, face) end)
end

local function bossInfoText()
    if not (st.bossEsp1 or st.bossEsp2 or st.autoBoss) then return "Boss ESP is off" end
    if not ActiveBoss.part or not ActiveBoss.meta then return "No active boss" end
    local meta = ActiveBoss.meta
    local islandName = ISLAND_LABELS[meta.islandId] or tostring(meta.islandId or "?")
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    local distText = ""
    if root then
        local d = (root.Position - ActiveBoss.part.Position).Magnitude
        distText = "\nDistance: "..math.floor(d).." studs"
    end
    return "Boss: "..meta.name.."\nIsland: "..islandName.."\nPart: "..meta.slot..distText.."\n"..tostring(BossStepState.step or "")
end

local fnR = false
local fnC = {}
local tag = nil
local tagLabel = nil
local tagColorState = {r=st.tagColorR or 0.7, g=st.tagColorG or 0.4, b=st.tagColorB or 1.0, rainbow=st.tagRainbow or false}
local humanoidRef = nil
local lastKillAt = 0
local NAME_HIDE = string.char(226,128,139)

local function hideOriginalNames()
    pcall(function()
        local rn = LP.Name
        local dn = LP.DisplayName
        local function sc(c)
            for _, o in ipairs(c:GetDescendants()) do
                if o:IsA("TextLabel") then
                    if o.Text == rn or o.Text == "@"..rn or o.Text == dn then
                        if not fnC[o] then fnC[o] = {t=o.Text, v=o.Visible, tr=o.TextTransparency} end
                        o.Text = "" o.Visible = false o.TextTransparency = 1
                    end
                end
            end
        end
        sc(workspace)
        for _, g in ipairs(PG:GetChildren()) do
            if g:IsA("ScreenGui") then sc(g) end
        end
    end)
end

local function restoreOriginalNames()
    for o, d in pairs(fnC) do
        pcall(function()
            if o and o.Parent then
                o.Text = d.t
                o.Visible = d.v
                o.TextTransparency = d.tr
            end
        end)
    end
    fnC = {}
end

local function createCustomTag()
    local ch = LP.Character
    if not ch then return end
    local head = ch:FindFirstChild("Head") or ch:FindFirstChild("HumanoidRootPart")
    if not head then return end
    local stale = head:FindFirstChild("DNHubNameTag")
    if stale then pcall(function() stale:Destroy() end) end
    local tx = tostring(customName ~= "" and customName or LP.DisplayName)
    local bb = Instance.new("BillboardGui")
    bb.Name = "DNHubNameTag"
    bb.Size = UDim2.fromOffset(130, 18)
    bb.StudsOffset = Vector3.new(0, 2.2, 0)
    bb.AlwaysOnTop = true
    bb.MaxDistance = 150
    bb.LightInfluence = 0
    bb.Adornee = head
    bb.Parent = head
    local lb = Instance.new("TextLabel")
    lb.Name = "Label"
    lb.Size = UDim2.new(1, 0, 1, 0)
    lb.BackgroundTransparency = 1
    lb.Text = tx
    lb.TextColor3 = Color3.new(tagColorState.r, tagColorState.g, tagColorState.b)
    lb.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    lb.TextStrokeTransparency = 0.3
    lb.TextScaled = true
    lb.Font = Enum.Font.GothamBold
    lb.RichText = false
    lb.Parent = bb
    tag = bb
    tagLabel = lb
    local hum = ch:FindFirstChildOfClass("Humanoid")
    if hum then
        humanoidRef = hum
        pcall(function() hum.DisplayName = NAME_HIDE end)
    end
end

local function killGameTag()
    local now = os.clock()
    if now - lastKillAt < 0.5 then return end
    lastKillAt = now
    local folder = workspace:FindFirstChild("Nametags")
    if not folder then return end
    local own = folder:FindFirstChild(LP.Name)
    if own then pcall(function() own:Destroy() end) end
end

local function applyTagColor()
    if not tagLabel or not tagLabel.Parent then return end
    if tagColorState.rainbow then
        local color = Color3.fromHSV((os.clock() % 12) / 12, 0.85, 1)
        pcall(function() tagLabel.TextColor3 = color end)
    else
        pcall(function() tagLabel.TextColor3 = Color3.new(tagColorState.r, tagColorState.g, tagColorState.b) end)
    end
end

local function refreshName()
    hideOriginalNames()
    if not tag or not tag.Parent or not tagLabel or not tagLabel.Parent then createCustomTag() end
    local text = tostring(customName ~= "" and customName or LP.DisplayName)
    if tagLabel and tagLabel.Parent then
        if tagLabel.Text ~= text then pcall(function() tagLabel.Text = text end) end
        applyTagColor()
    end
    local hum = humanoidRef
    if hum and hum.Parent and hum.DisplayName ~= NAME_HIDE then
        pcall(function() hum.DisplayName = NAME_HIDE end)
    end
    killGameTag()
end

local function startFake()
    if fnR then return end
    fnR = true
    task.spawn(function()
        hideOriginalNames()
        createCustomTag()
        while st.fakename do
            pcall(refreshName)
            task.wait(0.15)
        end
        fnR = false
    end)
end

local function stopFake()
    restoreOriginalNames()
    if tag then pcall(function() tag:Destroy() end) end
    tag = nil
    tagLabel = nil
    humanoidRef = nil
    if LP.Character then
        local hum = LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum.DisplayName = LP.DisplayName end) end
    end
end

local function setTagColor(r, g, b)
    tagColorState.r = r
    tagColorState.g = g
    tagColorState.b = b
    tagColorState.rainbow = false
    st.tagColorR = r st.tagColorG = g st.tagColorB = b st.tagRainbow = false
    applyTagColor()
end

local function setTagRainbow(on)
    tagColorState.rainbow = on
    st.tagRainbow = on
end

local function updateTagText()
    if tagLabel then
        pcall(function()
            tagLabel.Text = tostring(customName ~= "" and customName or LP.DisplayName)
        end)
    end
end

local antiAfkTask = nil
local function antiAfkTick()
    if not st.antiAfk then return end
    local ok, focused = pcall(function() return game:GetService("UserInputService"):GetFocusedTextBox() end)
    if ok and focused then return end
    local pressed = pcall(function()
        VU:CaptureController()
        VU:ClickButton2(Vector2.new(0,0))
    end)
    if not pressed then
        pcall(function()
            local key = st.antiAfkKey or "F13"
            local code = Enum.KeyCode[key] or Enum.KeyCode.F13
            VIM:SendKeyEvent(true, code, false, game)
            task.wait(0.05)
            VIM:SendKeyEvent(false, code, false, game)
        end)
    end
end

local function startAntiAfk()
    if antiAfkTask then return end
    antiAfkTask = task.spawn(function()
        while st.antiAfk do
            task.wait(math.max(10, st.antiAfkInterval or 50))
            if not st.antiAfk then break end
            pcall(antiAfkTick)
        end
        antiAfkTask = nil
    end)
end

local function applyAccent(library, value)
    if type(library) ~= "table" then return false end
    local color
    if typeof(value) == "Color3" then color = value
    elseif type(value) == "string" then
        local ok, c = pcall(function() return Color3.fromHex(value) end)
        if ok and typeof(c) == "Color3" then color = c end
    end
    if not color then return false end
    local base = st.uiTheme or "Dark"
    local themes = type(library.GetThemes) == "function" and library:GetThemes() or nil
    if type(themes) ~= "table" or type(themes[base]) ~= "table" then base = "Dark" end
    local ok = pcall(function()
        local custom = {}
        for key, entry in pairs(themes[base] or {}) do custom[key] = entry end
        custom.Name = "DNHubAccent"
        for _, key in ipairs({"Accent","Primary","Slider","Toggle","Checkbox"}) do
            custom[key] = color
        end
        library:AddTheme(custom)
    end)
    if not ok then return false end
    pcall(function() library:SetTheme("DNHubAccent") end)
    return true
end

-- ============== NEW FEATURES FROM FISHINGMASTER ==============

-- 1. AUTO ROLL GACHA
local RollTask = nil
local RollNames = {"Skill Master", "Ocean Chest", "Dragon Chest", "Aura"}
local RollNPC = {
    ["Skill Master"] = "npc_gacha_book",
    ["Ocean Chest"] = "crate_ocean_chest",
    ["Dragon Chest"] = "crate_dragon_chest",
    ["Aura"] = "npc_gacha_aura",
}

local function doRollPass()
    local gk = st.rollType
    local k = st.rollMulti == "x10" and 10 or 1
    local ctrl = getController("SkillGachaController")
    if not ctrl then return false end
    local crName = gk == "Ocean Chest" and "crate_ocean_chest" or gk == "Dragon Chest" and "crate_dragon_chest"
    local auraPull = gk == "Aura"
    local profile = fetchProfile()
    if not profile then return false end
    if crName then
        local CrateGacha = getController("CrateGachaController")
        if CrateGacha then
            local r = CrateGacha.OpenPacket:Fire(crName, k)
            if type(r) == "table" and r.ok then
                local names = {}
                for _, x in r.results or {} do
                    table.insert(names, tostring(x.rod_skin_id or x.rarity or "?"))
                end
                WindUI:Notify({Title=gk, Content=table.concat(names, ", "), Duration=3})
                return true
            end
        end
    elseif auraPull then
        local AuraCtrl = getController("AuraGachaController")
        if AuraCtrl then
            local r = AuraCtrl.Pull:Fire(k)
            if type(r) == "table" and r.ok then
                local names = {}
                for _, x in r.results or {} do
                    table.insert(names, tostring(x.aura_id or x.rarity or "?"))
                end
                WindUI:Notify({Title=gk, Content=table.concat(names, ", "), Duration=3})
                return true
            end
        end
    else
        local r = ctrl.Pull:Fire("Coin", k)
        if type(r) == "table" and r.ok then
            local names = {}
            for _, x in r.results or {} do
                table.insert(names, tostring(x.skill_id or x.rarity or "?"))
            end
            WindUI:Notify({Title="Skill Master", Content=table.concat(names, ", "), Duration=3})
            return true
        end
    end
    return false
end

local function startAutoRoll()
    if RollTask then return end
    RollTask = task.spawn(function()
        while st.autoRoll do
            task.wait(3)
            if not st.autoRoll then break end
            if SellBusy or Tweening then continue end
            pcall(doRollPass)
        end
        RollTask = nil
    end)
end

local function stopAutoRoll()
    st.autoRoll = false
    RollTask = nil
end

-- 2. AUTO BUY ROD
local BuyRodTask = nil
local ROD_LIST = {
    {name="Stone Rod", id="stone_rod", island="island_starter"},
    {name="Iron Rod", id="iron_rod", island="island_starter"},
    {name="Golden Rod", id="golden_rod", island="island_jungle"},
    {name="Steel Rod", id="steel_rod", island="island_jungle"},
    {name="Golden Steel Rod", id="golden_steel_rod", island="island_desert"},
    {name="Diamond Steel Rod", id="diamond_steel_rod", island="island_desert"},
    {name="Taoist Rod", id="taoist_rod", island="island_snow"},
    {name="Legacy Rod", id="legacy_rod", island="island_snow"},
}

local function tryBuyRod(rodEntry)
    if not rodEntry then return false end
    local ctrl = getController("FishingRodShopController")
    if not ctrl then return false end
    local r = ctrl.PurchaseRod:Fire(rodEntry.id)
    if r == true then
        WindUI:Notify({Title="Rod Purchase", Content="Bought "..rodEntry.name, Duration=3})
        local eqCtrl = getController("EquipmentsController")
        if eqCtrl then pcall(function() eqCtrl.EquipmentEquip:Fire("rod", rodEntry.id) end) end
        return true
    end
    return false
end

local function startAutoBuyRod()
    if BuyRodTask then return end
    BuyRodTask = task.spawn(function()
        while st.autoBuyRod do
            task.wait(5)
            if not st.autoBuyRod then break end
            local entry
            for _, r in ipairs(ROD_LIST) do
                if r.name == st.buyRodName then entry = r break end
            end
            if not entry then continue end
            local profile = fetchProfile()
            if profile and profile.Rods and profile.Rods[entry.id] then
                continue
            end
            pcall(tryBuyRod, entry)
        end
        BuyRodTask = nil
    end)
end

local function stopAutoBuyRod()
    st.autoBuyRod = false
    BuyRodTask = nil
end

-- 3. AUTO UNLOCK ISLAND (via NPC)
local UnlockTask = nil
local UNLOCK_QUESTS = {
    {npc="npc_unlock_island_2", from="island_starter", to="island_jungle", name="Jungle"},
    {npc="npc_unlock_island_3", from="island_jungle", to="island_desert", name="Desert"},
    {npc="npc_unlock_island_4", from="island_desert", to="island_snow", name="Snow"},
    {npc="npc_unlock_island_5", from="island_snow", to="island_volcano", name="Volcanic"},
    {npc="npc_unlock_island_6", from="island_volcano", to="island_fossil", name="Fossil"},
}

local function findInteractiveById(id, islandId)
    for _, x in ipairs(Collection:GetTagged("Interactive")) do
        if x:GetAttribute("InteractiveId") == id then
            if not islandId or x:GetAttribute("IslandId") == islandId then
                local p = x:IsA("Model") and x:GetPivot().Position or x:IsA("BasePart") and x.Position
                if p then return p end
            end
        end
    end
    return nil
end

local function startAutoUnlock()
    if UnlockTask then return end
    UnlockTask = task.spawn(function()
        while st.autoUnlock do
            task.wait(5)
            if not st.autoUnlock then break end
            local profile = fetchProfile()
            if not profile or not profile.UnlockedIslands then continue end
            for _, q in ipairs(UNLOCK_QUESTS) do
                if not profile.UnlockedIslands[q.to] then
                    local np = findInteractiveById(q.npc)
                    if np then
                        local c = LP.Character
                        local r = c and c:FindFirstChild("HumanoidRootPart")
                        if r then
                            local dist = (np - r.Position).Magnitude
                            if dist > 15 then
                                tweenTo(CFrame.new(np + Vector3.new(0, 5, 0)), 60)
                            else
                                local qCtrl = getController("QuestController")
                                if qCtrl then
                                    pcall(function()
                                        qCtrl:Accept(q.npc)
                                        task.wait(0.5)
                                        qCtrl:Complete(q.npc)
                                    end)
                                    WindUI:Notify({Title="Unlock Island", Content="Attempted unlock "..q.name, Duration=3})
                                end
                            end
                        end
                    end
                    break
                end
            end
        end
        UnlockTask = nil
    end)
end

local function stopAutoUnlock()
    st.autoUnlock = false
    UnlockTask = nil
end

-- 4. AUTO ISLAND (teleport to target island)
local AutoIslandTask = nil
local function startAutoIsland()
    if AutoIslandTask then return end
    AutoIslandTask = task.spawn(function()
        while st.autoIsland do
            task.wait(5)
            if not st.autoIsland then break end
            local targetId = ISLAND_IDS[string.lower(st.autoIslandTarget)]
            if targetId then
                local curId
                pcall(function()
                    local ctrl = getController("IslandRegionController")
                    curId = ctrl and ctrl:GetCurrentIslandId()
                end)
                if curId ~= targetId then
                    pcall(function() teleIsland(string.lower(st.autoIslandTarget)) end)
                end
            end
        end
        AutoIslandTask = nil
    end)
end

local function stopAutoIsland()
    st.autoIsland = false
    AutoIslandTask = nil
end

-- 5. TELEPORT TO NPC
local NPC_LIST = {
    "Fish Merchant - Starter Island",
    "Rod Merchant - Starter Island",
    "Boat Merchant - Starter Island",
    "Skill Master",
    "Auras Dealer",
    "Jungle Island Guide",
    "Fish Merchant - Jungle Island",
    "Rod Merchant - Jungle Island",
    "Boat Merchant - Jungle Island",
    "Desert Island Guide",
    "Fish Merchant - Desert Island",
    "Rod Merchant - Desert Island",
    "Boat Merchant - Desert Island",
    "Snow Island Guide",
    "Fish Merchant - Snow Island",
    "Rod Merchant - Snow Island",
    "Boat Merchant - Snow Island",
    "Volcanic Island Guide",
    "Fish Merchant - Volcanic Island",
    "Boat Merchant - Volcanic Island",
    "Fossil Island Guide",
    "Fish Merchant - Fossil Island",
}

local NPC_IDS = {
    ["Fish Merchant - Starter Island"] = {id="npc_fish_seller", island="island_starter"},
    ["Rod Merchant - Starter Island"] = {id="npc_rod_shop", island="island_starter"},
    ["Boat Merchant - Starter Island"] = {id="npc_car_merchant", island="island_starter"},
    ["Skill Master"] = {id="npc_gacha_book", island="island_starter"},
    ["Auras Dealer"] = {id="npc_gacha_aura", island="island_starter"},
    ["Jungle Island Guide"] = {id="npc_unlock_island_2", island="island_jungle"},
    ["Fish Merchant - Jungle Island"] = {id="npc_fish_seller", island="island_jungle"},
    ["Rod Merchant - Jungle Island"] = {id="npc_rod_shop", island="island_jungle"},
    ["Boat Merchant - Jungle Island"] = {id="npc_car_merchant", island="island_jungle"},
    ["Desert Island Guide"] = {id="npc_unlock_island_3", island="island_desert"},
    ["Fish Merchant - Desert Island"] = {id="npc_fish_seller", island="island_desert"},
    ["Rod Merchant - Desert Island"] = {id="npc_rod_shop", island="island_desert"},
    ["Boat Merchant - Desert Island"] = {id="npc_car_merchant", island="island_desert"},
    ["Snow Island Guide"] = {id="npc_unlock_island_4", island="island_snow"},
    ["Fish Merchant - Snow Island"] = {id="npc_fish_seller", island="island_snow"},
    ["Rod Merchant - Snow Island"] = {id="npc_rod_shop", island="island_snow"},
    ["Boat Merchant - Snow Island"] = {id="npc_car_merchant", island="island_snow"},
    ["Volcanic Island Guide"] = {id="npc_unlock_island_5", island="island_volcano"},
    ["Fish Merchant - Volcanic Island"] = {id="npc_fish_seller", island="island_volcano"},
    ["Boat Merchant - Volcanic Island"] = {id="npc_car_merchant", island="island_volcano"},
    ["Fossil Island Guide"] = {id="npc_unlock_island_6", island="island_fossil"},
    ["Fish Merchant - Fossil Island"] = {id="npc_fish_seller", island="island_fossil"},
}

local function teleportToNPC(npcName)
    local info = NPC_IDS[npcName]
    if not info then return end
    local np = findInteractiveById(info.id, info.island)
    if not np then
        WindUI:Notify({Title="Teleport", Content="NPC not found: "..npcName, Duration=3})
        return
    end
    tweenTo(CFrame.new(np + Vector3.new(0, 5, 0)), 60)
    task.wait(0.5)
    WindUI:Notify({Title="Teleport", Content="Arrived at "..npcName, Duration=2})
end

-- 6. FPS BOOSTER (Advanced)
local FPSActive = false
local FPSBackup = nil
local function enableFPSBooster()
    if FPSActive then return end
    FPSActive = true
    local sc = getController("SettingsController")
    if sc and type(sc._SetLocal) == "function" then
        pcall(sc._SetLocal, sc, "ultra_low_graphic", true)
        pcall(sc._SetLocal, sc, "show_others_vfx", false)
        pcall(sc._SetLocal, sc, "show_my_vfx", false)
        pcall(sc._SetLocal, sc, "camera_shaking", false)
        pcall(sc._SetLocal, sc, "show_damage_indicator", false)
    end
    FPSBackup = {shadows = Lighting.GlobalShadows, fogEnd = Lighting.FogEnd}
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1e9
    end)
    for _, d in ipairs(Lighting:GetChildren()) do
        if d:IsA("PostEffect") then
            d.Enabled = false
            d:GetPropertyChangedSignal("Enabled"):Connect(function()
                if d.Enabled then d.Enabled = false end
            end)
        elseif d:IsA("Atmosphere") then
            d.Density, d.Haze, d.Glare = 0, 0, 0
        end
    end
    task.spawn(function()
        for _, inst in ipairs(workspace:GetDescendants()) do
            pcall(function()
                if inst:IsA("ParticleEmitter") then inst.Enabled = false inst.Rate = 0
                elseif inst:IsA("Beam") or inst:IsA("Trail") then inst.Enabled = false
                elseif inst:IsA("PointLight") or inst:IsA("SurfaceLight") or inst:IsA("SpotLight") then inst.Enabled = false
                elseif inst:IsA("Highlight") and inst.Name ~= "DNHubBossEsp" and inst.Name ~= "DNHubNameTag" then inst.Enabled = false
                elseif inst:IsA("Fire") or inst:IsA("Smoke") or inst:IsA("Sparkles") then inst.Enabled = false
                elseif inst:IsA("BasePart") and inst.Material ~= Enum.Material.Water then
                    inst.Material = Enum.Material.SmoothPlastic
                    inst.Reflectance = 0
                    inst.CastShadow = false
                end
            end)
            task.wait()
        end
    end)
    WindUI:Notify({Title="FPS Booster", Content="Enabled until rejoin", Duration=3})
end

local function disableFPSBooster()
    if not FPSActive then return end
    FPSActive = false
    if FPSBackup then
        pcall(function()
            Lighting.GlobalShadows = FPSBackup.shadows
            Lighting.FogEnd = FPSBackup.fogEnd
        end)
    end
end

-- 7. VISUAL (Rod Skin / Aura)
local VisualActive = {RodSkinId = nil, AuraCatalogId = nil}
local function applyRodSkin(skinId)
    VisualActive.RodSkinId = skinId
    pcall(function() LP:SetAttribute("RodSkinId", skinId) end)
end

local function applyAura(auraId)
    VisualActive.AuraCatalogId = auraId
    pcall(function() LP:SetAttribute("AuraCatalogId", auraId) end)
end

local ROD_SKINS = {"Default", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Divine"}
local AURA_LIST = {"Default", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Divine"}

-- 8. BOSS HP BAR
local BossHpUI = nil
local function createBossHpUI()
    if BossHpUI then return end
    local sg = Instance.new("ScreenGui")
    sg.Name = "DNHubBossHP"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 15
    sg.Parent = PG
    BossHpUI = sg
    local fr = Instance.new("Frame")
    fr.Name = "Bar"
    fr.AnchorPoint = Vector2.new(0.5, 0)
    fr.Position = UDim2.new(0.5, 0, 0, 8)
    fr.Size = UDim2.fromOffset(420, 60)
    fr.BackgroundColor3 = Color3.fromRGB(37, 37, 34)
    fr.BorderSizePixel = 0
    fr.Visible = false
    fr.Parent = sg
    Instance.new("UICorner", fr).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(72, 72, 66)
    stroke.Thickness = 1
    stroke.Parent = fr
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.Position = UDim2.fromOffset(12, 6)
    nameLabel.Size = UDim2.new(1, -24, 0, 18)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.TextColor3 = Color3.fromRGB(244, 240, 232)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Text = "Boss"
    nameLabel.Parent = fr
    local barBg = Instance.new("Frame")
    barBg.Position = UDim2.fromOffset(12, 29)
    barBg.Size = UDim2.new(1, -24, 0, 8)
    barBg.BackgroundColor3 = Color3.fromRGB(72, 72, 66)
    barBg.BorderSizePixel = 0
    barBg.Parent = fr
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(0, 4)
    local barFill = Instance.new("Frame")
    barFill.Name = "Fill"
    barFill.Size = UDim2.fromScale(1, 1)
    barFill.BackgroundColor3 = Color3.fromRGB(214, 106, 94)
    barFill.BorderSizePixel = 0
    barFill.Parent = barBg
    Instance.new("UICorner", barFill).CornerRadius = UDim.new(0, 4)
    local hpText = Instance.new("TextLabel")
    hpText.Name = "HP"
    hpText.Position = UDim2.fromOffset(12, 40)
    hpText.Size = UDim2.new(1, -24, 0, 16)
    hpText.BackgroundTransparency = 1
    hpText.Font = Enum.Font.GothamMedium
    hpText.TextSize = 12
    hpText.TextColor3 = Color3.fromRGB(150, 147, 140)
    hpText.TextXAlignment = Enum.TextXAlignment.Left
    hpText.Text = "0 / 0"
    hpText.Parent = fr
end

local function updateBossHpUI()
    if not BossHpUI then return end
    local fr = BossHpUI:FindFirstChild("Bar")
    if not fr then return end
    if not ActiveBoss.part or not ActiveBoss.meta then
        fr.Visible = false
        return
    end
    fr.Visible = true
    fr.Name.Text = tostring(ActiveBoss.meta.name or "Boss")
    local hp = 100
    local hum = ActiveBoss.part.Parent and ActiveBoss.part.Parent:FindFirstChildOfClass("Humanoid")
    if hum then
        hp = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
        fr.HP.Text = string.format("%d / %d", math.floor(hum.Health), math.floor(hum.MaxHealth))
    else
        fr.HP.Text = "N/A"
    end
    fr.BarBg.Fill.Size = UDim2.fromScale(hp, 1)
end

-- 9. STATUS TAB (quest tracking)
local function buildStatusText()
    local lines = {}
    local profile = fetchProfile()
    if not profile then return "Loading..." end
    table.insert(lines, "Coins: " .. tostring(profile.Coin or 0))
    table.insert(lines, "Gems: " .. tostring(profile.Gem or 0))
    local quest = profile.Quest and profile.Quest.Current
    if quest then
        table.insert(lines, "Quest: " .. tostring(quest.Id))
    else
        table.insert(lines, "Quest: None")
    end
    local fish = countFishInBackpack()
    table.insert(lines, "Fish in bag: " .. tostring(fish) .. " / " .. FISH_CAPACITY)
    table.insert(lines, "Rod Equipped: " .. tostring(profile.RodEquip or "None"))
    return table.concat(lines, "\n")
end

-- ============== UI ==============
local Window = WindUI:CreateWindow({
    Title = "DNHUB 3.0",
    Icon = "fish",
    Author = "DN Team + NgaoGaming",
    Folder = "DNHub",
    Size = UDim2.fromOffset(700, 500),
    Theme = st.uiTheme or "Dark",
    Transparent = true,
    Resizable = true,
    HideSearchBar = false,
    Topbar = {Height=44, ButtonsType="Mac"},
    OpenButton = {
        Title = "DNHUB 3.0",
        Icon = "fish",
        CornerRadius = UDim.new(1,0),
        StrokeThickness = 2,
        Enabled = true,
        Draggable = true,
        Color = ColorSequence.new(Color3.fromHex("#7D91FF"), Color3.fromHex("#A0B4FF")),
    },
})

local MainTab = Window:Tab({Title="Main", Icon="user"})
local TeleTab = Window:Tab({Title="Teleport", Icon="map-pin"})
local RollTab = Window:Tab({Title="Roll", Icon="dice-5"})
local ShopTab = Window:Tab({Title="Shop", Icon="shopping-cart"})
local QuestTab = Window:Tab({Title="Quest", Icon="scroll"})
local BossTab = Window:Tab({Title="Boss", Icon="swords"})
local VisualTab = Window:Tab({Title="Visual", Icon="palette"})
local PlrTab = Window:Tab({Title="Player", Icon="users"})
local MiscTab = Window:Tab({Title="Misc", Icon="settings"})
local StatusTab = Window:Tab({Title="Status", Icon="info"})
local SettingsTab = Window:Tab({Title="Settings", Icon="wrench"})

LP.Idled:Connect(function() pcall(function() VU:CaptureController() VU:ClickButton2(Vector2.new()) end) end)

-- ========== MAIN TAB ==========
local MGSection = MainTab:Section({Title="Automation"})
MGSection:Toggle({Title="Auto Fish", Default=st.fish, Callback=function(v) st.fish=v if v then startFish() else stopFish() end end})
MGSection:Toggle({Title="Auto Skill", Default=st.skill, Callback=function(v) st.skill=v end})
MGSection:Toggle({Title="Bypass Minigame", Default=st.bypass, Callback=function(v) st.bypass=v end})

local SkillSection = MainTab:Section({Title="Skill Order"})
SkillSection:Input({
    Title = "Skill Order (1,2,3,4)",
    Value = table.concat(st.skillOrder or {1,2,1,3}, ","),
    Placeholder = "1,2,1,3",
    Callback = function(v)
        local arr = {}
        for num in tostring(v):gmatch("%d+") do
            local n = tonumber(num)
            if n and n >= 1 and n <= 4 then table.insert(arr, n) end
        end
        if #arr > 0 then st.skillOrder = arr SkillCycle.index = 1 end
    end
})

local SG2Section = MainTab:Section({Title="Sell"})
SG2Section:Toggle({Title="Auto Sell", Default=st.sell, Callback=function(v) st.sell=v if v then startSell() end end})
SG2Section:Toggle({Title="Sell When Full", Default=st.autoSellFull, Callback=function(v) st.autoSellFull=v if v then startAutoFull() end end})
SG2Section:Toggle({Title="Walk Mode", Default=st.useWalk, Callback=function(v) st.useWalk=v end})
SG2Section:Toggle({Title="Return After Sell", Default=st.returnAfterSell, Callback=function(v) st.returnAfterSell=v end})
SG2Section:Dropdown({
    Title = "Travel Mode",
    Values = {"Tween","Walk","Instant"},
    Value = st.sellTravelMode or "Tween",
    Callback = function(v)
        st.sellTravelMode = v
        st.useWalk = (v == "Walk")
    end,
})
SG2Section:Slider({Title="Interval (s)", Value={Min=30,Max=3600,Default=sellInt}, Step=1, Callback=function(v) sellInt=v end})
SG2Section:Button({Title="Sell Now", Callback=function() task.spawn(doSellFull) end})

local LockSection = MainTab:Section({Title="Fish Lock🔒"})
LockSection:Toggle({
    Title = "Auto Lock",
    Default = st.autoLock,
    Callback = function(v)
        st.autoLock = v
        if v then task.spawn(autoLockPass) end
    end
})

local rarityList = getRarityList()
local function raritySetToArray(set)
    local arr = {}
    for _, r in ipairs(rarityList) do
        if type(set)=="table" and set[r] then table.insert(arr, r) end
    end
    return arr
end

LockSection:Dropdown({
    Title = "Lock Rarity",
    Values = rarityList,
    Multi = true,
    AllowNone = true,
    Value = raritySetToArray(st.lockRarity),
    Callback = function(picked)
        local set = {}
        if type(picked) == "table" then
            for _, r in ipairs(picked) do set[r] = true end
        elseif type(picked) == "string" then
            set[picked] = true
        end
        st.lockRarity = set
    end
})

LockSection:Button({Title="Lock Now", Callback=function() task.spawn(autoLockPass) end})

-- ========== TELEPORT TAB ==========
local TGSection = TeleTab:Section({Title="Island"})
TGSection:Dropdown({
    Title = "Island",
    Values = ISLAND_DISPLAY,
    Value = ISLAND_LABELS[island] or "Starter",
    Callback = function(v)
        for _, id in ipairs(ISLAND_ORDER) do
            if ISLAND_LABELS[id] == v then island = id break end
        end
    end
})
TGSection:Button({Title="Teleport Island", Callback=function() teleIsland(island) end})
TGSection:Toggle({Title="ESP Island", Default=st.esp, Callback=function(v) st.esp=v if v then startESP() else stopESP() end end})

local AutoIslandSection = TeleTab:Section({Title="Auto Island"})
AutoIslandSection:Dropdown({
    Title = "Target Island",
    Values = ISLAND_DISPLAY,
    Value = "Starter",
    Callback = function(v) st.autoIslandTarget = v end,
})
AutoIslandSection:Toggle({
    Title = "Auto Island",
    Default = false,
    Callback = function(v)
        if v then startAutoIsland() else stopAutoIsland() end
    end
})

local NPCSection = TeleTab:Section({Title="Teleport to NPC"})
NPCSection:Dropdown({
    Title = "NPC",
    Values = NPC_LIST,
    Value = NPC_LIST[1],
    Callback = function(v) st.teleportTarget = v end,
})
NPCSection:Button({
    Title = "Teleport to NPC",
    Callback = function() task.spawn(function() teleportToNPC(st.teleportTarget) end) end,
})

local TpOptSection = TeleTab:Section({Title="Teleport Options"})
TpOptSection:Dropdown({
    Title = "Teleport Mode",
    Values = {"Tween","Instant TP"},
    Value = st.tpMode == "Instant" and "Instant TP" or "Tween",
    Callback = function(v) st.tpMode = (v == "Tween") and "Tween" or "Instant" end,
})
TpOptSection:Slider({Title="Fly Speed", Value={Min=20,Max=300,Default=70}, Step=1, Callback=function(v) st.flySpeed = v end})
TpOptSection:Button({Title="Stop Flying", Callback=function() Tweening = false end})

-- ========== ROLL TAB ==========
local RollSection = RollTab:Section({Title="Gacha Roll"})
RollSection:Dropdown({
    Title = "Gacha Type",
    Values = RollNames,
    Value = "Skill Master",
    Callback = function(v) st.rollType = v end,
})
RollSection:Dropdown({
    Title = "Roll Amount",
    Values = {"x1", "x10"},
    Value = "x1",
    Callback = function(v) st.rollMulti = v end,
})
RollSection:Toggle({
    Title = "Auto Roll",
    Default = false,
    Callback = function(v)
        if v then st.autoRoll = true startAutoRoll() else stopAutoRoll() end
    end,
})
RollSection:Button({Title="Roll Once", Callback=function() task.spawn(doRollPass) end})

-- ========== SHOP TAB ==========
local BuyRodSection = ShopTab:Section({Title="Rod Shop"})
local rodNames = {}
for _, r in ipairs(ROD_LIST) do table.insert(rodNames, r.name) end
BuyRodSection:Dropdown({
    Title = "Select Rod",
    Values = rodNames,
    Value = rodNames[1],
    Callback = function(v) st.buyRodName = v end,
})
BuyRodSection:Toggle({
    Title = "Auto Buy Rod",
    Default = false,
    Callback = function(v)
        if v then st.autoBuyRod = true startAutoBuyRod() else stopAutoBuyRod() end
    end,
})

-- ========== QUEST TAB ==========
local QuestSection = QuestTab:Section({Title="Unlock Island"})
QuestSection:Toggle({
    Title = "Auto Unlock Island",
    Default = false,
    Callback = function(v)
        if v then st.autoUnlock = true startAutoUnlock() else stopAutoUnlock() end
    end,
})

-- ========== BOSS TAB ==========
local BossSection = BossTab:Section({Title="ESP Boss"})
BossSection:Toggle({Title="ESP Part 1", Default=st.bossEsp1, Callback=function(v) st.bossEsp1=v end})
BossSection:Toggle({Title="ESP Part 2", Default=st.bossEsp2, Callback=function(v) st.bossEsp2=v end})
BossSection:Button({Title="Reset ESP", Callback=function() stopBossEsp() end})
BossSection:Toggle({Title="Auto Boss", Default=st.autoBoss, Callback=function(v)
    st.autoBoss = v
    if not v and BossStepState.holding then
        BossStepState.holding = false
        BossStepState.engaged = nil
        BossStepState.step = "Idle"
    end
end})
BossSection:Toggle({Title="Return After Boss", Default=st.bossReturn, Callback=function(v) st.bossReturn=v end})

local BossInfoSection = BossTab:Section({Title="Boss Info"})
local bossInfoLabel = BossInfoSection:Paragraph({Title = "Loading boss info..."})
BossInfoSection:Button({Title = "Teleport to Boss", Callback = function() task.spawn(teleToBoss) end})

-- ========== VISUAL TAB ==========
local VisualSection = VisualTab:Section({Title="Effect"})
VisualSection:Dropdown({
    Title = "Rod Skin",
    Values = ROD_SKINS,
    Value = "Default",
    Callback = function(v) applyRodSkin(v ~= "Default" and v or nil) end,
})
VisualSection:Dropdown({
    Title = "Aura",
    Values = AURA_LIST,
    Value = "Default",
    Callback = function(v) applyAura(v ~= "Default" and v or nil) end,
})

-- ========== PLAYER TAB ==========
local SpeedSection = PlrTab:Section({Title="Speed"})
SpeedSection:Toggle({Title="Enable Speed", Default=st.speedOn, Callback=function(v) enableSpeed(v) end})
SpeedSection:Slider({Title="Speed (16-200)", Value={Min=16,Max=200,Default=st.speed}, Step=1, Callback=function(v) applySpeed(v) end})

local FNSection = PlrTab:Section({Title="Fake Name"})
FNSection:Toggle({
    Title = "Enable Fake Name",
    Default = st.fakename,
    Callback = function(v) st.fakename = v if v then startFake() else stopFake() end end,
})
FNSection:Input({
    Title = "Custom Nametag",
    Value = customName,
    Placeholder = "DNHub 3.0",
    Callback = function(v) customName = v updateTagText() end,
})
FNSection:Toggle({Title="Rainbow Color", Default=st.tagRainbow, Callback=function(v) setTagRainbow(v) end})
FNSection:Colorpicker({
    Title = "Nametag Color",
    Default = Color3.new(st.tagColorR or 0.7, st.tagColorG or 0.4, st.tagColorB or 1.0),
    Callback = function(color) setTagColor(color.R, color.G, color.B) end,
})

-- ========== MISC TAB ==========
local GfxSection = MiscTab:Section({Title="Graphics"})
GfxSection:Toggle({Title="Lite Graphics", Default=st.liteGfx, Callback=function(v) setLite(v) end})
GfxSection:Button({Title="FPS Booster (Until Rejoin)", Callback=function() enableFPSBooster() end})

local SysSection = MiscTab:Section({Title="System"})
SysSection:Button({Title="Unload Menu", Callback=function()
    st.fish=false st.bypass=false st.skill=false st.sell=false st.speedOn=false st.fakename=false st.autoSellFull=false st.esp=false
    st.bossEsp1=false st.bossEsp2=false st.liteGfx=false st.autoLock=false st.autoBoss=false st.antiAfk=false
    st.autoRoll=false st.autoBuyRod=false st.autoIsland=false st.autoUnlock=false st.autoQuest=false
    Fish.farm = false
    Fish.paused = false
    stopESP()
    stopBossEsp()
    stopFake()
    stopAutoRoll()
    stopAutoBuyRod()
    stopAutoIsland()
    stopAutoUnlock()
    disableFPSBooster()
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed=16
        LP.Character.Humanoid.JumpPower=50
    end
    Window:Destroy()
end})

-- ========== STATUS TAB ==========
local StatSec = StatusTab:Section({Title="Live Info"})
local statusLabel = StatSec:Paragraph({Title="Loading..."})
StatSec:Button({Title="Refresh", Callback=function() statusLabel:SetTitle(buildStatusText()) end})

task.spawn(function()
    while Window and Window.UIElements do
        task.wait(2)
        pcall(function() statusLabel:SetTitle(buildStatusText()) end)
    end
end)

-- ========== SETTINGS TAB ==========
local AntiAfkSection = SettingsTab:Section({Title="Anti AFK"})
AntiAfkSection:Toggle({
    Title = "Anti AFK",
    Default = st.antiAfk,
    Callback = function(v) st.antiAfk = v if v then startAntiAfk() end end,
})
AntiAfkSection:Slider({
    Title = "Interval (s)",
    Value = {Min=10,Max=300,Default=st.antiAfkInterval or 50},
    Step = 1,
    Callback = function(v) st.antiAfkInterval = v end,
})

local ThemeSection = SettingsTab:Section({Title="Appearance"})
ThemeSection:Dropdown({
    Title = "UI Theme",
    Values = {"Dark","Light","Rose","Emerald"},
    Value = st.uiTheme or "Dark",
    Callback = function(v) st.uiTheme = v pcall(function() WindUI:SetTheme(v) end) end,
})
ThemeSection:Colorpicker({
    Title = "Accent Color",
    Default = Color3.fromHex("#2DD4BF"),
    Callback = function(color)
        st.uiAccent = color:ToHex()
        applyAccent(WindUI, color)
    end,
})

-- ========== BACKGROUND TASKS ==========
task.spawn(function()
    while true do
        if st.bossEsp1 or st.bossEsp2 or st.autoBoss then
            pcall(bossEsp)
            if st.autoBoss then pcall(bossStep) end
        end
        task.wait(1.5)
    end
end)

task.spawn(function()
    while true do
        if st.autoLock then pcall(autoLockPass) end
        task.wait(2)
    end
end)

task.spawn(function()
    task.wait(2)
    if st.fish then startFish() end
    if st.sell then startSell() end
    if st.autoSellFull then startAutoFull() end
    if st.fakename then startFake() end
    if st.esp then startESP() end
    if st.speedOn and st.speed then applySpeed(st.speed) end
    if st.liteGfx then setLite(true) end
    if st.antiAfk then startAntiAfk() end
end)

LP.CharacterAdded:Connect(function(c)
    c:WaitForChild("Humanoid")
    task.wait(0.5)
    if st.speedOn and st.speed then c.Humanoid.WalkSpeed = st.speed end
    if st.fish then startFish() end
    if st.fakename then
        task.wait(0.3)
        hideOriginalNames()
        createCustomTag()
    end
    if st.antiAfk then startAntiAfk() end
end)

-- ========== BOSS HP UI ==========
createBossHpUI()
task.spawn(function()
    while true do
        task.wait(0.3)
        pcall(updateBossHpUI)
    end
end)

-- ========== FISH COUNTER BUBBLE ==========
local FishCounterUI = Instance.new("ScreenGui")
FishCounterUI.Name = "DNHubFishCounter"
FishCounterUI.ResetOnSpawn = false
FishCounterUI.IgnoreGuiInset = true
FishCounterUI.DisplayOrder = 9000
FishCounterUI.Parent = PG

local bubble = Instance.new("Frame")
bubble.Name = "Bubble"
bubble.AnchorPoint = Vector2.new(1, 0)
bubble.Position = UDim2.new(1, -14, 0, 14)
bubble.Size = UDim2.fromOffset(220, 92)
bubble.BackgroundColor3 = Color3.fromRGB(14, 19, 31)
bubble.BackgroundTransparency = 0.08
bubble.BorderSizePixel = 0
bubble.Parent = FishCounterUI

Instance.new("UICorner", bubble).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(60, 74, 102)
stroke.Thickness = 1
stroke.Transparency = 0.3
stroke.Parent = bubble

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 22)
title.Position = UDim2.fromOffset(14, 8)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(56, 189, 248)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "DNHUB - STORAGE"
title.Parent = bubble

local line1 = Instance.new("TextLabel")
line1.Size = UDim2.new(1, -20, 0, 20)
line1.Position = UDim2.fromOffset(14, 32)
line1.BackgroundTransparency = 1
line1.Font = Enum.Font.GothamMedium
line1.TextSize = 14
line1.TextColor3 = Color3.fromRGB(238, 244, 255)
line1.TextXAlignment = Enum.TextXAlignment.Left
line1.Text = "Fish: 0 / 50"
line1.Parent = bubble

local line2 = Instance.new("TextLabel")
line2.Size = UDim2.new(1, -20, 0, 18)
line2.Position = UDim2.fromOffset(14, 56)
line2.BackgroundTransparency = 1
line2.Font = Enum.Font.Gotham
line2.TextSize = 12
line2.TextColor3 = Color3.fromRGB(172, 186, 210)
line2.TextXAlignment = Enum.TextXAlignment.Left
line2.Text = "Total: 0 | Rod: 0"
line2.Parent = bubble

local barBg = Instance.new("Frame")
barBg.Size = UDim2.new(1, -28, 0, 4)
barBg.Position = UDim2.new(0, 14, 1, -12)
barBg.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
barBg.BorderSizePixel = 0
barBg.Parent = bubble
Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

local barFill = Instance.new("Frame")
barFill.Size = UDim2.fromScale(0, 1)
barFill.BackgroundColor3 = Color3.fromRGB(56, 189, 248)
barFill.BorderSizePixel = 0
barFill.Parent = barBg
Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)

local lastFish, lastTotal, lastRods = -1, -1, -1

local function updateFishCounter()
    local bp = LP:FindFirstChildOfClass("Backpack")
    if not bp then
        line1.Text = "No Backpack"
        line2.Text = ""
        return
    end
    local total, fish, rods = 0, 0, 0
    for _, item in ipairs(bp:GetChildren()) do
        total = total + 1
        if isRodItem(item) then rods = rods + 1 else fish = fish + 1 end
    end
    if fish == lastFish and total == lastTotal and rods == lastRods then return end
    lastFish, lastTotal, lastRods = fish, total, rods
    local cap = FISH_CAPACITY
    line1.Text = string.format("Fish: %d / %d", fish, cap)
    line2.Text = string.format("Total: %d | Rod: %d", total, rods)
    local ratio = cap > 0 and math.clamp(fish / cap, 0, 1) or 0
    barFill.Size = UDim2.fromScale(ratio, 1)
    if fish >= cap then
        barFill.BackgroundColor3 = Color3.fromRGB(248, 113, 113)
        line1.TextColor3 = Color3.fromRGB(248, 113, 113)
    elseif ratio >= 0.8 then
        barFill.BackgroundColor3 = Color3.fromRGB(251, 146, 60)
        line1.TextColor3 = Color3.fromRGB(251, 146, 60)
    else
        barFill.BackgroundColor3 = Color3.fromRGB(56, 189, 248)
        line1.TextColor3 = Color3.fromRGB(238, 244, 255)
    end
end

updateFishCounter()

local bpRef = LP:FindFirstChildOfClass("Backpack")
if bpRef then
    bpRef.ChildAdded:Connect(updateFishCounter)
    bpRef.ChildRemoved:Connect(updateFishCounter)
end

LP.CharacterAdded:Connect(function()
    task.wait(1)
    local newBp = LP:FindFirstChildOfClass("Backpack")
    if newBp then
        newBp.ChildAdded:Connect(updateFishCounter)
        newBp.ChildRemoved:Connect(updateFishCounter)
    end
    updateFishCounter()
end)

task.spawn(function()
    while FishCounterUI.Parent do
        task.wait(0.5)
        updateFishCounter()
    end
end)

WindUI:Notify({Title="DNHUB 3.0", Content="FishingMaster features integrated!", Duration=5})
