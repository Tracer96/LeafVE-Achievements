LeafVE_DB = LeafVE_DB or {}
LeafVE_GlobalDB = LeafVE_GlobalDB or {}

LeafVE = LeafVE or {}
LeafVE.name = "LeafVillageLegends"
LeafVE.prefix = "LeafVE"
LeafVE.version = "10.7"

local SEP = "\31"
local SECONDS_PER_DAY = 86400
local SECONDS_PER_HOUR = 3600
local GROUP_MIN_TIME = 300
local GROUP_COOLDOWN = 3600
local GUILD_ROSTER_CACHE_DURATION = 30
local SHOUTOUT_MAX_PER_DAY = 2

local LEAF_EMBLEM = "Interface\\AddOns\\LeafVillageLegends\\media\\leaf.tga"
local LEAF_FALLBACK = "Interface\\Icons\\INV_Misc_Herb_01"

local PVP_RANK_ICONS = {
  [1] = "Interface\\PvPRankBadges\\PvPRank15",
  [2] = "Interface\\PvPRankBadges\\PvPRank14",
  [3] = "Interface\\PvPRankBadges\\PvPRank13",
}

local CLASS_ICONS = {
  WARRIOR = "Interface\\Icons\\Ability_Warrior_SavageBlow",
  PALADIN = "Interface\\Icons\\Spell_Holy_SealOfMight",
  HUNTER = "Interface\\Icons\\Ability_Hunter_AimedShot",
  ROGUE = "Interface\\Icons\\Ability_Rogue_Eviscerate",
  PRIEST = "Interface\\Icons\\Spell_Holy_PowerWordShield",
  SHAMAN = "Interface\\Icons\\Spell_Nature_LightningShield",
  MAGE = "Interface\\Icons\\Spell_Frost_IceStorm",
  WARLOCK = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
  DRUID = "Interface\\Icons\\Spell_Nature_Regeneration",
}

local CLASS_COLORS = {
  WARRIOR = {0.78, 0.61, 0.43}, PALADIN = {0.96, 0.55, 0.73}, HUNTER = {0.67, 0.83, 0.45},
  ROGUE = {1.00, 0.96, 0.41}, PRIEST = {1.00, 1.00, 1.00}, SHAMAN = {0.14, 0.35, 1.00},
  MAGE = {0.41, 0.80, 0.94}, WARLOCK = {0.58, 0.51, 0.79}, DRUID = {1.00, 0.49, 0.04},
}

local THEME = {
  bg = {0.05, 0.05, 0.06, 0.96}, insetBG = {0.02, 0.02, 0.03, 0.88},
  white = {0.96, 0.96, 0.96, 1.00}, leaf = {0.20, 0.78, 0.35, 1.00},
  leaf2 = {0.12, 0.55, 0.26, 1.00}, gold = {1.00, 0.82, 0.20, 1.00},
  border = {0.28, 0.28, 0.30, 1.00}, soft = {0.18, 0.18, 0.20, 1.00},
}

BADGES = {
  -- Social & Participation
  {id = "first_steps", name = "First Steps", desc = "Join the guild", icon = "Interface\\Icons\\INV_Misc_Medal_01"},
  {id = "team_player", name = "Team Player", desc = "Run 50 dungeons with guildmates", icon = "Interface\\Icons\\INV_Banner_02"},
  {id = "generous_spirit", name = "Generous Spirit", desc = "Donate 1000g to the guild bank", icon = "Interface\\Icons\\Spell_Holy_GreaterBlessingofKings"},
  {id = "social_butterfly", name = "Social Butterfly", desc = "Complete 100 guild groups", icon = "Interface\\Icons\\INV_Misc_Star_01"},
  
  -- Combat & Achievement
  {id = "dungeon_master", name = "Dungeon Master", desc = "Complete all level 60 dungeons", icon = "Interface\\Icons\\INV_Crown_01"},
  {id = "raid_veteran", name = "Raid Veteran", desc = "Clear Molten Core", icon = "Interface\\Icons\\Spell_Fire_Immolation"},
  {id = "pvp_champion", name = "PvP Champion", desc = "Reach Rank 10", icon = "Interface\\Icons\\Ability_Warrior_ShieldWall"},
  {id = "world_boss_slayer", name = "World Boss Slayer", desc = "Kill all world bosses", icon = "Interface\\Icons\\INV_Misc_Head_Dragon_Black"},
  
  -- Dedication & Time
  {id = "dedicated", name = "Dedicated", desc = "Login 30 days in a row", icon = "Interface\\Icons\\INV_Misc_Medal_02"},
  {id = "veteran", name = "Veteran", desc = "Be in the guild for 1 year", icon = "Interface\\Icons\\INV_Misc_Trophy_01"},
  {id = "always_online", name = "Always Online", desc = "500 hours played while guilded", icon = "Interface\\Icons\\Spell_Arcane_ArcaneResilience"},
  
  -- Crafting & Economy
  {id = "master_crafter", name = "Master Crafter", desc = "Reach max level in 3 professions", icon = "Interface\\Icons\\INV_Hammer_04"},
  {id = "market_tycoon", name = "Market Tycoon", desc = "Earn 10,000g through the AH", icon = "Interface\\Icons\\INV_Misc_Trophy_03"},
  {id = "material_provider", name = "Material Provider", desc = "Donate 1000 materials to guild", icon = "Interface\\Icons\\INV_Misc_EngGizmos_02"},
  
  -- Support & Leadership
  {id = "guild_mentor", name = "Guild Mentor", desc = "Help 10 new members reach 60", icon = "Interface\\Icons\\Spell_Holy_AuraOfLight"},
  {id = "recruitment_hero", name = "Recruitment Hero", desc = "Recruit 10 active members", icon = "Interface\\Icons\\INV_Banner_03"},
  {id = "officer_excellence", name = "Officer Excellence", desc = "Serve as officer for 6 months", icon = "Interface\\Icons\\INV_Crown_02"},
  
  -- Special & Elite
  {id = "guild_legend", name = "Guild Legend", desc = "Complete all other badges", icon = "Interface\\Icons\\INV_Misc_Head_Dragon_Red"},
  {id = "server_first", name = "Server First", desc = "Guild achieves a server first", icon = "Interface\\Icons\\INV_Misc_Star_02"},
  {id = "hardcore_survivor", name = "Hardcore Survivor", desc = "Reach 60 without dying", icon = "Interface\\Icons\\INV_Misc_Bone_Skull_01"},
}

LeafVE.guildRosterCache = {}
LeafVE.guildRosterCacheTime = 0
LeafVE.currentGroupStart = nil
LeafVE.currentGroupMembers = {}
LeafVE.notificationQueue = {}
LeafVE.errorLog = {}
LeafVE.maxErrors = 50

local function SetSize(f, w, h)
  if not f then return end
  if f.SetSize then f:SetSize(w, h) 
  else if w then f:SetWidth(w) end if h then f:SetHeight(h) end end
end

local function Print(msg)
  if DEFAULT_CHAT_FRAME then
    DEFAULT_CHAT_FRAME:AddMessage("|cFF2DD35CLeafVE|r: "..tostring(msg))
  end
end

local function Now() return time() end
local function Lower(s) return s and string.lower(s) or "" end
local function Trim(s) return (string.gsub(s or "", "^%s*(.-)%s*$", "%1")) end

local function ShortName(name)
  if not name then return nil end
  local dash = string.find(name, "-")
  if dash then return string.sub(name, 1, dash-1) end
  return name
end

local function FormatAchievementName(achID)
  if not achID then return "Unknown" end
  local formatted = string.gsub(achID, "raid_", "")
  formatted = string.gsub(formatted, "dungeon_", "")
  formatted = string.gsub(formatted, "pvp_", "")
  formatted = string.gsub(formatted, "mc_", "MC: ")
  formatted = string.gsub(formatted, "bwl_", "BWL: ")
  formatted = string.gsub(formatted, "aq40_", "AQ40: ")
  formatted = string.gsub(formatted, "naxx_", "Naxx: ")
  formatted = string.gsub(formatted, "onyxia_", "Onyxia: ")
  formatted = string.gsub(formatted, "zg_", "ZG: ")
  formatted = string.gsub(formatted, "_", " ")
  local first = string.sub(formatted, 1, 1)
  formatted = string.upper(first) .. string.sub(formatted, 2)
  return formatted
end

local function InGuild() return (IsInGuild and IsInGuild()) and true or false end

local function DayKeyFromTS(ts)
  local d = date("*t", ts)
  return string.format("%04d-%02d-%02d", d.year, d.month, d.day)
end

local function DayKey(ts) return DayKeyFromTS(ts or Now()) end

local function WeekStartTS(ts)
  local d = date("*t", ts or Now())
  d.hour, d.min, d.sec = 0, 0, 0
  local midnight = time(d)
  local wday = d.wday or 1
  
  -- Calculate days since last Tuesday (wday 3 = Tuesday)
  -- Sunday=1, Monday=2, Tuesday=3, Wednesday=4, etc.
  local daysSinceTuesday
  if wday >= 3 then
    daysSinceTuesday = wday - 3  -- Wed=1, Thu=2, Fri=3, Sat=4, Sun=5, Mon=6
  else
    daysSinceTuesday = wday + 4  -- Sun=5, Mon=6
  end
  
  return midnight - daysSinceTuesday * SECONDS_PER_DAY
end

local function GetWeekDateRange()
  local startTS = WeekStartTS(Now())
  local endTS = startTS + (6 * SECONDS_PER_DAY)
  return date("%m/%d", startTS).." - "..date("%m/%d", endTS)
end

local function SkinFrameModern(f)
  f:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = {left = 4, right = 4, top = 4, bottom = 4}
  })
  f:SetBackdropColor(THEME.bg[1], THEME.bg[2], THEME.bg[3], THEME.bg[4])
  f:SetBackdropBorderColor(THEME.border[1], THEME.border[2], THEME.border[3], THEME.border[4])
  if not f._accentStripe then
    local stripe = f:CreateTexture(nil, "BORDER")
    stripe:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -44)
    stripe:SetPoint("TOPRIGHT", f, "TOPRIGHT", -10, -44)
    stripe:SetHeight(2)
    stripe:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    stripe:SetVertexColor(THEME.leaf[1], THEME.leaf[2], THEME.leaf[3], 0.85)
    f._accentStripe = stripe
  end
end

local function CreateInset(parent)
  local inset = CreateFrame("Frame", nil, parent)
  inset:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = {left = 3, right = 3, top = 3, bottom = 3}
  })
  inset:SetBackdropColor(THEME.insetBG[1], THEME.insetBG[2], THEME.insetBG[3], THEME.insetBG[4])
  inset:SetBackdropBorderColor(THEME.soft[1], THEME.soft[2], THEME.soft[3], 1)
  return inset
end

local function CreateGradientInset(parent)
  local inset = CreateFrame("Frame", nil, parent)
  inset:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = {left = 3, right = 3, top = 3, bottom = 3}
  })
  inset:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
  inset:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
  local gradient = inset:CreateTexture(nil, "BACKGROUND")
  gradient:SetPoint("TOPLEFT", inset, "TOPLEFT", 4, -4)
  gradient:SetPoint("BOTTOMRIGHT", inset, "BOTTOMRIGHT", -4, 4)
  gradient:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
  gradient:SetGradientAlpha("VERTICAL", 0.2, 0.2, 0.22, 1, 0.08, 0.08, 0.1, 1)
  return inset
end

local function MakeResizeHandle(f)
  if f._resize then return end
  if f.SetResizable then f:SetResizable(true) end
  if f.SetMinResize then f:SetMinResize(950, 600) end
  if f.SetMaxResize then f:SetMaxResize(1400, 1000) end
  if f.SetClampedToScreen then f:SetClampedToScreen(true) end
  local grip = CreateFrame("Button", nil, f)
  SetSize(grip, 16, 16)
  grip:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -6, 6)
  local tex = grip:CreateTexture(nil, "ARTWORK")
  tex:SetAllPoints(grip)
  tex:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
  grip:SetNormalTexture(tex)
  grip:SetScript("OnMouseDown", function() if f.StartSizing then f:StartSizing("BOTTOMRIGHT") end end)
  grip:SetScript("OnMouseUp", function() 
    if f.StopMovingOrSizing then 
      f:StopMovingOrSizing()
      local w, h = f:GetWidth(), f:GetHeight()
      if w < 950 then f:SetWidth(950) w = 950 end
      if w > 1400 then f:SetWidth(1400) w = 1400 end
      if h < 600 then f:SetHeight(600) h = 600 end
      if h > 1000 then f:SetHeight(1000) h = 1000 end
      if LeafVE_DB and LeafVE_DB.ui then LeafVE_DB.ui.w = w LeafVE_DB.ui.h = h end
    end 
  end)
  f._resize = grip
end

local function SkinButtonAccent(btn)
  if not btn then return end
  btn:SetScript("OnEnter", function()
    local fs = btn.GetFontString and btn:GetFontString()
    if fs then fs:SetTextColor(THEME.leaf[1], THEME.leaf[2], THEME.leaf[3]) end
  end)
  btn:SetScript("OnLeave", function()
    local fs = btn.GetFontString and btn:GetFontString()
    if fs then fs:SetTextColor(1, 1, 1) end
  end)
end

local function EnsureDB()
  if not LeafVE_DB then LeafVE_DB = {} end
  if not LeafVE_DB.options then LeafVE_DB.options = {} end
  if not LeafVE_DB.ui then LeafVE_DB.ui = {} end
  if not LeafVE_DB.global then LeafVE_DB.global = {} end
  if not LeafVE_DB.alltime then LeafVE_DB.alltime = {} end
  if not LeafVE_DB.season then LeafVE_DB.season = {} end
  if not LeafVE_DB.loginTracking then LeafVE_DB.loginTracking = {} end
  if not LeafVE_DB.groupCooldowns then LeafVE_DB.groupCooldowns = {} end
  if not LeafVE_DB.shoutouts then LeafVE_DB.shoutouts = {} end
  if not LeafVE_DB.pointHistory then LeafVE_DB.pointHistory = {} end
  if not LeafVE_DB.badges then LeafVE_DB.badges = {} end
  if not LeafVE_DB.attendance then LeafVE_DB.attendance = {} end
  if not LeafVE_DB.weeklyRecap then LeafVE_DB.weeklyRecap = {} end
  if not LeafVE_DB.loginStreaks then LeafVE_DB.loginStreaks = {} end
  if not LeafVE_DB.persistentRoster then LeafVE_DB.persistentRoster = {} end
  if LeafVE_DB.ui.w == nil then LeafVE_DB.ui.w = 950 end
  if LeafVE_DB.ui.h == nil then LeafVE_DB.ui.h = 660 end
  if LeafVE_DB.options.officerRankThreshold == nil then LeafVE_DB.options.officerRankThreshold = 4 end
  if LeafVE_DB.options.showOfflineMembers == nil then LeafVE_DB.options.showOfflineMembers = true end
  if LeafVE_DB.options.minimapPos == nil then LeafVE_DB.options.minimapPos = 220 end
  if LeafVE_DB.options.enableNotifications == nil then LeafVE_DB.options.enableNotifications = true end
  if LeafVE_DB.options.notificationSound == nil then LeafVE_DB.options.notificationSound = true end
  if not LeafVE_GlobalDB then LeafVE_GlobalDB = {} end
  if not LeafVE_GlobalDB.playerNotes then LeafVE_GlobalDB.playerNotes = {} end
  if not LeafVE_GlobalDB.achievementCache then LeafVE_GlobalDB.achievementCache = {} end
end

function LeafVE:AddToHistory(playerName, pointType, amount, reason)
  EnsureDB() playerName = ShortName(playerName) if not playerName then return end
  if not LeafVE_DB.pointHistory[playerName] then LeafVE_DB.pointHistory[playerName] = {} end
  table.insert(LeafVE_DB.pointHistory[playerName], {timestamp = Now(), type = pointType, amount = amount, reason = reason or "Unknown"})
  while table.getn(LeafVE_DB.pointHistory[playerName]) > 500 do table.remove(LeafVE_DB.pointHistory[playerName], 1) end
end

function LeafVE:AwardBadge(playerName, badgeId)
  EnsureDB()
  playerName = ShortName(playerName)
  
  if not playerName then
    Print("ERROR: Invalid player name")
    return
  end
  
  -- Check if badge exists
  local badgeExists = false
  for i = 1, table.getn(BADGES) do
    if BADGES[i].id == badgeId then
      badgeExists = true
      break
    end
  end
  
  if not badgeExists then
    Print("ERROR: Badge '"..badgeId.."' does not exist")
    return
  end
  
  -- Initialize player badges table if needed
  if not LeafVE_DB.badges[playerName] then
    LeafVE_DB.badges[playerName] = {}
  end
  
  -- Check if already earned
  if LeafVE_DB.badges[playerName][badgeId] then
    Print(playerName.." already has badge: "..badgeId)
    return
  end
  
  -- Award the badge
  LeafVE_DB.badges[playerName][badgeId] = time()
  Print("Badge awarded to "..playerName..": "..badgeId)
  
  -- **NEW: Broadcast badges immediately after awarding**
  local me = ShortName(UnitName("player"))
  if me and playerName == me then
    self:BroadcastBadges()
  end
  
  -- Refresh UI if player card is showing this player
  if LeafVE.UI.cardCurrentPlayer == playerName then
    LeafVE.UI:UpdateCardRecentBadges(playerName)
  end
  
  -- Refresh badges tab if open
  if LeafVE.UI.panels and LeafVE.UI.panels.badges and LeafVE.UI.panels.badges:IsVisible() then
    LeafVE.UI:RefreshBadges()
  end
end

function LeafVE:GetHistory(playerName, limit)
  EnsureDB() playerName = ShortName(playerName) if not playerName then return {} end
  local history = LeafVE_DB.pointHistory[playerName] or {} local sorted = {}
  for i = table.getn(history), 1, -1 do table.insert(sorted, history[i]) if limit and table.getn(sorted) >= limit then break end end
  return sorted
end

function LeafVE:ShowNotification(title, message, icon, color)
  if not LeafVE_DB.options.enableNotifications then return end
  table.insert(self.notificationQueue, {title = title, message = message, icon = icon or LEAF_EMBLEM, color = color or THEME.leaf, timestamp = Now()})
end

function LeafVE:CreateToastFrame()
  if self.toastFrame then return end
  local toast = CreateFrame("Frame", "LeafVEToast", UIParent)
  toast:SetWidth(300) toast:SetHeight(80) toast:SetPoint("TOP", UIParent, "TOP", 0, -100) toast:SetFrameStrata("TOOLTIP") toast:SetAlpha(0)
  toast:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = {left = 4, right = 4, top = 4, bottom = 4}})
  toast:SetBackdropColor(0.05, 0.05, 0.06, 0.95) toast:SetBackdropBorderColor(THEME.leaf[1], THEME.leaf[2], THEME.leaf[3], 1)
  local icon = toast:CreateTexture(nil, "ARTWORK") icon:SetWidth(48) icon:SetHeight(48) icon:SetPoint("LEFT", toast, "LEFT", 12, 0) toast.icon = icon
  local title = toast:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge") title:SetPoint("TOPLEFT", icon, "TOPRIGHT", 10, -5) title:SetPoint("RIGHT", toast, "RIGHT", -12, 0) title:SetJustifyH("LEFT") toast.title = title
  local message = toast:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall") message:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -5) message:SetPoint("RIGHT", toast, "RIGHT", -12, 0) message:SetJustifyH("LEFT") toast.message = message
  toast:Hide() self.toastFrame = toast
end

function LeafVE:ProcessNotifications()
  if table.getn(self.notificationQueue) == 0 then return end
  if not self.toastFrame then self:CreateToastFrame() end
  if self.toastFrame:IsShown() then return end
  local notif = table.remove(self.notificationQueue, 1)
  self.toastFrame.icon:SetTexture(notif.icon) if not self.toastFrame.icon:GetTexture() then self.toastFrame.icon:SetTexture(LEAF_FALLBACK) end
  self.toastFrame.title:SetText(notif.title) self.toastFrame.title:SetTextColor(notif.color[1], notif.color[2], notif.color[3])
  self.toastFrame.message:SetText(notif.message)
  if LeafVE_DB.options.notificationSound then PlaySound("AuctionWindowOpen") end
  self.toastFrame:Show()
  local fadeIn = 0 local fadeInFrame = CreateFrame("Frame")
  fadeInFrame:SetScript("OnUpdate", function()
    fadeIn = fadeIn + arg1
    if fadeIn >= 0.3 then self.toastFrame:SetAlpha(1) fadeInFrame:Hide()
      local hold = 0 local holdFrame = CreateFrame("Frame")
      holdFrame:SetScript("OnUpdate", function()
        hold = hold + arg1
        if hold >= 4 then holdFrame:Hide()
          local fadeOut = 0 local fadeOutFrame = CreateFrame("Frame")
          fadeOutFrame:SetScript("OnUpdate", function()
            fadeOut = fadeOut + arg1
            if fadeOut >= 0.3 then self.toastFrame:SetAlpha(0) self.toastFrame:Hide() fadeOutFrame:Hide()
            else self.toastFrame:SetAlpha(1 - (fadeOut / 0.3)) end
          end)
        end
      end)
    else self.toastFrame:SetAlpha(fadeIn / 0.3) end
  end)
end

