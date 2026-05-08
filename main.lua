--- STEAMODDED HEADER
--- MOD_NAME: 1AHITM
--- MOD_ID: EXAMPLEJOKER
--- MOD_AUTHOR: [Lumi]
--- MOD_DESCRIPTION: Klassen Mod.
--- PREFIX: hcrf
---------------------------------------
------------MOD CODE ------------------


--odd todd ass

---Destroys the provided Joker
---@param card table
---@param after function?
function destroy_joker(card, after)
  G.E_MANAGER:add_event(Event({
    func = function()
      play_sound('tarot1')
      card.T.r = -0.2
      card:juice_up(0.3, 0.4)
      card.states.drag.is = true
      card.children.center.pinch.x = true
      G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.3,
        blockable = false,
        func = function()
          G.jokers:remove_card(card)
          card:remove()

          if after and type(after) == "function" then
            after()
          end

          return true
        end
      }))
      return true
    end
  }))
end

--- Adds a tag the same way vanilla does it
--- @param tag string | table a tag key or a tag table
--- @param event boolean? whether to send this in an event or not
--- @param silent boolean? whether to play a sound
function add_tags(tag, event, silent)
  local func = function()
    add_tag(type(tag) == 'string' and Tag(tag) or tag)
    if not silent then
      play_sound('generic1', 0.9 + math.random() * 0.1, 0.8)
      play_sound('holo1', 1.2 + math.random() * 0.1, 0.4)
    end
    return true
  end

  if event then
    G.E_MANAGER:add_event(Event {
      func = func
    })
  else
    func()
  end
end

---@diagnostic disable: duplicate-set-field, lowercase-global
-- Creates the flags
local BackApply_to_run_ref = Back.apply_to_run
function Back.apply_to_run(arg_56_0)
  BackApply_to_run_ref(arg_56_0)
  G.GAME.pool_flags.ahitm_filthy_can_spawn = false
    G.GAME.pool_flags.ahitm_beta_can_spawn = false
  G.GAME.pool_flags.ahitm_omega_can_spawn = false
  G.GAME.pool_flags.ahitm_d4c_can_spawn = true
  G.GAME.pool_flags.ahitm_ye_can_spawn = false
  G.GAME.pool_flags.ahitm_alpha_can_spawn = true
end

--- Tries to spawn a card into either the Jokers or Consumeable card areas, ensuring
--- that there is space available, using the respective buffer.
--- DOES NOT TAKE INTO ACCOUNT ANY OTHER AREAS
--- @param args CreateCard | { card: Card?, strip_edition: boolean? } | { instant: boolean?, func: function? } info:
--- Either a table passed to SMODS.create_card, which will create a new card.
--- Or a table with 'card', which will copy the passed card and remove its edition based on 'strip_edition'.
--- @return boolean? spawned whether the card was able to spawn
function try_spawn_card(args)
  local is_joker = args.card and (args.card.ability.set == 'Joker') or
      (args.set == 'Joker' or (args.key and args.key:sub(1, 1) == 'j'))
  local area = args.area or (is_joker and G.jokers) or G.consumeables
  local buffer = area == G.jokers and 'joker_buffer' or 'consumeable_buffer'

  if #area.cards + G.GAME[buffer] < area.config.card_limit then
    local added_card
    local function add()
      if args.card then
        added_card = copy_card(args.card, nil, nil, nil, args.strip_edition)
        added_card:add_to_deck()
        area:emplace(added_card)
      else
        SMODS.add_card(args)
      end
    end

    if args.instant then
      add()
    else
      G.GAME[buffer] = G.GAME[buffer] + 1

      G.E_MANAGER:add_event(Event {
        func = function()
          add()
          G.GAME[buffer] = 0
          return true
        end
      })
    end

    if args.func and type(args.func) == "function" then
      args.func(added_card)
    end

    return true
  end
end

