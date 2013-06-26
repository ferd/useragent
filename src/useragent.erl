-module(useragent).
-export([parse/1, parse/2]).

-record(browser, {name :: browser_name(),
                  family :: browser_family(),
                  type :: browser_type(),
                  manufacturer :: browser_manufacturer(),
                  engine :: browser_engine(),
                  in=[] :: [binary()],
                  out=[] :: [binary()]}).
-record(os, {name :: os_name(),
             family :: os_family(),
             type :: os_type(),
             manufacturer :: os_manufacturer(),
             in=[] :: [binary()],
             out=[] :: [binary()]}).

-type user_agent_string() :: iolist() | binary().

-type user_agent() :: [{string, iolist()} |
                       {browser, browser()} |
                       {os, os()}].
-type browser() :: [{name, browser_name()}
                 |  {vsn, browser_version()}
                 |  {family, browser_family()}
                 |  {type, browser_type()}
                 |  {manufacturer, browser_manufacturer()}
                 |  {engine, browser_engine()}].

-type os() :: [{name, os_name()} |
               {family, os_family()} |
               {type, os_type()} |
               {manufacturer, os_manufacturer()}].

%% browser subtypes
-type browser_version() :: term().
-type browser_name() :: binary().

-type browser_family() :: opera | konqueror | outlook | ie | chrome
                        | omniweb | safari | dolfin2 | apple_mail
                        | lotus_notes | thunderbird | camino | flock
                        | firefox | seamonkey | robot | mozilla | cfnetwork
                        | eudora | pocomail | thebat | netfront | evolution
                        | lynx | tool | undefined.
-type browser_type() :: web | mobile | text | email | robot | tool | undefined.
-type browser_manufacturer() :: microsoft | apple | sun | symbian | nokia
                              | blackberry | hp | sony_ericsson | samsung
                              | sony | nintendo | opera | mozilla | google
                              | compuserve | yahoo | aol | mmc | amazon
                              | roku | undefined.
-type browser_engine() :: trident | word | gecko | webkit | presto | mozilla
                        | khtml | undefined.
%% os subtypes
-type os_name() :: binary().
-type os_manufacturer() :: microsoft | google | hp | apple | nokia | samsung
                         | amazon | symbian | sony_ericsson | sun | sony
                         | nintendo | blackberry | roku | undefined.

-type os_type() :: computer | mobile | tablet | dmr | game_console | undefined.

-type os_family() :: windows | android | ios | mac_osx | mac_os | maemo | bada
                   | google_tv | kindle | symbian | series40 | sony_ericsson
                   | sun | psp | wii | blackberry | roku | undefined.

% -spec is_mobile_device...

-spec parse(user_agent_string()) -> user_agent().
parse(UA) -> parse(UA, utf8).

-spec parse(user_agent_string(), unicode:encoding()) -> user_agent().
parse(UA, Encoding) when is_list(UA) ->
    parse(iolist_to_binary(UA), Encoding);
parse(UA, Encoding) ->
    UALower = list_to_binary(string:to_lower(binary_to_list(characters_to_binary(UA, Encoding)))),
    [{browser, parse_browser(UALower, browsers())},
     {os, parse_os(UALower, os())},
     {string, UA}].

