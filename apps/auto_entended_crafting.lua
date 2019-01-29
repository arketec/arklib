local export_addr = require('me_addr')
local component = require('component')



local recipes = {
    everlasting_guilty_pool = {
        database_address = '564',
        adapter_address = '1d4',
        export_bus_address = 'eca',
        export_bus_index = 2,
        db_index = 1,
        items = {
            {
                -- fabulous pool
                dbSlot = 1,
                count = 13
            },
            {
                 -- will of ahrim
                dbSlot = 2,
                count = 1
            },
            {
                -- will of dharok
                dbSlot = 3,
                count = 1
            },
            {
                -- will of gunthan
                dbSlot = 4,
                count = 1
            },
            {
                 -- will of torag
                dbSlot = 5,
                count = 1
            },
            {
                -- will of verac
                dbSlot = 6,
                count = 1
            },
            {
                 -- will of karil
                dbSlot = 7,
                count = 1
            },
            {
                -- enhanced ender ingot
                dbSlot = 8,
                count = 5
            },
            {
                 -- bifrost block
                dbSlot = 9,
                count = 4
            },
            {
                -- corporea spark
                dbSlot = 10,
                count = 1
            },
            {
                 -- spark
                dbSlot = 11,
                count = 8
            },
            {
                 -- alfglass
                dbSlot = 12,
                count = 5
            },
            {
                 -- gaia ingot
                dbSlot = 13,
                count = 6
            },
            {
                 -- rod of unstable resevoir
                dbSlot = 14,
                count = 1
            },
            {
                 -- shulker pearl
                dbSlot = 15,
                count = 3
            },
            {
                 -- gaia spreader
                dbSlot = 16,
                count = 4
            },
            {
                 -- gaia pylon
                dbSlot = 17,
                count = 3
            },
            {
                 -- endoflame
                dbSlot = 18,
                count = 1
            },
            {
                 -- hydrogeas
                dbSlot = 19,
                count = 1
            },
            {
                 -- thermalily
                dbSlot = 20,
                count = 1
            },
            {
                 -- rosa arcana
                dbSlot = 21,
                count = 1
            },
            {
                 -- munchdew
                dbSlot = 22,
                count = 1
            },
            {
                 -- entropynium
                dbSlot = 23,
                count = 1
            },
            {
                 -- kekimurus
                dbSlot = 24,
                count = 1
            },
            {
                 -- gourmalous
                dbSlot = 25,
                count = 1
            },
            {
                 -- narslimmus
                dbSlot = 26,
                count = 1
            },
            {
                 -- spectroulos
                dbSlot = 27,
                count = 1
            },
            {
                 -- dandelifion
                dbSlot = 28,
                count = 3
            },
            {
                 -- rowflowsa
                dbSlot = 29,
                count = 1
            }
        }
    },
    creative_storage_upgrade = {
        database_address = '92a',
        adapter_address = 'f52',
        export_bus_address = '57b',
        export_bus_index = 1,
        db_index = 2,
        items = {
            {
                -- black iron nugget
               dbSlot = 1,
               count = 12
           },
           {
                -- emerald upgrade
               dbSlot = 2,
               count = 4
           },
           {
                -- upgrade template
               dbSlot = 3,
               count = 1
            },
            {
                -- diamond upgrade
               dbSlot = 4,
               count = 4
           },
           {
                    -- void upgrade
                dbSlot = 5,
                count = 4
            },
            {
                -- gold upgrade
               dbSlot = 6,
               count = 4
           }
        }
    }
}

local function makeOne(name)
    local r = recipes[name]
    local items = r.items
    local export_bus
    local db
    local counter = 0
    for bus in component.list("me_exportbus") do
        counter = counter + 1
        if counter == r.export_bus_index then
            export_bus = component.proxy(bus);
        end
    end

    counter = 0
    for d in component.list("database") do
        counter = counter + 1
        if counter == r.db_index then
            db = component.proxy(d)
        end
    end
    
    

    for i,v in ipairs(items) do
        export_bus.setExportConfiguration(0, 1, db.address, v.dbSlot)
        --os.sleep(2)
        for count = 1, v.count, 1 do
            export_bus.exportIntoSlot(0,1)
        end
    end
end

local args = {...}

makeOne(args[1])