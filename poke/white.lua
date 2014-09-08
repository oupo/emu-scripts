local count = 0
local count_mt = 0

gui.register(function()
  gui.osdtext(0,  5, string.format("%d", count))
  gui.osdtext(0, 30, string.format("%d", count_mt))
end)

memory.registerexec(0x020056EC, function()
  printf("%d", reg(0))
  count = count + 1
end)

memory.registerexec(0x0203EF18, function()
  count_mt = count_mt + 1
end)

--memory.registerexec(0x0203F054, function()
--  local lr = read32(reg(13)+4)
--  if lr == 0x021fea73  then
--    memory.setregister("r0", 0) -- ‚Ü‚Î‚½‚«‚³‚¹‚Ü‚­‚é
--  end
--end)

read32 = memory.readdword

function reg(n)
  return memory.getregister("r"..tostring(n))
end

function printf(...)
  print(string.format(...))
end
