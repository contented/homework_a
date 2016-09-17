-module(gtin14).
-compile(export_all).

validate({gtin, GTIN}) when is_binary(GTIN) ->
	validate({gtin, binary_to_list(GTIN)});
validate({gtin, GTIN}) ->
	GTINList = lists:flatten(GTIN),
	[ CheckDigit | ReversedBarcode ] = lists:reverse(GTINList),
	Mask = [3,1,3,1,3,1,3,1,3,1,3,1,3],
	Multiplied = [ X * Y || {X, Y} <- lists:zip(ReversedBarcode, Mask) ],
	Sum = lists:sum(Multiplied),
	CalculatedDigit = 10 - Sum rem 10,
	case CheckDigit == CalculatedDigit of
		true -> ok;
		_ -> {error, invalid_gtin}
	end.
