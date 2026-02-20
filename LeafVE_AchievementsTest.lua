-- LeafVE Achievement System - v1.4.0 - More Titles + Title Search Bar
-- Guild message: [Title] [LeafVE Achievement] earned [Achievement]

LeafVE_AchTest = LeafVE_AchTest or {}
LeafVE_AchTest.name = "LeafVE_AchievementsTest"
LeafVE_AchTest_DB = LeafVE_AchTest_DB or {}
LeafVE_AchTest.DEBUG = false -- Set to true for debug messages

local THEME = {
  bg = {0.05, 0.05, 0.06, 0.96},
  leaf = {0.20, 0.78, 0.35, 1.00},
  gold = {1.00, 0.82, 0.20, 1.00},
  orange = {1.00, 0.50, 0.00, 1.00},
  border = {0.28, 0.28, 0.30, 1.00}
}

local function Print(msg)
  if DEFAULT_CHAT_FRAME then
    DEFAULT_CHAT_FRAME:AddMessage("|cFF2DD35C[AchTest]|r: "..tostring(msg))
  end
end

local function Debug(msg)
  if LeafVE_AchTest.DEBUG then
    Print("|cFFFF0000[DEBUG]|r "..tostring(msg))
  end
end

local function Now() return time() end

local function ShortName(name)
  if not name or name == "" then 
    name = UnitName("player")
    if not name or name == "" then return nil end
  end
  local dash = string.find(name, "-")
  if dash then return string.sub(name, 1, dash-1) end
  return name
end

local function EnsureDB()
  if not LeafVE_AchTest_DB then LeafVE_AchTest_DB = {} end
  if not LeafVE_AchTest_DB.achievements then LeafVE_AchTest_DB.achievements = {} end
  if not LeafVE_AchTest_DB.exploredZones then LeafVE_AchTest_DB.exploredZones = {} end
  if not LeafVE_AchTest_DB.selectedTitles then LeafVE_AchTest_DB.selectedTitles = {} end
end

local KALIMDOR_ZONES = {"Durotar","Mulgore","The Barrens","Teldrassil","Darkshore","Ashenvale","Stonetalon Mountains","Desolace","Feralas","Thousand Needles","Tanaris","Dustwallow Marsh","Azshara","Felwood","Un'Goro Crater","Moonglade","Winterspring","Silithus"}
local EASTERN_KINGDOMS_ZONES = {"Dun Morogh","Elwynn Forest","Tirisfal Glades","Silverpine Forest","Westfall","Redridge Mountains","Duskwood","Wetlands","Loch Modan","Hillsbrad Foothills","Alterac Mountains","Arathi Highlands","Badlands","Searing Gorge","Burning Steppes","The Hinterlands","Western Plaguelands","Eastern Plaguelands","Stranglethorn Vale","Swamp of Sorrows","Blasted Lands","Deadwind Pass"}

