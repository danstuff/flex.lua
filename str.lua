local Str = {}

Str.MAX_DEPTH = 5

function Str.split(inpt, sep)
    --generate an array from inputstr based on sep, like in java
    local t = {}
    for str in string.gmatch(inpt..sep,"(.-)"..sep) do table.insert(t, str) end
    return t
end

function Str.toTable(str, depth)
    --parse a string formatted like a table of numbers, strings, sub-tables
	if not depth then depth = 1 end
	if depth > Str.MAX_DEPTH then return str end

    --find the curlies around the numbers
    local open1 = string.find(str, "{")
    local open2 = string.find(str, "{", open1 and open1+1 or 0)
    local clos1 = string.find(string.reverse(str), "}")
    local clos2 = string.find(str, "}")

    --remove outermost brackets
    if open1 then str = string.sub(str, open1+1, #str) end
    if clos1 then str = string.sub(str, 0, #str-clos1) end

    --split the list of numbers, now like X,X,X , by commas
    local a = {}
    local numstrs = Str.split(str, ",")

    -- convert each string value to a number
    local tbl_layers, tblstr = 0, ""
    for i, val in pairs(numstrs) do
        --locate the buckets in the string
		local bkt0, bkt1 = string.find(val, "{") ~= nil, 
            string.find(val, "}") ~= nil
		
		--add 1 to layers if theres an opening bracket
        if bkt0 then tbl_layers = tbl_layers + 1 end

		--if there's no surrounding table and no brackets add to table 
        if tbl_layers <= 0 and not bkt0 and not bkt1 then
            local vnum = tonumber(val)
            a[#a+1] = vnum or val

        --otherwise, cache it to be processed later
        else tblstr = tblstr == "" and val or tblstr..","..val end
						
        --remove a layer, and if you hit 0, process the table
		if bkt1 then
			tbl_layers = tbl_layers - 1
			
			if tbl_layers == 0 then
				a[#a+1] = Str.toTable(tblstr, depth+1)
				tblstr = ""			
			end
		end
    end

    return a
end

function Str.toTable(str, depth)
    --convert a string into a table of numbers, strings, and sub-tables


function Str.tableTo(tbl, str, depth, islast)
    --convert a table of numbers/strings into a readable string 
    if not str then str, depth, islast = "", 1, true end

    if depth > Str.MAX_DEPTH then return str end --limit excessive recursion

    if type(tbl) == "table" then
        str = str .. "{"
        
        --account for possible sub-tables with recursion
        for n, mem in pairs(tbl) do
            str = Str.tableTo(mem, str, depth+1, n == #tbl)
        end			
        return islast and str .. "}" or str .. "},"
        
    elseif type(tbl) == "number" then
        return islast and str..tostring(tbl) or str..tostring(tbl).."," 
    elseif type(tbl) == "string" then
        return islast and str..tbl or str..tbl.."," 
    end
    
    return str
end

function Str.printTable(tbl) print(Str.tableTo(tbl)) end

return Str
