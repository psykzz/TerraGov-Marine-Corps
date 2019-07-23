//merge-sort - gernerally faster than insert sort, for runs of 7 or larger
/proc/sortMerge(list/L, cmp = /proc/cmp_numeric_asc, associative, fromIndex = 1, toIndex, sortkey)
	if(length(L) >= 2)
		fromIndex = fromIndex % length(L)
		toIndex = toIndex % (length(L) + 1)
		if(fromIndex <= 0)
			fromIndex += length(L)
		if(toIndex <= 0)
			toIndex += length(L) + 1

		var/datum/sortInstance/SI = GLOB.sortInstance
		if(!SI)
			SI = new
		SI.L = L
		SI.cmp = cmp
		SI.associative = associative
		SI.sortkey = sortkey

		SI.mergeSort(fromIndex, toIndex)

	return L
