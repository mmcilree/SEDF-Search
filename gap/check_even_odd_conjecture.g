for n in [3..15] do
    for i in [1..NumberSmallGroups(2*n)] do
        G := SmallGroup(2*n, i);
        els := Elements(G);
        for el in els do
            if Order(el) = n then
                # Print(el, " has order ", n, " in ", StructureDescription(G), "\n");
                A_1 := List(Elements(Group(el)));
                pos := Position(A_1, el^-1);
                Remove(A_1, pos);
                sets := [List(A_1, l -> Position(els, l))];
                for el2 in els do
                    if not el2 in A_1 and el2 <> el^-1 then
                        Append(sets, [[Position(els, el2)]]);
                    fi;
                od;
                sets := List(sets, s -> List(s, l -> l - 1));
                mult := List(MultiplicationTable(G), s -> List(s, l -> l - 1));
                Print("test = SetFamily(", sets, ", ", mult, ") \n");
                Print("print(test.is_rwedf())\n\n");
                break;
            fi;
        od;
        
    od;
od;