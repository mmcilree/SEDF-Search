Read("make_params.g");

G := SmallGroup(10, 1);
#buildAllParamsForGroup(G, true);

buildParamsWithValues(G, 3, 3, 2, true);