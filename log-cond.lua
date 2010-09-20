local frame_delay = 180
local frame_count = 0

emu.start_log_cond("cond_log.txt", 30)
emu.registerafter(function()
	if frame_count >= frame_delay then
		emu.end_log_cond()
		error("finish")
	end
	frame_count = frame_count + 1
end)
