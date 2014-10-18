require "myutil"

-- メモリサーチみたいに関数をサーチするスクリプト
-- キーバインドがHot Key>Savestates Slotのデフォルトとダブっていることに注意

local candidates = nil
local candidates_num = 0
local count = {}
local prev_count = {}

emu.registerblinstruction(function ()
	if get_cpsr_mode() ~= 31 then -- SYS mode
		return
	end
	local addr = reg(15)
	count[addr] = (count[addr] or 0) + 1
end)

function copy(table)
	local copied = {}
	for k, v in pairs(table) do
		copied[k] = v
	end
	return copied
end

local prev_key

gui.register(function ()
	if input.get().U and not prev_key.U then -- reset
		prev_count = copy(count)
	end
	if input.get().I and not prev_key.I then -- increment
		if not candidate then
			candidate = {}
			for addr,v in pairs(count) do
				if (prev_count[addr] or 0) + 1 == v then
					candidate[addr] = true
					candidates_num = candidates_num + 1
				end
			end
		else
			for addr,_ in pairs(candidate) do
				if not (prev_count[addr] + 1 == count[addr]) then
					candidate[addr] = nil
					candidates_num = candidates_num - 1
				end
			end
		end
		prev_count = copy(count)
	end
	if input.get().O and not prev_key.O then -- remain
		for addr,_ in pairs(candidate) do
			if prev_count[addr] ~= count[addr] then
				candidate[addr] = nil
				candidates_num = candidates_num - 1
			end
		end
		prev_count = copy(count)
	end
	if input.get().P and not prev_key.P then -- print
		for addr,_ in pairs(candidate) do
			printf("%.8x %d", addr, count[addr])
		end
	end
	prev_key = copy(input.get())
	gui.text(0, 0, candidates_num)
end)