---Gets a pseudorandom tag from the Tag pool
---@param seed string
---@param options table? a list of tags to choose from, defaults to normal pool
---@return table
function poll_tag(seed, options)
  -- This part is basically a copy of how the base game does it
  -- Look at get_next_tag_key in common_events.lua
  local pool = options or get_current_pool('Tag')
  local tag_key = pseudorandom_element(pool, pseudoseed(seed))

  while tag_key == 'UNAVAILABLE' do
    tag_key = pseudorandom_element(pool, pseudoseed(seed))
  end

  local tag = Tag(tag_key)

  -- The way the hand for an orbital tag in the base game is selected could cause issues
  -- with mods that modify blinds, so we randomly pick one from all visible hands
  if tag_key == "tag_orbital" then
    local available_hands = {}

    for k, hand in pairs(G.GAME.hands) do
      if hand.visible then
        available_hands[#available_hands + 1] = k
      end
    end

    tag.ability.orbital_hand = pseudorandom_element(available_hands, pseudoseed(seed .. '_orbital'))
  end

  return tag
end

local function check_joker_space(card)
	if card.config.center.set == "Joker" and card.edition and card.edition.negative then return true end
	local c = 0
	local un_c = G.jokers.config.card_limit
	for i, v in ipairs(G.jokers.cards) do
		if v.edition and v.edition.type == "negative" then
			un_c = un_c - 1
		elseif v.ability.eternal then
			c = c + 1
		else
			break
		end
	end
	return c < un_c
end


SMODS.Atlas{
  key = 'template',
  path = 'template.png',
  px = 71,
  py = 95,
}

--monster
SMODS.Atlas{
  key = 'monster',
  path = 'monster.png',
  px = 71,
  py = 95,
}
SMODS.Joker{
  key = 'monster',
  loc_txt = {
    name = 'Monster',
    text = {
      'Gain a random {C:attention}skip tag{}',
      'at the end of round',
      'consumed after {C:attention}#1#{} cards {C:mult}discarded{}'
    }
  },
  atlas = 'monster',
  config = {
    extra = {
      var1= 30
    }
  },



    loc_vars = function(self, info_queue, card)
      return {
        vars = {
          card.ability.extra.var1
        }
      }
    end,
  pos = {x = 0, y = 0},
  rarity = 1,
  cost = 4,
  unlocked = true,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  calculate = function(self, card, context)
  -- Trigger reward at end of round
  if context.end_of_round and context.main_eval then
    add_tag(poll_tag("monster"))
        return {
        message = 'Tag!',
        colour = G.C.RED,
        card = card
      }
  end
  
  if not context.blueprint and context.discard then
    card.ability.extra.var1 = card.ability.extra.var1 - 1

    if card.ability.extra.var1 == 0 then
      destroy_joker(card)
      return {
        message = 'Consumed!',
        colour = G.C.GREEN,
        card = card
      }

    end
  end
end
}


--squirrel
SMODS.Atlas{
  key = 'squirrel',
  path = 'Jokerss.png',
  px = 71,
  py = 95,
}
SMODS.Joker{
  key = 'squirrel',
  loc_txt = {
    name = 'Squirrel',
    text = {
      'When sold creates a {C:attention}Joker{}',
      'of the rarity of the last',
      'sold {C:attention}Joker{} before Squirrel',
      '{C:inactive}(Currently:{} {C:attention}#1#{}{C:inactive})'
    }
  },
  atlas = 'squirrel',
  config = {
    extra = {
      rarity = 'Common'
    }
  },
  loc_vars = function(self, info_queue, card)
    return {
      vars = { card.ability.extra.rarity }
    }
  end,
  pos = {x = 0, y = 0},
  rarity = 2,
  unlocked = true,
  cost = 5,
  discovered = true,
  blueprint_compat = false,
  eternal_compat = true,
    calculate = function(self, card, context)
          if not context.blueprint and context.selling_card and context.card ~= card and
    context.card.ability.set == 'Joker' then

          local joker = context.card
          local rarity = joker.config.center.rarity
    if rarity == 1 then
      card.ability.extra.rarity = 'Common'
    end
        if rarity == 2 then
      card.ability.extra.rarity = 'Uncommon'
    end
        if rarity == 3 then
      card.ability.extra.rarity = 'Rare'
    end
        if rarity == 4 then
      card.ability.extra.rarity = 'Legendary'
    end

    end

    if not context.blueprint and context.selling_card and context.card == card and 
    context.card.ability.set == 'Joker' then
      local new_card = nil
          if card.ability.extra.rarity == 'Common' then
          new_card = create_card('Joker', G.joker, nil, 0.1 , nil, nil, nil)
    end
        if card.ability.extra.rarity == 'Uncommon' then
          new_card = create_card('Joker', G.joker, nil, 0.8 , nil, nil, nil)
    end
        if card.ability.extra.rarity == 'Rare' then
          new_card = create_card('Joker', G.joker, nil, 80 , nil, nil, nil)
    end
        if card.ability.extra.rarity == 'Legendary' then
          new_card = create_card('Joker', G.joker, true, nil , nil, nil, nil)
    end
        --common = 0.5 uncommon = 0.8 rare = 1  legendary = nil
        new_card:add_to_deck()
        G.jokers:emplace(new_card)
      end
  end
}

--kiss
SMODS.Atlas{
  key = 'kiss',
  path = 'kiss.png',
  px = 71,
  py = 95,
}
SMODS.Joker{
  key = 'kiss',
  loc_txt = {
    name = 'KISS',
    text = {
      'retrigger all {C:attention}played{}',
      'cards with {C:attention}seals{}',
      'an additional time'
    }
  },
  atlas = 'kiss',
  config = {
    extra = {
      chance = '1',
      chance2 = '20'
    }
  },

    -- Sets the sprite and hitbox
    set_ability = function(self, card, initial, delay_sprites)
      local h_scale = 71 / 95
  
      card.T.h = card.T.h * h_scale

    end,
  
    set_sprites = function(self, card, front)
      local h_scale = 71 / 95
  
      card.children.center.scale.y = card.children.center.scale.y * h_scale

    end,
  
    load = function(self, card, card_table, other_card)
      local h_scale = 71 / 95
  
      card.T.h = card.T.h * h_scale

    end,

    loc_vars = function(self, info_queue, card)
      return {
        vars = {
          card.ability.extra.chance,
          card.ability.extra.chance2
        }
      }
    end,
  pos = {x = 0, y = 0},
  rarity = 'Uncommon',
  unlocked = true,
  discovered = true,
  cost = 6,
  blueprint_compat = true,
  eternal_compat = true,
 calculate = function(self, card, context)
    if context.cardarea == G.play and context.repetition then
      if context.other_card:get_seal() then
        return {
          repetitions = 1
        }
      end
    end
end
}

--artisan
SMODS.Atlas{
  key = 'artisan',
  path = 'artisan.png',
  px = 71,
  py = 95,
}
SMODS.Joker{
  key = 'artisan',
  loc_txt = {
    name = 'Artisan',
    text = {
      'Retrigger played {C:attention}#1#{}',
      'two additional times'
    }
  },
  atlas = 'artisan',
  config = {
    extra = {
      card = 'Aces',
      [14] = 2
    }
  },
  loc_vars = function(self, info_queue, card)
    return {
      vars = { card.ability.extra.card }
    }
  end,
  pos = {x = 0, y = 0},
  rarity = 'Rare',
  unlocked = true,
  cost = 9,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  calculate = function(self, card, context)
    if context.cardarea == G.play and context.repetition then
      local card_id = context.other_card:get_id()
      if card_id == 14 then  -- Only apply to Aces
        return {
          repetitions = card.ability.extra[card_id]  -- = 2
        }
      end
    end
  end
}




--concentrate
SMODS.Atlas{
  key = 'concentrate',
  path = 'concentrate.png',
  px = 71,
  py = 95,
}
SMODS.Joker{
  key = 'concentrate',
  loc_txt = {
    name = 'Concentrate',
    text = {
      'All played',
      '{C:attention}face cards{}',
      'gain {C:dark_edition}Foil Edition{}'

    }
  },
  atlas = 'concentrate',
  config = {
    extra = {
      var1 = 5, -- Chips gained per Heart card
      var2 = 0   -- Total accumulated chips
    }
  },

  loc_vars = function(self, info_queue, card)
    return {
      vars = {
        card.ability.extra.var1,
        card.ability.extra.var2
      }
    }
  end,

  pos = {x = 0, y = 0},
  rarity = 2,
  cost = 9,
  unlocked = true,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,

  calculate = function(self, card, context)
  if context.individual and context.cardarea == G.play and context.other_card then
    local c = context.other_card
    if c:is_face() then
      c:set_edition('e_foil', true)
    
            return {
          message = 'GROW BACK!',
          colour = G.C.CHIPS,
          card = card
        }
     end
  end
end
}


--d4c
SMODS.Atlas{
  key = 'd4c',
  path = 'd4c.png',
  px = 568,
  py = 760,
}
SMODS.Joker{
  key = 'd4c',
  loc_txt = {
    name = 'Dirty Deeds Done Dirt Cheap',
    text = {
      '{C:green}#1# in #2#{} chance for the {C:attention}rightmost{}',
      '{C:attention}played card{} to gain a {C:dark_edition}Negative Edition{}',
      '{C:green}#1# in #2#{} {C:inactive}chance to be copyrighted{}',
      '{C:inactive}at the end of round{}'
    }
  },
  atlas = 'd4c',
  config = {
    extra = {
      var2= 7
    }
  },



    loc_vars = function(self, info_queue, card)
      return {
        vars = {
          G.GAME.probabilities.normal,
          card.ability.extra.var2,
          
        }
      }
    end,
  pos = {x = 0, y = 0},
  rarity = 3,
  unlocked = true,
  cost = 7,
  discovered = true,
  blueprint_compat = false,
  eternal_compat = true,
  yes_pool_flag = 'ahitm_d4c_can_spawn',

  calculate = function(self, card, context)
  if not context.blueprint  then
    local odds = G.GAME.probabilities.normal / (card.ability.extra.var2 or 7)
      if context.individual and context.cardarea == G.play then
      if context.individual and context.other_card then
      local c = context.other_card
        if c == context.scoring_hand[#context.scoring_hand] then
          if pseudorandom("d4c") < odds then
        c:set_edition('e_negative', true)
          end 
        end
      end
    end
       if context.end_of_round and context.main_eval then
        if pseudorandom("d4c") < odds then
         destroy_joker(card, function()
            G.GAME.pool_flags.ahitm_d4c_can_spawn = false
            G.GAME.pool_flags.ahitm_filthy_can_spawn = true
        end)
                 return {
          message = 'Copyrighted!',
          colour = G.C.MULT,
          card = card
        }
      else
        return {
          message = 'Safe!',
          colour = G.C.CHIPS,
          card = card
        }
      end 
       end
  end
end
}

--bms
SMODS.Atlas{
  key = 'bms',
  path = 'bms.png',
  px = 71,
  py = 95,
}
SMODS.Joker{
  key = 'bms',
  loc_txt = {
    name = 'House Carpet Rocketfuel',
    text = {
      'If {C:attention}Boss Blind{} is defeated',
      'on {C:attention}Third{} hand of round',
      'using a {C:attention}Full House{}',
      'create a {C:dark_edition}Negative Rocket{}'
    }
  },
  atlas = 'bms',
  config = {
    extra = {
      var1 = 1,
      var2 = 4
    }
  },

  loc_vars = function(self, info_queue, card)
    return {
      vars = {
        card.ability.extra.var1,
        card.ability.extra.var2
      }
    }
  end,

  pos = {x = 0, y = 0},
  rarity = 3,
  cost = 8,
  unlocked = true,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,

  calculate = function(self, card, context)
  -- Detect a Full House being played
  if not context.blueprint and context.before and context.main_eval then
    card.ability.housecheck = next(context.poker_hands['Full House']) and true or false
  end

  -- Trigger reward at end of round if boss blind and housecheck is true
  if context.end_of_round and context.main_eval and G.GAME.blind.boss and card.ability.housecheck and G.GAME.current_round.hands_played == 3 then
    local new_card = create_card('Joker', G.jokers, nil, nil, nil, nil, 'j_rocket')
    new_card:set_edition('e_negative', true, false)
    new_card:add_to_deck()
    G.jokers:emplace(new_card)

    -- Optional: clear the flag after use
    card.ability.housecheck = false

    return {
      message = 'Check It Out!',
      colour = G.C.MULT,
      card = card
    }
  end
end
}




--fiab
SMODS.Atlas{
  key = 'fiab',
  path = 'fiab.png',
  px = 71,
  py = 95,
}
SMODS.Joker{
  key = 'fiab',
  loc_txt = {
    name = 'Caged Fish',
    text = {
      'This Joker gains {X:mult,C:white}X#1#{}',
      'when {C:attention}Skipping a Blind{}',
      'The Mult on this decreases by',
      '{X:mult,C:white}X#2#{} at the {C:attention}end of round{}',
      '{C:inactive}(Currently:{} {X:mult,C:white}X#3#{}{C:inactive}){}'

    }
  },
  atlas = 'fiab',
  config = {
    extra = {
      var1 = 4,
      var2 = 1,
      mult = 4
    }
  },

  loc_vars = function(self, info_queue, card)
    return {
      vars = {
        card.ability.extra.var1,
        card.ability.extra.var2,
        card.ability.extra.mult
      }
    }
  end,

  pos = {x = 0, y = 0},
  rarity = 2,
  unlocked = true,
  cost = 8,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,

  calculate = function(self, card, context)
    if context.joker_main and context.cardarea == G.jokers then
      return {
        x_mult = card.ability.extra.mult
      }
    end
    if not context.blueprint and context.end_of_round and context.main_eval and card.area == G.jokers then
        card.ability.extra.mult = card.ability.extra.mult - 1

    if card.ability.extra.mult <= 1 then
        destroy_joker(card)
        return {
          message = 'Yikes!',
          colour = G.C.MULT,
          card = card
        }
      else
        return {
          message = '-1!',
          colour = G.C.MULT,
          card = card
        }
      end
    end
    if context.skip_blind then
        card.ability.extra.mult = card.ability.extra.var1 
      return {
          message = '+4!',
          colour = G.C.MULT,
          card = card
      }
    end
  end

}



--igor
SMODS.Atlas{
  key = 'igor',
  path = 'igor.png',
  px = 71,
  py = 95,
}
SMODS.Joker{
  key = 'igor',
  loc_txt = {
    name = 'IGOR',
    text = {
      'If {C:attention}played hand{} contains',
      'at least two scoring {C:attention}Jacks{}',
      'and a scoring {C:attention}Queen{}',
      'create a {C:dark_edition}Spectral{} card'
    }
  },
  atlas = 'igor',
  config = {
    extra = {
      var1 = 1
    }
  },
  loc_vars = function(self, info_queue, card)
    return {
      vars = {
        card.ability.extra.var1
      }
    }
  end,
  pos = {x = 0, y = 0},
  rarity = 2,
  unlocked = true,
  cost = 4,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,



calculate = function(self, card, context)
    if context.joker_main and context.cardarea == G.jokers and context.scoring_hand then
        local jack_count, queen_count = 0, 0

        for _, c in ipairs(context.scoring_hand) do
            if c:get_id() == 11 then jack_count = jack_count + 1 end
            if c:get_id() == 12 then queen_count = queen_count + 1 end
        end

        if jack_count >= 2 and queen_count >= 1 then
            
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()

                    --  CHECK LIMIT AT THE MOMENT OF CREATION
                    if #G.consumeables.cards < G.consumeables.config.card_limit then
                        local card_to_add = create_card('Spectral', G.consumeables, nil, nil, nil, true)
                        G.consumeables:emplace(card_to_add)
                    end

                    return true
                end
            }))
              if #G.consumeables.cards < G.consumeables.config.card_limit then
            return {
                message = "I think I've fallen in Looooove!",
                colour = G.C.TAROT,
                card = card
            }
          end
        end
    end
