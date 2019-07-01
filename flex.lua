--Flexible lua utility for type validation, conversion, and string operations
local F = {}
F.str = require("str")

function F.copy(obj)
    --performs a deep copy of an object with no metatables
    if type(obj) ~= 'table' then return obj end
    local res = {}
    for k, v in pairs(obj) do res[copy(k)] = copy(v) end
    return res
end

function F.v(value, tcode, dbg_out)
    --returns true if argument is the right type and within a certain range
    --first arg is a value to verify, second is a "typecode" in the format of:
    --for strings:              string:value1|value2|value3|..
    --for numbers (inclusive):  number:minimum|maximum
    --for tables:               table,subtype:length
    local pcomma, pcolon = string.find(tcode,","), string.find(tcode,":")

    local typ = pcomma and string.sub(tcode,0,pcomma-1) or
        pcolon and string.sub(tcode,0,pcolon-1) or
        tcode

    assert(typ, "Flex - format error: no type specified")

    local subtyp = ( pcomma and pcolon ) and 
        string.sub(tcode,pcomma+1,pcolon-1) or ""

    local rgstr = pcolon and string.sub(tcode,pcolon+1,#tcode)
    local range = rgstr  and F.str.split(rgstr, "|") or {}

	--print debug statistics
	if dbg_out then
        print("Flex - Validation output")
        print("Value: "..tostring(value), "Tcode: "..tcode)
        print("Typ: "..typ, "Subtyp: "..subtyp)
        print("Range: "..rgstr, "Rnglen: "..tostring(#range))
		if type(value) == "table" then 
            print("Subvalue: "..tostring(value[1]),
                "Length: "..tostring(#value),
                "Lenmin: "..tostring(range[1]))
        end
	end
	
    --determine if value is of valid type 
    if type(value) ~= typ then return false end

    if typ == "string" and #range > 0 then
        --ensure string matches one of the options in range
        for n,c in pairs(range) do if value == c then return true 
        end end

        return false

    elseif typ == "number" and #range >= 2 then
        --make sure number is above min and below max
        local min = tonumber(range[1]) or -math.huge
        local max = tonumber(range[2]) or math.huge
        return (min <= value and value <= max)

    elseif typ == "table" and #range >= 1 then	
        --ensure table matches length and subtype
        return (#value >= tonumber(range[1])) and (subtyp == "" or
            (#value > 0 and subtyp == type(value[1])))
    end

    return false
end

function F.opr(a, b, func, basetyp)
    --a safe function for math operations that can handle 1D tables and numbers
    local at, bt, ans = type(a), type(b), {}
    if at == basetyp and bt == basetyp then return func(a, b)

    --if both tables, iterate both and operate on corresponding entries  
    elseif at == "table" and bt == "table" then
        assert(#a == #b,
            "Flex - tried to operate two tables of different lengths")

        for i = 1,#a do ans[i] = F.opr(a[i], b[i], typ) end

    --if one table, iterate and operate on each entry with the value of b   
    elseif at == "table"  and bt == basetyp then
        for i = 1,#a do ans[i] = F.opr(a[i], b, typ) end

    else error("Flex - Invalid "..typ.." format: "..at.." and "..bt) end

    return ans
end

local n = "number"
function F.add(a,b) return F.opr(a,b, function(a,b) return a+b end, n) end
function F.sub(a,b) return F.opr(a,b, function(a,b) return a-b end, n) end
function F.mul(a,b) return F.opr(a,b, function(a,b) return a*b end, n) end
function F.div(a,b) return F.opr(a,b, function(a,b) return a/b end, n) end

function F.performance(name, func, trials)
    if not love.timer.getTime then
        print("Flex - performance calclulation failed, "..
            "to use performance, compile with LOVE")
    end

    --outputs the average execution time of the function
	local stime = love.timer.getTime()

    for i=1,trials do func() end

	stime = (love.timer.getTime() - stime) * 1000
    print("Flex - "..name.." ran in "..stime/trials.." ms over "
        ..trials.." trials, total "..stime.." ms")
end

return F
