--[=[
	Version 2.0.1
	Standlone version
	This is intended for Roblox ModuleScripts
	BSD 2-Clause Licence
	Copyright ©, 2020 - Blockzez (devforum.roblox.com/u/Blockzez and github.com/Blockzez)
	All rights reserved.
	
	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are met:
	
	1. Redistributions of source code must retain the above copyright notice, this
	   list of conditions and the following disclaimer.
	
	2. Redistributions in binary form must reproduce the above copyright notice,
	   this list of conditions and the following disclaimer in the documentation
	   and/or other materials provided with the distribution.
	
	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
	DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
	FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
	DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
	SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
	CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
	OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
	OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]=]--
local bi = { };
local formatting = require(script:WaitForChild("formatting"));
local fmn = require(script:WaitForChild("formatNumber"));

local math_floor, shl, shr, log, tonumber, abs, Infinity, NaN, min, max,
ipairs, setmetatable, table_move, table_create, table_insert, table_concat, table_remove, pack, unpack,
select, error, type, chr
	= math.floor, bit32.lshift, bit32.rshift, math.log, tonumber, math.abs, math.huge, tonumber('NaN'), math.min, math.max,
	ipairs, setmetatable, table.move, table.create, table.insert, table.concat, table.remove, table.pack, unpack,
	select, error, type, string.char;

--[=[ Functions ]=]--
local function moddiv(left, right)
	return left % right, math_floor(left / right);