end
}





--hockey
SMODS.Atlas{
  key = 'hockey',
  path = 'hockey.png',
  px = 71,
  py = 95,
}
SMODS.Joker{
  key = 'hockey',
  loc_txt = {
    name = 'Hockey',
    text = {
      'Gain a {C:attention}Voucher Tag{}',
      'When defeating the {C:attention}Boss Blind{}'
    }
  },
  atlas = 'hockey',
  config = {
    extra = {
      var1= 1
    }
  },



    loc_vars = function(self, info_queue, card)
      return {
        vars = {
          card.ability.extra.var1
        }
      }
    end,
  pos = {x = 0, y = 0},
  rarity = 1,
  unlocked = true,
  cost = 4,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  calculate = function(self, card, context)
  if context.end_of_round and context.main_eval and G.GAME.blind.boss then
      add_tags("tag_voucher")
      return {
        message = 'Dopamin!',
        colour = G.C.MULT,
        card = card
      }
    end
  end 
}



-- Alpha
SMODS.Atlas{
  key = 'alpha',
  path = 'alpha.png',
  px = 71,
  py = 95,
}
SMODS.Joker{
  key = 'alpha',
  loc_txt = {
    name = 'Alpha',
    text = {
      'Turns into {C:attention}Beta{}',
      'After skipping {C:attention}#1# Blinds{}',
      '{C:inactive}(#2# skipped){}'
    }
  },
  atlas = 'alpha',
  config = {
    extra = {
      var1 = 2,
      var2 = 0
    }
  },

  pos = {x = 0, y = 0},
  rarity = 1,
  unlocked = true,
  cost = 4,
  discovered = true,
  blueprint_compat = false,
  eternal_compat = false,
  yes_pool_flag = 'ahitm_alpha_can_spawn',
    loc_vars = function(self, info_queue, card)
    return {
      vars = {
        card.ability.extra.var1,
        card.ability.extra.var2,
      }
    }
  end,
    calculate = function(self, card, context)

    if context.skip_blind then
        card.ability.extra.var2 =  card.ability.extra.var2+1
        if card.ability.extra.var1 <= card.ability.extra.var2 then
          destroy_joker(card, function()
          G.GAME.pool_flags.ahitm_alpha_can_spawn = false
          local new_card = create_card('Joker', G.jokers, nil, nil, nil, nil, 'j_hcrf_beta')
          new_card:add_to_deck()
          G.jokers:emplace(new_card)
          return {
        message = 'BETA!',
        colour = G.C.PURPLE,
        card = card
      }
    end)
  else
      return {
          message = 'SKIP!',
          colour = G.C.MULT,
          card = card
      }
    end
    end
  end


}

