-- BitBuffer by Stravant on Roblox
-- Released open source, so I might as well make use of it.
local BitBuffer = {}

--[[
String Encoding:
	   Char 1   Char 2
str:  LSB--MSB LSB--MSB
Bit#  1,2,...8 9,...,16
--]]

local NumberToBase64; local Base64ToNumber; do
	NumberToBase64 = {}
	Base64ToNumber = {}
	local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	for i = 1, #chars do
		local ch = chars:sub(i, i)
		NumberToBase64[i-1] = ch
		Base64ToNumber[ch] = i-1
	end
end

local PowerOfTwo; do
	PowerOfTwo = {}
	for i = 0, 64 do
		PowerOfTwo[i] = 2^i
	end
end

local BrickColorToNumber; local NumberToBrickColor; do
	BrickColorToNumber = {}
	NumberToBrickColor = {}
	for i = 0, 63 do
		local color = BrickColor.palette(i)
		BrickColorToNumber[color.Number] = i
		NumberToBrickColor[i] = color
	end
end

local floor,insert = math.floor, table.insert
function ToBase(n, b)
    n = floor(n)
    if not b or b == 10 then return tostring(n) end
    local digits = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local t = {}
    local sign = ""
    if n < 0 then
        sign = "-"
    n = -n
    end
    repeat
        local d = (n % b) + 1
        n = floor(n / b)
        insert(t, 1, digits:sub(d, d))
    until n == 0
    return sign..table.concat(t, "")
end

