Read("make_params.g");

G := SmallGroup(25, 2);
Ns := NormalSubgroups(G);
for N in Ns do
    if Size(N) = 5 then
        break;
    fi;
od;

hom := NaturalHomomorphismByNormalSubgroup(G, N);
H := Image(hom, G);


#a := getAllowedVals(G, H, [[1, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 1, 3, 3, 3, 1, 1, 1, 1, 1, 2, 2], [1, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 1, 3, 3, 3, 1, 1, 1, 1, 1, 1, 2]], hom);

buildParamsFromOEDF(G, H, hom, [[1, 2, 1, 3, 1, 4, 3, 2, 3, 2, 4, 4], [2, 1, 4, 3, 2, 1, 5, 4, 5, 3, 5, 5]], 6, true);
#buildAllParamsForGroup(G, true);

#buildParamsWithValues(G, 3, 3, 2, true);