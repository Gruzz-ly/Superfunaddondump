local addonName, addon = ...
local frame = CreateFrame("Frame")

-- =========================================================================
-- 0. VERSION CHECK & EVENT REGISTRATION
-- =========================================================================
-- Check if we are on Retail (Version 10.0+) or Classic
local gameVersion = select(4, GetBuildInfo())
local IS_RETAIL = (gameVersion >= 100000)

-- Register the events (This fixes the "Targeting isn't working" bug)
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_FLAGS_CHANGED")
frame:RegisterEvent("PLAYER_LEVEL_UP")
frame:RegisterEvent("LOOT_READY")
frame:RegisterEvent("READY_CHECK")
frame:RegisterEvent("RESURRECT_REQUEST")
frame:RegisterEvent("DUEL_REQUESTED")
frame:RegisterEvent("CONFIRM_SUMMON")
frame:RegisterEvent("TAXIMAP_OPENED")
frame:RegisterEvent("BANKFRAME_OPENED")
frame:RegisterEvent("AUCTION_HOUSE_SHOW")
frame:RegisterEvent("MAIL_SHOW")
frame:RegisterEvent("TRADE_SKILL_SHOW")
frame:RegisterEvent("TRANSMOGRIFY_OPEN")
frame:RegisterEvent("BARBER_SHOP_OPEN")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:RegisterEvent("ZONE_CHANGED")

-- Only register LFG on Retail to avoid errors on some private/classic servers
if IS_RETAIL then
    frame:RegisterEvent("LFG_PROPOSAL_SHOW")
end

-- =========================================================================
-- 1. CONFIGURATION
-- =========================================================================
local WHISPER_COLOR = "|cffff80ff" 

local ENTITIES = {
    "|cffFF7D0A[The Nightmare]|r",       -- Druid Orange
    "|cff40C7EB[Entropy]|r",             -- Mage Blue
    "|cff8788EE[C'Thun]|r",              -- Warlock Purple
    "|cff8788EE[Yogg-Saron]|r",          -- Warlock Purple
    "|cff8788EE[N'Zoth]|r",              -- Warlock Purple
    "|cff8788EE[Y'Shaarj]|r",            -- Warlock Purple
    "|cffFFFFFF[Xal'atath]|r",           -- Priest White
    "|cff00FF96[The Sha of Doubt]|r",    -- Monk Green
    "|cff00FF96[The Sha of Fear]|r",     -- Monk Green
    "|cff00FF96[The Sha of Violence]|r", -- Monk Green
    "|cffFFF569[Faceless One]|r",        -- Rogue Yellow
    "|cff0070DE[Echo of Ner'zhul]|r",    -- Shaman Blue
    "|cffC41F3B[The Lich King]|r",       -- Death Knight Red
    "|cff8788EE[Il'gynoth]|r",           -- Warlock Purple
    "|cffA330C9[Sargeras]|r",            -- Demon Hunter Magenta
    "|cffA330C9[Kil'jaeden]|r",          -- Demon Hunter Magenta
    "|cffC41F3B[G'huun]|r"               -- Death Knight Red
}

