local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

local Camera = game:GetService("Workspace").CurrentCamera
local CurrentCamera = workspace.CurrentCamera

local LocalPlayer = game.Players.LocalPlayer
local HumanoidRootPart = LocalPlayer.Character:WaitForChild("HumanoidRootPart", true)

local Window = Library:CreateWindow({

    Title = 'Atoz v1 [BETA]',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Main = Window:AddTab('Main'),
    Esp = Window:AddTab('Esp'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

local MovementBox = Tabs.Main:AddLeftGroupbox('Movements')

local AutoFarmBox = Tabs.Main:AddRightGroupbox('Auto Farm')

local CombatBox = Tabs.Main:AddRightGroupbox('Combat')

local MiscBox = Tabs.Main:AddLeftGroupbox('Misc')

local TeleportBox = Tabs.Main:AddRightGroupbox('Teleport')

local RemovalsBox = Tabs.Main:AddLeftGroupbox('Removals')

-- \\ Movement Functions // --

local MovementSettings = {
    FlyConnection = nil,
    FlyBodyVelocity = nil,
    FlySpeed = 100,

    SpeedConnection = nil,
    SpeedBodyVelocity = nil,
    WalkSpeed = 200,

    JumpConnection = nil,
    InfiniteJump = false,
    JumpHeight = 25,
}

local function Fly(toggle)
    if not toggle then
        if MovementSettings.FlyConnection then
            MovementSettings.FlyConnection:Disconnect()
            MovementSettings.FlyConnection = nil
        end
        if MovementSettings.FlyBodyVelocity then
            MovementSettings.FlyBodyVelocity:Destroy()
            MovementSettings.FlyBodyVelocity = nil
        end
        return
    end

    MovementSettings.FlyBodyVelocity = Instance.new("BodyVelocity")
    MovementSettings.FlyBodyVelocity.Name = "FBody"
    MovementSettings.FlyBodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
    CollectionService:AddTag(MovementSettings.FlyBodyVelocity, "Whitelisted")

    MovementSettings.FlyConnection = RunService.Heartbeat:Connect(function()
        local character = LocalPlayer.Character
        if not character then return end

        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        if not rootPart or not humanoid then return end

        local camera = workspace.CurrentCamera
        if not camera then return end

        MovementSettings.FlyBodyVelocity.Parent = rootPart

        local moveDirection = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + camera.CFrame.RightVector
        end

        if moveDirection.Magnitude > 0 then
            MovementSettings.FlyBodyVelocity.Velocity = moveDirection.Unit * MovementSettings.FlySpeed
        else
            MovementSettings.FlyBodyVelocity.Velocity = Vector3.zero
        end
    end)
end

local function ToggleSpeed(toggle)
    if not toggle then
        if MovementSettings.SpeedConnection then
            MovementSettings.SpeedConnection:Disconnect()
            MovementSettings.SpeedConnection = nil
        end
        if MovementSettings.SpeedBodyVelocity then
            MovementSettings.SpeedBodyVelocity:Destroy()
            MovementSettings.SpeedBodyVelocity = nil
        end
        return
    end

    MovementSettings.SpeedBodyVelocity = Instance.new("BodyVelocity")
    MovementSettings.SpeedBodyVelocity.Name = "SBody"
    MovementSettings.SpeedBodyVelocity.MaxForce = Vector3.new(100000, 0, 100000)
    CollectionService:AddTag(MovementSettings.SpeedBodyVelocity, "Whitelisted")

    MovementSettings.SpeedConnection = game:GetService("RunService").Heartbeat:Connect(function()
        local player = game.Players.LocalPlayer
        local character = player.Character
        if not character then return end

        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        if not rootPart or not humanoid then return end

        MovementSettings.SpeedBodyVelocity.Parent = rootPart

        local camera = workspace.CurrentCamera
        if not camera then return end

        local moveDirection = Vector3.zero
        local UserInputService = game:GetService("UserInputService")
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + camera.CFrame.RightVector
        end

        if moveDirection.Magnitude > 0 then
            MovementSettings.SpeedBodyVelocity.Velocity = Vector3.new(moveDirection.Unit.X, rootPart.Velocity.Y, moveDirection.Unit.Z) * MovementSettings.WalkSpeed
        else
            MovementSettings.SpeedBodyVelocity.Velocity = Vector3.new(0, rootPart.Velocity.Y, 0)
        end
    end)
end

local function InfiniteJumpFunction(toggle)
    MovementSettings.InfiniteJump = toggle
    
    if not toggle then return end

    MovementSettings.JumpConnection = UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Space and MovementSettings.InfiniteJump then
            local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.Velocity = Vector3.new(rootPart.Velocity.X, MovementSettings.JumpHeight * 2, rootPart.Velocity.Z)
            end
        end
    end)

    task.spawn(function()
        repeat task.wait() until not MovementSettings.InfiniteJump
        if MovementSettings.JumpConnection then
            MovementSettings.JumpConnection:Disconnect()
            MovementSettings.JumpConnection = nil
        end
    end)
end

-- \\ Movement Buttons // --

MovementBox:AddToggle('FlyToggle', {
    Text = 'Fly',
    Default = false,
    Tooltip = 'Enable or disable flying.',

    Callback = function(Value)
        Fly(Value)
    end
}):AddKeyPicker('FlyKey', {
    Default = '',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'Fly',
    NoUI = false,
})

MovementBox:AddSlider('FlySpeed', {
    Text = 'Fly Speed',
    Default = 100,
    Min = 10,
    Max = 400,
    Rounding = 1,
    Compact = false,

    Callback = function(Value)
        MovementSettings.FlySpeed = Value
    end
})

MovementBox:AddToggle('SpeedWalkToggle', {
    Text = 'Speed Walk',
    Default = false,
    Tooltip = 'Let you run faster',

    Callback = function(Value)
        ToggleSpeed(Value)
    end
}):AddKeyPicker('SpeedKey', {
    Default = '',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'Speed Walk',
    NoUI = false,
})

MovementBox:AddSlider('SpeedSlider', {
    Text = 'Speed Amount',
    Default = 200,
    Min = 0,
    Max = 400,
    Rounding = 1,
    Compact = false,

    Callback = function(Value)
        MovementSettings.WalkSpeed = Value
    end
})

MovementBox:AddToggle('InfiniteJumpToggle', {
    Text = 'Infinite Jump',
    Default = false,
    Tooltip = 'Let you Jump more',

    Callback = function(Value)
        InfiniteJumpFunction(Value)
    end
}):AddKeyPicker('JumpKey', {
    Default = '',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'Infinite Jump',
    NoUI = false,
})

MovementBox:AddSlider('JumpPowerSlide', {
    Text = 'Jump Power',
    Default = 25,
    Min = 10,
    Max = 100,
    Rounding = 1,
    Compact = false,

    Callback = function(Value)
        MovementSettings.JumpHeight = Value
    end
})

-- \\ Auto Farm Functions // --

local KillAuraTable = {
    KillAuraSize = 20,
    KillAuraConnection = nil,

    KillAura2Size = 200,
    KillAura2Connection = nil,
}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local KillAuraTable = {
    KillAuraSize = 20,
    KillAuraConnection = nil,

    KillAura2Size = 200,
    KillAura2Connection = nil,

    AutoBoxConnection = nil,
}

local function SetupKillAura(Value)
    if not Value then
        if KillAuraTable.KillAuraConnection then
            KillAuraTable.KillAuraConnection:Disconnect()
            KillAuraTable.KillAuraConnection = nil
        end

        local ExistingHitbox = Workspace:FindFirstChild("HitboxAuraK")
        if ExistingHitbox then
            ExistingHitbox:Destroy()
        end

        return
    end

    local Player = Players.LocalPlayer
    local Character = Player.Character
    if not Character or not Character:FindFirstChild("HumanoidRootPart") then
        return
    end

    local Hitbox = Instance.new("Part")
    Hitbox.Parent = Workspace
    Hitbox.Name = "HitboxAuraK"
    Hitbox.CanCollide = false
    Hitbox.CastShadow = false
    Hitbox.Size = Vector3.new(KillAuraTable.KillAuraSize, KillAuraTable.KillAuraSize, KillAuraTable.KillAuraSize)
    Hitbox.Color = Color3.fromRGB(0, 255, 0)
    Hitbox.Massless = true
    Hitbox.CanQuery = false
    Hitbox.Material = Enum.Material.ForceField
    Hitbox.CFrame = Character.HumanoidRootPart.CFrame

    local Weld = Instance.new("WeldConstraint")
    Weld.Part0 = Character.HumanoidRootPart
    Weld.Part1 = Hitbox
    Weld.Parent = Hitbox

    local TouchedEnemy = {}

    Hitbox.Touched:Connect(function(TouchPart)
        local Character = TouchPart.Parent
        if Character and Character:FindFirstChild("Humanoid") and Character:GetAttribute("EntityID") then
            local Humanoid = Character:FindFirstChild("Humanoid")
            if Humanoid and not TouchedEnemy[Character.Name] then
                TouchedEnemy[Character.Name] = true
                Humanoid.Health = 0
            end
        end
    end)

    KillAuraTable.KillAuraConnection = RunService.Heartbeat:Connect(function()
        if Hitbox then
            Hitbox.Size = Vector3.new(KillAuraTable.KillAuraSize, KillAuraTable.KillAuraSize, KillAuraTable.KillAuraSize)
        end
    end)
end

local function SetupKillAura2(Value)
    if not Value then
        if KillAuraTable.KillAura2Connection then
            KillAuraTable.KillAura2Connection:Disconnect()
            KillAuraTable.KillAura2Connection = nil
        end
        return
    end

    local Player = Players.LocalPlayer
    local Character = Player.Character
    if not Character or not Character:FindFirstChild("HumanoidRootPart") then
        return
    end

    local TouchedEnemy = {}

    KillAuraTable.KillAura2Connection = RunService.Heartbeat:Connect(function()
        local PlayerPosition = Character.HumanoidRootPart.Position
        for _, Character in ipairs(Workspace.Entities:GetChildren()) do
            if Character:IsA("Model") and Character:FindFirstChild("Humanoid") and Character:GetAttribute("EntityID") then
                local Humanoid = Character:FindFirstChild("Humanoid")
                local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
                if Humanoid and HumanoidRootPart and not TouchedEnemy[Character.Name] then
                    local Distance = (PlayerPosition - HumanoidRootPart.Position).Magnitude
                    if Distance <= KillAuraTable.KillAura2Size then
                        TouchedEnemy[Character.Name] = true
                        Humanoid.Health = 0
                    end
                end
            end
        end
    end)
end

local function AutoBox(Value)
    if not Value then
        if KillAuraTable.AutoBoxConnection then
            KillAuraTable.AutoBoxConnection:Disconnect()
            KillAuraTable.AutoBoxConnection = nil
        end
        return
    end

    KillAuraTable.AutoBoxConnection = RunService.Heartbeat:Connect(function()
        if LocalPlayer.Character.Race.Value == "Human" and LocalPlayer.Character.Faction.Value == "CCG" then
            for _, v in pairs(workspace.MissionBoards[LocalPlayer.Character.Faction.Value]:GetDescendants()) do
                if v:IsA("TextLabel") and v.Name == "Desc" and v.Text == "Deliver a Box" then
                    local clickDetector = v.Parent.Parent:FindFirstChildOfClass("ClickDetector")
                    if clickDetector then
                        fireclickdetector(clickDetector)
                    end
                end
            end
        else
            for _, v in pairs(workspace.MissionBoards[LocalPlayer.Character.Race.Value]:GetDescendants()) do
                if v:IsA("TextLabel") and v.Name == "Desc" and v.Text == "Deliver a Box" then
                    local clickDetector = v.Parent.Parent:FindFirstChildOfClass("ClickDetector")
                    if clickDetector then
                        fireclickdetector(clickDetector)
                    end
                end
            end
        end
    
        task.wait(0.25)
    
        for _, v in pairs(workspace.NPCEncounterZones:GetChildren()) do
            if v:IsA("Part") and v.Name == "Part" then
                if v:GetAttribute("Reserved") == game.Players.LocalPlayer.Name then
                    v.Size = Vector3.new(0.1, 0.1, 0.1)
                    v.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                end
            end
        end
        
        task.wait(2.5)
    end)
end

-- \\ Auto Farm Buttons // --

AutoFarmBox:AddToggle('KillAuraToggle', {
    Text = 'Kill Aura V1',
    Default = false,
    Tooltip = 'Enable or disable Kill Aura.',

    Callback = function(Value)
        SetupKillAura(Value)
    end
}):AddKeyPicker('KillKey', {
    Default = '',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'Kill Aura V1',
    NoUI = false,
})

AutoFarmBox:AddSlider('KillSize', {
    Text = 'Kill Aura Size',
    Default = 20,
    Min = 1,
    Max = 200,
    Rounding = 1,
    Compact = false,

    Callback = function(Value)
        KillAuraTable.KillAuraSize = Value
    end
})

AutoFarmBox:AddDivider()

AutoFarmBox:AddToggle('KillAura2Toggle', {
    Text = 'Kill Aura V2',
    Default = false,
    Tooltip = 'Enable or disable Kill Aura V2.',

    Callback = function(Value)
        SetupKillAura2(Value)
    end
}):AddKeyPicker('KillKey2', {
    Default = '',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'Kill Aura V2',
    NoUI = false,
})

AutoFarmBox:AddSlider('KillSize2', {
    Text = 'Kill Aura Size',
    Default = 200,
    Min = 1,
    Max = 2000,
    Rounding = 1,
    Compact = false,

    Callback = function(Value)
        KillAuraTable.KillAura2Size = Value
    end
})

AutoFarmBox:AddDivider()

AutoFarmBox:AddToggle('AutoBoxDelivery', {
    Text = 'Auto Box Delivery',
    Default = false,
    Tooltip = 'Stay on the box delivery npc to complete the script.',

    Callback = function(Value)
        AutoBox(Value)
    end
})

AutoFarmBox:AddDropdown('JobSelectorDropdown', {
    Values = {},
    Default = 0,
    Multi = false,

    Text = 'Jobs',
    Tooltip = 'Choose an job to start quest.',

    Callback = function(Value)

    end
})

AutoFarmBox:AddButton({
    Text = 'Refresh Jobs',

    Func = function()
        
    end,

    DoubleClick = false,
    Tooltip = 'Refresh Jobs of your Race.'
})

AutoFarmBox:AddButton({
    Text = 'Take Selected Quest',

    Func = function()
        
    end,

    DoubleClick = false,
    Tooltip = 'Take the selected quest.'
})

AutoFarmBox:AddButton({
    Text = 'Go to Quest',

    Func = function()
        
    end,

    DoubleClick = false,
    Tooltip = 'Tween to the quest location.'
})

-- \\ Combat Functions // --

local CombatTable = {
    AutoSwingConnection = nil,
    AutoEquipConnection = nil,
}

local function AutoSwing(Value)
    if not Value then
        if CombatTable.AutoSwingConnection then
            CombatTable.AutoSwingConnection:Disconnect()
            CombatTable.AutoSwingConnection = nil
        end

        return
    end

    CombatTable.AutoSwingConnection = RunService.Heartbeat:Connect(function()
        if LocalPlayer.Character:GetAttribute("CombatMode") then
            game:GetService("ReplicatedStorage").Bridgenet2Main.dataRemoteEvent:FireServer({{Module="M1"},"\5"})
        end
    end)
end

local function AutoEquip(Value)
    if not Value then
        if CombatTable.AutoEquipConnection then
            CombatTable.AutoEquipConnection:Disconnect()
            CombatTable.AutoEquipConnection = nil
        end

        return
    end

    if not LocalPlayer.Character:GetAttribute("CombatMode") then
        game:GetService("ReplicatedStorage").Bridgenet2Main.dataRemoteEvent:FireServer({{Module="Toggle",IsHolding=false},"\5"})
    end

    CombatTable.AutoEquipConnection = LocalPlayer.Character:GetAttributeChangedSignal("CombatMode"):Connect(function()
        if not LocalPlayer.Character:GetAttribute("CombatMode") then
            repeat
                game:GetService("ReplicatedStorage").Bridgenet2Main.dataRemoteEvent:FireServer({{Module="Toggle",IsHolding=false},"\5"})
                task.wait()
            until LocalPlayer.Character:GetAttribute("CombatMode")
        end
    end)
end

-- \\ Combat Buttons // --

CombatBox:AddToggle('AutoSwingToggle', {
    Text = 'Auto Swing',
    Default = false,
    Tooltip = 'Enable Auto Swing',

    Callback = function(Value)
        AutoSwing(Value)
    end
})

CombatBox:AddToggle('AutoEquipToggle', {
    Text = 'Auto Equip',
    Default = false,
    Tooltip = 'Enable Auto Equip',

    Callback = function(Value)
        AutoEquip(Value)
    end
})

-- \\ Misc Functions // --

local TableMisc = {
    NoFogConnection = nil,
    FullBrightConnection = nil,
}

local function NoFog(Value)
    if Value then
        if TableMisc.NoFogConnection then TableMisc.NoFogConnection:Disconnect() end
        TableMisc.NoFogConnection = RunService.RenderStepped:Connect(function()
            Lighting.FogEnd = 1e6
            Lighting.FogStart = 0

            local Atmos = Lighting:FindFirstChildOfClass("Atmosphere")
            if Atmos then
                Atmos.Density = 0
                Atmos.Haze = 0
            end
        end)
    else
        if TableMisc.NoFogConnection then
            TableMisc.NoFogConnection:Disconnect()
            TableMisc.NoFogConnection = nil
        end

        Lighting.FogEnd = 100000
        Lighting.FogStart = 0

        local Atmos = Lighting:FindFirstChildOfClass("Atmosphere")
        if Atmos then
            Atmos.Density = 0.45
            Atmos.Haze = 10
        end
    end
end

local function SetFullBright(Value)
    if Value then
        if TableMisc.FullBrightConnection then TableMisc.FullBrightConnection:Disconnect() end
        TableMisc.FullBrightConnection = RunService.RenderStepped:Connect(function()
            Lighting.Brightness = 6
            Lighting.ClockTime = 12
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        end)
    else
        if TableMisc.FullBrightConnection then
            TableMisc.FullBrightConnection:Disconnect()
            TableMisc.FullBrightConnection = nil
        end

        Lighting.Brightness = 4
        Lighting.ClockTime = 12
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(157, 202, 211)
    end
end

-- \\ Misc Buttons // --

MiscBox:AddToggle('ShowRC', {
    Text = 'Show RC Cells',
    Default = false,
    Tooltip = 'Enable RC Cells',

    Callback = function(Value)
        if LocalPlayer.PlayerGui.HUD:FindFirstChild("RC") then
            LocalPlayer.PlayerGui.HUD:FindFirstChild("RC"):Destroy()
            return 
        end

        local CashClone = LocalPlayer.PlayerGui.HUD.Cash:Clone()
        CashClone.Parent = LocalPlayer.PlayerGui.HUD
        CashClone.Name = "RC"
        CashClone.Text = math.floor(LocalPlayer.Character:GetAttribute("RCCells")) .. " RC"
        CashClone.Position = UDim2.new(0, 6, 0.98, 0)

        repeat
            CashClone.Text = math.floor(LocalPlayer.Character:GetAttribute("RCCells")) .. " RC"
            task.wait()
        until not CashClone.Parent
    end
})

MiscBox:AddToggle('NoFogToggle', {
    Text = 'No Fog',
    Default = false,
    Tooltip = 'You can see everything',

    Callback = function(Value)
        NoFog(Value)
    end
})

MiscBox:AddToggle('FullBrightToggle', {
    Text = 'No Bright',
    Default = false,
    Tooltip = 'You can see everything',

    Callback = function(Value)
        SetFullBright(Value)
    end
})

MiscBox:AddButton({
    Text = 'Suicide',
    
    Func = function()
        LocalPlayer.Character.Humanoid.Health = -999
    end,

    DoubleClick = false,
    Tooltip = 'Kill Yourself to Respawn'
})

-- \\ Teleport Buttons // --

TeleportBox:AddButton({
    Text = 'Rejoin Server',
    
    Func = function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end,

    DoubleClick = false,
    Tooltip = 'Rejoin on the same server'
})

TeleportBox:AddInput('JobIdTextBox', {
    Default = '',
    Numeric = false,
    Finished = false,

    Text = 'Server Job Id',
    Tooltip = 'Put a job id to enter on a specific server',

    Placeholder = '',

    Callback = function(Value)

    end
})

TeleportBox:AddButton({
    Text = 'Join Server',
    
    Func = function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, Options.JobIdTextBox.Value, LocalPlayer)
    end,

    DoubleClick = false,
    Tooltip = 'Join on the Job Id Server'
})

-- \\ Removals Functions // --

local TableRemoval = {
    NoclipConnection = nil,
    NoAnimConnection = nil,
}

local function ToggleNoclip(Value)
    if not Value then
        if TableRemoval.NoclipConnection then
            TableRemoval.NoclipConnection:Disconnect()
            TableRemoval.NoclipConnection = nil
        end

        Workspace.FakeHeads:FindFirstChild(LocalPlayer.Name .. "FakeHead").CanCollide = true
        
        for _, CharacterPart in pairs(LocalPlayer.Character:GetChildren()) do
            if CharacterPart:IsA("BasePart") then
                if CharacterPart.Name == "Head" or CharacterPart.Name == "Torso" then
                    CharacterPart.CanCollide = true
                end
            end
        end
        return
    end

    TableRemoval.NoclipConnection = RunService.Stepped:Connect(function()
        Workspace.FakeHeads:FindFirstChild(LocalPlayer.Name .. "FakeHead").CanCollide = false

        for _, CharacterPart in pairs(LocalPlayer.Character:GetDescendants()) do
            if CharacterPart:IsA("BasePart") or CharacterPart:IsA("Part") then
                CharacterPart.CanCollide = false
            end
        end
    end)
end

local function NoAnims(Value)
    if not Value then
        if TableRemoval.NoAnimConnection then
            TableRemoval.NoAnimConnection:Disconnect()
            TableRemoval.NoAnimConnection = nil
        end

        return
    end

    TableRemoval.NoAnimConnection = RunService.Heartbeat:Connect(function()
        for _, track in next, LocalPlayer.Character.Humanoid.Animator:GetPlayingAnimationTracks() do
            track:Stop();
            track:Destroy();
        end;
    end)
end

RemovalsBox:AddToggle('NoclipToggle', {
    Text = 'Noclip',
    Default = false,
    Tooltip = 'Enable Noclip',

    Callback = function(Value)
        ToggleNoclip(Value)
    end
}):AddKeyPicker('NoclipKey', {
    Default = '',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'Noclip',
    NoUI = false,
})

RemovalsBox:AddToggle('NoAnims', {
    Text = 'No Animations',
    Default = false,
    Tooltip = 'Enable No Animations',

    Callback = function(Value)
        NoAnims(Value)
    end
})

-- \\ Esp Function // --

local EspTable = {
    Highlight = false,
    Tracer = false,
    Box = false,
    Font = 2,
    Size = 13,

    PlayerEsp = false,
    PlayerEspDistance = 2000,
    PlayerEspColor = Color3.new(1, 1, 1),

    MobEsp = false,
    MobEspDistance = 2000,
    MobEspColor = Color3.new(1, 1, 1),
}

local function PlayerEsp(Target, TargetCharacter)
    local Humanoid = TargetCharacter:WaitForChild("Humanoid")
    local HumPart = TargetCharacter:WaitForChild("HumanoidRootPart")
    local Head = TargetCharacter:WaitForChild("Head")

    local Text = Drawing.new("Text")
    Text.Visible = false
    Text.Center = true
    Text.Outline = true
    Text.Font = 2
    Text.Color = Color3.new(255, 255, 255)
    Text.Size = 13

    local Text2 = Drawing.new("Text")
    Text2.Visible = false
    Text2.Center = true
    Text2.Outline = true
    Text2.Font = 2
    Text2.Color = Color3.new(255, 255, 255)
    Text2.Size = 13

    local Highlight = Instance.new("Highlight")
    Highlight.FillColor = Color3.new(255, 255, 255)
    Highlight.FillTransparency = 1
    Highlight.OutlineColor = Color3.new(255, 255, 255)
    Highlight.OutlineTransparency = 0

    Highlight.Enabled = false
    Highlight.Parent = TargetCharacter

    local Connection1
    local Connection2

    local function Disconnect()
        Text.Visible = false
        Text2.Visible = false
        Text:Remove()
        Text2:Remove()

        if Connection1 then
            Connection1:Disconnect()
            Connection1 = nil
        end
        if Connection2 then
            Connection2:Disconnect()
            Connection2 = nil
        end
    end

    Connection2 = TargetCharacter.AncestryChanged:Connect(function(_, Parent)
        if not Parent then
            Disconnect()
        end
    end)

    Connection1 = RunService.RenderStepped:Connect(function()
        if not TargetCharacter or not TargetCharacter.Parent then
            Disconnect()
            return
        end
    
        local ScreenPosition, OnScreen = CurrentCamera:WorldToViewportPoint(Head.Position)
        local distance = (HumPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
    
        if OnScreen and EspTable.PlayerEsp and distance <= EspTable.PlayerEspDistance then
            Text.Position = Vector2.new(ScreenPosition.X, ScreenPosition.Y - 40)
            Text.Text = Target.Name .. " [" .. math.floor(distance) .. "m]"
            Text.Visible = true
            Text.Color = EspTable.PlayerEspColor
            Text.Size = EspTable.Size
            Text.Font = EspTable.Font

            Text2.Position = Vector2.new(ScreenPosition.X, ScreenPosition.Y - 28)
            Text2.Text = "[" .. TargetCharacter.Race.Value .. "] " .. "[Rank: " .. TargetCharacter.Rank.Value .. "] [" .. math.floor(Humanoid.Health) .. "/" .. math.floor(Humanoid.MaxHealth) .. "]"
            Text2.Visible = true
            Text2.Color = EspTable.PlayerEspColor
            Text2.Size = EspTable.Size
            Text2.Font = EspTable.Font
    
            Highlight.Enabled = EspTable.Highlight
            Highlight.OutlineColor = EspTable.PlayerEspColor
        else
            Text.Visible = false
            Text2.Visible = false
            Highlight.Enabled = false
        end
    end)
end

local function MobEsp(Character)
    if not Character or not Character.Parent then return end

    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local HumPart = Character:FindFirstChild("HumanoidRootPart")

    if not Humanoid or not HumPart then return end

    local Highlight = Instance.new("Highlight")
    Highlight.FillColor = Color3.new(1, 1, 1)
    Highlight.FillTransparency = 1
    Highlight.OutlineColor = Color3.new(1, 1, 1)
    Highlight.OutlineTransparency = 0
    Highlight.Adornee = Character
    Highlight.Parent = game.CoreGui

    task.wait()

    local Text = Drawing.new("Text")
    Text.Visible = false
    Text.Center = true
    Text.Outline = true
    Text.Font = 2
    Text.Color = Color3.new(1, 1, 1)
    Text.Size = 13

    local function Disconnect()
        Text.Visible = false
        Text:Remove()
        Highlight:Destroy()
    end

    local function Update()
        if not Character.Parent then
            Disconnect()
            return
        end

        local ScreenPosition, OnScreen = workspace.CurrentCamera:WorldToViewportPoint(HumPart.Position)
        local LocalPlayer = game.Players.LocalPlayer
        local HumanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

        if not HumanoidRootPart then return end

        local distance = (HumPart.Position - HumanoidRootPart.Position).Magnitude
        local MobName = Character:GetAttribute("EntityType") .. " Mob"

        if OnScreen and EspTable.MobEsp and distance <= EspTable.MobEspDistance and (not IsPet or EspTable.ShowPet) then
            Text.Position = Vector2.new(ScreenPosition.X, ScreenPosition.Y)
            Text.Text = string.format("%s %d/%d [%dm]", MobName, Humanoid.Health, Humanoid.MaxHealth, distance)
            Text.Visible = true
            Text.Color = IsPet and EspTable.PetEspColor or EspTable.MobEspColor
            Text.Size = EspTable.Size
            Text.Font = EspTable.Font

            Highlight.Adornee = Character
            Highlight.Enabled = EspTable.Highlight
            Highlight.OutlineColor = IsPet and EspTable.PetEspColor or EspTable.MobEspColor
        else
            Highlight.Enabled = false
            Text.Visible = false
        end
    end

    local Connections = {}

    table.insert(Connections, game:GetService("RunService").RenderStepped:Connect(Update))

    table.insert(Connections, Character.AncestryChanged:Connect(function(_, parent)
        if not parent then
            for _, conn in ipairs(Connections) do conn:Disconnect() end
            Disconnect()
        end
    end))
end

local function BoxEsp(Child)
    if not Child or not Child.Parent then return end
    
    local Text = Drawing.new("Text")
    Text.Visible = false
    Text.Center = true
    Text.Outline = true
    Text.Font = 2
    Text.Color = Color3.new(1, 1, 1)
    Text.Size = 13
    
    local Connection
    
    Connection = game:GetService("RunService").RenderStepped:Connect(function()
        if not Child or not Child.Parent then 
            Text:Remove()
            Connection:Disconnect()
            return
        end
        
        local PrimaryPart = Child
        if PrimaryPart then
            local GiftPos, OnScreen = workspace.CurrentCamera:WorldToViewportPoint(PrimaryPart.Position)
            
            if OnScreen then
                Text.Position = Vector2.new(GiftPos.X, GiftPos.Y - 20)
                Text.Text = Child.Name
                Text.Visible = true
            else
                Text.Visible = false
            end
        else
            Text.Visible = false
        end
    end)
end

-- \\ Esp Buttons // --

local ConfigTab = Tabs.Esp:AddRightGroupbox('Configuration')

ConfigTab:AddToggle('BoxToggle', {
    Text = 'Box',
    Default = false,
    Tooltip = 'Enable Box on Alive things',
    Callback = function(Value)
        EspTable.Box = Value
    end
})

ConfigTab:AddToggle('TracerToggle', {
    Text = 'Tracer',
    Default = false,
    Tooltip = 'Enable Tracer on Alive things',
    Callback = function(Value)
        EspTable.Tracer = Value
    end
})

ConfigTab:AddToggle('HighlightToggle', {
    Text = 'Highlight',
    Default = false,
    Tooltip = 'Enable Highlight on Alive things',
    Callback = function(Value)
        EspTable.Highlight = Value
    end
})

ConfigTab:AddSlider('EspSize', {
    Text = 'Esp Text Size',
    Default = 13,
    Min = 10,
    Max = 30,
    Rounding = 1,
    Compact = true,

    Callback = function(Value)
        EspTable.Size = Value
    end
})

ConfigTab:AddDropdown('FontDropdown', {
    Values = {'UI', 'System', 'Plex', 'Monospace'},
    Default = 3,
    Multi = false,

    Text = 'Esp Font',
    Tooltip = 'Choose a font for your esp',

    Callback = function(Value)
        local Valuess = {
            ["UI"] = 0,
            ["System"] = 1,
            ["Plex"] = 2,
            ["Monospace"] = 3,
        }

        EspTable.Font = Valuess[Value]
    end
})

local EspTab = Tabs.Esp:AddLeftGroupbox('Visual')

EspTab:AddToggle('PlayerEsp', {
    Text = 'Player Esp',
    Default = false,
    Tooltip = 'Track players around you',
    Callback = function(Value)
        EspTable.PlayerEsp = Value
    end
}):AddColorPicker('PlayerEspColor', {
    Default = Color3.new(255, 255, 255),
    Title = 'PlayerEspColor',
    Transparency = 0,

    Callback = function(Value)
        EspTable.PlayerEspColor = Value
    end
})

EspTab:AddSlider('PlayerEspDistance', {
    Text = 'Player Esp Distance',
    Default = 2000,
    Min = 100,
    Max = 10000,
    Rounding = 1,
    Compact = false,

    Callback = function(Value)
        EspTable.PlayerEspDistance = Value
    end
})

EspTab:AddDivider()

EspTab:AddToggle('MobEsp', {
    Text = 'Mob Esp',
    Default = false,
    Tooltip = 'Track Mobs around you',
    Callback = function(Value)
        EspTable.MobEsp = Value
    end
}):AddColorPicker('MobEspColor', {
    Default = Color3.new(255, 255, 255),
    Title = 'MobEspColor',
    Transparency = 0,

    Callback = function(Value)
        EspTable.MobEspColor = Value
    end
})

EspTab:AddSlider('MobEspDistance', {
    Text = 'Mob Esp Distance',
    Default = 2000,
    Min = 100,
    Max = 10000,
    Rounding = 1,
    Compact = false,

    Callback = function(Value)
        EspTable.MobEspDistance = Value
    end
})

local function PlayerAdded(P)
    if P.Character then
        PlayerEsp(P, P.Character)
    end
    P.CharacterAdded:Connect(function(Ch)
        PlayerEsp(P, Ch)
    end)
end

for _, P in next, Players:GetPlayers() do
    if P ~= LocalPlayer then
        PlayerAdded(P)
    end
end

for _, Child in pairs(workspace.Entities:GetChildren()) do
    if Child:IsA("Model") and Child:GetAttribute("EntityID") then
        MobEsp(Child)
    end

    if Child:IsA("Model") and Child.Name == "giftbox_blend" then
        BoxEsp(Child)
    end
end

workspace.Entities.ChildAdded:Connect(function(Child)
    if Child:IsA("Model") and Child:GetAttribute("EntityID") then
        MobEsp(Child)
    end
end)

workspace.ChildAdded:Connect(function(Child)
    if Child:IsA("Model") and Child.Name == "giftbox_blend" then
        BoxEsp(Child)
    end
end)

Players.PlayerAdded:Connect(PlayerAdded)

Library:OnUnload(function()
    Library.Unloaded = true
end)

local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

Library.KeybindFrame.Visible = true;

MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()

SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

ThemeManager:SetFolder('MyScriptHub')
SaveManager:SetFolder('MyScriptHub/specific-game')

SaveManager:BuildConfigSection(Tabs['UI Settings'])

ThemeManager:ApplyToTab(Tabs['UI Settings'])

SaveManager:LoadAutoloadConfig()
