Read("utils.g");

validValues := function(n)
    local numsets, setsizes, lambda, l, v, T;
    v := [];
	for numsets in [2..n-1] do
		for T in [2..n] do
            l := (numsets - 1)*T/(n - 1);
            for setsizes in Partitions(T, numsets) do
                # PrintFormatted("n = {}, m = {}, ks = {}, l={}\n", n, numsets, setsizes, l);
                Add(v, rec(numsets := numsets, setsizes := setsizes, l := l));
            od;
        od; 
    od;

    return v;
end;

outputEssenceFile := function(filename, ordgrp, tables, setsizes, numsets, lambda, weights)
	local output;
	output := OutputTextFile(filename, false);
	SetPrintFormattingStatus(output, false);
	PrintToFormatted(output, "letting n be {}\n", Length(ordgrp));
	PrintToFormatted(output, "letting inverses be {}\n", tables.inverses);
	PrintToFormatted(output, "letting multable be {}\n", tables.multable);
	PrintToFormatted(output, "letting mulinvtable be {}\n", tables.mulinvtable);
	PrintToFormatted(output, "letting multuples be {}\n", tables.multuples);
	PrintToFormatted(output, "letting mulinvtuples be {}\n", tables.mulinvtuples);
	PrintToFormatted(output, "letting setsizes be {}\n", setsizes);
    PrintToFormatted(output, "letting maxsetsize be {}\n", Maximum(setsizes));
	PrintToFormatted(output, "letting setnum be {}\n", numsets);
	PrintToFormatted(output, "letting dups be {}\n", lambda);
	PrintToFormatted(output, "letting weights be {}\n", weights);
	
	CloseStream(output);
end;

# Get some reusable information about the group.
getGroupData := function(group)
	local data, ordElms, name;

	ordElms := OrderedElements(group);
	name := StructureDescription(group);
	RemoveCharacters(name," ");

	data := rec(
		name := name,
		id := IdSmallGroup(group)[2],
		elements := ordElms,
		size := Order(group),
		syms := CollectSyms(ordElms, 1000),
		tables := BuildTables(ordElms)
	);

	return data;
end;

buildAllRWEDFParams := function(G)
    local g, o, options, filename, lcm, lambda, weights, sizesstr;
    g := getGroupData(G);

    options := validValues(g.size);

    for o in options do
        lcm := Lcm(Concatenation(o.setsizes, [g.size - 1]));
        lambda := o.l*lcm;
        weights := List(o.setsizes, k -> lcm/k);
        # Print("weights = ", weights);
		sizesstr := String(o.setsizes);
		RemoveCharacters(sizesstr, " ");
        filename := StringFormatted("allrwedfs/rwedf_{}_{}_{}_{}_{}.param", g.size, g.id, o.numsets, sizesstr, lambda);
        # Print(filename, "\n");
        outputEssenceFile(filename, g.elements, g.tables, o.setsizes, o.numsets, lambda, weights);
    od;
end;

buildAllRWEDFParamsForAllGroups := function(n)
	local i, j, G;
	for i in [2..n] do
		for j in [1..NumberSmallGroups(i)] do
			G := SmallGroup(i, j);
			buildAllRWEDFParams(G);
		od;
	od;
end;