-- =========================================================================
-- 2. THE MADNESS DATABASE
-- =========================================================================
local reactions = {
    -- =====================================================================
    -- DEATH KNIGHT
    -- =====================================================================
    SELF_DEATHKNIGHT_BLOOD_SOLO = { 
        "Use Gorefiend's Grasp on those critters and gather them around for a mandatory meeting.", 
        "Pop Vampiric Blood at 100% HP just to see if you can become even healthier.", 
        "Cast Death's Caress on that rat because it looked desperately lonely.", 
        "Summon your Dancing Rune Weapon so you don't have to dance alone.", 
        "Activate Path of Frost and jump in the fountain to walk on water like a god.",
        "Cast Blood Boil and make some delicious soup out of thin air.", 
        "Asphyxiate the vendor because his prices are absolutely criminal.", 
        "Pop Lichborne and take a quick nap in the undeath because you look tired.", 
        "Marrowrend the empty air to maintain your stacks of disappointment.", 
        "Cast Raise Dead because you look like you need a friend right now.",
        "Use Sacrificial Pact and betray your ghoul before he plots against you.", 
        "Wraith Walk to the mailbox because walking normally is for peasants.", 
        "Dark Command that target dummy and assert your dominance over the inanimate.", 
        "Drop Anti-Magic Zone and use it as an umbrella in case it rains.", 
        "Heart Strike something and go break a heart.",
        "Empower Rune Weapon because there is no such thing as overkill for a quest mob.", 
        "Death Strike the air and heal the damage you didn't take.", 
        "Cast Mind Freeze and give yourself a brain freeze.", 
        "Control Undead on that skeleton and start a beautiful family.", 
        "Cast Vampiric Strike and drink the life from the air."
    },
    SELF_DEATHKNIGHT_BLOOD_GROUP = { 
        "Gorefiend's Grasp the mobs AWAY from the AoE to save them from the fire.", 
        "Dark Command the boss immediately because everyone knows you are the main character.", 
        "Death Grip that loose add right next to the healer because they looked lonely.", 
        "Pop Anti-Magic Shell for that physical damage because it's the thought that counts.",
        "Pop Vampiric Blood at full health because the healer is boring you with their slowness.", 
        "Summon Dancing Rune Weapon and ignore threat because this is a DPS race now.", 
        "Cast Path of Frost right before the water jump and watch the raid shatter their ankles.", 
        "Asphyxiate the boss because I'm sure he's not immune this time.", 
        "Cast Reaper's Mark and mark the tank for death.",
        "Cast Raise Ally on the Hunter's pet because it contributes more than the rogue anyway.", 
        "Place Death's Due on the floor and start charging the melee DPS rent for standing there.", 
        "Pop Tombstone to accept your fate and become a literal grave.", 
        "Activate Abomination Limb because it's time for a group cuddle puddle.", 
        "Trigger Purgatory on purpose to give the healer a little pop quiz.",
        "Put Mark of Blood on the wrong target just to confuse the raid leader.", 
        "Hit Rune Tap and panic even though there is no danger.", 
        "Wraith Walk directly into the boss's model and become one with the enemy.", 
        "Control Undead on the mob the group is killing and make it your pet right before it dies.", 
        "Death Grip the caster closer to the Mage because they love having mobs in their face.", 
        "Pop Icebound Fortitude because you felt a slight breeze and got scared."
    },

    SELF_DEATHKNIGHT_FROST_SOLO = { 
        "Unleash Breath of Sindragosa on that single mob because it deserves the full might of a dragon.", 
        "Pop Pillar of Frost before opening that loot chest so you have the strength to lift the lid.", 
        "Cast Chains of Ice on that rabbit because it's moving way too fast for your liking.", 
        "Activate Remorseless Winter inside the inn because the patrons looked a bit too warm.", 
        "Cast Howling Blast and scream at the top of your lungs to wake up the neighbors.",
        "Empower Rune Weapon now because that grey-level mob might be hiding a secret phase.", 
        "Unleash Frostwyrm's Fury on the garden because those flowers need to be frozen solid immediately.", 
        "Use Obliterate on that critter and show it the meaning of excessive force.", 
        "Blow the Horn of Winter and announce your arrival to the entire zone.", 
        "Cast Reaper's Mark and slice the soul out of the air.",
        "Pop Icebound Fortitude because it's like a refreshing cold shower without the water.", 
        "Cast Mind Freeze on the wind and interrupt the silence.", 
        "Use Death Strike at full health to waste that Runic Power you have too much of.", 
        "Cast Sacrificial Pact and try to eat the ghoul you forgot to summon.", 
        "Control Undead on that skeleton because he looks like he needs a master.",
        "Cast Raise Dead because you're lonely and need a temporary friend for exactly one minute.", 
        "Wraith Walk in place because it's basically a spooky Moonwalk.", 
        "Cast Blinding Sleet and declare it a mandatory snow day.", 
        "Cast Arctic Assault and throw a snowball at the vendor.", 
        "Cast Chill Streak on a solo target and play a sad game of ping pong with yourself."
    },
    SELF_DEATHKNIGHT_FROST_GROUP = { 
        "Channel Breath of Sindragosa away from the mobs to cool off the healer instead.", 
        "Death Grip that caster closer to you because you wanted a hug, not the tank.", 
        "Pop Icebound Fortitude because the button looked shiny, even if you didn't need it.", 
        "Obliterate that polymorphed sheep because it was looking at you funny.",
        "Summon Frostwyrm's Fury and make sure it flies far enough to pull the next three rooms.", 
        "Blow the Horn of Winter because if it breaks crowd control, that's their problem.", 
        "Start Remorseless Winter and blind the other melee players with visual clutter.", 
        "Cast Chains of Ice on the boss because I'm sure he can be slowed, trust me.", 
        "Drop Anti-Magic Zone only over the hunters because the tank can fend for themselves.",
        "Cast Raise Ally on the person who is still alive just to confuse them.", 
        "Mind Freeze the spell that finished casting three seconds ago because it's the thought that counts.", 
        "Strangulate the tank's target and steal the threat while they can't speak.", 
        "Cast Dark Command and look at me because I am the tank now.", 
        "Wraith Walk right off the platform to see if you can float.",
        "Cast Reaper's Mark and explode the wrong target.", 
        "Cast Chill Streak on the single boss and watch it bounce to absolutely nothing.", 
        "Empower Rune Weapon immediately because who cares about timing windows?", 
        "Spam Death Strike and ignore the healer's mana because you are a strong independent Death Knight.", 
        "Cast Path of Frost during the jump to give everyone water walking so they die on impact.", 
        "Use Blinding Sleet to disorient the nicely stacked mobs so they run everywhere."
    },

    SELF_DEATHKNIGHT_UNHOLY_SOLO = { 
        "Cast Apocalypse and summon the boys because it's time for a party.", 
        "Summon Army of the Dead for that single quest mob because overkill is underrated.", 
        "Control that Undead and release it in the middle of town because chaos is funny.", 
        "Cast Defile on the clean floor because it was looking too shiny anyway.", 
        "Cast Epidemic and spread the sickness to absolutely no one around you.",
        "Festering Strike the empty air to infect the atmosphere.", 
        "Scourge Strike without any wounds and pop absolutely nothing but your cooldowns.", 
        "Activate Unholy Blight and just stink up the entire place.", 
        "Use Dark Transformation because your pet deserves to feel huge and powerful.", 
        "Death Coil that critter because it looked at you with judgement.",
        "Cast Outbreak and infect the local wildlife because they look too healthy.", 
        "Use Sacrificial Pact and blow up your minion because you can always make another one.", 
        "Summon your Gargoyle and do some bird watching while it attacks nothing.", 
        "Wraith Walk immediately to get stuck on a tiny pebble and look foolish.", 
        "Death Grip that mob and scream 'Get over here!' in real life.",
        "Cast Chains of Ice and tell it to stay like a bad dog.", 
        "Mind Freeze the air and silence the voices.", 
        "Pop Anti-Magic Shell because you just wanted to be inside a green bubble.", 
        "Activate Lichborne and heal yourself out of pure anxiety.", 
        "Cast Clawing Shadows and use the enemy as a scratching post."
    },
    SELF_DEATHKNIGHT_UNHOLY_GROUP = { 
        "Summon Army of the Dead and let the ghouls taunt everything to annoy the tank.", 
        "Activate Abomination Limb to grab that patrol from across the room because we need more friends.", 
        "Death Grip the wrong target and disrupt the strategy completely.", 
        "Cast Raise Ally on the guy who went AFK and make him work for it.",
        "Cast Apocalypse right now because who cares about Festering Wounds setup?", 
        "Drop Defile and cover up the boss's ground mechanics so no one can see them.", 
        "Spam Epidemic and break every crowd control in a forty-yard radius.", 
        "Cast Summon Horsemen and ride into battle with your spectral bros.", 
        "Dark Transformation your pet so it becomes huge and blocks the tank's view.",
        "Cast Outbreak to spread the disease and pull the entire room by accident.", 
        "Summon Gargoyle and pretend this trash pack is a DPS check.", 
        "Place Anti-Magic Zone in the far corner where nobody is standing.", 
        "Asphyxiate the boss and choke him out because surely he isn't immune.", 
        "Control that Undead add and keep it alive forever so the dungeon never ends.",
        "Death Coil the tank to pretend you are helpful even though it doesn't heal him anymore.", 
        "Festering Strike the boss but forget to pop the wounds and just leave them there.", 
        "Spam Scourge Strike with zero wounds to be as inefficient as possible.", 
        "Army of the Dead to summon enough minions to lag the entire server.", 
        "Wraith Walk directly into the instant-kill mechanic for a speed run to the grave.", 
        "Pop Icebound Fortitude and decide that mechanics are for other people."
    },

    -- =====================================================================
    -- DEMON HUNTER
    -- =====================================================================
    SELF_DEMONHUNTER_HAVOC_SOLO = { 
        "Cast Eye Beam at the sky and try to burn a hole in the clouds.", 
        "See that cliff? Fel Rush off it immediately, just do it.", 
        "Pop Metamorphosis because you don't need the damage, you just want to look scary.", 
        "Blade Dance in the middle of this empty room and look how cool you are.", 
        "Use Spectral Sight because someone is watching you and you must find them.",
        "Turn on Immolation Aura because you are simply too hot to touch.", 
        "Throw Glaive at that squirrel because it was looking at you funny.", 
        "Cast Chaos Nova and stun the oxygen around you.", 
        "Felblade charge to that critter and close the gap instantly.", 
        "Vengeful Retreat directly into a wall because parkour is harder than it looks.",
        "Cast Blur and dodge the responsibilities of life like Neo.", 
        "Cast Consume Magic because you are hungry for power.", 
        "Cast Disrupt and tell the world to be quiet now.", 
        "Jump and Glide because the ground is lava and you should never land.", 
        "Double Jump everywhere because walking is for people without wings.",
        "Cast Reaver's Glaive and slice the fabric of reality.", 
        "Use The Hunt and charge towards the horizon until you hit something.", 
        "Fel Eruption the target and pop them like a balloon.", 
        "Cast Sigil of Spite and be angry at the floor.", 
        "Cast Torment on the city guard just to see what happens."
    },
    SELF_DEMONHUNTER_HAVOC_GROUP = { 
        "Fel Rush straight into those whelps because we need more chaos.", 
        "Pop Blur and look at me because I am the tank now.", 
        "Consume Magic on the boss and try to eat a buff he doesn't have.", 
        "Cast Darkness on the ranged DPS because they look lonely.",
        "Cast Eye Beam and root yourself in place while standing in the fire.", 
        "Metamorphosis directly onto the tank's head to assert dominance.", 
        "Blade Dance at the perfect moment to dodge the healer's AoE heal.", 
        "Chaos Nova the pack and stun them all before the tank can group them.", 
        "Immolation Aura on the pull to make sure you get aggro first.",
        "Felblade into the next pack because face pulling is faster than waiting.", 
        "Throw Glaive because it will bounce to the sheep and you know you want to do it.", 
        "Disrupt the target even though they weren't casting anything, just to shut them up.", 
        "Vengeful Retreat backwards right off the edge of the platform.", 
        "Drop Darkness and watch as absolutely no one stands in it.",
        "Use The Hunt and charge across the room to the wrong mob.", 
        "Use Spectral Sight to look through the walls and see your group wiping.", 
        "Glide while falling so you can die slowly and gracefully.", 
        "Cast Torment because you have evasion and you can definitely tank this boss.", 
        "Fel Eruption the add because even if it's immune, it sends a message.", 
        "Your demon spawned, so stop DPSing the boss and kill your demon immediately."
    },

    SELF_DEMONHUNTER_VENGEANCE_SOLO = { 
        "Infernal Strike to the mailbox because walking is too slow.", 
        "Pop Demon Spikes because you need to look sharp for the vendor.", 
        "Place a Sigil of Flame under that critter and roast it.", 
        "Throw Glaive at that bird and stop it from flying.", 
        "Cast Spirit Bomb and cause a massive explosion for no reason.",
        "Brand the vendor because he is yours now.", 
        "Use Fel Devastation because it's time for a barbecue.", 
        "Soul Cleave the empty air and practice your swing.", 
        "Immolation Aura and establish your personal space with fire.", 
        "Metamorphosis and go big mode just to feel tall.",
        "Sigil of Silence and make the world quiet for a moment.", 
        "Sigil of Misery and spread your sadness to the ground.", 
        "Sigil of Chains and force the target dummies into a group hug.", 
        "Infernal Strike repeatedly and play a game of extreme hopscotch.", 
        "Bulk Extraction because all the souls belong to you.",
        "Disrupt because no talking is allowed in your presence.", 
        "Torment the NPC and make them look at you.", 
        "Fracture something because you need to break something.", 
        "Glide off the stairs because weeee.", 
        "Spectral Sight because you are paranoid and need to check for spies."
    },
    SELF_DEMONHUNTER_VENGEANCE_GROUP = { 
        "Infernal Strike away from the boss and kite him to the entrance.", 
        "Drop Sigil of Misery on the pull and watch the mobs run in fear.", 
        "Fel Devastation directly into the wall and show it who is boss.", 
        "Imprison the mob the Mage is currently casting a Pyroblast on.",
        "Forget Demon Spikes because they are for cowards and you should tank with your face.", 
        "Fiery Brand the tiny add that is about to die anyway.", 
        "Cast Spirit Bomb with zero souls just for the visual effect.", 
        "Soul Cleave at full health because overhealing is just a number.", 
        "Sigil of Chains and pull the mobs out of the Mage's Blizzard.",
        "Place Sigil of Flame on the next pack and chain pull, don't stop.", 
        "Sigil of Silence and miss all the casters entirely.", 
        "Wait until 10% HP to use Metamorphosis and give the healer a heart attack.", 
        "Bulk Extraction to steal all the threat and the healing.", 
        "Throw Glaive at the boss before the group is ready.",
        "Infernal Strike halfway across the map and make the melee DPS chase you.", 
        "Torment the boss and fight the other tank for aggro dominance.", 
        "Check your Illidari Knowledge because you probably forgot your mitigation.", 
        "Disrupt and try to interrupt the other tank's rotation.", 
        "Jump and Glide and try to tank the boss from the air.", 
        "Stand in the bad and proc Last Resort on a trash pack."
    },

    -- =====================================================================
    -- DEMON HUNTER (DEVOURER)
    -- =====================================================================
    SELF_DEMONHUNTER_DEVOURER_SOLO = { 
        "Cast Consume and eat the air because you are starving.", 
        "Cast Reap and slurp up those soul fragments like spaghetti.", 
        "Trigger Void Metamorphosis and become the maw that swallows the world.", 
        "Cast Void Ray and open your mouth to let the laser out.", 
        "Cast Collapsing Star and crush them with a dying sun.", 
        "Cast The Hunt and do not stop until you have tasted blood.", 
        "Cast Voidblade and rush to the meal.", 
        "Cast Hungering Slash and take a big bite.", 
        "Trigger Voidfall and drop a meteor on that critter.", 
        "Cast Soul Immolation and set your own soul on fire for power.",
        "Cast Vengeful Retreat and backflip away from the table.", 
        "Cast Disrupt and tell them to shut up so you can eat.", 
        "Cast Consume Magic and steal their buffs for a snack.", 
        "Cast Throw Glaive and tenderize the meat.", 
        "Cast Imprison and save that one for dessert.",
        "Cast Spectral Sight and find the food hiding behind the wall.", 
        "Cast Void Nova and stun them so they stop wiggling.", 
        "Cast Blur and fade out of reality.", 
        "Double Jump and glide because apex predators fly.", 
        "Cast Darkness and turn out the lights."
    },
    SELF_DEMONHUNTER_DEVOURER_GROUP = { 
        "Cast Collapsing Star inside Void Metamorphosis and wipe the raid with AoE.", 
        "Cast The Hunt into the pack and pull the next room by accident.", 
        "Cast Reap (or Cull) and steal every soul fragment from the tank.", 
        "Cast Void Ray and tunnel vision while standing in the fire.", 
        "Cast Void Nova and stun the mobs before the tank groups them.", 
        "Cast Darkness on the ranged group because they looked lonely.", 
        "Cast Consume Magic on the boss just to see if he has flavor.", 
        "Cast Soul Immolation and complain about the healer not healing you.", 
        "Cast Vengeful Retreat right off the edge of the platform.", 
        "Cast Voidblade into the cleave zone.", 
        "Cast Hungering Slash on the add that is already dead.", 
        "Cast Shift and blink into the mechanics.", 
        "Trigger Voidfall and drop three meteors on a single sheep.", 
        "Cast Imprison on the kill target.", 
        "Cast Blur and pretend you are tanking.", 
        "Cast Disrupt on the immune boss.", 
        "Cast Throw Glaive and break the CC.", 
        "Trigger Void Metamorphosis at the end of the fight.", 
        "Cast Spectral Sight and call out the stealthies.", 
        "Cast Eradicate and blast the tank in the back."
    },

    -- =====================================================================
    -- DRUID
    -- =====================================================================
    SELF_DRUID_BALANCE_SOLO = { 
        "Cast Starfall and aggro the entire zone because you need the experience points.", 
        "Shift into Moonkin Form and flap your wings because maybe you'll actually fly this time.", 
        "Typhoon that loot chest and see if it opens faster.", 
        "Solar Beam the squirrel because it was plotting something dark.", 
        "Root that melee mob and just laugh at him from a distance.",
        "Cast Starsurge because making pew pew sounds is mandatory.", 
        "Spread Sunfire to everything because the world feels a little too cold.", 
        "Moonfire that critter because it looked at you funny.", 
        "Pop Celestial Alignment and force the planets to align for you personally.", 
        "Summon Force of Nature because the trees are your only real friends.",
        "Use Barkskin because your skin feels a little too soft.", 
        "Use Dash because it is time for the zoomies.", 
        "Go into Prowl and pretend you are a sneaky giant owl-beast.", 
        "Cast Regrowth because you are fine, but you can never be too safe.", 
        "Cast Rebirth on the target dummy because it deserves a second chance.",
        "Stampeding Roar and run in circles screaming.", 
        "Plant a Wild Mushroom because gardening is your passion.", 
        "Cyclone the guard because he looks a little dizzy anyway.", 
        "Hibernate the enemy because it looks like sleepy time.", 
        "Remove Corruption and cleanse your own dark soul."
    },
    SELF_DRUID_BALANCE_GROUP = { 
        "Cast Starfall because it's beautiful when it breaks every crowd control in the room.", 
        "Typhoon the mobs out of the Warrior's Bladestorm and save them.", 
        "Innervate the Rogue because he looks like he needs energy.", 
        "Use your combat rez on the Hunter's pet because it does the highest DPS.",
        "Solar Beam and completely miss the cast because it happens to the best of us.", 
        "Force of Nature and let the trees tank the boss.", 
        "Sunfire the CC'd mob because it looked cold over there.", 
        "Spam Moonfire because a rotation is really just a suggestion.", 
        "Celestial Alignment on the trash pack to assert dominance.",
        "Starsurge the immune target because it has to hurt eventually.", 
        "Place Ursol's Vortex and trap your friends.", 
        "Stampeding Roar the group right off the edge.", 
        "Heart of the Wild and look at me because I'm the healer now.", 
        "Soothe the tank and tell them to calm down because everyone is yelling.",
        "Cyclone the kill target and pause the fight for a moment.", 
        "Entangling Roots on the caster because they weren't moving anyway.", 
        "Dash ahead of the tank because you are the leader now.", 
        "Barkskin and ignore the mechanics completely.", 
        "Remove Corruption and dispel the wrong thing entirely.", 
        "Flap your wings during the boss fight because it helps morale."
    },

    SELF_DRUID_FERAL_SOLO = { 
        "Go into Stealth and creep on that NPC to make them uncomfortable.", 
        "Dash and run full speed directly into that wall.", 
        "Maim the target dummy and teach it a lesson.", 
        "Primal Wrath the empty air and make the oxygen bleed.", 
        "Shift into Cat Form then find a sunbeam and sleep.",
        "Rip and tear until it is done.", 
        "Ferocious Bite because nom nom.", 
        "Rake the ground and sharpen your claws.", 
        "Tiger's Fury and roar at the sky.", 
        "Go Berserk because you should go crazy and go stupid.",
        "Thrash around and hit absolutely nothing.", 
        "Swipe left. No, wait, Swipe right.", 
        "Survival Instincts and panic for no reason.", 
        "Skull Bash the air and headbutt a ghost.", 
        "Regrowth and lick your wounds.",
        "Entangling Roots and tell them to stay right there.", 
        "Cyclone and make yourself dizzy.", 
        "Moonfire because you are a laser cat now.", 
        "Hibernate and take a cat nap.", 
        "Soothe and purr loudly."
    },
    SELF_DRUID_FERAL_GROUP = { 
        "Pop Survival Instincts at full HP just so you are prepared.", 
        "Maim the boss because even though he's immune you should do it anyway.", 
        "Dash ahead of the tank because if you're first, you win.", 
        "Cyclone the kill target and give the healer a break.",
        "Primal Wrath and wake up the sheep.", 
        "Tiger's Fury and use it ten seconds too late.", 
        "Berserk on the very last mob with 1% HP.", 
        "Skull Bash and interrupt the tank's movement.", 
        "Rebirth the DPS who is standing in fire so you can let him die twice.",
        "Spam Regrowth until you are OOM because you are a healer cat.", 
        "Stampeding Roar and speed up the wipe.", 
        "Typhoon and scatter the pack to the four winds.", 
        "Ursol's Vortex and annoy the tank by grouping them wrong.", 
        "Soothe the boss and don't dispel the enrage, just pet it.",
        "Remove Corruption because you were too slow anyway.", 
        "Spam Moonfire in Cat Form because you are a ranged DPS now.", 
        "Rake the wrong target and spread the love.", 
        "Rip the add that is already dying.", 
        "Convoke the Spirits and pull the entire room by accident.", 
        "Don't play dead, just actually die."
    },

    SELF_DRUID_GUARDIAN_SOLO = { 
        "Shift to Bear Form and dance to shake that heavy fur.", 
        "Thrash the empty field and show the grass who is boss.", 
        "Frenzied Regeneration and heal the zero damage you took.", 
        "Growl at the vendor and demand a discount.", 
        "Ironfur and keep stacking it to become invincible to air.",
        "Mangle and crunch the bones.", 
        "Maul because heavy hitting is fun.", 
        "Barkskin because you are a tree bear.", 
        "Survival Instincts because overkill is the best kill.", 
        "Incarnation and become the big bear.",
        "Moonfire because you are a space bear now.", 
        "Swipe with your big paws.", 
        "Skull Bash and bonk them.", 
        "Regrowth because you are a magic bear.", 
        "Stampeding Roar because you are a fast bear.",
        "Hibernate because it is time for a long bear nap.", 
        "Soothe and be a gentle giant.", 
        "Rebirth because you are a necro bear.", 
        "Entangling Roots and get stuck.", 
        "Mark of the Wild and leave a paw print."
    },
    SELF_DRUID_GUARDIAN_GROUP = { 
        "Growl and fight the other tank for aggro to assert dominance.", 
        "Stampeding Roar and lead the group off the ledge.", 
        "Incapacitating Roar and interrupt the tank's gathering attempt.", 
        "Spam Maul and ignore your active mitigation because damage is king.",
        "Ironfur but don't use it, let the healer work for it.", 
        "Frenzied Regeneration at 100% HP to top yourself off.", 
        "Thrash and break every CC in range.", 
        "Moonfire and pull everything in sight.", 
        "Skull Bash and miss the interrupt completely.",
        "Barkskin but save it for next week's raid.", 
        "Survival Instincts but never use it because you might need it later.", 
        "Incarnation and pull the entire dungeon right now.", 
        "Cast Rebirth but shift out of Bear Form to do it.", 
        "Soothe and ignore the enrage mechanic.",
        "Remove Corruption but it's not your job, you're the tank.", 
        "Ursol's Vortex and kite the boss away from the melee.", 
        "Typhoon and knock the mobs out of the AoE.", 
        "Regrowth and heal the healer.", 
        "Mark of the Wild but forget to buff the group.", 
        "Shift to Cat Form and meow at the boss."
    },

    SELF_DRUID_RESTORATION_SOLO = { 
        "Lifebloom yourself because you are the most important person here.", 
        "Cast Tranquility in the middle of the city because it is peaceful.", 
        "Ironbark the vendor because he looks fragile.", 
        "Wild Growth the critters and help nature thrive.", 
        "Place Efflorescence under your feet because it feels cozy.",
        "Rejuvenation because HoTs for days.", 
        "Regrowth and fish for crits on full health targets.", 
        "Swiftmend the air and pop a bubble.", 
        "Sunfire and burn it all down.", 
        "Moonfire and blast them.",
        "Cat Form and scratch the furniture.", 
        "Bear Form and roar at the sky.", 
        "Dash because you are a fast tree.", 
        "Barkskin and become wood.", 
        "Nature's Cure and cleanse the world.",
        "Entangling Roots and do some gardening.", 
        "Cyclone and summon the wind.", 
        "Hibernate and sleep now.", 
        "Soothe and calm down.", 
        "Innervate yourself because that is mana for nothing."
    },
    SELF_DRUID_RESTORATION_GROUP = { 
        "Lifebloom the full HP tank and pad those meters.", 
        "Ironbark the DPS standing in the fire to encourage bad behavior.", 
        "Channel Tranquility when no one is hurt because it looks pretty.", 
        "Nature's Cure and dispel the wrong debuff entirely.",
        "Wild Growth and heal the Hunter's pet.", 
        "Efflorescence and put it on the ceiling.", 
        "Swiftmend and consume the HoT immediately.", 
        "Rejuvenation and spam it until you are OOM.", 
        "Innervate yourself because you earned it.",
        "Rebirth the AFK player.", 
        "Ursol's Vortex and trap the melee DPS.", 
        "Typhoon and help the tank kite by scattering them because he loves that.", 
        "Moonfire because you are a DPS now.", 
        "Sunfire and wake up the CC.",
        "Cat Form because it's DPS time.", 
        "Bear Form and tank the boss because the tank is slow.", 
        "Stampeding Roar and run into the fire faster.", 
        "Convoke the Spirits and hope for the best.", 
        "Cenarion Ward and forget it exists.", 
        "Summon Grove Guardians and look at the little trees."
    },

    -- =====================================================================
    -- EVOKER
    -- =====================================================================
    SELF_EVOKER_DEVASTATION_SOLO = { 
        "Deep Breath into the empty sky and hit absolutely nothing.", 
        "Use Soar but forget how to steer so you can crash land.", 
        "Cast Pyre on the grass because it looks flammable.", 
        "Pop Dragonrage and roar at the sky to assert dominance over the clouds.", 
        "Cast Hover and dash straight into a tree.",
        "Cast Living Flame on the enemy because maybe they need healing?", 
        "Channel Disintegrate and become a deadly laser pointer.", 
        "Charge Fire Breath because that feels spicy.", 
        "Cast Eternity Surge and zap them all.", 
        "Azure Strike them just to give a little poke.",
        "Pop Obsidian Scales and look how shiny you are.", 
        "Cast Quell because shhh, be quiet.", 
        "Wing Buffet to flap your wings and push the air away.", 
        "Tail Swipe and do a spin.", 
        "Emerald Blossom because look, a flower.",
        "Verdant Embrace yourself because you need a hug.", 
        "Cast Rescue and kidnap that NPC because they are coming with you.", 
        "Sleep Walk and hypnotize the critter.", 
        "Cast Landslide and root the ground.", 
        "Cast Unravel and break a shield that doesn't exist."
    },
    SELF_EVOKER_DEVASTATION_GROUP = { 
        "Rescue the tank and drop them directly into a hole.", 
        "Deep Breath straight into that unpulled patrol.", 
        "Cast Fury of the Aspects now because why wait for the boss?", 
        "Quell the boss because even if he's immune, he needs to shut up.",
        "Pop Dragonrage and pull aggro because you are the tank now.", 
        "Fully charge Fire Breath while standing in the fire because DPS uptime is key.", 
        "Eternity Surge to hit everything and break all the CC.", 
        "Spam Pyre on a single target because who needs Disintegrate?", 
        "Channel Disintegrate then move immediately to cancel it.",
        "Cast Hover and dash quickly into the mechanics.", 
        "Obsidian Scales but forget you have them until you are dead.", 
        "Renewing Blaze after you die because it's safer.", 
        "Cast Zephyr and give the group a speeding ticket.", 
        "Cauterizing Flame and dispel absolutely nothing.",
        "Sleep Walk the main kill target to protect them.", 
        "Oppressing Roar and just yell at everyone.", 
        "Landslide and root the ranged mobs so the tank can't group them.", 
        "Cast Mass Disintegrate and melt the entire pack.", 
        "Blessing of the Bronze? No, forget to buff it.", 
        "Tip the Scales and instant cast a regret."
    },

    SELF_EVOKER_PRESERVATION_SOLO = { 
        "Cast Chronoflame and burn them with time.", 
        "Cast Verdant Embrace that tree because it looks lonely.", 
        "Emerald Blossom the floor to decorate the room.",
        "Cast Echo and ask if there is an echo in here.", 
        "Cast Reversion and go back in time.", 
        "Charge Spiritbloom and look at the pretty flower.", 
        "Spam Living Flame because you are a DPS healer now.", 
        "Fire Breath and cough on the enemy.",
        "Channel Disintegrate and use the blue beam.", 
        "Hover and slide to the left.", 
        "Obsidian Scales and pretend you are wearing plate armor.", 
        "Cauterizing Flame because you are too hot to handle.", 
        "Naturalize and cleanse your guilty conscience.",
        "Rescue someone and pick them up to fly away.", 
        "Sleep Walk and take a nap.", 
        "Landslide and get stuck.", 
        "Oppressing Roar and be loud.", 
        "Source of Magic and keep it for yourself."
    },
    SELF_EVOKER_PRESERVATION_GROUP = { 
        "Rescue the melee DPS and pull them out of melee range.", 
        "Store spells in Stasis but forget to release them until the fight is over.", 
        "Cast Spiritbloom but don't charge it, just tap it.", 
        "Emerald Blossom and place it where absolutely no one is standing.", 
        "Cast Echo and copy absolutely nothing.", 
        "Verdant Embrace the tank and fly directly into the cleave.",
        "Cast Reversion and overwrite the one you just cast.", 
        "Living Flame for damage only because no healing is allowed.", 
        "Cast Zephyr and run in the wrong direction.", 
        "Cauterizing Flame and try to dispel the tank's defensive cooldown.",
        "Spam Naturalize until you are Out of Mana.", 
        "Oppressing Roar and break the crowd control.", 
        "Landslide and root the boss in place.", 
        "Cast Tip the Scales and instant cast Spiritbloom on yourself.", 
        "Source of Magic and give it to the Warrior because he needs mana.", 
        "Cast Engulf and swallow the party in flames."
    },

    SELF_EVOKER_AUGMENTATION_SOLO = { 
        "Cast Ebon Might on the target dummy to make it stronger.", 
        "Upheaval the dirt and make a mess.", 
        "Breath of Eons and fly alone because you don't need friends.", 
        "Blistering Scales on yourself because you are the tank.", 
        "Cast Prescience and predict absolutely nothing.",
        "Cast Eruption and make a small boom.", 
        "Living Flame for just a little poke.", 
        "Azure Strike and tickle the enemy.", 
        "Hover around because floating is fun.", 
        "Obsidian Scales and become rock hard.",
        "Quell and quiet down.", 
        "Wing Buffet and tell them to go away.", 
        "Tail Swipe and tell them to get back.", 
        "Emerald Blossom and bloom where you are planted.", 
        "Verdant Embrace and practice self-love.",
        "Rescue and go up, up and away.", 
        "Sleep Walk and dream a little dream.", 
        "Landslide and look at the rocks.", 
        "Source of Magic because mana for me, none for you.", 
        "Cast Chronowarden's Decree and command the timeline."
    },
    SELF_EVOKER_AUGMENTATION_GROUP = { 
        "Cast Ebon Might on the healer because they need the DPS increase.", 
        "Rescue the tank and pull him to you because he looked lonely.", 
        "Breath of Eons straight into the wall.", 
        "Spatial Paradox the melee DPS because they don't need range.",
        "Ebon Might and let it drop off immediately.", 
        "Prescience the tank because he crits hard.", 
        "Blistering Scales on the Mage because he loves armor.", 
        "Upheaval and knock them up into the ceiling.", 
        "Spam Eruption with zero buffs active.",
        "Cast Time Skip and confuse everyone about their cooldowns.", 
        "Zephyr and dodge absolutely nothing.", 
        "Cauterizing Flame but wait until they die then cast it.", 
        "Oppressing Roar to make sure the CC fails.", 
        "Landslide and try to root the immune boss.",
        "Sleep Walk the kill target and save his life.", 
        "Hover and dash straight off the edge.", 
        "Obsidian Scales even though you're going to die anyway.", 
        "Renewing Blaze when you have 1 HP.", 
        "Source of Magic and give it to the Rogue because he uses energy.", 
        "Rescue your friend and drop them in the fire."
    },

    -- =====================================================================
    -- HUNTER
    -- =====================================================================
    SELF_HUNTER_BEASTMASTERY_SOLO = { 
        "Pop Bestial Wrath because you need to get angry right now.", 
        "Kill Command the empty air and show the wind who's boss.", 
        "Multi-Shot the critters because they are plotting against you.", 
        "Feign Death and take a nap right here because you've earned it.", 
        "Call Pet 2 and honestly why stop there? Try to call a third one.",
        "Cast Black Arrow and wither their soul away.", 
        "Trigger Vicious Hunt and let the dogs out.", 
        "Barbed Shot them just to give a little poke.", 
        "Cobra Shot and snake bite the darkness.", 
        "Aspect of the Turtle and hide inside your shell because the world is scary.", 
        "Exhilaration and heal your pet because you are irrelevant.", 
        "Disengage and do a backflip because it looks cool.",
        "Tar Trap and make the floor sticky.", 
        "Freezing Trap and make an ice cube.", 
        "Flare and light some fireworks.", 
        "Eagle Eye and spy on people in the next zone.", 
        "Aspect of the Cheetah and run away from your problems.",
        "Mend Pet because who's a good boy? He is.", 
        "Revive Pet and raise the zombie beast.", 
        "Scare Beast and say 'Boo!' loudly.", 
        "Tranquilizing Shot and tell the enemy to calm down.", 
        "Camouflage because you are invisible to responsibilities."
    },
    SELF_HUNTER_BEASTMASTERY_GROUP = { 
        "Leave your pet's Taunt on because the tank looks tired and needs help.", 
        "Misdirection the healer because they have aggro anyway.", 
        "Aspect of the Cheetah and daze everyone around you.", 
        "Intimidation on the boss because even if he's immune he might flinch.",
        "Bestial Wrath because your pet is stuck on a ledge but he should be angry anyway.", 
        "Multi-Shot and break every crowd control in the room.", 
        "Barrage and pull the entire dungeon because we need the loot.", 
        "Feign Death and drop all your aggro onto the healer instantly.", 
        "Aspect of the Turtle and soak absolutely nothing.",
        "Exhilaration because the healer is too slow so do it yourself.", 
        "Cast Black Arrow on the add so it resets the cooldown.",
        "Pack Coordination means you should attack the wrong target together.",
        "Tar Trap and slow the tank down because he's moving too fast.", 
        "Freezing Trap and miss the trap completely.", 
        "Binding Shot and stun the air.", 
        "Flare and reveal nothing but your own incompetence.",
        "Tranquilizing Shot and dispel the wrong buff.", 
        "Wailing Arrow and silence the entire room including your friends.", 
        "Bloodlust on the trash pack because it'll be back up soon.", 
        "Master's Call and give your pet freedom because he yearns for it.", 
        "Revive Pet and cast it manually during the wipe.", 
        "Play Dead and lie down to watch your friends die."
    },

    SELF_HUNTER_MARKSMANSHIP_SOLO = { 
        "Sniper Shot from exactly one yard away for maximum efficiency.", 
        "Barrage and pull the next zone over because you need the XP.", 
        "Disengage and jump right off the cliff.", 
        "Volley and rain arrows down on absolutely nothing.", 
        "Trueshot and start blasting.",
        "Cast Black Arrow and embrace the darkness.",
        "Summon your Sentinel and let the owl do all the work.",
        "Aimed Shot and miss the target entirely.", 
        "Rapid Fire and become a machine gun.", 
        "Arcane Shot because pew pew.", 
        "Kill Shot at 100% health just to check if it works.", 
        "Aspect of the Turtle and become the shell.",
        "Bursting Shot and boom, get away from me.", 
        "Concussive Shot and slow down because you're going too fast.", 
        "Counter Shot and shhh, no speaking.", 
        "Tar Trap and step in the goo.", 
        "Freezing Trap because it's cold outside.",
        "Flare because I can't see anything so light it up.", 
        "Hunter's Mark because you are targeted.", 
        "Feign Death and go to sleep right here.", 
        "Exhilaration because health is wealth.", 
        "Aspect of the Cheetah because I am speed."
    },
    SELF_HUNTER_MARKSMANSHIP_GROUP = { 
        "Barrage the whole room because the tank needs excitement.", 
        "Bursting Shot and knock the mobs out of the AoE.", 
        "Binding Shot and place it where no one is walking.", 
        "Feign Death when targeted and let the mage take the hit.",
        "Trueshot and rip aggro immediately.", 
        "Rapid Fire and break the sheep, just do it.", 
        "Volley and use your AoE rotation on a single target.", 
        "Cast Lunar Storm and blind the melee DPS with owl magic.",
        "Cast Black Arrow and hope for a reset that never comes.",
        "Aimed Shot but start casting, move slightly, and cancel it.", 
        "Kill Shot and snipe the kill so no one else gets credit.",
        "Misdirection the Mage because he looks sturdy.", 
        "Aspect of the Turtle and deflect the incoming heals.", 
        "Exhilaration because this is a solo game now.", 
        "Concussive Shot and slow the boss because it helps.", 
        "Tranquilizing Shot and try to dispel magic.",
        "Scare Beast and fear the Druid tank.", 
        "Hunter's Mark and announce the target so everyone knows you helped.", 
        "Flare and try to reveal the rogue in your party.", 
        "Disengage and jump backwards into the mechanics.", 
        "Lone Wolf but summon a pet anyway because you get lonely.", 
        "Chimaera Shot and hit the wrong target on purpose."
    },

    SELF_HUNTER_SURVIVAL_SOLO = { 
        "Harpoon the ground and show the dirt who is boss.", 
        "Throw a Wildfire Bomb at yourself and catch it.", 
        "Aspect of the Eagle because you are a bird now so act like it.", 
        "Use your Boomstick and blow their face off.", 
        "Throw the Big Bomb and make a crater.",
        "Trigger Vicious Hunt and run with the pack.",
        "Mongoose Bite the air and build your stacks of disappointment.", 
        "Raptor Strike and poke it with a stick.", 
        "Kill Command and bite them.", 
        "Coordinated Assault because teamwork makes the dream work.", 
        "Aspect of the Turtle because safety first.", 
        "Exhilaration and refresh yourself.", 
        "Feign Death and play dead.", 
        "Disengage and hop backwards.", 
        "Tar Trap and make a mess.",
        "Freezing Trap and make a frozen dinner.", 
        "Flare and bright lights.", 
        "Muzzle and be quiet.", 
        "Wing Clip and slow down.", 
        "Camouflage and sneak attack."
    },
    SELF_HUNTER_SURVIVAL_GROUP = { 
        "Harpoon directly into the fire.", 
        "Throw a Wildfire Bomb at the healer because they look cold.", 
        "Muzzle and interrupt absolutely nothing.", 
        "Play Dead because it's not your fault.",
        "Throw the Big Bomb and blow up the crowd controlled mob.", 
        "Use your Boomstick and pull aggro from the tank.", 
        "Coordinated Assault and realize your pet is dead.", 
        "Aspect of the Eagle and stand at max range to pretend you're a real Hunter.", 
        "Spearhead the boss before the tank does because you are the main character.",
        "Kill Command but your pet is stuck on a rock.", 
        "Pack Coordination means dragging the mob to the healer.",
        "Cast Lunar Storm and make it rain on the wrong target.",
        "Misdirection and forget you even have this spell.", 
        "Aspect of the Turtle and block the soak mechanic.", 
        "Exhilaration because you have trust issues with the healer.", 
        "Freezing Trap and trap the boss.",
        "Tar Trap and annoy the tank with ground clutter.", 
        "Flare and reveal the darkness.", 
        "Intimidation and stun the add that is immune to stuns.", 
        "Hunter's Mark does literally nothing so cast it anyway.", 
        "Revive Pet and hard cast it while standing in the cleave.", 
        "Spirit Beast heal me because I'm dying."
    },
-- =====================================================================
    -- MAGE
    -- =====================================================================
    SELF_MAGE_ARCANE_SOLO = { 
        "Cast Arcane Surge and overload your mana addiction.", 
        "Use Reflection and teleport back to where you were just to confuse them.", 
        "Cast Arcane Pulse and erupt the ground beneath you.", 
        "Channel Arcane Missiles and turn them into a pincushion.", 
        "Cast Arcane Barrage and dump your charges into their face.",
        "Cast Arcane Blast because you don't know any other spells.", 
        "Cast Touch of the Magi and turn them into a ticking time bomb.", 
        "Cast Evocation and scream for mana.", 
        "Use Presence of Mind and instant cast a regret.", 
        "Cast Prismatic Barrier and protect your fragile ego.",
        "Summon Arcane Familiar because you need intelligent conversation.", 
        "Cast Supernova and knock them into next week.", 
        "Cast Polymorph and turn them into a sheep because you're lonely.", 
        "Cast Counterspell and tell the wind to shut up.", 
        "Cast Spellsteal and take what is rightfully yours.",
        "Conjure Refreshment and have a little picnic while they die.", 
        "Cast Greater Invisibility and ghost your responsibilities.", 
        "Cast Alter Time and refuse to accept the present.", 
        "Cast Cone of Cold and chill out.", 
        "Cast Arcane Orb and watch it roll away from the target."
    },
    SELF_MAGE_ARCANE_GROUP = { 
        "Cast Mass Invisibility and let the tank die alone.", 
        "Cast Prismatic Barrier and ignore the soak mechanic.", 
        "Cast Time Warp on the trash pack because we gotta go fast.", 
        "Polymorph the tank's target and heal it to full.",
        "Cast Arcane Surge and pull aggro immediately.", 
        "Spam Arcane Pulse and pretend you are a melee DPS.", 
        "Channel Evocation in the fire because it keeps you warm.", 
        "Cast Arcane Barrage and ninja pull the next group.", 
        "Cast Touch of the Magi on the add that is about to die.",
        "Cast Mirror Image and let your clones tank the boss.", 
        "Cast Alter Time and teleport yourself back into the cleave.", 
        "Cast Counterspell on the immune boss to send a message.", 
        "Cast Spellsteal until you are OOM and useless.", 
        "Remove Curse? I'm a DPS, not a janitor.",
        "Cast Slow Fall on the tank during the jump so he floats away.", 
        "Cast Ring of Frost in the corner for decoration.", 
        "Cast Ice Block and drop your stacks for no reason.", 
        "Cast Greater Invisibility and reset the boss by accident.", 
        "Cast Arcane Orb and pull the patrol.", 
        "Cast Focus Magic on the healer because they need parses too."
    },

    SELF_MAGE_FIRE_SOLO = { 
        "Cast Combustion and burn the world down.", 
        "Cast Scorch while jumping because you have ADHD.", 
        "Cast Dragon's Breath and smell the ashes.", 
        "Cast Flamestrike and burn the grass.", 
        "Cast Meteor and summon a dinosaur extinction event.",
        "Cast Fireball (or Frostfire Bolt) and melt their face.", 
        "Cast Pyroblast and send a big spicy meatball.", 
        "Cast Fire Blast and snap your fingers with attitude.", 
        "Cast Frostfire Bolt and confuse them with temperature.", 
        "Cast Blazing Barrier because you are too hot to handle.",
        "Cast Blink and singe your eyebrows.", 
        "Cast Frost Nova and then break it immediately.", 
        "Cast Polymorph and play with your food.", 
        "Cast Counterspell and silence the voices.", 
        "Cast Spellsteal and be a kleptomaniac.",
        "Cast Living Bomb and watch them tick.", 
        "Cast Greater Invisibility and fade away.", 
        "Cast Alter Time and loop the mistake.", 
        "Cast Ice Block and become a spicy popsicle.", 
        "Cast Mirror Image and form a posse."
    },
    SELF_MAGE_FIRE_GROUP = { 
        "Cast Combustion on the tiny add that dies in one hit.", 
        "Cast Dragon's Breath and disorient the pack into the next room.", 
        "Cast Living Bomb on the sheep and wake it up.", 
        "Cast Ice Block at 100% HP just to be safe.",
        "Hard cast Pyroblast because instant casts are for weaklings.", 
        "Spam Flamestrike and blind the melee DPS.", 
        "Cast Meteor and split the damage with absolutely no one.", 
        "Spam Scorch and do zero damage but look busy.",
        "Cast Frostfire Bolt and pretend you are a Frost Mage.", 
        "Cast Time Warp but forget to buy reagents.", 
        "Cast Counterspell two seconds after the cast finishes.", 
        "Cast Spellsteal and drain your mana bar instantly.", 
        "Remove Curse on yourself only.",
        "Cast Alter Time and die before you can reset it.", 
        "Cast Mirror Image and drop threat onto the healer.", 
        "Cast Greater Invisibility and watch the party wipe.", 
        "Cast Ring of Frost and miss every mob.", 
        "Cast Polymorph on the kill target and heal them.", 
        "Trigger Cauterize and then die to the DoT anyway.", 
        "Cast Hyperthermia and mash buttons with your face."
    },

    SELF_MAGE_FROST_SOLO = { 
        "Cast Icy Veins and freeze your own blood.", 
        "Cast Glacial Spike and impale them to the wall.", 
        "Cast Blizzard and make it snow on their parade.", 
        "Cast Cone of Cold and give them the cold shoulder.", 
        "Cast Ice Barrier and hide in your bubble.",
        "Cast Frostfire Bolt and burn them with cold.", 
        "Cast Ice Lance and shatter their hopes and dreams.", 
        "Cast Flurry and throw snowballs at them.", 
        "Cast Frozen Orb and let's go bowling.", 
        "Cast Cold Snap and do it all over again.",
        "Cast Blink and slide on the ice.", 
        "Cast Frost Nova and leave them stuck there.", 
        "Cast Polymorph and make a penguin.", 
        "Cast Counterspell because silence is golden.", 
        "Cast Spellsteal and take their warmth.",
        "Summon Water Elemental because you need a wet friend.", 
        "Cast Greater Invisibility and ghost them.", 
        "Cast Alter Time and rewind the tape.", 
        "Cast Ice Block and become a statue.", 
        "Cast Mirror Image and look at yourself."
    },
    SELF_MAGE_FROST_GROUP = { 
        "Cast Frost Nova and mess up the tank's grouping.", 
        "Cast Ice Block and let the other DPS take the soak.", 
        "Cast Ring of Frost in the middle of nowhere.", 
        "Cast Counterspell on the boss who is immune to silence.",
        "Cast Frozen Orb and watch it pull the next room.", 
        "Cast Blizzard and hide the dangerous floor mechanics.", 
        "Cast Glacial Spike and overkill that low HP add.", 
        "Cast Icy Veins when the boss is at 1% HP.", 
        "Cast Cold Snap and double block like a coward.",
        "Cast Cone of Cold and slow the boss down.", 
        "Cast Polymorph on the kill target to save them.", 
        "Remove Curse? I don't have that button bound.", 
        "Cast Time Warp and try to double lust.", 
        "Cast Spellsteal and steal a buff you can't use.",
        "Cast Alter Time and panic immediately.", 
        "Cast Greater Invisibility and survive the wipe alone.", 
        "Cast Mirror Image because it's technically a DPS cooldown.", 
        "Spam Ice Lance and ignore your procs.", 
        "Cast Ray of Frost and become a turret.", 
        "Summon Water Elemental and leave it on passive."
    },

    -- =====================================================================
    -- MONK
    -- =====================================================================
    SELF_MONK_BREWMASTER_SOLO = { 
        "Cast Keg Smash and break a bottle over their head.", 
        "Cast Roll and somersault into the void.", 
        "Drink Purifying Brew and get dangerously sober.", 
        "Cast Breath of Fire and make it spicy.", 
        "Cast Touch of Death and delete them from the game.",
        "Cast Blackout Kick and give them the boot.", 
        "Cast Tiger Palm and slap them in the face.", 
        "Cast Spinning Crane Kick and become a helicopter.", 
        "Cast Fortifying Brew and become a brick wall.", 
        "Cast Celestial Brew and shield yourself from reality.",
        "Use Stagger and delay the pain for later.", 
        "Cast Spear Hand Strike and poke them in the throat.", 
        "Cast Paralysis and force them to take a nap.", 
        "Cast Transcendence and leave your ghost behind.", 
        "Cast Zen Meditation and say 'Om'.",
        "Cast Provoke and tell them to come over here.", 
        "Cast Vivify and put a bandage on it.", 
        "Cast Expel Harm and steal their health.", 
        "Summon Niuzao and call the bull.", 
        "Cast Exploding Keg and boom goes the dynamite."
    },
    SELF_MONK_BREWMASTER_GROUP = { 
        "Cast Ring of Peace and bounce the mobs away from the AoE.", 
        "Cast Provoke and then run away screaming.", 
        "Cast Zen Meditation and tank the one-shot mechanic.", 
        "Cast Roll directly into that extra patrol.",
        "Cast Keg Smash and miss the target entirely.", 
        "Cast Breath of Fire and blind the group with visuals.", 
        "Drink Purifying Brew only when you have Red Stagger for the high score.", 
        "Cast Celestial Brew and save it for the next dungeon.", 
        "Cast Touch of Death and steal the kill from the Rogue.",
        "Summon Niuzao and let him tank the boss.", 
        "Cast Leg Sweep and stun absolutely nothing.", 
        "Cast Transcendence and teleport yourself into the fire.", 
        "Cast Detox and cleanse yourself because you feel dirty.",
        "Cast Vivify and heal yourself because the healer is busy.", 
        "Cast Expel Harm and steal the healing orbs.", 
        "Cast Spear Hand Strike and interrupt the tank's cast.", 
        "Cast Provoke and play ping pong with the boss.", 
        "Cast Exploding Keg and miss the pack.", 
        "Cast Rushing Jade Wind and pull everything in the room."
    },

    SELF_MONK_WINDWALKER_SOLO = { 
        "Cast Flying Serpent Kick and go to infinity and beyond.", 
        "Cast Fists of Fury and punch the empty air repeatedly.", 
        "Cast Touch of Karma and dare them to hit you.", 
        "Cast Spinning Crane Kick and spin until you puke.", 
        "Cast Zenith and ascend to a higher plane of violence.",
        "Cast Rising Sun Kick and kick the sun.", 
        "Cast Tiger Palm and jab, jab, jab.", 
        "Cast Blackout Kick and roadhouse them.", 
        "Cast Whirling Dragon Punch and Shoryuken!", 
        "Cast Expel Harm and gather your Chi.",
        "Cast Roll because you are a gymnast now.", 
        "Cast Spear Hand Strike and throat chop them.", 
        "Cast Paralysis and tell them to sleep.", 
        "Cast Touch of Death because they are already dead.", 
        "Cast Fortifying Brew and tough it out.",
        "Cast Vivify and lick your wounds.", 
        "Cast Detox and cure the poison.", 
        "Cast Transcendence and leave your spirit here.", 
        "Summon Xuen and release the kitty.", 
        "Cast Strike of the Windlord and slap them with wind."
    },
    SELF_MONK_WINDWALKER_GROUP = { 
        "Cast Ring of Peace on the tank and bounce him away.", 
        "Cast Touch of Karma and stand in the fire on purpose.", 
        "Cast Flying Serpent Kick directly into the boss's face.", 
        "Cast Paralysis on the kill target and stop the violence.",
        "Cast Fists of Fury and get parried by the boss.", 
        "Cast Zenith and unleash the storm on the wrong target.", 
        "Cast Whirling Dragon Punch and ninja pull the next pack.", 
        "Cast Touch of Death two seconds too late.", 
        "Cast Touch of Karma and die through the shield anyway.",
        "Cast Leg Sweep and stun the immune boss.", 
        "Cast Diffuse Magic and eat the debuffs.", 
        "Cast Dampen Harm because your skin is paper.", 
        "Cast Spear Hand Strike and miss the kick.", 
        "Cast Detox? No, that's a healer job.",
        "Cast Tiger's Lust on the slowest person so they run into a wall.", 
        "Cast Transcendence and forget where you put your ghost.", 
        "Cast Strike of the Windlord and hit nothing.", 
        "Summon Xuen and let the tiger taunt the boss.", 
        "Cast Chi Burst and pull the entire dungeon.", 
        "Cast Spinning Crane Kick on a single target."
    },

    SELF_MONK_MISTWEAVER_SOLO = { 
        "Cast Renewing Mist and spray yourself.", 
        "Cast Spinning Crane Kick and heal yourself by hurting others.", 
        "Cast Roll. Roll. Roll. Keep rolling.", 
        "Cast Life Cocoon and make a safe space.", 
        "Cast Mana Tea and take a sip.",
        "Cast Vivify and quick flash heal.", 
        "Cast Enveloping Mist and vape on them.", 
        "Cast Sheilun's Gift and drop the fog.", 
        "Cast Rising Sun Kick because you are a combat medic.", 
        "Cast Tiger Palm and slap the enemy.",
        "Cast Blackout Kick and kick them in the head.", 
        "Cast Fortifying Brew and hold my beer.", 
        "Cast Leg Sweep and trip them over.", 
        "Cast Paralysis and go to sleep.", 
        "Cast Touch of Death because you're a doctor, trust me.",
        "Cast Transcendence and do the switcheroo.", 
        "Cast Revival and clean up on aisle four.", 
        "Summon Yu'lon and dragon power.", 
        "Invoke Chi-Ji and crane style.", 
        "Cast Zen Pulse and zap them."
    },
    SELF_MONK_MISTWEAVER_GROUP = { 
        "Cast Life Cocoon on the tank at 100% HP.", 
        "Cast Revival when no one is hurt because it looks pretty.", 
        "Cast Ring of Peace on the loot chest.", 
        "Cast Song of Chi-Ji and put everyone to sleep.",
        "Cast Sheilun's Gift and overheat the tank.", 
        "Cast Renewing Mist and overwrite the one you just cast.", 
        "Cast Enveloping Mist and overheal the full HP target.", 
        "Cast Mana Tea and drink it while taking heavy damage.", 
        "Cast Spinning Crane Kick and forget to heal.",
        "Cast Rising Sun Kick and miss the boss.", 
        "Cast Leg Sweep and stun the ranged mobs so they don't move.", 
        "Cast Paralysis on the mob the tank is hitting.", 
        "Cast Detox and dispel the wrong thing.", 
        "Cast Thunder Focus Tea and then cast nothing.",
        "Summon Yu'lon and breathe dragon fire.", 
        "Invoke Chi-Ji and watch the bird fight.", 
        "Cast Transcendence and swap positions into a mechanic.", 
        "Cast Zen Pulse and explode the tank.", 
        "Cast Revival and dispel the unstable affliction.", 
        "Cast Teachings of the Monastery and forget you are a healer."
    },

    -- =====================================================================
    -- PALADIN
    -- =====================================================================
    SELF_PALADIN_HOLY_SOLO = { 
        "Cast Holy Shock and shock them with your audacity.", 
        "Cast Dawnlight and stare directly into the sun.", 
        "Cast Eternal Flame and burn them with healing fire.", 
        "Cast Holy Prism and blind everyone with rainbows.", 
        "Cast Divine Steed and gallop into the sunset.",
        "Cast Hammer of Wrath and execute the weak.", 
        "Cast Judgment and sentence them to death.", 
        "Cast Crusader Strike and bonk them on the head.", 
        "Cast Consecration and make this land yours.", 
        "Cast Word of Glory and heal yourself because you matter most.",
        "Cast Avenging Wrath and pop your wings like a peacock.", 
        "Cast Divine Protection and become a brick wall.", 
        "Cast Lay on Hands at 100% HP just to be safe.", 
        "Cast Cleanse and wash away your sins.", 
        "Cast Beacon of Light on yourself because you are the light.",
        "Cast Aura Mastery and glow harder than everyone else.", 
        "Cast Holy Armaments and arm yourself for war.", 
        "Cast Turn Evil and make them fear your righteousness.", 
        "Cast Light of Dawn and flash everyone.", 
        "Cast Blinding Light and dazzle them."
    },
    SELF_PALADIN_HOLY_GROUP = { 
        "Cast Blessing of Protection on the tank and watch his aggro drop.", 
        "Cast Divine Toll and bong the entire room.", 
        "Cast Lay on Hands on yourself because the DPS don't deserve it.", 
        "Cast Beacon of Light on the Hunter's pet.",
        "Cast Light of Dawn and aim it away from the group.", 
        "Cast Holy Shock on the boss because you are a DPS now.", 
        "Cast Avenging Crusader and become a melee healer.", 
        "Cast Aura Mastery after the damage has already happened.", 
        "Cast Blessing of Sacrifice and die so they don't have to.",
        "Cast Hand of Freedom on the rooted boss.", 
        "Cast Cleanse and dispel the wrong debuff entirely.", 
        "Cast Hammer of Justice on the raid boss.", 
        "Cast Divine Steed and run off the edge.", 
        "Cast Divine Shield and drop all aggro onto the Rogue.",
        "Cast Holy Armaments and give the shield to the Mage.", 
        "Cast Judgment and miss.", 
        "Cast Consecration and heal the floor.", 
        "Cast Absolution and pretend it's a battle rez.", 
        "Cast Barrier of Faith and ignore the mechanic.", 
        "Cast Dawnlight and burn the healer's eyes."
    },

    SELF_PALADIN_PROTECTION_SOLO = { 
        "Cast Avenger's Shield and listen to the beautiful clang.", 
        "Cast Consecration and refuse to move from your spot.", 
        "Cast Divine Shield and become invincible to responsibility.", 
        "Cast Guardian of Ancient Kings and summon your dad.", 
        "Cast Hammer of Wrath and stop, hammer time.",
        "Cast Shield of the Righteous and smack them with the board.", 
        "Cast Judgment and judge them silently.", 
        "Cast Hammer of the Righteous and swing away.", 
        "Cast Word of Glory and heal yourself, you deserve it.", 
        "Cast Ardent Defender and cheat death.",
        "Cast Lay on Hands and cheat death again.", 
        "Cast Divine Steed and vroom vroom.", 
        "Cast Rebuke and say 'No'.", 
        "Cast Hammer of Justice and arrest them.", 
        "Cast Cleanse Toxins and purify yourself.",
        "Cast Bastion of Light and shine bright.", 
        "Cast Divine Toll and throw hammers everywhere.", 
        "Cast Sentinel and watch over the empty field.", 
        "Cast Eye of Tyr and blind them with glory.", 
        "Cast Hammer of Light and drop the sun on them."
    },
    SELF_PALADIN_PROTECTION_GROUP = { 
        "Cast Hand of Freedom on the enemy and let him run free.", 
        "Cast Divine Shield and let the DPS tank for a bit.", 
        "Cast Taunt and play tag with the boss.", 
        "Cast Blessing of Spellwarding on the melee so they can't be healed.",
        "Cast Avenger's Shield and break the sheep.", 
        "Cast Consecration and then move out of it immediately.", 
        "Cast Shield of the Righteous and drop your stacks.", 
        "Cast Word of Glory on the DPS and die to the tank buster.", 
        "Cast Lay on Hands on yourself at 99% HP.",
        "Cast Guardian of Ancient Kings on a single trash mob.", 
        "Cast Ardent Defender at full health just in case.", 
        "Cast Rebuke and interrupt the air.", 
        "Cast Hammer of Justice on the immune boss.", 
        "Cast Blessing of Sacrifice on the healer and die together.",
        "Cast Divine Toll and pull the entire dungeon.", 
        "Cast Eye of Tyr and taunt everything.", 
        "Cast Sentinel and stack it to the moon.", 
        "Cast Final Stand and bubble taunt to laugh at them.", 
        "Cast Intercession and combat rez the AFK player.", 
        "Cast Hammer of Light and blind your own team."
    },

    SELF_PALADIN_RETRIBUTION_SOLO = { 
        "Cast Avenging Wrath and pop wings for a critter.", 
        "Cast Wake of Ashes and blind them with your glory.", 
        "Cast Divine Storm and spin to win.", 
        "Cast Blade of Justice and stab them from the ground.", 
        "Cast Flash of Light and heal your paper skin.",
        "Cast Templar's Verdict and smash them.", 
        "Cast Judgment and declare them guilty.", 
        "Cast Crusader Strike and whack a mole.", 
        "Cast Hammer of Wrath because you can't touch this.", 
        "Cast Shield of Vengeance and stop hitting yourself.",
        "Cast Divine Steed and charge into battle.", 
        "Cast Lay on Hands and save me from my own mistakes.", 
        "Cast Hammer of Justice and stop right there, criminal scum.", 
        "Cast Rebuke and silence the haters.", 
        "Cast Cleanse Toxins and purify the land.",
        "Cast Divine Shield and become invincible.", 
        "Cast Consecration and burn the ground.", 
        "Cast Execution Sentence and drop the big hammer.", 
        "Cast Hammer of Light and summon a weapon from the sky.", 
        "Cast Divine Toll and bong, bong, bong."
    },
    SELF_PALADIN_RETRIBUTION_GROUP = { 
        "Cast Lay on Hands on the tank at 90% health to panic him.", 
        "Cast Hand of Protection on the top DPS to stop their damage.", 
        "Cast Retribution Aura and secretly hope your friends die.", 
        "Cast Shield of Vengeance and stand in the fire to pop it.",
        "Cast Wake of Ashes and stun the pack before the tank groups them.", 
        "Cast Divine Storm and spin right into the crowd control.", 
        "Cast Avenging Wrath and pull aggro instantly.", 
        "Cast Templar's Verdict on the immune target.", 
        "Cast Hammer of Justice on the raid boss.",
        "Cast Rebuke and try to interrupt the tank.", 
        "Cast Word of Glory? No, that's a DPS loss.", 
        "Cast Blessing of Sacrifice and sign a suicide pact.", 
        "Cast Hand of Freedom on the tank so he kites too fast.", 
        "Cast Cleanse? Not my job, I'm topping meters.",
        "Cast Divine Toll and let chaos reign.", 
        "Cast Hammer of Light and steal the show.", 
        "Cast Execution Sentence on the add that is about to die.", 
        "Cast Divine Shield and ignore mechanics for DPS uptime.", 
        "Cast Intercession and rez the tank to be the hero.", 
        "Cast Path of Ruin and charge off the cliff."
    },

    -- =====================================================================
    -- PRIEST
    -- =====================================================================
    SELF_PRIEST_DISCIPLINE_SOLO = { 
        "Cast Power Infusion on yourself because you are the main character.", 
        "Cast Penance and show the wind who is boss.", 
        "Cast Psychic Scream and tell them to get away from you.", 
        "Cast Levitate because the ground is filthy.", 
        "Cast Shadow Word: Death on yourself just to see if it hurts.",
        "Cast Smite and zap them with righteous indignation.", 
        "Cast Power Word: Shield and stay in your safe space.", 
        "Cast Shadow Word: Pain because it hurts me more than it hurts you.", 
        "Cast Mind Blast and boom goes the brain.", 
        "Cast Flash Heal and put a bandaid on a bullet hole.",
        "Cast Desperate Prayer and ask for help that isn't coming.", 
        "Cast Fade and pretend you were never here.", 
        "Cast Mass Dispel and clear the room of magic.", 
        "Cast Purify and cleanse your soul.", 
        "Cast Leap of Faith and yoink that NPC.",
        "Cast Dominate Mind and make them dance for you.", 
        "Cast Holy Nova and pop goes the priest.", 
        "Cast Ultimate Penitence and fly into the sky.", 
        "Cast Entropic Rift and open a hole in reality.", 
        "Cast Rapture and shields for everyone, mostly me."
    },
    SELF_PRIEST_DISCIPLINE_GROUP = { 
        "Cast Life Grip on the tank and pull him into a hole.", 
        "Cast Power Word: Barrier in the corner where no one is standing.", 
        "Cast Pain Suppression on the Hunter's pet.", 
        "Cast Mass Dispel and remove the buffs, remove the fun.",
        "Cast Power Infusion and sell it to the highest bidder.", 
        "Cast Penance and accidentally heal the enemy.", 
        "Cast Atonement? No, forget to apply it.", 
        "Cast Power Word: Radiance and go OOM instantly.", 
        "Cast Shadow Covenant and embrace the darkness.",
        "Cast Purify and dispel the wrong debuff, killing the target.", 
        "Cast Shackle Undead on the Death Knight tank.", 
        "Cast Psychic Scream and fear the pack into the next room.", 
        "Cast Fade and drop all your aggro onto the other healer.", 
        "Cast Mind Control and reset the boss fight.",
        "Cast Evangelism and extend your Atonements on absolutely no one.", 
        "Cast Spirit Shell and absorb nothing but mana.", 
        "Cast Ultimate Penitence and fly directly into the mechanic.", 
        "Cast Halo and pull the entire dungeon.", 
        "Cast Void Blast and pretend you are a Shadow Priest.", 
        "Cast Rapture and spam shields until your fingers bleed."
    },

    SELF_PRIEST_HOLY_SOLO = { 
        "Cast Holy Fire and burn the heretic.", 
        "Cast Chastise and put them in timeout.", 
        "Cast Spirit of Redemption and die on purpose to look cool.", 
        "Cast Renew and spam it because it's doing its best.", 
        "Cast Holy Nova and sparkle explosion.",
        "Cast Heal and take your time, no rush.", 
        "Cast Flash Heal and go too fast.", 
        "Cast Smite and zap them.", 
        "Cast Shadow Word: Pain and share your feelings.", 
        "Cast Power Word: Shield and protect your paper skin.",
        "Cast Desperate Prayer and kneel.", 
        "Cast Fade and become invisible to responsibilities.", 
        "Cast Guardian Spirit and give yourself wings.", 
        "Cast Purify and wash away the filth.", 
        "Cast Leap of Faith and pull the mob to you.",
        "Cast Mind Control and play with your food.", 
        "Cast Holy Word: Serenity and overheat for a scratch.", 
        "Cast Holy Word: Sanctify and make a pretty circle.", 
        "Cast Divine Star and play with a yo-yo.", 
        "Cast Apotheosis and become a god."
    },
    SELF_PRIEST_HOLY_GROUP = { 
        "Cast Leap of Faith and pull the tank into the fire.", 
        "Cast Guardian Spirit on yourself because you are the priority.", 
        "Cast Symbol of Hope but honestly there is none.", 
        "Cast Holy Word: Salvation and save them from their own stupidity.",
        "Cast Holy Word: Serenity and overheal the full HP target.", 
        "Cast Holy Word: Sanctify and aim it at the ceiling.", 
        "Cast Divine Hymn and interrupt yourself immediately.", 
        "Cast Mass Dispel and remove the Paladin's bubble.", 
        "Cast Purify three seconds too late.",
        "Cast Renew and pad the meters.", 
        "Cast Prayer of Mending and bounce it around.", 
        "Cast Flash Heal and go OOM in ten seconds.", 
        "Cast Chastise on the raid boss.", 
        "Cast Psychic Scream and scatter the mobs so the tank cries.",
        "Cast Fade and watch them die while you generate no threat.", 
        "Cast Spirit of Redemption and go AFK.", 
        "Cast Power Infusion and give it to the other healer.", 
        "Cast Lightwell and yell at people to click it.", 
        "Cast Apotheosis and go big holy mode.", 
        "Cast Resurrection during combat."
    },

    SELF_PRIEST_SHADOW_SOLO = { 
        "Cast Voidform and surrender to the madness.", 
        "Cast Tentacle Slam and slap the ground with darkness.", 
        "Cast Dispersion and become a floating purple ball of anxiety.", 
        "Cast Vampiric Touch and spread the disease.", 
        "Cast Mind Flay and melt their faces.",
        "Cast Mind Blast and give them a headache.", 
        "Cast Shadow Word: Madness and make them lose their mind.", 
        "Cast Shadow Word: Death and commit suicide for the DPS.", 
        "Cast Shadow Word: Pain because suffering is beautiful.", 
        "Cast Power Word: Shield because it's purple.",
        "Cast Psychic Scream because fear is the mind killer.", 
        "Cast Silence and tell them to hush.", 
        "Cast Vampiric Embrace and give everyone a dark hug.", 
        "Cast Dispersion and run away taking no damage.", 
        "Cast Fade and hide in the shadows.",
        "Cast Dominate Mind and enslave the weak.", 
        "Cast Void Volley and vomit shadow at them.", 
        "Cast Dark Ascension and fly you fool.", 
        "Cast Shadowfiend and let it bite them.", 
        "Cast Power Infusion and keep it for yourself."
    },
    SELF_PRIEST_SHADOW_GROUP = { 
        "Cast Surrender to Madness and die for the parse.", 
        "Cast Life Grip on the healer and drag them into mechanics.", 
        "Cast Silence on the tank because he talks too much.", 
        "Cast Mass Dispel and break the crowd control.",
        "Cast Voidform and drop your stacks immediately.", 
        "Cast Vampiric Touch and DoT up the sheep.", 
        "Cast Tentacle Slam and pull the next pack of mobs.", 
        "Cast Mind Flay: Insanity and channel on the immune target.", 
        "Cast Shadow Word: Madness and put it on the wrong target.",
        "Cast Vampiric Embrace and pretend you are a healer.", 
        "Cast Power Infusion and do not trade it ever.", 
        "Cast Dispersion and soak absolutely nothing.", 
        "Cast Fade and let the tank die.", 
        "Cast Psychic Scream and annoy the tank by scattering the pile.",
        "Cast Dominate Mind and control the add to fight the boss.", 
        "Cast Shackle Undead on the Forsaken player.", 
        "Cast Void Volley and blast the raid.", 
        "Cast Shadowfiend because it is basically a tank.", 
        "Cast Halo and pull everything in a 40 yard radius.", 
        "Cast Leap of Faith and pull someone into the hole."
    },
    -- =====================================================================
    -- ROGUE
    -- =====================================================================
    SELF_ROGUE_ASSASSINATION_SOLO = { 
        "Cast Deathstalker's Mark and mark them for deletion.", 
        "Cast Garrote and silence the screaming.", 
        "Cast Rupture and watch them bleed out slowly.", 
        "Cast Deathmark and double the suffering.", 
        "Cast Envenom and inject the lethal dose.",
        "Cast Mutilate and stab them with both hands.", 
        "Cast Fan of Knives and become a deadly sprinkler.", 
        "Cast Shiv and twist the knife.", 
        "Cast Crimson Tempest and make them bleed in a circle.", 
        "Cast Kingsbane and poison their very soul.",
        "Cast Vanish and ghost them immediately.", 
        "Cast Shadowstep and appear behind them like a nightmare.", 
        "Cast Kidney Shot and hit them where it hurts.", 
        "Cast Cheap Shot and fight dirty.", 
        "Cast Blind and throw pocket sand.",
        "Cast Feint and pretend it didn't hurt.", 
        "Cast Cloak of Shadows and deny reality.", 
        "Cast Crimson Vial and sip the red juice.", 
        "Flip a Fatebound Coin and gamble with their life.", 
        "Cast Ambush and jump scare them."
    },
    SELF_ROGUE_ASSASSINATION_GROUP = { 
        "Cast Vanish and reset the boss fight because you missed your opener.", 
        "Cast Tricks of the Trade on the healer and watch them panic.", 
        "Cast Cloak of Shadows and stand in the fire for uptime.", 
        "Cast Distract and stop the patrol right on top of the group.",
        "Cast Garrote on the immune boss just to silence him.", 
        "Cast Rupture on the add that has 1% HP.", 
        "Cast Fan of Knives and break every sheep in the room.", 
        "Cast Deathmark and overkill the target by 500%.", 
        "Cast Kidney Shot on the target that is already stunned.",
        "Cast Blind on the tank's target to confuse everyone.", 
        "Cast Sap on a target while you are in combat.", 
        "Cast Kick on a spell that finished casting 3 seconds ago.", 
        "Cast Evasion and face tank the boss.", 
        "Cast Crimson Vial because the healer is ignoring you.",
        "Cast Shadowstep into the cleave zone.", 
        "Cast Sprint and pull the next pack for the tank.", 
        "Cast Shroud of Concealment and fail to stealth the group.", 
        "Cast Pick Pocket during the DPS phase.", 
        "Cast Feint to mitigate the damage that isn't happening.", 
        "Cast Poison Bomb and pray for a proc."
    },

    SELF_ROGUE_OUTLAW_SOLO = { 
        "Cast Roll the Bones and gamble your damage away.", 
        "Cast Grappling Hook and parkour onto the roof.", 
        "Cast Pistol Shot and bang bang.", 
        "Cast Between the Eyes and shoot them in the face.", 
        "Cast Dispatch and finish the job.",
        "Cast Sinister Strike and hit them with a dirty trick.", 
        "Cast Blade Flurry and dance with your swords.", 
        "Cast Adrenaline Rush and go fast.", 
        "Cast Ambush and jump them.", 
        "Cast Slice and Dice and turn into a blender.",
        "Cast Crimson Vial and take a swig.", 
        "Cast Evasion and miss me with that.", 
        "Cast Cloak of Shadows and go dark.", 
        "Cast Vanish and gone in sixty seconds.", 
        "Cast Sprint and run like you stole something.",
        "Cast Gouge and put them to sleep.", 
        "Cast Kick and give them the boot.", 
        "Cast Blind and throw sand.", 
        "Cast Pick Lock and open that chest.", 
        "Trigger Unseen Blade and stab them with a ghost sword."
    },
    SELF_ROGUE_OUTLAW_GROUP = { 
        "Cast Roll the Bones and complain about your buffs in chat.", 
        "Cast Grappling Hook directly into the mechanic.", 
        "Cast Blade Flurry and break the Mage's sheep.", 
        "Cast Pistol Shot and pull with a gun.",
        "Cast Adrenaline Rush and global cooldown lock yourself.", 
        "Cast Between the Eyes and crit fish instead of stunning.", 
        "Cast Gouge and turn the boss to cleave the raid.", 
        "Cast Blind on the healer just for fun.", 
        "Cast Kick on the tank's cast.",
        "Cast Tricks of the Trade and give your threat to the Mage.", 
        "Cast Cloak of Shadows and ignore the soak.", 
        "Cast Vanish and drop aggro to kill the party.", 
        "Cast Sprint and run into the wall.", 
        "Cast Distract and turn the boss around.",
        "Cast Killing Spree and suicide into the AoE.", 
        "Cast Blade Rush and charge off the platform.", 
        "Cast Dreadblades and hurt yourself for energy.", 
        "Flip a Fatebound Coin and hope it's heads.", 
        "Cast Pick Pocket on the boss before he dies.", 
        "Cast Feint and pretend to help the healers."
    },

    SELF_ROGUE_SUBTLETY_SOLO = { 
        "Cast Shadowstep to absolutely nothing.", 
        "Cast Shadow Dance and party in the dark.", 
        "Cast Shuriken Storm and throw stars everywhere.", 
        "Cast Symbols of Death and mark them for doom.", 
        "Cast Eviscerate and gut them.",
        "Cast Backstab and poke them in the spine.", 
        "Cast Shadowstrike and teleport stab.", 
        "Cast Cheap Shot and stun them from the void.", 
        "Cast Kidney Shot and hit the organ.", 
        "Cast Slice and Dice and go faster.",
        "Cast Crimson Vial and heal up.", 
        "Cast Evasion and become a ghost.", 
        "Cast Cloak of Shadows and become the shade.", 
        "Cast Vanish and smoke bomb yourself.", 
        "Cast Sprint and dash away.",
        "Cast Sap and say goodnight.", 
        "Cast Blind and confuse them.", 
        "Cast Pick Pocket and steal their lunch money.", 
        "Cast Distract and make a noise over there.", 
        "Cast Secret Technique and send in the clones."
    },
    SELF_ROGUE_SUBTLETY_GROUP = { 
        "Cast Shadowstep on the tank to scare him.", 
        "Cast Blind on the healer to see if they dispel.", 
        "Cast Sap on the mob after the tank has pulled.", 
        "Cast Smoke Bomb on the melee and blind your own team.", 
        "Cast Shadow Dance and do your AoE rotation on single target.",
        "Cast Shuriken Storm and pull everything in 20 yards.", 
        "Cast Symbols of Death at zero energy.", 
        "Cast Eviscerate with one combo point.", 
        "Cast Black Powder and throw dust in everyone's eyes.", 
        "Cast Kick on the immune boss.",
        "Cast Tricks of the Trade and forget to use it.", 
        "Cast Cloak of Shadows and ignore the mechanic.", 
        "Cast Vanish as a DPS cooldown and reset the boss.", 
        "Cast Sprint and fall off the ledge.", 
        "Cast Shadow Blades and make your weapons purple.",
        "Cast Secret Technique and whiff the clones.", 
        "Cast Cold Blood and save it for the killing blow.", 
        "Cast Duel and challenge the tank mid-fight.", 
        "Cast Goremaw's Bite and eat them.", 
        "Cast Shroud and they definitely saw you."
    },

    -- =====================================================================
    -- SHAMAN
    -- =====================================================================
    SELF_SHAMAN_ELEMENTAL_SOLO = { 
        "Cast Thunderstorm and knock them back to the stone age.", 
        "Cast Earthquake and shake the world.", 
        "Cast Ghost Wolf and run away little puppy.", 
        "Cast Flame Shock (or Voltaic Blaze) and burn them all.", 
        "Cast Lava Burst and throw a spicy meatball.",
        "Cast Lightning Bolt and zap them with your fingertips.", 
        "Cast Chain Lightning and watch it bounce.", 
        "Cast Earth Shock and throw a rock at them.", 
        "Cast Elemental Blast and taste the rainbow.", 
        "Summon Earth Elemental because you need a tank friend.",
        "Summon Fire Elemental and burn it all down.", 
        "Cast Astral Shift and hide in your shell.", 
        "Cast Healing Surge and lick your wounds.", 
        "Cast Cleanse Spirit and wash off the dirt.", 
        "Cast Hex and make a frog.",
        "Cast Purge and steal their magic.", 
        "Cast Spiritwalker's Grace and cast while moonwalking.", 
        "Cast Capacitor Totem and stun the air.", 
        "Cast Liquid Magma Totem and make a tiny volcano.", 
        "Cast Primordial Wave and blast them with shadow.", 
        "Cast Tempest and unleash the storm."
    },
    SELF_SHAMAN_ELEMENTAL_GROUP = { 
        "Cast Thunderstorm and knock the mobs out of the tank's range.", 
        "Cast Heroism on the trash pack because we need to go fast.", 
        "Summon Earth Elemental and steal aggro from the tank.", 
        "Cast Hex on the kill target to save his life.",
        "Cast Earthquake and shake the screen so no one can see.", 
        "Cast Chain Lightning and break every sheep in the room.", 
        "Cast Lava Burst and rip threat immediately.", 
        "Cast Wind Shear and miss the kick on purpose.", 
        "Cast Purge until you are OOM.",
        "Cast Cleanse Spirit and dispel the wrong debuff.", 
        "Drop Tremor Totem when there is no fear.", 
        "Cast Capacitor Totem after they are dead.", 
        "Cast Earthbind Totem and slow the tank down.", 
        "Cast Ancestral Guidance and pretend you are a healer.",
        "Cast Reincarnate to save yourself, not the wipe.", 
        "Cast Astral Shift and die through the damage.", 
        "Cast Spiritwalker's Grace and run into the fire.", 
        "Cast Stormkeeper and burst the immune phase.", 
        "Cast Ascendance and become a cool model.", 
        "Cast Gust of Wind and jump off the platform."
    },

    SELF_SHAMAN_ENHANCEMENT_SOLO = { 
        "Cast Feral Spirit and release the hounds.", 
        "Cast Crash Lightning and make a thunder noise.", 
        "Drop Windfury Totem and hit them faster.", 
        "Cast Stormstrike and hit them with the hammer.", 
        "Cast Ghost Wolf and awoo.",
        "Cast Lava Lash and whip it good.", 
        "Cast Ice Strike and hit them with a popsicle.", 
        "Cast Lightning Bolt instantly and zap.", 
        "Cast Chain Lightning instantly and fry the circuits.", 
        "Cast Flame Shock (or Voltaic Blaze) and apply the spice.",
        "Summon Earth Elemental and let the rock tank.", 
        "Cast Astral Shift and safety first.", 
        "Cast Healing Surge and heal yourself.", 
        "Cast Cleanse Spirit and wash up.", 
        "Cast Hex and turn them into a chicken.",
        "Cast Purge because that magic is yours.", 
        "Cast Spirit Walk and gotta go fast.", 
        "Cast Sundering and crack the earth open.", 
        "Cast Capacitor Totem and static shock.", 
        "Cast Ascendance and become the wind.", 
        "Cast Tempest and call down the thunder."
    },
    SELF_SHAMAN_ENHANCEMENT_GROUP = { 
        "Cast Sundering and crowd control the entire room by accident.", 
        "Cast Heroism before the pull starts.", 
        "Drop Tremor Totem just for fun.", 
        "Drop Wind Rush Totem and speed everyone off the cliff.", 
        "Forget to drop Windfury Totem entirely.",
        "Cast Crash Lightning and break the crowd control.", 
        "Cast Stormstrike and rip aggro from the tank.", 
        "Cast Lava Lash and spread flame to targets we aren't killing.", 
        "Cast Feral Spirit and let the dogs body pull.", 
        "Cast Wind Shear and interrupt the tank.",
        "Cast Purge instead of doing damage.", 
        "Cast Cleanse Spirit even though it's a DPS loss.", 
        "Summon Earth Elemental and taunt the boss to death.", 
        "Cast Capacitor Totem on the immune boss.", 
        "Cast Reincarnate and die again immediately.",
        "Cast Astral Shift and ignore the mechanic.", 
        "Cast Spirit Walk and run into the hole.", 
        "Cast Ascendance and blast the wrong target.", 
        "Cast Primordial Wave and lightning everywhere.", 
        "Cast Doom Winds and proc nothing."
    },

    SELF_SHAMAN_RESTORATION_SOLO = { 
        "Cast Healing Rain and take a shower.", 
        "Cast Spirit Link Totem on yourself to balance your own health.", 
        "Cast Water Walking and Jesus mode.", 
        "Cast Riptide and splash.", 
        "Cast Lava Burst and throw spicy water.",
        "Cast Healing Wave and take your time.", 
        "Cast Healing Surge and quick splash.", 
        "Cast Chain Heal and bounce it off yourself.", 
        "Cast Flame Shock and burn them.", 
        "Cast Lightning Bolt because you're a DPS now.",
        "Cast Ghost Wolf and be a dog.", 
        "Summon Earth Elemental and guard me rock.", 
        "Cast Astral Shift and hide.", 
        "Cast Purify Spirit and wash up.", 
        "Cast Hex and piggy time.",
        "Cast Purge and remove it.", 
        "Cast Spiritwalker's Grace and walk and cast.", 
        "Cast Capacitor Totem and zap.", 
        "Cast Unleash Life and empower yourself.", 
        "Cast Mana Tide Totem and free drinks for me.", 
        "Cast Surging Totem and make it rain."
    },
    SELF_SHAMAN_RESTORATION_GROUP = { 
        "Cast Spirit Link Totem on the tank when he's alone to kill him.", 
        "Cast Ancestral Protection Totem on the full HP DPS.", 
        "Cast Hex on the tank just to see if you can.", 
        "Cast Reincarnate alone after the wipe.", 
        "Cast Healing Rain where absolutely no one is standing.",
        "Cast Chain Heal on the full HP pet.", 
        "Cast Riptide and overwrite the one you just cast.", 
        "Cast Healing Tide Totem while you are silenced.", 
        "Cast Mana Tide Totem for the Rogue.", 
        "Cast Earth Shield on the Mage because he's squishy.",
        "Cast Water Shield and let them hit you for mana.", 
        "Cast Wind Shear? No, I'm a healer.", 
        "Cast Purify Spirit on the wrong debuff.", 
        "Summon Earth Elemental when the tank dies.", 
        "Cast Spiritwalker's Grace and cast while jumping.",
        "Cast Cloudburst Totem and forget to pop it.", 
        "Cast Primordial Wave and huge healing wave on one person.", 
        "Cast Ascendance and big heals at the wrong time.", 
        "Cast Tremor Totem after the fear ends.", 
        "Cast Downpour and make them wet."
    },

 -- =====================================================================
    -- WARLOCK
    -- =====================================================================
    SELF_WARLOCK_AFFLICTION_SOLO = { 
        "Cast Seed of Corruption and pop it like a balloon.", 
        "Cast Drain Soul and suck the life right out of them.", 
        "Cast Fear and watch them run away in terror.", 
        "Summon Voidwalker because who needs friends when you have a blueberry?", 
        "Cast Unending Breath and breathe underwater just because you can.",
        "Cast Agony and make them suffer.", 
        "Cast Wither (or Corruption) and let them rot from the inside out.", 
        "Cast Unstable Affliction because I dare you to dispel me.", 
        "Cast Malefic Rapture and pop all your dots at once.", 
        "Cast Shadow Bolt because it's filler but it looks cool.",
        "Cast Health Funnel and sacrifice your own blood to heal your pet.", 
        "Create Healthstone and have a piece of candy.", 
        "Cast Soulstone because cheating death is a hobby.", 
        "Cast Burning Rush and hurt yourself to go fast.", 
        "Cast Dark Pact and make a shield out of blood.",
        "Cast Demonic Circle and teleport away from your problems.", 
        "Cast Demonic Gateway and make a portal to nowhere.", 
        "Cast Curse of Weakness because they look tired.", 
        "Cast Curse of Tongues and make them speak demonic.", 
        "Cast Cull the Weak and finish them off."
    },
    SELF_WARLOCK_AFFLICTION_GROUP = { 
        "Cast Fear on the mob and send it directly into the next pack.", 
        "Cast Soulstone on yourself because you are the only one who matters.", 
        "Cast Health Funnel and die while trying to keep your pet alive.", 
        "Cast Ritual of Summoning and go AFK while they click.",
        "Cast Seed of Corruption and break every crowd control effect in range.", 
        "Cast Unstable Affliction and kill the healer when they dispel it.", 
        "Cast Drain Soul and snipe the kill so you get the shard.", 
        "Cast Agony and pad the meters on targets that don't matter.", 
        "Cast Malefic Rapture with zero shards just to see what happens.",
        "Summon Imp because we need more DPS so forget the utility.", 
        "Create Healthstone but they won't take one anyway.", 
        "Cast Burning Rush and give the healer a heart attack.", 
        "Cast Dark Pact and ignore the mechanics because you have a shield.",
        "Cast Demonic Circle but realize you put it out of range.", 
        "Cast Demonic Gateway and place it directly into a wall.", 
        "Cast Shadowfury and miss the stun completely.", 
        "Cast Mortal Coil and fear the kill target away from the melee.", 
        "Cast Curse of Tongues and make the boss speak Common.", 
        "Cast Malevolence and embrace the void.", 
        "Cast Soul Rot and wither everything in sight."
    },

    SELF_WARLOCK_DEMONOLOGY_SOLO = { 
        "Cast Implosion and boom goes the imp.", 
        "Summon Felguard because he is your big strong bodyguard.", 
        "Cast Hand of Gul'dan and drop a meteor on their head.", 
        "Cast Demonic Circle because you'll be right back.", 
        "Cast Eye of Kilrogg and spy on the neighbors.",
        "Cast Shadow Bolt and throw a little ball of hate.", 
        "Cast Demonbolt and throw a big ball of hate.", 
        "Cast Call Dreadstalkers and release the hounds.", 
        "Cast Summon Vilefiend and spit on them.", 
        "Cast Demonic Strength and spin to win.",
        "Cast Health Funnel and command your minion to live.", 
        "Create Healthstone and eat a little green snack.", 
        "Cast Soulstone and buy an insurance policy.", 
        "Cast Burning Rush because your feet are on fire.", 
        "Cast Dark Pact and stay safe in your bubble.",
        "Cast Fear and call them a coward.", 
        "Cast Axe Toss and stun them with a weapon.", 
        "Cast Power Siphon and eat your friends for power.", 
        "Cast Grimoire: Felguard and summon the big brother.", 
        "Cast Diabolic Ritual and summon a demon lord."
    },
    SELF_WARLOCK_DEMONOLOGY_GROUP = { 
        "Cast Implosion on the pull and sacrifice your DPS for a visual effect.", 
        "Cast Banish on the add and remove it from the game for a bit.", 
        "Cast Ritual of Doom and dare someone to click it.", 
        "Cast Soulstone on the AFK player because they need it most.",
        "Cast Hand of Gul'dan with zero shards.", 
        "Cast Call Dreadstalkers and watch them pull the boss.", 
        "Cast Demonic Strength and let your Felguard spin in the wrong direction.", 
        "Summon Felguard and let him generate more threat than the tank.", 
        "Cast Demonbolt and hard cast it while ignoring the procs.",
        "Create Healthstone because the well is up and they need cookies.", 
        "Cast Ritual of Summoning but don't click it yourself.", 
        "Cast Burning Rush and race the tank to the next pack.", 
        "Cast Dark Pact and soak the one-shot mechanic.", 
        "Cast Demonic Circle and reset the boss by accident.",
        "Cast Demonic Gateway and troll the raid by placing it off a cliff.", 
        "Cast Axe Toss and interrupt the spell that already cast.", 
        "Cast Fear and scatter the mobs to the four winds.", 
        "Cast Curse of Weakness and pretend you're helping the tank.", 
        "Cast Power Siphon and sacrifice your demons right before the burst window.", 
        "Cast Summon Demonic Tyrant and look at the size of that lad."
    },

    SELF_WARLOCK_DESTRUCTION_SOLO = { 
        "Cast Chaos Bolt and obliterate that rat.", 
        "Cast Rain of Fire and make it rain hell.", 
        "Cast Cataclysm and break the world.", 
        "Cast Havoc on the empty air and double the nothing.", 
        "Summon Infernal and drop a rock on them.",
        "Cast Immolate (or Wither) and burn baby burn.", 
        "Cast Conflagrate and pop the blister.", 
        "Cast Incinerate and just use regular fire.", 
        "Cast Shadowburn and snipe the low health ones.", 
        "Channel Demonfire and shoot lazors everywhere.",
        "Cast Health Funnel and heal the pet because you have HP to spare.", 
        "Create Healthstone and it's cookie time.", 
        "Cast Soulstone and save yourself.", 
        "Cast Burning Rush because speed is life.", 
        "Cast Dark Pact and absorb the pain.",
        "Cast Fear and look at them run.", 
        "Cast Shadowfury and stun them all.", 
        "Cast Demonic Circle and port away.", 
        "Cast Demonic Gateway and jump through space.", 
        "Cast Dimensional Rift and open portals to nowhere."
    },
    SELF_WARLOCK_DESTRUCTION_GROUP = { 
        "Cast Shadowfury and miss every single mob.", 
        "Cast Rain of Fire on a single target because it looks cool.", 
        "Cast Fear and send the mob running into another group.", 
        "Cast Ritual of Summoning and don't you dare click it.",
        "Cast Chaos Bolt and pull aggro from the tank with one shot.", 
        "Cast Havoc and break the sheep instantly.", 
        "Cast Cataclysm and pull everything in the room.", 
        "Summon Infernal for maximum screen clutter.", 
        "Cast Immolate and apply it right before the mob dies.",
        "Cast Conflagrate and slow them down for no reason.", 
        "Create Healthstone and eat it while at full health.", 
        "Cast Soulstone and save it for the healer or just yourself.", 
        "Cast Burning Rush and commit suicide by fire.", 
        "Cast Dark Pact and cheese the mechanic.",
        "Cast Demonic Circle and find your safe spot.", 
        "Cast Demonic Gateway because a cliff looks like a nice destination.", 
        "Cast Mortal Coil to heal yourself and fear the target.", 
        "Cast Banish and banish the tank if you can.", 
        "Cast Curse of Exhaustion and make them walk slow.", 
        "Cast Ruination and drop a meteor on the tank."
    },

    -- =====================================================================
    -- WARRIOR
    -- =====================================================================
    SELF_WARRIOR_ARMS_SOLO = { 
        "Cast Bladestorm and spin to win.", 
        "Cast Heroic Leap and jump to the moon.", 
        "Cast Execute and chop their head off.", 
        "Cast Die by the Sword because you are the master of parrying.", 
        "Cast Charge and go in headfirst.",
        "Cast Mortal Strike and apply that healing reduction to the air.", 
        "Cast Overpower because you cannot be dodged.", 
        "Cast Slam and use your rage to bonk them.", 
        "Cast Colossus Smash and break their armor into pieces.", 
        "Cast Sweeping Strikes and hit two things at once.",
        "Cast Victory Rush because you won so have a snack.", 
        "Cast Hamstring and cut their ankles.", 
        "Cast Pummel and punch them in the throat.", 
        "Cast Storm Bolt and throw your hammer at their face.", 
        "Cast Intimidating Shout and yell at them until they run away.",
        "Cast Spell Reflection and say 'No u' to the magic.", 
        "Cast Berserker Rage and get angry for absolutely no reason.", 
        "Cast Rallying Cry and pretend you have friends to save.", 
        "Cast Piercing Howl and make their ears bleed.", 
        "Cast Demolish and crush them beneath your boots."
    },
    SELF_WARRIOR_ARMS_GROUP = { 
        "Cast Bladestorm and spin right through the crowd control.", 
        "Cast Intimidating Shout and fear the pack into the next group.", 
        "Cast Intervene on the dead body to protect it.", 
        "Cast Taunt on the boss because you can surely take a hit.",
        "Cast Mortal Strike and stop the healer from healing.", 
        "Cast Execute and steal the kill from the Rogue.", 
        "Cast Colossus Smash and burst damage on the immune phase.", 
        "Cast Sweeping Strikes and hit the sheep by accident.", 
        "Cast Die by the Sword and look at me because I'm the tank now.",
        "Cast Heroic Leap behind a pillar and Line of Sight the healer.", 
        "Cast Charge directly into the fire patch.", 
        "Cast Pummel and interrupt the spell the tank was going to kick.", 
        "Cast Storm Bolt and try to stun the raid boss.", 
        "Cast Spell Reflection and try to reflect the physical damage.",
        "Cast Rallying Cry after everyone is dead.", 
        "Cast Berserker Rage when you aren't even feared.", 
        "Cast Victory Rush but oh wait you haven't killed anything.", 
        "Cast Slam and dump all your rage into a shield.", 
        "Cast Avatar and become big to block the camera.", 
        "Cast Thunder Clap and pull aggro from the tank."
    },

    SELF_WARRIOR_FURY_SOLO = { 
        "Cast Rampage and go absolutely feral.", 
        "Cast Whirlwind and become a blender.", 
        "Cast Heroic Leap and jump for joy.", 
        "Cast Enraged Regeneration and heal through the pain.", 
        "Cast Piercing Howl and slow everyone down.",
        "Cast Bloodthirst and drink their blood.", 
        "Cast Raging Blow and smack them with both weapons.", 
        "Cast Execute and off with their heads.", 
        "Cast Slam because why is this even on your bar?", 
        "Cast Charge and zoom zoom.",
        "Cast Victory Rush and take the free health.", 
        "Cast Hamstring and trip them up.", 
        "Cast Pummel and face punch.", 
        "Cast Storm Bolt and bonk them.", 
        "Cast Intimidating Shout and scatter the rats.",
        "Cast Spell Reflection and reflect the silence.", 
        "Cast Berserker Rage and grrrr.", 
        "Cast Rallying Cry and command the empty room.", 
        "Cast Intervene and dash to your imaginary friend.", 
        "Cast Odyn's Fury and explode with fire."
    },
    SELF_WARRIOR_FURY_GROUP = { 
        "Cast Heroic Leap into the pack to start the pull.", 
        "Stand in the fire because it probably generates Rage.", 
        "Pop Recklessness on a single trash mob.", 
        "Cast Intimidating Shout and fear the mobs everywhere.",
        "Cast Rampage and generate so much threat you die.", 
        "Cast Whirlwind and AoE the single target boss.", 
        "Cast Bloodthirst because you don't need a healer.", 
        "Cast Execute and pad the meters on the add.", 
        "Cast Enraged Regeneration and solo the boss while the tank is dead.",
        "Cast Charge and face pull the patrol.", 
        "Cast Heroic Leap directly into the cleave zone.", 
        "Cast Pummel and miss the kick.", 
        "Cast Storm Bolt and stun the immune target.", 
        "Cast Spell Reflection and reflect the auto attack.",
        "Cast Rallying Cry and save it for the next expansion.", 
        "Cast Intimidating Shout and make the tank chase them.", 
        "Cast Intervene on the tank and take the tank buster.", 
        "Cast Avatar and make yourself a bigger target.", 
        "Cast Thunder Blast and call down the lightning.", 
        "Cast Onslaught and enrage yourself."
    },

    SELF_WARRIOR_PROTECTION_SOLO = { 
        "Cast Shield Slam and break their jaw.", 
        "Cast Thunder Clap and make some noise.", 
        "Cast Shield Wall and increase your health because you are invincible.", 
        "Cast Last Stand and refuse to die today.", 
        "Cast Charge and get in there.",
        "Cast Revenge and it's payback time.", 
        "Cast Devastate and poke them with your sword.", 
        "Cast Execute and finish the job.", 
        "Cast Shield Block and raise the shield.", 
        "Cast Ignore Pain because it's just a flesh wound.",
        "Cast Victory Rush and winner winner.", 
        "Cast Hamstring and drag them down.", 
        "Cast Pummel and shield bash.", 
        "Cast Storm Bolt and sit down.", 
        "Cast Intimidating Shout and roar like a lion.",
        "Cast Spell Reflection because magic is for nerds.", 
        "Cast Berserker Rage and be an angry tank.", 
        "Cast Rallying Cry and rally yourself.", 
        "Cast Intervene and dash to the vendor.", 
        "Cast Ravager and throw your weapon at them."
    },
    SELF_WARRIOR_PROTECTION_GROUP = { 
        "Cast Heroic Throw on the boss to start the fight early.", 
        "Cast Intervene on the healer and cleave them.", 
        "Cast Shockwave and stun the air behind you.", 
        "Cast Spell Reflection and try to reflect the melee swing.",
        "Cast Shield Slam and take aggro from the other tank.", 
        "Cast Thunder Clap and break the CC nearby.", 
        "Cast Shield Block but forget to press it.", 
        "Cast Ignore Pain because you are rage starved.", 
        "Cast Last Stand at 90% health.",
        "Cast Shield Wall on the trash pack.", 
        "Cast Revenge and spam it instead of mitigation.", 
        "Cast Devastate because pressing buttons is fun.", 
        "Cast Taunt and play ping pong with the boss.", 
        "Cast Charge around the corner.",
        "Cast Heroic Leap away from the mobs.", 
        "Cast Pummel and interrupt the spell that does no damage.", 
        "Cast Storm Bolt and stun the add that is dying.", 
        "Cast Demoralizing Shout and make them sad.", 
        "Cast Avatar and look at me because I am the boss now.", 
        "Cast Challenging Shout and hit the suicide button."
    },

    -- =====================================================================
    -- GENERAL FALLBACKS (Used if spec detection fails)
    -- =====================================================================
    SELF_PRIEST_SOLO = { 
        "Cast Levitate. The ground is too dirty for you.", 
        "Mind Control the enemy. Make them jump off a cliff.", 
        "Smite them. You are the judge and jury.", 
        "Heal yourself. You are the only one who matters.", 
        "Fade. Disappear from your responsibilities.",
        "Power Word: Shield. Protect your fragile ego.", 
        "Psychic Scream. Yell at the clouds.", 
        "Holy Fire. Burn the evidence.", 
        "Shadow Word: Pain. Share your feelings.", 
        "Penance. Forgive yourself, punish them."
    }, 
    SELF_PRIEST_GROUP = { 
        "Life Grip the tank. Pull him back, he's going too fast.", 
        "Stop healing. Let them appreciate you more.", 
        "Mass Dispel. Remove the tank's defensive cooldowns.", 
        "Power Infusion. Sell it to the highest bidder.", 
        "Resurrection. Cast it while the boss is still alive.",
        "Leap of Faith. Drag the Rogue into the fire.", 
        "Shackle Undead. Try to CC the Death Knight.", 
        "Dispel Magic. Remove the helpful buffs by mistake.", 
        "Mind Soothe. Calm down the raging tank.", 
        "Psychic Scream. Scatter the pack for fun."
    },

    SELF_MAGE_SOLO = { 
        "Blink forward. Directly into a wall.", 
        "Cast Slow Fall. Jump off the highest point you can find.", 
        "Fireball. It's the answer to everything.", 
        "Frostbolt. Chill out.", 
        "Polymorph. Turn that threat into a sheep.",
        "Ice Block. Become a statue of yourself.", 
        "Invisibility. Run away from the fight.", 
        "Cone of Cold. Freeze the air.", 
        "Arcane Explosion. Be a melee mage.", 
        "Conjure Food. Have a picnic."
    }, 
    SELF_MAGE_GROUP = { 
        "Cast a Portal. Make it lead to Ancient Dalaran.", 
        "Time Warp. Use it on the very first trash pack.", 
        "Conjure Refreshment Table. Eat alone while they fight.", 
        "Counterspell. Interrupt the tank's pull.", 
        "Ice Block. Watch the group wipe from inside your cube.",
        "Spellsteal. Take all the buffs, leave none for them.", 
        "Remove Curse. Pretend you don't know how.", 
        "Polymorph the kill target. Heal it to full.", 
        "Blink into the mechanic. Test the healer's reflexes.", 
        "Mirror Image. Confuse the tank."
    },

    SELF_HUNTER_SOLO = { 
        "Do a 360 jump shot. Style points matter.", 
        "Feign Death. Take a nap right here.", 
        "Tame Beast. You need another pet, surely.", 
        "Lay a Trap. Catch a tiger by the toe.", 
        "Feed Pet. It looks hungry.",
        "Disengage. Backflip off the edge.", 
        "Arcane Shot. Pew pew.", 
        "Eagle Eye. Spy on people in the next zone.", 
        "Aspect of the Cheetah. Run fast, take more damage.", 
        "Flare. Light up the darkness."
    }, 
    SELF_HUNTER_GROUP = { 
        "Misdirection. Put it on the healer.", 
        "Barrage. Pull everything in the dungeon.", 
        "Aspect of the Pack. Daze the entire group. (I wish).", 
        "Bloodlust. Use it now. Why wait?", 
        "Play Dead. Drop all aggro onto the Warlock.",
        "Multi-Shot. Break the crowd control.", 
        "Freezing Trap. Trap the boss.", 
        "Intimidation. Stun the add that is immune.", 
        "Revive Pet. Do it during the wipe.", 
        "Fetch. Tell your pet to loot for you."
    },

    SELF_ROGUE_SOLO = { 
        "Stealth. Sneak past your problems.", 
        "Sprint. Run circles around the enemy.", 
        "Pick Pocket. Steal their lunch money.", 
        "Vanish. Ghost the situation.", 
        "Backstab. It's the only way.",
        "Sap. Knock them out cold.", 
        "Blind. Throw sand in their eyes.", 
        "Evasion. You can't touch this.", 
        "Slice and Dice. Faster.", 
        "Cheap Shot. Fight dirty."
    }, 
    SELF_ROGUE_GROUP = { 
        "Vanish. Reset the boss, I didn't like that pull.", 
        "Tricks of the Trade. Kill the Mage.", 
        "Shroud of Concealment. Skip the trash, trigger the trap.", 
        "Kick. Interrupt the air.", 
        "Blind. CC the healer for fun.",
        "Sprint. Run ahead and pull for the tank.", 
        "Cloak of Shadows. Soak the one-shot mechanic.", 
        "Distract. Turn the boss around.", 
        "Feint. Pretend to take damage.", 
        "Shiv. Poke the enraged bear."
    },

    SELF_WARLOCK_SOLO = { 
        "Drain Soul. Their soul is yours.", 
        "Use your Healthstone. Tasty snack.", 
        "Fear. Watch them run.", 
        "Summon Demon. You need a friend.", 
        "DoT everything. Spread the infection.",
        "Life Tap. Hurt yourself for mana.", 
        "Unending Breath. Breathe underwater.", 
        "Eye of Kilrogg. Spy on the loot.", 
        "Shadow Bolt. Throw shadow at them.", 
        "Curse of Weakness. Mock their strength."
    }, 
    SELF_WARLOCK_GROUP = { 
        "Ritual of Summoning. Make them click.", 
        "Summon Imp. We need the stamina buff (wait, wrong expansion).", 
        "Create Soulwell. Force feed them candy.", 
        "Demonic Gateway. Place it off a cliff.", 
        "Banish. Remove the tank's target.",
        "Soulstone. Put it on yourself, you are the carry.", 
        "Fear. Scatter the pack to the four winds.", 
        "Shadowfury. Stun the team.", 
        "Health Funnel. Heal your pet, ignore the boss.", 
        "Curse of Tongues. Make the boss speak gibberish."
    },

    SELF_WARRIOR_SOLO = { 
        "Heroic Leap. Jump good.", 
        "Whirlwind. Spin to win.", 
        "Charge. Head first.", 
        "Slam. Bonk.", 
        "Shout. Loud noises.",
        "Execute. Finish them.", 
        "Victory Rush. Free health.", 
        "Hamstring. Cut them down.", 
        "Thunder Clap. Make it rain.", 
        "Shield Block. Pretend you have a shield."
    }, 
    SELF_WARRIOR_GROUP = { 
        "Taunt. Ping pong the boss.", 
        "Intimidating Shout. Fear the mobs into the next room.", 
        "Rallying Cry. Use it when everyone is dead.", 
        "Intervene. Dash to the corpse.", 
        "Smash. Hit the buttons harder.",
        "Spell Reflection. Reflect the silence.", 
        "Berserker Rage. Get angry at the healer.", 
        "Heroic Throw. Pull the boss early.", 
        "Pummel. Miss the kick.", 
        "Bladestorm. Spin away from the group."
    },

    SELF_PALADIN_SOLO = { 
        "Divine Shield. Can't touch this.", 
        "Summon Charger. Look at my horse.", 
        "Flash of Light. Sparkle heal.", 
        "Smite? No, Judgment.", 
        "Avenging Wrath. Pop wings.",
        "Hammer of Justice. Stop.", 
        "Consecration. The floor is holy.", 
        "Crusader Strike. Hit them.", 
        "Lay on Hands. Save yourself.", 
        "Redemption. Wake up."
    }, 
    SELF_PALADIN_GROUP = { 
        "Blessing of Protection. Drop the tank's aggro.", 
        "Hand of Freedom. Let the enemy run.", 
        "Lay on Hands. Heal yourself at 90%.", 
        "Devotion Aura. Armor is boring.", 
        "Redemption. Combat rez the pet.",
        "Divine Shield. Drop aggro and wipe the group.", 
        "Blessing of Sacrifice. Kill yourself for the rogue.", 
        "Cleanse. Dispel the wrong thing.", 
        "Hammer of Justice. Stun the immune boss.", 
        "Divine Steed. Run into the wall."
    },

    SELF_DRUID_SOLO = { 
        "Flight Form. Be a bird.", 
        "Moonfire. Laser beams.", 
        "Cat Form. Be sneaky.", 
        "Bear Form. Be tough.", 
        "Regrowth. Lick your wounds.",
        "Travel Form. Run away.", 
        "Entangling Roots. Stay.", 
        "Wrath. Solar power.", 
        "Swipe. Scratch them.", 
        "Dash. Zoom."
    }, 
    SELF_DRUID_GROUP = { 
        "Typhoon. Knock them out of the AoE.", 
        "Rebirth. Rez the AFK player.", 
        "Innervate. Use it on the Rogue.", 
        "Stampeding Roar. Run into the fire.", 
        "Soothe. Calming vibes only.",
        "Cyclone. CC the kill target.", 
        "Ursol's Vortex. Annoy the tank.", 
        "Tranquility. It's too quiet.", 
        "Growl. Steal aggro in cat form.", 
        "Barkskin. Save yourself."
    },

    SELF_SHAMAN_SOLO = { 
        "Ghost Wolf. Run like a dog.", 
        "Water Walking. Jesus mode.", 
        "Lightning Bolt. Zap.", 
        "Drop a Totem. Any totem.", 
        "Healing Surge. Splash water.",
        "Flame Shock. Fire burn.", 
        "Earth Shock. Rock throw.", 
        "Frost Shock. Chill.", 
        "Astral Shift. Panic button.", 
        "Hex. Frog time."
    }, 
    SELF_SHAMAN_GROUP = { 
        "Heroism. Use it on the trash.", 
        "Hex. CC the tank.", 
        "Purge. Remove the buffs, all of them.", 
        "Spirit Link Totem. Share the pain.", 
        "Reincarnate. Stand up and die again.",
        "Wind Shear. Interrupt nothing.", 
        "Tremor Totem. Drop it for no reason.", 
        "Earth Elemental. Let the rock tank.", 
        "Ancestral Spirit. Rez them slow.", 
        "Bloodlust. Screaming helps."
    },

    SELF_DEATHKNIGHT_SOLO = { 
        "Path of Frost. Ice skating time.", 
        "Death Grip. Get over here.", 
        "Death Strike. Heal me.", 
        "Raise Dead. Rise, minion.", 
        "Runeforging. Sharpen the sword.",
        "Chains of Ice. Freeze.", 
        "Mind Freeze. Shhh.", 
        "Anti-Magic Shell. Green bubble.", 
        "Wraith Walk. Float away.", 
        "Dark Command. Look at me."
    }, 
    SELF_DEATHKNIGHT_GROUP = { 
        "Dark Command. I am the tank now.", 
        "Army of the Dead. Lag the server.", 
        "Death Grip. Pull the mob to the healer.", 
        "Raise Ally. Rez the pet.", 
        "Anti-Magic Shell. Ignore the mechanic.",
        "Control Undead. Tame the elite.", 
        "Gorefiend's Grasp. Group hug.", 
        "Asphyxiate. Choke them.", 
        "Path of Frost. Kill the raid on the jump.", 
        "Icebound Fortitude. I feel nothing."
    },

    SELF_DEMONHUNTER_SOLO = { 
        "Glide. Never touch the ground.", 
        "Fel Rush. Zoom.", 
        "Double Jump. Parkour.", 
        "Eye Beam. Laser eyes.", 
        "Spectral Sight. I see you.",
        "Metamorphosis. Big demon energy.", 
        "Throw Glaive. Catch.", 
        "Immolation Aura. Fire walk.", 
        "Consume Magic. Nom nom.", 
        "Torment. Taunt."
    }, 
    SELF_DEMONHUNTER_GROUP = { 
        "Imprison. Lock them up.", 
        "The Hunt. Charge the wrong target.", 
        "Darkness. Hide in the cloud.", 
        "Torment. Fight the tank.", 
        "Chaos Nova. Stun the team.",
        "Blur. Tank mode activated.", 
        "Netherwalk. Ghost mode.", 
        "Fel Eruption. Pop.", 
        "Vengeful Retreat. Backflip into danger.", 
        "Glide. Float over the mechanics."
    },

    SELF_EVOKER_SOLO = { 
        "Soar. Fly away.", 
        "Tail Swipe. Spin move.", 
        "Deep Breath. Burn the path.", 
        "Hover. Float around.", 
        "Living Flame. Heal or harm?",
        "Azure Strike. Poke.", 
        "Disintegrate. Laser beam.", 
        "Obsidian Scales. Armor up.", 
        "Emerald Blossom. Flower power.", 
        "Quell. Silence."
    }, 
    SELF_EVOKER_GROUP = { 
        "Rescue. Kidnap the tank.", 
        "Fury of the Aspects. Lust now.", 
        "Oppressing Roar. Yell at them.", 
        "Cauterizing Flame. Dispel nothing.", 
        "Time Spiral. Speed up.",
        "Rewind. Undo the damage.", 
        "Zephyr. Dodge.", 
        "Landslide. Root them.", 
        "Sleep Walk. Nap time.", 
        "Tip the Scales. Instant regret."
    },

    SELF_MONK_SOLO = { 
        "Roll. Keep rolling.", 
        "Leg Sweep. Trip them.", 
        "Tiger Palm. Slap.", 
        "Touch of Death. Pop.", 
        "Zen Pilgrimage. Go home.",
        "Flying Serpent Kick. Zoom.", 
        "Vivify. Bandage.", 
        "Paralysis. Poke.", 
        "Fortifying Brew. Drink up.", 
        "Crackling Jade Lightning. Zzzzt."
    }, 
    SELF_MONK_GROUP = { 
        "Ring of Peace. Bounce them away.", 
        "Provoke. Taunt the boss.", 
        "Life Cocoon. Bubble boy.", 
        "Paralysis. CC the tank's target.", 
        "Detox. Cleanse.",
        "Revival. Mass dispel the raid.", 
        "Transcendence. Teleport into fire.", 
        "Spear Hand Strike. Chop.", 
        "Zen Meditation. Tank the big hit.", 
        "Touch of Karma. Die anyway."
    },
    -- =====================================================================
    -- GENERAL CATEGORIES
    -- =====================================================================
    ELITE_SOLO = { 
        "Go ahead and solo it because you are the main character.", 
        "Kite it all the way to the capital city and cause a panic.", 
        "It's just a loot piñata so hit it until candy comes out.", 
        "Do you hear that? The boss music is playing for you.", 
        "Stand in the bad stuff because it probably buffs you.",
        "You can take him so I don't see why you're hesitating.", 
        "Use all your cooldowns at once and panic immediately.", 
        "Do you really need a potion? Save it for later just in case.", 
        "Run away and leave your dignity behind!", 
        "It sees you so just freeze and pretend you're a statue.",
        "Just pull and pray because it works every time.", 
        "Go touch it and see what happens.", 
        "Take a selfie with the angry monster before it eats you.", 
        "Is it a rare spawn? Kill it immediately before someone else does.", 
        "Mount up and run circles around it to confuse the AI.",
        "Charge in because glory awaits the bold.", 
        "Try to stealth and maybe it won't notice you aren't a Rogue.", 
        "Ask general chat for help because they are always so nice.", 
        "Invite a friend and share the pain.", 
        "Just poke it with a stick and see if it's angry."
    },
    ELITE_GROUP = { 
        "Pull it before the tank gets there and be a hero.", 
        "Taunt the boss and assert your dominance.", 
        "Stand in the cleave because it tickles.", 
        "Roll Need on the loot because you need the gold.", 
        "Misdirect the healer because it's just a prank.",
        "Go AFK and just auto-attack because no one will know.", 
        "Stand in the fire because it increases your DPS.", 
        "Blame the lag if you die.", 
        "Is this a DPS check? Because you are failing it.", 
        "Check everyone's parses right now and judge them.",
        "Inspect the tank's gear and judge him silently.", 
        "Whisper the boss and tell him his secrets.", 
        "Dance in the middle of the fight to boost morale.", 
        "Jump repeatedly because it helps you dodge.", 
        "Use a toy like the Train Set because everyone loves that.",
        "Pull more mobs because the tank is too slow.", 
        "This is a speed run now so go fast.", 
        "Skip this pack because what could go wrong?", 
        "Kill the adds and ignore the boss.", 
        "Focus the boss and ignore the adds."
    },
    TARGET_CORPSE = { 
        "Crouch repeatedly because it is the custom.", 
        "Jump on the body because it makes a funny sound.", 
        "Poke it with a stick and check if it's really dead.", 
        "Loot it fast before it despawns and you lose the copper.", 
        "Rest in pieces, friend.", 
        "Can we keep the skull? I want the skull.",
        "I wonder if we can eat it.", 
        "Take a selfie with the victim to remember the moment.", 
        "Mourn the fallen and cry loudly in chat.", 
        "Laugh at their misfortune because you survived.",
        "Spit on the ground because they were disrespectful.", 
        "Dance on their grave and celebrate life.", 
        "Sit on their face to assert dominance.", 
        "Sleep next to them because it's nap time.", 
        "Kick it just to be sure it's not faking.",
        "Can you revive it? Try to revive it for round two.", 
        "Bury it in the backyard.", 
        "It's floating so physics is clearly a lie.", 
        "It's starting to stink so walk away.", 
        "Jump up and down on the corpse to flatten it."
    },
    COMBAT_START = { 
        "Pull the other group too because we need more excitement.", 
        "Stop attacking and become a pacifist right now.", 
        "Peace was never an option so destroy them.", 
        "Sit down and try to drink water mid-fight.",
        "Did you remember to eat? No? Starve then.", 
        "You are wearing the wrong gear set and you look foolish.", 
        "You forgot your buffs so you're basically naked.", 
        "Do you have reagents? Probably not.", 
        "Lag. It's definitely lag.",
        "Panic and press every button at once.", 
        "Mash the keyboard with your forehead for maximum DPS.", 
        "Roll your face across the keys.", 
        "Click your spells. Do it. Click them.", 
        "Keyboard turn slowly to the left.",
        "Turn your monitor off and use the force.", 
        "Put the cat on the keyboard and let him play.", 
        "Answer that phone call because it's important.", 
        "The doorbell is ringing so go check it.", 
        "Sneeze during the important mechanic.", 
        "Blink and you'll miss the wipe."
    },
    AFK = { 
        "Just Alt-F4 and be free.", 
        "Delete your Hearthstone because you live here now.", 
        "Wait for the disconnect timer and stare at the screen.",
        "Go make some coffee because they can wait.", 
        "Bathroom break time so take your time.", 
        "Go walk the dog because nature calls.", 
        "Take a nap because you look tired.", 
        "Read a book and expand your mind.",
        "Watch a movie on the second monitor.", 
        "Play a different game entirely.", 
        "Go touch grass outside.", 
        "Call your mom because she misses you.", 
        "Go cook a five-course dinner.",
        "Do your laundry because you smell.", 
        "Do the dishes because they are piling up.", 
        "Take out the trash and be useful.", 
        "Go shopping and buy things you don't need.", 
        "Go to work because real life calls.", 
        "Contemplate your life choices.", 
        "Do you even exist?"
    },
    CRAFTING = { 
        "Vendor it because the auction house is too much work.", 
        "Click 'Craft All' and walk away for an hour.", 
        "Disenchant your weapon. Do it.",
        "Is there a fail chance? I hope so.", 
        "Skill up on the most expensive recipe to show off.", 
        "Waste your materials because you have plenty.", 
        "That is too expensive to make but do it anyway.", 
        "This item is useless so make ten of them.",
        "Sell it on the Auction House for 1 copper.", 
        "Mail it to your alt and forget about it forever.", 
        "Destroy the item because it brings you joy.", 
        "Hoard the materials and never use them.", 
        "Put it in the bank and let it rot.",
        "You made the wrong item but good job.", 
        "You have too many of these so make more.", 
        "Your bags are full so panic.", 
        "Lag is making you craft slower.", 
        "Cancel the craft and stop.", 
        "Stop crafting because it's boring.", 
        "This is boring so do something else."
    },
    BANK = { 
        "Fill your bank with grey rocks.", 
        "Delete all your gear sets and start over.", 
        "Deposit your Hearthstone and never go home.",
        "Clean your bags and throw everything away.", 
        "Sort your items by color.", 
        "Hoard that trash because it might be useful one day.", 
        "Your slots are full so buy more.", 
        "Buy all the bank slots and spend your gold.",
        "Put everything in the Reagent Bank.", 
        "Deposit all your gold and be poor.", 
        "Withdraw all your gold and be rich.", 
        "Steal from the guild bank? No, just kidding... unless?", 
        "Organize everything perfectly.",
        "Your bank is a mess so just close it.", 
        "I think you lost an item in here.", 
        "Oh, you found that old item.", 
        "Look at that old gear and feel the nostalgia.", 
        "Nostalgia is a trap.", 
        "Delete everything.", 
        "Close the window because it's too stressful."
    },
    QUEUE_POP = { 
        "Decline the queue and make them wait.", 
        "Accept the queue then go AFK immediately.", 
        "Wait until the last second to accept.",
        "Panic because you aren't ready.", 
        "You are in the wrong spec so accept anyway.", 
        "You are wearing your fishing gear but who cares.", 
        "You are not prepared.", 
        "Decline. Do it.",
        "Accept and let's go.", 
        "Enter the dungeon.", 
        "Leave the queue and be free.", 
        "Did you queue as Tank? I hope not.", 
        "Did you queue as Healer? Good luck.", 
        "Did you queue as DPS? Enjoy the wait.",
        "That was a long wait.", 
        "That was an instant pop so it's suspicious.", 
        "Surprise! You found a group.", 
        "Are you scared? You should be.", 
        "Are you happy? You shouldn't be.", 
        "This is going to be boring."
    },
    READY_CHECK = { 
        "Click 'No' and be that guy.", 
        "Pretend you know the tactics and lie.", 
        "Stay AFK until the timer runs out.",
        "You are not ready.", 
        "You are ready. Or are you?", 
        "Start cooking dinner.", 
        "Start eating loudly into the mic.", 
        "Take a drink.",
        "Go to the toilet right now.", 
        "Look at your phone.", 
        "Check Discord.", 
        "Change your song on Spotify.", 
        "Watch a Youtube video.",
        "Alt-tab out of the game.", 
        "Stare at the loading screen.", 
        "Pray for a crash.", 
        "Lag out on purpose.", 
        "Type 'r' in chat but don't click ready.", 
        "Ignore the check.", 
        "Go back to sleep."
    },
    RESURRECT = { 
        "Decline the rez and sleep a bit longer.", 
        "Wait for a mass rez because you are special.", 
        "Take rez sickness because walking is for peasants.",
        "Release to the Spirit Healer.", 
        "Run back because it's good exercise.", 
        "Do the walk of shame.", 
        "You are lost so where is your body?", 
        "You are stuck so unstuck me.",
        "Accept the rez and live again.", 
        "Say thank you and be polite.", 
        "You have no mana so drink.", 
        "You need to rebuff so do it.", 
        "Eat some food.",
        "Drink some water.", 
        "You need to repair your armor.", 
        "Ask for a summon and be lazy.", 
        "Ask for a portal.", 
        "Hearthstone out of there.", 
        "Logout because you're done.", 
        "Cry in the corner."
    },
    DUEL = { 
        "Type /yield immediately and confuse them.", 
        "Run out of bounds and waste their time.", 
        "Type /sleep and disrespect them.",
        "Accept the duel and destroy them.", 
        "Decline the duel because they aren't worth it.", 
        "Spam emotes at them.", 
        "Take off all your gear and fight naked.", 
        "Only use punches.",
        "Kite them forever.", 
        "Line of Sight them behind a tree.", 
        "Hide in a bush.", 
        "Cheat and use everything.", 
        "Drink potions because it's allowed.",
        "Steal their buffs.", 
        "Pop all your cooldowns instantly.", 
        "Lag and blame lag.", 
        "You are going to lose.", 
        "You are going to win.", 
        "It's a draw.", 
        "Challenge them to a rematch."
    },
    VANITY = { 
        "Your character is ugly so fix it.", 
        "Hide your helm and show your face.", 
        "Transmog everything into low level greens.",
        "Change your hair color.", 
        "Change your face.", 
        "Change your race and become a gnome.", 
        "Change your gender.", 
        "Change your name because it's bad.",
        "Your gear doesn't match.", 
        "Wear a clown suit.", 
        "Take your shirt off.", 
        "Wear a tabard to hide your chest piece.", 
        "Hide your cape.",
        "Your shoulders are too big.", 
        "Your belt doesn't match your shoes.", 
        "Those boots are ugly.", 
        "Your gloves are the wrong color.", 
        "Hide your bracers.", 
        "Enchant your weapon with a glow.", 
        "You look fabulous."
    },
    SUMMON = { 
        "Don't click the portal and let them suffer.", 
        "Summon the Warlock instead.", 
        "Stand on the portal but don't click.",
        "Click the portal.", 
        "Channel the portal.", 
        "Move while channeling to break it.", 
        "Cancel the summon.", 
        "Accept the summon.",
        "Decline the summon and walk there.", 
        "Where are you going?", 
        "Are we inside?", 
        "Are we outside?", 
        "Help me.",
        "You are lazy so walk.", 
        "Run there.", 
        "Fly there.", 
        "Walk there.", 
        "Ride there.", 
        "Swim there.", 
        "Ask for a port."
    },
    LEVEL_UP = { 
        "Scream UNLIMITED POWER!", 
        "Another level and another waste of time.", 
        "You unlocked a passive talent and it's boring.",
        "You learned a new spell so use it.", 
        "You learned a new rank so you are stronger.", 
        "New dungeon unlocked so go die in it.", 
        "New zone unlocked so go explore.", 
        "New gear available so equip it.",
        "Spend your talent point.", 
        "Buy a new glyph.", 
        "Get a new mount.", 
        "You can fly now.", 
        "You can ride now.",
        "Skill up your weapon.", 
        "Level your profession.", 
        "Check your reputation.", 
        "Change your title.", 
        "Check your achievements.", 
        "Do a quest.", 
        "Ding! You are still weak."
    },
    LOOTING_JUNK = { 
        "Keep it because it might be important.", 
        "It's garbage but keep it anyway.", 
        "Equip that grey item because it looks cool.",
        "Sell it to a vendor.", 
        "Delete it.", 
        "Hoard it in your bank.", 
        "Mail it to a friend.", 
        "Trade it to a stranger.",
        "Link it in chat.", 
        "Show it off.", 
        "Hide it.", 
        "Ignore it.", 
        "Loot everything.",
        "Pass on the loot.", 
        "Greed on the loot.", 
        "Need on the loot.", 
        "Disenchant it.", 
        "Put it in the guild bank.", 
        "Give it to the guild.", 
        "Throw it into the void."
    },
    PLAYER_GENERIC = { 
        "Trade them 1 copper and don't explain why.", 
        "Follow him around for an hour.", 
        "Inspect him and judge his gear.", 
        "Whisper 'I know' to them.",
        "Spam emotes at them.", 
        "Dance with them.", 
        "Wave at them.", 
        "Slap them.", 
        "Hug them.",
        "Kiss them.", 
        "Bow to them.", 
        "Cheer for them.", 
        "Clap for them.", 
        "Cry at them.",
        "Laugh at them.", 
        "Roar at them.", 
        "Be rude to them.", 
        "Salute them.", 
        "Act shy.", 
        "Sleep on their feet."
    },
    PLAYER_PET = { 
        "Tell them to rename that pet because it's awful.", 
        "I wonder if that pet tastes like chicken.", 
        "Ask if they can Feign Death.",
        "Pet the good boy.", 
        "Feed it a treat.", 
        "Tell them to dismiss it.", 
        "Call your own pet.", 
        "Revive it.",
        "Mend the pet.", 
        "Tell it to attack.", 
        "Tell it to stay.", 
        "Follow the pet.", 
        "Put it on passive.",
        "Put it on defensive.", 
        "Put it on aggressive.", 
        "Turn off Taunt.", 
        "Turn off Growl.", 
        "Does it bite?", 
        "Watch out for the claws.", 
        "It's kind of cute."
    },
    BEAST = { 
        "Go pet that wild animal because it looks fluffy.", 
        "I bet you could tame that.", 
        "Roar back at it and assert dominance.",
        "I wonder what its leather looks like on you.", 
        "Hunt it down.", 
        "Trap it.", 
        "Feed it.", 
        "Ride it.",
        "Kill it because it looked at you funny.", 
        "Ignore it and walk away.", 
        "Run away before it eats you.", 
        "Hide from it.", 
        "Scare it.",
        "Study it.", 
        "Watch it.", 
        "Follow it.", 
        "Mimic it.", 
        "Don't let it bite you.", 
        "Scratch it behind the ears.", 
        "Howl at the moon."
    },
    DEMON = { 
        "Try to banish it back to the twisting nether.", 
        "Try to speak Demonic to it and make friends.", 
        "I bet you could enslave that.",
        "Fear it.", 
        "Summon another one.", 
        "Bind it to your will.", 
        "Make a contract.", 
        "Hunt it.",
        "Kill it with fire.", 
        "Ignore it.", 
        "Run away.", 
        "Hide from it.", 
        "Scare it.",
        "Study it.", 
        "Watch it.", 
        "Follow it.", 
        "Mimic it.", 
        "Burn it with fel fire.", 
        "Slice it up.", 
        "Laugh at it."
    },
    HUMANOID = { 
        "Check their pockets because there might be gold inside.", 
        "Ask them for directions to the nearest inn.", 
        "Steal their identity.",
        "Talk to them.", 
        "Kill them.", 
        "Ignore them.", 
        "Run away.", 
        "Hide from them.",
        "Scare them.", 
        "Study them.", 
        "Watch them.", 
        "Follow them.", 
        "Mimic them.",
        "Dance with them.", 
        "Emote at them.", 
        "Trade with them.", 
        "Duel them.", 
        "Invite them.", 
        "Kick them.", 
        "Report them."
    },
    CRITTER = { 
        "Blow your cooldowns on that squirrel because it deserves it.", 
        "Polymorph that sheep. Wait, you can't.", 
        "Kneel before the mighty rabbit.",
        "Kill it and show no mercy.", 
        "Pet it and be gentle.", 
        "Love it.", 
        "Hate it.", 
        "Kick it.",
        "Stomp on it.", 
        "Burn it.", 
        "Freeze it.", 
        "Zap it.", 
        "Shoot it.",
        "Stab it.", 
        "Crush it.", 
        "Eat it.", 
        "Catch it.", 
        "Battle it.", 
        "Release it.", 
        "Name it."
    },
    GENERIC_DUNGEON = { 
        "Pull while the healer is drinking.", 
        "Go the wrong way on purpose.", 
        "Roll Need on everything.",
        "Go AFK in the middle of the run.", 
        "Disconnect.", 
        "Lag out.", 
        "Wipe the group.", 
        "Run away.",
        "Skip the boss.", 
        "Pull the boss.", 
        "Pull the trash.", 
        "Loot the chest.", 
        "Roll for loot.",
        "Trade the loot.", 
        "Kick the tank.", 
        "Leave the group.", 
        "Join the group.", 
        "Queue up.", 
        "Wait for the tank.", 
        "Go faster."
    },
    GENERIC_RAID = { 
        "Stand in the fire because it's warm.", 
        "Drop the Toy Train set and annoy everyone.", 
        "Drop the Explosive Sheep.",
        "Wipe the raid.", 
        "Reset the boss.", 
        "Check your buffs.", 
        "Eat your food.", 
        "Drink your flask.",
        "Use a rune.", 
        "Pull the boss.", 
        "Check the pull timer.", 
        "Check DBM.", 
        "Check BigWigs.",
        "Distribute the loot.", 
        "Loot Council sucks.", 
        "DKP is better.", 
        "GDKP is life.", 
        "Roll for it.", 
        "Pass on it.", 
        "Start some drama."
    },
    AUCTION_HOUSE = { 
        "Buy everything on the page.", 
        "Bid on all the trash items.", 
        "Undercut them by exactly 1 copper.",
        "Sell everything you own.", 
        "Search for nothing.", 
        "Scan the entire database.", 
        "Post an auction.", 
        "Cancel your auctions.",
        "Buyout the market.", 
        "Bid war.", 
        "You need more Gold.", 
        "You need more Silver.", 
        "You need more Copper.",
        "You are rich.", 
        "You are poor.", 
        "Snipe that auction.", 
        "Are you a bot?", 
        "Play the market.", 
        "Check the price.", 
        "Crash the economy."
    },
    MAILBOX = { 
        "Mail all your gold to a stranger.", 
        "Return to sender.", 
        "Dance naked on the mailbox.",
        "Open your mail.", 
        "Send some mail.", 
        "Read the letter.", 
        "Delete the letter.", 
        "Take the item.",
        "Return the mail.", 
        "Spam someone.", 
        "Where is my Gold?", 
        "Where is my Item?", 
        "Send it COD.",
        "Write a letter.", 
        "Send a package.", 
        "Send a gift.", 
        "Don't get scammed.", 
        "Wait for the mail.", 
        "Close the mailbox.", 
        "Your mailbox is full."
    },
    FLIGHT_MASTER = { 
        "Click the dismount button mid-air and see what happens.", 
        "Hope for a mid-air collision.", 
        "Ask for a refund on this flight.",
        "Fly away.", 
        "Land safely.", 
        "Crash land.", 
        "This is too slow.", 
        "This is fast.",
        "Enjoy the scenic route.", 
        "This is boring.", 
        "Go AFK.", 
        "Alt-tab out.", 
        "Check the map.",
        "Change zone.", 
        "Go to the city.", 
        "Go to the town.", 
        "Go to the village.", 
        "Camp the flight path.", 
        "Unlock the point.", 
        "Follow the path."
    },
    MAP = { 
        "Climb to the highest peak and jump off.", 
        "Pathfinding is a lie.", 
        "Find a hole in the world geometry.", 
        "Zoom out until you can't see anything.",
        "Ping the map.", 
        "Mark the map.", 
        "Set a waypoint.", 
        "You are lost.", 
        "You are found.",
        "Explore the fog of war.", 
        "The map is foggy.", 
        "Clear the map.", 
        "Do a quest.", 
        "Find the quest hub.",
        "Find a rare mob.", 
        "Find a treasure.", 
        "Find the boss.", 
        "Gather nodes.", 
        "Go fish.", 
        "Dig here."
    },
    SYSTEM_MENU = { 
        "Log out and be free.", 
        "Exit Game and go outside.", 
        "Delete this character right now.", 
        "Reset your interface.",
        "Check your settings.", 
        "Lower your graphics.", 
        "Turn off the sound.", 
        "Change your keybindings.", 
        "Write a macro.",
        "Update your addons.", 
        "Read the help menu.", 
        "Contact support.", 
        "Read the credits.", 
        "Watch the cinematics.",
        "Change the language.", 
        "Change your region.", 
        "Check your account.", 
        "Check your subscription.", 
        "Open the store.", 
        "Quit the game."
    },
    ACHIEVEMENT_FRAME = { 
        "Look at all those meaningless points.", 
        "You haven't done this yet.", 
        "I wish you could reset your stats.",
        "Link the achievement.", 
        "Track the achievement.", 
        "Complete it.", 
        "Fail it.", 
        "Grind for it.",
        "Farm for it.", 
        "It's a rare achievement.", 
        "It's hard.", 
        "It's easy.", 
        "It looks fun.",
        "It looks boring.", 
        "It's bugged.", 
        "It's hidden.", 
        "Feat of Strength.", 
        "Legacy achievement.", 
        "Guild achievement.", 
        "Player achievement."
    }
}

