Read("make_params.g");

find_cyclic_25 := function()
    local G, Ns, N, hom, H;
    G := SmallGroup(25, 2);
    Ns := NormalSubgroups(G);
    for N in Ns do
        if Size(N) = 5 then
            break;
        fi;
    od;

    hom := NaturalHomomorphismByNormalSubgroup(G, N);
    H := Image(hom, G);

    buildParamsFromOEDF(G, H, hom, [[1, 2, 1, 3, 1, 4, 3, 2, 3, 2, 4, 4], [2, 1, 4, 3, 2, 1, 5, 4, 5, 3, 5, 5]], 6, true);
end;

ff64 := function()
    local G, H, N, hom;
    G := SmallGroup(64, 267);
    N := NormalSubgroups(G)[100];
    hom := NaturalHomomorphismByNormalSubgroup(G, N);
    H := Image(hom, G);
    Print(StructureDescription(H));

    buildAllParamsForImage(G, H, true);
end;

ff64cont := function()
    local G, H, N, hom, osedf;
    G := SmallGroup(64, 267);
    N := NormalSubgroups(G)[100];
    hom := NaturalHomomorphismByNormalSubgroup(G, N);
    H := Image(hom, G);
    Print(StructureDescription(H));
    
    # osedf := [[1,2,3],[1,2,3],[1,2,4],[1,2,4],[1,3,4],[1,3,4],[2,3,4],[2,3,4]]; #dups = 1
    osedf := [[1, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 1, 4, 4, 1, 1, 1, 1, 1, 1, 1], 
    [1, 2, 3, 3, 3, 3, 3, 3, 3, 4, 4, 1, 4, 4, 1, 2, 2, 2, 2, 2, 2]];
    buildParamsFromOEDF(G, H, hom, osedf, 7, true);
end;


