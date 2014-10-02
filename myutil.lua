function reg(i) return memory.getregister("r"..i) end
function regw(i,v) return memory.setregister("r"..i, v) end
read8 = memory.readbyte
read16 = memory.readword
read32 = memory.readdword
read16s = memory.readwordsigned
read32s = memory.readdwordsigned

write8 = memory.writebyte
write16 = memory.writeword
write32 = memory.writedword
function read16_noalign(addr)
	return bit.bor(read8(addr), bit.lshift(read8(addr+1), 8))
end
function read32_noalign(addr)
	return bit.bor(read16_noalign(addr), bit.lshift(read16_noalign(addr+2), 16))
end
function PC() return memory.getregister("curr_insn_addr") end

function printf(...) print(string.format(...)) end
function registerexec_all(addrs, fn)
	for k, addr in pairs(addrs) do
		memory.registerexec(addr, fn)
	end
end


function read_byte(byte_array, index)
	return byte_array[index+1]
end

function read_short(byte_array, index)
	return bit.bor(byte_array[index+1], bit.lshift(byte_array[index+2], 8))
end

function read_long(byte_array, index)
	return bit.bor(byte_array[index+1],
	               bit.lshift(byte_array[index+2],  8),
	               bit.lshift(byte_array[index+3], 16),
	               bit.lshift(byte_array[index+4], 24))
end

function write_byte(byte_array, index, val)
	byte_array[index+1] = val
end

function write_short(byte_array, index, val)
	byte_array[index+1] = bit.band(val, 0xff)
	byte_array[index+2] = bit.band(bit.rshift(val, 8), 0xff)
end

function write_long(byte_array, index, val)
	byte_array[index+1] = bit.band(val, 0xff)
	byte_array[index+2] = bit.band(bit.rshift(val,  8), 0xff)
	byte_array[index+3] = bit.band(bit.rshift(val, 16), 0xff)
	byte_array[index+4] = bit.band(bit.rshift(val, 24), 0xff)
end

function read_byte_list(byte_array, index, len)
	return read_list(byte_array, index, len, read_byte, 1)
end

function read_short_list(byte_array, index, len)
	return read_list(byte_array, index, len, read_short, 2)
end

function read_long_list(byte_array, index, len)
	return read_list(byte_array, index, len, read_long, 4)
end

function read_list(byte_array, index, len, fn, size)
	local result = {}
	for i = 0, len - 1 do
		result[1+i] = fn(byte_array, index + i * size)
	end
	return result
end

function make_prng(a, b)
	local prng = {}
	prng.new = function(seed)
		local obj = {}
		obj.seed = seed
		obj.rand = function(self)
			self.seed = mul(self.seed, a) + b
			return bit.rshift(self.seed, 16)
		end
		return obj
	end
	return prng
end

function mul(a, b)
	local a1, a2, b1, b2
	a1 = bit.rshift(a, 16)
	a2 = bit.band(a, 0xffff)
	b1 = bit.rshift(b, 16)
	b2 = bit.band(b, 0xffff)
	return bit.tobit(bit.lshift(a1 * b2 + a2 * b1, 16) + a2 * b2)
end

function string_to_byte_array(str)
	local bytes = {}
	for i = 1, #str do
		bytes[i] = string.byte(str, i)
	end
	return bytes
end

function byte_array_to_string(bytes)
	local chars = {}
	for i = 1, #bytes do
		chars[i] = string.char(bytes[i])
	end
	return table.concat(chars)
end

function read_memory_bytes(addr, len, bits)
	bits = bits or 1
	local bytes = {}
	for i = 0, len - 1 do
		if bits == 1 then
			bytes[i+1] = read8(addr + i)
		elseif bits == 2 then
			bytes[i+1] = read16(addr + i * 2)
		elseif bits == 4 then
			bytes[i+1] = read32(addr + i * 4)
		end
	end
	return bytes
end