local ACHIEVEMENTS = {
  -- Leveling
  lvl_10={id="lvl_10",name="Level 10",desc="Reach level 10",category="Leveling",points=5,icon="Interface\\Icons\\INV_Misc_Bone_HumanSkull_01"},
  lvl_20={id="lvl_20",name="Level 20",desc="Reach level 20",category="Leveling",points=10,icon="Interface\\Icons\\INV_Helmet_08"},
  lvl_30={id="lvl_30",name="Level 30",desc="Reach level 30",category="Leveling",points=15,icon="Interface\\Icons\\INV_Shoulder_23"},
  lvl_40={id="lvl_40",name="Level 40",desc="Reach level 40",category="Leveling",points=20,icon="Interface\\Icons\\INV_Chest_Plate16"},
  lvl_50={id="lvl_50",name="Level 50",desc="Reach level 50",category="Leveling",points=25,icon="Interface\\Icons\\INV_Weapon_ShortBlade_25"},
  lvl_60={id="lvl_60",name="Level 60",desc="Reach maximum level",category="Leveling",points=50,icon="Interface\\Icons\\Spell_Holy_BlessingOfStrength"},
  
  -- Professions
  prof_alchemy_300={id="prof_alchemy_300",name="Master Alchemist",desc="Reach 300 Alchemy",category="Professions",points=25,icon="Interface\\Icons\\Trade_Alchemy"},
  prof_blacksmithing_300={id="prof_blacksmithing_300",name="Master Blacksmith",desc="Reach 300 Blacksmithing",category="Professions",points=25,icon="Interface\\Icons\\Trade_BlackSmithing"},
  prof_enchanting_300={id="prof_enchanting_300",name="Master Enchanter",desc="Reach 300 Enchanting",category="Professions",points=25,icon="Interface\\Icons\\Trade_Engraving"},
  prof_engineering_300={id="prof_engineering_300",name="Master Engineer",desc="Reach 300 Engineering",category="Professions",points=25,icon="Interface\\Icons\\Trade_Engineering"},
  prof_herbalism_300={id="prof_herbalism_300",name="Master Herbalist",desc="Reach 300 Herbalism",category="Professions",points=25,icon="Interface\\Icons\\Trade_Herbalism"},
  prof_leatherworking_300={id="prof_leatherworking_300",name="Master Leatherworker",desc="Reach 300 Leatherworking",category="Professions",points=25,icon="Interface\\Icons\\Trade_LeatherWorking"},
  prof_mining_300={id="prof_mining_300",name="Master Miner",desc="Reach 300 Mining",category="Professions",points=25,icon="Interface\\Icons\\Trade_Mining"},
  prof_skinning_300={id="prof_skinning_300",name="Master Skinner",desc="Reach 300 Skinning",category="Professions",points=25,icon="Interface\\Icons\\INV_Misc_Pelt_Wolf_01"},
  prof_tailoring_300={id="prof_tailoring_300",name="Master Tailor",desc="Reach 300 Tailoring",category="Professions",points=25,icon="Interface\\Icons\\Trade_Tailoring"},
  prof_fishing_300={id="prof_fishing_300",name="Master Fisherman",desc="Reach 300 Fishing",category="Professions",points=25,icon="Interface\\Icons\\Trade_Fishing"},
  prof_cooking_300={id="prof_cooking_300",name="Master Chef",desc="Reach 300 Cooking",category="Professions",points=25,icon="Interface\\Icons\\INV_Misc_Food_15"},
  prof_firstaid_300={id="prof_firstaid_300",name="Master Medic",desc="Reach 300 First Aid",category="Professions",points=25,icon="Interface\\Icons\\Spell_Holy_SealOfSacrifice"},
  prof_dual_artisan={id="prof_dual_artisan",name="Dual Artisan",desc="Reach 300 in two professions",category="Professions",points=50,icon="Interface\\Icons\\INV_Misc_Note_06"},
  
  -- Gold
  gold_10={id="gold_10",name="Copper Baron",desc="Accumulate 10 gold",category="Gold",points=10,icon="Interface\\Icons\\INV_Misc_Coin_01"},
  gold_100={id="gold_100",name="Silver Merchant",desc="Accumulate 100 gold",category="Gold",points=20,icon="Interface\\Icons\\INV_Misc_Coin_03"},
  gold_500={id="gold_500",name="Gold Tycoon",desc="Accumulate 500 gold",category="Gold",points=40,icon="Interface\\Icons\\INV_Misc_Coin_05"},
  gold_1000={id="gold_1000",name="Wealthy Elite",desc="Accumulate 1000 gold",category="Gold",points=75,icon="Interface\\Icons\\INV_Misc_Coin_06"},
  gold_5000={id="gold_5000",name="Fortune Builder",desc="Accumulate 5000 gold",category="Gold",points=100,icon="Interface\\Icons\\INV_Misc_Coin_17"},
  
  -- Dungeons - Classic
  dung_rfc={id="dung_rfc",name="Ragefire Chasm",desc="Defeat Taragaman the Hungerer",category="Dungeons",points=5,icon="Interface\\Icons\\Spell_Shadow_SealOfKings"},
  dung_wc={id="dung_wc",name="Wailing Caverns",desc="Defeat Mutanus the Devourer",category="Dungeons",points=5,icon="Interface\\Icons\\Spell_Nature_NullifyDisease"},
  dung_dm={id="dung_dm",name="The Deadmines",desc="Defeat Edwin VanCleef",category="Dungeons",points=5,icon="Interface\\Icons\\INV_Sword_01"},
  dung_sfk={id="dung_sfk",name="Shadowfang Keep",desc="Defeat Arugal",category="Dungeons",points=10,icon="Interface\\Icons\\Spell_Shadow_Possession"},
  dung_bfd={id="dung_bfd",name="Blackfathom Deeps",desc="Defeat Aku'mai",category="Dungeons",points=10,icon="Interface\\Icons\\INV_Misc_Fish_02"},
  dung_stocks={id="dung_stocks",name="The Stockade",desc="Defeat Bazil Thredd",category="Dungeons",points=10,icon="Interface\\Icons\\INV_Misc_Key_03"},
  dung_gnomer={id="dung_gnomer",name="Gnomeregan",desc="Defeat Mekgineer Thermaplugg",category="Dungeons",points=15,icon="Interface\\Icons\\INV_Misc_Gear_01"},
  dung_rfk={id="dung_rfk",name="Razorfen Kraul",desc="Defeat Charlga Razorflank",category="Dungeons",points=15,icon="Interface\\Icons\\INV_Misc_Head_Boar_01"},
  dung_sm_graveyard={id="dung_sm_graveyard",name="SM: Graveyard",desc="Defeat Bloodmage Thalnos",category="Dungeons",points=10,icon="Interface\\Icons\\Spell_Holy_BlessingOfStrength"},
  dung_sm_library={id="dung_sm_library",name="SM: Library",desc="Defeat Arcanist Doan",category="Dungeons",points=10,icon="Interface\\Icons\\INV_Misc_Book_11"},
  dung_sm_armory={id="dung_sm_armory",name="SM: Armory",desc="Defeat Herod",category="Dungeons",points=10,icon="Interface\\Icons\\INV_Gauntlets_17"},
  dung_sm_cathedral={id="dung_sm_cathedral",name="SM: Cathedral",desc="Defeat High Inquisitor Whitemane",category="Dungeons",points=15,icon="Interface\\Icons\\Spell_Holy_GuardianSpirit"},
  dung_rfdown={id="dung_rfdown",name="Razorfen Downs",desc="Defeat Amnennar the Coldbringer",category="Dungeons",points=20,icon="Interface\\Icons\\Spell_Ice_LichTransform"},
  dung_ulda={id="dung_ulda",name="Uldaman",desc="Defeat Archaedas",category="Dungeons",points=20,icon="Interface\\Icons\\INV_Misc_StoneTablet_11"},
  dung_zf={id="dung_zf",name="Zul'Farrak",desc="Defeat Chief Ukorz Sandscalp",category="Dungeons",points=25,icon="Interface\\Icons\\Ability_Hunter_Pet_Dragonhawk"},
  dung_mara={id="dung_mara",name="Maraudon",desc="Defeat Princess Theradras",category="Dungeons",points=25,icon="Interface\\Icons\\INV_Misc_Root_02"},
  dung_st={id="dung_st",name="Sunken Temple",desc="Defeat Shade of Eranikus",category="Dungeons",points=30,icon="Interface\\Icons\\Spell_Shadow_Charm"},
  dung_brd={id="dung_brd",name="Blackrock Depths",desc="Defeat Emperor Dagran Thaurissan",category="Dungeons",points=30,icon="Interface\\Icons\\Spell_Fire_LavaSpawn"},
  dung_scholo={id="dung_scholo",name="Scholomance",desc="Defeat Darkmaster Gandling",category="Dungeons",points=35,icon="Interface\\Icons\\Spell_Shadow_Charm"},
  dung_stratholme={id="dung_stratholme",name="Stratholme",desc="Defeat Baron Rivendare",category="Dungeons",points=35,icon="Interface\\Icons\\Spell_Shadow_RaiseDead"},
  dung_lbrs={id="dung_lbrs",name="Lower Blackrock Spire",desc="Defeat Overlord Wyrmthalak",category="Dungeons",points=30,icon="Interface\\Icons\\INV_Misc_Head_Dragon_Black"},
  dung_ubrs={id="dung_ubrs",name="Upper Blackrock Spire",desc="Defeat General Drakkisath",category="Dungeons",points=35,icon="Interface\\Icons\\INV_Misc_Head_Dragon_01"},
  dung_diremaul_east={id="dung_diremaul_east",name="Dire Maul East",desc="Complete Dire Maul East",category="Dungeons",points=30,icon="Interface\\Icons\\INV_Misc_Key_14"},
  dung_diremaul_west={id="dung_diremaul_west",name="Dire Maul West",desc="Complete Dire Maul West",category="Dungeons",points=30,icon="Interface\\Icons\\INV_Misc_Key_14"},
  dung_diremaul_north={id="dung_diremaul_north",name="Dire Maul North",desc="Complete Dire Maul North",category="Dungeons",points=35,icon="Interface\\Icons\\INV_Misc_Key_14"},
  
  -- Raids - Molten Core
  raid_mc_lucifron={id="raid_mc_lucifron",name="MC: Lucifron",desc="Defeat Lucifron",category="Raids",points=25,icon="Interface\\Icons\\Spell_Fire_Incinerate"},
  raid_mc_magmadar={id="raid_mc_magmadar",name="MC: Magmadar",desc="Defeat Magmadar",category="Raids",points=25,icon="Interface\\Icons\\INV_Misc_Head_Dragon_01"},
  raid_mc_gehennas={id="raid_mc_gehennas",name="MC: Gehennas",desc="Defeat Gehennas",category="Raids",points=25,icon="Interface\\Icons\\Spell_Shadow_Requiem"},
  raid_mc_garr={id="raid_mc_garr",name="MC: Garr",desc="Defeat Garr",category="Raids",points=25,icon="Interface\\Icons\\Spell_Nature_WispSplode"},
  raid_mc_geddon={id="raid_mc_geddon",name="MC: Baron Geddon",desc="Defeat Baron Geddon",category="Raids",points=30,icon="Interface\\Icons\\Spell_Fire_ElementalDevastation"},
  raid_mc_shazzrah={id="raid_mc_shazzrah",name="MC: Shazzrah",desc="Defeat Shazzrah",category="Raids",points=25,icon="Interface\\Icons\\Spell_Nature_Lightning"},
  raid_mc_sulfuron={id="raid_mc_sulfuron",name="MC: Sulfuron Harbinger",desc="Defeat Sulfuron Harbinger",category="Raids",points=30,icon="Interface\\Icons\\Spell_Fire_FireArmor"},
  raid_mc_golemagg={id="raid_mc_golemagg",name="MC: Golemagg",desc="Defeat Golemagg the Incinerator",category="Raids",points=30,icon="Interface\\Icons\\INV_Misc_MonsterScales_15"},
  raid_mc_majordomo={id="raid_mc_majordomo",name="MC: Majordomo",desc="Defeat Majordomo Executus",category="Raids",points=40,icon="Interface\\Icons\\INV_Helmet_08"},
  raid_mc_ragnaros={id="raid_mc_ragnaros",name="MC: Ragnaros",desc="Defeat Ragnaros the Firelord",category="Raids",points=100,icon="Interface\\Icons\\Spell_Fire_LavaSpawn"},
  
  -- Raids - Onyxia
  raid_onyxia={id="raid_onyxia",name="Onyxia's Lair",desc="Defeat Onyxia",category="Raids",points=75,icon="Interface\\Icons\\INV_Misc_Head_Dragon_01"},
  
  -- Raids - Blackwing Lair
  raid_bwl_razorgore={id="raid_bwl_razorgore",name="BWL: Razorgore",desc="Defeat Razorgore the Untamed",category="Raids",points=30,icon="Interface\\Icons\\INV_Misc_Head_Dragon_Black"},
  raid_bwl_vaelastrasz={id="raid_bwl_vaelastrasz",name="BWL: Vaelastrasz",desc="Defeat Vaelastrasz the Corrupt",category="Raids",points=35,icon="Interface\\Icons\\Spell_Shadow_ShadowWordDominate"},
  raid_bwl_broodlord={id="raid_bwl_broodlord",name="BWL: Broodlord",desc="Defeat Broodlord Lashlayer",category="Raids",points=30,icon="Interface\\Icons\\INV_Bracer_18"},
  raid_bwl_firemaw={id="raid_bwl_firemaw",name="BWL: Firemaw",desc="Defeat Firemaw",category="Raids",points=25,icon="Interface\\Icons\\INV_Misc_Head_Dragon_01"},
  raid_bwl_ebonroc={id="raid_bwl_ebonroc",name="BWL: Ebonroc",desc="Defeat Ebonroc",category="Raids",points=25,icon="Interface\\Icons\\INV_Misc_Head_Dragon_Black"},
  raid_bwl_flamegor={id="raid_bwl_flamegor",name="BWL: Flamegor",desc="Defeat Flamegor",category="Raids",points=25,icon="Interface\\Icons\\Spell_Fire_Fire"},
  raid_bwl_chromaggus={id="raid_bwl_chromaggus",name="BWL: Chromaggus",desc="Defeat Chromaggus",category="Raids",points=40,icon="Interface\\Icons\\INV_Misc_Head_Dragon_Bronze"},
  raid_bwl_nefarian={id="raid_bwl_nefarian",name="BWL: Nefarian",desc="Defeat Nefarian",category="Raids",points=125,icon="Interface\\Icons\\INV_Misc_Head_Dragon_Black"},
  
  -- Raids - Zul'Gurub
  raid_zg_venoxis={id="raid_zg_venoxis",name="ZG: High Priest Venoxis",desc="Defeat High Priest Venoxis",category="Raids",points=15,icon="Interface\\Icons\\Spell_Nature_NullifyPoison"},
  raid_zg_jeklik={id="raid_zg_jeklik",name="ZG: High Priestess Jeklik",desc="Defeat High Priestess Jeklik",category="Raids",points=15,icon="Interface\\Icons\\Spell_Shadow_UnholyFrenzy"},
  raid_zg_marli={id="raid_zg_marli",name="ZG: High Priestess Mar'li",desc="Defeat High Priestess Mar'li",category="Raids",points=15,icon="Interface\\Icons\\Spell_Nature_Polymorph"},
  raid_zg_thekal={id="raid_zg_thekal",name="ZG: High Priest Thekal",desc="Defeat High Priest Thekal",category="Raids",points=20,icon="Interface\\Icons\\Ability_Druid_Mangle2"},
  raid_zg_arlokk={id="raid_zg_arlokk",name="ZG: High Priestess Arlokk",desc="Defeat High Priestess Arlokk",category="Raids",points=20,icon="Interface\\Icons\\INV_Misc_MonsterScales_14"},
  raid_zg_hakkar={id="raid_zg_hakkar",name="ZG: Hakkar",desc="Defeat Hakkar the Soulflayer",category="Raids",points=50,icon="Interface\\Icons\\Spell_Shadow_PainSpike"},
  
  -- Raids - AQ20
  raid_aq20_kurinnaxx={id="raid_aq20_kurinnaxx",name="AQ20: Kurinnaxx",desc="Defeat Kurinnaxx",category="Raids",points=15,icon="Interface\\Icons\\INV_Qiraj_JewelBlessed"},
  raid_aq20_rajaxx={id="raid_aq20_rajaxx",name="AQ20: General Rajaxx",desc="Defeat General Rajaxx",category="Raids",points=20,icon="Interface\\Icons\\INV_Sword_43"},
  raid_aq20_moam={id="raid_aq20_moam",name="AQ20: Moam",desc="Defeat Moam",category="Raids",points=15,icon="Interface\\Icons\\Spell_Shadow_UnholyStrength"},
  raid_aq20_buru={id="raid_aq20_buru",name="AQ20: Buru",desc="Defeat Buru the Gorger",category="Raids",points=20,icon="Interface\\Icons\\INV_Qiraj_JewelEngraved"},
  raid_aq20_ayamiss={id="raid_aq20_ayamiss",name="AQ20: Ayamiss",desc="Defeat Ayamiss the Hunter",category="Raids",points=20,icon="Interface\\Icons\\INV_Spear_04"},
  raid_aq20_ossirian={id="raid_aq20_ossirian",name="AQ20: Ossirian",desc="Defeat Ossirian the Unscarred",category="Raids",points=40,icon="Interface\\Icons\\INV_Qiraj_JewelGlowing"},
  
  -- Raids - AQ40
  raid_aq40_skeram={id="raid_aq40_skeram",name="AQ40: The Prophet Skeram",desc="Defeat The Prophet Skeram",category="Raids",points=30,icon="Interface\\Icons\\Spell_Shadow_MindSteal"},
  raid_aq40_bug_trio={id="raid_aq40_bug_trio",name="AQ40: Bug Trio",desc="Defeat the Silithid Royalty",category="Raids",points=35,icon="Interface\\Icons\\INV_Misc_AhnQirajTrinket_02"},
  raid_aq40_sartura={id="raid_aq40_sartura",name="AQ40: Battleguard Sartura",desc="Defeat Battleguard Sartura",category="Raids",points=30,icon="Interface\\Icons\\INV_Weapon_ShortBlade_25"},
  raid_aq40_fankriss={id="raid_aq40_fankriss",name="AQ40: Fankriss",desc="Defeat Fankriss the Unyielding",category="Raids",points=30,icon="Interface\\Icons\\INV_Qiraj_Husk"},
  raid_aq40_viscidus={id="raid_aq40_viscidus",name="AQ40: Viscidus",desc="Defeat Viscidus",category="Raids",points=35,icon="Interface\\Icons\\Spell_Nature_Acid_01"},
  raid_aq40_huhuran={id="raid_aq40_huhuran",name="AQ40: Princess Huhuran",desc="Defeat Princess Huhuran",category="Raids",points=35,icon="Interface\\Icons\\INV_Misc_AhnQirajTrinket_03"},
  raid_aq40_twins={id="raid_aq40_twins",name="AQ40: Twin Emperors",desc="Defeat the Twin Emperors",category="Raids",points=50,icon="Interface\\Icons\\INV_Jewelry_Ring_AhnQiraj_04"},
  raid_aq40_ouro={id="raid_aq40_ouro",name="AQ40: Ouro",desc="Defeat Ouro",category="Raids",points=40,icon="Interface\\Icons\\INV_Qiraj_JewelGlowing"},
  raid_aq40_cthun={id="raid_aq40_cthun",name="AQ40: C'Thun",desc="Defeat C'Thun",category="Raids",points=150,icon="Interface\\Icons\\Spell_Shadow_Charm"},
  
  -- Raids - Naxxramas
  raid_naxx_anubrekhan={id="raid_naxx_anubrekhan",name="Naxx: Anub'Rekhan",desc="Defeat Anub'Rekhan",category="Raids",points=30,icon="Interface\\Icons\\Spell_Shadow_UnholyStrength"},
  raid_naxx_faerlina={id="raid_naxx_faerlina",name="Naxx: Grand Widow Faerlina",desc="Defeat Grand Widow Faerlina",category="Raids",points=30,icon="Interface\\Icons\\Spell_Shadow_Possession"},
  raid_naxx_maexxna={id="raid_naxx_maexxna",name="Naxx: Maexxna",desc="Defeat Maexxna",category="Raids",points=35,icon="Interface\\Icons\\INV_Misc_MonsterSpiderCarapace_01"},
  raid_naxx_noth={id="raid_naxx_noth",name="Naxx: Noth",desc="Defeat Noth the Plaguebringer",category="Raids",points=30,icon="Interface\\Icons\\Spell_Shadow_CurseOfAchimonde"},
  raid_naxx_heigan={id="raid_naxx_heigan",name="Naxx: Heigan",desc="Defeat Heigan the Unclean",category="Raids",points=35,icon="Interface\\Icons\\Spell_Shadow_DeathScream"},
  raid_naxx_loatheb={id="raid_naxx_loatheb",name="Naxx: Loatheb",desc="Defeat Loatheb",category="Raids",points=50,icon="Interface\\Icons\\Spell_Shadow_CallofBone"},
  raid_naxx_razuvious={id="raid_naxx_razuvious",name="Naxx: Instructor Razuvious",desc="Defeat Instructor Razuvious",category="Raids",points=30,icon="Interface\\Icons\\Spell_Shadow_ShadowWordPain"},
  raid_naxx_gothik={id="raid_naxx_gothik",name="Naxx: Gothik",desc="Defeat Gothik the Harvester",category="Raids",points=30,icon="Interface\\Icons\\Spell_Shadow_ShadowBolt"},
  raid_naxx_four_horsemen={id="raid_naxx_four_horsemen",name="Naxx: Four Horsemen",desc="Defeat The Four Horsemen",category="Raids",points=60,icon="Interface\\Icons\\Spell_DeathKnight_ClassIcon"},
  raid_naxx_patchwerk={id="raid_naxx_patchwerk",name="Naxx: Patchwerk",desc="Defeat Patchwerk",category="Raids",points=30,icon="Interface\\Icons\\INV_Weapon_ShortBlade_25"},
  raid_naxx_grobbulus={id="raid_naxx_grobbulus",name="Naxx: Grobbulus",desc="Defeat Grobbulus",category="Raids",points=30,icon="Interface\\Icons\\Spell_Shadow_CallofBone"},
  raid_naxx_gluth={id="raid_naxx_gluth",name="Naxx: Gluth",desc="Defeat Gluth",category="Raids",points=30,icon="Interface\\Icons\\Spell_Shadow_AnimateDead"},
  raid_naxx_thaddius={id="raid_naxx_thaddius",name="Naxx: Thaddius",desc="Defeat Thaddius",category="Raids",points=40,icon="Interface\\Icons\\Spell_Shadow_UnholyFrenzy"},
  raid_naxx_sapphiron={id="raid_naxx_sapphiron",name="Naxx: Sapphiron",desc="Defeat Sapphiron",category="Raids",points=75,icon="Interface\\Icons\\INV_Misc_Head_Dragon_Blue"},
  raid_naxx_kelthuzad={id="raid_naxx_kelthuzad",name="Naxx: Kel'Thuzad",desc="Defeat Kel'Thuzad",category="Raids",points=200,icon="Interface\\Icons\\Spell_Shadow_SoulGem"},
  
  -- Exploration
  explore_kalimdor={id="explore_kalimdor",name="Explore Kalimdor",desc="Discover all zones in Kalimdor",category="Exploration",points=50,icon="Interface\\Icons\\INV_Misc_Map_01"},
  explore_eastern_kingdoms={id="explore_eastern_kingdoms",name="Explore Eastern Kingdoms",desc="Discover all zones in Eastern Kingdoms",category="Exploration",points=50,icon="Interface\\Icons\\INV_Misc_Map_02"},
  
  -- PvP
  pvp_hk_100={id="pvp_hk_100",name="Soldier",desc="Earn 100 honorable kills",category="PvP",points=10,icon="Interface\\Icons\\INV_Sword_27"},
  pvp_hk_1000={id="pvp_hk_1000",name="Gladiator",desc="Earn 1000 honorable kills",category="PvP",points=50,icon="Interface\\Icons\\INV_Sword_48"},
  pvp_hk_5000={id="pvp_hk_5000",name="Warlord",desc="Earn 5000 honorable kills",category="PvP",points=100,icon="Interface\\Icons\\INV_Sword_62"},
  pvp_hk_10000={id="pvp_hk_10000",name="High Warlord",desc="Earn 10000 honorable kills",category="PvP",points=200,icon="Interface\\Icons\\INV_Sword_39"},
  pvp_duel_10={id="pvp_duel_10",name="Duelist",desc="Win 10 duels",category="PvP",points=10,icon="Interface\\Icons\\Ability_Dualwield"},
  pvp_duel_50={id="pvp_duel_50",name="Master Duelist",desc="Win 50 duels",category="PvP",points=25,icon="Interface\\Icons\\INV_Sword_39"},
  pvp_duel_100={id="pvp_duel_100",name="Grand Duelist",desc="Win 100 duels",category="PvP",points=50,icon="Interface\\Icons\\INV_Sword_62"},
  pvp_wsg_flag_return={id="pvp_wsg_flag_return",name="Flag Defender",desc="Return 25 flags in Warsong Gulch",category="PvP",points=25,icon="Interface\\Icons\\INV_Banner_02"},
  pvp_ab_assault={id="pvp_ab_assault",name="Base Assault",desc="Assault 50 bases in Arathi Basin",category="PvP",points=25,icon="Interface\\Icons\\INV_BannerPVP_02"},
  pvp_av_towers={id="pvp_av_towers",name="Tower Assault",desc="Assault 25 towers in Alterac Valley",category="PvP",points=25,icon="Interface\\Icons\\INV_BannerPVP_01"},
  
  -- Elite Achievements
  elite_mc_speedrun={id="elite_mc_speedrun",name="Molten Core Speedrun",desc="Clear Molten Core in under 90 minutes",category="Elite",points=150,icon="Interface\\Icons\\Spell_Fire_BurningSpeed"},
  elite_bwl_speedrun={id="elite_bwl_speedrun",name="Blackwing Speedrun",desc="Clear BWL in under 60 minutes",category="Elite",points=200,icon="Interface\\Icons\\Spell_Fire_BurningSpeed"},
  elite_naxx_speedrun={id="elite_naxx_speedrun",name="Naxxramas Speedrun",desc="Clear Naxxramas in under 4 hours",category="Elite",points=300,icon="Interface\\Icons\\Spell_Fire_BurningSpeed"},
  elite_ironman={id="elite_ironman",name="Ironman",desc="Reach level 60 without dying",category="Elite",points=500,icon="Interface\\Icons\\INV_Helmet_74"},
  elite_flawless_rag={id="elite_flawless_rag",name="Flawless Ragnaros",desc="Defeat Ragnaros without anyone dying",category="Elite",points=250,icon="Interface\\Icons\\Spell_Fire_LavaSpawn"},
  elite_flawless_nef={id="elite_flawless_nef",name="Flawless Nefarian",desc="Defeat Nefarian without anyone dying",category="Elite",points=300,icon="Interface\\Icons\\INV_Misc_Head_Dragon_Black"},
  elite_flawless_cthun={id="elite_flawless_cthun",name="Flawless C'Thun",desc="Defeat C'Thun without anyone dying",category="Elite",points=400,icon="Interface\\Icons\\Spell_Shadow_Charm"},
  elite_flawless_kt={id="elite_flawless_kt",name="Flawless Kel'Thuzad",desc="Defeat Kel'Thuzad without anyone dying",category="Elite",points=500,icon="Interface\\Icons\\Spell_Shadow_SoulGem"},
  elite_solo_ubrs={id="elite_solo_ubrs",name="Solo UBRS",desc="Defeat General Drakkisath solo",category="Elite",points=200,icon="Interface\\Icons\\INV_Misc_Head_Dragon_01"},
  elite_solo_scholo={id="elite_solo_scholo",name="Solo Scholomance",desc="Defeat Darkmaster Gandling solo",category="Elite",points=200,icon="Interface\\Icons\\Spell_Shadow_Charm"},
  elite_solo_strat={id="elite_solo_strat",name="Solo Stratholme",desc="Defeat Baron Rivendare solo",category="Elite",points=200,icon="Interface\\Icons\\Spell_Shadow_RaiseDead"},
  elite_naked_rag={id="elite_naked_rag",name="Naked Ragnaros",desc="Defeat Ragnaros wearing no gear",category="Elite",points=1000,icon="Interface\\Icons\\INV_Shirt_GuildTabard_01"},
  elite_guild_first_mc={id="elite_guild_first_mc",name="Guild First MC",desc="First in your guild to clear Molten Core",category="Elite",points=100,icon="Interface\\Icons\\INV_Misc_Trophy_Gold"},
  elite_guild_first_bwl={id="elite_guild_first_bwl",name="Guild First BWL",desc="First in your guild to clear BWL",category="Elite",points=150,icon="Interface\\Icons\\INV_Misc_Trophy_Gold"},
  elite_guild_first_aq40={id="elite_guild_first_aq40",name="Guild First AQ40",desc="First in your guild to clear AQ40",category="Elite",points=200,icon="Interface\\Icons\\INV_Misc_Trophy_Gold"},
  elite_guild_first_naxx={id="elite_guild_first_naxx",name="Guild First Naxx",desc="First in your guild to clear Naxxramas",category="Elite",points=300,icon="Interface\\Icons\\INV_Misc_Trophy_Gold"},
  elite_no_wipe_mc={id="elite_no_wipe_mc",name="No Wipe MC",desc="Clear Molten Core with zero wipes",category="Elite",points=200,icon="Interface\\Icons\\INV_Misc_Ribbon_01"},
  elite_no_wipe_bwl={id="elite_no_wipe_bwl",name="No Wipe BWL",desc="Clear BWL with zero wipes",category="Elite",points=250,icon="Interface\\Icons\\INV_Misc_Ribbon_01"},
  elite_no_wipe_naxx={id="elite_no_wipe_naxx",name="No Wipe Naxx",desc="Clear Naxxramas with zero wipes",category="Elite",points=400,icon="Interface\\Icons\\INV_Misc_Ribbon_01"},
  elite_undergeared_rag={id="elite_undergeared_rag",name="Undergeared Ragnaros",desc="Defeat Ragnaros in all green gear",category="Elite",points=400,icon="Interface\\Icons\\INV_Chest_Cloth_17"},
  elite_pvp_rank_14={id="elite_pvp_rank_14",name="Grand Marshal",desc="Achieve PvP Rank 14",category="Elite",points=1000,icon="Interface\\Icons\\INV_Sword_39"},
  elite_resource_solo={id="elite_resource_solo",name="Self-Made",desc="Reach level 60 without trading or receiving help",category="Elite",points=300,icon="Interface\\Icons\\INV_Misc_Coin_17"},
  elite_all_raids_one_week={id="elite_all_raids_one_week",name="Raid Marathon",desc="Clear MC, BWL, AQ40, and Naxx in one week",category="Elite",points=500,icon="Interface\\Icons\\Spell_Holy_BorrowedTime"},
  elite_no_consumables_rag={id="elite_no_consumables_rag",name="Purist Raider",desc="Defeat Ragnaros without using consumables",category="Elite",points=300,icon="Interface\\Icons\\INV_Potion_54"},
  elite_tank_solo_5man={id="elite_tank_solo_5man",name="One Man Army",desc="Solo a level 60 dungeon as a tank",category="Elite",points=250,icon="Interface\\Icons\\Ability_Warrior_DefensiveStance"},
  elite_heal_no_death={id="elite_heal_no_death",name="Perfect Healer",desc="Complete a full raid without anyone dying while healing",category="Elite",points=300,icon="Interface\\Icons\\Spell_Holy_FlashHeal"},
  
  -- Casual Achievements
  casual_mount_60={id="casual_mount_60",name="First Mount",desc="Obtain your first mount at level 40",category="Casual",points=10,icon="Interface\\Icons\\Ability_Mount_Raptor"},
  casual_epic_mount={id="casual_epic_mount",name="Epic Mount",desc="Obtain an epic mount",category="Casual",points=25,icon="Interface\\Icons\\Ability_Mount_WhiteTiger"},
  casual_pet_collector={id="casual_pet_collector",name="Pet Collector",desc="Collect 10 vanity pets",category="Casual",points=15,icon="Interface\\Icons\\INV_Box_PetCarrier_01"},
  casual_pet_fanatic={id="casual_pet_fanatic",name="Pet Fanatic",desc="Collect 25 vanity pets",category="Casual",points=30,icon="Interface\\Icons\\INV_Box_PetCarrier_01"},
  casual_explore_barrens={id="casual_explore_barrens",name="Barrens Explorer",desc="Explore all of The Barrens",category="Casual",points=5,icon="Interface\\Icons\\INV_Misc_Map_01"},
  casual_explore_elwynn={id="casual_explore_elwynn",name="Elwynn Explorer",desc="Explore all of Elwynn Forest",category="Casual",points=5,icon="Interface\\Icons\\INV_Misc_Map_02"},
  casual_deaths_100={id="casual_deaths_100",name="Death's Door",desc="Die 100 times",category="Casual",points=5,icon="Interface\\Icons\\Spell_Shadow_DeathScream"},
  casual_hearthstone_use={id="casual_hearthstone_use",name="Frequent Traveler",desc="Use your hearthstone 50 times",category="Casual",points=10,icon="Interface\\Icons\\INV_Misc_Rune_01"},
  casual_eat_1000={id="casual_eat_1000",name="Glutton",desc="Consume 1000 food items",category="Casual",points=10,icon="Interface\\Icons\\INV_Misc_Food_15"},
  casual_drink_1000={id="casual_drink_1000",name="Drunkard",desc="Consume 1000 drinks",category="Casual",points=10,icon="Interface\\Icons\\INV_Drink_05"},
  casual_fish_100={id="casual_fish_100",name="Angler",desc="Catch 100 fish",category="Casual",points=10,icon="Interface\\Icons\\Trade_Fishing"},
  casual_fish_1000={id="casual_fish_1000",name="Master Angler",desc="Catch 1000 fish",category="Casual",points=25,icon="Interface\\Icons\\Trade_Fishing"},
  casual_quest_100={id="casual_quest_100",name="Quest Starter",desc="Complete 100 quests",category="Casual",points=10,icon="Interface\\Icons\\INV_Misc_Note_06"},
  casual_quest_500={id="casual_quest_500",name="Quest Master",desc="Complete 500 quests",category="Casual",points=25,icon="Interface\\Icons\\INV_Misc_Note_06"},
  casual_quest_1000={id="casual_quest_1000",name="Loremaster",desc="Complete 1000 quests",category="Casual",points=50,icon="Interface\\Icons\\INV_Misc_Book_09"},
  casual_friend_emote={id="casual_friend_emote",name="Social Butterfly",desc="Use 100 emotes on other players",category="Casual",points=5,icon="Interface\\Icons\\INV_Misc_Toy_07"},
  casual_guild_join={id="casual_guild_join",name="Guild Member",desc="Join a guild",category="Casual",points=5,icon="Interface\\Icons\\INV_Shirt_GuildTabard_01"},
  casual_party_join={id="casual_party_join",name="Team Player",desc="Join 50 groups",category="Casual",points=10,icon="Interface\\Icons\\INV_Misc_GroupNeedMore"},
  casual_mail_send={id="casual_mail_send",name="Postmaster",desc="Send 100 mail items",category="Casual",points=10,icon="Interface\\Icons\\INV_Letter_15"},
  casual_ah_buy={id="casual_ah_buy",name="Auction House Regular",desc="Buy 100 items from the auction house",category="Casual",points=15,icon="Interface\\Icons\\INV_Misc_Coin_01"},
  casual_ah_sell={id="casual_ah_sell",name="Merchant",desc="Sell 100 items on the auction house",category="Casual",points=15,icon="Interface\\Icons\\INV_Misc_Coin_05"},
  casual_haircut={id="casual_haircut",name="New Look",desc="Visit a barber shop",category="Casual",points=5,icon="Interface\\Icons\\INV_Misc_Ear_Human_01"},
  casual_emote_dance={id="casual_emote_dance",name="Dancer",desc="Use /dance 100 times",category="Casual",points=5,icon="Interface\\Icons\\INV_Misc_Toy_08"},
  casual_screenshot={id="casual_screenshot",name="Photographer",desc="Take 50 screenshots",category="Casual",points=10,icon="Interface\\Icons\\INV_Misc_Spyglass_03"},
  casual_fall_death={id="casual_fall_death",name="Falling Star",desc="Die from falling 10 times",category="Casual",points=5,icon="Interface\\Icons\\Ability_Rogue_FeintedStrike"},
  casual_drown={id="casual_drown",name="Landlubber",desc="Drown 10 times",category="Casual",points=5,icon="Interface\\Icons\\Spell_Frost_SummonWaterElemental_2"},
  casual_repair_1000g={id="casual_repair_1000g",name="Expensive Repairs",desc="Spend 1000 gold on repairs",category="Casual",points=20,icon="Interface\\Icons\\Trade_BlackSmithing"},
  casual_vendor_trash={id="casual_vendor_trash",name="Trash Collector",desc="Sell 1000 items to vendors",category="Casual",points=15,icon="Interface\\Icons\\INV_Misc_Bag_10"},
  casual_taxi_1000g={id="casual_taxi_1000g",name="Frequent Flyer",desc="Spend 1000 gold on flight paths",category="Casual",points=20,icon="Interface\\Icons\\Ability_Mount_Wyvern_01"},
  casual_bank_full={id="casual_bank_full",name="Pack Rat",desc="Fill your bank completely",category="Casual",points=10,icon="Interface\\Icons\\INV_Misc_Bag_22"},
}