-- Beta
SMODS.Atlas{
  key = 'beta',
  path = 'beta.png',
  px = 71,
  py = 95,
}
SMODS.Joker{
  key = 'beta',
  loc_txt = {
    name = 'Beta',
    text = {
      'Turns into {C:attention}Omega{}',
      'after playing a',
      '{C:attention}Straight Flush{}'
    }
  },
  atlas = 'beta',
  config = {
    extra = {
      slots = 2
    }
  },

  pos = {x = 0, y = 0},
  rarity = 2,
  unlocked = true,
  cost = 6,
  discovered = true,
  blueprint_compat = false,
  eternal_compat = false,
  yes_pool_flag = 'ahitm_beta_can_spawn',

  calculate = function(self, card, context)

 if not context.blueprint and context.before and context.main_eval then
    if context.poker_hands and next(context.poker_hands['Straight Flush']) then
    destroy_joker(card, function()
    local new_card = create_card('Joker', G.jokers, nil, nil, nil, nil, 'j_hcrf_omega')
    new_card:add_to_deck()
    G.jokers:emplace(new_card)
          return {
        message = 'OMEGA!',
        colour = G.C.GREEN,
        card = card
      }
    end)
  end
  end

  end

}

-- Omega
SMODS.Atlas{
  key = 'omega',
  path = 'omega.png',
  px = 71,
  py = 95,
}
SMODS.Joker{
  key = 'omega',
  loc_txt = {
    name = 'Omega',
    text = {
      '{X:mult,C:white}X#1#{} Mult',
    }
  },
  atlas = 'omega',
  config = {
    extra = {
      mult = 30
    }
  },
  loc_vars = function(self, info_queue, card)
    return {
      vars = {
        card.ability.extra.mult
      }
    }
  end,
  pos = {x = 0, y = 0},
  rarity = 3,
  unlocked = true,
  cost = 8,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = false,
  yes_pool_flag = 'ahitm_omega_can_spawn',

  calculate = function(self, card, context)
    -- Apply x_mult during play if this Joker is being used
    if context.joker_main and context.cardarea == G.jokers then
      return {
        x_mult = card.ability.extra.mult
      }
    end
  end


}