function read_cstr(addr)
	local chars = {}
	local i = 0
	while true do
		local b = read8(addr+i)
		if b == 0 then break end
		chars[i+1] = string.char(b)
		i = i + 1
	end
	return table.concat(chars)
end

function inspect_bytes(bytes, bits)
	bits = bits or 1
	local fmt = "%."..(bits*2).."x"
	return table.concat(array_map(bytes, function(i) return string.format(fmt, i) end), " ")
end

function dump_memory(addr, len, bits)
	return inspect_bytes(read_memory_bytes(addr, len, bits), bits)
end

function array_map(array, fn)
	local result = {}
	for k, v in pairs(array) do
		result[k] = fn(v)
	end
	return result
end

function array_copy(array)
	local result = {}
	for k, v in pairs(array) do
		result[k] = v
	end
	return result
end

function indexof(array, val)
	for k, v in pairs(array) do
		if v == val then
			return k
		end
	end
	return nil
end

function array_concat(dest, src, index, len)
	for i = index, index + len - 1 do
		dest[#dest+1] = src[i+1]
	end
end

function array_move(dest, src, dest_index, src_index, len)
	for i = 0, len - 1 do
		dest[dest_index + i + 1] = src[src_index + i + 1]
	end
end

function file_read(path)
	local f = io.open(path, "rb")
	if not f then
		error("can't open "..path)
	end
	local data = f:read("*a")
	f:close()
	return data
end

function file_write(path, data)
	local f = io.open(path, "wb")
	if not f then
		error("can't open "..path)
	end
	f:write(data)
	f:close()
end

function split(str, sep, is_regexp)
	local ret = {}
	local pos = 1
	while true do
		local start_pos, end_pos = string.find(str, sep, pos, not is_regexp)
		if start_pos == nil then
			ret[#ret+1] = string.sub(str, pos)
			break
		end
		ret[#ret+1] = string.sub(str, pos, start_pos - 1)
		pos = end_pos + 1
	end
	return ret
end

function cut_last_empty(array)
	if array[#array] == "" then
		table.remove(array)
	end
	return array
end

function join(array, delimiter)
	return table.concat(array, delimiter or ",")
end

function string_to_lines(str)
	return cut_last_empty(split(str, "\r?\n", true))
end

-- base: http://d.aoikujira.com/blog/index.php?2009%252F04%252F16
function inspect(o)
	local t = type(o)
	if t == "string" then
		return string.format("%q", o)
	elseif t == "table" then
		local result = ""
		
		for k,v in pairs(o) do
			local tmp
			if type(k) == "number" and 1 <= k and k <= #o then
				tmp = inspect(v)
			elseif type(k) == "string" and k:find("^[A-Z_a-z][0-9A-Z_a-z]*$") then
				tmp = k.."="..inspect(v)
			else
				tmp = "["..inspect(k).."]="..inspect(v)
			end
			if result == "" then
				result = tmp
			else
				result = result..","..tmp
			end
		end
		return "{"..result.."}"
	else
		return tostring(o)
	end
end

function memset(addr, val, len)
	for i = 0, len-1 do
		memory.writebyte(addr+i, val)
	end
end

function W(addr, size)
  memory.registerwrite(addr, size or 4, function(p, l)
    printf("written %.8x %s (pc=%.8x)", addr, dump_memory(p, l), PC())
  end)
end

function E(addr, fn)
  memory.registerexec(addr, fn)
end

function start_debug()
  function fn()
    local addr = memory.getregister("curr_insn_addr")
    local thumb = is_thumb_state()
    if thumb then
      emu.disasm(addr - 2, thumb) -- bl–½—ß‚Ì”ò‚Ñæ‚ð³‚µ‚­•\Ž¦‚·‚é‚½‚ß
    end
    print(string.format("%.8x %s", addr, emu.disasm(addr, is_thumb_state())))
    emu.pause()
  end
  print("start_debug")
  memory.registerexec(0x02000000, 0x00400000, fn)
  fn()
end

function is_thumb_state()
	return bit.band(bit.rshift(memory.getregister("cpsr"), 5), 1) ~= 0
end