local TITLES = {
  -- Leveling Titles
  {id="title_champion",name="Champion",achievement="lvl_60",prefix=false,icon="Interface\\Icons\\Spell_Holy_BlessingOfStrength"},
  {id="title_elder",name="the Elder",achievement="lvl_60",prefix=false,icon="Interface\\Icons\\Spell_Holy_BlessingOfStrength"},
  
  -- Molten Core Titles
  {id="title_firelord",name="Firelord",achievement="raid_mc_ragnaros",prefix=false,icon="Interface\\Icons\\Spell_Fire_LavaSpawn"},
  {id="title_flamewaker",name="Flamewaker",achievement="raid_mc_sulfuron",prefix=false,icon="Interface\\Icons\\Spell_Fire_FireArmor"},
  {id="title_core_hound",name="Core Hound",achievement="raid_mc_magmadar",prefix=false,icon="Interface\\Icons\\INV_Misc_Head_Dragon_01"},
  {id="title_molten_destroyer",name="Molten Destroyer",achievement="raid_mc_golemagg",prefix=false,icon="Interface\\Icons\\INV_Misc_MonsterScales_15"},
  
  -- Onyxia/Dragons
  {id="title_dragonslayer",name="Dragonslayer",achievement="raid_onyxia",prefix=false,icon="Interface\\Icons\\INV_Misc_Head_Dragon_01"},
  {id="title_dragon_hunter",name="Dragon Hunter",achievement="raid_onyxia",prefix=false,icon="Interface\\Icons\\INV_Misc_Head_Dragon_01"},
  
  -- Blackwing Lair Titles
  {id="title_blackwing_slayer",name="Blackwing Slayer",achievement="raid_bwl_nefarian",prefix=false,icon="Interface\\Icons\\INV_Misc_Head_Dragon_Black"},
  {id="title_dragonkin_slayer",name="Dragonkin Slayer",achievement="raid_bwl_razorgore",prefix=false,icon="Interface\\Icons\\INV_Misc_Head_Dragon_Black"},
  {id="title_chromatic",name="the Chromatic",achievement="raid_bwl_chromaggus",prefix=false,icon="Interface\\Icons\\INV_Misc_Head_Dragon_Bronze"},
  {id="title_vaels_bane",name="Vael's Bane",achievement="raid_bwl_vaelastrasz",prefix=false,icon="Interface\\Icons\\Spell_Shadow_ShadowWordDominate"},
  {id="title_broodlord_slayer",name="Broodlord Slayer",achievement="raid_bwl_broodlord",prefix=false,icon="Interface\\Icons\\INV_Bracer_18"},
  
  -- Zul'Gurub Titles
  {id="title_zandalar",name="of Zandalar",achievement="raid_zg_hakkar",prefix=false,icon="Interface\\Icons\\Spell_Shadow_PainSpike"},
  {id="title_bloodlord",name="Bloodlord",achievement="raid_zg_hakkar",prefix=false,icon="Interface\\Icons\\Spell_Shadow_PainSpike"},
  {id="title_troll_slayer",name="Troll Slayer",achievement="raid_zg_thekal",prefix=false,icon="Interface\\Icons\\Ability_Druid_Mangle2"},
  {id="title_snake_handler",name="Snake Handler",achievement="raid_zg_venoxis",prefix=false,icon="Interface\\Icons\\Spell_Nature_NullifyPoison"},
  
  -- AQ20 Titles
  {id="title_silithid_slayer",name="Silithid Slayer",achievement="raid_aq20_ossirian",prefix=false,icon="Interface\\Icons\\INV_Qiraj_JewelGlowing"},
  {id="title_scarab_hunter",name="Scarab Hunter",achievement="raid_aq20_kurinnaxx",prefix=false,icon="Interface\\Icons\\INV_Qiraj_JewelBlessed"},
  
  -- AQ40 Titles
  {id="title_scarab_lord",name="Scarab Lord",achievement="raid_aq40_cthun",prefix=false,icon="Interface\\Icons\\Spell_Shadow_Charm"},
  {id="title_qiraji_slayer",name="Qiraji Slayer",achievement="raid_aq40_cthun",prefix=false,icon="Interface\\Icons\\Spell_Shadow_Charm"},
  {id="title_bug_squasher",name="Bug Squasher",achievement="raid_aq40_bug_trio",prefix=false,icon="Interface\\Icons\\INV_Misc_AhnQirajTrinket_02"},
  {id="title_twin_emperor",name="Twin Emperor",achievement="raid_aq40_twins",prefix=false,icon="Interface\\Icons\\INV_Jewelry_Ring_AhnQiraj_04"},
  {id="title_viscidus_slayer",name="Viscidus Slayer",achievement="raid_aq40_viscidus",prefix=false,icon="Interface\\Icons\\Spell_Nature_Acid_01"},
  {id="title_the_prophet",name="the Prophet",achievement="raid_aq40_skeram",prefix=false,icon="Interface\\Icons\\Spell_Shadow_MindSteal"},
  
  -- Naxxramas Titles
  {id="title_death_demise",name="of the Ashen Verdict",achievement="raid_naxx_kelthuzad",prefix=false,icon="Interface\\Icons\\Spell_Shadow_SoulGem"},
  {id="title_immortal",name="the Immortal",achievement="elite_flawless_kt",prefix=false,icon="Interface\\Icons\\Spell_Holy_DivineIntervention"},
  {id="title_undying",name="the Undying",achievement="elite_no_wipe_naxx",prefix=false,icon="Interface\\Icons\\Spell_Shadow_RaiseDead"},
  {id="title_patient",name="the Patient",achievement="elite_no_wipe_naxx",prefix=false,icon="Interface\\Icons\\Spell_Nature_TimeStop"},
  {id="title_lich_hunter",name="Lich Hunter",achievement="raid_naxx_kelthuzad",prefix=false,icon="Interface\\Icons\\Spell_Shadow_SoulGem"},
  {id="title_plaguebearer",name="Plaguebearer",achievement="raid_naxx_loatheb",prefix=false,icon="Interface\\Icons\\Spell_Shadow_CallofBone"},
  {id="title_spore_bane",name="Spore Bane",achievement="raid_naxx_loatheb",prefix=false,icon="Interface\\Icons\\Spell_Shadow_CallofBone"},
  {id="title_frost_wyrm",name="Frost Wyrm Slayer",achievement="raid_naxx_sapphiron",prefix=false,icon="Interface\\Icons\\INV_Misc_Head_Dragon_Blue"},
  {id="title_arachnid_slayer",name="Arachnid Slayer",achievement="raid_naxx_maexxna",prefix=false,icon="Interface\\Icons\\INV_Misc_MonsterSpiderCarapace_01"},
  {id="title_four_horsemen",name="of the Four Horsemen",achievement="raid_naxx_four_horsemen",prefix=false,icon="Interface\\Icons\\Spell_DeathKnight_ClassIcon"},
  {id="title_death_knight",name="Death Knight",achievement="raid_naxx_four_horsemen",prefix=false,icon="Interface\\Icons\\Spell_DeathKnight_ClassIcon"},
  
  -- Elite Raid Titles
  {id="title_insane",name="the Insane",achievement="elite_naked_rag",prefix=false,icon="Interface\\Icons\\Spell_Shadow_Charm"},
  {id="title_flawless",name="the Flawless",achievement="elite_flawless_cthun",prefix=false,icon="Interface\\Icons\\Spell_Holy_BlessingOfStrength"},
  {id="title_speed_demon",name="Speed Demon",achievement="elite_naxx_speedrun",prefix=false,icon="Interface\\Icons\\Spell_Fire_BurningSpeed"},
  {id="title_speed_runner",name="the Speed Runner",achievement="elite_mc_speedrun",prefix=false,icon="Interface\\Icons\\Spell_Fire_BurningSpeed"},
  {id="title_unstoppable",name="the Unstoppable",achievement="elite_no_wipe_bwl",prefix=false,icon="Interface\\Icons\\INV_Misc_Ribbon_01"},
  {id="title_perfect",name="the Perfect",achievement="elite_flawless_nef",prefix=false,icon="Interface\\Icons\\INV_Misc_Head_Dragon_Black"},
  {id="title_flawless_firelord",name="Flawless Firelord",achievement="elite_flawless_rag",prefix=false,icon="Interface\\Icons\\Spell_Fire_LavaSpawn"},
  {id="title_untouchable",name="the Untouchable",achievement="elite_flawless_kt",prefix=false,icon="Interface\\Icons\\Spell_Shadow_SoulGem"},
  
  -- Elite Achievement Titles
  {id="title_ironman",name="the Ironman",achievement="elite_ironman",prefix=false,icon="Interface\\Icons\\INV_Helmet_74"},
  {id="title_guild_pioneer",name="Guild Pioneer",achievement="elite_guild_first_mc",prefix=false,icon="Interface\\Icons\\INV_Misc_Trophy_Gold"},
  {id="title_legendary",name="the Legendary",achievement="elite_guild_first_naxx",prefix=false,icon="Interface\\Icons\\INV_Misc_Trophy_Gold"},
  {id="title_undergeared",name="the Undergeared",achievement="elite_undergeared_rag",prefix=false,icon="Interface\\Icons\\INV_Chest_Cloth_17"},
  {id="title_self_made",name="the Self-Made",achievement="elite_resource_solo",prefix=false,icon="Interface\\Icons\\INV_Misc_Coin_17"},
  {id="title_raid_marathon",name="Raid Marathoner",achievement="elite_all_raids_one_week",prefix=false,icon="Interface\\Icons\\Spell_Holy_BorrowedTime"},
  {id="title_purist",name="the Purist",achievement="elite_no_consumables_rag",prefix=false,icon="Interface\\Icons\\INV_Potion_54"},
  {id="title_one_man_army",name="One Man Army",achievement="elite_tank_solo_5man",prefix=false,icon="Interface\\Icons\\Ability_Warrior_DefensiveStance"},
  {id="title_perfect_healer",name="Perfect Healer",achievement="elite_heal_no_death",prefix=false,icon="Interface\\Icons\\Spell_Holy_FlashHeal"},
  {id="title_solo_hero",name="Solo Hero",achievement="elite_solo_ubrs",prefix=false,icon="Interface\\Icons\\INV_Misc_Head_Dragon_01"},
  {id="title_death_defier",name="Death Defier",achievement="elite_solo_strat",prefix=false,icon="Interface\\Icons\\Spell_Shadow_RaiseDead"},
  
  -- PvP Titles
  {id="title_warlord",name="Warlord",achievement="pvp_hk_5000",prefix=true,icon="Interface\\Icons\\INV_Sword_62"},
  {id="title_grand_marshal",name="Grand Marshal",achievement="elite_pvp_rank_14",prefix=true,icon="Interface\\Icons\\INV_Sword_39"},
  {id="title_bloodthirsty",name="the Bloodthirsty",achievement="pvp_hk_10000",prefix=false,icon="Interface\\Icons\\Spell_Shadow_BloodBoil"},
  {id="title_arena_master",name="Arena Master",achievement="pvp_duel_100",prefix=false,icon="Interface\\Icons\\INV_Sword_62"},
  {id="title_gladiator",name="Gladiator",achievement="pvp_hk_1000",prefix=false,icon="Interface\\Icons\\INV_Sword_48"},
  {id="title_duelist",name="the Duelist",achievement="pvp_duel_50",prefix=false,icon="Interface\\Icons\\INV_Sword_39"},
  {id="title_high_warlord",name="High Warlord",achievement="pvp_hk_10000",prefix=true,icon="Interface\\Icons\\INV_Sword_39"},
  {id="title_battlemaster",name="Battlemaster",achievement="pvp_wsg_flag_return",prefix=false,icon="Interface\\Icons\\INV_Banner_02"},
  
  -- Profession Titles
  {id="title_master_alchemist",name="Master Alchemist",achievement="prof_alchemy_300",prefix=false,icon="Interface\\Icons\\Trade_Alchemy"},
  {id="title_master_blacksmith",name="Master Blacksmith",achievement="prof_blacksmithing_300",prefix=false,icon="Interface\\Icons\\Trade_BlackSmithing"},
  {id="title_master_enchanter",name="Master Enchanter",achievement="prof_enchanting_300",prefix=false,icon="Interface\\Icons\\Trade_Engraving"},
  {id="title_master_engineer",name="Master Engineer",achievement="prof_engineering_300",prefix=false,icon="Interface\\Icons\\Trade_Engineering"},
  {id="title_artisan",name="the Artisan",achievement="prof_dual_artisan",prefix=false,icon="Interface\\Icons\\INV_Misc_Note_06"},
  
  -- Casual Titles
  {id="title_explorer",name="the Explorer",achievement="explore_kalimdor",prefix=false,icon="Interface\\Icons\\INV_Misc_Map_01"},
  {id="title_loremaster",name="Loremaster",achievement="casual_quest_1000",prefix=false,icon="Interface\\Icons\\INV_Misc_Book_09"},
  {id="title_angler",name="the Master Angler",achievement="casual_fish_1000",prefix=false,icon="Interface\\Icons\\Trade_Fishing"},
  {id="title_pet_collector",name="the Pet Collector",achievement="casual_pet_fanatic",prefix=false,icon="Interface\\Icons\\INV_Box_PetCarrier_01"},
  {id="title_merchant",name="the Merchant",achievement="casual_ah_sell",prefix=false,icon="Interface\\Icons\\INV_Misc_Coin_05"},
  {id="title_glutton",name="the Glutton",achievement="casual_eat_1000",prefix=false,icon="Interface\\Icons\\INV_Misc_Food_15"},
  {id="title_drunkard",name="the Drunkard",achievement="casual_drink_1000",prefix=false,icon="Interface\\Icons\\INV_Drink_05"},
  {id="title_banker",name="the Banker",achievement="gold_5000",prefix=false,icon="Interface\\Icons\\INV_Misc_Coin_17"},
  {id="title_socialite",name="the Socialite",achievement="casual_friend_emote",prefix=false,icon="Interface\\Icons\\INV_Misc_Toy_07"},
  {id="title_death_prone",name="Death-Prone",achievement="casual_deaths_100",prefix=false,icon="Interface\\Icons\\Spell_Shadow_DeathScream"},
  {id="title_clumsy",name="the Clumsy",achievement="casual_fall_death",prefix=false,icon="Interface\\Icons\\Ability_Rogue_FeintedStrike"},
  
  -- Gold Titles
  {id="title_wealthy",name="the Wealthy",achievement="gold_1000",prefix=false,icon="Interface\\Icons\\INV_Misc_Coin_06"},
  {id="title_fortune_builder",name="Fortune Builder",achievement="gold_5000",prefix=false,icon="Interface\\Icons\\INV_Misc_Coin_17"},
  {id="title_tycoon",name="the Tycoon",achievement="gold_5000",prefix=false,icon="Interface\\Icons\\INV_Misc_Coin_17"},
  
  -- Dungeon Titles
  {id="title_dungeoneer",name="the Dungeoneer",achievement="dung_ubrs",prefix=false,icon="Interface\\Icons\\INV_Misc_Head_Dragon_01"},
  {id="title_undead_slayer",name="Undead Slayer",achievement="dung_stratholme",prefix=false,icon="Interface\\Icons\\Spell_Shadow_RaiseDead"},
  {id="title_shadow_hunter",name="Shadow Hunter",achievement="dung_scholo",prefix=false,icon="Interface\\Icons\\Spell_Shadow_Charm"},
  {id="title_dungeon_master",name="Dungeon Master",achievement="dung_diremaul_north",prefix=false,icon="Interface\\Icons\\INV_Misc_Key_14"},
}