--filthy
SMODS.Atlas{
  key = 'filthy',
  path = 'd4c2.png',
  px = 71,
  py = 95,
}
SMODS.Joker{
  key = 'filthy',
  loc_txt = {
    name = 'Filthy Acts at a Reasonable Price',
    text = {
      'Every {C:dark_edition}Negative{}',
      'card {C:attention}held in hand{}',
      'gives {X:mult,C:white}X#1#{} Mult'

    }
  },
  atlas = 'filthy',
  config = {
    extra = {
      var1= 2
    }
  },



    loc_vars = function(self, info_queue, card)
      return {
        vars = {
          card.ability.extra.var1
        }
      }
    end,
  pos = {x = 0, y = 0},
  rarity = 1,
  unlocked = true,
  cost = 5,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  yes_pool_flag = 'ahitm_filthy_can_spawn',
    calculate = function(self, card, context)
    if context.individual and context.cardarea == G.hand then
      if context.individual and context.other_card and not context.end_of_round then
      local c = context.other_card
      if c.edition and c.edition.negative then
      return{
        x_mult = card.ability.extra.var1
      }
    end
      end
    end
  end
}

--dwarven
SMODS.Atlas{
  key = 'dwarven',
  path = 'dwarven.png',
  px = 568,
  py = 760,
}
SMODS.Joker{
  key = 'dwarven',
  loc_txt = {
    name = 'Dwarven',
    text = {
      'retrigger all',
      'played {C:spades}spades{}',

    }
  },
  atlas = 'dwarven',
  config = {
    extra = {
      var1= 1
    }
  },



    loc_vars = function(self, info_queue, card)
      return {
        vars = {
          card.ability.extra.var1
        }
      }
    end,
  pos = {x = 0, y = 0},
  rarity = 2,
  unlocked = true,
  cost = 7,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)

    if context.cardarea == G.play and context.repetition then
      local card_id = context.other_card:get_id()
      if context.other_card:is_suit("Spades") then
        return {
          repetitions = 1
        }
      end
    end
  end
}

--sigma
SMODS.Atlas{
  key = 'sigma',
  path = 'sigma.png',
  px = 71,
  py = 95,
}
SMODS.Joker{
  key = 'sigma',
  loc_txt = {
    name = 'Sigma',
    text = {
      'Every scored ',
      '{C:attention}8{} of {C:spades}spades{}',
      'gives {X:mult,C:white}X#1#{}',

    }
  },
  atlas = 'sigma',
  config = {
    extra = {
      var1= 2.5
    }
  },



    loc_vars = function(self, info_queue, card)
      return {
        vars = {
          card.ability.extra.var1
        }
      }
    end,
  pos = {x = 0, y = 0},
  rarity = 3,
  unlocked = true,
  cost = 7,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  calculate = function(self, card, context)
    if context.individual and context.other_card and context.cardarea == G.play and not context.end_of_round then
      local c = context.other_card
      if c:is_suit("Spades") and c:get_id() == 8 then
        return {
          x_mult = card.ability.extra.var1

        }
      end
    end
  end
}

--redbull
SMODS.Atlas{
  key = 'redbull',
  path = 'redbull.png',
  px = 71,
  py = 95,
}
SMODS.Joker{
  key = 'redbull',
  loc_txt = {
    name = 'Red Bull',
    text = {
      'earn {C:money}#1#${} when',
      'a {C:attention}skip{} is taken',
      'consumed in {C:attention}#2#{} rounds',

    }
  },
  atlas = 'redbull',
  config = {
    extra = {
      var1= 20,
      var2= 3
    }
  },



    loc_vars = function(self, info_queue, card)
      return {
        vars = {
          card.ability.extra.var1,
          card.ability.extra.var2
        }
      }
    end,
  pos = {x = 0, y = 0},
  rarity = 1,
  cost = 3,
  unlocked = true,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  calculate = function(self, card, context)
    -- Only run if in play, not blueprint, and at end of round
    if not context.blueprint and context.end_of_round and context.main_eval and card.area == G.jokers then
      card.ability.extra.var2 = card.ability.extra.var2 - 1
  
      if card.ability.extra.var2 <= 0 then
        destroy_joker(card)
        return {
          message = 'Eaten!',
          colour = G.C.MULT,
          card = card
        }
      else
        return {
          message = 'Sip!',
          colour = G.C.MULT,
          card = card
        }
      end
    end
  
    -- Grant money when skipping blind
    if context.skip_blind then
      return {
        dollars = card.ability.extra.var1
      }
    end
  end
  
  
}

