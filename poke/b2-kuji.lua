require "myutil"

-- 1�s���ƂɁu0001:�}�X�^�[�{�[���v�ȂǂƏ����ꂽ�A�C�e�������X�g��items.txt�Ƃ��ėp�ӂ��Ă���
items = {}
for k, line in pairs(string_to_lines(file_read("items.txt"))) do
  local splitted = split(line, ":")
  local num = tonumber(splitted[1], 16)
  local name = splitted[2]
  items[num] = name
end

E(0x021F41DA, function()
  printf("�� ���ւ��seed���� %.8x %.8x", reg(0), reg(5))
end)

E(0x2037950, function()
  local str = ""
  if 0x02000000 <= reg(2) and reg(2) <= 0x02400000 then
    str = str .. " " .. read_wide(reg(2))
  end
  if reg(1) == 4 or reg(1) == 7 then
    printf("�ʍs�l�����ݒ� %.8x %d %.8x%s lr=%.8x", reg(0), reg(1), reg(2), str, reg(14))
  end
end)

E(0x021F4060, function()
  printf("�ʍs�l id=%d %.8x,%.8x,%.8x, lr=%.8x", reg(3), reg(0), reg(1), reg(2), reg(14))
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

-- ���ւ��seed�̕ω�������
do
local x
E(0x020386CC, function()
	x = reg(0)
end)
E(0x020386CE, function()
	printf("���ւ��seed�X�V %.8x -> %.8x", x, reg(0))
end)
end

-- �����̃A�C�e������
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
        printf("����������I")
      end
      str = str .. string.format(" %d, ", weight)
      prev = num
    end
    print(str)
  end
  --]]

end)

-- �A�C�e��index�����߂闐����������������
E(0x021E59A4, function()
	local x = 103
	local orig = reg(2)
	memory.setregister("r2", x)
	printf("set! %d->%d", orig, x)
end)

E(0x021F42E0, function()
  printf("�ʍs�l�� %.8x", reg(14))
end)

-- �ʍs�l�ݒ��1��
E(0x021F4204, function()
  printf("���� %.8x %.8x %.8x %.8x", reg(0), reg(1), reg(2), reg(3))
end)

-- �ʍs�l�ݒ�Ń��[�v�̂���Ƃ���
E(0x021F0180, function()
  printf("������")
end)
-- ���܂�ʍs�lID
E(0x021F42A6, function()
  --printf("��%d", reg(5))
end)

E(0x020390c4, function()
	printf("���ʍs�l����p���� seed=%.8x ����=%d �J��Ԃ�=%d", read32(reg(0)+0xe4), reg(2), reg(1))
end)

-- �ʍs�l�pseed�̕ω�������
do
local x
E(0x02038FE0, function()
	x = reg(0)
end)
E(0x02038FE2, function()
	printf("�ʍs�l�pseed�X�V %.8x -> %.8x", x, reg(0))
end)
end