-- ==========================================
-- PUBLIC API FOR OTHER ADDONS
-- ==========================================

local function GetAchievementIcon(achId)
  if not achId then return "Interface\\Icons\\INV_Misc_QuestionMark" end
  
  -- Check ACHIEVEMENTS table first
  local achData = ACHIEVEMENTS[achId]
  if achData and achData.icon then
    return achData.icon
  end
  
  -- Fallback icons based on achievement ID pattern
  local lowerAchId = string.lower(achId)
  
  -- Leveling icons
  if string.find(lowerAchId, "^lvl_") then
    return "Interface\\Icons\\INV_Misc_Book_09"
  end
  
  -- Profession icons
  if string.find(lowerAchId, "^prof_") then
    return "Interface\\Icons\\Trade_Engineering"
  end
  
  -- Gold icons
  if string.find(lowerAchId, "^gold_") then
    return "Interface\\Icons\\INV_Misc_Coin_01"
  end
  
  -- Dungeon icons
  if string.find(lowerAchId, "^dung_") then
    return "Interface\\Icons\\INV_Misc_Key_14"
  end
  
  -- Raid icons
  if string.find(lowerAchId, "^raid_") then
    return "Interface\\Icons\\INV_Misc_Head_Dragon_01"
  end
  
  -- PvP icons
  if string.find(lowerAchId, "^pvp_") then
    return "Interface\\Icons\\INV_Sword_48"
  end
  
  -- Elite icons
  if string.find(lowerAchId, "^elite_") then
    return "Interface\\Icons\\INV_Misc_Trophy_Gold"
  end
  
  -- Casual icons
  if string.find(lowerAchId, "^casual_") then
    return "Interface\\Icons\\INV_Misc_Gift_01"
  end
  
  -- Exploration icons
  if string.find(lowerAchId, "^explore_") then
    return "Interface\\Icons\\INV_Misc_Map_01"
  end
  
  -- Default fallback
  return "Interface\\Icons\\INV_Misc_QuestionMark"
