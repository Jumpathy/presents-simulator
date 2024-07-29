local function roll(t, _)
	return
		not _
		and roll(t,{0,next(t)})
		or _
		and table.move({_[#_-2]+_[#_],next(t,_[#_-1])},1,3,#_+1,_)
		and #_%3 == 0
		and roll(t,_)
		or _[1] == 0
		and not table.move({math.random(_[#_])},1,1,1,_)
		or table.move({},1,1,#_-#_%3+1,_)
		and _[#_] >= _[1]
		and _[#_-1]
		or table.move({_[1]-_[#_]},1,1,1,_)
		and not table.move({},1,3,#_-2,_)
end
return roll;