-- =========================================================================
-- 3. SPEC DETECTION (RETAIL & CLASSIC COMPATIBLE)
-- =========================================================================

-- Helper: Get Spec for TBC (Counts Talent Points)
local function GetClassicSpec()
    local highestPoints = 0
    local specIndex = 1 
    
    -- Loop through the 3 talent tabs
    for i = 1, 3 do
        local _, _, pointsSpent = GetTalentTabInfo(i) 
        if pointsSpent and pointsSpent > highestPoints then
            highestPoints = pointsSpent
            specIndex = i
        end
    end
    
    local _, classFilename = UnitClass("player")
    local specMap = {
        MAGE = { "ARCANE", "FIRE", "FROST" },
        WARLOCK = { "AFFLICTION", "DEMONOLOGY", "DESTRUCTION" },
        PRIEST = { "DISCIPLINE", "HOLY", "SHADOW" },
        ROGUE = { "ASSASSINATION", "COMBAT", "SUBTLETY" },
        DRUID = { "BALANCE", "FERAL", "RESTORATION" },
        HUNTER = { "BEASTMASTERY", "MARKSMANSHIP", "SURVIVAL" },
        SHAMAN = { "ELEMENTAL", "ENHANCEMENT", "RESTORATION" },
        WARRIOR = { "ARMS", "FURY", "PROTECTION" },
        PALADIN = { "HOLY", "PROTECTION", "RETRIBUTION" },
    }

    if specMap[classFilename] then
        return specMap[classFilename][specIndex]
    end
    return "NONE"