end

local function GetAchievementIcon(achId)
  if not achId then return "Interface\\Icons\\INV_Misc_QuestionMark" end
  
  -- Check ACHIEVEMENTS table first
  local achData = ACHIEVEMENTS[achId]
  if achData and achData.icon then
    return achData.icon
  end
  
  -- Fallback icons based on achievement ID pattern
  local lowerAchId = string.lower(achId)
  
  -- Leveling icons
  if string.find(lowerAchId, "^lvl_") then
    return "Interface\\Icons\\INV_Misc_Book_09"
  end
  
  -- Profession icons
  if string.find(lowerAchId, "^prof_") then
    return "Interface\\Icons\\Trade_Engineering"
  end
  
  -- Gold icons
  if string.find(lowerAchId, "^gold_") then
    return "Interface\\Icons\\INV_Misc_Coin_01"
  end
  
  -- Dungeon icons
  if string.find(lowerAchId, "^dung_") then
    return "Interface\\Icons\\INV_Misc_Key_14"
  end
  
  -- Raid icons
  if string.find(lowerAchId, "^raid_") then
    return "Interface\\Icons\\INV_Misc_Head_Dragon_01"
  end
  
  -- PvP icons
  if string.find(lowerAchId, "^pvp_") then
    return "Interface\\Icons\\INV_Sword_48"
  end
  
  -- Elite icons
  if string.find(lowerAchId, "^elite_") then
    return "Interface\\Icons\\INV_Misc_Trophy_Gold"
  end
  
  -- Casual icons
  if string.find(lowerAchId, "^casual_") then
    return "Interface\\Icons\\INV_Misc_Gift_01"
  end
  
  -- Exploration icons
  if string.find(lowerAchId, "^explore_") then
    return "Interface\\Icons\\INV_Misc_Map_01"
  end
  
  -- Default fallback
  return "Interface\\Icons\\INV_Misc_QuestionMark"
end

-- ==========================================
-- PUBLIC API FOR OTHER ADDONS
-- ==========================================

LeafVE_AchTest.API = {
  GetPlayerPoints = function(playerName)
    return LeafVE_AchTest:GetTotalAchievementPoints(playerName)
  end,
  
  GetRecentAchievements = function(playerName, count)
    if not LeafVE_AchTest_DB or not LeafVE_AchTest_DB.achievements then return {} end
    playerName = ShortName(playerName)
    if not playerName then return {} end
    if not LeafVE_AchTest_DB.achievements[playerName] then return {} end
    
    local achievements = {}
    for achId, achData in pairs(LeafVE_AchTest_DB.achievements[playerName]) do
      if type(achData) == "table" and achData.points and achData.timestamp then
        local achievement = ACHIEVEMENTS[achId]
        if achievement then
          table.insert(achievements, {
            id = achId,
            name = achievement.name,
            icon = GetAchievementIcon(achId),
            points = achData.points,
            timestamp = achData.timestamp
          })
        end
      end
    end
    
    -- Sort by most recent
    table.sort(achievements, function(a, b) return a.timestamp > b.timestamp end)
    
    -- Return only the requested count
    local result = {}
    for i = 1, math.min(count or 5, table.getn(achievements)) do
      table.insert(result, achievements[i])
    end
    
    return result
  end
}

Print("Achievement API loaded!")

-- Store original SendChatMessage before hooking
local originalSendChatMessage = SendChatMessage

-- Store original SendChatMessage before hooking
local originalSendChatMessage = SendChatMessage

-- Store original SendChatMessage before hooking
local originalSendChatMessage = SendChatMessage

function LeafVE_AchTest:GetPlayerAchievements(playerName)
  EnsureDB()
  playerName = ShortName(playerName or UnitName("player"))
  if not playerName then return {} end
  if not LeafVE_AchTest_DB.achievements[playerName] then
    LeafVE_AchTest_DB.achievements[playerName] = {}
  end
  return LeafVE_AchTest_DB.achievements[playerName]
end

function LeafVE_AchTest:HasAchievement(playerName, achievementID)
  local achievements = self:GetPlayerAchievements(playerName)
  return achievements[achievementID] ~= nil
end

function LeafVE_AchTest:ShowAchievementPopup(achievementID)
  local achievement = ACHIEVEMENTS[achievementID]
  if not achievement then return end
  
  local popup = CreateFrame("Frame", nil, UIParent)
  popup:SetWidth(320)
  popup:SetHeight(90)
  popup:SetPoint("TOP", UIParent, "TOP", 0, -150)
  popup:SetFrameStrata("HIGH")
  popup:SetAlpha(0)
  
  popup:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = {left = 4, right = 4, top = 4, bottom = 4}
  })
  popup:SetBackdropColor(0, 0, 0, 0.9)
  popup:SetBackdropBorderColor(THEME.orange[1], THEME.orange[2], THEME.orange[3], 1)
  
  local earnedText = popup:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  earnedText:SetPoint("TOP", popup, "TOP", 0, -10)
  earnedText:SetText("|cFFFF7F00Achievement Earned!|r")
  
  local icon = popup:CreateTexture(nil, "ARTWORK")
  icon:SetWidth(48)
  icon:SetHeight(48)
  icon:SetPoint("LEFT", popup, "LEFT", 15, -5)
  icon:SetTexture(achievement.icon)
  icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
  
  local nameText = popup:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  nameText:SetPoint("TOPLEFT", icon, "TOPRIGHT", 10, 0)
  nameText:SetPoint("RIGHT", popup, "RIGHT", -10, 0)
  nameText:SetJustifyH("LEFT")
  nameText:SetText("|cFF2DD35C"..achievement.name.."|r")
  
  local descText = popup:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  descText:SetPoint("TOPLEFT", nameText, "BOTTOMLEFT", 0, -3)
  descText:SetPoint("RIGHT", popup, "RIGHT", -10, 0)
  descText:SetJustifyH("LEFT")
  descText:SetText(achievement.desc)
  
  local pointsText = popup:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  pointsText:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT", 10, 0)
  pointsText:SetText("|cFFFF7F00+"..achievement.points.." points|r")
  
  local fadeIn = 0
  local stay = 0
  local fadeOut = 0
  
  popup:SetScript("OnUpdate", function()
    if fadeIn < 0.5 then
      fadeIn = fadeIn + arg1
      popup:SetAlpha(fadeIn / 0.5)
    elseif stay < 4 then
      stay = stay + arg1
      popup:SetAlpha(1)
    elseif fadeOut < 0.5 then
      fadeOut = fadeOut + arg1
      popup:SetAlpha(1 - (fadeOut / 0.5))
    else
      popup:Hide()
      popup = nil
    end
  end)
  
  popup:Show()
  PlaySound("LevelUp")
end

-- Broadcast your achievements to guild
function LeafVE_AchTest:BroadcastAchievements()
  if not IsInGuild() then return end
  
  local me = ShortName(UnitName("player"))
  if not me then return end
  
  local myAchievements = self:GetPlayerAchievements(me)
  
  -- Build compressed achievement list (just IDs and timestamps)
  local achData = {}
  for achID, data in pairs(myAchievements) do
    table.insert(achData, achID..":"..data.timestamp..":"..data.points)
  end
  
  local message = table.concat(achData, ",")
  
  -- Send via addon channel
  SendAddonMessage("LeafVEAch", "SYNC:"..message, "GUILD")
  Debug("Broadcast "..table.getn(achData).." achievements to guild")
end

-- Receive other players' achievements
function LeafVE_AchTest:OnAddonMessage(prefix, message, channel, sender)
  if prefix ~= "LeafVEAch" then return end
  if channel ~= "GUILD" then return end
  
  sender = ShortName(sender)
  if not sender then return end
  
  -- Parse sync message
  if string.sub(message, 1, 5) == "SYNC:" then
    local achData = string.sub(message, 6)
    
    if not LeafVE_AchTest_DB.achievements[sender] then
      LeafVE_AchTest_DB.achievements[sender] = {}
    end
    
    -- Parse achievement data
    local achievements = {}
    for achEntry in string.gfind(achData, "[^,]+") do
      local achID, timestamp, points = string.match(achEntry, "([^:]+):([^:]+):([^:]+)")
      if achID and timestamp and points then
        achievements[achID] = {
          timestamp = tonumber(timestamp),
          points = tonumber(points)
        }
      end
    end
    
    -- Update stored data for this player
    LeafVE_AchTest_DB.achievements[sender] = achievements
    Debug("Received "..table.getn(achievements).." achievements from "..sender)
    
    -- Refresh UI if viewing this player
    if LeafVE and LeafVE.UI and LeafVE.UI.cardCurrentPlayer == sender then
      LeafVE.UI:ShowPlayerCard(sender)
    end
  end
end

-- Hook into existing event frame
local syncFrame = CreateFrame("Frame")
syncFrame:RegisterEvent("CHAT_MSG_ADDON")
syncFrame:SetScript("OnEvent", function()
  if event == "CHAT_MSG_ADDON" then
    LeafVE_AchTest:OnAddonMessage(arg1, arg2, arg3, arg4)
  end
end)

-- Auto-broadcast on login and every 5 minutes
local broadcastTimer = 0
local broadcastFrame = CreateFrame("Frame")
broadcastFrame:SetScript("OnUpdate", function()
  broadcastTimer = broadcastTimer + arg1
  if broadcastTimer >= 300 then -- 5 minutes
    broadcastTimer = 0
    LeafVE_AchTest:BroadcastAchievements()
  end
end)

