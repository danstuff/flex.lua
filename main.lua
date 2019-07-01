--this file is a utility for testing Flex in LOVE.
--LOVE is only required to use F.performance
local F = require("flex")

function love.load()
    tbl = { 0,"test",0,0 }
    str = "asdk"
    num = 16
    adv_tbl = {"hello", "world", 123, 3903, {{0}}, {10, {5}, 9}}
	
    print("Validation test")
    
	print(F.v(tbl, "table,number:4", true))     --true
    print()
    print(F.v(tbl, "table,string:4", true))     --false
    print()
    print(F.v(tbl, "number,string:4", true))    --false
    print()
    print(F.v(tbl, "table,number:5", true))     --false
    print()

    print(F.v(num, "number:14|18", true))       --true
    print()
    print(F.v(num, "number:14|15", true))       --false
    print()
    print(F.v(num, "number:17|18", true))       --false
    print()
    print(F.v(num, "number,string:14|18", true))--true
    print()
    
    print(F.v(str, "string:fes|tse|asdk", true))        --true
    print()
    print(F.v(str, "string:fes|tse|asde", true))        --false
    print()
    print(F.v(str, "string:asdk|tse|asde", true))       --true
    print()
    print(F.v(str, "string,table:fes|tse|asdk", true))  --true
    print()

    F.performance("table validation",
        function() F.v2(str, "table,number:4") end, 
        100)
    print()
	
    print("Table Conversion Test")
    print(adv_tbl, #adv_tbl)
    F.str.printTable(adv_tbl)
    F.str.printTable(F.str.toTable("{hello,world,123,3903,{{0}},{10,{5},9}}"))
	
    print()

    F.performance("table-string-table conversion",
        function() 
            F.str.toTable(F.str.tableTo(tbl))
        end,
        100)
	
	love.event.quit()
end
