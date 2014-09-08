local call_stack = {}
local call_count_map = {}

emu.registerenterfunc(function()
	if get_cpsr_mode() == 18 then -- IRQ mode
		return
	end
	local addr = get_current_insn_addr()
	local sp = memory.getregister("r13")
	while #call_stack > 0 do
		local last = call_stack[#call_stack]
		if last.sp > sp then break end
		table.remove(call_stack)
	end
	
	if not next(call_count_map) then
		print("enterfunc callback")
	end
	call_stack[#call_stack+1] = {
		caller = memory.getregister("r14"),
		callee = addr,
		is_thumb = is_thumb_state(),
		callee_id = inc_call_count(addr),
		sp = sp,
		args = {reg(0), reg(1), reg(2), reg(3)}
	}
end)

function inc_call_count(addr)
	local id = (call_count_map[addr] or 0)
	call_count_map[addr] = id + 1
	return id
end

function inspect_stacktrace(stacktrace)
	local lines = {}
	for k,v in ipairs(stacktrace) do
		local args = {}
		for i, v in ipairs(v.args) do
			args[i] = ("%.8x"):format(v)
		end
		lines[#lines+1] = string.format("%.8x,%.8x#%d(%s)%s,%.8x",
		                                v.caller, v.callee, v.callee_id,
		                                table.concat(args, ", "), v.is_thumb and " T" or "", v.sp)
	end
	return table.concat(lines, "\r\n")
end

function print_stacktrace()
	print("caller   callee          sp")
	print(inspect_stacktrace(call_stack))
	print("-------------------------------")
end

function get_current_insn_addr()
	-- local pc = memory.getregister("r15")
	-- return pc - (is_thumb_state() and 4 or 8)
	return memory.getregister("curr_insn_addr")
end

function is_thumb_state()
	-- return get_cpsr().t
	return bit.band(bit.rshift(memory.getregister("cpsr"), 5), 1) ~= 0
end

function get_cpsr_mode()
	return bit.band(memory.getregister("cpsr"), 31)
end

function get_cpsr()
	local cpsr = memory.getregister("cpsr")
	return {
		mode = bit.band(cpsr, 31),
		t = bit.band(bit.rshift(cpsr, 5), 1) ~= 0,
		f = bit.band(bit.rshift(cpsr, 6), 1) ~= 0,
		i = bit.band(bit.rshift(cpsr, 7), 1) ~= 0,
		raz = bit.band(bit.rshift(cpsr, 8), 0x7ffff),
		q = bit.band(bit.rshift(cpsr, 27), 1) ~= 0,
		v = bit.band(bit.rshift(cpsr, 28), 1) ~= 0,
		c = bit.band(bit.rshift(cpsr, 29), 1) ~= 0,
		z = bit.band(bit.rshift(cpsr, 30), 1) ~= 0,
		n = bit.band(bit.rshift(cpsr, 31), 1) ~= 0,
	}
end
