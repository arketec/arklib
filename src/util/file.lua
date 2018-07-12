local term = require('term')
local file_util = {}

function file_util.exists(file)
    local f = io.open(file, "rb")
    if f then f:close() end
    return f ~= nil
end

function file_util.readAllLines(file)
    if not file_util.exists(file) then return nil end
    local lines = {}
    for line in io.lines(file) do
        lines[#lines + 1] = line
    end
    return lines
end

function file_util.write(path, text)
    if file_util.exists(path) then 
        print('file exists: Overwrite?')
        local ans = term.read()
        if ans == 'Y' then
            print()
        else
            return
        end
    end
    local f = io.open(path, "w")
    f:write(text)
    f:close()
end

return file_util