function LeafVE:CheckAndAwardBadge(playerName, badgeId)
  EnsureDB() playerName = ShortName(playerName) if not playerName then return end
  if not LeafVE_DB.badges[playerName] then LeafVE_DB.badges[playerName] = {} end
  if LeafVE_DB.badges[playerName][badgeId] then return false end
  LeafVE_DB.badges[playerName][badgeId] = Now()
  local badge = nil
  for i = 1, table.getn(MILESTONE_BADGES) do
    if MILESTONE_BADGES[i].id == badgeId then badge = MILESTONE_BADGES[i] break end
  end
  if badge then
    self:ShowNotification("Badge Earned!", badge.name..": "..badge.desc, badge.icon, THEME.gold)
    local me = ShortName(UnitName("player"))
    if me and Lower(playerName) == Lower(me) then Print("|cFFFFD700Badge Earned:|r "..badge.name.." - "..badge.desc) end
  end
  return true
end

function LeafVE:CheckBadgeMilestones(playerName)
  EnsureDB() playerName = ShortName(playerName) if not playerName then return end
  local alltime = LeafVE_DB.alltime[playerName] or {L = 0, G = 0, S = 0}
  local totalPoints = (alltime.L or 0) + (alltime.G or 0) + (alltime.S or 0)
  if alltime.L >= 1 then self:CheckAndAwardBadge(playerName, "first_login") end
  if alltime.G >= 1 then self:CheckAndAwardBadge(playerName, "first_group") end
  if alltime.G >= 10 then self:CheckAndAwardBadge(playerName, "group_10") end
  if alltime.G >= 50 then self:CheckAndAwardBadge(playerName, "group_50") end
  if totalPoints >= 25 then self:CheckAndAwardBadge(playerName, "total_25") end
  if totalPoints >= 100 then self:CheckAndAwardBadge(playerName, "total_100") end
  if totalPoints >= 500 then self:CheckAndAwardBadge(playerName, "total_500") end
  local attendance = LeafVE_DB.attendance[playerName] or {}
  local attendCount = table.getn(attendance)
  if attendCount >= 10 then self:CheckAndAwardBadge(playerName, "attendance_10") end
  if attendCount >= 50 then self:CheckAndAwardBadge(playerName, "attendance_50") end
end

function LeafVE:GetPlayerBadges(playerName)
  EnsureDB() playerName = ShortName(playerName) if not playerName then return {} end
  local playerBadges = LeafVE_DB.badges[playerName] or {} local badges = {}
  for i = 1, table.getn(MILESTONE_BADGES) do
    local badge = MILESTONE_BADGES[i]
    if playerBadges[badge.id] then table.insert(badges, {badge = badge, earnedAt = playerBadges[badge.id]}) end
  end
  table.sort(badges, function(a, b) return a.earnedAt > b.earnedAt end)
  return badges
end

function LeafVE:TrackAttendance()
  local inRaid = GetNumRaidMembers() > 0
  if not inRaid then return end
  EnsureDB() local me = ShortName(UnitName("player")) if not me then return end
  if not LeafVE_DB.attendance[me] then LeafVE_DB.attendance[me] = {} end
  local today = DayKey() local found = false
  for i = 1, table.getn(LeafVE_DB.attendance[me]) do
    if LeafVE_DB.attendance[me][i].date == today then found = true break end
  end
  if not found then
    table.insert(LeafVE_DB.attendance[me], {date = today, timestamp = Now()})
    self:AddToHistory(me, "A", 1, "Raid attendance")
    self:CheckBadgeMilestones(me)
  end
end

function LeafVE:AddPoints(playerName, pointType, amount)
  EnsureDB() playerName = ShortName(playerName) if not playerName then return end
  amount = amount or 1 local day = DayKey()
  if not LeafVE_DB.global[day] then LeafVE_DB.global[day] = {} end
  if not LeafVE_DB.global[day][playerName] then LeafVE_DB.global[day][playerName] = {L = 0, G = 0, S = 0} end
  LeafVE_DB.global[day][playerName][pointType] = (LeafVE_DB.global[day][playerName][pointType] or 0) + amount
  if not LeafVE_DB.alltime[playerName] then LeafVE_DB.alltime[playerName] = {L = 0, G = 0, S = 0} end
  LeafVE_DB.alltime[playerName][pointType] = (LeafVE_DB.alltime[playerName][pointType] or 0) + amount
  if not LeafVE_DB.season[playerName] then LeafVE_DB.season[playerName] = {L = 0, G = 0, S = 0} end
  LeafVE_DB.season[playerName][pointType] = (LeafVE_DB.season[playerName][pointType] or 0) + amount
  local me = ShortName(UnitName("player"))
  if me and Lower(playerName) == Lower(me) then
    local typeNames = {L = "Login", G = "Group", S = "Shoutout"}
    self:ShowNotification("Points Earned!", string.format("+%d %s Point%s", amount, typeNames[pointType] or "?", amount > 1 and "s" or ""), LEAF_EMBLEM, THEME.leaf)
  end
  self:CheckBadgeMilestones(playerName)
end

function LeafVE:CheckDailyLogin()
  EnsureDB() local playerName = ShortName(UnitName("player")) if not playerName then return end
  local today = DayKey()
  if not LeafVE_DB.loginTracking[playerName] then LeafVE_DB.loginTracking[playerName] = {} end
  if LeafVE_DB.loginTracking[playerName][today] then return end
  self:AddPoints(playerName, "L", 1)
  self:AddToHistory(playerName, "L", 1, "Daily login")
  LeafVE_DB.loginTracking[playerName][today] = true
  Print("Daily login point awarded! (+1 L)")
end

function LeafVE:UpdateGuildRosterCache()
  local now = Now()
  if now - self.guildRosterCacheTime < GUILD_ROSTER_CACHE_DURATION then return end
  
  self.guildRosterCache = {} 
  if not InGuild() then return end
  
  EnsureDB()
  
  if GuildRoster then GuildRoster(1) end
  local n = GetNumGuildMembers and GetNumGuildMembers() or 0
  
  -- Get currently online members
  for i = 1, n do
    local name, rank, rankIndex, level, class, zone, note, officernote, online, status = GetGuildRosterInfo(i)
    name = ShortName(name)
    if name then
      local isOnline = false
      if online then 
        if type(online) == "number" then 
          isOnline = (online == 1) 
        else 
          isOnline = (online == true) 
        end 
      end
      
      local memberData = {
        name = name, 
        rank = rank, 
        rankIndex = rankIndex, 
        level = level, 
        class = class, 
        zone = zone, 
        note = note, 
        officernote = officernote, 
        online = isOnline, 
        status = status,
        lastSeen = now
      }
      
      self.guildRosterCache[Lower(name)] = memberData
      
      -- Store in persistent roster
      LeafVE_DB.persistentRoster[Lower(name)] = memberData
    end
  end
  
  -- Add offline members from persistent roster
  if LeafVE_DB.options.showOfflineMembers then
    for lowerName, memberData in pairs(LeafVE_DB.persistentRoster) do
      if not self.guildRosterCache[lowerName] then
        -- This member is offline, add them with offline flag
        local offlineCopy = {}
        for k, v in pairs(memberData) do
          offlineCopy[k] = v
        end
        offlineCopy.online = false
        offlineCopy.zone = "Offline"
        
        self.guildRosterCache[lowerName] = offlineCopy
      end
    end
  end
  
  self.guildRosterCacheTime = now
end

function LeafVE:GetGuildInfo(playerName)
  if not InGuild() then return nil end
  self:UpdateGuildRosterCache() playerName = ShortName(playerName) if not playerName then return nil end
  return self.guildRosterCache[Lower(playerName)]
end

function LeafVE:IsOfficer()
  if CanEditOfficerNote and CanEditOfficerNote() then return true end
  if CanGuildInvite and CanGuildInvite() then return true end
  return false
end

function LeafVE:GetGroupGuildies()
  if not InGuild() then return {} end
  self:UpdateGuildRosterCache()
  local guildies = {} local numMembers = GetNumRaidMembers() local isRaid = numMembers > 0
  if not isRaid then numMembers = GetNumPartyMembers() end
  if numMembers == 0 then return {} end
  for i = 1, numMembers do
    local unit = isRaid and "raid"..i or "party"..i
    if UnitExists(unit) then local name = UnitName(unit) name = ShortName(name)
      if name and self.guildRosterCache[Lower(name)] then table.insert(guildies, name) end
    end
  end
  return guildies
end

function LeafVE:GetGroupHash(members) table.sort(members) return table.concat(members, ",") end

function LeafVE:OnGroupUpdate()
  local guildies = self:GetGroupGuildies() local numGuildies = table.getn(guildies)
  if numGuildies == 0 then self.currentGroupStart = nil self.currentGroupMembers = {} return end
  local groupHash = self:GetGroupHash(guildies)
  if not self.currentGroupStart or groupHash ~= self:GetGroupHash(self.currentGroupMembers) then
    self.currentGroupStart = Now() self.currentGroupMembers = guildies return
  end
  local timeInGroup = Now() - self.currentGroupStart
  if timeInGroup < GROUP_MIN_TIME then return end
  EnsureDB()
  if LeafVE_DB.groupCooldowns[groupHash] then
    local timeSinceLastCredit = Now() - LeafVE_DB.groupCooldowns[groupHash]
    if timeSinceLastCredit < GROUP_COOLDOWN then return end
  end
  local playerName = ShortName(UnitName("player"))
  if playerName then
    local points = numGuildies
    self:AddPoints(playerName, "G", points)
    self:AddToHistory(playerName, "G", points, "Grouped with "..numGuildies.." guildies: "..table.concat(guildies, ", "))
    LeafVE_DB.groupCooldowns[groupHash] = Now()
    Print(string.format("Group points awarded! +%d G for grouping with %d guildies", points, numGuildies))
  end
  self.currentGroupStart = Now()
end

function LeafVE:GiveShoutout(targetName, reason)
  EnsureDB() 
  local giverName = ShortName(UnitName("player")) 
  targetName = ShortName(targetName)
  if not giverName or not targetName then 
    Print("Error: Invalid player names") 
    return false 
  end
  if Lower(giverName) == Lower(targetName) then 
    Print("You cannot shout out yourself!") 
    return false 
  end
  
  local today = DayKey()
  if not LeafVE_DB.shoutouts[giverName] then 
    LeafVE_DB.shoutouts[giverName] = {} 
  end
  
  local count = 0
  for tname, timestamp in pairs(LeafVE_DB.shoutouts[giverName]) do
    local shoutoutDay = DayKeyFromTS(timestamp)
    if shoutoutDay == today then 
      count = count + 1 
    else 
      LeafVE_DB.shoutouts[giverName][tname] = nil 
    end
  end
  
  if count >= SHOUTOUT_MAX_PER_DAY then 
    Print(string.format("You've used all %d shoutouts for today!", SHOUTOUT_MAX_PER_DAY)) 
    return false 
  end
  
  local targetInfo = self:GetGuildInfo(targetName)
  if not targetInfo then 
    Print("Player "..targetName.." is not in the guild!") 
    return false 
  end
  
  LeafVE_DB.shoutouts[giverName][targetName] = Now()
  self:AddPoints(targetName, "S", 1)
  self:AddToHistory(targetName, "S", 1, "Shoutout from "..giverName..(reason and (": "..reason) or ""))
  self:CheckAndAwardBadge(giverName, "first_shoutout_given")
  self:CheckAndAwardBadge(targetName, "first_shoutout_received")
  
  local receivedCount = 0
  for giver, _ in pairs(LeafVE_DB.shoutouts) do
    for target, _ in pairs(LeafVE_DB.shoutouts[giver]) do
      if Lower(target) == Lower(targetName) then 
        receivedCount = receivedCount + 1 
      end
    end
  end
  
  if receivedCount >= 10 then 
    self:CheckAndAwardBadge(targetName, "shoutout_received_10") 
  end
  
  self:CheckBadgeMilestones(targetName)
  
  if InGuild() then
    reason = reason and Trim(reason) or ""
    
    local title = nil
    if LeafVE_AchTest_DB and LeafVE_AchTest_DB[giverName] and LeafVE_AchTest_DB[giverName].equippedTitle then
      title = LeafVE_AchTest_DB[giverName].equippedTitle
    end
    
    local message
    if title and title ~= "" then
      message = string.format("[%s] recognizes %s!", title, targetName)
    else
      message = string.format("recognizes %s!", targetName)
    end
    
    if reason ~= "" then 
      message = message .. " - " .. reason 
    end
    
    message = message .. " (+1 Leaf Point)"
    SendChatMessage(message, "GUILD")
  end
  
  local remaining = SHOUTOUT_MAX_PER_DAY - count - 1
  Print(string.format("Shoutout sent to %s! (%d remaining today)", targetName, remaining))
  return true
end

function LeafVE:BroadcastMyAchievements()
  -- Placeholder for achievement system
end

function LeafVE:BroadcastBadges()
  if not InGuild() then return end
  
  local me = ShortName(UnitName("player"))
  if not me then return end
  
  EnsureDB()
  local myBadges = LeafVE_DB.badges[me] or {}
  
  -- Build compressed badge list: "badgeID:timestamp,badgeID:timestamp,..."
  local badgeData = {}
  for badgeId, timestamp in pairs(myBadges) do
    table.insert(badgeData, badgeId..":"..timestamp)
  end
  
  if table.getn(badgeData) > 0 then
    local message = table.concat(badgeData, ",")
    SendAddonMessage("LeafVE", "BADGES:"..message, "GUILD")
    Print("Broadcast "..table.getn(badgeData).." badges to guild")
  end
end

function LeafVE:BroadcastBadges()
  if not InGuild() then return end
  
  local me = ShortName(UnitName("player"))
  if not me then return end
  
  EnsureDB()
  local myBadges = LeafVE_DB.badges[me] or {}
  
  -- Build compressed badge list: "badgeID:timestamp,badgeID:timestamp,..."
  local badgeData = {}
  for badgeId, timestamp in pairs(myBadges) do
    table.insert(badgeData, badgeId..":"..timestamp)
  end
  
  if table.getn(badgeData) > 0 then
    local message = table.concat(badgeData, ",")
    SendAddonMessage("LeafVE", "BADGES:"..message, "GUILD")
    Print("Broadcast "..table.getn(badgeData).." badges to guild")
  end
end

-- **ADD THIS FUNCTION HERE (Step 3)**
function LeafVE:BroadcastPlayerNote(noteText)
  if not InGuild() then return end
  
  local me = ShortName(UnitName("player"))
  if not me then return end
  
  noteText = noteText or ""
  
  -- Escape special characters
  noteText = string.gsub(noteText, "|", "||")
  
  SendAddonMessage("LeafVE", "NOTE:"..noteText, "GUILD")
  Print("Broadcast player note to guild")
end

function LeafVE:OnAddonMessage(prefix, message, channel, sender)
  -- ... existing code ...
end

function LeafVE:OnAddonMessage(prefix, message, channel, sender)
  if prefix ~= "LeafVE" then return end
  if channel ~= "GUILD" then return end
  
  sender = ShortName(sender)
  if not sender then return end
  
  -- Parse badge sync message
  if string.sub(message, 1, 7) == "BADGES:" then
    local badgeData = string.sub(message, 8)
    
    EnsureDB()
    if not LeafVE_DB.badges[sender] then
      LeafVE_DB.badges[sender] = {}
    end
    
    -- Parse badge data (Vanilla WoW compatible)
    local badges = {}
    local startPos = 1
    
    while startPos <= string.len(badgeData) do
      local commaPos = string.find(badgeData, ",", startPos)
      local badgeEntry
      
      if commaPos then
        badgeEntry = string.sub(badgeData, startPos, commaPos - 1)
        startPos = commaPos + 1
      else
        badgeEntry = string.sub(badgeData, startPos)
        startPos = string.len(badgeData) + 1
      end
      
      -- Parse individual badge: "badgeID:timestamp"
      local colonPos = string.find(badgeEntry, ":")
      if colonPos then
        local badgeId = string.sub(badgeEntry, 1, colonPos - 1)
        local timestamp = string.sub(badgeEntry, colonPos + 1)
        badges[badgeId] = tonumber(timestamp)
      end
    end
    
    -- Update stored data for this player
    LeafVE_DB.badges[sender] = badges
    
    local count = 0
    for _ in pairs(badges) do count = count + 1 end
    Print("Received "..count.." badges from "..sender)
    
    -- Refresh UI if viewing this player
    if LeafVE.UI and LeafVE.UI.cardCurrentPlayer == sender then
      LeafVE.UI:UpdateCardRecentBadges(sender)
    end
    
  -- **NEW: Parse player note sync message**
  elseif string.sub(message, 1, 5) == "NOTE:" then
    local noteText = string.sub(message, 6)
    
    -- Unescape special characters
    noteText = string.gsub(noteText, "||", "|")
    
    EnsureDB()
    if not LeafVE_GlobalDB.playerNotes then
      LeafVE_GlobalDB.playerNotes = {}
    end
    
    LeafVE_GlobalDB.playerNotes[sender] = noteText
    Print("Received player note from "..sender)
    
    -- Refresh UI if viewing this player
    if LeafVE.UI and LeafVE.UI.cardCurrentPlayer == sender then
      if LeafVE.UI.cardNotesEdit then
        LeafVE.UI.cardNotesEdit:SetText(noteText)
      end
    end
  end
end
function FindUnitToken(playerName)
  if UnitName("player") == playerName then return "player" end
  if UnitExists("target") and UnitName("target") == playerName then return "target" end
  for i = 1, 4 do local unit = "party"..i if UnitExists(unit) and UnitName(unit) == playerName then return unit end end
  for i = 1, 40 do local unit = "raid"..i if UnitExists(unit) and UnitName(unit) == playerName then return unit end end
  return nil
end

function AggForThisWeek()
  EnsureDB() local startTS = WeekStartTS(Now()) local agg = {}
  for d = 0, 6 do
    local dk = DayKeyFromTS(startTS + d * SECONDS_PER_DAY)
    if LeafVE_DB.global[dk] then
      for name, t in pairs(LeafVE_DB.global[dk]) do
        if not agg[name] then agg[name] = {L = 0, G = 0, S = 0} end
        agg[name].L = agg[name].L + (t.L or 0)
        agg[name].G = agg[name].G + (t.G or 0)
        agg[name].S = agg[name].S + (t.S or 0)
      end
    end
  end
  return agg, startTS
end

function LeafVE:ToggleUI()
  EnsureDB()
  
  if not LeafVE.UI or not LeafVE.UI.Build then 
    Print("ERROR: UI not loaded. Check addon file!") 
    return 
  end
  
  if not LeafVE.UI.frame then 
    Print("Building UI for first time...")
    LeafVE.UI:Build()
  end
  
  if not LeafVE.UI.frame then
    Print("ERROR: UI frame failed to build!")
    return
  end
  
  if LeafVE.UI.frame:IsVisible() then 
    LeafVE.UI.frame:Hide()
  else 
    LeafVE.UI.frame:Show()
    LeafVE.UI:Refresh()
  end
end

-------------------------------------------------
-- UI SYSTEM - ALL TABS
-------------------------------------------------
LeafVE.UI = LeafVE.UI or { activeTab = "me" }

