local MESSAGE = {}
MESSAGE[0x0225059f] = "ツメ判定"
MESSAGE[0x02248965] = "ツメ判定"
MESSAGE[0x02257251] = "急所"
MESSAGE[0x0224b51d] = "命中"
MESSAGE[0x02257183] = "ダメージ"
MESSAGE[0x0224fb7b] = "追加効果"
MESSAGE[0x0225d977] = "技選択"
MESSAGE[0x02257b4f] = "トレース"
MESSAGE[0x0223fdfb] = "ゆびをふる"
MESSAGE[0x0224365b] = "ものひろい"
MESSAGE[0x0224366b] = "ものひろい"

-- 戦闘のrand()
memory.registerexec(0x0223B2EC, function()
  local seed = memory.getregister("r0")
  local rand = bit.rshift(seed, 16)
  local lr = memory.getregister("r14")
  print(string.format("battle prng r14=%.8x %s",
                      lr, MESSAGE[lr] or ""))
end)

-- 通常乱数のrand()
memory.registerexec(0x0201FA00, function()
  local seed = memory.getregister("r0")
  local rand = bit.rshift(seed, 16)
  --print(string.format("normal prng r14=%.8x",
  --                    memory.getregister("r14")))
end)

-- 0x02238016 = seedを初期化するルーチン
memory.registerexec(0x02238016, function()
  print(string.format("init seed: %#.8x addr: %#.8x", memory.getregister("r3"), memory.getregister("r2") + 0x19c))
end)

read8 = memory.readbyte
read16 = memory.readword
read32 = memory.readdword

function reg(n)
  return memory.getregister("r"..tostring(n))
end

function printf(...)
  print(string.format(...))
end
