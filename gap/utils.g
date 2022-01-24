LoadPackage("json");
LoadPackage("images");

# Generate the elements of 'g' with a "nice"
# ordering:
# * Cyclic groups are ordered in the "natural" way
# * The identity always comes first
OrderedElements := function(g)
    local l,p, eles, maxorder, newe, newloop;
    l := [];
    eles := Set(Elements(g));
    # First find the identity:
    Add(l, First(eles, x -> Order(x) = 1));
    
    # Remove elements not used
    eles := Filtered(eles, x -> not(x in l));

    while not IsEmpty(eles) do
        maxorder := PositionMaximum(eles, Order);
        newe := eles[maxorder];
        newloop := Filtered(List([1..Order(newe)-1], x -> newe^x), y -> y in eles);
        Append(l, newloop);
        eles := Filtered(eles, x -> not(x in l));
    od;

    Assert(0, SortedList(l) = SortedList(Elements(g)));
    return l;
end;

ElementAsInteger := function(g, i)
    local ordered, elements, el, pos;
    ordered := OrderedElements(g);
    elements := Elements(g);
    el := elements[i];

    return Position(ordered, el);
end;

# Map to an fp group (for ease of reading)
FpSmallGroupIso := function(g)
    local map, map2;
    map := IsomorphismFpGroup(g);
    map2 := IsomorphismSimplifiedFpGroup(Image(map));
    #return rec(grp := Image(map2, Image(map)), image := {x} -> Image(map2, Image(map, x)));
    return rec(grp := Image(map), image := {x} ->  Image(map, x));
end;

EDFSymGroup := function(l,g)
    local gens,n;
    n := Length(l);
    gens := [];

    Append(gens, List(GeneratorsOfGroup(AutomorphismGroup(g)),
                              gen -> PermList(List([1..n], z -> Position(l, Image(gen,l[z]))))));
    Append(gens, List([1..n], i -> PermList(List([1..n], z -> Position(l, l[i]*l[z])))));
    Append(gens, List([1..n], i -> PermList(List([1..n], z -> Position(l, l[z]*l[i])))));
    Append(gens, List([1..n], i -> PermList(List([1..n], z -> Position(l, l[z]^l[i])))));
    return Group(gens);
end;


# Choose some elements from the group.
# We cannot pass every element to the constraint solver, so we pick a subset which
# will break "lots" of symmetry. This set is derived from:
# 'Automatic Generation of Constraints for Partial Symmetry Breaking'
SomeElements := function(group)
	local retlist,i,j1,j2,subgroup,p;
	retlist := [];
	for i in [1..LargestMovedPoint(group)] do
		subgroup := Stabilizer(group, [1..i-1], OnTuples);
		# early exit
		if Size(subgroup) = 1 then return Set(retlist); fi;

		for j1 in [i+1..LargestMovedPoint(group)] do
            p := RepresentativeAction(group, [i], [j1], OnTuples);
            if p <> fail then
                Add(retlist, p);
            fi;
		od;
	od;
	return Set(retlist);
end;
		

CollectSyms := function(l, limit)
	local g, group, syms;
	g := Group(l);
    group := EDFSymGroup(l,g);
	if Size(group) <= limit then
		syms := Elements(group);
	else
		syms := SomeElements(group);
	fi;
	return List(syms, x -> ListPerm(x,Length(l)));
end;


# Express the group, it's inverses, and "x*y^-1", as tables of integers
# for the constraint solver
BuildTables := function(ordelements)
    local r;
    r := rec();

    r.inverses := List(ordelements, x -> Position(ordelements, Inverse(x)));
    r.multable := MultiplicationTable(ordelements);
    r.mulinvtable := List(ordelements, x ->
                           List(ordelements, y ->
                            Position(ordelements, x*y^-1)));
    

    r.multuples := ListX([1..Length(ordelements)], [1..Length(ordelements)],
                         {x,y} -> [x,y,r.multable[x][y]]);

    r.mulinvtuples := ListX([1..Length(ordelements)], [1..Length(ordelements)],
                       {x,y} ->  [x,y,r.mulinvtable[x][y]]);
    
    return r;
end;


checkSEDF := function(s, l)
    local i,j, gather, check;
    for i in [1..Length(s)] do
        gather := [];
        for j in [1..Length(s)] do
            if i <> j then
                Append(gather, ListX(s[i], s[j], {x,y} -> l[x]*(l[y]^-1)));
            fi;
        od;
        #Print("County: ",Collected(gather),"\n");
        for check in l{[2..Length(l)]} do
            if Size(Filtered(gather, x -> (x=check))) <> Size(Filtered(gather, x -> (x=l[2]))) then
                Print("Wrong number of elements...",check,"\n");
                return false;
            fi;
        od;
        if Size(Filtered(gather, x -> (x=l[1]))) <> 0 then
                Print("Found an identity\n");
            return false;
        fi;
    od;
    return true;
end;