-- Achievement icon mapping
local ACHIEVEMENT_ICONS = {
  -- Professions
  ["prof_skinning_300"] = "Interface\\Icons\\INV_Misc_Pelt_Wolf_01",
  ["prof_herbalism_300"] = "Interface\\Icons\\INV_Misc_Herb_07",
  ["prof_mining_300"] = "Interface\\Icons\\INV_Pick_02",
  ["prof_alchemy_300"] = "Interface\\Icons\\Trade_Alchemy",
  ["prof_blacksmithing_300"] = "Interface\\Icons\\Trade_BlackSmithing",
  ["prof_engineering_300"] = "Interface\\Icons\\Trade_Engineering",
  ["prof_enchanting_300"] = "Interface\\Icons\\Trade_Engraving",
  ["prof_tailoring_300"] = "Interface\\Icons\\Trade_Tailoring",
  ["prof_leatherworking_300"] = "Interface\\Icons\\Trade_LeatherWorking",
  
  -- PvP
  ["pvp_duel_100"] = "Interface\\Icons\\Ability_Duel",
  ["pvp_honorable_kills_1000"] = "Interface\\Icons\\Ability_Warrior_Challange",
  ["pvp_warsong_victories_100"] = "Interface\\Icons\\INV_BannerPVP_01",
  ["pvp_arathi_victories_100"] = "Interface\\Icons\\INV_BannerPVP_02",
  
  -- Dungeons
  ["dung_sm_armory"] = "Interface\\Icons\\INV_Misc_Key_03",
  ["dung_gnomer"] = "Interface\\Icons\\INV_Gizmo_02",
  ["dung_deadmines"] = "Interface\\Icons\\INV_Ingot_03",
  ["dung_wailing_caverns"] = "Interface\\Icons\\Spell_Nature_NullifyDisease",
  ["dung_shadowfang_keep"] = "Interface\\Icons\\Spell_Shadow_Curse",
  ["dung_blackfathom_deeps"] = "Interface\\Icons\\Spell_Shadow_SacrificialShield",
  ["dung_razorfen_kraul"] = "Interface\\Icons\\Spell_Shadow_ShadeTrueSight",
  ["dung_uldaman"] = "Interface\\Icons\\INV_Misc_Rune_01",
  ["dung_zul_farrak"] = "Interface\\Icons\\Ability_Hunter_Pet_Vulture",
  ["dung_maraudon"] = "Interface\\Icons\\Spell_Nature_ResistNature",
  ["dung_sunken_temple"] = "Interface\\Icons\\INV_Misc_Head_Dragon_Green",
  ["dung_blackrock_depths"] = "Interface\\Icons\\Spell_Fire_LavaSpawn",
  ["dung_dire_maul"] = "Interface\\Icons\\INV_Misc_Book_11",
  ["dung_stratholme"] = "Interface\\Icons\\INV_Misc_Key_14",
  ["dung_scholomance"] = "Interface\\Icons\\INV_Misc_Bone_HumanSkull_01",
  
  -- Raids
  ["elite_no_wipe_bwl"] = "Interface\\Icons\\INV_Misc_Head_Dragon_Black",
  ["elite_flawless_nef"] = "Interface\\Icons\\INV_Misc_Head_Dragon_01",
  ["elite_all_raids_one_week"] = "Interface\\Icons\\INV_Misc_Bone_ElfSkull_01",
  ["elite_molten_core_clear"] = "Interface\\Icons\\Spell_Fire_Incinerate",
  ["elite_onyxia_kill"] = "Interface\\Icons\\INV_Misc_Head_Dragon_01",
  ["elite_zul_gurub_clear"] = "Interface\\Icons\\Ability_Mount_JungleTiger",
  ["elite_ahn_qiraj_20_clear"] = "Interface\\Icons\\INV_Misc_AhnQirajTrinket_04",
  ["elite_ahn_qiraj_40_clear"] = "Interface\\Icons\\INV_Misc_AhnQirajTrinket_05",
  ["elite_naxxramas_clear"] = "Interface\\Icons\\INV_Misc_Key_15",
  
  -- Exploration
  ["explore_eastern_kingdoms"] = "Interface\\Icons\\INV_Misc_Map_01",
  ["explore_kalimdor"] = "Interface\\Icons\\INV_Misc_Map02",
  
  -- Gold
  ["gold_1000"] = "Interface\\Icons\\INV_Misc_Coin_01",
  ["gold_5000"] = "Interface\\Icons\\INV_Misc_Coin_05",
  ["gold_10000"] = "Interface\\Icons\\INV_Misc_Coin_16",
  
  -- Casual/Fun
  ["casual_fall_death"] = "Interface\\Icons\\Ability_Rogue_FeignDeath",
  ["casual_drunk"] = "Interface\\Icons\\INV_Drink_05",
  ["casual_fish_100"] = "Interface\\Icons\\INV_Misc_Fish_02",
  ["casual_first_aid_300"] = "Interface\\Icons\\Spell_Holy_SealOfSacrifice",
  ["casual_cooking_300"] = "Interface\\Icons\\INV_Misc_Food_15",
  
  -- Level achievements
  ["level_60"] = "Interface\\Icons\\INV_Misc_LevelGain",
  ["level_40_mount"] = "Interface\\Icons\\Ability_Mount_RidingHorse",
  ["level_60_epic_mount"] = "Interface\\Icons\\Ability_Mount_NightmareHorse",
}

local function GetAchievementIcon(achId)
  if not achId then return "Interface\\Icons\\INV_Misc_QuestionMark" end
  
  local lowerAchId = string.lower(achId)
  
  local iconMap = {
    lvl_10 = "Interface\\Icons\\INV_Sword_04",
    lvl_20 = "Interface\\Icons\\INV_Sword_27",
    lvl_30 = "Interface\\Icons\\INV_Sword_39",
    lvl_40 = "Interface\\Icons\\INV_Sword_43",
    lvl_50 = "Interface\\Icons\\INV_Sword_62",
    lvl_60 = "Interface\\Icons\\INV_Sword_65",
    gold_10 = "Interface\\Icons\\INV_Misc_Coin_01",
    gold_100 = "Interface\\Icons\\INV_Misc_Coin_05",
    gold_1000 = "Interface\\Icons\\INV_Misc_Gem_Pearl_05",
  }
  
  if iconMap[lowerAchId] then
    return iconMap[lowerAchId]
  end
  
  if string.find(lowerAchId, "lvl") or string.find(lowerAchId, "level") then
    return "Interface\\Icons\\INV_Sword_04"
  elseif string.find(lowerAchId, "gold") then
    return "Interface\\Icons\\INV_Misc_Coin_01"
  end
  
  return "Interface\\Icons\\INV_Misc_QuestionMark"
end

local function TabButton(parent, text, name)
  local b = CreateFrame("Button", name, parent, "UIPanelButtonTemplate")
  b:SetHeight(20)
  b:SetText(text)
  SkinButtonAccent(b)
  return b
end

function LeafVE.UI:BuildPlayerCard(parent)
  if self.card then return end
  
  local c = CreateGradientInset(parent)
  self.card = c
  c:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -10, -10)
  c:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -10, 10)
  c:SetWidth(480)

  local title = c:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  title:SetPoint("TOPLEFT", c, "TOPLEFT", 10, -10)
  title:SetText("Player Card")
  title:SetTextColor(THEME.leaf[1], THEME.leaf[2], THEME.leaf[3])

  local portraitContainer = CreateFrame("Frame", nil, c)
  portraitContainer:SetPoint("TOP", c, "TOP", 0, -40)
  portraitContainer:SetWidth(180)
  portraitContainer:SetHeight(180)
  portraitContainer:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = {left = 3, right = 3, top = 3, bottom = 3}
  })
  portraitContainer:SetBackdropColor(0.1, 0.1, 0.15, 0.9)
  portraitContainer:SetBackdropBorderColor(THEME.leaf[1], THEME.leaf[2], THEME.leaf[3], 0.8)

  local model = CreateFrame("PlayerModel", nil, portraitContainer)
  model:SetAllPoints(portraitContainer)
  model:Hide()
  self.cardModel = model

  local classIconFrame = CreateFrame("Frame", nil, portraitContainer)
  classIconFrame:SetAllPoints(portraitContainer)
  classIconFrame:Hide()
  self.cardClassIconFrame = classIconFrame

  local classIcon = classIconFrame:CreateTexture(nil, "ARTWORK")
  classIcon:SetPoint("CENTER", classIconFrame, "CENTER", 0, 0)
  classIcon:SetWidth(130)
  classIcon:SetHeight(130)
  classIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
  self.cardClassIcon = classIcon

  local portraitTypeText = c:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  portraitTypeText:SetPoint("TOP", portraitContainer, "BOTTOM", 0, 2)
  portraitTypeText:SetText("")
  portraitTypeText:SetTextColor(0.7, 0.7, 0.7)
  self.cardPortraitTypeText = portraitTypeText

  local nameFS = c:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
  nameFS:SetPoint("TOP", portraitContainer, "BOTTOM", 0, -10)
  nameFS:SetWidth(430)
  nameFS:SetJustifyH("CENTER")
  nameFS:SetText("-")
  self.cardName = nameFS

  local infoFS = c:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  infoFS:SetPoint("TOP", nameFS, "BOTTOM", 0, -5)
  infoFS:SetWidth(430)
  infoFS:SetJustifyH("CENTER")
  infoFS:SetText("")
  self.cardClassLevelRank = infoFS

-- Recent Badges Section (LEFT SIDE)
local recentBadgesLabel = c:CreateFontString(nil, "OVERLAY", "GameFontNormal")
recentBadgesLabel:SetPoint("TOPLEFT", c, "TOPLEFT", 10, -300)
recentBadgesLabel:SetText("|cFFFFD700Recent Badges|r")

local recentBadgesFrame = CreateFrame("Frame", nil, c)
recentBadgesFrame:SetPoint("TOPLEFT", recentBadgesLabel, "BOTTOMLEFT", 0, -10)
recentBadgesFrame:SetWidth(210)
recentBadgesFrame:SetHeight(160)
self.cardRecentBadgesFrame = recentBadgesFrame

self.cardRecentBadgeFrames = {}

  -- View All Badges Button
  local viewAllBadgesBtn = CreateFrame("Button", nil, c, "UIPanelButtonTemplate")
  viewAllBadgesBtn:SetWidth(140)
  viewAllBadgesBtn:SetHeight(22)
  viewAllBadgesBtn:SetPoint("TOPLEFT", recentBadgesFrame, "BOTTOMLEFT", 0, -10)
  viewAllBadgesBtn:SetText("View All Badges")
  SkinButtonAccent(viewAllBadgesBtn)
  viewAllBadgesBtn:SetScript("OnClick", function()
    LeafVE.UI:ShowAllBadgesPanel(LeafVE.UI.inspectedPlayer or UnitName("player"))
  end)
  self.viewAllBadgesBtn = viewAllBadgesBtn

  -- Achievements Section
  local achLabel = c:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  achLabel:SetPoint("TOPRIGHT", c, "TOPRIGHT", -40, -300)
  achLabel:SetText("|cFFFFD700Achievements|r")
  
  local achPointsText = c:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  achPointsText:SetPoint("TOP", achLabel, "BOTTOM", 0, -5)
  achPointsText:SetWidth(210)
  achPointsText:SetJustifyH("CENTER")
  achPointsText:SetText("0 Points")
  self.cardAchPoints = achPointsText
  
  local recentLabel = c:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  recentLabel:SetPoint("TOP", achPointsText, "BOTTOM", -0, -8)
  recentLabel:SetText("|cFFAAAAFFRecent Achievements|r")
  
  -- Recent achievements frame
  local recentFrame = CreateFrame("Frame", nil, c)
  recentFrame:SetPoint("TOP", recentLabel, "BOTTOM", 27, -7)
  recentFrame:SetWidth(230)
  recentFrame:SetHeight(110)
  self.cardRecentAchFrame = recentFrame
  
  self.cardRecentAchEntries = {}
  
  -- View All button
  local viewAllBtn = CreateFrame("Button", nil, c, "UIPanelButtonTemplate")
  viewAllBtn:SetPoint("TOP", recentFrame, "BOTTOM", -33, -10)
  viewAllBtn:SetWidth(180)
  viewAllBtn:SetHeight(22)
  viewAllBtn:SetText("View All Achievements")
  SkinButtonAccent(viewAllBtn)
viewAllBtn:SetScript("OnClick", function()
  if LeafVE.UI.cardCurrentPlayer then
    LeafVE.UI:CreateAchievementListPopup()
    LeafVE.UI:RefreshAchievementPopup(LeafVE.UI.cardCurrentPlayer)
    LeafVE.UI.achPopup:Show()  -- ADD THIS LINE
  end
end)
  self.cardViewAllBtn = viewAllBtn

  local notesLabel = c:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  notesLabel:SetPoint("TOPLEFT", c, "TOPLEFT", 20, -100)
  notesLabel:SetText("|cFFFFD700Player Note|r")

  local notesEditBox = CreateFrame("EditBox", nil, c)
  notesEditBox:SetPoint("TOPLEFT", notesLabel, "BOTTOMLEFT", 0, -5)
  notesEditBox:SetWidth(210)
  notesEditBox:SetHeight(60)
  notesEditBox:SetMultiLine(true)
  notesEditBox:SetAutoFocus(false)
  notesEditBox:SetFontObject(GameFontHighlightSmall)
  notesEditBox:SetMaxLetters(500)
  
  -- ... background setup ...
  
  notesEditBox:SetScript("OnEscapePressed", function() 
    this:ClearFocus() 
  end)
  
  self.cardNotesEdit = notesEditBox  -- ← MAKE SURE THIS LINE EXISTS
  
  -- Save button
  local saveNoteBtn = CreateFrame("Button", nil, c, "UIPanelButtonTemplate")
  saveNoteBtn:SetPoint("TOPLEFT", notesEditBox, "BOTTOMLEFT", 0, -5)
  saveNoteBtn:SetWidth(100)
  saveNoteBtn:SetHeight(22)
  saveNoteBtn:SetText("Save Note")
  SkinButtonAccent(saveNoteBtn)
  
  saveNoteBtn:SetScript("OnClick", function()
    local cardPlayer = LeafVE.UI.cardCurrentPlayer
    if not cardPlayer then 
      Print("No player selected!")
      return 
    end
    
    EnsureDB()
    local me = ShortName(UnitName("player"))
    
    -- Only save if editing your own note
    if me and cardPlayer == me then
    local text = LeafVE.UI.cardNotesEdit:GetText()  -- Correct - using stored reference
      if not LeafVE_GlobalDB.playerNotes then
        LeafVE_GlobalDB.playerNotes = {}
      end
      LeafVE_GlobalDB.playerNotes[me] = text
      
      -- Clear focus
      LeafVE.UI.cardNotesEdit:ClearFocus()  -- Correct
      
      -- Broadcast the note change
      LeafVE:BroadcastPlayerNote(text)
      Print("Player note saved and broadcast!")
    else
      Print("You can only edit your own note!")
    end
  end)
  
  self.cardSaveNoteBtn = saveNoteBtn

  -- Leaf Village Emblem with BIG BRIGHT GLOW
  local leafGlow = c:CreateTexture(nil, "BACKGROUND")
  leafGlow:SetWidth(128)  -- ← DOUBLED from 64
  leafGlow:SetHeight(128)
  leafGlow:SetPoint("CENTER", c, "CENTER", 0, -50)
  leafGlow:SetTexture("Interface\\GLUES\\Models\\UI_Draenei\\GenericGlow64")
  leafGlow:SetVertexColor(THEME.leaf[1], THEME.leaf[2], THEME.leaf[3], 1.0)  -- ← FULL BRIGHTNESS (was 0.6)
  leafGlow:SetBlendMode("ADD")
  
  local leafEmblem = c:CreateTexture(nil, "ARTWORK")
  leafEmblem:SetWidth(48)  -- ← BIGGER (was 32)
  leafEmblem:SetHeight(48)
  leafEmblem:SetPoint("CENTER", c, "CENTER", 0, -50)
  leafEmblem:SetTexture("Interface\\Icons\\INV_Misc_Herb_8")
  leafEmblem:SetVertexColor(THEME.leaf[1], THEME.leaf[2], THEME.leaf[3], 1.0)

  local leafLabel = c:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  leafLabel:SetPoint("TOP", leafEmblem, "BOTTOM", 0, -2)
  leafLabel:SetText("Leaf Village")
  leafLabel:SetTextColor(THEME.leaf[1], THEME.leaf[2], THEME.leaf[3])
  
  -- Debug output
  Print("Attempting to load leaf emblem...")
  Print("SetTexture returned: "..tostring(success))
  
  -- Check if it loaded
  local loadedTexture = leafEmblem:GetTexture()
  if loadedTexture then
    Print("SUCCESS: Texture loaded - "..tostring(loadedTexture))
  else
    Print("FAILED: Texture not loaded, trying fallback")
    leafEmblem:SetTexture("Interface\\Icons\\INV_Misc_Herb_01")
  end
  
  leafEmblem:SetVertexColor(THEME.leaf[1], THEME.leaf[2], THEME.leaf[3], 0.8)

  local leafLabel = c:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  leafLabel:SetPoint("TOP", leafEmblem, "BOTTOM", 0, -2)
  leafLabel:SetText("Leaf Village")
  leafLabel:SetTextColor(THEME.leaf[1], THEME.leaf[2], THEME.leaf[3])
 end

-- Show All Badges Panel
function LeafVE.UI:ShowAllBadgesPanel(playerName)
  if not playerName then
    playerName = UnitName("player")
  end

  -- Create main frame
  if not self.allBadgesFrame then
    local f = CreateFrame("Frame", "LeafVEAllBadgesFrame", UIParent)
    SetSize(f, 700, 550)
    f:SetPoint("anchorPoint", parentFrame, "relativePoint", xOffset, yOffset)
    f:SetFrameStrata("DIALOG")
    f:EnableMouse(true)
    f:SetMovable(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:SetClampedToScreen(true)
    
    -- Title
    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    f.title:SetPoint("TOP", f, "TOP", 0, -5)
    
    -- Close button (already exists from BasicFrameTemplateWithInset)
    
    -- Scroll Frame
    local scrollFrame = CreateFrame("ScrollFrame", "LeafVEAllBadgesScrollFrame", f, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", f.InsetBg or f, "TOPLEFT", 10, -40)
    scrollFrame:SetPoint("BOTTOMRIGHT", f.InsetBg or f, "BOTTOMRIGHT", -30, 10)
    
    -- Content Frame
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetWidth(scrollFrame:GetWidth())
    content:SetHeight(1) -- Will be updated dynamically
    scrollFrame:SetScrollChild(content)
    
    f.scrollFrame = scrollFrame
    f.content = content
    
    self.allBadgesFrame = f
  end

  local f = self.allBadgesFrame
  f.title:SetText(playerName .. "'s Badge Collection")
  
  -- Clear existing content
  if f.badgeIcons then
    for _, icon in ipairs(f.badgeIcons) do
      icon:Hide()
      icon:SetParent(nil)
    end
  end
  f.badgeIcons = {}
  
  -- Get player's badges
  local profile = self:GetProfileForPlayer(playerName)
  local playerBadges = {}
  if profile and profile.badges then
    for _, badge in ipairs(profile.badges) do
      playerBadges[badge.id] = badge
    end
  end
  
  -- Organize badges by category
  local categories = {}
  for id, badge in pairs(LeafVE.Badges) do
    local category = badge.category or "Other"
    if not categories[category] then
      categories[category] = {}
    end
    table.insert(categories[category], {
      id = id,
      name = badge.name,
      description = badge.description,
      icon = badge.icon,
      earned = playerBadges[id] ~= nil,
      earnedDate = playerBadges[id] and playerBadges[id].earned or nil
    })
  end
  
  -- Sort categories
  local sortedCategories = {}
  for category, _ in pairs(categories) do
    table.insert(sortedCategories, category)
  end
  table.sort(sortedCategories)
  
  -- Build UI
  local yOffset = -10
  local content = f.content
  
  for _, category in ipairs(sortedCategories) do
    -- Category Header
    local header = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    header:SetPoint("TOPLEFT", content, "TOPLEFT", 10, yOffset)
    header:SetText("|cFFFFD700" .. category .. "|r")
    table.insert(f.badgeIcons, header)
    yOffset = yOffset - 30
    
    -- Sort badges in category (earned first)
    table.sort(categories[category], function(a, b)
      if a.earned ~= b.earned then
        return a.earned
      end
      return a.name < b.name
    end)
    
    -- Display badges in grid
    local xOffset = 10
    local col = 0
    local maxCols = 5
    local iconSize = 50
    local spacing = 10
    
    for _, badgeData in ipairs(categories[category]) do
      local icon = CreateFrame("Frame", nil, content)
      icon:SetSize(iconSize, iconSize)
      icon:SetPoint("TOPLEFT", content, "TOPLEFT", xOffset, yOffset)
      
      -- Badge texture
      local tex = icon:CreateTexture(nil, "ARTWORK")
      tex:SetAllPoints()
      tex:SetTexture(badgeData.icon)
      
      if not badgeData.earned then
        tex:SetDesaturated(true)
        tex:SetAlpha(0.3)
      end
      
      -- Border
      local border = icon:CreateTexture(nil, "OVERLAY")
      border:SetAllPoints()
      border:SetTexture("Interface\\AchievementFrame\\UI-Achievement-IconFrame")
      border:SetTexCoord(0, 0.5625, 0, 0.5625)
      
      -- Tooltip
      icon:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(badgeData.name, 1, 1, 1)
        GameTooltip:AddLine(badgeData.description, nil, nil, nil, true)
        if badgeData.earned and badgeData.earnedDate then
          GameTooltip:AddLine(" ", 1, 1, 1)
          GameTooltip:AddLine("Earned: " .. date("%m/%d/%Y", badgeData.earnedDate), 0.5, 0.5, 0.5)
        elseif not badgeData.earned then
          GameTooltip:AddLine(" ", 1, 1, 1)
          GameTooltip:AddLine("Not yet earned", 0.5, 0.5, 0.5)
        end
        GameTooltip:Show()
      end)
      icon:SetScript("OnLeave", function()
        GameTooltip:Hide()
      end)
      
      table.insert(f.badgeIcons, icon)
      
      col = col + 1
      if col >= maxCols then
        col = 0
        xOffset = 10
        yOffset = yOffset - (iconSize + spacing)
      else
        xOffset = xOffset + iconSize + spacing
      end
    end
    
    -- Move to next row if we didn't finish a full row
    if col > 0 then
      yOffset = yOffset - (iconSize + spacing)
    end
    
    yOffset = yOffset - 20 -- Extra space between categories
  end
  
  -- Update content height
  content:SetHeight(math.abs(yOffset) + 50)
  
  -- Show frame
  f:Show()
end

function LeafVE.UI:UpdateCardRecentBadges(playerName)
  Print("UpdateCardRecentBadges called for: "..tostring(playerName))
  
  if not self.cardRecentBadgesFrame then
    Print("ERROR: cardRecentBadgesFrame is nil!")
    return
  end
  
  if not self.cardRecentBadgeFrames then
    Print("ERROR: cardRecentBadgeFrames is nil!")
    return
  end
  
  Print("Frames exist, continuing...")
  
  -- Hide all existing badge frames
  for i = 1, table.getn(self.cardRecentBadgeFrames) do
    self.cardRecentBadgeFrames[i]:Hide()
  end
  
  local shortName = ShortName(playerName)
  Print("Short name: "..tostring(shortName))
  
  EnsureDB()
  
  local myBadges = LeafVE_DB.badges[shortName] or {}
  Print("Found badges for player: "..tostring(table.getn(myBadges)))
  
  -- Build list of earned badges with timestamps
  local earnedBadges = {}
  for i = 1, table.getn(BADGES) do
    local badge = BADGES[i]
    if myBadges[badge.id] then
      table.insert(earnedBadges, {
        id = badge.id,
        name = badge.name,
        desc = badge.desc,
        icon = badge.icon,
        earnedAt = myBadges[badge.id],
        earned = true
      })
    end
  end
  
  Print("Total earned badges: "..table.getn(earnedBadges))
  
  -- Sort by most recent first
  table.sort(earnedBadges, function(a, b)
    return a.earnedAt > b.earnedAt
  end)
  
  -- Take top 9 earned badges
  local topEarned = {}
  for i = 1, math.min(9, table.getn(earnedBadges)) do
    table.insert(topEarned, earnedBadges[i])
  end
  
  -- Fill remaining slots with locked badges (not yet earned)
  if table.getn(topEarned) < 9 then
    for i = 1, table.getn(BADGES) do
      if table.getn(topEarned) >= 9 then break end
      
      local badge = BADGES[i]
      local alreadyShown = false
      
      for j = 1, table.getn(topEarned) do
        if topEarned[j].id == badge.id then
          alreadyShown = true
          break
        end
      end
      
      if not alreadyShown then
        table.insert(topEarned, {
          id = badge.id,
          name = badge.name,
          desc = badge.desc,
          icon = badge.icon,
          earnedAt = nil,
          earned = false
        })
      end
    end
  end
  
  -- Display all 9 badges (earned + locked)
  local badgeSize = 45
  local xSpacing = 50
  local ySpacing = 50
  local perRow = 3
  
  for i = 1, 9 do  -- ← CHANGE FROM 6 TO 9
    local badge = topEarned[i]
    local frame = self.cardRecentBadgeFrames[i]
    
    Print("Creating/updating badge "..i..": "..(badge and badge.name or "empty slot"))
    
    if not frame then
      Print("Creating NEW frame for badge "..i)
      frame = CreateFrame("Frame", nil, self.cardRecentBadgesFrame)
      frame:SetWidth(badgeSize)
      frame:SetHeight(badgeSize)
      frame:EnableMouse(true)
      
      local icon = frame:CreateTexture(nil, "ARTWORK")
      icon:SetAllPoints(frame)
      frame.icon = icon
      
      table.insert(self.cardRecentBadgeFrames, frame)
    end
    
    -- Position: grid layout (3 per row)
    local row = math.floor((i - 1) / perRow)
    local col = math.mod(i - 1, perRow)
    
    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", self.cardRecentBadgesFrame, "TOPLEFT", col * xSpacing, -row * ySpacing)
    
    Print("Positioned at col="..col.." row="..row)
    
    if badge then
      -- Set icon
      frame.icon:SetTexture(badge.icon)
      if not frame.icon:GetTexture() then
        frame.icon:SetTexture(LEAF_FALLBACK)
      end
      
      -- Style: earned = full color, locked = greyed out
      if badge.earned then
        frame.icon:SetVertexColor(1, 1, 1, 1)
        frame.icon:SetDesaturated(nil)
      else
        frame.icon:SetVertexColor(0.4, 0.4, 0.4, 0.7)
        if frame.icon.SetDesaturated then
          frame.icon:SetDesaturated(true)
        end
      end
      
      -- Tooltip
      frame:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        
        if badge.earned then
          GameTooltip:SetText(badge.name, THEME.gold[1], THEME.gold[2], THEME.gold[3], 1, true)
          GameTooltip:AddLine(badge.desc, 1, 1, 1, true)
          GameTooltip:AddLine(" ", 1, 1, 1)
          GameTooltip:AddLine("Earned: "..date("%m/%d/%Y", badge.earnedAt), 0.5, 0.8, 0.5)
        else
          GameTooltip:SetText(badge.name, 0.6, 0.6, 0.6, 1, true)
          GameTooltip:AddLine(badge.desc, 0.7, 0.7, 0.7, true)
          GameTooltip:AddLine(" ", 1, 1, 1)
          GameTooltip:AddLine("Not yet earned", 0.8, 0.4, 0.4)
        end
        
        GameTooltip:Show()
      end)
      
      frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
      end)
    else
      -- Empty slot
      frame.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
      frame.icon:SetVertexColor(0.3, 0.3, 0.3, 0.5)
      if frame.icon.SetDesaturated then
        frame.icon:SetDesaturated(true)
      end
      
      frame:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:SetText("Empty Badge Slot", 0.5, 0.5, 0.5, 1, true)
        GameTooltip:Show()
      end)
      
      frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
      end)
    end
    
    frame:Show()
    Print("Badge "..i.." frame shown")
  end
  
  -- Hide "No badges" text
  if self.cardNoBadgesText then
    self.cardNoBadgesText:Hide()
  end
  
  Print("UpdateCardRecentBadges complete")
