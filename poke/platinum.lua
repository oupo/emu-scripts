local MESSAGE = {}
MESSAGE[0x022536cb] = "�c������"
MESSAGE[0x0224bac9] = "�c������"
MESSAGE[0x0225ac83] = "�g���[�X"
MESSAGE[0x0226020f] = "�Z�I��"
MESSAGE[0x0225a385] = "�}��"
MESSAGE[0x0225a2b7] = "�_���[�W"
MESSAGE[0x0224e625] = "����"
MESSAGE[0x02252ca7] = "�ǉ�����"

memory.registerexec(0x0223E8CA, function()
  local lr = memory.getregister("r14")
  print(string.format("battle prng r14=%.8x %s",
                      lr, MESSAGE[lr] or ""))
end)

