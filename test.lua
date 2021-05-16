package.path = package.path .. ";node_modules/?/init.lua;node_modules/?/?.lua"
local mousexml = require "init"

dumptbl = function(tbl, indent, cb)
    if not indent then indent = 0 end
    if not cb then cb = print end
    if indent > 6 then
        cb(string.rep("  ", indent) .. "...")
        return
    end
    for k, v in pairs(tbl) do
        formatting = string.rep("  ", indent) .. k .. ": "
        if type(v) == "table" then
            cb(formatting)
            dumptbl(v, indent+1, cb)
        elseif type(v) == 'boolean' then
            cb(formatting .. tostring(v))
        elseif type(v) == "function" then
            cb(formatting .. "()")
        else
            cb(formatting .. v)
        end
    end
end

local tests = {
    function ()
        local xml = [[<C><P MEDATA=";2,1;;;-0;0::0:1-"/><Z><S><S T="0" X="400" Y="380" L="800" H="40" P="0,0,0.3,0.2,0,0,0,0"/><S T="1" X="309" Y="322" L="69" H="69" P="0,0,0.1,0.2,0,0,0,0"/><S T="1" X="471" Y="322" L="69" H="69" P="0,0,0.1,0.2,0,0,0,0"/></S><D><T X="90" Y="358"/><F X="89" Y="351"/><DS X="430" Y="336"/></D><O><O X="390" Y="349" C="705" P="0"/></O><L><JD M1="1" M2="2"/></L></Z></C>]]
        local xmlobj = mousexml.parse(xml)
        print(xmlobj:toXmlString())
        assert(xmlobj ~= nil)
    end,
}

local failed_count = 0

for i = 1, #tests do
    local res, ret = pcall(tests[i])
    local test_result = res

    print(("Test #%s ... %s"):format(i, test_result and "success" or "failure"))

    if not test_result then
        if ret then print("  - " .. ret) end
        failed_count = failed_count + 1
    end
end

print("Failed tests: " .. failed_count)