--communist
SMODS.Atlas{
  key = 'leo',
  path = 'leo.png',
  px = 71,
  py = 95,
}
SMODS.Joker{
  key = 'leo',
  loc_txt = {
    name = 'Communist',
    text = {
      'This card has ',
      '{X:mult,C:white}X#1#{} Mult for every',
      'Joker to the right of it',
      '{C:inactive}(Currently:{} {X:mult,C:white}X#2#{}{C:inactive})'
    }
  },
  atlas = 'leo',
  config = {
    extra = {
      var1 = '1',
      var2 = 0 -- this stores current multiplier
    }
  },
  loc_vars = function(self, info_queue, card)
    return {
      vars = {
        card.ability.extra.var1,
        tostring(card.ability.extra.var2)
      }
    }
  end,
  pos = {x = 0, y = 0},
  rarity = 'Rare',
  unlocked = true,
  cost = 9,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,


  update = function(self, card)
    if G.jokers and G.jokers.cards then
      local mult = 0
      for _, other in ipairs(G.jokers.cards) do
        if card ~= other and card.T.x + card.T.w / 2 < other.T.x + other.T.w / 2 then
          mult = mult + 1
        end
      end
      card.ability.extra.var2 = mult
    end
  end,


  calculate = function(self, card, context)
    if context.joker_main and context.cardarea == G.jokers then
      return {
        x_mult = card.ability.extra.var2
      }
    end
  end
}




--kanye west
SMODS.Atlas{
  key = 'kanye',
  path = 'kanye.png',
  px = 568,
  py = 760,
}
SMODS.Joker{
  key = 'kanye',
  loc_txt = {
    name = 'Kanye West',
    text = {
      '{X:mult,C:white}X#3#{} Mult',
      '{C:green}#1# in #2#{} chance to destroy',
      'and create an {C:attention}eternal Ye{}'
    }
  },
  atlas = 'kanye',
  config = {
    extra = {
      var2 = 6,
      mult = 3
    }
  },

  loc_vars = function(self, info_queue, card)
    return {
      vars = {
        G.GAME.probabilities.normal,
        card.ability.extra.var2,
        card.ability.extra.mult
      }
    }
  end,

  pos = {x = 0, y = 0},
  rarity = 2,
  unlocked = true,
  cost = 8,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = false,

  
  calculate = function(self, card, context)
    -- Apply x_mult during play if this Joker is being used
    if context.joker_main and context.cardarea == G.jokers then
      return {
        x_mult = card.ability.extra.mult
      }
    end
  
    -- At end of round, chance to destroy this Joker and spawn 'ye'
    if context.end_of_round and not (context.blueprint) and context.main_eval then
      local chance = G.GAME.probabilities.normal / card.ability.extra.var2
  
      if pseudorandom("Kanye West") < chance then
        destroy_joker(card, function()
          local new_card = create_card('Joker', G.joker, nil, nil, nil, nil, 'j_hcrf_ye')
          new_card:set_eternal(true)
          new_card:add_to_deck()
          G.jokers:emplace(new_card)
        end)
  
        return {
          message = 'BUT HE MADE GRADUATION!!!',
          colour = G.C.MULT,
          card = card
        }
      else
        return {
          message = 'Still Good!',
          colour = G.C.CHIPS,
          card = card
        }
      end
    end
  
    return nil  -- Explicit fallback to avoid accidental behavior
  end
  
}

--ye
SMODS.Atlas{
  key = 'ye',
  path = 'ye.png',
  px = 71,
  py = 95,
}
SMODS.Joker{
  key = 'ye',
  loc_txt = {
    name = 'Ye',
    text = {
      'Does Nothing?'
    }
  },
  atlas = 'ye',
  config = {
    extra = {
      var2=2
    }
  },

  loc_vars = function(self, info_queue, card)
    return {
      vars = {
        G.GAME.probabilities.normal,
        card.ability.extra.var2,
      }
    }
  end,

  pos = {x = 0, y = 0},
  rarity = 1,
  unlocked = true,
  cost = 8,
  discovered = true,
  blueprint_compat = false,
  eternal_compat = true,
  perishable_compat = false,
  yes_pool_flag = 'ahitm_ye_can_spawn',
  
  calculate = function(self, card, context)
    if context.end_of_round and not (context.blueprint) and context.main_eval then
      local chance = G.GAME.probabilities.normal / card.ability.extra.var2
    if pseudorandom("Ye") < chance then
        return {
          message = 'FUCK YOU!',
          colour = G.C.MULT,
          card = card
        }
      else
        return {
          message = 'BITCH!',
          colour = G.C.CHIPS,
          card = card
        }
      end
    end

  end
  
}

--faster
SMODS.Atlas{
  key = 'faster',
  path = 'faster.png',
  px = 71,
  py = 95,
}
SMODS.Joker{
  key = 'faster',
  loc_txt = {
    name = 'Faster',
    text = {
      'If you beat a Blind',
      'on your {C:attention}First Hand{}',
      'create a {C:attention}Speed Tag{}'
    }
  },
  atlas = 'faster',
  config = {
    extra = {
    }
  },


  pos = {x = 0, y = 0},
  rarity = 1,
  unlocked = true,
  cost = 4,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,

      calculate = function(self, card, context)
  if context.end_of_round and context.main_eval and G.GAME.current_round.hands_played == 1 then
      add_tags("tag_skip")
      return {
        message = 'Faster!',
        colour = G.C.Chip,
        card = card
      }
    end
  end 
}

