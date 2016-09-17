-module(six_handler).
-behaviour(cowboy_http_handler).
-export([init/3,handle/2,terminate/3]).

-compile(export_all).

-include_lib("xmerl/include/xmerl.hrl").

init({tcp, http}, Req, _Opts) ->
	{ok, Req, undefined_state}.

handle(Req, State) ->
    {<<"POST">>, Req2} = cowboy_req:method(Req),
    {ok, Body, Req3} = cowboy_req:body(Req2),
    XMLElement = parse(Body),
    case check_request(XMLElement) of
        invalid_request -> {ok, Req4} = cowboy_req:reply(200, [], "invalid request\n", Req3);
        Data -> true = save_to_csv(Data), {ok, Req4} = cowboy_req:reply(200, [], "successfully saved to csv\n", Req3)
    end,
    {ok, Req4, State}.

terminate(_Reason, _Req, _State) ->
	ok.

print(X) ->
    io:format("~p~n",[X]).



parse(HtmlBody) ->
    UnicodeBinary = unicode:characters_to_binary(HtmlBody),
    UnicodeList = binary_to_list(UnicodeBinary),
    {XMLElement,_} = xmerl_scan:string(UnicodeList),
    XMLElement.

save_to_csv({GTIN, Name, Desc, Brand}) ->
    File = "output.csv",
    Header = ["GTIN", "Name", "Desc", "Brand"],
    ResultHeader = file:write_file(File, io_lib:fwrite("~p,~p,~p,~p\r\n", Header)),
    ResultData = file:write_file(File, [GTIN, ",", Name, ",", Desc, ",", Brand, "\r\n"], [append]),
    {ok, ok} == {ResultHeader, ResultData}.

check_request(XML) ->
    case {get_prod_cover_gtin(XML), get_prod_name(XML)} of
        {not_found, _} -> invalid_request;
        {_, not_found} -> invalid_request;
        {GTIN, Name} -> {GTIN, Name, get_prod_desc(XML), get_brand_owner_name(XML)}
    end.

get_prod_cover_gtin(XML) ->
    XPath = "/S:Envelope/S:Body/ns2:GetItemByGTINResponse/ns2:GS46Item/DataRecord/record/BaseAttributeValues/value[@baseAttrId='PROD_COVER_GTIN']/@value",
    case xmerl_xpath:string(XPath, XML) of
        [XmlAttributeRecord] -> unicode:characters_to_binary(XmlAttributeRecord#xmlAttribute.value);
        _ -> not_found
    end.

get_prod_name(XML) ->
    XPath = "/S:Envelope/S:Body/ns2:GetItemByGTINResponse/ns2:GS46Item/DataRecord/record/BaseAttributeValues/value[@baseAttrId='PROD_NAME']/@value",
    case xmerl_xpath:string(XPath, XML) of
        [XmlAttributeRecord] -> unicode:characters_to_binary(XmlAttributeRecord#xmlAttribute.value);
        _ -> not_found
    end.

get_prod_desc(XML) ->
    XPath = "/S:Envelope/S:Body/ns2:GetItemByGTINResponse/ns2:GS46Item/DataRecord/record/BaseAttributeValues/value[@baseAttrId='PROD_DESC']/@value",
    case xmerl_xpath:string(XPath, XML) of
        [XmlAttributeRecord] -> unicode:characters_to_binary(XmlAttributeRecord#xmlAttribute.value);
        _ -> ""
    end.

get_brand_owner_name(XML) ->
    XPath = "/S:Envelope/S:Body/ns2:GetItemByGTINResponse/ns2:GS46Item/DataRecord/record/BaseAttributeValues/value[@baseAttrId='BRAND_OWNER_NAME']/@value",
    case xmerl_xpath:string(XPath, XML) of
        [XmlAttributeRecord] -> unicode:characters_to_binary(XmlAttributeRecord#xmlAttribute.value);
        _ -> ""
    end.