-- Broadcast on first load
local loginFrame = CreateFrame("Frame")
loginFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
loginFrame:SetScript("OnEvent", function()
  if event == "PLAYER_ENTERING_WORLD" then
    -- Wait 5 seconds after login before broadcasting
    local waitTimer = 0
    this:SetScript("OnUpdate", function()
      waitTimer = waitTimer + arg1
      if waitTimer >= 5 then
        LeafVE_AchTest:BroadcastAchievements()
        this:SetScript("OnUpdate", nil)
      end
    end)
  end
end)

Print("Achievement sync system loaded!")

function LeafVE_AchTest:AwardAchievement(achievementID, silent)
  local playerName = UnitName("player")
  if not playerName or playerName == "" then return end
  local me = ShortName(playerName)
  if not me or me == "" then return end
  if self:HasAchievement(me, achievementID) then
    Print("You already have this achievement!")
    return
  end
  local achievement = ACHIEVEMENTS[achievementID]
  if not achievement then return end
  local achievements = self:GetPlayerAchievements(me)
  achievements[achievementID] = {timestamp = Now(), points = achievement.points}
  
  if not silent then
    self:ShowAchievementPopup(achievementID)
    Print("Achievement earned: "..achievement.name.." (+"..achievement.points.." pts)")
  end
  
  -- Guild announcement with ORANGE title only - player name is automatic by WoW
  if IsInGuild() then
    local currentTitle = self:GetCurrentTitle(me)
    local guildMsg = ""
    
    -- Build message: [Title] [LeafVE Achievement] earned [Achievement]
    if currentTitle then
      guildMsg = "|cFFFF7F00["..currentTitle.name.."]|r |cFF2DD35C[LeafVE Achievement]|r earned |cFF2DD35C["..achievement.name.."]|r"
    else
      guildMsg = "|cFF2DD35C[LeafVE Achievement]|r earned |cFF2DD35C["..achievement.name.."]|r"
    end
    
    -- Use original SendChatMessage to avoid adding title twice
    if originalSendChatMessage then
      originalSendChatMessage(guildMsg, "GUILD")
    else
      SendChatMessage(guildMsg, "GUILD")
    end
    
    Debug("Sent guild achievement: "..guildMsg)
  end
  
  if LeafVE_AchTest.UI and LeafVE_AchTest.UI.Refresh then
    LeafVE_AchTest.UI:Refresh()
  end
  
  -- Notify LeafLegends to refresh if it's open
  if LeafVE and LeafVE.UI and LeafVE.UI.ShowPlayerCard and LeafVE.UI.cardCurrentPlayer then
    LeafVE.UI:ShowPlayerCard(LeafVE.UI.cardCurrentPlayer)
  end
end

function LeafVE_AchTest:GetTotalAchievementPoints(playerName)
  local achievements = self:GetPlayerAchievements(playerName)
  local total = 0
  for achID, data in pairs(achievements) do
    local ach = ACHIEVEMENTS[achID]
    if ach then total = total + ach.points end
  end
  return total
end

function LeafVE_AchTest:GetCurrentTitle(playerName)
  EnsureDB()
  playerName = ShortName(playerName or UnitName("player"))
  if not playerName then return nil end
  local titleData = LeafVE_AchTest_DB.selectedTitles[playerName]
  if not titleData then return nil end
  local titleID = titleData
  local asPrefix = false
  if type(titleData) == "table" then
    titleID = titleData.id
    asPrefix = titleData.asPrefix or false
  end
  for _, title in ipairs(TITLES) do
    if title.id == titleID then
      return {id=title.id,name=title.name,achievement=title.achievement,prefix=asPrefix}
    end
  end
  return nil
end

function LeafVE_AchTest:SetTitle(playerName, titleID, usePrefix)
  EnsureDB()
  playerName = ShortName(playerName or UnitName("player"))
  if not playerName then return end
  if not titleID or titleID == "" then return end
  local titleData = nil
  for _, title in ipairs(TITLES) do
    if title.id == titleID then titleData = title break end
  end
  if not titleData then return end
  if self:HasAchievement(playerName, titleData.achievement) then
    LeafVE_AchTest_DB.selectedTitles[playerName] = {id=titleID,asPrefix=usePrefix or false}
    local displayText = usePrefix and (titleData.name.." "..playerName) or (playerName.." "..titleData.name)
    Print("Title set to: |cFFFF7F00"..displayText.."|r")
    if LeafVE_AchTest.UI and LeafVE_AchTest.UI.Refresh then
      LeafVE_AchTest.UI:Refresh()
    end
  else
    Print("You haven't earned that title yet!")
  end
end

function LeafVE_AchTest:CheckLevelAchievements()
  local level = UnitLevel("player")
  if level >= 10 then self:AwardAchievement("lvl_10", true) end
  if level >= 20 then self:AwardAchievement("lvl_20", true) end
  if level >= 30 then self:AwardAchievement("lvl_30", true) end
  if level >= 40 then self:AwardAchievement("lvl_40", true) end
  if level >= 50 then self:AwardAchievement("lvl_50", true) end
  if level >= 60 then self:AwardAchievement("lvl_60") end
end

function LeafVE_AchTest:CheckGoldAchievements()
  local gold = math.floor(GetMoney() / 10000)
  if gold >= 10 then self:AwardAchievement("gold_10", true) end
  if gold >= 100 then self:AwardAchievement("gold_100", true) end
  if gold >= 500 then self:AwardAchievement("gold_500", true) end
  if gold >= 1000 then self:AwardAchievement("gold_1000", true) end
  if gold >= 5000 then self:AwardAchievement("gold_5000", true) end
end

LeafVE_AchTest.UI = {}
LeafVE_AchTest.UI.currentView = "achievements"
LeafVE_AchTest.UI.selectedCategory = "All"
LeafVE_AchTest.UI.searchText = ""
LeafVE_AchTest.UI.titleSearchText = ""

-- Boss kill tracking
local BOSS_ACHIEVEMENTS = {
  -- Ragefire Chasm
  ["Taragaman the Hungerer"] = "dung_rfc",
  
  -- Wailing Caverns
  ["Mutanus the Devourer"] = "dung_wc",
  
  -- Deadmines
  ["Edwin VanCleef"] = "dung_dm",
  
  -- Shadowfang Keep
  ["Archmage Arugal"] = "dung_sfk",
  
  -- Blackfathom Deeps
  ["Aku'mai"] = "dung_bfd",
  
  -- Stockade
  ["Bazil Thredd"] = "dung_stocks",
  
  -- Gnomeregan
  ["Mekgineer Thermaplugg"] = "dung_gnomer",
  
  -- Razorfen Kraul
  ["Charlga Razorflank"] = "dung_rfk",
  
  -- Scarlet Monastery
  ["Bloodmage Thalnos"] = "dung_sm_graveyard",
  ["Arcanist Doan"] = "dung_sm_library",
  ["Herod"] = "dung_sm_armory",
  ["High Inquisitor Whitemane"] = "dung_sm_cathedral",
  
  -- Razorfen Downs
  ["Amnennar the Coldbringer"] = "dung_rfdown",
  
  -- Uldaman
  ["Archaedas"] = "dung_ulda",
  
  -- Zul'Farrak
  ["Chief Ukorz Sandscalp"] = "dung_zf",
  
  -- Maraudon
  ["Princess Theradras"] = "dung_mara",
  
  -- Sunken Temple
  ["Shade of Eranikus"] = "dung_st",
  
  -- Blackrock Depths
  ["Emperor Dagran Thaurissan"] = "dung_brd",
  
  -- Scholomance
  ["Darkmaster Gandling"] = "dung_scholo",
  
  -- Stratholme
  ["Baron Rivendare"] = "dung_stratholme",
  
  -- Lower Blackrock Spire
  ["Overlord Wyrmthalak"] = "dung_lbrs",
  
  -- Upper Blackrock Spire
  ["General Drakkisath"] = "dung_ubrs",
  
  -- Dire Maul
  ["Alzzin the Wildshaper"] = "dung_diremaul_east",
  ["Prince Tortheldrin"] = "dung_diremaul_west",
  ["King Gordok"] = "dung_diremaul_north",
  
  -- Molten Core
  ["Lucifron"] = "raid_mc_lucifron",
  ["Magmadar"] = "raid_mc_magmadar",
  ["Gehennas"] = "raid_mc_gehennas",
  ["Garr"] = "raid_mc_garr",
  ["Baron Geddon"] = "raid_mc_geddon",
  ["Shazzrah"] = "raid_mc_shazzrah",
  ["Sulfuron Harbinger"] = "raid_mc_sulfuron",
  ["Golemagg the Incinerator"] = "raid_mc_golemagg",
  ["Majordomo Executus"] = "raid_mc_majordomo",
  ["Ragnaros"] = "raid_mc_ragnaros",
  
  -- Onyxia
  ["Onyxia"] = "raid_onyxia",
  
  -- Blackwing Lair
  ["Razorgore the Untamed"] = "raid_bwl_razorgore",
  ["Vaelastrasz the Corrupt"] = "raid_bwl_vaelastrasz",
  ["Broodlord Lashlayer"] = "raid_bwl_broodlord",
  ["Firemaw"] = "raid_bwl_firemaw",
  ["Ebonroc"] = "raid_bwl_ebonroc",
  ["Flamegor"] = "raid_bwl_flamegor",
  ["Chromaggus"] = "raid_bwl_chromaggus",
  ["Nefarian"] = "raid_bwl_nefarian",
  
  -- Zul'Gurub
  ["High Priest Venoxis"] = "raid_zg_venoxis",
  ["High Priestess Jeklik"] = "raid_zg_jeklik",
  ["High Priestess Mar'li"] = "raid_zg_marli",
  ["High Priest Thekal"] = "raid_zg_thekal",
  ["High Priestess Arlokk"] = "raid_zg_arlokk",
  ["Hakkar"] = "raid_zg_hakkar",
  
  -- AQ20
  ["Kurinnaxx"] = "raid_aq20_kurinnaxx",
  ["General Rajaxx"] = "raid_aq20_rajaxx",
  ["Moam"] = "raid_aq20_moam",
  ["Buru the Gorger"] = "raid_aq20_buru",
  ["Ayamiss the Hunter"] = "raid_aq20_ayamiss",
  ["Ossirian the Unscarred"] = "raid_aq20_ossirian",
  
  -- AQ40
  ["The Prophet Skeram"] = "raid_aq40_skeram",
  ["Fankriss the Unyielding"] = "raid_aq40_fankriss",
  ["Viscidus"] = "raid_aq40_viscidus",
  ["Princess Huhuran"] = "raid_aq40_huhuran",
  ["Emperor Vek'lor"] = "raid_aq40_twins",
  ["Ouro"] = "raid_aq40_ouro",
  ["C'Thun"] = "raid_aq40_cthun",
  
  -- Special AQ40 (Bug Trio)
  ["Lord Kri"] = "raid_aq40_bug_trio",
  ["Princess Yauj"] = "raid_aq40_bug_trio",
  ["Vem"] = "raid_aq40_bug_trio",
  
  -- Special AQ40 (Sartura)
  ["Battleguard Sartura"] = "raid_aq40_sartura",
  
  -- Naxxramas
  ["Anub'Rekhan"] = "raid_naxx_anubrekhan",
  ["Grand Widow Faerlina"] = "raid_naxx_faerlina",
  ["Maexxna"] = "raid_naxx_maexxna",
  ["Noth the Plaguebringer"] = "raid_naxx_noth",
  ["Heigan the Unclean"] = "raid_naxx_heigan",
  ["Loatheb"] = "raid_naxx_loatheb",
  ["Instructor Razuvious"] = "raid_naxx_razuvious",
  ["Gothik the Harvester"] = "raid_naxx_gothik",
  ["Highlord Mograine"] = "raid_naxx_four_horsemen",
  ["Thane Korth'azz"] = "raid_naxx_four_horsemen",
  ["Lady Blaumeux"] = "raid_naxx_four_horsemen",
  ["Sir Zeliek"] = "raid_naxx_four_horsemen",
  ["Patchwerk"] = "raid_naxx_patchwerk",
  ["Grobbulus"] = "raid_naxx_grobbulus",
  ["Gluth"] = "raid_naxx_gluth",
  ["Thaddius"] = "raid_naxx_thaddius",
  ["Sapphiron"] = "raid_naxx_sapphiron",
  ["Kel'Thuzad"] = "raid_naxx_kelthuzad",
}

function LeafVE_AchTest:CheckBossKill(bossName)
  if BOSS_ACHIEVEMENTS[bossName] then
    Debug("Boss kill detected: "..bossName)
    self:AwardAchievement(BOSS_ACHIEVEMENTS[bossName])
  end
end