end

function LeafVE.UI:ShowPlayerCard(playerName)
  EnsureDB()
  playerName = ShortName(playerName)
  if not playerName or not self.card then return end
  
  self.cardCurrentPlayer = playerName
  self.cardName:SetText(playerName)

  local guildInfo = LeafVE:GetGuildInfo(playerName)
  local class = guildInfo and guildInfo.class or "Unknown"
  local level = guildInfo and guildInfo.level or "??"
  local rank = guildInfo and guildInfo.rank or "Unknown"

  class = string.upper(Trim(class))

  local classColor = CLASS_COLORS[class] or {1, 1, 1}
  self.cardName:SetTextColor(classColor[1], classColor[2], classColor[3])
  self.cardClassLevelRank:SetText(string.format("Lvl %s %s\n%s", tostring(level), class, rank))

  local unitToken = FindUnitToken(playerName)
  local useModel = unitToken ~= nil
  
  if useModel then
    self.cardModel:Show()
    self.cardClassIconFrame:Hide()
    self.cardModel:ClearModel()
    self.cardModel:SetCamera(0)
    pcall(function()
      self.cardModel:SetUnit(unitToken)
      self.cardModel:SetPosition(0, 0, 0)
      self.cardModel:SetFacing(0.5)
    end)
    if self.cardPortraitTypeText then
      self.cardPortraitTypeText:SetText("|cFF00FF00Live|r")
    end
  else
    self.cardModel:Hide()
    self.cardClassIconFrame:Show()
    local classIconPath = CLASS_ICONS[class] or LEAF_FALLBACK
    self.cardClassIcon:SetTexture(classIconPath)
    self.cardClassIcon:SetVertexColor(1, 1, 1, 1)
    if self.cardPortraitTypeText then
      self.cardPortraitTypeText:SetText("|cFFFFAA00"..class.."|r")
    end
  end

  -- UPDATE RECENT BADGES (LEFT SIDE) - REPLACES Today/Week/Season stats
  Print("About to call UpdateCardRecentBadges...")
  if self.UpdateCardRecentBadges then
    Print("Function exists, calling it now")
    self:UpdateCardRecentBadges(playerName)
  else
    Print("ERROR: UpdateCardRecentBadges function does not exist!")
  end
  
 if self.cardNotesEdit then
    EnsureDB()
    if not LeafVE_GlobalDB.playerNotes then
      LeafVE_GlobalDB.playerNotes = {}
    end
    
    local note = LeafVE_GlobalDB.playerNotes[playerName] or ""
    self.cardNotesEdit:SetText(note)
    
    local me = ShortName(UnitName("player"))
    
    if me and playerName == me then
      -- Enable editing
      self.cardNotesEdit:EnableMouse(true)
      self.cardNotesEdit:EnableKeyboard(true)
      self.cardNotesEdit:SetTextColor(1, 1, 1, 1)  -- Bright white (RGBA)
      self.cardNotesEdit:SetAlpha(1)
      
      -- Show save button
      if self.cardSaveNoteBtn then
        self.cardSaveNoteBtn:Show()
        self.cardSaveNoteBtn:Enable()
      end
    else
      -- Disable editing (Vanilla compatible)
      self.cardNotesEdit:EnableMouse(false)
      self.cardNotesEdit:EnableKeyboard(false)
      self.cardNotesEdit:SetTextColor(0.9, 0.9, 0.9)  -- Slightly dimmed white for other players
      self.cardNotesEdit:SetAlpha(0.7)
      
      -- Hide save button for other players
      if self.cardSaveNoteBtn then
        self.cardSaveNoteBtn:Hide()
      end
      
      -- Clear focus to prevent editing
      self.cardNotesEdit:ClearFocus()
    end
  end

    -- Update achievement points display using API
  Print("DEBUG: Starting achievement section for player: "..tostring(playerName))
  
  local achPoints = 0
  if LeafVE_AchTest then
    Print("DEBUG: LeafVE_AchTest exists")
    if LeafVE_AchTest.API then
      Print("DEBUG: LeafVE_AchTest.API exists")
      if LeafVE_AchTest.API.GetPlayerPoints then
        Print("DEBUG: GetPlayerPoints function exists")
        -- FIX: Pass playerName instead of assuming it's the local player
        achPoints = LeafVE_AchTest.API.GetPlayerPoints(playerName)
        Print("DEBUG: Got "..tostring(achPoints).." points for "..playerName)
      else
        Print("DEBUG: GetPlayerPoints NOT FOUND")
      end
    else
      Print("DEBUG: API NOT FOUND")
    end
  else
    Print("DEBUG: LeafVE_AchTest NOT LOADED")
  end
  
  if self.cardAchPoints then
    self.cardAchPoints:SetText(string.format("|cFFFFD700%d|r Points", achPoints))
  end
  
  -- Get recent achievements using API
  local recentAch = {}
  if LeafVE_AchTest and LeafVE_AchTest.API and LeafVE_AchTest.API.GetRecentAchievements then
    Print("DEBUG: Calling GetRecentAchievements for "..tostring(playerName))
    -- FIX: Pass playerName instead of assuming local player
    recentAch = LeafVE_AchTest.API.GetRecentAchievements(playerName, 5)
    Print("DEBUG: API returned "..tostring(table.getn(recentAch)).." achievements")
    
    -- Debug each achievement
    for i = 1, table.getn(recentAch) do
      local ach = recentAch[i]
      Print("DEBUG: Achievement "..i..": name="..tostring(ach.name)..", icon="..tostring(ach.icon)..", points="..tostring(ach.points))
    end
  else
    Print("DEBUG: GetRecentAchievements API not available")
  end
  
  -- Clear previous recent achievements
  Print("DEBUG: Clearing "..tostring(table.getn(self.cardRecentAchEntries)).." previous entries")
  for i = 1, table.getn(self.cardRecentAchEntries) do
    self.cardRecentAchEntries[i]:Hide()
  end
  
  -- Display recent achievements (max 5)
  local maxRecent = math.min(5, table.getn(recentAch))
  Print("DEBUG: Will display "..tostring(maxRecent).." achievements")
  local yOffset = 0
  
  for i = 1, maxRecent do
    local ach = recentAch[i]
    local entry = self.cardRecentAchEntries[i]
    
    Print("DEBUG: Creating/updating entry "..i)
    
    if not entry then
      Print("DEBUG: Creating NEW entry frame")
      entry = CreateFrame("Frame", nil, self.cardRecentAchFrame)
      entry:SetWidth(210)
      entry:SetHeight(20)
      
      local icon = entry:CreateTexture(nil, "ARTWORK")
      icon:SetWidth(16)
      icon:SetHeight(16)
      icon:SetPoint("LEFT", entry, "LEFT", 0, 0)
      entry.icon = icon
      
      local nameText = entry:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
      nameText:SetPoint("LEFT", icon, "RIGHT", 5, 0)
      nameText:SetWidth(160)
      nameText:SetJustifyH("LEFT")
      entry.nameText = nameText
      
      local pointsText = entry:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
      pointsText:SetPoint("RIGHT", entry, "RIGHT", -50, 0)
      pointsText:SetWidth(60)
      pointsText:SetJustifyH("RIGHT")
      entry.pointsText = pointsText
      
      table.insert(self.cardRecentAchEntries, entry)
    end
    
    entry:SetPoint("TOPLEFT", self.cardRecentAchFrame, "TOPLEFT", 0, -yOffset)
    
    Print("DEBUG: Setting icon to: "..tostring(ach.icon))
    entry.icon:SetTexture(ach.icon)
    if not entry.icon:GetTexture() then
      Print("DEBUG: Icon texture failed, using fallback")
      entry.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    end
    
    Print("DEBUG: Setting name to: "..tostring(ach.name))
    entry.nameText:SetText(ach.name)
    
    Print("DEBUG: Setting points to: "..tostring(ach.points))
    entry.pointsText:SetText("|cFFFFD700"..ach.points.."|r")
    
    entry:Show()
    Print("DEBUG: Entry "..i.." shown")
    yOffset = yOffset + 22
  end
  
  Print("DEBUG: Achievement display complete")
 end

function LeafVE.UI:ShowAchievementPopup(achId, achData)
  if not achId or not achData then return end
  
  -- Create popup frame if it doesn't exist
  if not self.achPopup then
    local popup = CreateFrame("Frame", "LeafVE_AchievementPopup", UIParent)
    popup:SetWidth(300)
    popup:SetHeight(80)
    popup:SetPoint("TOP", UIParent, "TOP", 0, -150)
    popup:SetBackdrop({
      bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
      edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
      tile = true, tileSize = 32, edgeSize = 32,
      insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    popup:SetBackdropColor(0, 0, 0, 0.9)
    popup:Hide()
    
    -- Icon
    popup.icon = popup:CreateTexture(nil, "ARTWORK")
    popup.icon:SetWidth(36)
    popup.icon:SetHeight(36)
    popup.icon:SetPoint("LEFT", popup, "LEFT", 15, 0)
    
    -- Title text
    popup.title = popup:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    popup.title:SetPoint("TOPLEFT", popup.icon, "TOPRIGHT", 10, -5)
    popup.title:SetText("|cFFFFD700Achievement Earned!|r")
    
    -- Achievement name
    popup.achName = popup:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    popup.achName:SetPoint("TOPLEFT", popup.title, "BOTTOMLEFT", 0, -5)
    popup.achName:SetJustifyH("LEFT")
    popup.achName:SetWidth(220)
    
    -- Points
    popup.points = popup:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    popup.points:SetPoint("BOTTOMLEFT", popup.icon, "BOTTOMRIGHT", 10, 5)
    
    self.achPopup = popup
  end
  
  -- Format achievement name
  local displayName = achId
  displayName = string.gsub(displayName, "_", " ")
  displayName = string.gsub(displayName, "(%a)([%w_']*)", function(first, rest)
    return string.upper(first)..string.lower(rest)
  end)
  
  -- Set popup content
  self.achPopup.icon:SetTexture(GetAchievementIcon(achId))
  self.achPopup.achName:SetText(displayName)
  self.achPopup.points:SetText(achData.points.." Points")
  
  -- Show and auto-hide
  self.achPopup:Show()
  self.achPopup:SetScript("OnUpdate", function()
    if not this.showTime then
      this.showTime = GetTime()
    end
    
    if GetTime() - this.showTime > 5 then
      this:Hide()
      this.showTime = nil
      this:SetScript("OnUpdate", nil)
    end
  end)
  
  -- Play sound
  PlaySound("LevelUp")
end

function LeafVE.UI:CreateAchievementListPopup()
  if self.achPopup then return end
  
  local popup = CreateFrame("Frame", "LeafVE_AchievementListPopup", UIParent)
  popup:SetWidth(600)
  popup:SetHeight(500)
  popup:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
  popup:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
  })
  popup:SetBackdropColor(0, 0, 0, 0.95)
  popup:EnableMouse(true)
  popup:SetMovable(true)
  popup:RegisterForDrag("LeftButton")
  popup:SetScript("OnDragStart", function() this:StartMoving() end)
  popup:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
  popup:Hide()
  
  -- Title
  local titleText = popup:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  titleText:SetPoint("TOP", popup, "TOP", 0, -20)
  titleText:SetText("|cFFFFD700Achievements|r")
  
  -- Player name
  local playerNameText = popup:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  playerNameText:SetPoint("TOP", titleText, "BOTTOM", 0, -5)
  popup.playerNameText = playerNameText
  
  -- Close button
  local closeBtn = CreateFrame("Button", nil, popup, "UIPanelCloseButton")
  closeBtn:SetPoint("TOPRIGHT", popup, "TOPRIGHT", -5, -5)
  closeBtn:SetScript("OnClick", function() popup:Hide() end)
  
  -- Scroll frame
  local scrollFrame = CreateFrame("ScrollFrame", "LeafVE_AchScrollFrame", popup, "UIPanelScrollFrameTemplate")
  scrollFrame:SetPoint("TOPLEFT", popup, "TOPLEFT", 20, -60)
  scrollFrame:SetPoint("BOTTOMRIGHT", popup, "BOTTOMRIGHT", -30, 15)
  popup.scrollFrame = scrollFrame
  
  -- Scroll child
  local scrollChild = CreateFrame("Frame", nil, scrollFrame)
  scrollChild:SetWidth(550)
  scrollChild:SetHeight(1)
  scrollFrame:SetScrollChild(scrollChild)
  popup.scrollChild = scrollChild
  
  -- Scroll bar
  local scrollBar = getglobal(scrollFrame:GetName().."ScrollBar")
  popup.scrollBar = scrollBar
  
  -- Achievement entries table
  popup.achEntries = {}
  
  self.achPopup = popup
end

function LeafVE.UI:RefreshAchievementPopup(playerName)
  if not self.achPopup then return end
  
  self.achPopup.playerNameText:SetText(playerName.."'s Achievements")
  
  local achievements = {}
  
  if LeafVE_AchTest_DB and LeafVE_AchTest_DB.achievements and LeafVE_AchTest_DB.achievements[playerName] then
    local playerAchievements = LeafVE_AchTest_DB.achievements[playerName]
    
    for achId, achData in pairs(playerAchievements) do
      if type(achData) == "table" and achData.points and achData.timestamp then
        -- Format achievement name
        local displayName = achId
        displayName = string.gsub(displayName, "_", " ")
        displayName = string.gsub(displayName, "(%a)([%w_']*)", function(first, rest)
          return string.upper(first)..string.lower(rest)
        end)
        
        table.insert(achievements, {
          id = achId,
          name = displayName,
          desc = "Completed on "..date("%m/%d/%Y", achData.timestamp),
          icon = GetAchievementIcon(achId),
          points = achData.points,
          completed = true,
          timestamp = achData.timestamp
        })
      end
    end
  end
  
  -- Sort by most recent
  table.sort(achievements, function(a, b)
    return a.timestamp > b.timestamp
  end)
  
  -- Clear previous entries
  for i = 1, table.getn(self.achPopup.achEntries) do
    self.achPopup.achEntries[i]:Hide()
  end
  
  local scrollChild = self.achPopup.scrollChild
  local yOffset = -5
  local entryHeight = 50
  
  if table.getn(achievements) == 0 then
    local noAch = self.achPopup.achEntries[1]
    if not noAch then
      noAch = CreateFrame("Frame", nil, scrollChild)
      noAch:SetWidth(550)
      noAch:SetHeight(50)
      
      local text = noAch:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      text:SetPoint("CENTER", noAch, "CENTER", 0, 0)
      text:SetText("|cFF888888No achievements yet|r")
      noAch.text = text
      
      table.insert(self.achPopup.achEntries, noAch)
    end
    noAch:SetPoint("TOP", scrollChild, "TOP", 0, -20)
    noAch:Show()
  else
    for i = 1, table.getn(achievements) do
      local ach = achievements[i]
      local entry = self.achPopup.achEntries[i]
      
      if not entry then
        entry = CreateFrame("Frame", nil, scrollChild)
        entry:SetWidth(550)
        entry:SetHeight(entryHeight)
        
        local icon = entry:CreateTexture(nil, "ARTWORK")
        icon:SetWidth(40)
        icon:SetHeight(40)
        icon:SetPoint("LEFT", entry, "LEFT", 5, 0)
        entry.icon = icon
        
        local nameText = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        nameText:SetPoint("TOPLEFT", icon, "TOPRIGHT", 10, -5)
        nameText:SetWidth(400)
        nameText:SetJustifyH("LEFT")
        entry.nameText = nameText
        
        local descText = entry:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        descText:SetPoint("TOPLEFT", nameText, "BOTTOMLEFT", 0, -2)
        descText:SetWidth(400)
        descText:SetJustifyH("LEFT")
        entry.descText = descText
        
        local pointsText = entry:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        pointsText:SetPoint("RIGHT", entry, "RIGHT", -10, 0)
        pointsText:SetWidth(60)
        pointsText:SetJustifyH("RIGHT")
        entry.pointsText = pointsText
        
        local bg = entry:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(entry)
        bg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
        bg:SetVertexColor(0.1, 0.1, 0.1, 0.3)
        entry.bg = bg
        
        table.insert(self.achPopup.achEntries, entry)
      end
      
      entry:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 5, yOffset)
      
      entry.icon:SetTexture(ach.icon)
      if not entry.icon:GetTexture() then
        entry.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
      end
      
      entry.icon:SetVertexColor(1, 1, 1, 1)
      entry.nameText:SetText(ach.name)
      entry.nameText:SetTextColor(THEME.gold[1], THEME.gold[2], THEME.gold[3])
      entry.descText:SetText(ach.desc)
      entry.descText:SetTextColor(0.8, 0.8, 0.8)
      entry.pointsText:SetText("|cFFFFD700"..ach.points.." pts|r")
      
      entry:Show()
      yOffset = yOffset - entryHeight - 3
    end
  end
  
  scrollChild:SetHeight(math.max(1, math.abs(yOffset) + 50))
  
  local scrollRange = self.achPopup.scrollFrame:GetVerticalScrollRange()
  if scrollRange > 0 then
    self.achPopup.scrollBar:Show()
  else
    self.achPopup.scrollBar:Hide()
  end
  
  self.achPopup.scrollFrame:SetVerticalScroll(0)
  self.achPopup.scrollBar:SetValue(0)
