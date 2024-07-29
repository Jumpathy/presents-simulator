local RobloxLocaleId = game:GetService("LocalizationService").RobloxLocaleId;
local localedata = require(script.Parent:WaitForChild("localedata"));
local numbering_system = {
	arab = { [0] = ('٠'):reverse(), ('١'):reverse(), ('٢'):reverse(), ('٣'):reverse(), ('٤'):reverse(), ('٥'):reverse(), ('٦'):reverse(), ('٧'):reverse(), ('٨'):reverse(), ('٩'):reverse() },
	arabtext = { [0] = ('۰'):reverse(), ('۱'):reverse(), ('۲'):reverse(), ('۳'):reverse(), ('۴'):reverse(), ('۵'):reverse(), ('۶'):reverse(), ('۷'):reverse(), ('۸'):reverse(), ('۹'):reverse() },
	beng = { [0] = ('০'):reverse(), ('১'):reverse(), ('২'):reverse(), ('৩'):reverse(), ('৪'):reverse(), ('৫'):reverse(), ('৬'):reverse(), ('৭'):reverse(), ('৮'):reverse(), ('৯'):reverse() },
	deva = { [0] = ('०'):reverse(), ('१'):reverse(), ('२'):reverse(), ('३'):reverse(), ('४'):reverse(), ('५'):reverse(), ('६'):reverse(), ('७'):reverse(), ('८'):reverse(), ('९'):reverse() },
	hanidec = { [0] = ('〇'):reverse(), ('一'):reverse(), ('二'):reverse(), ('三'):reverse(), ('四'):reverse(), ('五'):reverse(), ('六'):reverse(), ('七'):reverse(), ('八'):reverse(), ('九'):reverse() },
	mymr = { [0] = ('၀'):reverse(), ('၁'):reverse(), ('၂'):reverse(), ('၃'):reverse(), ('၄'):reverse(), ('၅'):reverse(), ('၆'):reverse(), ('၇'):reverse(), ('၈'):reverse(), ('၉'):reverse() },
	olck = { [0] = ('᱐'):reverse(), ('᱑'):reverse(), ('᱒'):reverse(), ('᱓'):reverse(), ('᱔'):reverse(), ('᱕'):reverse(), ('᱖'):reverse(), ('᱗'):reverse(), ('᱘'):reverse(), ('᱙'):reverse() },
	tamldec = { [0] = ('௦'):reverse(), ('௧'):reverse(), ('௨'):reverse(), ('௩'):reverse(), ('௪'):reverse(), ('௫'):reverse(), ('௬'):reverse(), ('௭'):reverse(), ('௮'):reverse(), ('௯'):reverse() },
	tibt = { [0] = ('༠'):reverse(), ('༡'):reverse(), ('༢'):reverse(), ('༣'):reverse(), ('༤'):reverse(), ('༥'):reverse(), ('༦'):reverse(), ('༧'):reverse(), ('༨'):reverse(), ('༩'):reverse() },
	thai = { [0] = ('๐'):reverse(), ('๑'):reverse(), ('๒'):reverse(), ('๓'):reverse(), ('๔'):reverse(), ('๕'):reverse(), ('๖'):reverse(), ('๗'):reverse(), ('๘'):reverse(), ('๙'):reverse() },
};
local locale_parent = {
	['en-150'] = "en-001", ['en-AG'] = "en-001", ['en-AI'] = "en-001", ['en-AU'] = "en-001", ['en-BB'] = "en-001", ['en-BM'] = "en-001", ['en-BS'] = "en-001", ['en-BW'] = "en-001", ['en-BZ'] = "en-001", ['en-CA'] = "en-001", ['en-CC'] = "en-001", ['en-CK'] = "en-001", ['en-CM'] = "en-001", ['en-CX'] = "en-001",
	['en-CY'] = "en-001", ['en-DG'] = "en-001", ['en-DM'] = "en-001", ['en-ER'] = "en-001", ['en-FJ'] = "en-001", ['en-FK'] = "en-001", ['en-FM'] = "en-001", ['en-GB'] = "en-001", ['en-GD'] = "en-001", ['en-GG'] = "en-001", ['en-GH'] = "en-001", ['en-GI'] = "en-001", ['en-GM'] = "en-001", ['en-GY'] = "en-001",
	['en-HK'] = "en-001", ['en-IE'] = "en-001", ['en-IL'] = "en-001", ['en-IM'] = "en-001", ['en-IN'] = "en-001", ['en-IO'] = "en-001", ['en-JE'] = "en-001", ['en-JM'] = "en-001", ['en-KE'] = "en-001", ['en-KI'] = "en-001", ['en-KN'] = "en-001", ['en-KY'] = "en-001", ['en-LC'] = "en-001", ['en-LR'] = "en-001",
	['en-LS'] = "en-001", ['en-MG'] = "en-001", ['en-MO'] = "en-001", ['en-MS'] = "en-001", ['en-MT'] = "en-001", ['en-MU'] = "en-001", ['en-MW'] = "en-001", ['en-MY'] = "en-001", ['en-NA'] = "en-001", ['en-NF'] = "en-001", ['en-NG'] = "en-001", ['en-NR'] = "en-001", ['en-NU'] = "en-001", ['en-NZ'] = "en-001",
	['en-PG'] = "en-001", ['en-PH'] = "en-001", ['en-PK'] = "en-001", ['en-PN'] = "en-001", ['en-PW'] = "en-001", ['en-RW'] = "en-001", ['en-SB'] = "en-001", ['en-SC'] = "en-001", ['en-SD'] = "en-001", ['en-SG'] = "en-001", ['en-SH'] = "en-001", ['en-SL'] = "en-001", ['en-SS'] = "en-001", ['en-SX'] = "en-001",
	['en-SZ'] = "en-001", ['en-TC'] = "en-001", ['en-TK'] = "en-001", ['en-TO'] = "en-001", ['en-TT'] = "en-001", ['en-TV'] = "en-001", ['en-TZ'] = "en-001", ['en-UG'] = "en-001", ['en-VC'] = "en-001", ['en-VG'] = "en-001", ['en-VU'] = "en-001", ['en-WS'] = "en-001", ['en-ZA'] = "en-001", ['en-ZM'] = "en-001",
	['en-ZW'] = "en-001", ['en-AT'] = "en-150", ['en-BE'] = "en-150", ['en-CH'] = "en-150", ['en-DE'] = "en-150", ['en-DK'] = "en-150", ['en-FI'] = "en-150", ['en-NL'] = "en-150", ['en-SE'] = "en-150", ['en-SI'] = "en-150", ['es-AR'] = "es-419", ['es-BO'] = "es-419", ['es-BR'] = "es-419", ['es-BZ'] = "es-419",
	['es-CL'] = "es-419", ['es-CO'] = "es-419", ['es-CR'] = "es-419", ['es-CU'] = "es-419", ['es-DO'] = "es-419", ['es-EC'] = "es-419", ['es-GT'] = "es-419", ['es-HN'] = "es-419", ['es-MX'] = "es-419", ['es-NI'] = "es-419", ['es-PA'] = "es-419", ['es-PE'] = "es-419", ['es-PR'] = "es-419", ['es-PY'] = "es-419",
	['es-SV'] = "es-419", ['es-US'] = "es-419", ['es-UY'] = "es-419", ['es-VE'] = "es-419", ['pt-AO'] = "pt-PT", ['pt-CH'] = "pt-PT", ['pt-CV'] = "pt-PT", ['pt-FR'] = "pt-PT", ['pt-GQ'] = "pt-PT", ['pt-GW'] = "pt-PT", ['pt-LU'] = "pt-PT", ['pt-MO'] = "pt-PT", ['pt-MZ'] = "pt-PT", ['pt-ST'] = "pt-PT", ['pt-TL'] = "pt-PT",
	['az-Arab'] = "root", ['az-Cyrl'] = "root", ['blt-Latn'] = "root", ['bm-Nkoo'] = "root", ['bs-Cyrl'] = "root", ['byn-Latn'] = "root", ['cu-Glag'] = "root", ['dje-Arab'] = "root", ['dyo-Arab'] = "root", ['en-Dsrt'] = "root", ['en-Shaw'] = "root", ['ff-Adlm'] = "root", ['ff-Arab'] = "root", ['ha-Arab'] = "root",
	['hi-Latn'] = "root", ['iu-Latn'] = "root", ['kk-Arab'] = "root", ['ks-Deva'] = "root", ['ku-Arab'] = "root", ['ky-Arab'] = "root", ['ky-Latn'] = "root", ['ml-Arab'] = "root", ['mn-Mong'] = "root", ['mni-Mtei'] = "root", ['ms-Arab'] = "root", ['pa-Arab'] = "root", ['sat-Deva'] = "root", ['sd-Deva'] = "root",
	['sd-Khoj'] = "root", ['sd-Sind'] = "root", ['shi-Latn'] = "root", ['so-Arab'] = "root", ['sr-Latn'] = "root", ['sw-Arab'] = "root", ['tg-Arab'] = "root", ['ug-Cyrl'] = "root", ['uz-Arab'] = "root", ['uz-Cyrl'] = "root", ['vai-Latn'] = "root", ['wo-Arab'] = "root", ['yo-Arab'] = "root", ['yue-Hans'] = "root",
	['zh-Hant'] = "root", ['zh-Hant-MO'] = "zh-Hant-HK",
};