end;
local function copy(self)
	return table_move(self, 1, #self, 1, table_create(#self));
end;

--[=[ Creation of BigInteger ]=]--
-- Clears trailing zero (little endian number)
local function clear_trailing_zero(self)
	while self[#self] == 0 do table_remove(self) end;
	return self;
end;
local bi_m = { };
local bi_mt = { __index = bi_m };
local proxy = setmetatable({ }, { __mode = 'k' });
local hashed_value = setmetatable({ }, { __mode = 'kv' });
local function new_bigint(sign, bits)
	local r0, r1 = table_create(math.ceil(#clear_trailing_zero(bits) / 8)), sign and 1 or 0;
	for i, v in ipairs(bits) do
		if i % 8 == 0 then
			table_insert(r0, chr(r1));
			r1 = v;
		elseif v == 1 then
			r1 += 2 ^ (i % 8);
		end;
	end;
	if r1 > 0 then
		table_insert(r0, chr(r1));
	end;
	local hash = table_concat(r0);
	if hashed_value[hash] then
		return hashed_value[hash];
	end;
	local object = newproxy(true);
	local object_mt = getmetatable(object);
	for k, v in next, bi_mt do
		object_mt[k] = v;
	end;
	proxy[object] = { sign = sign, bits = bits };
	hashed_value[hash] = object;
	return object;
end;
local function bin_swap(bits, v)
	local i = 0;
	repeat
		i += 1;
		bits[i] = (bits[i] == 1) and 0 or 1;
	until bits[i] == v;
	return bits;
end;

--[=[ Base convertion ]=]--
local function add_base(to_add, value, base)
	local c = 0;
	for i = 1, max(#to_add, #value) do
		to_add[i], c = moddiv((to_add[i] or 0) + (value[i] or 0) + c, base);
	end;
	if c > 0 then
		table_insert(to_add, (to_add[#value + 1] or 0) + c);
	end;
	return to_add;
end;
local function multiply_2_base(to_multiply, base)
	local c = 0;
	for i, v in ipairs(to_multiply) do
		to_multiply[i], c = moddiv(c + v * 2, base);
	end;
	if c > 0 then
		table_insert(to_multiply, c);
	end;
	return to_multiply;
end;
local function compare_base(left, right)
	if #left ~= #right then
		return #left < #right and -1 or 1;
	end;
	for i = #left, 1, - 1 do
		if left[i] ~= right[i] then
			return left[i] < right[i] and -1 or 1;
		end;
	end;
	return 0;
end;
local function sub_base(to_sub, value, base)
	if compare_base(to_sub, value) < 0 then
		return nil;
	end;
	local c = 0;
	for i = 1, max(#to_sub, #value) do
		to_sub[i], c = moddiv((to_sub[i] or 0) - (value[i] or 0) + c, base);
	end;
	if c < 0 then
		to_sub[#value + 1] = (to_sub[#value + 1] or 0) + c;
	end;
	return clear_trailing_zero(to_sub);
end;
local base_cache = { };
local function from_base(base, value)
	if base == 2 then
		return value;
	end;
	local log2_b = log(base, 2);
	local ret = table_create(math.ceil(#value * log2_b));
	if log2_b % 1 == 0 then
		for _, v in ipairs(value) do
			for i = 0, log2_b - 1 do
				table_insert(ret, shr(v, i) % 2);
			end;
		end;
	else
		if not base_cache[base] then
			base_cache[base] = { { 1 } };
		end;
		local c, b, l = base_cache[base], { 1 }, 1;
		while compare_base(multiply_2_base(b, base), value, base) <= 0 do
			l += 1;
			c[l] = c[l] or copy(b);
		end;
		for i = l, 1, -1 do
			ret[i] = sub_base(value, c[i], base) and 1 or 0;
		end;
	end;
	return ret;
end;
local function to_base(base, value)
	if base == 2 then
		return clear_trailing_zero(copy(value));
	end;
	local log2_b = log(base, 2);
	local ret = table_create(math.ceil(#value * log2_b));
	if log2_b % 1 == 0 then
		local r = 0;
		for i, v in ipairs(value) do
			i = (i - 1) % log2_b;
			r += shl(1, i) * v;
			if i == log2_b - 1 then
				table_insert(ret, r);
				r = 0;
			end;
		end;
		if r > 0 then
			table_insert(ret, r);
		end;
	else
		if not base_cache[base] then
			base_cache[base] = { { 1 } };
		end;
		local c, b = base_cache[base], { 1 };
		for i, v in ipairs(value) do
			c[i] = c[i] or copy(b);
			if v == 1 then
				add_base(ret, b, base);
			end;
			multiply_2_base(b, base);
		end;
	end;
	return clear_trailing_zero(ret);
end;
local base_char = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
local function from_string(value, base)
	local sign, unsigned_value;
	value = value:gsub(' ', ' ');
	if base == 10 then
		local base_modifier;
		sign, base_modifier, unsigned_value = value:upper():match("^([+%-]?)0([BOX])([0-9A-F%s_]+)$");
		if unsigned_value then
			base = base_modifier == 'B' and 2 or (base_modifier == 'X' and 16 or 8);
			if (base == 2 and unsigned_value:find('[^01]')) or (base == 8 and unsigned_value:find('[^0-7]')) then
				return false, nil;
			end;
		else
			sign, unsigned_value = value:match("^([+%-]?)([%d%s_]+)%.?[%d%s_]*$");
		end;
	else
		sign, unsigned_value = value:upper():match(("^([+%%-]?)([%s%%s_]+)$"):format(base_char:sub(1, base)));
	end;
	if not unsigned_value or unsigned_value:match('^[_%s]') or unsigned_value:match('[_%s]$') then
		return false, nil;
	end;
	local base_value = table_create(#unsigned_value:gsub('[_%s]', ''));
	for v in unsigned_value:gmatch("[^_%s]") do
		table_insert(base_value, 1, tonumber(v, base));
	end;
	clear_trailing_zero(base_value);
	if #base_value == 0 then
		return false, base_value;
	end;
	local v = from_base(base, base_value);
	return sign == '-', sign == '-' and bin_swap(v, 0) or v;
end;

--[=[ Raw BigInteger methods ]=]--
local function add_bigint(self, other)
	local s0, s1 = proxy[self].sign, proxy[other].sign;
	local bit0, bit1 = proxy[self].bits, proxy[other].bits;
	local rbit = table_create(max(#bit0, #bit1));
	local carry = 0;
	for i = 1, max(#bit0, #bit1) do
		local diff;
		diff = (bit0[i] or 0) + ((bit1[i] or 0) * ((s0 == s1) and 1 or -1)) + carry;
		rbit[i], carry = moddiv(diff, 2);
	end;
	if s1 then
		bin_swap(rbit, s0 and 1 or 0);
	end;
	
	if carry == -1 then
		carry = 0;
		s0 = not s0;
		local len = #rbit + 1;
		for i, v in ipairs(rbit) do
			rbit[i], carry = moddiv((1 - v) + carry, 2);
		end;
		table_insert(rbit, 0);
	elseif carry == 1 then
		table_insert(rbit, carry);
	end;
	return new_bigint(s0, rbit);
end;
local function copysign_bigint(self, other)
	if self == bi.zero then
		return self;
	end;
	-- other == true to ensure boolean
	local s0, s1 = proxy[self].sign, type(other) ~= "boolean" and proxy[other].sign or other == true;
	local bit = proxy[self].bits;
	return s0 == s1 and self or new_bigint(s1, bin_swap(copy(bit), s1 and 0 or 1));
end;
local function rawmul(bit0, bit1)
	local p, q = #bit0, #bit1;
	local ret = table_create(p + q + 1, 0);
	local tot = 0;
	for ri in ipairs(ret) do
		for bi = max(1, ri - p + 1), min(ri, q) do
			local ai = ri - bi + 1;
			tot += (bit0[ai] or 0) * (bit1[bi] or 0);
		end;
		ret[ri], tot = moddiv(tot, 2);
	end;
	ret[p + q + 1] = tot % 2;
	return ret;
end;
local function mul_bigint(self, other)
	if self == bi.zero or other == bi.zero then
		return bi.zero;
	elseif self == bi.one then
		return other;
	elseif other == bi.one then
		return self;
	elseif self == bi.minusone then
		return -other;
	elseif other == bi.minusone then
		return -self;
	end;
	
	local negative = proxy[self].sign ~= proxy[other].sign;
	local r = rawmul(proxy[self:abs()].bits, proxy[other:abs()].bits);
	return new_bigint(negative, negative and bin_swap(r, 0) or r);
end;

local function shl_bigint(self, ...)
	if select('#', ...) == 0 then
		error("missing argument #2 (BigInteger/number expected)", 3);
	end;
	local other = ...;
	if proxy[other] then
		other = other:todouble();
	else
		other = tonumber(other) or error("invalid argument #2 (BigInteger/number expected got " .. typeof(other) .. ')', 3);
	end;
	if self == bi.zero or other == 0 or abs(other) == Infinity or other ~= other then
		return self;
	end;
	local bit, sign = proxy[self:abs()].bits, proxy[self].sign;
	local bitlen = #bit;
	local ret;
	if other < 0 then
		ret = table_move(bit, 1 - other, bitlen, 1, table_create(bitlen + other));
	else
		ret = table_move(bit, 1, bitlen, 1 + other, table_create(bitlen + other, 0));
	end;
	return new_bigint(sign, sign and bin_swap(ret, 0) or ret);
end;
local function band_bigint(self, other)
	if self == bi.zero or other == bi.zero then
		return bi.zero;
	end;
	local s0, s1 = proxy[self].sign, proxy[other].sign;
	local bit0, bit1 = proxy[self].bits, proxy[other].bits;
	local ret = table_create(max(#bit0, #bit1));
	
	for i = 1, max(#bit0, #bit1) do
		ret[i] = (((bit0[i] or 0) == (s0 and 0 or 1)) and ((bit1[i] or 0) == (s1 and 0 or 1))) and 1 or 0; 
	end;
	return new_bigint(s0 and s1, ret);
end;
local function bnot_bigint(self)
	return new_bigint(not proxy[self].sign, proxy[self].value);
end;
local function bor_bigint(self, other)
	if self == bi.zero then
		return other;
	elseif other == bi.zero then
		return self;
	end;
	local s0, s1 = proxy[self].sign, proxy[other].sign;
	local bit0, bit1 = proxy[self].bits, proxy[other].bits;
	local ret = table_create(max(#bit0, #bit1));
	
	for i = 1, max(#bit0, #bit1) do
		ret[i] = (((bit0[i] or 0) == (s0 and 0 or 1)) or ((bit1[i] or 0) == (s1 and 0 or 1))) and 1 or 0; 
	end;
	return new_bigint(s0 and s1, ret);
end;
local function bxor_bigint(self, other)
	local s0, s1 = proxy[self].sign, proxy[other].sign;
	local bit0, bit1 = proxy[self].bits, proxy[other].bits;
	local ret = table_create(max(#bit0, #bit1));
	
	for i = 1, max(#bit0, #bit1) do
		ret[i] = (((bit0[i] or 0) == (s0 and 0 or 1)) ~= ((bit1[i] or 0) == (s1 and 0 or 1))) and 1 or 0; 
	end;
	return new_bigint(s0 and s1, ret);
end;

local function divrem_bigint(self, other)
	if other == bi.zero then
		error("Division remainder by zero", 3);
	elseif self == other then
		return bi.one, bi.zero;
	elseif self == bi.zero then
		return bi.zero, bi.zero;
	elseif self == bi.one then
		return bi.zero, bi.one;
	elseif self == bi.Negative_one then
		return bi.zero, bi.minusone;
	elseif other == bi.one then
		return self, bi.zero;
	elseif other == bi.minusone then
		return -self, bi.zero;
	end;
	
	local s0, s1 = proxy[self].sign, proxy[other].sign;
	self, other = self:abs(), other:abs();
	local bit0, bit1 = proxy[self].bits, proxy[other].bits;
	
	if self < other then
		return bi.zero, self * (s1 and 1 or -1);
	end;
	
	local ret, rem = table_create(#bit0), table_create(#bit0);
	for i = #bit0, 1, -1 do
		table_insert(rem, 1, bit0[i]);
		ret[i] = sub_base(rem, bit1, 2) and 1 or 0;
	end;
	return new_bigint(s0 ~= s1, s0 ~= s1 and bin_swap(ret, 0) or ret), new_bigint(s0, s0 and bin_swap(rem, 0) or rem);
end;
local function pow_bigint(self, other)
	if other == bi.zero then
		return bi.one;
	elseif other == bi.one then
		return self;
	elseif other < bi.zero then
		return bi.zero;
	elseif self == bi.one or self == bi.zero then
		return self;
	elseif self == bi.minusone then
		return other:iseven() and bi.one or bi.minusone;
	end;
	local is_neg = proxy[self].sign and not other:iseven();
	local bit = copy(proxy[self:abs()].bits);
	local bitlen = #bit;
	local zcount = -1;
	for i, v in ipairs(bit) do
		if i ~= bitlen and v == 1 then
			zcount = nil;
			break;
		end;
		zcount += 1;
	end;
	if zcount then
		local len = other:todouble() * zcount + (is_neg and 0 or 1);
		local ret = table_create(len, is_neg and 1 or 0);
		if not is_neg then
			ret[len] = 1;
		end;
		return new_bigint(is_neg, ret);
	end;
	local ret = { 1 };
	while other ~= bi.zero do
		if band_bigint(other, bi.one) ~= bi.zero then
			ret = rawmul(ret, bit);
		end;
		other /= 2;
		bit = rawmul(bit, bit);
	end;
	return new_bigint(is_neg, is_neg and bin_swap(ret, 0) or ret);
end;
local function log_bigint(self, ...)
	if select('#', ...) == 0 then
		error("missing argument #2 (BigInteger/number expected)", 3);
	end;
	local other = ...;
	if proxy[other] then
		other = other:todouble();
	else
		other = tonumber(other) or (other == nil and 2.71828182845905) or error("invalid argument #2 (BigInteger/number expected got " .. typeof(other) .. ')', 3);
	end;
	if proxy[self].sign or other == 1 then
		return NaN;
	elseif self == bi.one then
		return 0;
	elseif abs(other) == Infinity or other ~= other or other == 0 then
		return NaN;
	end;
	
	local bit = proxy[self].bits;
	local r0, r1 = 0, 0.5;
	local r2 = bit[#bit];
	
	for i = #bit, 1, -1 do
		r0 += bit[i] * r1;
		r1 /= 2;
	end;
	return (log(r0) + (log(2) * #bit)) / log(other);
end;

local function compare_bigint(self, other)
	if rawequal(self, other) then
		return 0;
	end;
	local s0, s1 = proxy[self].sign, proxy[other].sign;
	local bit0, bit1 = proxy[self].bits, proxy[other].bits;
	if s0 ~= s1 then
		return s0 and -1 or 1;
	end;
	return compare_base(bit0, bit1) * (s0 and -1 or 1);
end;

local function check_bigint(n, mix, func)
	return function(...)
		local vararg = pack(...);
		if vararg.n < (n == '#' and 1 or n) then
			error("missing argument #" .. (vararg.n + 1) .. " (BigInteger expected)", 2);
		end;
		for i = 1, n == '#' and vararg.n or n do
			if not proxy[vararg[i]] then
				local v;
				if mix or type(vararg[i]) == "string" or (type(vararg[i]) == "number" and vararg[i] % 1 == 0) then
					v = bi.new(vararg[i]);
				end;
				if v then
					vararg[i] = v;
				else
					error(mix and ("invalid argument #%d (BigInteger expected, got %s)"):format(i, typeof(vararg[i]))
						or "Cannot mix BigInteger and other types that's not integer or string, use explicit conversions", 2);
				end;
			end;
		end;
		if n == '#' then
			return func(vararg);
		end;
		return func(unpack(vararg, 1, vararg.n));
	end;
end;

--[=[ BigInteger metamethods ]=]--
function bi_mt.__tostring(self)
	local bits = to_base(10, proxy[self].bits);
	if proxy[self].sign then
		add_base(bits, { 1 }, 10);
		table_insert(bits, '-');
	elseif #bits == 0 then
		return '0';
	end;
	return table_concat(bits):reverse();
end;
function bi_mt.__unm(self)
	local sign = proxy[self].sign;
	return new_bigint(not sign, bin_swap(copy(proxy[self].bits), sign and 1 or 0));
end;
bi_mt.__add = check_bigint(2, false, add_bigint);
bi_mt.__sub = check_bigint(2, false, function(self, other)
	return add_bigint(self, -other);
end);
bi_mt.__mul = check_bigint(2, false, mul_bigint);
bi_mt.__div = check_bigint(2, false, function(self, other)
	if other == bi.zero then
		error("Division by zero", 3);
	end;
	return (divrem_bigint(self, other));
end);
bi_mt.__mod = check_bigint(2, false, function(self, other)
	if other == bi.zero then
		error("Remainder by zero", 3);
	end;
	return (select(2, divrem_bigint(self, other)));
end);
bi_mt.__pow = check_bigint(2, false, pow_bigint);

bi_mt.__le = check_bigint(2, false, function(self, other)
	return compare_bigint(self, other) <= 0;
end);
bi_mt.__lt = check_bigint(2, false, function(self, other)
	return compare_bigint(self, other) < 0;
end);

function bi_mt.__concat(self, other)
	if not (proxy[self] and proxy[other])
		and type(self) ~= "string" and type(self) ~= "number"
		and type(other) ~= "string" and type(other) ~= "number" then
		error(("attempt to concatenate %s with %s"):format(typeof(self), typeof(other)), 2);
	end;
	return tostring(self) .. tostring(other);
end;

--[=[ BigInteger methods ]=]--
bi_m.compare = check_bigint(2, true, compare_bigint);
function bi_m.tostring(...)
	if select('#', ...) == 0 then
		error("missing argument #1 (BigInteger expected)", 2);
	end;
	local self, options = ...;
	if type(options) ~= "table" then
		options = { };
	end;
	local v = bi.new(self);
	return formatting.ToString(v and proxy[v].sign, v and to_base(options.base or 10, proxy[v].bits), options or { });
end;
function bi_m.tolocalestring(...)
	if select('#', ...) == 0 then
		error("missing argument #1 (BigInteger expected)", 2);
	end;
	local self, locale, options = ...;
	local v = bi.new(self);
	return formatting.ToLocaleString(v and proxy[v].sign, v and to_base(10, proxy[v].bits), locale, options or { });
end;
bi_m.copysign = check_bigint(2, true, copysign_bigint);
bi_m.todouble = check_bigint(1, true, function(self)
	local ret = 0;
	for i, v in ipairs(proxy[self].bits) do
		ret += v * 2 ^ (i - 1);
		if ret == math.huge then
			return math.huge * (proxy[self].sign and -1 or 1);
		end;
	end;
	return (ret + (proxy[self].sign and 1 or 0)) * (proxy[self].sign and -1 or 1);
end);
bi_m.abs = check_bigint(1, true, function(self)
	return copysign_bigint(self, false);
end);
bi_m.divrem = check_bigint(2, true, divrem_bigint);
bi_m.sign = check_bigint(1, true, function(self)
	if self == bi.zero then
		return 0;
	end;
	return proxy[self].sign and -1 or 1;
end);
bi_m.pow = check_bigint(2, true, pow_bigint);
bi_m.log = check_bigint(1, true, log_bigint);
bi_m.log16 = check_bigint(1, true, function(self)
	return log_bigint(self, 16);
end);
bi_m.log12 = check_bigint(1, true, function(self)
	return log_bigint(self, 12);
end);
bi_m.log10 = check_bigint(1, true, function(self)
	return log_bigint(self, 10);
end);
bi_m.log8 = check_bigint(1, true, function(self)
	return log_bigint(self, 8);
end);
bi_m.log2 = check_bigint(1, true, function(self)
	return log_bigint(self, 2);
end);
bi_m.iseven = check_bigint(1, true, function(self)
	return proxy[self].bits[1] == (proxy[self].sign and 1 or 0);
end);
bi_m.ispoweroftwo = check_bigint(1, true, function(self)
	local bit = proxy[self].bits;
	for i, v in ipairs(bit) do
		if v == (proxy[self].sign and 0 or 1) then
			return i == #bit;
		end;
	end;
	return not proxy[self].sign;
end);

bi_m.shl = check_bigint(1, true, shl_bigint);
bi_m.shr = check_bigint(1, true, function(self, ...)
	if select('#', ...) == 0 then
		error("missing argument #2 (BigInteger/number expected)", 3);
	end;
	local other = ...;
	if proxy[other] then
		other = other:todouble();
	else
		other = tonumber(other) or error("invalid argument #2 (BigInteger/number expected got " .. typeof(other) .. ')', 3);
	end;
	return shl_bigint(self, -other);
end);
bi_m.band = check_bigint(2, true, band_bigint);
bi_m.bor = check_bigint(2, true, bor_bigint);
bi_m.bnot = check_bigint(1, true, bnot_bigint);
bi_m.bxor = check_bigint(2, true, bxor_bigint);

bi_m.min = check_bigint('#', true, function(arguments)
	local min;
	for i, v in ipairs(arguments) do
		if not min or compare_bigint(v, min) < 0 then
			min = v;
		end;
	end;
	return min;
end);
bi_m.max = check_bigint('#', true, function(arguments)
	local max;
	for i, v in ipairs(arguments) do
		if not max or compare_bigint(v, max) > 0 then
			max = v;
		end;
	end;
	return max;
end);
bi_m.clamp = check_bigint(3, true, function(x, min, max)
	if max < min then
		error("max must be greater than min", 3);
	end;
	if x < min then
		return min;
	elseif x > max then
		return max;
	end;
	return x;
end);
bi_m.sum = check_bigint('#', true, function(arguments)
	local ret = bi.zero;
	for i, v in ipairs(arguments) do
		ret = add_bigint(ret, v);
	end;
	return ret;
end);

bi_m.bin = check_bigint(1, true, function(self)
	local bits = proxy[self].bits;
	if proxy[self].sign then
		return ("-0b%s"):format(table_concat(bin_swap(copy(bits), 1)):reverse());
	elseif #bits == 0 then
		return "0b0";
	end;
	return ("0b%s"):format(table_concat(bits):reverse());
end);
bi_m.oct = check_bigint(1, true, function(self)
	local bits = to_base(8, proxy[self].bits);
	if proxy[self].sign then
		return ("-0b%s"):format(table_concat(bin_swap(copy(bits), 1)):reverse());
	elseif #bits == 0 then
		return "0b0";
	end;
	return ("0o%s"):format(table_concat(bits):reverse());
end);
bi_m.hex = check_bigint(1, true, function(self, uppercase)
	local bits = to_base(16, proxy[self].bits);
	if proxy[self].sign then
		add_base(bits, { 1 }, 16);
		for i, v in ipairs(bits) do
			bits[i] = base_char:sub(v + 1, v + 1);
		end;
		return ("-0x%s"):format(table_concat(bits):reverse());
	elseif #bits == 0 then
		return '0x0';
	end;
	for i, v in ipairs(bits) do
		bits[i] = base_char:sub(v + 1, v + 1);
	end;
	return ("0x%s"):format(table_concat(bits):reverse());
end);

bi_m.gcd = check_bigint(2, true, function(self, other)
	self, other = self:abs(), other:abs();
	while other ~= bi.zero do
		self, other = other, self % other;
	end;
	return self;
end);

bi_m.bitlength = check_bigint(1, true, function(self)
	return #proxy[self:abs()].bits;
end);

bi_m.factorial = check_bigint(1, true, function(self)
	if self == bi.zero then
		return bi.one;
	end;
	local r0, r1 = bi.one, bi.one;
	while r1 <= self do
		r0 *= r1;
		r1 += 1;
	end;
	return r0;
end);

--
function bi.new(...)
	if select('#', ...) == 0 then
		error("missing argument #1", 2);
	end;
	local value, base = ...;
	base = base == nil and 10 or math_floor(tonumber(base) or error("invalid argument #2 to 'tonumber' (number expected, got " .. typeof(base) .. ')'));
	if type(value) == "string" then
		if base == 10 then
			local negt, intg, frac, expt = value:match("^([+%-]?)(%d*)(%.?%d*)[Ee]([+%-]?%d+)$");
			if intg then
				expt = tonumber(expt);
				if not expt then
					return nil;
				end;
				if intg == '' and frac == '' then
					return nil;
				end;
				if expt < -1 then
					return new_bigint(false, { });
				end;
				frac = frac:gsub('0+$', '');
				value = negt .. intg .. frac .. ('0'):rep(expt - #frac);
			end;
		end;
		local sign, bit = from_string(value, base);
		if bit then
			return new_bigint(sign, bit);
		end;
	elseif type(value) == "number" then
		if abs(value) < 1 then
			return new_bigint(false, { });
		elseif value ~= value or abs(value) == Infinity then
			return nil;
		end;
		local uvalue = math_floor(abs(value)) - (value < 0 and 1 or 0);
		local len = uvalue == 0 and 0 or log(uvalue, 2);
		local v = table_create(len + 1);
		for i = 0, len do
			table_insert(v, math_floor(uvalue / (2 ^ i)) % 2);
		end;
		return new_bigint(value < 0, v);
	elseif proxy[value] then
		return value;
	elseif type(getmetatable(value)) == "table" and getmetatable(value).__tobigint ~= nil then
		local v = getmetatable(value).__tobigint(...);
		if type(v) == "string" then
			local sign, bit = from_string(v, base);
			if bit then
				return new_bigint(sign, bit);
			end;
		elseif proxy[v] then
			return v;
		end;
		error("'__tobigint must return a bigint'", 2);
	end;
	return nil;
end;

function bi.isbiginteger(value)
	return not not proxy[value];
end;

bi.minusone = new_bigint(true, { });
bi.zero = new_bigint(false, { });
bi.one = new_bigint(false, { 1 });
bi.format = fmn;

return setmetatable({ }, { __index = function(self, index) return bi[index] or bi_m[index] end, __metatable = "The metatable is locked", __newindex = function() error("Attempt to modify a readonly table", 2) end });