--time bomb
SMODS.Atlas{
  key = 'bomb',
  path = 'bomb.png',
  px = 71,
  py = 95,
}
SMODS.Joker{
  key = 'bomb',
  loc_txt = {
    name = 'Time Bomb',
    text = {
      '{C:mult}+#3#{} Mult',
      '{C:green}#1# in #2#{} chance to destroy',
      'itself and all {C:attention}adjacent jokers{}'
    }
  },
  atlas = 'bomb',
  config = {
    extra = {
      var2 = 7,
      mult = 30
    }
  },

  loc_vars = function(self, info_queue, card)
    return {
      vars = {
        G.GAME.probabilities.normal,
        card.ability.extra.var2,
        card.ability.extra.mult
      }
    }
  end,

  pos = {x = 0, y = 0},
  rarity = 1,
  unlocked = true,
  cost = 8,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
    calculate = function(self, card, context)
    -- Apply x_mult during play if this Joker is being used
    if context.joker_main and context.cardarea == G.jokers then
      return {
        mult = card.ability.extra.mult
      }
    end
  
    -- At end of round, chance to destroy this Joker and spawn 'ye'
    if context.end_of_round and not (context.blueprint) and context.main_eval then
      local chance = G.GAME.probabilities.normal / card.ability.extra.var2
  
      if pseudorandom("Time Bomb") < chance then
      local other_joker
      local other_joker2
      for i, v in ipairs(G.jokers.cards) do
        if v == card then
          other_joker = G.jokers.cards[i + 1]
          other_joker2 = G.jokers.cards[i - 1]
          break
        end
      end
        destroy_joker(card)
        if other_joker then
        destroy_joker(other_joker)
        end
        if other_joker2 then
        destroy_joker(other_joker2)  
        end
        return {
          message = 'BOOM!',
          colour = G.C.MULT,
          card = card
        }
      else
        return {
          message = 'Safe!',
          colour = G.C.CHIPS,
          card = card
        }
      end
    end
  
    return nil  -- Explicit fallback to avoid accidental behavior
  end
}


-- Adachi 
SMODS.Atlas{
  key = 'adachi',
  path = 'adachi.png',
  px = 71,
  py = 95,
}
SMODS.Joker{
  key = 'adachi',
  loc_txt = {
    name = 'Toru Adachi',
    text = {
      '{C:attention}+2 Joker Slots{}'
    }
  },
  atlas = 'adachi',
  config = {
    extra = {
      slots = 2
    }
  },

  pos = {x = 0, y = 0},
  rarity = 3,
  unlocked = true,
  cost = 10,
  discovered = true,
  blueprint_compat = false,
  eternal_compat = true,
  perishable_compat = true,

  add_to_deck = function(self, card, from_debuff)
    G.jokers.config.card_limit = G.jokers.config.card_limit + card.ability.extra.slots
  end,

  remove_from_deck = function(self, card, from_debuff)
    G.jokers.config.card_limit = G.jokers.config.card_limit - card.ability.extra.slots
  end,


}

--Deal
SMODS.Atlas{
  key = 'deal',
  path = 'deal.png',
  px = 499,
  py = 665,
}
SMODS.Joker{
  key = 'deal',
  loc_txt = {
    name = 'Evil Deal',
    text = {
      'When a {C:attention}6{} is played',
      '{C:attention}permanently{} gains',
      '+{X:mult,C:white}1X{} Mult'
    }
  },

  atlas = 'deal',
  config = {
    extra = {
      var1 = 1
    }
  },

  loc_vars = function(self, info_queue, card)
    return {
      vars = {
        card.ability.extra.var1
      }
    }
  end,

  pos = {x = 0, y = 0},
  soul_pos = { x = 1, y = 0 },
  rarity = 3,
  unlocked = true,
  cost = 50,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
    config = {
    extra = {
      mult_mod = 1
    }
  },

  loc_vars = function(self, info_queue, card)
    return {
      vars = {
        card.ability.extra.mult_mod
      }
    }
  end,


  calculate = function(self, card, context)
    if context.individual and context.cardarea == G.play and context.other_card then
            local card_id = context.other_card:get_id()
      if card_id == 6 then 
      local c = context.other_card
      -- Stack permanent multiplier on the card itself
      c.ability.perma_x_mult = (c.ability.perma_x_mult or 1) + card.ability.extra.mult_mod

      return {
        extra = { message = string.format("+1X Mult", c.ability.perma_x_mult), colour = G.C.MULT },
        colour = G.C.MULT,
        card = card
      }
    elseif context.other_card and context.cardarea == G.play then
      local c = context.other_card
      if c.ability.perma_x_mult and c.ability.perma_x_mult > 1 then
        return {
          x_mult = c.ability.perma_x_mult
        }
      end
      end
    end
  end
}

--King Crimson
SMODS.Atlas{
  key = 'crimson',
  path = 'crimsonsheet.png',
  px = 499,
  py = 665,
}
SMODS.Joker{
  key = 'crimson',
  loc_txt = {
    name = 'King Crimson',
    text = {
      'Enter the payout phase',
      'when {C:attention}skipping a Blind{}'
    }
  },

  atlas = 'crimson',
  config = {
    extra = {
      var1 = 1
    }
  },

  loc_vars = function(self, info_queue, card)
    return {
      vars = {
        card.ability.extra.var1
      }
    }
  end,

  pos = {x = 0, y = 0},
  soul_pos = { x = 1, y = 0 },
  rarity = 4,
  unlocked = true,
  cost = 20,
  discovered = true,
  blueprint_compat = false,
  eternal_compat = true,

  calculate = function(self, card, context)
  if context.skip_blind then
    G.STATE = G.STATES.ROUND_EVAL
    G.STATE_COMPLETE = false
    G.GAME.skip_money = false
    G.GAME.current_round.skipped = false

    return {
      message = "Time Erased",
      colour = G.C.RED,
      card = card
    }
  end
end
}


