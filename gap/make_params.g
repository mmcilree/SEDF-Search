#!/usr/bin/gap -q
max := 100;
G := "";

Read("utils.g");

# Check if there is any valid Lambda value
validLambdas := function(n, sedf)
	local numsets, setsize, lambda, l;
	l := [];
	for numsets in [2..n-1] do
		for setsize in [2..n] do
			if numsets * setsize > n then
				continue;
			fi;

			if sedf then
				lambda := (setsize * setsize * (numsets - 1))/(n-1);
			else
				lambda := (setsize * setsize * numsets * (numsets - 1))/(n-1);
			fi;

			if IsInt(lambda) then
				Add(l, rec(setsize := setsize, numsets := numsets, lambda := lambda));
			fi;
		od;
	od;
	return l;
end;

outputEssenceFile := function(filename, ordgrp, s, tables, symlist, setsize, numsets, lambda, sedf)
	local output;
	output := OutputTextFile(filename, false );
	SetPrintFormattingStatus(output, false);
	PrintToFormatted(output, "letting n be {}\n", Length(ordgrp));

	if s <> false then
		PrintToFormatted(output, "letting s be {}\n", s);
	fi;

	PrintToFormatted(output, "letting inverses be {}\n", tables.inverses);
	PrintToFormatted(output, "letting multable be {}\n", tables.multable);
	PrintToFormatted(output, "letting mulinvtable be {}\n", tables.mulinvtable);
	PrintToFormatted(output, "letting multuples be {}\n", tables.multuples);
	PrintToFormatted(output, "letting mulinvtuples be {}\n", tables.mulinvtuples);
	PrintToFormatted(output, "letting setsize be {}\n", setsize);
	PrintToFormatted(output, "letting setnum be {}\n", numsets);
	PrintToFormatted(output, "letting dups be {}\n", lambda);
	

	if symlist <> false then
		# The whole 'List(l, x -> x)' gets rid of any range notation, which savilerow doesn't understand
		PrintToFormatted(output, "letting symsize be {}\n", Size(symlist));
		PrintToFormatted(output, "letting syms be {}\n", List(symlist, l -> List(l, x -> x)));
	fi;
	
	PrintToFormatted(output, "letting makeEDF be false\n", not sedf);
	PrintToFormatted(output, "letting makeSEDF be true\n", sedf);
	
	CloseStream(output);
end;

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

buildAllParamsForGroup := function(group, isSEDF)
	local g, o, options, type, option, filename;
	
	g := getGroupData(group);

	options := validLambdas(g.size, isSEDF);

	if isSEDF then
		type := "sedf";
	else
		type := "edf";
	fi;
	
	for o in options do
		filename := StringFormatted("params/{}_{}_{}_{}_{}_{}.param", type, g.size, g.id, o.numsets, o.setsize, o.lambda);
		outputEssenceFile(filename, g.elements, false, g.tables, g.syms, o.setsize, o.numsets, o.lambda, isSEDF);
	od;
end;

buildParamsWithValues := function(group, numSets, setSize, lambda, isSEDF)
	local g, type, filename;
	g := getGroupData(group);

	if isSEDF then
		type := "sedf";
	else
		type := "edf";
	fi;

	filename := StringFormatted("params/{}_{}_{}_{}_{}_{}.param", type, g.size, g.id, numSets, setSize, lambda);
	outputEssenceFile(filename, g.elements, false, g.tables, g.syms, setSize, numSets, lambda, isSEDF);
end;

buildAllParamsForImage := function(group, image, isSEDF)
	local g, o, i, type, lambda, filename, options;
	g := getGroupData(group);
	i := getGroupData(image);

	if isSEDF then
		type := "osedf";
	else
		type := "oedf";
	fi;

	options := validLambdas(g.size, isSEDF);

	for o in options do
		lambda := o.lambda*(g.size/i.size);
		filename := StringFormatted("params/{}_{}_{}_{}_{}_{}_{}_{}.param", type, g.size, g.id, i.size, i.id, o.setsize, o.numsets, lambda);
		outputEssenceFile(filename, i.elements, g.size, i.tables, false, o.setsize, o.numsets, lambda, isSEDF);
	od;
end;

bapfi := function(n, i1, i, i2)
	buildAllParamsForImage(SmallGroup(n, i1), SmallGroup(i, i2), true);
end;