function LeafVE_AchTest.UI:Build()
  if self.frame then
    self.frame:Show()
    self:Refresh()
    return
  end
  
  local f = CreateFrame("Frame", "LeafVE_AchTestFrame", UIParent)
  self.frame = f
  f:SetPoint("CENTER", 0, 0)
  f:SetWidth(700)
  f:SetHeight(500)
  f:EnableMouse(true)
  f:SetMovable(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", function() f:StartMoving() end)
  f:SetScript("OnDragStop", function() f:StopMovingOrSizing() end)
  f:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = {left = 4, right = 4, top = 4, bottom = 4}
  })
  f:SetBackdropColor(THEME.bg[1], THEME.bg[2], THEME.bg[3], THEME.bg[4])
  f:SetBackdropBorderColor(THEME.border[1], THEME.border[2], THEME.border[3], 1)
  
  local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("TOP", f, "TOP", 0, -15)
  title:SetText("LeafVE Achievement System")
  title:SetTextColor(THEME.leaf[1], THEME.leaf[2], THEME.leaf[3])
  
  local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -6, -6)
  
  self.pointsLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  self.pointsLabel:SetPoint("TOP", f, "TOP", 0, -45)
  
  local achTab = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  achTab:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -75)
  achTab:SetWidth(100)
  achTab:SetHeight(25)
  achTab:SetText("Achievements")
  achTab:SetScript("OnClick", function()
    LeafVE_AchTest.UI.currentView = "achievements"
    LeafVE_AchTest.UI:Refresh()
  end)
  self.achTab = achTab
  
  local titlesTab = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  titlesTab:SetPoint("LEFT", achTab, "RIGHT", 5, 0)
  titlesTab:SetWidth(80)
  titlesTab:SetHeight(25)
  titlesTab:SetText("Titles")
  titlesTab:SetScript("OnClick", function()
    LeafVE_AchTest.UI.currentView = "titles"
    LeafVE_AchTest.UI:Refresh()
  end)
  self.titlesTab = titlesTab
  
  local catLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  catLabel:SetPoint("LEFT", titlesTab, "RIGHT", 15, 0)
  catLabel:SetText("Category:")
  self.catLabel = catLabel
  
  local catButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  catButton:SetPoint("LEFT", catLabel, "RIGHT", 5, 0)
  catButton:SetWidth(100)
  catButton:SetHeight(25)
  catButton:SetText(self.selectedCategory)
  self.catButton = catButton
  
  catButton:SetScript("OnClick", function()
    local categories = {"All", "Leveling", "Professions", "Gold", "Dungeons", "Raids", "Exploration", "PvP", "Elite", "Casual"}
    local currentIndex = 1
    for i, cat in ipairs(categories) do
      if cat == LeafVE_AchTest.UI.selectedCategory then
        currentIndex = i
        break
      end
    end
    currentIndex = currentIndex + 1
    if currentIndex > table.getn(categories) then currentIndex = 1 end
    LeafVE_AchTest.UI.selectedCategory = categories[currentIndex]
    catButton:SetText(LeafVE_AchTest.UI.selectedCategory)
    LeafVE_AchTest.UI:Refresh()
  end)
  
  local awardBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  awardBtn:SetPoint("LEFT", catButton, "RIGHT", 10, 0)
  awardBtn:SetWidth(60)
  awardBtn:SetHeight(25)
  awardBtn:SetText("Award")
  awardBtn:SetScript("OnClick", function()
    local me = ShortName(UnitName("player") or "")
    local playerAchievements = LeafVE_AchTest:GetPlayerAchievements(me)
    local availableAchievements = {}
    
    for achID, achData in pairs(ACHIEVEMENTS) do
      if not playerAchievements[achID] then
        table.insert(availableAchievements, achID)
      end
    end
    
    if table.getn(availableAchievements) > 0 then
      local randomIndex = math.random(1, table.getn(availableAchievements))
      local randomAchID = availableAchievements[randomIndex]
      LeafVE_AchTest:AwardAchievement(randomAchID, false)
    else
      Print("You already have all achievements!")
    end
  end)
  self.awardBtn = awardBtn
  
  local resetBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  resetBtn:SetPoint("LEFT", awardBtn, "RIGHT", 5, 0)
  resetBtn:SetWidth(60)
  resetBtn:SetHeight(25)
  resetBtn:SetText("Reset")
  resetBtn:SetScript("OnClick", function()
    LeafVE_AchTest_DB.achievements = {}
    LeafVE_AchTest_DB.selectedTitles = {}
    Print("Reset complete!")
    LeafVE_AchTest.UI:Refresh()
  end)
  
  -- Achievement Search Bar
  local searchLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  searchLabel:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -110)
  searchLabel:SetText("Search:")
  self.searchLabel = searchLabel
  
  local searchBox = CreateFrame("EditBox", nil, f)
  searchBox:SetPoint("LEFT", searchLabel, "RIGHT", 5, 0)
  searchBox:SetWidth(200)
  searchBox:SetHeight(25)
  searchBox:SetAutoFocus(false)
  searchBox:SetFontObject("GameFontHighlight")
  searchBox:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = {left = 4, right = 4, top = 4, bottom = 4}
  })
  searchBox:SetBackdropColor(0, 0, 0, 0.8)
  searchBox:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
  searchBox:SetTextInsets(8, 8, 0, 0)
  searchBox:SetScript("OnEscapePressed", function() this:ClearFocus() end)
  searchBox:SetScript("OnEnterPressed", function() this:ClearFocus() end)
  searchBox:SetScript("OnTextChanged", function()
    LeafVE_AchTest.UI.searchText = this:GetText()
    LeafVE_AchTest.UI:Refresh()
  end)
  self.searchBox = searchBox
  
  local clearBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  clearBtn:SetPoint("LEFT", searchBox, "RIGHT", 5, 0)
  clearBtn:SetWidth(50)
  clearBtn:SetHeight(25)
  clearBtn:SetText("Clear")
  clearBtn:SetScript("OnClick", function()
    searchBox:SetText("")
    LeafVE_AchTest.UI.searchText = ""
    LeafVE_AchTest.UI:Refresh()
  end)
  self.clearBtn = clearBtn
  
  -- Title Search Bar (hidden by default)
  local titleSearchLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  titleSearchLabel:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -110)
  titleSearchLabel:SetText("Search:")
  titleSearchLabel:Hide()
  self.titleSearchLabel = titleSearchLabel
  
  local titleSearchBox = CreateFrame("EditBox", nil, f)
  titleSearchBox:SetPoint("LEFT", titleSearchLabel, "RIGHT", 5, 0)
  titleSearchBox:SetWidth(200)
  titleSearchBox:SetHeight(25)
  titleSearchBox:SetAutoFocus(false)
  titleSearchBox:SetFontObject("GameFontHighlight")
  titleSearchBox:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = {left = 4, right = 4, top = 4, bottom = 4}
  })
  titleSearchBox:SetBackdropColor(0, 0, 0, 0.8)
  titleSearchBox:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
  titleSearchBox:SetTextInsets(8, 8, 0, 0)
  titleSearchBox:SetScript("OnEscapePressed", function() this:ClearFocus() end)
  titleSearchBox:SetScript("OnEnterPressed", function() this:ClearFocus() end)
  titleSearchBox:SetScript("OnTextChanged", function()
    LeafVE_AchTest.UI.titleSearchText = this:GetText()
    LeafVE_AchTest.UI:Refresh()
  end)
  titleSearchBox:Hide()
  self.titleSearchBox = titleSearchBox
  
  local titleClearBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  titleClearBtn:SetPoint("LEFT", titleSearchBox, "RIGHT", 5, 0)
  titleClearBtn:SetWidth(50)
  titleClearBtn:SetHeight(25)
  titleClearBtn:SetText("Clear")
  titleClearBtn:SetScript("OnClick", function()
    titleSearchBox:SetText("")
    LeafVE_AchTest.UI.titleSearchText = ""
    LeafVE_AchTest.UI:Refresh()
  end)
  titleClearBtn:Hide()
  self.titleClearBtn = titleClearBtn
  
  local scrollFrame = CreateFrame("ScrollFrame", nil, f)
  scrollFrame:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -145)
  scrollFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -40, 15)
  scrollFrame:EnableMouseWheel(true)
  self.scrollFrame = scrollFrame
  
  local scrollChild = CreateFrame("Frame", nil, scrollFrame)
  scrollChild:SetWidth(620)
  scrollChild:SetHeight(1)
  scrollFrame:SetScrollChild(scrollChild)
  self.scrollChild = scrollChild
  
  local scrollbar = CreateFrame("Slider", nil, f)
  scrollbar:SetPoint("TOPRIGHT", f, "TOPRIGHT", -15, -145)
  scrollbar:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -15, 15)
  scrollbar:SetWidth(16)
  scrollbar:SetOrientation("VERTICAL")
  scrollbar:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
  scrollbar:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 8,
    insets = {left = 3, right = 3, top = 3, bottom = 3}
  })
  scrollbar:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
  scrollbar:SetMinMaxValues(0, 1)
  scrollbar:SetValue(0)
  scrollbar:SetValueStep(20)
  self.scrollbar = scrollbar
  
  scrollbar:SetScript("OnValueChanged", function()
    if LeafVE_AchTest.UI and LeafVE_AchTest.UI.scrollFrame then
      LeafVE_AchTest.UI.scrollFrame:SetVerticalScroll(this:GetValue())
    end
  end)
  
  scrollFrame:SetScript("OnMouseWheel", function()
    local current = this:GetVerticalScroll()
    local maxScroll = this:GetVerticalScrollRange()
    local newScroll = current - (arg1 * 20)
    if newScroll < 0 then newScroll = 0 end
    if newScroll > maxScroll then newScroll = maxScroll end
    this:SetVerticalScroll(newScroll)
    if LeafVE_AchTest.UI and LeafVE_AchTest.UI.scrollbar then
      LeafVE_AchTest.UI.scrollbar:SetValue(newScroll)
    end
  end)
  
  self:Refresh()
end

function LeafVE_AchTest.UI:Refresh()
  if not self.frame or not self.scrollChild then return end
  
  local me = ShortName(UnitName("player") or "")
  local totalPoints = LeafVE_AchTest:GetTotalAchievementPoints(me)
  local currentTitle = LeafVE_AchTest:GetCurrentTitle(me)
  
  if self.pointsLabel then
    if currentTitle then
      local titleText = currentTitle.prefix and (currentTitle.name.." "..me) or (me.." "..currentTitle.name)
      self.pointsLabel:SetText("|cFFFF7F00"..titleText.."|r | Points: |cFFFF7F00"..totalPoints.."|r")
    else
      self.pointsLabel:SetText(me.." | Points: |cFFFF7F00"..totalPoints.."|r")
    end
  end
  
  if self.achievementFrames then
    for i = 1, table.getn(self.achievementFrames) do
      if self.achievementFrames[i] then self.achievementFrames[i]:Hide() end
    end
  end
  
  if self.titleFrames then
    for i = 1, table.getn(self.titleFrames) do
      if self.titleFrames[i] then self.titleFrames[i]:Hide() end
    end
  end
  
  if self.scrollFrame then self.scrollFrame:SetVerticalScroll(0) end
  if self.scrollbar then self.scrollbar:SetValue(0) end
  
  if self.currentView == "achievements" then
    if self.achTab then self.achTab:Disable() end
    if self.titlesTab then self.titlesTab:Enable() end
    if self.catLabel then self.catLabel:Show() end
    if self.catButton then self.catButton:Show() end
    if self.awardBtn then self.awardBtn:Show() end
    if self.searchLabel then self.searchLabel:Show() end
    if self.searchBox then self.searchBox:Show() end
    if self.clearBtn then self.clearBtn:Show() end
    if self.titleSearchLabel then self.titleSearchLabel:Hide() end
    if self.titleSearchBox then self.titleSearchBox:Hide() end
    if self.titleClearBtn then self.titleClearBtn:Hide() end
    self:RefreshAchievements()
  else
    if self.achTab then self.achTab:Enable() end
    if self.titlesTab then self.titlesTab:Disable() end
    if self.catLabel then self.catLabel:Hide() end
    if self.catButton then self.catButton:Hide() end
    if self.awardBtn then self.awardBtn:Hide() end
    if self.searchLabel then self.searchLabel:Hide() end
    if self.searchBox then self.searchBox:Hide() end
    if self.clearBtn then self.clearBtn:Hide() end
    if self.titleSearchLabel then self.titleSearchLabel:Show() end
    if self.titleSearchBox then self.titleSearchBox:Show() end
    if self.titleClearBtn then self.titleClearBtn:Show() end
    self:RefreshTitles()
  end
  
  if self.scrollFrame and self.scrollbar then
    local maxScroll = self.scrollFrame:GetVerticalScrollRange()
    self.scrollbar:SetMinMaxValues(0, maxScroll > 0 and maxScroll or 1)
  end
end

