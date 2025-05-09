--- STEAMODDED HEADER
--- MOD_NAME: 1AHITM
--- MOD_ID: EXAMPLEJOKER
--- MOD_AUTHOR: [Nikkie]
--- MOD_DESCRIPTION: Klassen Mod.
--- PREFIX: xmpl
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

--- Gets a random consumable type
--- @param seed string
--- @return SMODS.ConsumableType
function poll_consumable_type(seed)
  local types = {}

  for _, v in pairs(SMODS.ConsumableTypes) do
    types[#types + 1] = v
  end

  return pseudorandom_element(types, pseudoseed(seed))
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
    name = 'Monster Energy',
    text = {
      'Gain a random',
      '{C:attention}skip tag{} at the',
      'end of round',
      'consumed in {C:attention}#1#{} rounds'
    }
  },
  atlas = 'monster',
  config = {
    extra = {
      var1= 4
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
  blueprint_compat = false,
  eternal_compat = true,

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
      '{C:green}#1# in #2#{} chance for cards',
      'to be drawn {C:attention}face down{}',
      'gain {C:money}4${} for every',
      '{C:attention}face down card{} played'
    }
  },
  atlas = 'fiab',
  config = {
    extra = {
      var1= 1,
      var2= 4
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
  cost = 4,
  unlocked = true,
  discovered = true,
  blueprint_compat = false,
  eternal_compat = true,

}



--squirrel
SMODS.Atlas{
  key = 'squirrel',
  path = 'Jokers.png',
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
      '{C:inactive}(Currently:{} {C:common}#1#{}{C:inactive})'
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
  rarity = 'Rare',
  unlocked = true,
  cost = 8,
  discovered = true,
  blueprint_compat = false,
  eternal_compat = true,
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
      'retrigger all {C:attention}played{} cards',
      'with {C:attention}seals{} once and',
      '{C:attention}purple seals{} twice'
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
  blueprint_compat = false,
  eternal_compat = true,
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
      'Retrigger {C:attention}#1#{} two',
      'additional times'
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
  blueprint_compat = false,
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
      'this joker gains',
      '{C:chips}+#1# {}chips if played hand',
      'conatins a {C:attention}Three of a Kind{}',
      '{C:inactive}(Currently {C:chips}+#2# {}{C:inactive}chips)'
    }
  },
  atlas = 'concentrate',
  config = {
    extra = {
      var1= 11,
      var2= 0
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
  cost = 9,
  unlocked = true,
  discovered = true,
  blueprint_compat = false,
  eternal_compat = true,
  calculate = function(self, card, context)
    -- Upgrade var2 if Three of a Kind is played
    if not context.blueprint and context.before and context.main_eval then
      if next(context.poker_hands['Three of a Kind']) then
        card.ability.extra.var2 = card.ability.extra.var2 + card.ability.extra.var1
        return {
          message = 'Upgrade!',
          colour = G.C.CHIPS
        }
      end
    end
  
    -- Apply chip value during scoring
    if context.joker_main then
      return {
        chips = card.ability.extra.var2,
        card = card
      }
    end
  end  
}

--adachi
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
      '{C:attention}+5 Joker Slots{}',
      'Removes all other {C:rare}Rare{}',
      'Jokers from appearing',
      '{C:inactive}(Including Wraith and Rare tags{C:inactive})'
    }
  },
  atlas = 'adachi',
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
  rarity = 3,
  unlocked = true,
  cost = 4,
  discovered = true,
  blueprint_compat = false,
  eternal_compat = true,
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
      '???'

    }
  },
  atlas = 'd4c',
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
  blueprint_compat = false,
  eternal_compat = true,
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
  if context.end_of_round and context.main_eval and G.GAME.blind.boss and not context.blueprint and card.ability.housecheck and G.GAME.current_round.hands_played == 3 then
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
    name = 'Earfquake',
    text = {
      '???'
    }
  },
  atlas = 'igor',
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
  blueprint_compat = false,
  eternal_compat = true,
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
      '???'

    }
  },
  atlas = 'filthy',
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
  cost = 5,
  discovered = true,
  blueprint_compat = false,
  eternal_compat = true,
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
  blueprint_compat = false,
  eternal_compat = true,
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
    if context.individual and context.other_card then
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
  blueprint_compat = false,
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
      var2 = '1'
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
  rarity = 'Rare',
  unlocked = true,
  cost = 9,
  discovered = true,
  blueprint_compat = false,
  eternal_compat = true,
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
      'and create an {C:attention}eternal Jimbo{}'
    }
  },
  atlas = 'kanye',
  config = {
    extra = {
      var2 = 9,
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
          local new_card = create_card('Joker', G.joker, nil, nil, nil, nil, 'j_joker')
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
      var1 = 1,
      var2 = 7,
      mult = 30
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
  rarity = 1,
  unlocked = true,
  cost = 8,
  discovered = true,
  blueprint_compat = false,
  eternal_compat = true,

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

  soul_pos = { x = 1, y = 0 },
  rarity = 4,
  unlocked = true,
  cost = 20,
  discovered = true,
  blueprint_compat = false,
  eternal_compat = true,
}

--payaso
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
      '???'
    }
  },

  atlas = 'payaso',
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

  soul_pos = { x = 1, y = 0 },
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
      'Create a {C:dark_edition}Negative{} consumable',
      'if played hand does',
      'not contain a {C:attention}Straight{}'
    }
  },
 
  atlas = 'schrepper',
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

  soul_pos = { x = 1, y = 0 },
  rarity = 4,
  unlocked = true,
  cost = 20,
  discovered = true,
  blueprint_compat = false,
  eternal_compat = true,
}



------------------------------------------
-------------MOD CODE END ----------------