local function add_base_10(value)
	local i = 0;
	repeat
		i += 1;
		value[i] = ((value[i] or 0) + 1) % 10;
	until value[i] ~= 0;
end;

local valid_value_property =
{
	groupSymbol = "f/str",
	decimalSymbol = "f/str",
	compactPattern = "f/table",
	
	useGrouping = "f/bool",
	minimumIntegerDigits = "f/1..",
	minimumGroupingDigits = "f/1..4",
	maximumFractionsDigits = "f/0..",
	
	notation = { "standard", "compact", "abbreviated", "scientific", "engineering" },
	numberingSystem = { "arab", "arabtext", "beng", "deva", "hanidec", "mymr", "olck", "tamldec", "thai", "tibt" },
};

local function check_property(tbl_out, tbl_to_check, property, default)
	local check_values = valid_value_property[property];
	if not check_values then
		return;
	end;
	
	local value = rawget(tbl_to_check, property);
	if property == 'useGrouping' and type(value) == "boolean" then
		tbl_out[property] = value and default or "never";
		return;
	end;
	local valid = false;
	if type(check_values) == "table" then
		valid = table.find(check_values, value);
	elseif check_values == 'f/bool' then
		valid = (type(value) == "boolean");
	elseif check_values == 'f/str' then
		valid = (type(value) == "string");
	elseif check_values == 'f/table' then
		valid = (type(value) == "table");
	elseif not check_values then
		valid = true;
	elseif type(value) == "number" and (value % 1 == 0) or (value == math.huge) then
		local min, max = check_values:match("f/(%w*)%.%.(%w*)");
		valid = (value >= (tbl_out[min] or tonumber(min) or 0)) and ((max == '' and value ~= math.huge) or (value <= tonumber(max)));
	end;
	if valid then
		tbl_out[property] = value;
		return;
	elseif value == nil then
		if type(default) == "string" and (default:sub(1, 7) == 'error: ') then
			error(default:sub(8), 4);
		end;
		tbl_out[property] = default;
		return;
	end;
	error(property .. " value is out of range.", 4);
