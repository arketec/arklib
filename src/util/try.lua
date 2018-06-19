return function (f, f_catch)
    local status, e = pcall(f)
    if (not status) then
        f_catch('general_exception', e)
    end
end