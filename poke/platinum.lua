local MESSAGE = {}
MESSAGE[0x022536cb] = "ツメ判定"
MESSAGE[0x0224bac9] = "ツメ判定"
MESSAGE[0x0225ac83] = "トレース"
MESSAGE[0x0226020f] = "技選択"
MESSAGE[0x0225a385] = "急所"
MESSAGE[0x0225a2b7] = "ダメージ"
MESSAGE[0x0224e625] = "命中"
MESSAGE[0x02252ca7] = "追加効果"

memory.registerexec(0x0223E8CA, function()
  local lr = memory.getregister("r14")
  print(string.format("battle prng r14=%.8x %s",
                      lr, MESSAGE[lr] or ""))
end)