function BitBuffer.Create()
	local this = {}
	
	-- Tracking
	local mBitPtr = 0
	local mBitBuffer = {}
	
	function this:ResetPtr()
		mBitPtr = 0
	end
	function this:Reset()
		mBitBuffer = {}
		mBitPtr = 0
	end
	
	-- Set debugging on
	local mDebug = false
	function this:SetDebug(state)
		mDebug = state
	end
	
	-- Read / Write to a string
	function this:FromString(str)
		this:Reset()
		for i = 1, #str do
			local ch = str:sub(i, i):byte()
			for i = 1, 8 do
				mBitPtr = mBitPtr + 1
				mBitBuffer[mBitPtr] = ch % 2
				ch = math.floor(ch / 2)
			end
		end
		mBitPtr = 0
	end
	function this:ToString()
		local str = ""
		local accum = 0
		local pow = 0
		for i = 1, math.ceil((#mBitBuffer) / 8)*8 do
			accum = accum + PowerOfTwo[pow]*(mBitBuffer[i] or 0)
			pow = pow + 1
			if pow >= 8 then
				str = str..string.char(accum)
				accum = 0
				pow = 0
			end
		end
		return str
	end
	
	-- Read / Write to base64
	function this:FromBase64(str)
		this:Reset()
		for i = 1, #str do
			local ch = Base64ToNumber[str:sub(i, i)]
			assert(ch, "Bad character: 0x"..ToBase(str:sub(i, i):byte(), 16))
			for i = 1, 6 do
				mBitPtr = mBitPtr + 1
				mBitBuffer[mBitPtr] = ch % 2
				ch = math.floor(ch / 2)
			end
			assert(ch == 0, "Character value 0x"..ToBase(Base64ToNumber[str:sub(i, i)], 16).." too large")
		end
		this:ResetPtr()
	end
	function this:ToBase64()
		local strtab = {}
		local accum = 0
		local pow = 0
		for i = 1, math.ceil((#mBitBuffer) / 6)*6 do
			accum = accum + PowerOfTwo[pow]*(mBitBuffer[i] or 0)
			pow = pow + 1
			if pow >= 6 then
				table.insert(strtab, NumberToBase64[accum])
				accum = 0
				pow = 0
			end
		end
		return table.concat(strtab)
	end	
	
	-- Dump
	function this:Dump()
		local str = ""
		local str2 = ""
		local accum = 0
		local pow = 0
		for i = 1, math.ceil((#mBitBuffer) / 8)*8 do
			str2 = str2..(mBitBuffer[i] or 0)
			accum = accum + PowerOfTwo[pow]*(mBitBuffer[i] or 0)
			--print(pow..": +"..PowerOfTwo[pow].."*["..(mBitBuffer[i] or 0).."] -> "..accum)
			pow = pow + 1
			if pow >= 8 then
				str2 = str2.." "
				str = str.."0x"..ToBase(accum, 16).." "
				accum = 0
				pow = 0
			end
		end
		print("Bytes:", str)
		print("Bits:", str2)
	end
	
	-- Read / Write a bit
	local function writeBit(v)
		mBitPtr = mBitPtr + 1
		mBitBuffer[mBitPtr] = v
	end
	local function readBit(v)
		mBitPtr = mBitPtr + 1
		return mBitBuffer[mBitPtr]
	end
	
	-- Read / Write an unsigned number
	function this:WriteUnsigned(w, value, printoff)
		assert(w, "Bad arguments to BitBuffer::WriteUnsigned (Missing BitWidth)")
		assert(value, "Bad arguments to BitBuffer::WriteUnsigned (Missing Value)")
		assert(value >= 0, "Negative value to BitBuffer::WriteUnsigned")
		assert(math.floor(value) == value, "Non-integer value to BitBuffer::WriteUnsigned")
		if mDebug and not printoff then
			print("WriteUnsigned["..w.."]:", value)
		end
		-- Store LSB first
		for i = 1, w do
			writeBit(value % 2)
			value = math.floor(value / 2)
		end
		assert(value == 0, "Value "..tostring(value).." has width greater than "..w.."bits")
	end 
	function this:ReadUnsigned(w, printoff)
		local value = 0
		for i = 1, w do
			value = value + readBit() * PowerOfTwo[i-1]
		end
		if mDebug and not printoff then
			print("ReadUnsigned["..w.."]:", value)
		end
		return value
	end
	
	-- Read / Write a signed number
	function this:WriteSigned(w, value)
		assert(w and value, "Bad arguments to BitBuffer::WriteSigned (Did you forget a bitWidth?)")
		assert(math.floor(value) == value, "Non-integer value to BitBuffer::WriteSigned")
		if mDebug then
			print("WriteSigned["..w.."]:", value)
		end
		-- Write sign
		if value < 0 then
			writeBit(1)
			value = -value
		else
			writeBit(0)
		end
		-- Write value
		this:WriteUnsigned(w-1, value, true)
	end
	function this:ReadSigned(w)
		-- Read sign
		local sign = (-1)^readBit()
		-- Read value
		local value = this:ReadUnsigned(w-1, true)
		if mDebug then
			print("ReadSigned["..w.."]:", sign*value)
		end
		return sign*value
	end
	
	-- Read / Write a string. May contain embedded nulls (string.char(0))
	function this:WriteString(s)
		-- First check if it's a 7 or 8 bit width of string
		local bitWidth = 7
		for i = 1, #s do
			if s:sub(i, i):byte() > 127 then
				bitWidth = 8
				break
			end
		end
		
		-- Write the bit width flag
		if bitWidth == 7 then
			this:WriteBool(false)
		else
			this:WriteBool(true) -- wide chars
		end
	
		-- Now write out the string, terminated with "0x10, 0b0"
		-- 0x10 is encoded as "0x10, 0b1"
		for i = 1, #s do
			local ch = s:sub(i, i):byte()
			if ch == 0x10 then
				this:WriteUnsigned(bitWidth, 0x10)
				this:WriteBool(true)
			else
				this:WriteUnsigned(bitWidth, ch)
			end
		end
		
		-- Write terminator
		this:WriteUnsigned(bitWidth, 0x10)
		this:WriteBool(false)
	end
	function this:ReadString()
		-- Get bit width
		local bitWidth;
		if this:ReadBool() then
			bitWidth = 8
		else
			bitWidth = 7
		end
		
		-- Loop
		local str = ""
		while true do
			local ch = this:ReadUnsigned(bitWidth)
			if ch == 0x10 then
				local flag = this:ReadBool()
				if flag then
					str = str..string.char(0x10)
				else
					break
				end
			else
				str = str..string.char(ch)
			end
		end
		return str
	end
	
	-- Read / Write a bool
	function this:WriteBool(v)
		if mDebug then
			print("WriteBool[1]:", v and "1" or "0")
		end
		if v then
			this:WriteUnsigned(1, 1, true)
		else
			this:WriteUnsigned(1, 0, true)
		end
	end
	function this:ReadBool()
		local v = (this:ReadUnsigned(1, true) == 1)
		if mDebug then
			print("ReadBool[1]:", v and "1" or "0")
		end
		return v
	end
	
	-- Read / Write a floating point number with |wfrac| fraction part
	-- bits, |wexp| exponent part bits, and one sign bit.
	function this:WriteFloat(wfrac, wexp, f)
		assert(wfrac and wexp and f)
		
		-- Sign
		local sign = 1
		if f < 0 then
			f = -f
			sign = -1
		end
		
		-- Decompose
		local mantissa, exponent = math.frexp(f)
		if exponent == 0 and mantissa == 0 then
			this:WriteUnsigned(wfrac + wexp + 1, 0)
			return
		else
			mantissa = ((mantissa - 0.5)/0.5 * PowerOfTwo[wfrac])
		end
		
		-- Write sign
		if sign == -1 then
			this:WriteBool(true)
		else
			this:WriteBool(false)
		end
		
		-- Write mantissa
		mantissa = math.floor(mantissa + 0.5) -- Not really correct, should round up/down based on the parity of |wexp|
		this:WriteUnsigned(wfrac, mantissa)
		
		-- Write exponent
		local maxExp = PowerOfTwo[wexp-1]-1
		if exponent > maxExp then
			exponent = maxExp
		end
		if exponent < -maxExp then
			exponent = -maxExp
		end
		this:WriteSigned(wexp, exponent)	
	end
	function this:ReadFloat(wfrac, wexp)
		assert(wfrac and wexp)
		
		-- Read sign
		local sign = 1
		if this:ReadBool() then
			sign = -1
		end
		
		-- Read mantissa
		local mantissa = this:ReadUnsigned(wfrac)
		
		-- Read exponent
		local exponent = this:ReadSigned(wexp)
		if exponent == 0 and mantissa == 0 then
			return 0
		end
		
		-- Convert mantissa
		mantissa = mantissa / PowerOfTwo[wfrac] * 0.5 + 0.5
		
		-- Output
		return sign * math.ldexp(mantissa, exponent)
	end
	
	-- Read / Write minifloat
	function this:WriteFloat8(f)
		this:WriteFloat(3, 4, f)
	end
	function this:ReadFloat8()
		return this:ReadFloat(3, 4)
	end
	
	-- Read / Write half precision floating point
	function this:WriteFloat16(f)
		this:WriteFloat(10, 5, f)
	end
	function this:ReadFloat16()
		return this:ReadFloat(10, 5)
	end
	
	-- Read / Write single precision floating point
	function this:WriteFloat32(f)
		this:WriteFloat(23, 8, f)
	end
	function this:ReadFloat32()
		return this:ReadFloat(23, 8)
	end
	
	-- Read / Write double precision floating point
	function this:WriteFloat64(f)
		this:WriteFloat(52, 11, f)
	end
	function this:ReadFloat64()
		return this:ReadFloat(52, 11)
	end
	
	return this
end

return BitBuffer