end

-- Helper: Master Function to get the Spec Name
local function GetPlayerSpecName()
    local specName = "NONE"

    if IS_RETAIL then
        -- RETAIL LOGIC
        local currentSpecIndex = GetSpecialization()
        if currentSpecIndex then
            local _, name = GetSpecializationInfo(currentSpecIndex)
            if name then 
                specName = string.upper(string.gsub(name, " ", "")) 
            end
        end
    else
        -- CLASSIC / TBC LOGIC
        specName = GetClassicSpec()
        
        -- Fix TBC naming mismatches for your specific tables
        if specName == "COMBAT" then specName = "OUTLAW" end
    end
    
    return specName
end

-- =========================================================================
-- 4. WHISPER LOGIC
-- =========================================================================

-- TESTING SETTINGS (Set back to 60 / 0.50 when done testing!)
local BASE_CHANCE = 0.50    
local THROTTLE_TIME = 60    
local lastWhisperTime = 0

function VoidWhisper(category)
    local currentTime = GetTime()
    local timeSinceLast = currentTime - lastWhisperTime
    
    -- Urgent events ignore throttle
    local isUrgent = (category == "LOW_HEALTH" or category == "AFK" or category == "QUEUE_POP" or category == "READY_CHECK" or category == "RESURRECT" or category == "DUEL")
    
    if isUrgent then
        if timeSinceLast < 10 then return end 
    else
        if timeSinceLast < THROTTLE_TIME then return end

        local chance = BASE_CHANCE 
        if category == "FLIGHT_MASTER" or category == "AUCTION_HOUSE" or category == "BANK" or 
           category == "MAILBOX" or category == "GENERIC_DUNGEON" or category == "GENERIC_RAID" or 
           category == "VANITY" or category == "CRAFTING" or category == "SUMMON" or category == "MAP" or
           category == "SYSTEM_MENU" or category == "ACHIEVEMENT_FRAME" or
           string.find(category, "ELITE_") then 
            chance = 0.25 
        end
        if math.random() > chance then return end 
    end

    local table = reactions[category]
    if table then
        local msg = table[math.random(#table)]
        local entityName = ENTITIES[math.random(#ENTITIES)]
        print(entityName .. WHISPER_COLOR .. " whispers: " .. msg .. "|r")
        PlaySound(3081, "Master") 
        lastWhisperTime = currentTime
    end
end

-- =========================================================================
-- 5. EVENT HANDLER
-- =========================================================================

frame:SetScript("OnEvent", function(self, event, ...)
    
    -- Helper to safely get unit data without crashing
    local function SafeGet(func, unit)
        local success, result = pcall(func, unit)
        if success and (type(result) == "string" or type(result) == "number" or type(result) == "boolean") then
            return result
        end
        return nil
    end

    if event == "PLAYER_ENTERING_WORLD" then
        local _, classFilename = UnitClass("player")
        self.classBase = "SELF_" .. (classFilename or "PRIEST")
    
    -- UI Events
    elseif event == "LFG_PROPOSAL_SHOW" then VoidWhisper("QUEUE_POP")
    elseif event == "READY_CHECK" then VoidWhisper("READY_CHECK")
    elseif event == "RESURRECT_REQUEST" then VoidWhisper("RESURRECT")
    elseif event == "DUEL_REQUESTED" then VoidWhisper("DUEL")
    elseif event == "CONFIRM_SUMMON" then VoidWhisper("SUMMON")
    elseif event == "TAXIMAP_OPENED" then VoidWhisper("FLIGHT_MASTER")
    elseif event == "BANKFRAME_OPENED" then VoidWhisper("BANK")
    elseif event == "AUCTION_HOUSE_SHOW" then VoidWhisper("AUCTION_HOUSE")
    elseif event == "MAIL_SHOW" then VoidWhisper("MAILBOX")
    elseif event == "TRADE_SKILL_SHOW" then VoidWhisper("CRAFTING")
    elseif event == "TRANSMOGRIFY_OPEN" or event == "BARBER_SHOP_OPEN" then VoidWhisper("VANITY")
    
    -- Zoning
    elseif event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED" then
        local zone = GetRealZoneText()
        if reactions[zone] then VoidWhisper(zone); return end
        
        local inInstance, instanceType = IsInInstance()
        if inInstance then
            if instanceType == "party" then VoidWhisper("GENERIC_DUNGEON")
            elseif instanceType == "raid" then VoidWhisper("GENERIC_RAID")
            elseif instanceType == "scenario" then VoidWhisper("GENERIC_DUNGEON") 
            end
        end

    -- Targeting Logic
    elseif event == "PLAYER_TARGET_CHANGED" then
        if UnitExists("target") then
            
            -- Is Player?
            local isPlayer = SafeGet(UnitIsPlayer, "target")
            if isPlayer then
                local success, _, classFilename = pcall(UnitClass, "target")
                if not success or type(classFilename) ~= "string" then 
                    VoidWhisper("PLAYER_GENERIC")
                    return 
                end

                if classFilename == "PALADIN" then VoidWhisper("PLAYER_PALADIN")
                elseif classFilename == "DEMONHUNTER" then VoidWhisper("PLAYER_DEMONHUNTER")
                elseif classFilename == "WARLOCK" then VoidWhisper("PLAYER_WARLOCK")
                else VoidWhisper("PLAYER_GENERIC")
                end
                return
            end
            
            -- Is Pet?
            local isControlled = SafeGet(UnitPlayerControlled, "target")
            if isControlled and not isPlayer then VoidWhisper("PLAYER_PET"); return end
            
            -- Is Dead?
            if SafeGet(UnitIsDead, "target") then VoidWhisper("TARGET_CORPSE"); return end

            -- Is Elite/Boss?
            local classification = SafeGet(UnitClassification, "target")
            if classification and (classification == "worldboss" or classification == "elite" or classification == "rareelite") then
                if IsInGroup() then VoidWhisper("ELITE_GROUP") else VoidWhisper("ELITE_SOLO") end
                return
            end
            
            -- Creature Type
            local cType = SafeGet(UnitCreatureType, "target")
            if cType then
                if cType == "Beast" then VoidWhisper("BEAST")
                elseif cType == "Demon" then VoidWhisper("DEMON")
                elseif cType == "Humanoid" then VoidWhisper("HUMANOID")
                elseif cType == "Critter" then VoidWhisper("CRITTER")
                else
                    if IsInGroup() then VoidWhisper("ELITE_GROUP") else VoidWhisper("ELITE_SOLO") end
                end
            else
                if IsInGroup() then VoidWhisper("ELITE_GROUP") else VoidWhisper("ELITE_SOLO") end
            end
        end

    -- Combat / Spec Detection Logic
    elseif event == "PLAYER_REGEN_DISABLED" then 
        if math.random() > 0.5 then
            -- Get Spec Name (Works for Retail or TBC)
            local specName = GetPlayerSpecName()
            local groupSuffix = IsInGroup() and "_GROUP" or "_SOLO"
            local specKey = self.classBase .. "_" .. specName .. groupSuffix
            
            if reactions[specKey] then 
                VoidWhisper(specKey) 
            else 
                VoidWhisper(self.classBase .. groupSuffix) 
            end
        else
            VoidWhisper("COMBAT_START")
        end

    -- AFK Check
    elseif event == "PLAYER_FLAGS_CHANGED" then
        if UnitIsAFK("player") then
            if not self.isAFK then VoidWhisper("AFK"); self.isAFK = true end
        else self.isAFK = false end
        
    -- Level Up
    elseif event == "PLAYER_LEVEL_UP" then VoidWhisper("LEVEL_UP")
    
    -- Loot
    elseif event == "LOOT_READY" then
        local numItems = GetNumLootItems()
        if numItems > 0 then
            for i = 1, numItems do
                if GetLootSlotType(i) == LOOT_SLOT_ITEM then
                    local link = GetLootSlotLink(i)
                    if link then
                        local _, _, quality = GetItemInfo(link)
                        if quality == 0 then VoidWhisper("LOOTING_JUNK"); break end
                    end
                end
            end
        end
    end
end)

-- Hook UI Windows
if WorldMapFrame then WorldMapFrame:HookScript("OnShow", function() VoidWhisper("MAP") end) end
if AchievementFrame then AchievementFrame:HookScript("OnShow", function() VoidWhisper("ACHIEVEMENT_FRAME") end) end
if GameMenuFrame then GameMenuFrame:HookScript("OnShow", function() VoidWhisper("SYSTEM_MENU") end) end