end

local function BuildMyPanel(panel)
  local maxWidth = 500
  
  local h = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  h:SetPoint("TOP", panel, "TOP", 0, -10)
  h:SetText("|cFFFFD700My Stats|r")

  local subtitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  subtitle:SetPoint("TOP", h, "BOTTOM", 0, -3)
  subtitle:SetText("|cFF888888View your contribution statistics|r")
  
  local todayLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  todayLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, -80)
  todayLabel:SetText("|cFF2DD35CToday|r")
  
  local todayStats = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  todayStats:SetPoint("TOPLEFT", todayLabel, "BOTTOMLEFT", 0, -5)
  todayStats:SetWidth(maxWidth)
  todayStats:SetJustifyH("LEFT")
  todayStats:SetText("")
  panel.todayStats = todayStats
  
  local weekLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  weekLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, -150)
  weekLabel:SetText("|cFF2DD35CThis Week|r")
  
  local weekStats = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  weekStats:SetPoint("TOPLEFT", weekLabel, "BOTTOMLEFT", 0, -5)
  weekStats:SetWidth(maxWidth)
  weekStats:SetJustifyH("LEFT")
  weekStats:SetText("")
  panel.weekStats = weekStats
  
  local seasonLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  seasonLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, -220)
  seasonLabel:SetText("|cFF2DD35CSeason|r")
  
  local seasonStats = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  seasonStats:SetPoint("TOPLEFT", seasonLabel, "BOTTOMLEFT", 0, -5)
  seasonStats:SetWidth(maxWidth)
  seasonStats:SetJustifyH("LEFT")
  seasonStats:SetText("")
  panel.seasonStats = seasonStats
  
  local alltimeLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  alltimeLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, -290)
  alltimeLabel:SetText("|cFF2DD35CAll-Time|r")
  
  local alltimeStats = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  alltimeStats:SetPoint("TOPLEFT", alltimeLabel, "BOTTOMLEFT", 0, -5)
  alltimeStats:SetWidth(maxWidth)
  alltimeStats:SetJustifyH("LEFT")
  alltimeStats:SetText("")
  panel.alltimeStats = alltimeStats
  
  -- Section Divider (now anchored to alltimeStats)
  local divider = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  divider:SetPoint("TOPLEFT", alltimeStats, "BOTTOMLEFT", 0, -20)
  divider:SetText("|cFFFFD700▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬|r")
  
  -- Last Week's Winner (styled like other stats)
  local lastWeekLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  lastWeekLabel:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 0, -15)
  lastWeekLabel:SetText("|cFF2DD35CLast Week's Winner|r")
  
  local lastWeekWinner = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  lastWeekWinner:SetPoint("TOPLEFT", lastWeekLabel, "BOTTOMLEFT", 0, -5)
  lastWeekWinner:SetWidth(maxWidth)
  lastWeekWinner:SetJustifyH("LEFT")
  lastWeekWinner:SetText("Loading...")
  panel.lastWeekWinner = lastWeekWinner
  
  -- All-Time Leader (styled like other stats)
  local alltimeLeaderLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  alltimeLeaderLabel:SetPoint("TOPLEFT", lastWeekWinner, "BOTTOMLEFT", 0, -15)
  alltimeLeaderLabel:SetText("|cFF2DD35CAll-Time Leader|r")
  
  local alltimeLeader = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  alltimeLeader:SetPoint("TOPLEFT", alltimeLeaderLabel, "BOTTOMLEFT", 0, -5)
  alltimeLeader:SetWidth(maxWidth)
  alltimeLeader:SetJustifyH("LEFT")
  alltimeLeader:SetText("Loading...")
  panel.alltimeLeader = alltimeLeader
  
  -- Week Countdown (styled like other stats) - MOVE TO RIGHT SIDE
  local weekCountdownLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  weekCountdownLabel:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 250, -15)  -- ← 250 pixels to the right
  weekCountdownLabel:SetText("|cFF2DD35CWeek Resets In|r")
  
  local weekCountdown = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  weekCountdown:SetPoint("TOPLEFT", weekCountdownLabel, "BOTTOMLEFT", 0, -5)
  weekCountdown:SetWidth(maxWidth)
  weekCountdown:SetJustifyH("LEFT")
  weekCountdown:SetText("Loading...")
  panel.weekCountdown = weekCountdown
  
local legend = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  legend:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 12, 12)
  legend:SetWidth(maxWidth)
  legend:SetJustifyH("LEFT")
  legend:SetText("|cFFAAAAAAL = Login  |  G = Group  |  S = Shoutout|r")
end

local function BuildShoutoutsPanel(panel)
  local h = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  h:SetPoint("TOP", panel, "TOP", 0, -10)
  h:SetText("|cFFFFD700Shoutouts|r")

  local subtitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  subtitle:SetPoint("TOP", h, "BOTTOM", 0, -3)
  subtitle:SetText("|cFF888888Give recognition to guild members! You can give 2 shoutouts per day.|r")
  
  local usageText = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  usageText:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, -80)
  usageText:SetText("Shoutouts remaining today: 2 / 2")
  panel.usageText = usageText
  
  local targetLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  targetLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, -120)
  targetLabel:SetText("Target Player:")
  
  local targetInput = CreateFrame("EditBox", nil, panel)
  targetInput:SetPoint("TOPLEFT", targetLabel, "BOTTOMLEFT", 5, -5)
  targetInput:SetWidth(200)
  targetInput:SetHeight(20)
  targetInput:SetAutoFocus(false)
  targetInput:SetFontObject(GameFontHighlight)
  targetInput:SetMaxLetters(50)
  
  local targetInputBG = CreateFrame("Frame", nil, panel)
  targetInputBG:SetPoint("TOPLEFT", targetInput, "TOPLEFT", -5, 5)
  targetInputBG:SetPoint("BOTTOMRIGHT", targetInput, "BOTTOMRIGHT", 5, -5)
  targetInputBG:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = {left = 3, right = 3, top = 3, bottom = 3}
  })
  targetInputBG:SetBackdropColor(0, 0, 0, 0.5)
  targetInputBG:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
  targetInputBG:SetFrameLevel(targetInput:GetFrameLevel() - 1)
  
  targetInput:SetScript("OnEscapePressed", function() targetInput:ClearFocus() end)
  targetInput:SetScript("OnEnterPressed", function() targetInput:ClearFocus() end)
  
  panel.targetInput = targetInput
  
  local hintText = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  hintText:SetPoint("TOPLEFT", targetInput, "BOTTOMLEFT", 0, -2)
  hintText:SetText("|cFF888888Type player name (case-insensitive)|r")
  
  local reasonLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  reasonLabel:SetPoint("TOPLEFT", targetInput, "BOTTOMLEFT", -5, -20)
  reasonLabel:SetText("Reason (optional):")
  
  local reasonEdit = CreateFrame("EditBox", nil, panel)
  reasonEdit:SetPoint("TOPLEFT", reasonLabel, "BOTTOMLEFT", 0, -5)
  reasonEdit:SetWidth(450)
  reasonEdit:SetHeight(60)
  reasonEdit:SetMultiLine(true)
  reasonEdit:SetAutoFocus(false)
  reasonEdit:SetFontObject(GameFontHighlight)
  reasonEdit:SetMaxLetters(200)
  
  local reasonBG = CreateFrame("Frame", nil, panel)
  reasonBG:SetPoint("TOPLEFT", reasonEdit, "TOPLEFT", -5, 5)
  reasonBG:SetPoint("BOTTOMRIGHT", reasonEdit, "BOTTOMRIGHT", 5, -5)
  reasonBG:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = {left = 3, right = 3, top = 3, bottom = 3}
  })
  reasonBG:SetBackdropColor(0, 0, 0, 0.5)
  reasonBG:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
  reasonBG:SetFrameLevel(reasonEdit:GetFrameLevel() - 1)
  reasonEdit:SetScript("OnEscapePressed", function() reasonEdit:ClearFocus() end)
  panel.reasonEdit = reasonEdit
  
  local sendBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
  sendBtn:SetPoint("TOPLEFT", reasonEdit, "BOTTOMLEFT", 0, -10)
  sendBtn:SetWidth(120)
  sendBtn:SetHeight(25)
  sendBtn:SetText("Send Shoutout")
  SkinButtonAccent(sendBtn)
  
  sendBtn:SetScript("OnClick", function()
    local target = panel.targetInput:GetText()
    target = Trim(target)
    local reason = reasonEdit:GetText()
    
    if target and target ~= "" then
      if LeafVE:GiveShoutout(target, reason) then
        panel.targetInput:SetText("")
        reasonEdit:SetText("")
        
        if LeafVE.UI and LeafVE.UI.Refresh then
          LeafVE.UI:Refresh()
        end
      end
    else
      Print("Please enter a player name!")
    end
  end)
end

local function CreateScrollablePanel(panel, title, desc)
  local h = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  h:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, -12)
  h:SetText(title)
  h:SetTextColor(THEME.leaf[1], THEME.leaf[2], THEME.leaf[3])
  
  local infoText = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  infoText:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, -40)
  infoText:SetWidth(500)
  infoText:SetJustifyH("LEFT")
  infoText:SetText(desc)
  
  local scrollFrame = CreateFrame("ScrollFrame", nil, panel)
  scrollFrame:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, -80)
  scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -30, 12)
  scrollFrame:EnableMouse(true)
  scrollFrame:EnableMouseWheel(true)
  
  local scrollChild = CreateFrame("Frame", nil, scrollFrame)
  scrollChild:SetWidth(500)
  scrollChild:SetHeight(1)
  scrollFrame:SetScrollChild(scrollChild)
  
  scrollFrame:SetScript("OnMouseWheel", function()
    local current = scrollFrame:GetVerticalScroll()
    local maxScroll = scrollFrame:GetVerticalScrollRange()
    local newScroll = current - (arg1 * 40)
    if newScroll < 0 then newScroll = 0 end
    if newScroll > maxScroll then newScroll = maxScroll end
    scrollFrame:SetVerticalScroll(newScroll)
  end)
  
  local scrollBar = CreateFrame("Slider", nil, panel)
  scrollBar:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -8, -80)
  scrollBar:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -8, 12)
  scrollBar:SetWidth(16)
  scrollBar:SetOrientation("VERTICAL")
  scrollBar:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
  scrollBar:SetMinMaxValues(0, 100)
  scrollBar:SetValue(0)
  
  local thumb = scrollBar:GetThumbTexture()
  thumb:SetWidth(16)
  thumb:SetHeight(24)
  
  scrollBar:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 8, edgeSize = 8,
    insets = {left = 2, right = 2, top = 2, bottom = 2}
  })
  scrollBar:SetBackdropColor(0, 0, 0, 0.3)
  scrollBar:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
  
  scrollBar:SetScript("OnValueChanged", function()
    local value = scrollBar:GetValue()
    local maxScroll = scrollFrame:GetVerticalScrollRange()
    if maxScroll > 0 then
      scrollFrame:SetVerticalScroll((value / 100) * maxScroll)
    end
  end)
  
  scrollFrame:SetScript("OnVerticalScroll", function()
    local maxScroll = scrollFrame:GetVerticalScrollRange()
    if maxScroll > 0 then
      local current = scrollFrame:GetVerticalScroll()
      scrollBar:SetValue((current / maxScroll) * 100)
    else
      scrollBar:SetValue(0)
    end
  end)
  
  panel.scrollFrame = scrollFrame
  panel.scrollChild = scrollChild
  panel.scrollBar = scrollBar
end

local function BuildLeaderboardPanel(panel, isWeekly)
  local h = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  h:SetPoint("TOP", panel, "TOP", 0, -10)
  h:SetText(isWeekly and "|cFFFFD700Weekly Leaderboard|r" or "|cFFFFD700Lifetime Leaderboard|r")
  
  local subtitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  subtitle:SetPoint("TOP", h, "BOTTOM", 0, -3)
  subtitle:SetText(isWeekly and "|cFF888888Top performers ranked by achievement points|r" or "|cFF888888Top performers ranked by achievement points|r")
  
  local scrollFrame = CreateFrame("ScrollFrame", nil, panel)
  scrollFrame:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, -45)
  scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -30, 12)
  scrollFrame:EnableMouse(true)
  scrollFrame:EnableMouseWheel(true)
  
  local scrollChild = CreateFrame("Frame", nil, scrollFrame)
  scrollChild:SetWidth(500)
  scrollChild:SetHeight(1)
  scrollFrame:SetScrollChild(scrollChild)
  
  scrollFrame:SetScript("OnMouseWheel", function()
    local current = scrollFrame:GetVerticalScroll()
    local maxScroll = scrollFrame:GetVerticalScrollRange()
    local newScroll = current - (arg1 * 40)
    if newScroll < 0 then newScroll = 0 end
    if newScroll > maxScroll then newScroll = maxScroll end
    scrollFrame:SetVerticalScroll(newScroll)
  end)
  
  local scrollBar = CreateFrame("Slider", nil, panel)
  scrollBar:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -8, -45)
  scrollBar:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -8, 12)
  scrollBar:SetWidth(16)
  scrollBar:SetOrientation("VERTICAL")
  scrollBar:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
  scrollBar:SetMinMaxValues(0, 100)
  scrollBar:SetValue(0)
  
  local thumb = scrollBar:GetThumbTexture()
  thumb:SetWidth(16)
  thumb:SetHeight(24)
  
  scrollBar:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 8, edgeSize = 8,
    insets = {left = 2, right = 2, top = 2, bottom = 2}
  })
  scrollBar:SetBackdropColor(0, 0, 0, 0.3)
  scrollBar:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
  
  scrollBar:SetScript("OnValueChanged", function()
    local value = scrollBar:GetValue()
    local maxScroll = scrollFrame:GetVerticalScrollRange()
    if maxScroll > 0 then
      scrollFrame:SetVerticalScroll((value / 100) * maxScroll)
    end
  end)
  
  scrollFrame:SetScript("OnVerticalScroll", function()
    local maxScroll = scrollFrame:GetVerticalScrollRange()
    if maxScroll > 0 then
      local current = scrollFrame:GetVerticalScroll()
      scrollBar:SetValue((current / maxScroll) * 100)
    else
      scrollBar:SetValue(0)
    end
  end)
  
  panel.scrollFrame = scrollFrame
  panel.scrollChild = scrollChild
  panel.scrollBar = scrollBar
  panel.leaderEntries = {}
  panel.isWeekly = isWeekly
end

function LeafVE.UI:RefreshLeaderboard(panelName)
  if not self.panels or not self.panels[panelName] then return end
  
  local panel = self.panels[panelName]
  local isWeekly = panel.isWeekly
  
  EnsureDB()
  LeafVE:UpdateGuildRosterCache()
  
  local leaders = {}
  
  if isWeekly then
    local weekAgg = AggForThisWeek()
    for _, guildInfo in pairs(LeafVE.guildRosterCache) do
      local name = guildInfo.name
      local pts = weekAgg[name] or {L = 0, G = 0, S = 0}
      local total = (pts.L or 0) + (pts.G or 0) + (pts.S or 0)
      
      table.insert(leaders, {
        name = name, total = total,
        L = pts.L or 0, G = pts.G or 0, S = pts.S or 0,
        class = guildInfo.class or "Unknown"
      })
    end
  else
    for _, guildInfo in pairs(LeafVE.guildRosterCache) do
      local name = guildInfo.name
      local pts = LeafVE_DB.alltime[name] or {L = 0, G = 0, S = 0}
      local total = (pts.L or 0) + (pts.G or 0) + (pts.S or 0)
      
      table.insert(leaders, {
        name = name, total = total,
        L = pts.L or 0, G = pts.G or 0, S = pts.S or 0,
        class = guildInfo.class or "Unknown"
      })
    end
  end
  
  table.sort(leaders, function(a, b)
    if a.total == b.total then
      return Lower(a.name) < Lower(b.name)
    end
    return a.total > b.total
  end)
  
  for i = 1, table.getn(panel.leaderEntries) do
    panel.leaderEntries[i]:Hide()
  end
  
  local scrollChild = panel.scrollChild
  local yOffset = -5
  local entryHeight = 40
  
  local maxShow = math.min(20, table.getn(leaders))
  
  if table.getn(leaders) == 0 then
    if not panel.noDataText then
      local noDataText = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      noDataText:SetPoint("TOP", scrollChild, "TOP", 0, -20)
      noDataText:SetText("|cFF888888No data available yet|r")
      panel.noDataText = noDataText
    end
    panel.noDataText:Show()
  else
    if panel.noDataText then
      panel.noDataText:Hide()
    end
    
    for i = 1, maxShow do
      local leader = leaders[i]
      local frame = panel.leaderEntries[i]
      
      if not frame then
        frame = CreateFrame("Frame", nil, scrollChild)
        frame:SetWidth(480)
        frame:SetHeight(entryHeight)
        
        local rankIcon = frame:CreateTexture(nil, "ARTWORK")
        rankIcon:SetWidth(32)
        rankIcon:SetHeight(32)
        rankIcon:SetPoint("LEFT", frame, "LEFT", 5, 0)
        frame.rankIcon = rankIcon
        
        local rank = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        rank:SetPoint("LEFT", frame, "LEFT", 5, 0)
        rank:SetWidth(30)
        rank:SetJustifyH("RIGHT")
        frame.rank = rank
        
        local nameText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        nameText:SetPoint("LEFT", rank, "RIGHT", 40, 0)
        nameText:SetWidth(150)
        nameText:SetJustifyH("LEFT")
        frame.nameText = nameText
        
        local pointsText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        pointsText:SetPoint("LEFT", nameText, "RIGHT", 10, 0)
        pointsText:SetWidth(250)
        pointsText:SetJustifyH("LEFT")
        frame.pointsText = pointsText
        
        local bg = frame:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(frame)
        bg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
        bg:SetVertexColor(0.1, 0.1, 0.1, 0.3)
        frame.bg = bg
        
        table.insert(panel.leaderEntries, frame)
      end
      
      frame:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 5, yOffset)
      
      local rankColor = {1, 1, 1}
      
      if i <= 3 and PVP_RANK_ICONS[i] then
        frame.rankIcon:SetTexture(PVP_RANK_ICONS[i])
        if frame.rankIcon:GetTexture() then
          frame.rankIcon:Show()
          frame.rank:Hide()
        else
          frame.rankIcon:Hide()
          frame.rank:Show()
          frame.rank:SetText("#"..i)
          frame.rank:SetTextColor(rankColor[1], rankColor[2], rankColor[3])
        end
      else
        frame.rankIcon:Hide()
        frame.rank:Show()
        frame.rank:SetText("#"..i)
        frame.rank:SetTextColor(rankColor[1], rankColor[2], rankColor[3])
      end
      
      local class = string.upper(leader.class or "UNKNOWN")
      local classColor = CLASS_COLORS[class] or {1, 1, 1}
      frame.nameText:SetText(leader.name)
      frame.nameText:SetTextColor(classColor[1], classColor[2], classColor[3])
      
      frame.pointsText:SetText(string.format("|cFFFFD700%d pts|r  (L:%d G:%d S:%d)", leader.total, leader.L, leader.G, leader.S))
      
      frame:Show()
      yOffset = yOffset - entryHeight - 3
    end
  end
  
  scrollChild:SetHeight(math.max(1, math.abs(yOffset) + 50))
  
  local scrollRange = panel.scrollFrame:GetVerticalScrollRange()
  if scrollRange > 0 then
    panel.scrollBar:Show()
  else
    panel.scrollBar:Hide()
  end
  
  panel.scrollFrame:SetVerticalScroll(0)
  panel.scrollBar:SetValue(0)
end

