require "myutil"

local call_stack = {}
local call_count_map = {}

gui.register(function ()
	if input.get().T then
		print_stacktrace()
	end
end)

emu.registerblinstruction(function ()
	if get_cpsr_mode() ~= 31 then -- SYS mode
		return
	end
	local addr = reg(15)
	local sp = reg(13)
	pop_stack()
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

function pop_stack()
	while #call_stack > 0 do
		local last = call_stack[#call_stack]
		if last.sp > reg(13) then break end
		table.remove(call_stack)
	end
end

function inc_call_count(addr)
	local id = (call_count_map[addr] or 0)
	call_count_map[addr] = id + 1
	return id
end

function inspect_stacktrace(stacktrace)
	local lines = {}
	pop_stack()
	for k,v in ipairs(stacktrace) do
		local args = {}
		for i, v in ipairs(v.args) do
			args[i] = ("%.8x%s"):format(v, find_str(v))
		end
		lines[#lines+1] = string.format("%.8x,%.8x#%d(%s)%s,%.8x",
		                                v.caller, v.callee, v.callee_id,
		                                table.concat(args, ", "), v.is_thumb and " T" or "", v.sp)
	end
	return table.concat(lines, "\r\n")
end

function find_str(x)
	if not (0x02000000 <= x and x < 0x04000000) then return "" end
	local str = read_cstr(x, 256)
	if #str >= 1 and string.find(str, "^[\\t\\r\\n\\.-~]+$") then
		return " " .. str
	else
		return ""
	end
end

function print_stacktrace()
	print("caller   callee          sp")
	print(inspect_stacktrace(call_stack))
	print("-------------------------------")
end