checkEDF := function(s, l)
    local i,j, gather, check, lambda, collect;
    gather := [];
    for i in [1..Length(s)] do
        for j in [1..Length(s)] do
            if i <> j then
                Append(gather, ListX(s[i], s[j], {x,y} -> l[x]*(l[y]^-1)));
            fi;
        od;
    od;

    lambda := Length(gather)/(Length(l)-1);

    collect := Collected(gather);
    if Length(collect) <> Length(l)-1 then
        return false;
    fi;

    if not ForAll(collect, x -> x[2] = lambda) then
        return false;
    fi;

    if Size(Filtered(gather, x -> (x=l[1]))) <> 0 then
        return false;
    fi;
    return true;
end; 

# This is a horrible function which reads Conjure's output and turns it into GAP
readConjure := function(filename)
    local tf, sols, str;
    sols := [];
    str := Chomp(StringFile(filename));

    tf := InputTextString(str);
    
    while not IsEndOfStream(tf) do
        Add(sols, JsonStreamToGap(tf));
    od;
    CloseStream(tf);
    return sols;
end;


testname := "groups/conjure-output/model000001-edf_16_12_3_5_12.solutions.json";
readSolutions := function(name)
    local split, args, grp, elements, sols, s, syms;
    split := SplitString(name, "-_.");
    args := split{[Length(split)-7..Length(split)-2]};
    grp := SmallGroup(Int(args[2]), Int(args[3]));
    elements := OrderedElements(grp);
    sols := readConjure(name);
    sols := List(sols, x -> x.edf);
    for s in sols do
        if args[1] = "sedf" then
            if not(checkSEDF(s, elements)) then
                Print("Invalid sedf!: ", s.edf);
            fi;
        else
            if not(checkEDF(s, elements)) then
                Print("Invalid edf!: ", s.edf);
            fi;
        fi;
    od;

    syms := EDFSymGroup(elements, grp);
    return rec(type := args[1], grp := [Int(args[2]), Int(args[3])], name := name, numsets := Length(sols[1]), setsize := Length(sols[1][1]), mins := Set(sols, x -> MinimalImage(syms, x, OnSetsSets)));
end;

readAllSolutions := function(dir, ending)
    local contents;
    contents := SortedList(DirectoryContents(dir));
    contents := Filtered(contents, x -> EndsWith(x, ending));
    return List(contents, x -> readSolutions(Concatenation(dir, "/", x)));
end;

cleanAllSolutions := function(dir)
    local contents, file, sols;
    contents := SortedList(DirectoryContents(dir));
    contents := Filtered(contents, x -> EndsWith(x, ".json"));
    for file in contents do
        sols := readSolutions(Concatenation(dir, "/", file));
        FileString(Concatenation(dir,"/", file, ".cleaned"), GapToJsonString(sols));
        PrintFormatted("Done {}\n", file);
    od;
end;

EDFDatabase := [];

loadDirIntoDatabase := function(dir)
    local name, data;
    for name in Filtered(SortedList(DirectoryContents(dir)), x -> EndsWith(x, ".json.cleaned")) do
        data := JsonStringToGap(StringFile(Concatenation(dir, "/",name)));
        data.grpobj := SmallGroup(data.grp[1], data.grp[2]);
        data.grpname := StructureDescription(data.grpobj);
        data.elements := OrderedElements(data.grpobj);
        if data.type = "sedf" then
            if not ForAll(data.mins, x -> checkSEDF(x, data.elements)) then
                Print("Fatal Error : Invalid SEDF Database data ", name, "\n");
            fi;
        else
            if not ForAll(data.mins, x -> checkEDF(x, data.elements)) then
                Print("Fatal Error : Invalid EDF Database data ", name, "\n");
            fi;
        fi;

        data.edfs := List(data.mins, x -> List(x, y -> List(y, z -> data.elements[z])));
        Add(EDFDatabase, data);
    od;
end;

ReadEDFDatabase := function()
    if Length(EDFDatabase) > 0 then
        return;
    fi;
    loadDirIntoDatabase("database/sedf");
    loadDirIntoDatabase("database/edf");
end;

nicePrint := function(sol, maxprint)
    local fpmap, edf;
    fpmap := FpSmallGroupIso(sol.grp);
    Assert(0, Size(fpmap.grp) = Size(sol.grp));
    Print(StructureDescription(fpmap.grp), " -- Size: ", Size(fpmap.grp), " -- ", RelatorsOfFpGroup(fpmap.grp), "\n");
    for edf in sol.mins{[1..Minimum(Length(sol.mins), maxprint)]} do
        Print(List(edf, s -> List(s, y -> fpmap.image(sol.elements[y]))),"\n");
    od;
    Print("\n");
end;


Goodelements := function(g)
    local l,p;
    l := Elements(g);
    if IsCyclic(g) then
        p := First(l, x -> Order(x)=Size(g));
        l := List([0..Size(g)-1], i -> p^i);
    fi;
    Assert(0, Order(l[1])=1);
    Assert(0, Set(l)=Set(g));
    return l;
end;

ValidateSEDFDatabase := function(data)
    local d, grp, nicegrp, s, lister, found;

    for d in data do
        grp := SmallGroup(d.grp[1],d.grp[2]);
        for s in d.sedfs do
            found := false;
            for lister in [List, OrderedElements, Goodelements] do
                nicegrp := lister(grp);
                if checkSEDF(s, nicegrp) then
                    found := true;
                fi;
            od;

            if not found then
                Print("Invalid SEDF in ",d.grp," : ",s,"\n");
            fi;
        od;
    od;
end;