local function BuildRosterPanel(panel)
  local h = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  h:SetPoint("TOP", panel, "TOP", 0, -10)
  h:SetText("|cFFFFD700Guild Roster|r")
  
  local subtitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  subtitle:SetPoint("TOP", h, "BOTTOM", 0, -3)
  subtitle:SetText("|cFF888888Click a member to view their achievements and badges|r")
  
  -- SEARCH BAR
  local searchLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  searchLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, -45)
  searchLabel:SetText("Search:")
  
  local searchBox = CreateFrame("EditBox", nil, panel)
  searchBox:SetPoint("LEFT", searchLabel, "RIGHT", 5, 0)
  searchBox:SetWidth(200)
  searchBox:SetHeight(20)
  searchBox:SetAutoFocus(false)
  searchBox:SetFontObject(GameFontHighlight)
  searchBox:SetMaxLetters(50)
  
  local searchBG = CreateFrame("Frame", nil, panel)
  searchBG:SetPoint("TOPLEFT", searchBox, "TOPLEFT", -5, 5)
  searchBG:SetPoint("BOTTOMRIGHT", searchBox, "BOTTOMRIGHT", 5, -5)
  searchBG:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = {left = 3, right = 3, top = 3, bottom = 3}
  })
  searchBG:SetBackdropColor(0, 0, 0, 0.5)
  searchBG:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
  searchBG:SetFrameLevel(searchBox:GetFrameLevel() - 1)
  
  searchBox:SetScript("OnEscapePressed", function() 
    this:ClearFocus() 
  end)
  
  searchBox:SetScript("OnTextChanged", function()
    if LeafVE.UI and LeafVE.UI.RefreshRoster then
      LeafVE.UI:RefreshRoster()
    end
  end)
  
  panel.searchBox = searchBox
  
  -- Clear button
  local clearBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
  clearBtn:SetPoint("LEFT", searchBox, "RIGHT", 5, 0)
  clearBtn:SetWidth(50)
  clearBtn:SetHeight(20)
  clearBtn:SetText("Clear")
  SkinButtonAccent(clearBtn)
  
  clearBtn:SetScript("OnClick", function()
    panel.searchBox:SetText("")
    panel.searchBox:ClearFocus()
    if LeafVE.UI and LeafVE.UI.RefreshRoster then
      LeafVE.UI:RefreshRoster()
    end
  end)
  
  -- SCROLL FRAME (moved down for search bar)
  local scrollFrame = CreateFrame("ScrollFrame", nil, panel)
  scrollFrame:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, -75)
  scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -30, 12)
  scrollFrame:EnableMouse(true)
  scrollFrame:EnableMouseWheel(true)
  
  local scrollChild = CreateFrame("Frame", nil, scrollFrame)
  scrollChild:SetWidth(500)
  scrollChild:SetHeight(1)
  scrollFrame:SetScrollChild(scrollChild)
  
  scrollFrame:SetScript("OnMouseWheel", function()
    local current = scrollFrame:GetVerticalScroll()
    local maxScroll = scrollFrame:GetVerticalScrollRange()
    local newScroll = current - (arg1 * 40)
    if newScroll < 0 then newScroll = 0 end
    if newScroll > maxScroll then newScroll = maxScroll end
    scrollFrame:SetVerticalScroll(newScroll)
  end)
  
  local scrollBar = CreateFrame("Slider", nil, panel)
  scrollBar:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -8, -75)
  scrollBar:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -8, 12)
  scrollBar:SetWidth(16)
  scrollBar:SetOrientation("VERTICAL")
  scrollBar:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
  scrollBar:SetMinMaxValues(0, 100)
  scrollBar:SetValue(0)
  
  local thumb = scrollBar:GetThumbTexture()
  thumb:SetWidth(16)
  thumb:SetHeight(24)
  
  scrollBar:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 8, edgeSize = 8,
    insets = {left = 2, right = 2, top = 2, bottom = 2}
  })
  scrollBar:SetBackdropColor(0, 0, 0, 0.3)
  scrollBar:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
  
  scrollBar:SetScript("OnValueChanged", function()
    local value = scrollBar:GetValue()
    local maxScroll = scrollFrame:GetVerticalScrollRange()
    if maxScroll > 0 then
      scrollFrame:SetVerticalScroll((value / 100) * maxScroll)
    end
  end)
  
  scrollFrame:SetScript("OnVerticalScroll", function()
    local maxScroll = scrollFrame:GetVerticalScrollRange()
    if maxScroll > 0 then
      local current = scrollFrame:GetVerticalScroll()
      scrollBar:SetValue((current / maxScroll) * 100)
    else
      scrollBar:SetValue(0)
    end
  end)
  
  panel.scrollFrame = scrollFrame
  panel.scrollChild = scrollChild
  panel.scrollBar = scrollBar
  panel.rosterButtons = {}
end

function LeafVE.UI:RefreshRoster()
  if not self.panels or not self.panels.roster then return end
  
  EnsureDB()
  LeafVE:UpdateGuildRosterCache()
  
  -- GET SEARCH TEXT
  local searchText = ""
  if self.panels.roster.searchBox then
    searchText = Lower(Trim(self.panels.roster.searchBox:GetText() or ""))
  end
  
  local members = {}
  for _, info in pairs(LeafVE.guildRosterCache) do
    -- FILTER BY SEARCH TEXT
    if searchText == "" or string.find(Lower(info.name), searchText, 1, true) then
      table.insert(members, info)
    end
  end
  
  table.sort(members, function(a, b)
    if a.online ~= b.online then
      return a.online
    end
    return Lower(a.name) < Lower(b.name)
  end)
  
  for i = 1, table.getn(self.panels.roster.rosterButtons) do
    self.panels.roster.rosterButtons[i]:Hide()
  end
  
  local scrollChild = self.panels.roster.scrollChild
  local yOffset = -5
  local buttonHeight = 28
  
  for i = 1, table.getn(members) do
    local member = members[i]
    local btn = self.panels.roster.rosterButtons[i]
    
    if not btn then
      btn = CreateFrame("Button", nil, scrollChild)
      btn:SetWidth(480)
      btn:SetHeight(buttonHeight)
      
      local text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      text:SetPoint("LEFT", btn, "LEFT", 5, 0)
      text:SetWidth(475)
      text:SetJustifyH("LEFT")
      btn.text = text
      
      local bg = btn:CreateTexture(nil, "BACKGROUND")
      bg:SetAllPoints(btn)
      bg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
      bg:SetVertexColor(0.1, 0.1, 0.1, 0.5)
      bg:SetAlpha(0)
      btn.bg = bg
      
      btn:SetScript("OnEnter", function() this.bg:SetAlpha(0.8) end)
      btn:SetScript("OnLeave", function() this.bg:SetAlpha(0) end)
      
      table.insert(self.panels.roster.rosterButtons, btn)
    end
    
    btn:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 5, yOffset)
    
    local class = string.upper(member.class or "UNKNOWN")
    local classColor = CLASS_COLORS[class] or {1, 1, 1}
    
    local onlineIndicator = member.online and "|cFF00FF00●|r " or "|cFF888888●|r "
    
    btn.text:SetText(string.format("%s%s - Lvl %s %s", onlineIndicator, member.name, tostring(member.level), member.rank))
    btn.text:SetTextColor(classColor[1], classColor[2], classColor[3])
    
    btn.playerName = member.name
    btn:SetScript("OnClick", function()
      if LeafVE.UI.cardCurrentPlayer ~= this.playerName then
        LeafVE.UI:ShowPlayerCard(this.playerName)
      end
    end)
    
    btn:Show()
    yOffset = yOffset - buttonHeight
  end
  
  scrollChild:SetHeight(math.max(1, math.abs(yOffset) + 50))
  
  local scrollRange = self.panels.roster.scrollFrame:GetVerticalScrollRange()
  if scrollRange > 0 then
    self.panels.roster.scrollBar:Show()
  else
    self.panels.roster.scrollBar:Hide()
  end
  
  self.panels.roster.scrollFrame:SetVerticalScroll(0)
  self.panels.roster.scrollBar:SetValue(0)
end

local function BuildHistoryPanel(panel)
  local h = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  h:SetPoint("TOP", panel, "TOP", 0, -10)
  h:SetText("|cFFFFD700Point History|r")
  
  local subtitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  subtitle:SetPoint("TOP", h, "BOTTOM", 0, -3)
  subtitle:SetText("|cFF888888Complete log of all your point transactions|r")
  
  local scrollFrame = CreateFrame("ScrollFrame", nil, panel)
  scrollFrame:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, -45)
  scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -30, 12)
  scrollFrame:EnableMouse(true)
  scrollFrame:EnableMouseWheel(true)
  
  local scrollChild = CreateFrame("Frame", nil, scrollFrame)
  scrollChild:SetWidth(500)
  scrollChild:SetHeight(1)
  scrollFrame:SetScrollChild(scrollChild)
  
  scrollFrame:SetScript("OnMouseWheel", function()
    local current = scrollFrame:GetVerticalScroll()
    local maxScroll = scrollFrame:GetVerticalScrollRange()
    local newScroll = current - (arg1 * 40)
    if newScroll < 0 then newScroll = 0 end
    if newScroll > maxScroll then newScroll = maxScroll end
    scrollFrame:SetVerticalScroll(newScroll)
  end)
  
  local scrollBar = CreateFrame("Slider", nil, panel)
  scrollBar:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -8, -45)
  scrollBar:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -8, 12)
  scrollBar:SetWidth(16)
  scrollBar:SetOrientation("VERTICAL")
  scrollBar:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
  scrollBar:SetMinMaxValues(0, 100)
  scrollBar:SetValue(0)
  
  local thumb = scrollBar:GetThumbTexture()
  thumb:SetWidth(16)
  thumb:SetHeight(24)
  
  scrollBar:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 8, edgeSize = 8,
    insets = {left = 2, right = 2, top = 2, bottom = 2}
  })
  scrollBar:SetBackdropColor(0, 0, 0, 0.3)
  scrollBar:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
  
  scrollBar:SetScript("OnValueChanged", function()
    local value = scrollBar:GetValue()
    local maxScroll = scrollFrame:GetVerticalScrollRange()
    if maxScroll > 0 then
      scrollFrame:SetVerticalScroll((value / 100) * maxScroll)
    end
  end)
  
  scrollFrame:SetScript("OnVerticalScroll", function()
    local maxScroll = scrollFrame:GetVerticalScrollRange()
    if maxScroll > 0 then
      local current = scrollFrame:GetVerticalScroll()
      scrollBar:SetValue((current / maxScroll) * 100)
    else
      scrollBar:SetValue(0)
    end
  end)
  
  panel.scrollFrame = scrollFrame
  panel.scrollChild = scrollChild
  panel.scrollBar = scrollBar
  panel.historyEntries = {}
end

local function BuildBadgesPanel(panel)
  -- Title
  local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("TOP", panel, "TOP", 0, -10)
  title:SetText("|cFFFFD700Milestone Badges|r")
  
  local subtitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  subtitle:SetPoint("TOP", title, "BOTTOM", 0, -3)
  subtitle:SetText("|cFF888888Earn badges by completing milestones and challenges|r")
  
  -- Scroll frame
  local scrollFrame = CreateFrame("ScrollFrame", nil, panel)
  scrollFrame:SetPoint("TOPLEFT", panel, "TOPLEFT", 5, -45)
  scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -25, 5)
  panel.scrollFrame = scrollFrame
  
  local scrollChild = CreateFrame("Frame", nil, scrollFrame)
  scrollChild:SetWidth(scrollFrame:GetWidth())
  scrollChild:SetHeight(1)
  scrollFrame:SetScrollChild(scrollChild)
  panel.scrollChild = scrollChild
  
  -- Scroll bar
  local scrollBar = CreateFrame("Slider", nil, scrollFrame)
  scrollBar:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -5, -50)
  scrollBar:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -5, 10)
  scrollBar:SetWidth(16)
  scrollBar:SetOrientation("VERTICAL")
  scrollBar:SetMinMaxValues(0, 100)
  scrollBar:SetValue(0)
  scrollBar:SetValueStep(1)
  panel.scrollBar = scrollBar
  
  local scrollBg = scrollBar:CreateTexture(nil, "BACKGROUND")
  scrollBg:SetAllPoints(scrollBar)
  scrollBg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
  scrollBg:SetVertexColor(0.2, 0.2, 0.2, 0.8)
  
  local scrollThumb = scrollBar:CreateTexture(nil, "OVERLAY")
  scrollThumb:SetWidth(16)
  scrollThumb:SetHeight(30)
  scrollThumb:SetTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
  scrollBar:SetThumbTexture(scrollThumb)
  
  scrollBar:SetScript("OnValueChanged", function()
    local val = this:GetValue()
    scrollFrame:SetVerticalScroll(val)
  end)
  
  scrollFrame:SetScript("OnVerticalScroll", function()
    local offset = arg1
    local scrollRange = scrollFrame:GetVerticalScrollRange()
    if scrollRange > 0 then
      scrollBar:SetMinMaxValues(0, scrollRange)
      scrollBar:SetValue(offset)
      scrollBar:Show()
    else
      scrollBar:Hide()
    end
  end)
  
  panel.badgeFrames = {}
end

local function BuildAchievementsPanel(panel)
  local h = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  h:SetPoint("TOP", panel, "TOP", 0, -10)
  h:SetText("|cFFFFD700Achievements|r")
  
  local subtitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  subtitle:SetPoint("TOP", h, "BOTTOM", 0, -3)
  subtitle:SetText("|cFF888888Complete challenges to earn achievement points and titles|r")
  
  local scrollFrame = CreateFrame("ScrollFrame", nil, panel)
  scrollFrame:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, -45)
  scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -30, 12)
  scrollFrame:EnableMouse(true)
  scrollFrame:EnableMouseWheel(true)
  
  local scrollChild = CreateFrame("Frame", nil, scrollFrame)
  scrollChild:SetWidth(500)
  scrollChild:SetHeight(1)
  scrollFrame:SetScrollChild(scrollChild)
  
  scrollFrame:SetScript("OnMouseWheel", function()
    local current = scrollFrame:GetVerticalScroll()
    local maxScroll = scrollFrame:GetVerticalScrollRange()
    local newScroll = current - (arg1 * 40)
    if newScroll < 0 then newScroll = 0 end
    if newScroll > maxScroll then newScroll = maxScroll end
    scrollFrame:SetVerticalScroll(newScroll)
  end)
  
  local scrollBar = CreateFrame("Slider", nil, panel)
  scrollBar:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -8, -45)
  scrollBar:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -8, 12)
  scrollBar:SetWidth(16)
  scrollBar:SetOrientation("VERTICAL")
  scrollBar:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
  scrollBar:SetMinMaxValues(0, 100)
  scrollBar:SetValue(0)
  
  local thumb = scrollBar:GetThumbTexture()
  thumb:SetWidth(16)
  thumb:SetHeight(24)
  
  scrollBar:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 8, edgeSize = 8,
    insets = {left = 2, right = 2, top = 2, bottom = 2}
  })
  scrollBar:SetBackdropColor(0, 0, 0, 0.3)
  scrollBar:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
  
  scrollBar:SetScript("OnValueChanged", function()
    local value = scrollBar:GetValue()
    local maxScroll = scrollFrame:GetVerticalScrollRange()
    if maxScroll > 0 then
      scrollFrame:SetVerticalScroll((value / 100) * maxScroll)
    end
  end)
  
  scrollFrame:SetScript("OnVerticalScroll", function()
    local maxScroll = scrollFrame:GetVerticalScrollRange()
    if maxScroll > 0 then
      local current = scrollFrame:GetVerticalScroll()
      scrollBar:SetValue((current / maxScroll) * 100)
    else
      scrollBar:SetValue(0)
    end
  end)
  
  panel.scrollFrame = scrollFrame
  panel.scrollChild = scrollChild
  panel.scrollBar = scrollBar
  panel.achEntries = {}
end

function LeafVE.UI:RefreshHistory()
  if not self.panels or not self.panels.history then return end
  local panel = self.panels.history

  local me = ShortName(UnitName("player"))
  local history = LeafVE:GetHistory(me, 100)

  for i = 1, table.getn(panel.historyEntries) do
    panel.historyEntries[i]:Hide()
  end

  local scrollChild = panel.scrollChild
  local yOffset = -5
  local entryHeight = 30

  if table.getn(history) == 0 then
    if not panel.noHistoryText then
      local noHistoryText = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      noHistoryText:SetPoint("TOP", scrollChild, "TOP", 0, -20)
      noHistoryText:SetText("|cFF888888No history yet|r")
      panel.noHistoryText = noHistoryText
    end
    panel.noHistoryText:Show()
  else
    if panel.noHistoryText then
      panel.noHistoryText:Hide()
    end

    for i = 1, table.getn(history) do
      local entry = history[i]
      local frame = panel.historyEntries[i]

      if not frame then
        frame = CreateFrame("Frame", nil, scrollChild)
        frame:SetWidth(480)
        frame:SetHeight(entryHeight)

        local dateText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        dateText:SetPoint("LEFT", frame, "LEFT", 5, 0)
        dateText:SetWidth(100)
        dateText:SetJustifyH("LEFT")
        frame.dateText = dateText

        local typeIcon = frame:CreateTexture(nil, "ARTWORK")
        typeIcon:SetWidth(16)
        typeIcon:SetHeight(16)
        typeIcon:SetPoint("LEFT", dateText, "RIGHT", 5, 0)
        frame.typeIcon = typeIcon

        local amountText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        amountText:SetPoint("LEFT", typeIcon, "RIGHT", 5, 0)
        amountText:SetWidth(40)
        amountText:SetJustifyH("LEFT")
        frame.amountText = amountText

        local reasonText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        reasonText:SetPoint("LEFT", amountText, "RIGHT", 10, 0)
        reasonText:SetWidth(280)
        reasonText:SetJustifyH("LEFT")
        frame.reasonText = reasonText

        local bg = frame:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(frame)
        bg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
        bg:SetVertexColor(0.1, 0.1, 0.1, 0.3)
        frame.bg = bg

        table.insert(panel.historyEntries, frame)
      end

      frame:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 5, yOffset)

      frame.dateText:SetText(date("%m/%d %H:%M", entry.timestamp))

      local typeColor = {1, 1, 1}
      if entry.type == "L" then
        frame.typeIcon:SetTexture(LEAF_EMBLEM)
        typeColor = THEME.leaf
      elseif entry.type == "G" then
        frame.typeIcon:SetTexture("Interface\\Icons\\INV_Misc_GroupLooking")
        typeColor = THEME.gold
      elseif entry.type == "S" then
        frame.typeIcon:SetTexture("Interface\\Icons\\INV_Misc_Note_01")
        typeColor = THEME.gold
      end

      if not frame.typeIcon:GetTexture() then
        frame.typeIcon:SetTexture(LEAF_FALLBACK)
      end
      frame.typeIcon:SetVertexColor(typeColor[1], typeColor[2], typeColor[3])

      frame.amountText:SetText("|cFFFFD700+"..entry.amount.."|r")
      frame.reasonText:SetText(entry.reason or "")

      frame:Show()
      yOffset = yOffset - entryHeight
    end
  end

  scrollChild:SetHeight(math.max(1, math.abs(yOffset) + 50))

  local scrollRange = panel.scrollFrame:GetVerticalScrollRange()
  if scrollRange > 0 then
    panel.scrollBar:Show()
  else
    panel.scrollBar:Hide()
  end

  panel.scrollFrame:SetVerticalScroll(0)
  panel.scrollBar:SetValue(0)
end

function LeafVE.UI:RefreshBadges()
  if not self.panels or not self.panels.badges then 
    Print("ERROR: panels.badges not found")
    return 
  end
  local panel = self.panels.badges

  local me = ShortName(UnitName("player"))
  EnsureDB()

  local myBadges = LeafVE_DB.badges[me] or {}

  -- Safety check: ensure badgeFrames exists
  if not panel.badgeFrames then
    panel.badgeFrames = {}
  end

  for i = 1, table.getn(panel.badgeFrames) do
    panel.badgeFrames[i]:Hide()
  end

  local scrollChild = panel.scrollChild

  -- Ensure scrollChild is properly configured
  if not scrollChild then
    Print("ERROR: scrollChild doesn't exist!")
    return
  end

  scrollChild:ClearAllPoints()
  scrollChild:SetPoint("TOPLEFT", panel.scrollFrame, "TOPLEFT", 0, 0)
  scrollChild:SetWidth(panel.scrollFrame:GetWidth() or 500)
  scrollChild:Show()

  local yOffset = -10
  local badgeSize = 80
  local xSpacing = 90
  local ySpacing = 110
  local perRow = 4

  local allBadges = {}
  for i = 1, table.getn(BADGES) do
    local badge = BADGES[i]
    local earned = myBadges[badge.id] ~= nil
    table.insert(allBadges, {
      id = badge.id,
      name = badge.name,
      desc = badge.desc,
      icon = badge.icon,
      earned = earned,
      earnedAt = myBadges[badge.id]
    })
  end

  if table.getn(allBadges) == 0 then
    if not panel.noBadgesText then
      local noBadgesText = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      noBadgesText:SetPoint("TOP", scrollChild, "TOP", 0, -20)
      noBadgesText:SetText("|cFF888888No badges available yet|r")
      panel.noBadgesText = noBadgesText
    end
    panel.noBadgesText:Show()
  else
    if panel.noBadgesText then
      panel.noBadgesText:Hide()
    end

    local row = 0
    local col = 0

    for i = 1, table.getn(allBadges) do
      local badge = allBadges[i]
      local frame = panel.badgeFrames[i]

      if not frame then
        frame = CreateFrame("Frame", nil, scrollChild)
        frame:SetWidth(badgeSize)
        frame:SetHeight(badgeSize)
        
        -- ENABLE MOUSE INTERACTION (CRITICAL FOR TOOLTIPS!)
        frame:EnableMouse(true)

        local icon = frame:CreateTexture(nil, "ARTWORK")
        icon:SetWidth(badgeSize - 10)
        icon:SetHeight(badgeSize - 10)
        icon:SetPoint("CENTER", frame, "CENTER", 0, 0)
        frame.icon = icon

        local nameText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        nameText:SetPoint("TOP", frame, "BOTTOM", 0, -2)
        nameText:SetWidth(badgeSize + 20)
        nameText:SetJustifyH("CENTER")
        frame.nameText = nameText

        table.insert(panel.badgeFrames, frame)
      end
      
      -- Update tooltip scripts every refresh (in case badge data changes)
      frame:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:SetText(this.badgeName, THEME.gold[1], THEME.gold[2], THEME.gold[3], 1, true)
        GameTooltip:AddLine(this.badgeDesc, 1, 1, 1, true)
        if this.earnedAt then
          GameTooltip:AddLine(" ", 1, 1, 1)
          GameTooltip:AddLine("Earned: "..date("%m/%d/%Y", this.earnedAt), 0.5, 0.8, 0.5)
        else
          GameTooltip:AddLine(" ", 1, 1, 1)
          GameTooltip:AddLine("Not yet earned", 0.6, 0.6, 0.6)
        end
        GameTooltip:Show()
      end)
      
      frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
      end)
      
      -- CALCULATE POSITION
      local xPos = 10 + (col * xSpacing)
      local yPos = yOffset - (row * ySpacing)

      -- Clear any existing points before setting new position
      frame:ClearAllPoints()
      frame:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", xPos, yPos)

      -- SET ICON AND STYLE
      frame.icon:SetTexture(badge.icon)
      if not frame.icon:GetTexture() then
        frame.icon:SetTexture(LEAF_FALLBACK)
      end

      if badge.earned then
        frame.icon:SetVertexColor(1, 1, 1, 1)
        frame.nameText:SetText(badge.name)
        frame.nameText:SetTextColor(THEME.gold[1], THEME.gold[2], THEME.gold[3])
      else
        frame.icon:SetVertexColor(0.3, 0.3, 0.3, 1)
        frame.nameText:SetText(badge.name)
        frame.nameText:SetTextColor(0.5, 0.5, 0.5)
      end

      frame.badgeName = badge.name
      frame.badgeDesc = badge.desc
      frame.earnedAt = badge.earnedAt

      frame:Show()

      -- INCREMENT COLUMN/ROW
      col = col + 1
      if col >= perRow then
        col = 0
        row = row + 1
      end
    end

    -- Set scroll height based on total rows needed
    local totalRows = math.ceil(table.getn(allBadges) / perRow)
    local totalHeight = (totalRows * ySpacing) + 50
    scrollChild:SetHeight(totalHeight)
  end

  -- Update scrollbar visibility
  local scrollRange = panel.scrollFrame:GetVerticalScrollRange()
  if scrollRange > 0 then
    panel.scrollBar:Show()
  else
    panel.scrollBar:Hide()
  end

  panel.scrollFrame:SetVerticalScroll(0)
  panel.scrollBar:SetValue(0)
