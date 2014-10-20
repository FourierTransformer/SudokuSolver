local CSP = require('TableSalt/TableSalt')
local TableSalt = CSP.TableSalt
local Pepper = CSP.Pepper

local function printTable(table)
    for j = 1, 9 do
        local row = ""
        for i = 1, 9 do
            local val = table:getValueByPair(i, j)
            if val ~= nil then
                row = row .. val .. " "
            else
                row = row .. "?" .. " "
            end
            if i%3 == 0 then
                row = row .. "|" .. " "
            end
        end
        print(row)
        if j % 3 == 0 then
            print("- - - - - - - - - - - -")
        end
    end
end

local function solveSudoku(puzzle, i)
    -- print some infos
    print("Puzzle", i)

    -- setup the board
    local test = TableSalt:new({1,2,3,4,5,6,7,8,9}, 9, 9)
    test:setAddVarsAfterAnyChange(false)

    -- import the puzzle to csp style
    local start_time = os.clock()
    local index = 1
    for c in puzzle:gmatch"." do
        if c ~= "0" and c~="." then
            test:addConstraintByIDs({index}, Pepper.setVal, tonumber(c))
        end
        index = index + 1
    end
    local duration = (os.clock() - start_time) * 1000
    print(duration .. "ms to load puzzle")

    -- add the various constraints needed to solve
    for n = 0, 2 do
        for k = 0, 2 do
            local giantList = {}
            for i = 1, 3 do
                for j = 1, 3 do
                    giantList[ #giantList+1 ] = {i+k*3, j+n*3}
                end
            end
            test:addConstraintByPairs(giantList, Pepper.allDiff)
        end
    end

    -- SWEET LATIN SQUARES
    test:addConstraintForEachColumn(Pepper.allDiff)
    test:addConstraintForEachRow(Pepper.allDiff)

    -- solve the puzzle
    local start_time = os.clock()
    test:solve(false)
    local duration = (os.clock() - start_time) * 1000
    print(duration .. "ms to solve this puzzle")

    printTable(test)

    -- print out the solution
    local passed = test:isSolved()
    print("Able to solve?: ", passed)

    -- Debug Output (for when testing single puzzles failing)
    for j = 1, 9 do
        for i = 1, 9 do
            local cell = test:getValueByPair(i, j)
            if cell == nil then
                print(test:getIDByPair(i, j), table.concat(test:getDomainByPair(i, j)))
            end
        end
    end

    print("\n\n")

    return passed, duration

end

local puzzles = {}

-- loading up the 50 puzzles from sudoku.txt
-- -- Grid XX + newLine + 9 lines of (9 chars + 1 newline)
-- io.input("sudoku.txt")
-- for i = 1, 50 do
--     local t = io.read(string.len("Grid XX") + 1)
--     t = io.read(9*10)
--     t = t:gsub("%s+", "")
--     puzzles[ #puzzles + 1 ] = t
-- end

-- loading up the 95 'hard' puzzles from top95.txt
io.input("top95.txt")
for i = 1, 95 do
    local t = io.read(82)
    t = t:gsub("%s+", "")
    -- if i > 90 then
        puzzles[ #puzzles+1 ] = t
    -- end
end

-- -- loading up the 11 "hardest" puzzles
-- io.input("hardest.txt")
-- for i = 1, 11 do
--     local t = io.read(82)
--     t = t:gsub("%s+", "")
--     puzzles[ #puzzles+1 ] = t
-- end


-- ProFi = require 'ProFi'
-- ProFi:start()
-- -- solveSudoku(puzzles[4])
-- -- solveSudoku(puzzles[39])
-- solveSudoku(puzzles[1])

-- ProFi:stop()
-- ProFi:writeReport( 'Puzzle11-1.txt' )

local numPassed = 0
local totalDuration = 0
local smallestDuration = math.huge
local longestDuration = -math.huge
for i = 1, #puzzles do
    local passed, duration = solveSudoku(puzzles[i])
    if passed then
        numPassed = numPassed + 1
        totalDuration = totalDuration + duration
        if duration < smallestDuration then
            smallestDuration = duration
        end
        if duration > longestDuration then
            longestDuration = duration
        end
    end
end

print("Passed " .. numPassed .."/".. #puzzles .." = " .. numPassed/#puzzles*100 .. "%")
print("Total Time: " .. totalDuration .. "ms Average Time: " .. totalDuration/#puzzles .. "ms")
print("Longest Duration: " .. longestDuration .. "ms Smallest Duration:" .. smallestDuration .. "ms")
