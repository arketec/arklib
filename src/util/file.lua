local file_util = {}

function file_util.exists(file)
    local f = io.open(file, "rb")
    if f then f:close() end
    return f ~= nil
end

function file_util.readAllLines(file)
    if not file_exists(file) then return nil end
    local lines = {}
    for line in io.lines(file) do
        lines[#lines + 1] = line
    end
    return lines
end

return file_util