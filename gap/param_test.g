Read("make_params.g");

G := SmallGroup(243, 67);
Ns := NormalSubgroups(G);
for N in Ns do
    if Size(N) = 81 then
        break;
    fi;
od;

hom := NaturalHomomorphismByNormalSubgroup(G, N);
H := Image(hom, G);

#a := getAllowedVals(G, H, [[1, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 1, 3, 3, 3, 1, 1, 1, 1, 1, 2, 2], [1, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 1, 3, 3, 3, 1, 1, 1, 1, 1, 1, 2]], hom);

buildParamsFromOEDF(G, H, hom, [[1, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 1, 3, 3, 3, 1, 1, 1, 1, 1, 2, 2], [1, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 1, 3, 3, 3, 1, 1, 1, 1, 1, 1, 2]], 2, true);
#buildAllParamsForGroup(G, true);

#buildParamsWithValues(G, 3, 3, 2, true);