parse_browser(UA, Browsers) ->
    case parse(UA, Browsers, #browser.in, #browser.out) of
        #browser{name=Name,family=Family, type=Type,manufacturer=Man,engine=Eng} ->
            [{name,Name},{family,Family},{type,Type},{manufacturer,Man},{engine,Eng}];
        _ ->
            [{name,undefined},{family,undefined},{type,undefined},
             {manufacturer,undefined},{engine,undefined}]
    end.

parse_os(UA, Os) ->
    case parse(UA, Os, #os.in, #os.out) of
        #os{name=Name,family=Family, type=Type,manufacturer=Man} ->
            [{name,Name},{family,Family},{type,Type},{manufacturer,Man}];
        _ ->
            [{name,undefined},{family,undefined},{type,undefined},{manufacturer,undefined}]
    end.

parse(_UA, [], _InPos, _OutPos) -> [];
parse(UA, [[H|T]|Candidates], InPos, OutPos) ->
    InPat = element(InPos,H),
    OutPat = element(OutPos,H),
    case {match(UA,InPat,OutPat), T} of
        {{true,true}, []} -> % generic one fits, no children
            H;
        {{true,true}, _} -> % check for more precise entries
            parse_sub(UA, T, InPos, OutPos, H);
        {{true,false}, _} -> % check for more precise entries
            case parse_sub(UA, T, InPos, OutPos, H) of
                H -> parse(UA, Candidates, InPos, OutPos);
                Val -> Val
            end;
        {{false,_}, _} -> % no match, keep looking
            parse(UA, Candidates, InPos, OutPos)
    end.

parse_sub(UA, Children, InPos, OutPos, Default) ->
    try
        _ = [case match(UA, element(InPos,Item), element(OutPos,Item)) of
                {true,true} -> throw(Item);
                _ -> nomatch
             end || Item <- Children],
        Default
    catch
        Term -> Term
    end.

match(UA, InPattern, OutPattern) ->
    {lists:any(fun(Pat) -> nomatch =/= binary:match(UA, Pat) end, InPattern),
     lists:all(fun(Pat) -> nomatch =:= binary:match(UA, Pat) end, OutPattern)}.

browsers() ->
    Opera=#browser{name= <<"Opera">>, family=opera, type=web, manufacturer=opera, engine=presto, in=[<<"opera">>]},
    Outlook=#browser{name= <<"Outlook">>, family=outlook, type=email, manufacturer=microsoft, engine=word, in=[<<"msoffice">>]},
    IE=#browser{name= <<"Internet Explorer">>, family=ie, type=web, manufacturer=microsoft, engine=trident, in=[<<"msie">>]},
    Chrome=#browser{name= <<"Chrome">>, family=chrome, type=web, manufacturer=google, engine=webkit, in=[<<"chrome">>]},
    Safari=#browser{name= <<"Safari">>, family=safari, type=web, manufacturer=apple, engine=webkit, in=[<<"safari">>]},
    Thundr=#browser{name= <<"Thunderbird">>, family=thunderbird, type=email, manufacturer=mozilla, engine=gecko, in=[<<"thunderbird">>]},
    Cam=#browser{name= <<"Camino">>, family=camino, type=web, engine=gecko, in=[<<"camino">>]},
    FF=#browser{name= <<"Firefox">>, family=firefox, type=web, manufacturer=mozilla, engine=gecko, in=[<<"firefox">>]},
    [
     %% Opera
     [Opera
      ,Opera#browser{name= <<"Opera Mini">>, type=mobile, in=[<<"opera mini">>]}
      ,Opera#browser{name= <<"Opera 10">>, in=[<<"opera/9.8">>]}
      ,Opera#browser{name= <<"Opera 9">>, in=[<<"opera/9">>]}
     ],
     %% Konqueror
     [#browser{name= <<"Konqueror">>, family=konqueror, type=web, engine=khtml, in=[<<"konqueror">>]}
     ],
     %% Outlook / Word engine
     [Outlook
      ,Outlook#browser{name= <<"Outlook 2007">>, in=[<<"msoffice 12">>]}
      ,Outlook#browser{name= <<"Outlook 2010">>, in=[<<"msoffice 14">>]}
     ],
     %% IE
     [IE
      ,IE#browser{name= <<"Windows Live Mail">>, type=email, in=[<<"outlook-express/7.0">>]}
      ,IE#browser{name= <<"IE Mobile 9">>, type=mobile, in=[<<"iemobile/9">>]}
      ,IE#browser{name= <<"IE Mobile 7">>, type=mobile, in=[<<"iemobile 7">>]}
      ,IE#browser{name= <<"IE Mobile 6">>, type=mobile, in=[<<"iemobile 6">>]}
      ,IE#browser{name= <<"Internet Explorer 10">>, in=[<<"msie 10">>]}
      ,IE#browser{name= <<"Internet Explorer 9">>, in=[<<"msie 9">>]}
      ,IE#browser{name= <<"Internet Explorer 8">>, in=[<<"msie 8">>]}
      ,IE#browser{name= <<"Internet Explorer 7">>, in=[<<"msie 7">>]}
      ,IE#browser{name= <<"Internet Explorer 6">>, in=[<<"msie 6">>]}
      ,IE#browser{name= <<"Internet Explorer 5.5">>, in=[<<"msie 5.5">>]}
      ,IE#browser{name= <<"Internet Explorer 5">>, in=[<<"msie 5">>]}
     ],
     %% Chrome
     [Chrome
      ,Chrome#browser{name= <<"Chrome 19">>, in=[<<"chrome/19">>]}
      ,Chrome#browser{name= <<"Chrome 18">>, in=[<<"chrome/18">>]}
      ,Chrome#browser{name= <<"Chrome 17">>, in=[<<"chrome/17">>]}
      ,Chrome#browser{name= <<"Chrome 16">>, in=[<<"chrome/16">>]}
      ,Chrome#browser{name= <<"Chrome 15">>, in=[<<"chrome/15">>]}
      ,Chrome#browser{name= <<"Chrome 14">>, in=[<<"chrome/14">>]}
      ,Chrome#browser{name= <<"Chrome 13">>, in=[<<"chrome/13">>]}
      ,Chrome#browser{name= <<"Chrome 12">>, in=[<<"chrome/12">>]}
      ,Chrome#browser{name= <<"Chrome 11">>, in=[<<"chrome/11">>]}
      ,Chrome#browser{name= <<"Chrome 10">>, in=[<<"chrome/10">>]}
      ,Chrome#browser{name= <<"Chrome 9">>, in=[<<"chrome/9">>]}
      ,Chrome#browser{name= <<"Chrome 8">>, in=[<<"chrome/8">>]}
     ],
     %% Omniweb
     [#browser{name= <<"OmniWeb">>, family=omniweb, type=web, engine=webkit, in=[<<"omniweb">>]}
     ],
     %% Safari
     [Safari
      ,Safari#browser{name= <<"Chrome Mobile">>, type=mobile, manufacturer=google, in=[<<"crmo">>]}
      ,Safari#browser{name= <<"Mobile Safari">>, type=mobile, in=[<<"mobile safari">>,<<"mobile/">>]}
      ,Safari#browser{name= <<"Silk">>, manufacturer=amazon, in=[<<"silk/">>]}
      ,Safari#browser{name= <<"Safari 5">>, in=[<<"version/5">>]}
      ,Safari#browser{name= <<"Safari 4">>, in=[<<"version/4">>]}
     ],
     %% Dolphin2
     [#browser{name= <<"Samsung Dolphin 2">>, family=dolfin2, type=mobile, manufacturer=samsung, engine=webkit, in=[<<"dolfin/2">>]}
     ],
     %% apple mail
     [#browser{name= <<"Apple Mail">>, family=apple_mail, type=email, manufacturer=apple, engine=webkit, in=[<<"applewebkit">>]}
     ],
     %% lotus notes
     [#browser{name= <<"Lotus Notes">>, family=lotus_notes, type=email, in=[<<"lotus-notes">>]}
     ],
     %% thunderbird
     [Thundr
      ,Thundr#browser{name= <<"Thunderbird 12">>, in=[<<"thunderbird/12">>]}
      ,Thundr#browser{name= <<"Thunderbird 11">>, in=[<<"thunderbird/11">>]}
      ,Thundr#browser{name= <<"Thunderbird 10">>, in=[<<"thunderbird/10">>]}
      ,Thundr#browser{name= <<"Thunderbird 8">>, in=[<<"thunderbird/8">>]}
      ,Thundr#browser{name= <<"Thunderbird 7">>, in=[<<"thunderbird/7">>]}
      ,Thundr#browser{name= <<"Thunderbird 6">>, in=[<<"thunderbird/6">>]}
      ,Thundr#browser{name= <<"Thunderbird 3">>, in=[<<"thunderbird/3">>]}
      ,Thundr#browser{name= <<"Thunderbird 2">>, in=[<<"thunderbird/2">>]}
     ],
     %% Camino
     [Cam
      ,Cam#browser{name= <<"Camino 2">>, in=[<<"camino/2">>]}
     ],
     %% flock
     [#browser{name= <<"Flock">>, family=flock, type=web, engine=gecko, in=[<<"flock">>]}
     ],
     %% firefox
     [FF
      ,FF#browser{name= <<"Firefox 3 Mobile">>, type=mobile, in=[<<"firefox/3.5 maemo">>]}
      ,FF#browser{name= <<"Firefox 22">>, in=[<<"firefox/22">>]}
      ,FF#browser{name= <<"Firefox 21">>, in=[<<"firefox/21">>]}
      ,FF#browser{name= <<"Firefox 20">>, in=[<<"firefox/20">>]}
      ,FF#browser{name= <<"Firefox 19">>, in=[<<"firefox/19">>]}
      ,FF#browser{name= <<"Firefox 18">>, in=[<<"firefox/18">>]}
      ,FF#browser{name= <<"Firefox 17">>, in=[<<"firefox/17">>]}
      ,FF#browser{name= <<"Firefox 16">>, in=[<<"firefox/16">>]}
      ,FF#browser{name= <<"Firefox 15">>, in=[<<"firefox/15">>]}
      ,FF#browser{name= <<"Firefox 14">>, in=[<<"firefox/14">>]}
      ,FF#browser{name= <<"Firefox 13">>, in=[<<"firefox/13">>]}
      ,FF#browser{name= <<"Firefox 12">>, in=[<<"firefox/12">>]}
      ,FF#browser{name= <<"Firefox 11">>, in=[<<"firefox/11">>]}
      ,FF#browser{name= <<"Firefox 10">>, in=[<<"firefox/10">>]}
      ,FF#browser{name= <<"Firefox 9">>, in=[<<"firefox/9">>]}
      ,FF#browser{name= <<"Firefox 8">>, in=[<<"firefox/8">>]}
      ,FF#browser{name= <<"Firefox 7">>, in=[<<"firefox/7">>]}
      ,FF#browser{name= <<"Firefox 6">>, in=[<<"firefox/6">>]}
      ,FF#browser{name= <<"Firefox 5">>, in=[<<"firefox/5">>]}
      ,FF#browser{name= <<"Firefox 4">>, in=[<<"firefox/4">>]}
      ,FF#browser{name= <<"Firefox 3">>, in=[<<"firefox/3">>]}
      ,FF#browser{name= <<"Firefox 2">>, in=[<<"firefox/2">>]}
      ,FF#browser{name= <<"Firefox 1.5">>, in=[<<"firefox/1.5">>]}
     ],
     %% seamonkey
     [#browser{name= <<"SeaMonkey">>, family=seamonkey, type=web, engine=gecko, in=[<<"seamonkey">>]}
     ],
     %% bot
     [#browser{name= <<"Robot/Spider">>, family=robot, type=robot,
               in=[<<"googlebot">>,<<"bot">>,<<"spider">>,<<"crawler">>,
                   <<"feedfetcher">>,<<"slurp">>,<<"twiceler">>,<<"nutch">>,
                   <<"becomebot">>]}
     ],
     %% standalones
     [#browser{name= <<"Mozilla">>, family=mozilla, type=web, manufacturer=mozilla, in=[<<"mozilla">>,<<"moozilla">>]}
     ],
     [#browser{name= <<"CFNetwork">>, family=cfnetwork, in=[<<"cfnetwork">>]}
     ],
     [#browser{name= <<"Eudora">>, family=eudora, type=email, in=[<<"eudora">>]}
     ],
     [#browser{name= <<"PocoMail">>, family=pocomail, type=email, in=[<<"pocomail">>]}
     ],
     [#browser{name= <<"The Bat!">>, family=thebat, type=email, in=[<<"the bat">>]}
     ],
     [#browser{name= <<"NetFront">>, family=netfront, type=mobile, in=[<<"netfront">>]}
     ],
     [#browser{name= <<"Evolution">>, family=evolution, type=email, in=[<<"camelhttpstream">>]}
     ],
     [#browser{name= <<"Lynx">>, family=lynx, type=text, in=[<<"lynx">>]}
     ],
     [#browser{name= <<"Downloading Tool">>, family=tool, type=text, in=[<<"curl">>, <<"wget">>]}
     ]
    ].

os() ->
    Win=#os{name= <<"Windows">>, family=windows, type=computer, manufacturer=microsoft,
            in=[<<"windows">>], out=[<<"palm">>]},
    Droid=#os{name= <<"Android">>, family=android, type=mobile, manufacturer=google,
              in=[<<"android">>]},
    IOs=#os{name= <<"iOS">>, family=ios, type=mobile, manufacturer=apple, in=[<<"like mac os x">>]},
    Kind=#os{name= <<"Linux (Kindle)">>, family=kindle, type=tablet,
             manufacturer=amazon, in=[<<"kindle">>]},
    Sym=#os{name= <<"Symbian OS">>, family=symbian, type=mobile, manufacturer=symbian,
            in=[<<"symbian">>,<<"series60">>]},
    BBY=#os{name= <<"BlackBerryOS">>,family=blackberry, type=mobile,
            manufacturer=blackberry, in=[<<"blackberry">>]},
    [%% Windows
     [Win,
      Win#os{name= <<"Windows 8">>, in=[<<"windows nt 6.2">>], out=[]},
      Win#os{name= <<"Windows 7">>, in=[<<"windows nt 6.1">>], out=[]},
      Win#os{name= <<"Windows Vista">>, in=[<<"windows nt 6">>], out=[]},
      Win#os{name= <<"Windows 2000">>, in=[<<"windows nt 5.0">>], out=[]},
      Win#os{name= <<"Windows XP">>, in=[<<"windows nt 5">>], out=[]},
      Win#os{name= <<"Windows Mobile 7">>, type=mobile, in=[<<"windows phone os 7">>], out=[]},
      Win#os{name= <<"Windows Mobile">>, type=mobile, in=[<<"windows ce">>], out=[]},
      Win#os{name= <<"Windows 98">>, in=[<<"windows 98">>,<<"win98">>]}],
     %% Android
     [Droid,
      Droid#os{name= <<"Android 3.x Tablet">>, type=tablet, in=[<<"android 3">>]},
      Droid#os{name= <<"Android 4.x Tablet">>, type=tablet, in=[<<"xoom">>,<<"transformer">>]},
      Droid#os{name= <<"Android 4.x">>, in=[<<"android 4">>,<<"android-4">>]},
      Droid#os{name= <<"Android 2.x Tablet">>, type=tablet,
               in=[<<"kindle fire">>,<<"gt-p1000">>,<<"sch-i800">>]},
      Droid#os{name= <<"Android 2.x">>, in=[<<"android 2">>]},
      Droid#os{name= <<"Android 1.x">>, in=[<<"android 1">>]}],
     [#os{name= <<"WebOS">>, family=webos, type=mobile, manufacturer=hp, in=[<<"webos">>]}],
     [#os{name= <<"PalmOS">>, family=palm, type=mobile, manufacturer=hp, in=[<<"palm">>]}],
     % ios
     [IOs,
      IOs#os{name= <<"iOS 5 (iPhone)">>, in=[<<"iphone os 5">>]},
      IOs#os{name= <<"iOS 4 (iPhone)">>, in=[<<"iphone os 4">>]},
      IOs#os{name= <<"Mac OS X (iPad)">>, type=tablet, in=[<<"ipad">>]},
      IOs#os{name= <<"Mac OS X (iPhone)">>, in=[<<"iphone">>]},
      IOs#os{name= <<"Mac OS X (iPod)">>, in=[<<"ipod">>]}],
     % osx
     [#os{name= <<"Mac OS X">>, family=mac_osx, type=computer, manufacturer=apple,
          in=[<<"mac os x">>, <<"cfnetwork">>]}],
     % os < osx
     [#os{name= <<"Mac OS">>, family=mac_os, type=computer, manufacturer=apple, in=[<<"mac">>]}],
     %% maemo
     [#os{name= <<"Maemo">>, family=maemo, type=mobile, manufacturer=nokia, in=[<<"maemo">>]}],
     %% bada
     [#os{name= <<"Bada">>, family=bada, type=mobile, manufacturer=samsung, in=[<<"bada">>]}],
     %% google tv
     [#os{name= <<"Android (Google TV)">>, family=google_tv, type=dmr,
          manufacturer=google, in=[<<"googletv">>]}],
     %% kindle
     [Kind,
      Kind#os{name= <<"Linux (Kindle 3)">>, in=[<<"kindle/3">>]},
      Kind#os{name= <<"Linux (Kindle 2)">>, in=[<<"kindle/2">>]}],
     %% linux
     [#os{name= <<"Linux">>, family=linux, type=computer, in=[<<"linux">>,<<"camelhttpstream">>]}],
     %% symbian
     [Sym,
      Sym#os{name= <<"Symbian OS 9.x">>, in=[<<"symbianos/9">>,<<"series60/3">>]},
      Sym#os{name= <<"Symbian OS 8.x">>, in=[<<"symbianos/8">>,<<"series60/2.6">>,<<"series60/2.8">>]},
      Sym#os{name= <<"Symbian OS 7.x">>, in=[<<"symbianos/7">>]},
      Sym#os{name= <<"Symbian OS 6.x">>, in=[<<"symbianos/6">>]}],
     %% blackberry
     [BBY,
      BBY#os{name = <<"BlackBerry 7">>,in=[<<"version/7">>]},
      BBY#os{name = <<"BlackBerry 6">>,in=[<<"version/6">>]}
     ],
     %% blackberry tablet OS
     [#os{name = <<"BlackBerry Tablet OS">>, family=blackberry_tablet, type=tablet, manufacturer=blackberry, in=[<<"rim tablet os">>]}],
     %% others
     [#os{name= <<"Series 40">>, family=series40, type=mobile, manufacturer=nokia, in=[<<"nokia6300">>]}],
     [#os{name= <<"Sony Ericsson">>, family=sony_ericsson, type=mobile,
          manufacturer=sony_ericsson, in=[<<"sonyericsson">>]}],
     [#os{name= <<"SunOS">>, family=sun, type=computer, manufacturer=sun, in=[<<"sunos">>]}],
     [#os{name= <<"Sony Playstation">>, family=playstation, type=game_console,
          manufacturer=sony, in=[<<"playstation">>]}],
     [#os{name= <<"Nintendo Wii">>, family=wii, type=game_console,
          manufacturer=nintendo, in=[<<"wii">>]}],
     [#os{name= <<"Roku OS">>, family=roku, type=dmr, manufacturer=roku,
          in=[<<"roku">>]}]].

characters_to_binary(Binary, Encoding) ->
    case unicode:characters_to_binary(Binary, Encoding, latin1) of
        {error, Result, _} -> Result;
        {incomplete, Result, _} -> Result;
        Result -> Result
    end.