end;

local function resolve_options(options, to_locale_string)
	local ret = { };
	if not to_locale_string then
		check_property(ret, options, 'groupSymbol', ' ');
		check_property(ret, options, 'decimalSymbol', '.');
		check_property(ret, options, 'minimumGroupingDigits', 1);
	end;
	check_property(ret, options, 'notation', 'standard');
	check_property(ret, options, 'useGrouping', true);
	check_property(ret, options, 'minimumIntegerDigits', 1);
	check_property(ret, options, 'maximumFractionDigits');
	check_property(ret, options, 'numberingSystem', (not to_locale_string) and 'latn');
	return ret;
end;

local function format_bigint(sign, value, frac, data, options)
	local ns = options.numberingSystem or data.defaultNumberingSystem or 'latn';
	local nsdata = data[ns] or data.latn;
	if not value then
		return nsdata.nanSymbol or data.latn.nanSymbol or 'NaN';
	end;
	if sign then
		add_base_10(value);
	end;
	if options.notation == "scientific" or options.notation == "engineering" then
		local vlen = #value;
		if frac then
			value = table.move(value, 1, #value, #frac + 1, frac);
		end;
		local d = options.notation == "engineering" and ((vlen - 1) % 3) or 0;
		local dsym = nsdata.decimalSymbol or data.latn.decimalSymbol or '.';
		if vlen - d > 1 then
			table.insert(value, vlen - d, dsym);
		end;
		while value[1] == 0 or value[1] == dsym
			or (options.maximumFractionsDigits and ((table.find(value, dsym) or 0) > 1 + options.maximumFractionsDigits)) do
			table.remove(value, 1);
		end;
		table.insert(value, 1, nsdata.exponentialSymbol or 'E');
		local exp = vlen - 1 - d;
		if ns == "latn" then
			table.insert(value, 1, string.reverse(exp));
		elseif exp == 0 then
			table.insert(value, 1, numbering_system[ns][0]);
		else
			for i = 0, math.log(exp, 10) do
				table.insert(value, 1, numbering_system[ns][math.floor(exp / (10 ^ i)) % 10]);
			end;
		end;
	else
		local intlen = #value - 3;
		local mgd = data.minimumGroupingDigits or ((options.notation == "compact" or options.notation == "abbreviated") and 2 or 1);
		local compactData = (options.notation == "compact" or options.notation == "abbreviated") and (nsdata.shortDecimal or data.latn.shortDecimal)[math.min(intlen, 12)];
		local previous_value, size;
		if compactData then
			size = compactData.size + math.max(intlen - 12, 0);
			previous_value = value;
			value = table.move(value, intlen - (options.notation == "abbreviated" and math.min(3, size) or size) + 4, #value, 1, table.create(size));
			if options.notation == "abbreviated" then
				for _ = 1, size - 3 do
					table.insert(value, 1, 0);
				end;
			end;
		elseif options.notation == "abbreviated" and intlen > 0 then
			value = table.move(value, intlen + 1, intlen + 3, 1, table.create(3));
			for _ = 1, intlen do
				table.insert(value, 1, 0);
			end;
		end;
		while #value < (options.minimumIntegerDigits or 1) do
			table.insert(value, 0);
		end;
		local gs = options.useGrouping and (nsdata.groupSize or data.latn.groupSize);
		if gs and #value >= (gs[1] + mgd) then
			local vlen = #value;
			local gsym = nsdata.groupSymbol or data.latn.groupSymbol or ',';
			table.insert(value, gs[1] + 1, gsym);
			for i = 1, (vlen - (gs[1] + 1)) / gs[2] do
				table.insert(value, (gs[1] + 1) + ((gs[2] + 1) * i), gsym);
			end;
		end;
		local dsym = nsdata.decimalSymbol or data.latn.decimalSymbol or '.';
		if compactData then
			if size == 1 and previous_value[intlen + 2] ~= 0 then
				table.insert(value, 1, dsym);
				table.insert(value, 1, previous_value[intlen + 2]);
				if options.notation == "abbreviated" and previous_value[intlen + 1] ~= 0 then
					table.insert(value, 1, previous_value[intlen + 1]);
				end;
			elseif size == 2 and options.notation == "abbreviated" and previous_value[intlen + 2] ~= 0 then
				table.insert(value, 1, dsym);
				table.insert(value, 1, previous_value[intlen + 2]);
			end;
			if compactData.suffix then
				table.insert(value, 1, compactData.suffix);
			end;
			if compactData.beforeNumber then
				table.insert(value, nsdata.minusSign or data.latn.minusSign or '-');
				sign = false;
			end;
			if compactData.prefix then
				table.insert(value, compactData.prefix);
			end;
		elseif options.notation == "compact" and intlen == -2 and frac and frac[1] ~= 0 then
			table.insert(value, 1, dsym);
			table.insert(value, 1, frac[1]);
		elseif frac and options.maximumFractionsDigits > 0 then
			for _ = 1, options.maximumFractionsDigits do
				table.remove(frac);
			end;
			if #frac > 0 then
				table.insert(value, 1, dsym);
				value = table.move(value, 1, #value, #frac + 1, frac);
			end;
		end;
	end;
	if sign then
		table.insert(value, nsdata.minusSign or data.latn.minusSign or '-');
	end;
	if numbering_system[ns] then
		for i, v in ipairs(value) do
			if type(v) == "number" then
				value[i] = numbering_system[ns][v];
			end;
		end;
	end;
	return table.concat(value):reverse();
end;
local function title_case_gsub(first, other)
	return first:upper() .. other:lower();
end;
local function title_case(str)
	return str:gsub("^(.)(.*)$", title_case_gsub);
end;
local data_cache;
local locale_cache;
local function deepcopymerge(t0, t1)
	local copy = { };
	if t0 then
		for k, v in next, t0 do
			if type(v) == "table" and (k ~= 'groupSize' and k ~= 'prefix' and k ~= 'suffix') then
				copy[k] = deepcopymerge(v);
			else
				copy[k] = v;
			end;
		end;
	elseif t1 then
		return deepcopymerge(t1);
	else
		return nil;
	end;
	if t1 then
		for k, v in next, t1 do
			if type(v) == "table" and (k ~= 'groupSize' and k ~= 'prefix' and k ~= 'suffix') then
				if type(t0[k]) == "table" then
					copy[k] = deepcopymerge(t0[k], v);
				else
					copy[k] = deepcopymerge(v);
				end;
			else
				copy[k] = v;
			end;
		end;
	end;
	return copy;
end;
local function merge_locale(locale)
	if locale == "root" then
		return localedata.root;
	elseif locale_cache == locale then
		return data_cache;
	end;
	local data = deepcopymerge(merge_locale(locale_parent[locale] or (locale:match('%-') and locale:gsub("%-%w+$", '') or 'root')), localedata[locale]);
	locale_cache = locale;
	data_cache = data;
	return data_cache;
end;
local f = { };
function f.ToLocaleString(sign, value, locale, options)
	if locale ~= nil and type(locale) ~= "string" then
		error("Incorrect locale information provided" ..
			(typeof(locale) == "userdata" and getmetatable(locale) and " (if you're inputting a Locale class from International, please explicitally convert it to string for this one)" or 
				(type(locale) == "table" and " (it doesn't support array locale negotiation)" or '')), 3);
	end;
	local script, region;
	local variants = { };
	local parts = (locale or RobloxLocaleId):gsub('%-u%-.+', ''):split('-');
	if not (parts[1] and (parts[1]:match("^%a%a%a?%a?%a?%a?%a?%a?$") and #parts[1] ~= 4)) then
		if locale then
			error("Incorrect locale information provided", 3);
		else
			parts = { 'en', 'Latn', 'US' };
		end;
	end;
	local language = table.remove(parts, 1):lower();
	if parts[1] and parts[1]:match('^%a%a%a%a$') then
		script = title_case(table.remove(parts, 1));
	end;
	if parts[1] and (parts[1]:match("^%a%a$") or parts[1]:match("^%d%d%d$")) then
		region = table.remove(parts, 1):upper();
	end;
	while parts[1] and (parts[1]:match("^%d%w%w%w$") or parts[1]:match("^%w%w%w%w%w%w?%w?%w?$")) do
		table.insert(variants, table.remove(parts, 1):upper());
	end;
	table.sort(variants);
	if #parts > 0 then
		if locale then
			error("Incorrect locale information provided", 3);
		else
			language, script, region, variants = 'en', 'Latn', 'US', { };
		end;
	end;
	if type(options) ~= "table" then
		options = { };
	end;
	options = resolve_options(options, true);
	return format_bigint(sign, value, nil, merge_locale(language .. (script and ('-' .. script) or '')
		.. (region and ('-' .. region) or '') .. (variants[1] and ('-' .. table.concat(variants, '-')) or '')), options or { });
end;
function f.ToString(sign, value, options)
	options = resolve_options(options, false);
	if not value then
		return 'NaN';
	end;
	if sign then
		add_base_10(value);
	end;
	if options.notation == "scientific" or options.notation == "engineering" then
		local vlen = #value;
		local d = options.notation == "engineering" and ((vlen - 1) % 3) or 0;
		local dsym = options.decimalSymbol or '.';
		if vlen - d > 1 then
			table.insert(value, vlen - d, dsym:reverse());
		end;
		while value[1] == 0 or value[1] == dsym
			or (options.maximumFractionsDigits and ((table.find(value, dsym:reverse()) or 0) > 1 + options.maximumFractionsDigits)) do
			table.remove(value, 1);
		end;
		table.insert(value, 1, 'E');
		local exp = vlen - 1 - d;
		if options.numberingSystem == "latn" then
			table.insert(value, 1, string.reverse(exp));
		elseif exp == 0 then
			table.insert(value, 1, numbering_system[options.numberingSystem][0]);
		else
			for i = 0, math.log(exp, 10) do
				table.insert(value, 1, numbering_system[options.numberingSystem][math.floor(exp / (10 ^ i)) % 10]);
			end;
		end;
	else
		while #value < options.minimumIntegerDigits do
			table.insert(value, 0);
		end;
		if options.useGrouping and #value > 2 + options.minimumGroupingDigits then
			for i = 1, (#value - 1) / 3 do
				table.insert(value, 4 * i, options.groupSymbol:reverse());
			end;
		end;
	end;
	if sign then
		table.insert(value, '-');
	end;
	if numbering_system[options.numberingSystem] then
		for i, v in ipairs(value) do
			if type(v) == "number" then
				value[i] = numbering_system[options.numberingSystem][v];
			end;
		end;
	end;
	return table.concat(value):reverse();
end;
return f;