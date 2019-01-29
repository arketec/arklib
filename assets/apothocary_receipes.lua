local ingredients = require('apothocary_ingredients')

local recipes = {
    spectrolus = {
        number = 1,
        type = 'generating',
        items = {
            ingredients.petal_red,
            ingredients.petal_red,
            ingredients.petal_green,
            ingredients.petal_green,
            ingredients.petal_blue,
            ingredients.petal_blue,
            ingredients.petal_white,
            ingredients.petal_white,
            ingredients.rune_winter,
            ingredients.rune_air,
            ingredients.pixie_dust
        }
    },
    endoflame = {
        number = 2,
        type = 'generating',
        items = {
            ingredients.petal_brown,
            ingredients.petal_brown,
            ingredients.petal_red,
            ingredients.petal_light_gray
        }
    },
    hydroangeas = {
        number = 3,
        type = 'generating',
        items = {
            ingredients.petal_blue,
            ingredients.petal_blue,
            ingredients.petal_cyan,
            ingredients.petal_cyan
        }
    },
    thermalily = {
        number = 4,
        type = 'generating',
        items = {
            ingredients.petal_red,
            ingredients.petal_orange,
            ingredients.petal_orange,
            ingredients.rune_earth,
            ingredients.rune_fire
        }
    },
    rosa_arcana = {
        number = 5,
        type = 'generating',
        items = {
            ingredients.petal_pink,
            ingredients.petal_pink,
            ingredients.petal_purple,
            ingredients.petal_purple,
            ingredients.petal_lime,
            ingredients.rune_mana
        }
    },
    munchdew = {
        number = 6,
        type = 'generating',
        items = {
            ingredients.petal_lime,
            ingredients.petal_lime,
            ingredients.petal_red,
            ingredients.petal_red,
            ingredients.petal_green,
            ingredients.rune_gluttony
        }
    },
    entropinnyum = {
        number = 7,
        type = 'generating',
        items = {
            ingredients.petal_red,
            ingredients.petal_red,
            ingredients.petal_gray,
            ingredients.petal_gray,
            ingredients.petal_white,
            ingredients.petal_white,
            ingredients.rune_wrath,
            ingredients.rune_fire
        }
    },
    kekimurus = {
        number = 8,
        type = 'generating',
        items = {
            ingredients.petal_white,
            ingredients.petal_white,
            ingredients.petal_orange,
            ingredients.petal_orange,
            ingredients.petal_brown,
            ingredients.petal_brown,
            ingredients.rune_gluttony,
            ingredients.pixie_dust
        }
    },
    gourmaryllis = {
        number = 9,
        type = 'generating',
        items = {
            ingredients.petal_light_gray,
            ingredients.petal_light_gray,
            ingredients.petal_yellow,
            ingredients.petal_yellow,
            ingredients.petal_red,
            ingredients.rune_fire,
            ingredients.rune_summer
        }
    },
    narslimmus = {
        number = 10,
        type = 'generating',
        items = {
            ingredients.petal_lime,
            ingredients.petal_lime,
            ingredients.petal_green,
            ingredients.petal_green,
            ingredients.petal_black,
            ingredients.rune_summer,
            ingredients.rune_water
        }
    },
    rafflowsia = {
        number = 11,
        type = 'generating',
        items = {
            ingredients.petal_purple,
            ingredients.petal_purple,
            ingredients.petal_green,
            ingredients.petal_green,
            ingredients.petal_black,
            ingredients.rune_earth,
            ingredients.rune_pride,
            ingredients.pixie_dust
        }
    },
    dandelifeon = {
        number = 12,
        type = 'generating',
        items = {
            ingredients.petal_purple,
            ingredients.petal_purple,
            ingredients.petal_lime,
            ingredients.petal_green,
            ingredients.rune_water,
            ingredients.rune_fire,
            ingredients.rune_earth,
            ingredients.rune_air,
            ingredients.additional_item -- gaia spirit
        }
    },
    pure_daisy = {
        number = 13,
        type = 'basic',
        items = {
            ingredients.petal_white,
            ingredients.petal_white,
            ingredients.petal_white,
            ingredients.petal_white
        }
    },
    manastar = {
        number = 14,
        type = 'basic',
        items = {
            ingredients.petal_light_blue,
            ingredients.petal_green,
            ingredients.petal_red,
            ingredients.petal_cyan
        }
    },
    agricarnation  = {
        number = 15,
        type = 'functional',
        items = {
            ingredients.petal_lime,
            ingredients.petal_lime,
            ingredients.petal_green,
            ingredients.petal_yellow,
            ingredients.rune_spring,
            ingredients.redstone_root
        }
    },
    bellethorne  = {
        number = 16,
        type = 'functional',
        items = {
            ingredients.petal_red,
            ingredients.petal_red,
            ingredients.petal_red,
            ingredients.petal_cyan,
            ingredients.petal_cyan,
            ingredients.redstone_root
        }
    },
    bubbell  = {
        number = 17,
        type = 'functional',
        items = {
            ingredients.petal_blue,
            ingredients.petal_blue,
            ingredients.petal_light_blue,
            ingredients.petal_light_blue,
            ingredients.petal_cyan,
            ingredients.petal_cyan,
            ingredients.pixie_dust,
            ingredients.rune_water,
            ingredients.rune_summer
        }
    },
    clayconia  = {
        number = 18,
        type = 'functional',
        items = {
            ingredients.petal_light_gray,
            ingredients.petal_light_gray,
            ingredients.petal_gray,
            ingredients.petal_cyan,
            ingredients.rune_earth
        }
    },
    daffomill  = {
        number = 19,
        type = 'functional',
        items = {
            ingredients.petal_white,
            ingredients.petal_white,
            ingredients.petal_brown,
            ingredients.petal_yellow,
            ingredients.rune_air,
            ingredients.redstone_root
        }
    },
    dreadthorne   = {
        number = 20,
        type = 'functional',
        items = {
            ingredients.petal_black,
            ingredients.petal_black,
            ingredients.petal_black,
            ingredients.petal_cyan,
            ingredients.petal_cyan,
            ingredients.redstone_root
        }
    },
    exoflame   = {
        number = 21,
        type = 'functional',
        items = {
            ingredients.petal_red,
            ingredients.petal_gray,
            ingredients.petal_light_gray,
            ingredients.rune_fire,
            ingredients.rune_summer
        }
    },
    fallen_kanade = {
        number = 22,
        type = 'functional',
        items = {
            ingredients.petal_white,
            ingredients.petal_white,
            ingredients.petal_yellow,
            ingredients.petal_yellow,
            ingredients.petal_orange,
            ingredients.rune_spring
        }
    },
    heisei_dream = {
        number = 23,
        type = 'functional',
        items = {
            ingredients.petal_magenta,
            ingredients.petal_magenta,
            ingredients.petal_purple,
            ingredients.petal_pink,
            ingredients.rune_wrath,
            ingredients.pixie_dust
        }
    },
    hopperhock  = {
        number = 24,
        type = 'functional',
        items = {
            ingredients.petal_gray,
            ingredients.petal_gray,
            ingredients.petal_light_gray,
            ingredients.petal_light_gray,
            ingredients.rune_air,
            ingredients.redstone_root
        }
    },
    hyacidus = {
        number = 25,
        type = 'functional',
        items = {
            ingredients.petal_purple,
            ingredients.petal_purple,
            ingredients.petal_magenta,
            ingredients.petal_magenta,
            ingredients.petal_green,
            ingredients.rune_water,
            ingredients.rune_autumn,
            ingredients.redstone_root
        }
    },
    jaded_amaranthus = {
        number = 26,
        type = 'functional',
        items = {
            ingredients.petal_purple,
            ingredients.petal_lime,
            ingredients.petal_green,
            ingredients.rune_spring,
            ingredients.redstone_root
        }
    },
    jiyuulia = {
        number = 27,
        type = 'functional',
        items = {
            ingredients.petal_pink,
            ingredients.petal_pink,
            ingredients.petal_purple,
            ingredients.petal_light_gray,
            ingredients.rune_water,
            ingredients.rune_air
        }
    },
    loonium = {
        number = 28,
        type = 'functional',
        items = {
            ingredients.petal_green,
            ingredients.petal_green,
            ingredients.petal_green,
            ingredients.petal_green,
            ingredients.petal_gray,
            ingredients.redstone_root,
            ingredients.rune_sloth,
            ingredients.rune_envy,
            ingredients.rune_gluttony,
            ingredients.pixie_dust
        }
    },
    marimorphosis = {
        number = 29,
        type = 'functional',
        items = {
            ingredients.petal_gray,
            ingredients.petal_yellow,
            ingredients.petal_green,
            ingredients.petal_red,
            ingredients.rune_earth,
            ingredients.rune_fire,
            ingredients.redstone_root
        }
    },
    medumone  = {
        number = 30,
        type = 'functional',
        items = {
            ingredients.petal_brown,
            ingredients.petal_brown,
            ingredients.petal_gray,
            ingredients.petal_gray,
            ingredients.rune_earth,
            ingredients.redstone_root
        }
    },
    orechid  = {
        number = 31,
        type = 'functional',
        items = {
            ingredients.petal_gray,
            ingredients.petal_gray,
            ingredients.petal_yellow,
            ingredients.petal_green,
            ingredients.petal_red,
            ingredients.rune_pride,
            ingredients.rune_greed, -- doesn't yet exist
            ingredients.redstone_root,
            ingredients.pixie_dust
        }
    },
    orechid_ignem = {
        number = 32,
        type = 'functional',
        items = {
            ingredients.petal_red,
            ingredients.petal_red,
            ingredients.petal_white,
            ingredients.petal_white,
            ingredients.petal_pink,
            ingredients.rune_pride,
            ingredients.rune_greed, -- doesn't yet exist
            ingredients.redstone_root,
            ingredients.pixie_dust
        }
    },
    pollidisiac  = {
        number = 33,
        type = 'functional',
        items = {
            ingredients.petal_red,
            ingredients.petal_red,
            ingredients.petal_pink,
            ingredients.petal_pink,
            ingredients.petal_orange,
            ingredients.rune_lust, -- doesn't yet exist
            ingredients.rune_fire
        }
    },
    rannuncarpus = {
        number = 34,
        type = 'functional',
        items = {
            ingredients.petal_orange,
            ingredients.petal_orange,
            ingredients.petal_yellow,
            ingredients.rune_earth,
            ingredients.redstone_root
        }
    },
    solegnolia = {
        number = 35,
        type = 'functional',
        items = {
            ingredients.petal_brown,
            ingredients.petal_brown,
            ingredients.petal_red,
            ingredients.petal_blue,
            ingredients.redstone_root
        }
    },
    spectranthemum = {
        number = 36,
        type = 'functional',
        items = {
            ingredients.petal_white,
            ingredients.petal_white,
            ingredients.petal_light_gray,
            ingredients.petal_light_gray,
            ingredients.petal_cyan,
            ingredients.rune_envy,
            ingredients.rune_water,
            ingredients.pixie_dust
        }
    },
    tangleberrie  = {
        number = 37,
        type = 'functional',
        items = {
            ingredients.petal_cyan,
            ingredients.petal_cyan,
            ingredients.petal_gray,
            ingredients.petal_light_gray,
            ingredients.rune_air,
            ingredients.rune_earth
        }
    },
    tigerseye = {
        number = 38,
        type = 'functional',
        items = {
            ingredients.petal_yellow,
            ingredients.petal_brown,
            ingredients.petal_orange,
            ingredients.petal_lime,
            ingredients.rune_autumn
        }
    },
    vinculotus  = {
        number = 39,
        type = 'functional',
        items = {
            ingredients.petal_black,
            ingredients.petal_black,
            ingredients.petal_purple,
            ingredients.petal_purple,
            ingredients.petal_green,
            ingredients.rune_water,
            ingredients.rune_sloth,
            ingredients.rune_lust, -- doesn't yet exist
            ingredients.redstone_root
        }
    }
}

return recipes