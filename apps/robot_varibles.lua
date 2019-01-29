local variables = {}
variables.startpos = {x = 0, y = -1, z = 2}

variables.fl = {pos = {}}
variables.fl.pos[0] = {x = 0, y = 0, z = 1}
variables.fl.pos[1] = {x = -1, y = 0, z = 0}
variables.fl.pos[2] = {x = 0, y = 0, z = -1}
variables.fl.pos[3] = {x = 1, y = 0, z = 0}
variables.fl.pos[4] = {x = 0, y = 0, z = 0}
variables.fl.pos[5] = {x = 0, y = 1, z = 0}

variables.cpos = {}
variables.cpos.anlzer = {x = -1, y = 0, z = 1}
variables.cpos.bin = {x = -1, y = 0, z = -1}
variables.cpos.chest = {x = 1, y = 0, z = -1}

variables.slot = {sticks = {}, fuel = 1, rake = 4, seeds = 5, seedsExtra = 6}
variables.slot.sticks[1] = 2
variables.slot.sticks[2] = 3

variables.lang_noFuel = "Please insert a valid fuel in slot "..slot.fuel.."!"
variables.lang_noSticks = "Please insert Crop Sticks in slot "..slot.sticks[1].." or "..slot.sticks[2].."!"
variables.lang_noRake = "Please insert a Hand Rake in slot "..slot.rake.."!"
variables.lang_noSeed = "Please insert ONLY 1 valid seeds in slot "..slot.seeds.."!"
variables.lang_timeBtwGen = "Waiting time between generations: "
variables.lang_curGen = "Current generation: "
variables.lang_line = "---------------------------------------"

return variables