end

function LeafVE.UI:RefreshAchievementsLeaderboard()
  if not self.panels or not self.panels.achievements then return end
  local panel = self.panels.achievements

  EnsureDB()
  LeafVE:UpdateGuildRosterCache()

  local leaders = {}

  for _, guildInfo in pairs(LeafVE.guildRosterCache) do
    local name = guildInfo.name
    local achPoints = 0

    if LeafVE_AchTest_DB and LeafVE_AchTest_DB.achievements and LeafVE_AchTest_DB.achievements[name] then
      for achId, achData in pairs(LeafVE_AchTest_DB.achievements[name]) do
        if type(achData) == "table" and achData.points then
          achPoints = achPoints + achData.points
        end
      end
    end

    if achPoints > 0 then
      table.insert(leaders, {
        name = name,
        points = achPoints,
        class = guildInfo.class or "Unknown"
      })
    end
  end

  table.sort(leaders, function(a, b)
    if a.points == b.points then
      return Lower(a.name) < Lower(b.name)
    end
    return a.points > b.points
  end)

  for i = 1, table.getn(panel.achEntries) do
    panel.achEntries[i]:Hide()
  end

  local scrollChild = panel.scrollChild
  local yOffset = -5
  local entryHeight = 40

  local maxShow = math.min(20, table.getn(leaders))

  if table.getn(leaders) == 0 then
    if not panel.noDataText then
      local noDataText = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      noDataText:SetPoint("TOP", scrollChild, "TOP", 0, -20)
      noDataText:SetText("|cFF888888No achievement data available yet|r")
      panel.noDataText = noDataText
    end
    panel.noDataText:Show()
  else
    if panel.noDataText then
      panel.noDataText:Hide()
    end

    for i = 1, maxShow do
      local leader = leaders[i]
      local frame = panel.achEntries[i]
      if not frame then
        frame = CreateFrame("Frame", nil, scrollChild)
        frame:SetWidth(480)
        frame:SetHeight(entryHeight)

        local rankIcon = frame:CreateTexture(nil, "ARTWORK")
        rankIcon:SetWidth(32)
        rankIcon:SetHeight(32)
        rankIcon:SetPoint("LEFT", frame, "LEFT", 5, 0)
        frame.rankIcon = rankIcon

        local rank = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        rank:SetPoint("LEFT", frame, "LEFT", 5, 0)
        rank:SetWidth(30)
        rank:SetJustifyH("RIGHT")
        frame.rank = rank

        local nameText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        nameText:SetPoint("LEFT", rank, "RIGHT", 40, 0)
        nameText:SetWidth(200)
        nameText:SetJustifyH("LEFT")
        frame.nameText = nameText

        local pointsText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        pointsText:SetPoint("LEFT", nameText, "RIGHT", 10, 0)
        pointsText:SetWidth(200)
        pointsText:SetJustifyH("LEFT")
        frame.pointsText = pointsText

        local bg = frame:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(frame)
        bg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
        bg:SetVertexColor(0.1, 0.1, 0.1, 0.3)
        frame.bg = bg

        table.insert(panel.achEntries, frame)
      end

      frame:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 5, yOffset)

      -- Show PVP rank icons for top 3, numbers for rest
      if i <= 3 and PVP_RANK_ICONS[i] then
        frame.rankIcon:SetTexture(PVP_RANK_ICONS[i])
        if frame.rankIcon:GetTexture() then
          frame.rankIcon:Show()
          frame.rank:Hide()
        else
          frame.rankIcon:Hide()
          frame.rank:Show()
          frame.rank:SetText("#"..i)
          frame.rank:SetTextColor(1, 1, 1)
        end
      else
        frame.rankIcon:Hide()
        frame.rank:Show()
        frame.rank:SetText("#"..i)
        frame.rank:SetTextColor(1, 1, 1)
      end

      local class = string.upper(leader.class or "UNKNOWN")
      local classColor = CLASS_COLORS[class] or {1, 1, 1}
      frame.nameText:SetText(leader.name)
      frame.nameText:SetTextColor(classColor[1], classColor[2], classColor[3])

      frame.pointsText:SetText("|cFFFFD700"..leader.points.." achievement pts|r")

      frame:Show()
      yOffset = yOffset - entryHeight - 3
    end
  end

  scrollChild:SetHeight(math.max(1, math.abs(yOffset) + 50))

  local scrollRange = panel.scrollFrame:GetVerticalScrollRange()
  if scrollRange > 0 then
    panel.scrollBar:Show()
  else
    panel.scrollBar:Hide()
  end

  panel.scrollFrame:SetVerticalScroll(0)
  panel.scrollBar:SetValue(0)
end

function LeafVE.UI:Build()
  if self.frame then return end
  
  EnsureDB()
  
  local f = CreateFrame("Frame", nil, UIParent)
  self.frame = f
  f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
  
  local w = LeafVE_DB.ui.w or 1050
  local h = LeafVE_DB.ui.h or 699  -- ← CHANGED TO 699
  
  if w < 950 then w = 950 end
  if w > 1400 then w = 1400 end
  if h < 600 then h = 600 end  
  if h > 1000 then h = 1000 end
  
  f:SetWidth(w)
  f:SetHeight(h)
  f:EnableMouse(true)
  f:SetMovable(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", function() f:StartMoving() end)
  f:SetScript("OnDragStop", function()
    f:StopMovingOrSizing()
    if LeafVE_DB and LeafVE_DB.ui then
      local point, _, relativePoint, x, y = f:GetPoint()
      LeafVE_DB.ui.point = point
      LeafVE_DB.ui.relativePoint = relativePoint
      LeafVE_DB.ui.x = x
      LeafVE_DB.ui.y = y
    end
  end)
  
  SkinFrameModern(f)
  MakeResizeHandle(f)
  
  f:SetScript("OnSizeChanged", function()
    if LeafVE_DB and LeafVE_DB.ui then
      LeafVE_DB.ui.w = f:GetWidth()
      LeafVE_DB.ui.h = f:GetHeight()
    end
  end)
  
  local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", f, "TOPLEFT", 40, -12)
  title:SetText("Leaf Village Legends")
  title:SetTextColor(THEME.white[1], THEME.white[2], THEME.white[3])
  
  local emblem = f:CreateTexture(nil, "ARTWORK")
  emblem:SetWidth(22)
  emblem:SetHeight(22)
  emblem:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -12)
  emblem:SetTexture(LEAF_EMBLEM)
  if not emblem:GetTexture() then emblem:SetTexture(LEAF_FALLBACK) end
  emblem:SetVertexColor(THEME.leaf[1], THEME.leaf[2], THEME.leaf[3], 1)
  
  local sub = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  sub:SetPoint("TOPLEFT", f, "TOPLEFT", 16, -34)
  sub:SetText("Auto-tracking: Login + Group Points")
  sub:SetTextColor(0.85, 0.88, 0.86)
  
  local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -6, -6)
  
  self.tabMe = TabButton(f, "My Stats", "LeafVE_TabMy")
  self.tabMe:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -52)
  self.tabMe:SetWidth(70)
  
  self.tabShoutouts = TabButton(f, "Shoutouts", "LeafVE_TabShoutouts")
  self.tabShoutouts:SetPoint("LEFT", self.tabMe, "RIGHT", 4, 0)
  self.tabShoutouts:SetWidth(75)
  
  self.tabLeaderWeek = TabButton(f, "Weekly", "LeafVE_TabLeaderWeek")
  self.tabLeaderWeek:SetPoint("LEFT", self.tabShoutouts, "RIGHT", 4, 0)
  self.tabLeaderWeek:SetWidth(60)
  
  self.tabLeaderLife = TabButton(f, "Lifetime", "LeafVE_TabLeaderLife")
  self.tabLeaderLife:SetPoint("LEFT", self.tabLeaderWeek, "RIGHT", 4, 0)
  self.tabLeaderLife:SetWidth(65)
  
  self.tabRoster = TabButton(f, "Roster", "LeafVE_TabRoster")
  self.tabRoster:SetPoint("LEFT", self.tabLeaderLife, "RIGHT", 4, 0)
  self.tabRoster:SetWidth(60)
  
  self.tabHistory = TabButton(f, "History", "LeafVE_TabHistory")
  self.tabHistory:SetPoint("LEFT", self.tabRoster, "RIGHT", 4, 0)
  self.tabHistory:SetWidth(60)
  
  self.tabBadges = TabButton(f, "Badges", "LeafVE_TabBadges")
  self.tabBadges:SetPoint("LEFT", self.tabHistory, "RIGHT", 4, 0)
  self.tabBadges:SetWidth(65)
  
  self.tabAchievements = TabButton(f, "Achievements", "LeafVE_TabAchievements")
  self.tabAchievements:SetPoint("LEFT", self.tabBadges, "RIGHT", 4, 0)
  self.tabAchievements:SetWidth(95)
  
  self.inset = CreateInset(f)
  self.inset:SetPoint("TOPLEFT", f, "TOPLEFT", 12, -80)
  self.inset:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -12, 12)
  
  self.left = CreateFrame("Frame", nil, self.inset)
  self.left:SetPoint("TOPLEFT", self.inset, "TOPLEFT", 0, 0)
  self.left:SetPoint("BOTTOMLEFT", self.inset, "BOTTOMLEFT", 0, 0)
  self.left:SetPoint("TOPRIGHT", self.inset, "TOPRIGHT", -470, 0)
  self.left:SetPoint("BOTTOMRIGHT", self.inset, "BOTTOMRIGHT", -470, 0)
  
  self:BuildPlayerCard(self.inset)
  
  -- Create all panels
  self.panels = {}
  
  self.panels.me = CreateFrame("Frame", nil, self.left)
  self.panels.me:SetAllPoints(self.left)
  BuildMyPanel(self.panels.me)
  
  self.panels.shoutouts = CreateFrame("Frame", nil, self.left)
  self.panels.shoutouts:SetAllPoints(self.left)
  BuildShoutoutsPanel(self.panels.shoutouts)
  
  self.panels.leaderWeek = CreateFrame("Frame", nil, self.left)
  self.panels.leaderWeek:SetAllPoints(self.left)
  BuildLeaderboardPanel(self.panels.leaderWeek, true)
  
  self.panels.leaderLife = CreateFrame("Frame", nil, self.left)
  self.panels.leaderLife:SetAllPoints(self.left)
  BuildLeaderboardPanel(self.panels.leaderLife, false)
  
  self.panels.roster = CreateFrame("Frame", nil, self.left)
  self.panels.roster:SetAllPoints(self.left)
  BuildRosterPanel(self.panels.roster)
  
  self.panels.history = CreateFrame("Frame", nil, self.left)
  self.panels.history:SetAllPoints(self.left)
  BuildHistoryPanel(self.panels.history)
  
  self.panels.badges = CreateFrame("Frame", nil, self.left)
  self.panels.badges:SetAllPoints(self.left)
  BuildBadgesPanel(self.panels.badges)
  
  self.panels.achievements = CreateFrame("Frame", nil, self.left)
  self.panels.achievements:SetAllPoints(self.left)
  BuildAchievementsPanel(self.panels.achievements)
  
  -- Tab click handlers
  self.tabMe:SetScript("OnClick", function()
    self.activeTab = "me"
    self:Refresh()
  end)
  
  self.tabShoutouts:SetScript("OnClick", function()
    self.activeTab = "shoutouts"
    self:Refresh()
  end)
  
  self.tabLeaderWeek:SetScript("OnClick", function()
    self.activeTab = "leaderWeek"
    self:Refresh()
  end)
  
  self.tabLeaderLife:SetScript("OnClick", function()
    self.activeTab = "leaderLife"
    self:Refresh()
  end)
  
  self.tabRoster:SetScript("OnClick", function()
    self.activeTab = "roster"
    self:Refresh()
  end)
  
  self.tabHistory:SetScript("OnClick", function()
    self.activeTab = "history"
    self:Refresh()
  end)
  
  self.tabBadges:SetScript("OnClick", function()
    self.activeTab = "badges"
    self:Refresh()
  end)
  
  self.tabAchievements:SetScript("OnClick", function()
    self.activeTab = "achievements"
    self:Refresh()
  end)
  
  -- Initial state - hide all panels except "me"
  self.activeTab = "me"
  
  self.panels.shoutouts:Hide()
  self.panels.leaderWeek:Hide()
  self.panels.leaderLife:Hide()
  self.panels.roster:Hide()
  self.panels.history:Hide()
  self.panels.badges:Hide()
  self.panels.achievements:Hide()
  
  self.panels.me:Show()
  
  local me = ShortName(UnitName("player"))
  if me then
    self:ShowPlayerCard(me)
  end
  
  if LeafVE_DB.ui.point and LeafVE_DB.ui.x and LeafVE_DB.ui.y then
    f:ClearAllPoints()
    f:SetPoint(LeafVE_DB.ui.point, UIParent, LeafVE_DB.ui.relativePoint or "CENTER", LeafVE_DB.ui.x, LeafVE_DB.ui.y)
  end
  
  f:Hide()
end

function LeafVE.UI:Refresh()
  EnsureDB()
  
  -- Safety check
  if not self.panels then 
    Print("ERROR: Panels not initialized!")
    return 
  end
  
  -- Hide all panels safely
  local panelNames = {"me", "shoutouts", "leaderWeek", "leaderLife", "roster", "history", "badges", "achievements"}
  for _, name in ipairs(panelNames) do
    if self.panels[name] and self.panels[name].Hide then
      self.panels[name]:Hide()
    end
  end
  
  -- Show active tab
  if self.activeTab == "me" and self.panels.me then
    self.panels.me:Show()
    local me = ShortName(UnitName("player") or "")
    if not me or me == "" then return end
    
    local day = DayKey()
    local dayT = (LeafVE_DB.global[day] and LeafVE_DB.global[day][me]) or {L = 0, G = 0, S = 0}
    
    if self.panels.me.todayStats then
      self.panels.me.todayStats:SetText(string.format(
        "Login: %d  |  Group: %d  |  Shoutouts: %d  |  |cFFFFD700Total: %d|r",
        dayT.L or 0, dayT.G or 0, dayT.S or 0, (dayT.L or 0) + (dayT.G or 0) + (dayT.S or 0)
      ))
    end
    
    local weekAgg = AggForThisWeek()
    local weekT = weekAgg[me] or {L = 0, G = 0, S = 0}
    if self.panels.me.weekStats then
      self.panels.me.weekStats:SetText(string.format(
        "Login: %d  |  Group: %d  |  Shoutouts: %d  |  |cFFFFD700Total: %d|r",
        weekT.L or 0, weekT.G or 0, weekT.S or 0, (weekT.L or 0) + (weekT.G or 0) + (weekT.S or 0)
      ))
    end
    
    local seasonT = LeafVE_DB.season[me] or {L = 0, G = 0, S = 0}
    if self.panels.me.seasonStats then
      self.panels.me.seasonStats:SetText(string.format(
        "Login: %d  |  Group: %d  |  Shoutouts: %d  |  |cFFFFD700Total: %d|r",
        seasonT.L or 0, seasonT.G or 0, seasonT.S or 0, (seasonT.L or 0) + (seasonT.G or 0) + (seasonT.S or 0)
      ))
    end
    
    local alltimeT = LeafVE_DB.alltime[me] or {L = 0, G = 0, S = 0}
    if self.panels.me.alltimeStats then
      self.panels.me.alltimeStats:SetText(string.format(
        "Login: %d  |  Group: %d  |  Shoutouts: %d  |  |cFFFFD700Total: %d|r",
        alltimeT.L or 0, alltimeT.G or 0, alltimeT.S or 0, (alltimeT.L or 0) + (alltimeT.G or 0) + (alltimeT.S or 0)
      ))
    end
  
    -- Calculate Last Week's Winner
    if self.panels.me.lastWeekWinner then
      local lastWeekStart = WeekStartTS(Now()) - (7 * SECONDS_PER_DAY)
      local lastWeekAgg = {}
      
      for d = 0, 6 do
        local dk = DayKeyFromTS(lastWeekStart + d * SECONDS_PER_DAY)
        if LeafVE_DB.global[dk] then
          for name, t in pairs(LeafVE_DB.global[dk]) do
            if not lastWeekAgg[name] then lastWeekAgg[name] = {L = 0, G = 0, S = 0} end
            lastWeekAgg[name].L = lastWeekAgg[name].L + (t.L or 0)
            lastWeekAgg[name].G = lastWeekAgg[name].G + (t.G or 0)
            lastWeekAgg[name].S = lastWeekAgg[name].S + (t.S or 0)
          end
        end
      end
      
      local winner = nil
      local maxPoints = 0
      for name, pts in pairs(lastWeekAgg) do
        local total = (pts.L or 0) + (pts.G or 0) + (pts.S or 0)
        if total > maxPoints then
          maxPoints = total
          winner = name
        end
      end
      
    if winner then
      self.panels.me.lastWeekWinner:SetText(string.format("%s with |cFFFFD700%d points|r", winner, maxPoints))
    else
      self.panels.me.lastWeekWinner:SetText("|cFF888888No data available|r")
    end
   end
    
    -- Calculate All-Time Leader
    if self.panels.me.alltimeLeader then
      local leader = nil
      local maxPoints = 0
      
      for name, pts in pairs(LeafVE_DB.alltime) do
        local total = (pts.L or 0) + (pts.G or 0) + (pts.S or 0)
        if total > maxPoints then
          maxPoints = total
          leader = name
        end
      end
      
    if leader then
      self.panels.me.alltimeLeader:SetText(string.format("%s with |cFFFFD700%d points|r", leader, maxPoints))
    else
      self.panels.me.alltimeLeader:SetText("|cFF888888No data available|r")
    end
   end
  
    -- Calculate Week Countdown
    if self.panels.me.weekCountdown then
      local weekStart = WeekStartTS(Now())
      local weekEnd = weekStart + (7 * SECONDS_PER_DAY)
      local timeLeft = weekEnd - Now()
      
    if timeLeft > 0 then
      local days = math.floor(timeLeft / SECONDS_PER_DAY)
      local hours = math.floor((timeLeft - (days * SECONDS_PER_DAY)) / SECONDS_PER_HOUR)
      local minutes = math.floor((timeLeft - (days * SECONDS_PER_DAY) - (hours * SECONDS_PER_HOUR)) / 60)
      
      self.panels.me.weekCountdown:SetText(string.format("|cFFFFD700%dd %dh %dm|r", days, hours, minutes))
    else
      self.panels.me.weekCountdown:SetText("|cFFFF0000Resetting now!|r")
    end
   end

  elseif self.activeTab == "shoutouts" and self.panels.shoutouts then
    self.panels.shoutouts:Show()
    local me = ShortName(UnitName("player"))
    if me then
      local today = DayKey()
      if not LeafVE_DB.shoutouts[me] then LeafVE_DB.shoutouts[me] = {} end
      local count = 0
      for tname, timestamp in pairs(LeafVE_DB.shoutouts[me]) do
        if DayKeyFromTS(timestamp) == today then count = count + 1 end
      end
      local remaining = SHOUTOUT_MAX_PER_DAY - count
      if self.panels.shoutouts.usageText then
        self.panels.shoutouts.usageText:SetText(string.format("Shoutouts remaining today: %d / %d", remaining, SHOUTOUT_MAX_PER_DAY))
      end
    end
    
  elseif self.activeTab == "leaderWeek" and self.panels.leaderWeek then
    self.panels.leaderWeek:Show()
    self:RefreshLeaderboard("leaderWeek")
    
  elseif self.activeTab == "leaderLife" and self.panels.leaderLife then
    self.panels.leaderLife:Show()
    self:RefreshLeaderboard("leaderLife")
    
  elseif self.activeTab == "roster" and self.panels.roster then
    self.panels.roster:Show()
    self:RefreshRoster()
    
  elseif self.activeTab == "history" and self.panels.history then
    self.panels.history:Show()
    self:RefreshHistory()
    
  elseif self.activeTab == "badges" and self.panels.badges then
    self.panels.badges:Show()
    self:RefreshBadges()
    
  elseif self.activeTab == "achievements" and self.panels.achievements then
    self.panels.achievements:Show()
    self:RefreshAchievementsLeaderboard()
  end
