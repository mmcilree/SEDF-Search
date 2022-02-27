for i in [1..10] do
    for j in [1..NumberSmallGroups(i)] do   
        Print(i, " ", j, ": ", StructureDescription(SmallGroup(i, j)), "\n");
    od;
od;