--Hisoka
SMODS.Atlas{
  key = 'hisoka',
  path = 'Hisoka.png',
  px = 499,
  py = 665,
}

SMODS.Joker{
  key = 'hisoka',
  loc_txt = {
    name = 'Hisoka',
    text = {
      'Every played {C:attention}card{}',
      '{C:attention}permanently{} gains',
      '+{X:mult,C:white}0.1X{} Mult'
    }
  },

  atlas = 'hisoka',
  config = {
    extra = {
      mult_mod = 0.1
    }
  },

  loc_vars = function(self, info_queue, card)
    return {
      vars = {
        card.ability.extra.mult_mod
      }
    }
  end,

  pos = {x = 0, y = 0},
  soul_pos = { x = 1, y = 0 },
  rarity = 4,
  unlocked = true,
  cost = 20,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,

  calculate = function(self, card, context)
    if context.individual and context.cardarea == G.play and context.other_card then
      local c = context.other_card
      -- Stack permanent multiplier on the card itself
      c.ability.perma_x_mult = (c.ability.perma_x_mult or 1) + card.ability.extra.mult_mod

      return {
        extra = { message = string.format("+0.1X Mult", c.ability.perma_x_mult), colour = G.C.MULT },
        colour = G.C.MULT,
        card = card
      }
    elseif context.other_card and context.cardarea == G.play then
      local c = context.other_card
      if c.ability.perma_x_mult and c.ability.perma_x_mult > 1 then
        return {
          x_mult = c.ability.perma_x_mult
        }
      end
    end
  end
}





-- payaso
SMODS.Atlas{
  key = 'payaso',
  path = 'payaso.png',
  px = 499,
  py = 665,
}
SMODS.Joker{
  key = 'payaso',
  loc_txt = {
    name = 'Payaso',
    text = {
      'Gain {C:attention}+#2#{} hand size',
      'every {C:attention}#1#{} cards played.',
      '{C:inactive}(#3# cards left)'
    }
  },

  atlas = 'payaso',

  config = {
    extra = {
      cards_played_count = 37,
      hand_size_increase = 1,
      cards_togo = 37,
      handsize_gained = 0
    }
  },

   loc_vars = function(self, info_queue, card)
    return {
      vars = {
        card.ability.extra.cards_played_count,
        card.ability.extra.hand_size_increase,
        card.ability.extra.cards_togo,
        card.ability.extra.handsize_gained
      }
    }
  end,

  calculate = function(self, card, context)
  if not context.blueprint and context.individual and context.cardarea == G.play then
    card.ability.extra.cards_togo = card.ability.extra.cards_togo - 1

    if card.ability.extra.cards_togo == 0 then
        local increase = card.ability.extra.hand_size_increase or 1
        G.hand:change_size(increase)
        card.ability.extra.handsize_gained = card.ability.extra.handsize_gained + 1
        card.ability.extra.cards_togo = 37
        return {
          message = "Hand size increased!",
          colour = G.C.CHIPS,
          card = card
        }
      end
    end
    if not context.blueprint and context.selling_card and context.card ~= card then
      local remove = (card.ability.extra.handsize_gained)
      G.hand:change_size(remove)
          return {
          message = "Hand size increased!",
          colour = G.C.CHIPS,
          card = card
        }
    end
  end,

  pos = {x = 0, y = 0},
  soul_pos = {x = 1, y = 0},
  rarity = 4,
  unlocked = true,
  cost = 20,
  discovered = true,
  blueprint_compat = false,
  eternal_compat = true,
}


--Schrepper
SMODS.Atlas{
  key = 'schrepper',
  path = 'schrepper.png',
  px = 499,
  py = 665,
}

SMODS.Joker{
  key = 'schrepper',
  loc_txt = {
    name = 'Schrepper',
    text = {
      'Create a {C:dark_edition}polychrome{} consumable',
      'if played hand does',
      'not contain a {C:attention}Straight{}',
      '{C:inactive}(Must not have Room){}'
    }
  },

  atlas = 'schrepper',
  config = {
    extra = {
      var1 = 1
    }
  },

  loc_vars = function(self, info_queue, card)
    return {
      vars = {
        card.ability.extra.var1
      }
    }
  end,

  pos = {x = 0, y = 0},
  soul_pos = { x = 1, y = 0 },
  rarity = 4,
  unlocked = true,
  cost = 20,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,

  calculate = function(self, card, context)
    if context.joker_main and context.cardarea == G.jokers and context.poker_hands then
      local has_straight = context.poker_hands["Straight"] and next(context.poker_hands["Straight"])
      local has_straight_flush = context.poker_hands["Straight Flush"] and next(context.poker_hands["Straight Flush"])

      if not has_straight and not has_straight_flush then
        G.E_MANAGER:add_event(Event({
          trigger = 'after',
          delay = 0.2,
          func = function()
            local types = {'Tarot', 'Planet', 'Spectral'}
            local chosen = pseudorandom_element(types)
            local card_to_add = create_card(chosen, G.consumeables, nil, nil, nil, true)
            card_to_add:set_edition('e_polychrome', true)
            G.consumeables:emplace(card_to_add)
            return true
          end
        }))

        return {
          message = "Create!",
          colour = G.C.DARK_EDITION,
          card = card
        }
      end
    end
  end
}




------------------------------------------
-------------MOD CODE END ----------------