end

-------------------------------------------------
-- ERROR TRACKING SYSTEM
-------------------------------------------------
local function LogError(errorMsg, source)
  local timestamp = Now()
  local errorEntry = {
    message = errorMsg,
    source = source or "Unknown",
    timestamp = timestamp,
    dateStr = date("%m/%d %H:%M:%S", timestamp)
  }
  
  table.insert(LeafVE.errorLog, errorEntry)
  
  while table.getn(LeafVE.errorLog) > LeafVE.maxErrors do
    table.remove(LeafVE.errorLog, 1)
  end
end

local oldErrorHandler = geterrorhandler()
seterrorhandler(function(err)
  local stackTrace = debugstack(2)
  
  if string.find(stackTrace, "LeafVillageLegends") or string.find(tostring(err), "LeafVE") then
    LogError(tostring(err), "GlobalErrorHandler")
    Print("|cFFFF0000ERROR LOGGED:|r Use /lvedebug errors to view")
  end
  
  if oldErrorHandler then
    oldErrorHandler(err)
  end
end)

-------------------------------------------------
-- EVENT HANDLERS
-------------------------------------------------
local ef = CreateFrame("Frame")
ef:RegisterEvent("ADDON_LOADED")
ef:RegisterEvent("CHAT_MSG_ADDON")
ef:RegisterEvent("PLAYER_LOGIN")
ef:RegisterEvent("PARTY_MEMBERS_CHANGED")
ef:RegisterEvent("RAID_ROSTER_UPDATE")

local groupCheckTimer = 0
local notificationTimer = 0
local attendanceTimer = 0

ef:SetScript("OnEvent", function()
  if event == "ADDON_LOADED" and arg1 == LeafVE.name then
    EnsureDB()
    
    -- Safely register addon message prefixes
    if RegisterAddonMessagePrefix then
      RegisterAddonMessagePrefix("LeafVE")
      RegisterAddonMessagePrefix("LeafVEAch")
      Debug("Registered addon message prefixes")
    else
      Print("Warning: RegisterAddonMessagePrefix not available!")
    end
    
    LeafVE:CreateMinimapButton()
    Print("Addon loaded v"..LeafVE.version.."! Use /lve or /leaf to open")
    return
  end  -- <-- ADD THIS LINE!
  
  if event == "PLAYER_LOGIN" then
    Print("Loaded v"..LeafVE.version)
    Print("Auto-tracking: Login & Group points enabled!")
    LeafVE:CheckDailyLogin()
    
    -- Broadcast after 5 seconds
    local broadcastTimer = 0
    local broadcastFrame = CreateFrame("Frame")
    broadcastFrame:SetScript("OnUpdate", function()
      broadcastTimer = broadcastTimer + arg1
      if broadcastTimer >= 5 then
        if InGuild() then
          LeafVE:BroadcastBadges()
          
          -- **NEW: Broadcast player note**
          local me = ShortName(UnitName("player"))
          if me and LeafVE_GlobalDB.playerNotes and LeafVE_GlobalDB.playerNotes[me] then
            LeafVE:BroadcastPlayerNote(LeafVE_GlobalDB.playerNotes[me])
          end
        end
        broadcastFrame:SetScript("OnUpdate", nil)
      end
    end)
    return
  end
  
  if event == "CHAT_MSG_ADDON" then
    LeafVE:OnAddonMessage(arg1, arg2, arg3, arg4)
    return
  end
  
  if event == "PARTY_MEMBERS_CHANGED" or event == "RAID_ROSTER_UPDATE" then
    LeafVE:OnGroupUpdate()
    return
  end
end)

local updateFrame = CreateFrame("Frame")
updateFrame:SetScript("OnUpdate", function()
  groupCheckTimer = groupCheckTimer + arg1
  notificationTimer = notificationTimer + arg1
  attendanceTimer = attendanceTimer + arg1
  
  if groupCheckTimer >= 30 then
    groupCheckTimer = 0
    LeafVE:OnGroupUpdate()
  end
  
  if notificationTimer >= 0.1 then
    notificationTimer = 0
    LeafVE:ProcessNotifications()
  end
  
  if attendanceTimer >= 300 then
    attendanceTimer = 0
    LeafVE:TrackAttendance()
  end
end)

local badgeSyncTimer = 0

local updateFrame = CreateFrame("Frame")
updateFrame:SetScript("OnUpdate", function()
  groupCheckTimer = groupCheckTimer + arg1
  notificationTimer = notificationTimer + arg1
  attendanceTimer = attendanceTimer + arg1
  badgeSyncTimer = badgeSyncTimer + arg1
  
  if groupCheckTimer >= 30 then
    groupCheckTimer = 0
    LeafVE:OnGroupUpdate()
  end
  
  if notificationTimer >= 0.1 then
    notificationTimer = 0
    LeafVE:ProcessNotifications()
  end
  
  if attendanceTimer >= 300 then
    attendanceTimer = 0
    LeafVE:TrackAttendance()
  end
  
  -- Sync badges every 5 minutes
  if badgeSyncTimer >= 300 then
    badgeSyncTimer = 0
    if InGuild() then
      LeafVE:BroadcastBadges()
    end
  end
end)

-------------------------------------------------
-- SLASH COMMANDS
-------------------------------------------------

SLASH_NOTESYNC1 = "/notesync"
SlashCmdList["NOTESYNC"] = function()
  local me = ShortName(UnitName("player"))
  if me and LeafVE_GlobalDB.playerNotes and LeafVE_GlobalDB.playerNotes[me] then
    LeafVE:BroadcastPlayerNote(LeafVE_GlobalDB.playerNotes[me])
    Print("Broadcasting player note to guild...")
  else
    Print("You don't have a player note set!")
  end
end

SLASH_BADGESYNC1 = "/badgesync"
SlashCmdList["BADGESYNC"] = function()
  LeafVE:BroadcastBadges()
  Print("Broadcasting badges to guild...")
end

SLASH_LEAFVE1 = "/lve"
SlashCmdList["LEAFVE"] = function(msg)
  local trimmedMsg = Trim(Lower(msg or ""))
  
  if trimmedMsg == "bigger" or trimmedMsg == "taller" then
    EnsureDB()
    LeafVE_DB.ui.h = (LeafVE_DB.ui.h or 700) + 50
    if LeafVE_DB.ui.h > 1000 then LeafVE_DB.ui.h = 1000 end
    Print("Height increased to: "..LeafVE_DB.ui.h)
    if LeafVE.UI and LeafVE.UI.frame then
      LeafVE.UI.frame:Hide()
      LeafVE.UI.frame = nil
      LeafVE.UI.panels = nil
      LeafVE.UI.card = nil
    end
    LeafVE.UI = { activeTab = "me" }
    LeafVE:ToggleUI()
    
  elseif trimmedMsg == "smaller" or trimmedMsg == "shorter" then
    EnsureDB()
    LeafVE_DB.ui.h = (LeafVE_DB.ui.h or 700) - 50
    if LeafVE_DB.ui.h < 600 then LeafVE_DB.ui.h = 600 end
    Print("Height decreased to: "..LeafVE_DB.ui.h)
    if LeafVE.UI and LeafVE.UI.frame then
      LeafVE.UI.frame:Hide()
      LeafVE.UI.frame = nil
      LeafVE.UI.panels = nil
      LeafVE.UI.card = nil
    end
    LeafVE.UI = { activeTab = "me" }
    LeafVE:ToggleUI()
    
  elseif trimmedMsg == "wider" then
    EnsureDB()
    LeafVE_DB.ui.w = (LeafVE_DB.ui.w or 1050) + 50
    if LeafVE_DB.ui.w > 1400 then LeafVE_DB.ui.w = 1400 end
    Print("Width increased to: "..LeafVE_DB.ui.w)
    if LeafVE.UI and LeafVE.UI.frame then
      LeafVE.UI.frame:Hide()
      LeafVE.UI.frame = nil
      LeafVE.UI.panels = nil
      LeafVE.UI.card = nil
    end
    LeafVE.UI = { activeTab = "me" }
    LeafVE:ToggleUI()
    
  elseif trimmedMsg == "narrower" then
    EnsureDB()
    LeafVE_DB.ui.w = (LeafVE_DB.ui.w or 1050) - 50
    if LeafVE_DB.ui.w < 950 then LeafVE_DB.ui.w = 950 end
    Print("Width decreased to: "..LeafVE_DB.ui.w)
    if LeafVE.UI and LeafVE.UI.frame then
      LeafVE.UI.frame:Hide()
      LeafVE.UI.frame = nil
      LeafVE.UI.panels = nil
      LeafVE.UI.card = nil
    end
    LeafVE.UI = { activeTab = "me" }
    LeafVE:ToggleUI()
    
  elseif trimmedMsg == "reset" then
    EnsureDB()
    LeafVE_DB.ui.w = 1050
    LeafVE_DB.ui.h = 700
    Print("UI size reset to default!")
    if LeafVE.UI and LeafVE.UI.frame then
      LeafVE.UI.frame:Hide()
      LeafVE.UI.frame = nil
      LeafVE.UI.panels = nil
      LeafVE.UI.card = nil
    end
    LeafVE.UI = { activeTab = "me" }
    LeafVE:ToggleUI()
    
  else
    LeafVE:ToggleUI()
  end
end

SLASH_LEAFSHOUTOUT1 = "/shoutout"
SLASH_LEAFSHOUTOUT2 = "/so"
SlashCmdList["LEAFSHOUTOUT"] = function(msg)
  if not msg or msg == "" then
    Print("Usage: /shoutout PlayerName [reason]")
    return
  end
  
  local playerName, reason = string.match(msg, "^(%S+)%s*(.*)$")
  
  if playerName then
    LeafVE:GiveShoutout(playerName, reason)
  end
end

SLASH_LEAFBADGES1 = "/lvebadges"
SlashCmdList["LEAFBADGES"] = function()
  local me = ShortName(UnitName("player"))
  if not me then return end
  
  local badges = LeafVE:GetPlayerBadges(me)
  Print(string.format("You have earned %d badge%s:", table.getn(badges), table.getn(badges) ~= 1 and "s" or ""))
  
  for i = 1, table.getn(badges) do
    Print("  - "..badges[i].badge.name..": "..badges[i].badge.desc)
  end
end

SLASH_LEAFDEBUG1 = "/lvedebug"
SlashCmdList["LEAFDEBUG"] = function(msg)
  if msg == "login" then
    LeafVE:CheckDailyLogin()
    
  elseif msg == "group" then
    LeafVE:OnGroupUpdate()
    
  elseif msg == "points" then
    local me = ShortName(UnitName("player"))
    local day = DayKey()
    local dayT = (LeafVE_DB.global[day] and LeafVE_DB.global[day][me]) or {L = 0, G = 0, S = 0}
    Print(string.format("Today: L:%d G:%d S:%d | Total: %d", dayT.L, dayT.G, dayT.S, (dayT.L + dayT.G + dayT.S)))
    
    local allT = LeafVE_DB.alltime[me] or {L = 0, G = 0, S = 0}
    Print(string.format("All-Time: L:%d G:%d S:%d | Total: %d", allT.L, allT.G, allT.S, (allT.L + allT.G + allT.S)))
    
  elseif msg == "shoutouts" then
    local me = ShortName(UnitName("player"))
    local today = DayKey()
    if not LeafVE_DB.shoutouts[me] then LeafVE_DB.shoutouts[me] = {} end
    local count = 0
    for tname, timestamp in pairs(LeafVE_DB.shoutouts[me]) do
      if DayKeyFromTS(timestamp) == today then count = count + 1 end
    end
    Print(string.format("Shoutouts used today: %d / %d", count, SHOUTOUT_MAX_PER_DAY))
    
  elseif msg == "notify" then
    LeafVE:ShowNotification("Test Notification", "This is a test message!", LEAF_EMBLEM, THEME.gold)
    
  elseif msg == "badges" then
    local me = ShortName(UnitName("player"))
    Print("Checking all badge milestones...")
    LeafVE:CheckBadgeMilestones(me)
    
  elseif msg == "attendance" then
    LeafVE:TrackAttendance()
    Print("Attendance tracked!")
    
  elseif msg == "history" then
    local me = ShortName(UnitName("player"))
    local history = LeafVE:GetHistory(me, 5)
    Print("Last 5 history entries:")
    for i = 1, table.getn(history) do
      local entry = history[i]
      Print(string.format("  %s: +%d %s - %s", date("%m/%d %H:%M", entry.timestamp), entry.amount, entry.type, entry.reason))
    end
    
  elseif msg == "populate" then
    Print("Manually populating persistent roster from online members...")
    LeafVE:UpdateGuildRosterCache()
    
    local count = 0
    if LeafVE_DB.persistentRoster then
      for _ in pairs(LeafVE_DB.persistentRoster) do count = count + 1 end
    end
    
    Print("Persistent roster now has: "..count.." members")
    Print("These members will show even when offline.")
    
    if LeafVE.UI and LeafVE.UI.RefreshRoster then
      LeafVE.UI:RefreshRoster()
    end
    
  elseif msg == "errors" then
    if table.getn(LeafVE.errorLog) == 0 then
      Print("|cFF00FF00No errors logged!|r")
    else
      Print("|cFFFFD700=== ERROR LOG ===|r")
      Print(string.format("Total errors: %d (showing last %d)", table.getn(LeafVE.errorLog), math.min(10, table.getn(LeafVE.errorLog))))
      
      local startIdx = math.max(1, table.getn(LeafVE.errorLog) - 9)
      for i = startIdx, table.getn(LeafVE.errorLog) do
        local err = LeafVE.errorLog[i]
        Print(string.format("|cFFFF0000[%s]|r %s", err.dateStr, err.source))
        Print("|cFFAAAAAA  "..err.message.."|r")
      end
      Print("|cFFFFD700=================|r")
    end
    
  elseif msg == "clearerrors" then
    LeafVE.errorLog = {}
    Print("|cFF00FF00Error log cleared!|r")
    
  elseif msg == "ui" then
    Print("=== UI DEBUG INFO ===")
    if LeafVE.UI then
      Print("LeafVE.UI: EXISTS")
      Print("LeafVE.UI.frame: "..(LeafVE.UI.frame and "EXISTS" or "NIL"))
      Print("LeafVE.UI.Build: "..(LeafVE.UI.Build and "EXISTS" or "NIL"))
      Print("LeafVE.UI.Refresh: "..(LeafVE.UI.Refresh and "EXISTS" or "NIL"))
      Print("LeafVE.UI.activeTab: "..(LeafVE.UI.activeTab or "NIL"))
      
      if LeafVE.UI.panels then
        Print("Panels:")
        for name, panel in pairs(LeafVE.UI.panels) do
          local visible = panel:IsVisible() and "VISIBLE" or "HIDDEN"
          Print("  "..name..": "..visible)
        end
      else
        Print("Panels: NIL")
      end
    else
      Print("LeafVE.UI: NIL")
    end
    Print("====================")
    
  elseif msg == "reload" then
    Print("Reloading UI...")
    if LeafVE.UI and LeafVE.UI.frame then
      LeafVE.UI.frame:Hide()
      LeafVE.UI.frame = nil
      LeafVE.UI.panels = nil
      LeafVE.UI.card = nil
    end
    LeafVE.UI = { activeTab = "me" }
    Print("UI reset! Use /lve to rebuild.")
    
  elseif msg == "db" then
    Print("=== DATABASE INFO ===")
    Print("LeafVE_DB: "..(LeafVE_DB and "EXISTS" or "NIL"))
    if LeafVE_DB then
      local dayCount = 0
      if LeafVE_DB.global then
        for _ in pairs(LeafVE_DB.global) do dayCount = dayCount + 1 end
      end
      Print("  global: "..dayCount.." days")
      Print("  alltime: "..(LeafVE_DB.alltime and "EXISTS" or "NIL"))
      Print("  season: "..(LeafVE_DB.season and "EXISTS" or "NIL"))
      Print("  shoutouts: "..(LeafVE_DB.shoutouts and "EXISTS" or "NIL"))
      Print("  badges: "..(LeafVE_DB.badges and "EXISTS" or "NIL"))
      
      local rosterCount = 0
      if LeafVE_DB.persistentRoster then
        for _ in pairs(LeafVE_DB.persistentRoster) do rosterCount = rosterCount + 1 end
      end
      Print("  persistentRoster: "..rosterCount.." members")
    end
    Print("LeafVE_GlobalDB: "..(LeafVE_GlobalDB and "EXISTS" or "NIL"))
    if LeafVE_GlobalDB then
      Print("  achievementCache: "..(LeafVE_GlobalDB.achievementCache and "EXISTS" or "NIL"))
      Print("  playerNotes: "..(LeafVE_GlobalDB.playerNotes and "EXISTS" or "NIL"))
    end
    Print("=====================")
    
  elseif msg == "guild" then
    Print("=== GUILD CACHE INFO ===")
    Print("InGuild: "..(InGuild() and "YES" or "NO"))
    local cacheCount = 0
    for _ in pairs(LeafVE.guildRosterCache) do cacheCount = cacheCount + 1 end
    Print("Cache size: "..cacheCount)
    Print("Cache age: "..(Now() - LeafVE.guildRosterCacheTime).." seconds")
    
    local onlineCount = 0
    local offlineCount = 0
    for _, info in pairs(LeafVE.guildRosterCache) do
      if info.online then 
        onlineCount = onlineCount + 1 
      else
        offlineCount = offlineCount + 1
      end
    end
    Print("Online members: "..onlineCount)
    Print("Offline members: "..offlineCount)
    
    local persistentCount = 0
    if LeafVE_DB.persistentRoster then
      for _ in pairs(LeafVE_DB.persistentRoster) do persistentCount = persistentCount + 1 end
    end
    Print("Persistent roster: "..persistentCount.." members")
    Print("========================")
    
  elseif msg == "test" then
    Print("=== RUNNING TESTS ===")
    
    Print("Test 1: Core functions")
    Print("  LeafVE:ToggleUI: "..(LeafVE.ToggleUI and "PASS" or "FAIL"))
    Print("  LeafVE:AddPoints: "..(LeafVE.AddPoints and "PASS" or "FAIL"))
    Print("  LeafVE:GiveShoutout: "..(LeafVE.GiveShoutout and "PASS" or "FAIL"))
    
    Print("Test 2: UI structure")
    Print("  LeafVE.UI: "..(LeafVE.UI and "PASS" or "FAIL"))
    Print("  LeafVE.UI.Build: "..(LeafVE.UI and LeafVE.UI.Build and "PASS" or "FAIL"))
    Print("  LeafVE.UI.Refresh: "..(LeafVE.UI and LeafVE.UI.Refresh and "PASS" or "FAIL"))
    
    Print("Test 3: Database")
    EnsureDB()
    Print("  LeafVE_DB: "..(LeafVE_DB and "PASS" or "FAIL"))
    Print("  LeafVE_DB.global: "..(LeafVE_DB.global and "PASS" or "FAIL"))
    Print("  LeafVE_DB.alltime: "..(LeafVE_DB.alltime and "PASS" or "FAIL"))
    Print("  LeafVE_DB.persistentRoster: "..(LeafVE_DB.persistentRoster and "PASS" or "FAIL"))
    
    Print("Test 4: Player info")
    local me = ShortName(UnitName("player"))
    Print("  Player name: "..(me or "FAIL"))
    local guildInfo = LeafVE:GetGuildInfo(me)
    Print("  Guild info: "..(guildInfo and "PASS" or "FAIL"))
    
    Print("Test 5: Achievement title")
    if LeafVE_AchTest_DB and LeafVE_AchTest_DB[me] then
      local title = LeafVE_AchTest_DB[me].equippedTitle
      Print("  Equipped title: "..(title or "NONE"))
    else
      Print("  Achievement addon: NOT LOADED")
    end
    
    Print("=====================")
    
  else
    Print("=== DEBUG COMMANDS ===")
    Print("/lvedebug login - Test login point award")
    Print("/lvedebug group - Test group point check")
    Print("/lvedebug points - Show current points")
    Print("/lvedebug shoutouts - Show shoutout usage")
    Print("/lvedebug notify - Test notification")
    Print("/lvedebug badges - Check badge milestones")
    Print("/lvedebug attendance - Track attendance")
    Print("/lvedebug history - Show point history")
    Print("/lvedebug populate - Populate roster from online")
    Print("|cFFFFD700/lvedebug errors|r - Show error log")
    Print("|cFFFFD700/lvedebug clearerrors|r - Clear error log")
    Print("/lvedebug ui - Show UI debug info")
    Print("/lvedebug reload - Reset and reload UI")
    Print("/lvedebug db - Show database info")
    Print("/lvedebug guild - Show guild cache info")
    Print("/lvedebug test - Run all tests")
    Print("======================")
  end
end

-------------------------------------------------
-- STARTUP MESSAGE
-------------------------------------------------
Print("|cFF2DD35CLeaf Village Legends|r v"..LeafVE.version.." loaded!")
Print("Type |cFFFFD700/lve|r or |cFFFFD700/leaf|r to open the UI")
Print("Type |cFFFFD700/lvedebug|r for debug commands")