function LeafVE_AchTest.UI:RefreshAchievements()
  if not self.scrollChild then return end
  local me = ShortName(UnitName("player") or "")
  local playerAchievements = LeafVE_AchTest:GetPlayerAchievements(me)
  if not self.achievementFrames then self.achievementFrames = {} end
  
  local achievementList = {}
  for achID, achData in pairs(ACHIEVEMENTS) do
    local matchesCategory = self.selectedCategory == "All" or achData.category == self.selectedCategory
    local matchesSearch = true
    
    -- Search filter
    if self.searchText and self.searchText ~= "" then
      local searchLower = string.lower(self.searchText)
      local nameLower = string.lower(achData.name)
      local descLower = string.lower(achData.desc)
      matchesSearch = string.find(nameLower, searchLower) or string.find(descLower, searchLower)
    end
    
    if matchesCategory and matchesSearch then
      local completed = playerAchievements[achID] ~= nil
      local timestamp = completed and playerAchievements[achID].timestamp or 0
      table.insert(achievementList, {id=achID,data=achData,completed=completed,timestamp=timestamp})
    end
  end
  
  table.sort(achievementList, function(a, b)
    if a.completed and not b.completed then return true end
    if not a.completed and b.completed then return false end
    if a.completed and b.completed then return a.timestamp > b.timestamp end
    return a.data.points > b.data.points
  end)
  
  local yOffset = 0
  local frameIndex = 1
  
  for i, ach in ipairs(achievementList) do
    local frame = self.achievementFrames[frameIndex]
    if not frame then
      frame = CreateFrame("Frame", nil, self.scrollChild)
      frame:SetWidth(610)
      frame:SetHeight(60)
      frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 8,
        insets = {left = 2, right = 2, top = 2, bottom = 2}
      })
      frame:SetBackdropColor(0.1, 0.1, 0.1, 0.6)
      local icon = frame:CreateTexture(nil, "ARTWORK")
      icon:SetWidth(40)
      icon:SetHeight(40)
      icon:SetPoint("LEFT", frame, "LEFT", 8, 0)
      icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
      frame.icon = icon
      local checkmark = frame:CreateTexture(nil, "OVERLAY")
      checkmark:SetWidth(20)
      checkmark:SetHeight(20)
      checkmark:SetPoint("CENTER", icon, "TOPRIGHT", -2, -2)
      checkmark:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready")
      frame.checkmark = checkmark
      local name = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      name:SetPoint("TOPLEFT", icon, "TOPRIGHT", 8, -5)
      name:SetWidth(500)
      name:SetJustifyH("LEFT")
      frame.name = name
      local desc = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
      desc:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -3)
      desc:SetWidth(500)
      desc:SetJustifyH("LEFT")
      frame.desc = desc
      local points = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
      points:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT", 8, 0)
      frame.points = points
      table.insert(self.achievementFrames, frame)
    end
    frame:SetPoint("TOPLEFT", self.scrollChild, "TOPLEFT", 5, -yOffset)
    frame.icon:SetTexture(ach.data.icon)
    if ach.completed then
      frame.icon:SetDesaturated(false)
      frame.icon:SetAlpha(1)
      frame.checkmark:Show()
      frame:SetBackdropBorderColor(THEME.leaf[1], THEME.leaf[2], THEME.leaf[3], 0.6)
      frame.name:SetText(ach.data.name)
      frame.name:SetTextColor(THEME.leaf[1], THEME.leaf[2], THEME.leaf[3])
      frame.desc:SetText(ach.data.desc)
      frame.desc:SetTextColor(0.9, 0.9, 0.9)
      frame.points:SetText("|cFFFF7F00"..ach.data.points.." pts|r - Completed")
    else
      frame.icon:SetDesaturated(true)
      frame.icon:SetAlpha(0.5)
      frame.checkmark:Hide()
      frame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
      frame.name:SetText(ach.data.name)
      frame.name:SetTextColor(0.6, 0.6, 0.6)
      frame.desc:SetText(ach.data.desc)
      frame.desc:SetTextColor(0.5, 0.5, 0.5)
      frame.points:SetText("|cFF888888"..ach.data.points.." pts|r")
    end
    frame:Show()
    yOffset = yOffset + 65
    frameIndex = frameIndex + 1
  end
  if self.scrollChild then self.scrollChild:SetHeight(yOffset + 10) end
  if self.scrollFrame and self.scrollbar then
    local maxScroll = self.scrollFrame:GetVerticalScrollRange()
    self.scrollbar:SetMinMaxValues(0, maxScroll > 0 and maxScroll or 1)
  end
end

function LeafVE_AchTest.UI:RefreshTitles()
  if not self.scrollChild then return end
  local me = ShortName(UnitName("player") or "")
  if not self.titleFrames then self.titleFrames = {} end
  
  -- Build filtered title list
  local filteredTitles = {}
  for i, titleData in ipairs(TITLES) do
    local matchesSearch = true
    
    -- Search filter
    if self.titleSearchText and self.titleSearchText ~= "" then
      local searchLower = string.lower(self.titleSearchText)
      local nameLower = string.lower(titleData.name)
      local achData = ACHIEVEMENTS[titleData.achievement]
      local achNameLower = achData and string.lower(achData.name) or ""
      matchesSearch = string.find(nameLower, searchLower) or string.find(achNameLower, searchLower)
    end
    
    if matchesSearch then
      table.insert(filteredTitles, titleData)
    end
  end
  
  local yOffset = 0
  for i, titleData in ipairs(filteredTitles) do
    local frame = self.titleFrames[i]
    local earned = LeafVE_AchTest:HasAchievement(me, titleData.achievement)
    if not frame then
      frame = CreateFrame("Frame", nil, self.scrollChild)
      frame:SetWidth(610)
      frame:SetHeight(55)
      frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 8,
        insets = {left = 2, right = 2, top = 2, bottom = 2}
      })
      frame:SetBackdropColor(0.1, 0.1, 0.1, 0.6)
      local icon = frame:CreateTexture(nil, "ARTWORK")
      icon:SetWidth(32)
      icon:SetHeight(32)
      icon:SetPoint("LEFT", frame, "LEFT", 10, 0)
      icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
      frame.icon = icon
      local name = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      name:SetPoint("LEFT", icon, "RIGHT", 10, 8)
      name:SetWidth(330)
      name:SetJustifyH("LEFT")
      frame.name = name
      local requirement = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
      requirement:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -3)
      requirement:SetWidth(330)
      requirement:SetJustifyH("LEFT")
      frame.requirement = requirement
      local prefixBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
      prefixBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -70, -12)
      prefixBtn:SetWidth(60)
      prefixBtn:SetHeight(20)
      prefixBtn:SetText("Prefix")
      frame.prefixBtn = prefixBtn
      local suffixBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
      suffixBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -12)
      suffixBtn:SetWidth(60)
      suffixBtn:SetHeight(20)
      suffixBtn:SetText("Suffix")
      frame.suffixBtn = suffixBtn
      table.insert(self.titleFrames, frame)
    end
    frame:SetPoint("TOPLEFT", self.scrollChild, "TOPLEFT", 5, -yOffset)
    local achData = ACHIEVEMENTS[titleData.achievement]
    frame.icon:SetTexture(titleData.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
    if earned then
      frame:SetBackdropBorderColor(THEME.leaf[1], THEME.leaf[2], THEME.leaf[3], 0.6)
      frame.icon:SetDesaturated(false)
      frame.icon:SetAlpha(1)
      frame.name:SetText(titleData.name)
      frame.name:SetTextColor(THEME.leaf[1], THEME.leaf[2], THEME.leaf[3])
      frame.requirement:SetText("From: "..achData.name)
      frame.requirement:SetTextColor(0.9, 0.9, 0.9)
      frame.prefixBtn:Enable()
      frame.suffixBtn:Enable()
      frame.prefixBtn.titleID = titleData.id
      frame.prefixBtn:SetScript("OnClick", function()
        LeafVE_AchTest:SetTitle(me, this.titleID, true)
        LeafVE_AchTest.UI:Refresh()
      end)
      frame.suffixBtn.titleID = titleData.id
      frame.suffixBtn:SetScript("OnClick", function()
        LeafVE_AchTest:SetTitle(me, this.titleID, false)
        LeafVE_AchTest.UI:Refresh()
      end)
    else
      frame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
      frame.icon:SetDesaturated(true)
      frame.icon:SetAlpha(0.3)
      frame.name:SetText(titleData.name)
      frame.name:SetTextColor(0.5, 0.5, 0.5)
      frame.requirement:SetText("Requires: "..achData.name)
      frame.requirement:SetTextColor(0.6, 0.4, 0.4)
      frame.prefixBtn:Disable()
      frame.suffixBtn:Disable()
    end
    frame:Show()
    yOffset = yOffset + 60
  end
  
  -- Hide unused frames
  for i = table.getn(filteredTitles) + 1, table.getn(self.titleFrames) do
    if self.titleFrames[i] then
      self.titleFrames[i]:Hide()
    end
  end
  
  if self.scrollChild then self.scrollChild:SetHeight(yOffset + 10) end
  if self.scrollFrame and self.scrollbar then
    local maxScroll = self.scrollFrame:GetVerticalScrollRange()
    self.scrollbar:SetMinMaxValues(0, maxScroll > 0 and maxScroll or 1)
  end
end

local ef = CreateFrame("Frame")
ef:RegisterEvent("ADDON_LOADED")
ef:RegisterEvent("PLAYER_LEVEL_UP")
ef:RegisterEvent("PLAYER_MONEY")
ef:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")  -- ADD THIS LINE

ef:SetScript("OnEvent", function()
  if event == "ADDON_LOADED" and arg1 == LeafVE_AchTest.name then
    EnsureDB()
    LeafVE_AchTest:CheckLevelAchievements()
    LeafVE_AchTest:CheckGoldAchievements()
    Print("Achievement System Loaded! Type /achtest")
    Debug("Debug mode is: "..tostring(LeafVE_AchTest.DEBUG))
  end
  if event == "PLAYER_LEVEL_UP" then LeafVE_AchTest:CheckLevelAchievements() end
  if event == "PLAYER_MONEY" then LeafVE_AchTest:CheckGoldAchievements() end
  
  -- ADD THIS BLOCK
  if event == "CHAT_MSG_COMBAT_HOSTILE_DEATH" then
    local bossName = arg1
    -- Remove " dies." or " is slain!" from the message
    bossName = string.gsub(bossName, " dies%.", "")
    bossName = string.gsub(bossName, " is slain!", "")
    LeafVE_AchTest:CheckBossKill(bossName)
  end
end)

SLASH_ACHTEST1 = "/achtest"
SlashCmdList["ACHTEST"] = function(msg)
  LeafVE_AchTest.UI:Build()
end

SLASH_ACHTESTDEBUG1 = "/achtestdebug"
SlashCmdList["ACHTESTDEBUG"] = function(msg)
  LeafVE_AchTest.DEBUG = not LeafVE_AchTest.DEBUG
  Print("Debug mode: "..tostring(LeafVE_AchTest.DEBUG))
end

-- Chat Title Integration with Orange Color (Vanilla WoW Compatible)
local chatHooked = false

local function HookChatWithTitles()
  if chatHooked then 
    Debug("Chat already hooked")
    return 
  end
  
  Debug("Installing chat title hooks...")
  
  SendChatMessage = function(msg, chatType, language, channel)
    Debug("SendChatMessage called - Type: "..tostring(chatType))
    local me = ShortName(UnitName("player"))
    
    -- ONLY add titles to GUILD chat
    if me and msg and msg ~= "" and chatType == "GUILD" then
      if not string.find(msg, "^/") and not string.find(msg, "^%[LeafVE") then
        local title = LeafVE_AchTest:GetCurrentTitle(me)
        if title then
          Debug("Adding title: "..title.name.." (prefix: "..tostring(title.prefix)..")")
          if title.prefix then
            msg = "|cFFFF7F00["..title.name.."]|r "..msg
          else
            msg = msg.." |cFFFF7F00["..title.name.."]|r"
          end
          Debug("Modified message: "..msg)
        else
          Debug("No title found for player")
        end
      end
    end
    return originalSendChatMessage(msg, chatType, language, channel)
  end
  
  chatHooked = true
  Print("Chat titles enabled!")
  Debug("Chat hook complete")
end

-- Minimap Button
local minimapButton = CreateFrame("Button", "LeafVE_AchTestMinimapButton", Minimap)
minimapButton:SetWidth(32)
minimapButton:SetHeight(32)
minimapButton:SetFrameStrata("MEDIUM")
minimapButton:SetFrameLevel(8)
minimapButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

-- Icon
local icon = minimapButton:CreateTexture(nil, "BACKGROUND")
icon:SetWidth(20)
icon:SetHeight(20)
icon:SetTexture("Interface\\Icons\\INV_Misc_Trophy_Gold")
icon:SetPoint("CENTER", 0, 1)
minimapButton.icon = icon

-- Border
local overlay = minimapButton:CreateTexture(nil, "OVERLAY")
overlay:SetWidth(52)
overlay:SetHeight(52)
overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
overlay:SetPoint("TOPLEFT", 0, 0)

-- Position on minimap
local function UpdateMinimapPosition()
  local angle = 45 -- Default angle
  local x = math.cos(angle) * 80
  local y = math.sin(angle) * 80
  minimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

UpdateMinimapPosition()

-- Dragging functionality
minimapButton:SetMovable(true)
minimapButton:EnableMouse(true)
minimapButton:RegisterForDrag("LeftButton")
minimapButton:SetScript("OnDragStart", function()
  this:StartMoving()
end)

minimapButton:SetScript("OnDragStop", function()
  this:StopMovingOrSizing()
  local centerX, centerY = Minimap:GetCenter()
  local buttonX, buttonY = this:GetCenter()
  local angle = math.atan2(buttonY - centerY, buttonX - centerX)
  local x = math.cos(angle) * 80
  local y = math.sin(angle) * 80
  this:ClearAllPoints()
  this:SetPoint("CENTER", Minimap, "CENTER", x, y)
end)

-- Click to open
minimapButton:SetScript("OnClick", function()
  LeafVE_AchTest.UI:Build()
end)

-- Tooltip
minimapButton:SetScript("OnEnter", function()
  GameTooltip:SetOwner(this, "ANCHOR_LEFT")
  GameTooltip:SetText("|cFF2DD35CLeafVE Achievements|r", 1, 1, 1)
  GameTooltip:AddLine("Click to open", 0.8, 0.8, 0.8)
  GameTooltip:AddLine("Drag to move", 0.6, 0.6, 0.6)
  GameTooltip:Show()
end)

minimapButton:SetScript("OnLeave", function()
  GameTooltip:Hide()
end)

Print("Minimap button loaded!")

local hookTimer = 0
local hookFrame = CreateFrame("Frame")
hookFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
hookFrame:SetScript("OnEvent", function()
  if event == "PLAYER_ENTERING_WORLD" then
    Debug("Player entering world - starting hook timer")
    hookTimer = 0
    hookFrame:SetScript("OnUpdate", function()
      hookTimer = hookTimer + arg1
      if hookTimer >= 3 then
        HookChatWithTitles()
        hookFrame:SetScript("OnUpdate", nil)
      end
    end)
  end
end)

Print("LeafVE Achievement System loaded successfully!")
