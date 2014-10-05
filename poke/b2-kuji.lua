require "myutil"

-- 1行ごとに「0001:マスターボール」などと書かれたアイテム名リストをitems.txtとして用意しておく
items = {}
for k, line in pairs(string_to_lines(file_read("items.txt"))) do
  local splitted = split(line, ":")
  local num = tonumber(splitted[1], 16)
  local name = splitted[2]
  items[num] = name
end

E(0x021F41DA, function()
  printf("★ 日替わりseed決定 %.8x %.8x", reg(0), reg(5))
end)

E(0x2037950, function()
  local str = ""
  if 0x02000000 <= reg(2) and reg(2) <= 0x02400000 then
    str = str .. " " .. read_wide(reg(2))
  end
  if reg(1) == 4 or reg(1) == 7 then
    printf("通行人属性設定 %.8x %d %.8x%s lr=%.8x", reg(0), reg(1), reg(2), str, reg(14))
  end
end)

E(0x021F4060, function()
  printf("通行人 id=%d %.8x,%.8x,%.8x, lr=%.8x", reg(3), reg(0), reg(1), reg(2), reg(14))
end)

function read_wide(addr)
	local chars = {}
	, reg(3)local i = 0
	while true do
		local b = read16(addr+i*2)
		if b == 0 or b == 0xffff then break end
		chars[i+1] = b
		i = i + 1
	end
	return WideCharToMultiByte(chars)
end

--E(0x02043D14, function()
--  printf("mt value = %.8x", reg(0))
--end)
--
E(0x0200577E, function()
  --printf("lcg value = %.8x (%.8x)", reg(0), read32(reg(13)+4*3))
end)

E(0x020057B2, function()
  --printf("lcg2 value = %.8x (%.8x)", reg(0), read32(reg(13)+4*3))
end)

-- 日替わりseedの変化を見る
do
local x
E(0x020386CC, function()
	x = reg(0)
end)
E(0x020386CE, function()
	printf("日替わりseed更新 %.8x -> %.8x", x, reg(0))
end)
end

-- くじのアイテム決定
E(0x021E59A8, function()
  --printf("%.8x", reg(6))
  local table = read32(reg(6)+8)
  local x = read32(reg(6))
  local multiplier = reg(4)
  local index = reg(0)
  printf("table = %.8x, x = %d, multiplier = %d, index = %d, loopnum = %d", table, x, multiplier, index, read32(reg(13)+4))
  --[[
  for i = 0, 9 do
    local str = ""
    local prev = 0
    for multiplier = 52, 61 do
      weight = read16(table + 2 * (multiplier * x + i * 2 + 2))
      num = read16(table + 2 * (multiplier * x + i * 2 + 3))
      if prev == 0 then
        str = items[num] or ""
      elseif prev ~= num then
        printf("おかしいよ！")
      end
      str = str .. string.format(" %d, ", weight)
      prev = num
    end
    print(str)
  end
  --]]

end)

-- アイテムindexをきめる乱数を強制書き換え
E(0x021E59A4, function()
	local x = 103
	local orig = reg(2)
	memory.setregister("r2", x)
	printf("set! %d->%d", orig, x)
end)

E(0x021F42E0, function()
  printf("通行人★ %.8x", reg(14))
end)

-- 通行人設定の1つ上
E(0x021F4204, function()
  printf("★★ %.8x %.8x %.8x %.8x", reg(0), reg(1), reg(2), reg(3))
end)

-- 通行人設定でループのあるところ
E(0x021F0180, function()
  printf("★★★")
end)
-- 決まる通行人ID
E(0x021F42A6, function()
  --printf("■%d", reg(5))
end)

E(0x020390c4, function()
	printf("■通行人決定用乱数 seed=%.8x 分母=%d 繰り返し=%d", read32(reg(0)+0xe4), reg(2), reg(1))
end)

-- 通行人用seedの変化を見る
do
local x
E(0x02038FE0, function()
	x = reg(0)
end)
E(0x02038FE2, function()
	printf("通行人用seed更新 %.8x -> %.8x", x, reg(0))
end)
end
