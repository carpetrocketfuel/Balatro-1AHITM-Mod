--escchips
SMODS.Atlas{
  key = 'escchips',
  path = 'escchips.png',
  px = 71,
  py = 95,
}
SMODS.Joker{
  key = 'escchips',
  loc_txt = {
    name = 'Escapist of Wits',
    text = {
      '{C:chips}+#1#{} Chips if played',
      'hand contains no ',
      'scoring {C:attention}face cards{}'
    }
  },
  atlas = 'escchips',
  config = {
    extra = {
      var1= 60
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
      if context.joker_main and context.cardarea == G.jokers then
    local faces = false
    -- Checks if played hand contains a face card
    for i = 1, #context.scoring_hand do
      if context.scoring_hand[i]:is_face() then faces = true end
    end

        if not faces then
          return {
          chips = card.ability.extra.var1
          }
        end
      end
  end
}

--escmult
SMODS.Atlas{
  key = 'escmult',
  path = 'escmult.png',
  px = 71,
  py = 95,
}
SMODS.Joker{
  key = 'escmult',
  loc_txt = {
    name = 'Escapist of Strenght',
    text = {
      '{C:mult}+#1#{} Mult if played',
      'hand contains no',
      'scoring {C:attention}face cards{}'
    }
  },
  atlas = 'escmult',
  config = {
    extra = {
      var1= 12
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
      if context.joker_main and context.cardarea == G.jokers then
    local faces = false
    -- Checks if played hand contains a face card
    for i = 1, #context.scoring_hand do
      if context.scoring_hand[i]:is_face() then faces = true end
    end

        if not faces then
          return {
          mult = card.ability.extra.var1
          }
        end
      end
  end
}

--escmoney
SMODS.Atlas{
  key = 'escmoney',
  path = 'escmoney.png',
  px = 71,
  py = 95,
}
SMODS.Joker{
  key = 'escmoney',
  loc_txt = {
    name = 'Escapist of Fortune',
    text = {
      'earn {C:money}$#1#{} if played',
      'hand contains no',
      'scoring {C:attention}face cards{}'
    }
  },
  atlas = 'escmoney',
  config = {
    extra = {
      var1= 5
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
      if context.joker_main and context.cardarea == G.jokers then
    local faces = false
    -- Checks if played hand contains a face card
    for i = 1, #context.scoring_hand do
      if context.scoring_hand[i]:is_face() then faces = true end
    end

        if not faces then
          return {
          dollars = card.ability.extra.var1
          }
        end
      end
  end
}

--Paint the Town
SMODS.Atlas{
  key = 'blue',
  path = 'blue.png',
  px = 71,
  py = 95,
}
SMODS.Joker{
  key = 'blue',
  loc_txt = {
    name = 'Paint The Town',
    text = {
      'All played',
      '{C:attention}face cards{}',
      'gain a {C:dark_edition}Foil{}'

    }
  },
  atlas = 'blue',
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
  cost = 6,
  discovered = true,
  blueprint_compat = false,
  eternal_compat = true,
  calculate = function(self, card, context)
  if context.individual and context.cardarea == G.play and context.other_card then
    local c = context.other_card
    if c:is_face() then
      c:set_edition('e_foil', true)
    end
  end
end
}

--Rock Bottom
SMODS.Atlas{
  key = 'rock',
  path = 'rock.png',
  px = 71,
  py = 95,
}
SMODS.Joker{
  key = 'rock',
  loc_txt = {
    name = 'Rock Bottom',
    text = {
      'When leaving your {C:attention}First Shop{} all',
      'other Jokers gain an {C:attention}Eternal Sticker{}',
      'When sold all Jokers',
      'lose {C:attention}all their Stickers{}'
    }
  },
  atlas = 'rock',
  config = {
    extra = {
      shop2 = false,
      sticker = "eternal"
    }
  },

  loc_vars = function(self, info_queue, card)
    return {
      vars = {
        G.GAME.probabilities.normal,
        card.ability.extra.shop2,
        card.ability.extra.sticker
      }
    }
  end,

  pos = {x = 0, y = 0},
  rarity = 2,
  unlocked = true,
  cost = 4,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = false,
  perishable_compat = true,

calculate = function(self, card, context)
  if context.ending_shop and context.cardarea == G.jokers and not context.blueprint and not card.ability.extra.shop2 then
    local area = G.jokers.cards
    local applied = false

    for i = 1, #area do
      local other = area[i]

      if other ~= card and other.ability.set == 'Joker' then
        if not other.ability[card.ability.extra.sticker] then
          applied = true
          card.ability.extra.shop2 = true

          G.E_MANAGER:add_event(Event({
            trigger = 'immediate',
            func = function()
              card:juice_up()
              other:add_sticker(card.ability.extra.sticker, true)
              if other.ability.perishable then 
                other.ability.perishable = false 
              end
              return true
            end
          }))
        end
      end
    end

    if applied then
      return {
        message = 'Pause!',
        colour = G.C.MULT,
        card = card
      }
    end
  end
  if not context.blueprint and context.selling_card and context.card ~= card then
    for i = 1, #G.jokers.cards do
      local j = G.jokers.cards[i]

      -- skip itself if you want
      if j ~= card then
        j.ability.perishable = nil
        j.pinned = nil
        j.ability.pinned = nil
        j:set_rental(nil)

        if not j.sob then
          j:set_eternal(nil)
        end

        j.ability.banana = nil
        j.ability.cry_possessed = nil

        -- remove stickers (this is the important part)
        for _, sticker_key in ipairs(SMODS.Sticker.obj_buffer) do
          local sticker = SMODS.Stickers[sticker_key]
          if sticker and j.ability[sticker_key] then
            j.ability[sticker_key] = nil
          end
        end
      end
    end

    return {
      message = "Wiped!",
      colour = G.C.RED,
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



--klepto
SMODS.Atlas{
  key = 'klepto',
  path = 'kleptomancy.png',
  px = 568,
  py = 760,
}
SMODS.Joker{
  key = 'klepto',
  loc_txt = {
    name = 'Kleptomancy',
    text = {
      'Allows you take',
      '{C:attention}one {}additional card',
      'in every {C:attention}Booster Pack{}'

    }
  },
  atlas = 'klepto',
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
  cost = 10,
  discovered = true,
  blueprint_compat = false,
  eternal_compat = true,

    calculate = function(self, card, context)

end
}

--curveball
SMODS.Atlas{
  key = 'curveball',
  path = 'curveball.png',
  px = 71,
  py = 95,
}
SMODS.Joker{
  key = 'curveball',
  loc_txt = {
    name = 'Curveball',
    text = {
      'Every Hand is',
      'considered a {C:attention}Flush{}'
    }
  },
  atlas = 'curveball',
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

--taitai
SMODS.Atlas{
  key = 'taitai',
  path = 'taitai.png',
  px = 499,
  py = 665,
}
SMODS.Joker{
  key = 'taitai',
  loc_txt = {
    name = 'Taitai',
    text = {
      '???'
    }
  },
 
  atlas = 'taitai',
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