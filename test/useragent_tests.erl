-module(useragent_tests).
-include_lib("eunit/include/eunit.hrl").

browser_test_() ->
    [check_browser(UA, Name,Family,Type,Manufacturer,Engine) ||
        {Name,Family,Type,Manufacturer,Engine,UAs} <- browsers(),
        UA <- UAs].

os_test_() ->
    [check_os(UA, OS) || {OS,UAs} <- os(), UA <- UAs].

check_browser(UA, Name, Family, Type, Manufacturer, Engine) ->
    Res = useragent:parse(UA,latin1),
    B = proplists:get_value(browser,Res,[]),
    [?_assertEqual(Name, proplists:get_value(name,B)),
     ?_assertEqual({Name,Family}, {Name,proplists:get_value(family,B)}),
     ?_assertEqual({Name,Type}, {Name,proplists:get_value(type,B)}),
     ?_assertEqual({Name,Manufacturer}, {Name,proplists:get_value(manufacturer,B)}),
     ?_assertEqual({Name,Engine}, {Name,proplists:get_value(engine,B)})].

check_os(UA, List) ->
    Res = useragent:parse(UA,latin1),
    B = proplists:get_value(os, Res, []),
    prop(UA, List, B).

prop(_UA, [], _Res) ->
    [];
prop(UA, [{K,V}|T], Res) ->
    [?_assertEqual({UA,V},{UA,proplists:get_value(K,Res)}) | prop(UA,T,Res)].


browsers() ->
    [
        {<<"Internet Explorer 6">>, ie, web, microsoft, trident, [
                "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0; T312461)",
                "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.1.4322; XMPP Tiscali Communicator v.10.0.2; .NET CLR 2.0.50727)",
                "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.2; SV1; .NET CLR 1.1.4322; .NET CLR 2.0.50727)"
            ]},
        {<<"Internet Explorer 7">>, ie, web, microsoft, trident, [
                "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; SV1; .NET CLR 2.0.50727)",
                "Mozilla/4.0 (compatible; MSIE 7.0b; Windows NT 6.0 ; .NET CLR 2.0.50215; SL Commerce Client v1.0; Tablet PC 2.0",
                "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; .NET CLR 1.1.4322; .NET CLR 2.0.50727)",
                "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0; SLCC1; .NET CLR 2.0.50727; .NET CLR 3.0.04506)" %% Windows Mail on Vista
            ]},
        {<<"Internet Explorer 8">>, ie, web, microsoft, trident, [
                "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0; WOW64; SLCC1; .NET CLR 2.0.50727; .NET CLR 3.0.04506; Media Center PC 5.0; .NET CLR 1.1.4322)",
                "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0; Win64; x64; .NET CLR 2.0.50727; SLCC1; Media Center PC 5.0; .NET CLR 3.0.04506)"
            ]},
        {<<"Internet Explorer 9">>, ie, web, microsoft, trident, [
                "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; Zune 4.0; InfoPath.3; MS-RTC LM 8; .NET4.0C; .NET4.0E)",
                "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Win64; x64; Trident/5.0"
            ]},
        {<<"Internet Explorer 10">>, ie, web, microsoft, trident, [
                "Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1; Trident/6.0)"
            ]},
        {<<"Internet Explorer 5.5">>, ie, web, microsoft, trident, [
                "Mozilla/4.0 (compatible; MSIE 5.5; Windows NT 5.0; .NET CLR 1.1.4322)",
                "Mozilla/4.0 (compatible; MSIE 5.5; Windows NT 5.0)",
                "Mozilla/4.0 (compatible; MSIE 5.5; Windows 95)"
            ]},
        {<<"Internet Explorer">>, ie, web, microsoft, trident, [ % too old
                "Mozilla/4.0 (compatible; MSIE 4.01; Windows 95)",
                "Mozilla/4.0 (compatible; MSIE 4.0; Windows 95; .NET CLR 1.1.4322; .NET CLR 2.0.50727)",
                "Mozilla/2.0 (compatible; MSIE 3.03; Windows 3.1)"
            ]},
        {<<"Outlook 2007">>, outlook, email, microsoft, word, [
                "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0; SLCC1; .NET CLR 2.0.50727; .NET CLR 3.0.04506; .NET CLR 1.1.4322; MSOffice 12)"
            ]},
        {<<"Outlook 2010">>, outlook, email, microsoft, word, [
                "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0; Trident/4.0; GTB6.4; Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1) ; SLCC1; .NET CLR 2.0.50727; Media Center PC 5.0; .NET CLR 1.1.4322; .NET CLR 3.5.30729; .NET CLR 3.0.30729; OfficeLiveConnector.1.3; OfficeLivePatch.0.0; MSOffice 14)",
                "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.1; Trident/4.0; .NET CLR 2.0.50727; .NET CLR 3.0.30729; .NET CLR 3.5.30729; Media Center PC 6.0; SLCC2; ms-office; MSOffice 14)"
            ]},
        {<<"Windows Live Mail">>, ie, email, microsoft, trident, [
                "Outlook-Express/7.0 (MSIE 6.0; Windows NT 5.1; SV1; SIMBAR={xxx}; .NET CLR 2.0.50727; .NET CLR 1.1.4322; TmstmpExt)",
                "Outlook-Express/7.0 (MSIE 7.0; Windows NT 5.1; InfoPath.2; .NET CLR 1.1.4322; .NET CLR 2.0.50727; TmstmpExt)"
            ]},
        {<<"IE Mobile 6">>, ie, mobile, microsoft, trident, [
                "HTC_TyTN Mozilla/4.0 (compatible; MSIE 6.0; Windows CE; IEMobile 6.12)",
                "Mozilla/4.0 (compatible; MSIE 6.0; Windows CE; IEMobile 6.12) Vodafone/1.0/HTC_s710/1.22.172.3",
                "Mozilla/4.0 (compatible; MSIE 6.0; Windows CE; IEMobile 6.8) PPC; 240x320; HTC_TyTN/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1"
            ]},
        {<<"IE Mobile 7">>, ie, mobile, microsoft, trident, [
                "HTC_TouchDual Mozilla/4.0 (compatible; MSIE 6.0; Windows CE; IEMobile 7.6)",
                "PPC; 240x320; HTC_P3450/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 Mozilla/4.0 (compatible; MSIE 6.0; Windows CE; IEMobile 7.6)",
                "Mozilla/4.0 (compatible; MSIE 6.0; Windows CE; IEMobile 7.6) PPC; MDA Vario/3.0 Profile/MIDP-2.0 Configuration/CLDC-1.1",
                "Palm750/v0005 Mozilla/4.0 (compatible; MSIE 6.0; Windows CE; IEMobile 7.6) UP.Link/6.3.0.0.0"
            ]},
        {<<"IE Mobile 9">>, ie, mobile, microsoft, trident, [
                "Mozilla/5.0 (compatible; MSIE 9.0; Windows Phone OS 7.5; Trident/5.0; IEMobile/9.0)"
            ]},
        {<<"Lotus Notes">>, lotus_notes, email, undefined, undefined, [
                "Mozilla/4.0 (compatible; Lotus-Notes/5.0; Windows-NT)",
                "Mozilla/4.0 (compatible; Lotus-Notes/6.0; Windows-NT)"
            ]},
        {<<"Lynx">>, lynx, text, undefined, undefined, [
                "Lynx/2.8.5rel.1 libwww-FM/2.14 SSL-MM/1.4.1 OpenSSL/0.9.7d",
                "Lynx/2.7.1ac-0.102+intl+csuite libwww-FM/2.14"
            ]},
        {<<"Konqueror">>, konqueror, web, undefined, khtml, [
                "Mozilla/5.0 (compatible; konqueror/3.3; linux 2.4.21-243-smp4G) (KHTML, like Geko)",
                "Mozilla/6.0 (compatible; Konqueror/4.2; i686 FreeBSD 6.4; 20060308)",
                "Mozilla/5.0 (compatible; Konqueror/3.1; Linux 2.4.21-20.0.1.ELsmp; X11; i686; , en_US, en, de)"
            ]},
        {<<"Chrome Mobile">>, safari, mobile, google, webkit, [
                "Mozilla/5.0 (Linux; U; Android-4.0.3; en-us; Xoom Build/IML77) AppleWebKit/535.7 (KHTML, like Gecko) CrMo/16.0.912.75 Safari/535.7",
                "Mozilla/5.0 (Linux; U; Android-4.0.3; en-us; Galaxy Nexus Build/IML74K) AppleWebKit/535.7 (KHTML, like Gecko) CrMo/16.0.912.75 Mobile Safari/535.7"
            ]},
        {<<"Chrome">>, chrome, web, google, webkit, [
                "Mozilla/5.0 (Windows; U; Windows NT 5.2; en-US) AppleWebKit/532.9 (KHTML, like Gecko) Chrome/5.0.310.0 Safari/532.9",
                "Mozilla/5.0 (X11; U; Linux x86_64; en-US) AppleWebKit/532.9 (KHTML, like Gecko) Chrome/5.0.309.0 Safari/532.9"
            ]},
        {<<"Chrome 8">>, chrome, web, google, webkit, [
                "Mozilla/5.0 (Windows; U; Windows NT 5.2; en-US) AppleWebKit/534.10 (KHTML, like Gecko) Chrome/8.0.558.0 Safari/534.10",
                "Mozilla/5.0 (X11; U; Linux x86_64; en-US) AppleWebKit/540.0 (KHTML, like Gecko) Ubuntu/10.10 Chrome/8.1.0.0 Safari/540.0"
            ]},
        {<<"Chrome 9">>, chrome, web, google, webkit, [
                "Mozilla/5.0 (X11; U; Linux x86_64; en-US) AppleWebKit/540.0 (KHTML,like Gecko) Chrome/9.1.0.0 Safari/540.0",
                "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US) AppleWebKit/534.14 (KHTML, like Gecko) Chrome/9.0.600.0 Safari/534.14"
            ]},
        {<<"Chrome 10">>, chrome, web, google, webkit, [
                "Mozilla/5.0 (X11; U; Linux i686; en-US) AppleWebKit/534.15 (KHTML, like Gecko) Ubuntu/10.10 Chromium/10.0.613.0 Chrome/10.0.613.0 Safari/534.15"
            ]},
        {<<"Chrome 11">>, chrome, web, google, webkit, [
                "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/534.24 (KHTML, like Gecko) Chrome/11.0.697.0 Safari/534.24"
            ]},
        {<<"Chrome 12">>, chrome, web, google, webkit, [
                "Mozilla/5.0 (X11; CrOS i686 12.0.742.91) AppleWebKit/534.30 (KHTML, like Gecko) Chrome/12.0.742.93 Safari/534.30"
            ]},
        {<<"Chrome 13">>, chrome, web, google, webkit, [
                "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_7) AppleWebKit/535.1 (KHTML, like Gecko) Chrome/13.0.782.41 Safari/535.1"
            ]},
        {<<"Chrome 14">>, chrome, web, google, webkit, [
                "Mozilla/5.0 (Windows NT 5.1) AppleWebKit/535.1 (KHTML, like Gecko) Chrome/14.0.815.0 Safari/535.1"
            ]},
        {<<"Firefox 3">>, firefox, web, mozilla, gecko, [
                "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.14) Gecko/2009090216 Ubuntu/9.04 (jaunty) Firefox/3.0.14"
            ]},
        {<<"Firefox 4">>, firefox, web, mozilla, gecko, [
                "Mozilla/5.0 (X11; Linux x86_64; rv:2.0b4) Gecko/20100818 Firefox/4.0b4",
                "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:2.0b9pre) Gecko/20101228 Firefox/4.0b9pre"
            ]},
        {<<"Firefox 5">>, firefox, web, mozilla, gecko, [
                "Mozilla/5.0 (Windows NT 6.1; U; ru; rv:5.0.1.6) Gecko/20110501 Firefox/5.0.1 Firefox/5.0.1",
                "Mozilla/5.0 (X11; U; Linux i586; de; rv:5.0) Gecko/20100101 Firefox/5.0"
            ]},
        {<<"Firefox 6">>, firefox, web, mozilla, gecko, [
                "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:6.0a2) Gecko/20110612 Firefox/6.0a2"
            ]},
        {<<"Firefox 14">>, firefox, web, mozilla, gecko, [
                "Mozilla/5.0 (Windows NT 6.2; rv:14.0) Gecko/20100101 Firefox/14.0.1",
                "Mozilla/5.0 (Macintosh; Intel Mac OS X 11.7; rv:14.0) Gecko/20120801 Firefox/14.0.1",
                "Mozilla/5.0 (Windows NT 6.2; rv:14.0) Gecko/20100101 Firefox/14.0",
                "Mozilla/5.0 (Windows NT 6.2; WOW64; rv:14.0) Gecko/20100101 Firefox/14.0"
            ]},
        {<<"Firefox 15">>, firefox, web, mozilla, gecko, [
                "Mozilla/5.0 (Windows NT 6.2; rv:15.0) Gecko/20100101 Firefox/15.0.1",
                "Mozilla/5.0 (Windows NT 6.2; rv:15.0) Gecko/20100101 Firefox/15.0.1 AppEngine-Google; (+http://code.google.com/appengine; appid: slupanama13)",
                "Mozilla/5.0 (chakra; rv:15.0) chakra kubuntu Gecko/20120825 Firefox/15.0",
                "Mozilla/5.0 (Windows NT 6.2; rv:15.0) Gecko/20100101 Firefox/15.0.2.0 IceDragon/15.0.2.0"
            ]},
        {<<"Firefox 16">>, firefox, web, mozilla, gecko, [
                "Mozilla/5.0 (Windows NT 6.2; rv:16.0) Gecko/20100101 Firefox/16.0",
                "Mozilla/5.0 (Windows NT 5.2; Win64; x64; rv:16.0) Gecko/20121026 Firefox/16.0",
                "Mozilla/5.0 (Windows NT 6.2; rv:16.0) Gecko/16.0 Firefox/16.0",
                "Mozilla/5.0 (Windows NT 6.2; rv:16.0; WUID260bb86a94fb8ad07b7bbe87867a42ef; WTB619) Gecko/20100101 Firefox/16.0"
            ]},
        {<<"Firefox 17">>, firefox, web, mozilla, gecko, [
                "Mozilla/5.0 (Windows NT 6.2; rv:17.0) Gecko/20100101 Firefox/17.0",
                "Mozilla/5.0 (Windows NT 6.2; rv:17.0) Gecko/17.0 Firefox/17.0",
                "Mozilla/5.0 (Windows NT 6.2; rv:17.0) Gecko/17.0 Firefox/17.0 AppEngine-Google; (+http://code.google.com/appengine; appid: sharry96887)",
                "Mozilla/5.0 (X11; DragonFly x8664; rv:17.0) Gecko/20121214 Firefox/17.0",
                "Mozilla/5.0 (Mac OS X 10.7 Lion; rv:17.0) Gecko/20100101 Firefox/17.0"
            ]},
        {<<"Firefox 18">>, firefox, web, mozilla, gecko, [
                "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8.3) Gecko/20120221 Firefox/18.0",
                "Mozilla/6.0 (Windows NT 6.1; WOW64; rv:16.0.1) Gecko/20121011 Firefox/18.0.1 CentOS",
                "Mozilla/5.0 (Windows NT 6.2; rv:18.0) Gecko/20100101 Firefox/18.0",
                "Mozilla/5.0 (Windows NT 6.2; rv:18.0) Gecko/18.0 Firefox/18.0"
            ]},
        {<<"Firefox 19">>, firefox, web, mozilla, gecko, [
                "Mozilla/5.0 (Windows NT 6.2; rv:19.0) Gecko/20100101 Firefox/19.0",
                "Mozilla/5.0 (Windows NT 6.2; rv:19.0) Gecko/20100101 Firefox/19.0 AlexaToolbar/alxf-2.17",
                "Mozilla/5.0 (Windows NT 6.2; rv:19.0) Gecko/19.0 Firefox/19.0",
                "Mozilla/5.0 (Android 4.2; rv:19.0) Gecko/20121129 Firefox/19.0"
            ]},
        {<<"Firefox 20">>, firefox, web, mozilla, gecko, [
                "Mozilla/5.0 (Windows NT 6.2; rv:20.0) Gecko/20.0 Firefox/20.0",
                "Mozilla/5.0 (Windows NT 6.2; rv:20.0) Gecko/20121217 Firefox/20.0",
                "Mozilla/5.0 (Windows NT 5.2; Win64; x64; rv:20.0) Gecko/20121218 Firefox/20.0",
                "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:20.0) Gecko/20121215 Firefox/20.0 AppEngine-Google; (+http://code.google.com/appengine; appid: slubuntuk)"
            ]},
        {<<"Firefox 21">>, firefox, web, mozilla, gecko, [
                "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:21.0) Gecko/20130331 Firefox/21.0",
                "Mozilla/5.0 (Windows NT 6.2; rv:21.0) Gecko/20130326 Firefox/21.0",
                "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:21.0) Gecko/20130401 Firefox/21.0",
                "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:21.0) Gecko/20100101 Firefox/21.0",
                % merge 21.0.1 in 21
                "Mozilla/5.0 (Windows NT 6.2; Win64; x64; rv:16.0.1) Gecko/20121011 Firefox/21.0.1"
            ]},
        {<<"Firefox 22">>, firefox, web, mozilla, gecko, [
                "Mozilla/5.0 (Windows NT 6.1; rv:22.0) Gecko/20130405 Firefox/22.0",
                "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:22.0) Gecko/20130328 Firefox/22.0"
            ]},
        {<<"Firefox 3 Mobile">>, firefox, mobile, mozilla, gecko, [
                "Mozilla/5.0 (X11; U; Linux armv7l; en-US; rv:1.9.2a1pre) Gecko/20091127 Firefox/3.5 Maemo Browser 1.5.6 RX-51 N900"
            ]},
        {<<"Safari">>, safari, web, apple, webkit, [
                "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_5_7; en-us) AppleWebKit/525.28.3 (KHTML, like Gecko) Version/3.2.3 Safari/525.28.3",
                "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-gb) AppleWebKit/523.10.6 (KHTML, like Gecko) Version/3.0.4 Safari/523.10.6"
            ]},
        {<<"Safari 5">>, safari, web, apple, webkit, [
                "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_4; en-us) AppleWebKit/533.16 (KHTML, like Gecko) Version/5.0 Safari/533.16",
                "Mozilla/5.0 (Windows; U; Windows NT 6.1; ja-JP) AppleWebKit/533.16 (KHTML, like Gecko) Version/5.0 Safari/533.16",
                "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_5; en-us) AppleWebKit/533.19.4 (KHTML, like Gecko) Version/5.0.3 Safari/533.19.4",
                "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_7; da-dk) AppleWebKit/533.21.1 (KHTML, like Gecko) Version/5.0.5 Safari/533.21.1"
            ]},
        {<<"Safari 4">>, safari, web, apple, webkit, [
                "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_2; en-us) AppleWebKit/531.21.8 (KHTML, like Gecko) Version/4.0.4 Safari/531.21.10",
                "Mozilla/5.0 (Windows; U; Windows NT 6.1; es-ES) AppleWebKit/531.22.7 (KHTML, like Gecko) Version/4.0.5 Safari/531.22.7",
                "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_5_7; en-us) AppleWebKit/531.2+ (KHTML, like Gecko) Version/4.0.1 Safari/530.18"
            ]},
        {<<"Mobile Safari">>, safari, mobile, apple, webkit, [
                "Mozilla/5.0 (Linux; U; Android 2.1; en-us; Nexus One Build/ERD62) AppleWebKit/530.17 (KHTML, like Gecko) Version/4.0 Mobile Safari/530.17",
                "Mozilla/5.0 (iPod; U; CPU iPhone OS 2_0 like Mac OS X; de-de) AppleWebKit/525.18.1 (KHTML, like Gecko) Version/3.1.1 Mobile/5A347 Safari/525.20", % Mobile Safari 3.1.1
                "Mozilla/5.0 (iPod; U; CPU like Mac OS X; en) AppleWebKit/420.1 (KHTML, like Gecko) Version/3.0 Mobile/3A101a Safari/419.3", % Mobile Safari 3.0
                "Mozilla/5.0 (iPad; U; CPU OS 3_2 like Mac OS X; en-us) AppleWebKit/531.21.10 (KHTML, like Gecko) Version/4.0.4 Mobile/7B367 Safari/531.21.10",
                "Mozilla/5.0 (iPod; U; CPU iPhone OS 4_1 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8B117 Safari/6531.22.7",
                "Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3"
            ]},
        {<<"Samsung Dolphin 2">>, dolfin2, mobile, samsung, webkit, [
                "Mozilla/5.0 (SAMSUNG; SAMSUNG-GT-S8500/S8500NEJE5; U; Bada/1.0; fr-fr) AppleWebKit/533.1 (KHTML, like Gecko) Dolfin/2.0 Mobile WVGA SMM-MMS/1.2.0 NexPlayer/3.0 profile/MIDP-2.1 configuration/CLDC-1.1 OPN-B"
            ]},
        %% similar to Safari, but doesn't mention Safari in the user-agent string
        {<<"Apple Mail">>, apple_mail, email, apple, webkit, [
                "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_4; en-us) AppleWebKit/533.18.1 (KHTML, like Gecko)"
            ]},
        {<<"OmniWeb">>, omniweb, web, undefined, webkit, [
                "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_5_8; en-US) AppleWebKit/531.9+(KHTML, like Gecko, Safari/528.16) OmniWeb/v622.10.0",
                "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US) AppleWebKit/525.18 (KHTML, like Gecko, Safari/525.20) OmniWeb/v622.3.0.105198"
            ]},
        {<<"Opera">>, opera, web, opera, presto, [
                "Opera/8.0 (Macintosh; PPC Mac OS X; U; en)"
            ]},
        {<<"Opera 9">>, opera, web, opera, presto, [
                "Opera/9.52 (Windows NT 5.1; U; en)",
                "Opera/9.20 (Macintosh; Intel Mac OS X; U; en)"
            ]},
        {<<"Opera 10">>, opera, web, opera, presto, [
                "Opera/9.80 (Windows NT 5.2; U; en) Presto/2.2.15 Version/10.10",
                "Opera/9.80 (Macintosh; Intel Mac OS X; U; en) Presto/2.6.30 Version/10.61"
            ]},
        {<<"Opera Mini">>, opera, mobile, opera, presto, [
                "Opera/9.60 (J2ME/MIDP; Opera Mini/4.2.13337/458; U; en) Presto/2.2.0",
                "Opera/9.80 (J2ME/MIDP; Opera Mini/5.0.16823/1428; U; en) Presto/2.2.0"
            ]},
        {<<"Camino 2">>, camino, web, undefined, gecko, [
                "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en; rv:1.9.0.19) Gecko/2010111021 Camino/2.0.6 (MultiLang) (like Firefox/3.0.19)",
                "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en; rv:1.9.0.18) Gecko/2010021619 Camino/2.0.2 (like Firefox/3.0.18)"
            ]},
        {<<"Camino">>, camino, web, undefined, gecko, [
                "Mozilla/5.0 (Macintosh; U; PPC Mac OS X Mach-O; it; rv:1.8.1.21) Gecko/20090327 Camino/1.6.7 (MultiLang) (like Firefox/2.0.0.21pre)",
                "Mozilla/5.0 (Macintosh; U; PPC Mac OS X Mach-O; en-US; rv:1.8.0.4) Gecko/20060613 Camino/1.0.2"
            ]},
        {<<"Flock">>, flock, web, undefined, gecko, [
                "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.3) Gecko/2008100716 Firefox/3.0.3 Flock/2.0"
            ]},
        {<<"SeaMonkey">>, seamonkey, web, undefined, gecko, [
                "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.1.13) Gecko/20100914 Mnenhy/0.8.3 SeaMonkey/2.0.8"
            ]},
        {<<"Robot/Spider">>, robot, robot, undefined, undefined, [
                "Mozilla/5.0 (compatible; Googlebot/2.1; http://www.google.com/bot.html)",
                "Mozilla/5.0 (compatible; Yahoo! Slurp; http://help.yahoo.com/help/us/ysearch/slurp)",
                "Googlebot-Image/1.0"
            ]},
        {<<"Downloading Tool">>, tool, text, undefined, undefined, [
                "curl/7.19.5 (i586-pc-mingw32msvc) libcurl/7.19.5 OpenSSL/0.9.8l zlib/1.2.3",
                "Wget/1.8.1"
            ]},
        {<<"Thunderbird 3">>, thunderbird, email, mozilla, gecko, [
                "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.2.12) Gecko/20101027 Thunderbird/3.1.6",
                "Mozilla/5.0 (Windows; U; Windows NT 6.1; sv-SE; rv:1.9.2.8) Gecko/20100802 Thunderbird/3.1.2 ThunderBrowse/3.3.2"
            ]},
        {<<"Thunderbird 2">>, thunderbird, email, mozilla, gecko, [
                "Mozilla/5.0 (Windows; U; Windows NT 6.0; en-GB; rv:1.8.1.14) Gecko/20080421 Thunderbird/2.0.0.14",
                "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1.17) Gecko/20080914 Thunderbird/2.0.0.17"
            ]},
        {<<"Silk">>, safari, web, amazon, webkit, [
                "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_3; en-us; Silk/1.1.0-80) AppleWebKit/533.16 (KHTML, like Gecko) Version/5.0 Safari/533.16 Silk-Accelerated=true"
            ]}
    ].

os() ->
    [
        {[{type,tablet}], [
                "Mozilla/5.0 (Linux; U; Android 2.2; es-es; GT-P1000 Build/FROYO) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1",
                "Mozilla/5.0 (Linux; U; Android 2.2; en-us; SCH-I800 Build/FROYO) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1",
                "Mozilla/5.0 (iPad; U; CPU iPhone OS 3_2 like Mac OS X; en-us) AppleWebKit/531.21.10 (KHTML, like Gecko) Mobile/7D11",
                "Mozilla/4.0 (compatible; Linux 2.6.10) NetFront/3.3 Kindle/1.0 (screen 600x800)",
                "Mozilla/4.0 (compatible; Linux 2.6.22) NetFront/3.4 Kindle/2.0 (screen 600x800)",
                "Mozilla/5.0 (Linux; U; en-US) AppleWebKit/528.5+ (KHTML, like Gecko, Safari/528.5+) Version/4.0 Kindle/3.0 (screen 600x800; rotate)",
                "Mozilla/5.0 (Linux; U; Android 3.0; en-us; Xoom Build/HRI39) AppleWebKit/534.13 (KHTML, like Gecko) Version/4.0 Safari/534.13", % dropped the mobile part, so Android without mobile should be a tablet!
                "Mozilla/5.0 (PlayBook; U; RIM Tablet OS 1.0.0; en-US) AppleWebKit/534.8+ like Gecko) Version/0.0.1 Safari/534.8+",
                "Mozilla/5.0 (Linux; U; Android 4.0.3; en-us; Transformer TF101 Build/IML74K) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Safari/534.30"
            ]},
        {[{type,dmr}, {family,google_tv}], [
                "Mozilla/5.0 (X11; U; Linux i686; en-US) AppleWebKit/533.4 (KHTML, like Gecko) Chrome/5.0.375.127 Large Screen Safari/533.4 GoogleTV/161242",
                "Mozilla/5.0 (X11; U: Linux i686; en-US) AppleWebKit/533.4 (KHTML, like Gecko) Chrome/5.0.375.127 Large Screen Safari/533.4 GoogleTV/162671", % Sony
                "Mozilla/5.0 (X11; U: Linux i686; en-US) AppleWebKit/533.4 (KHTML, like Gecko) Chrome/5.0.375.127 Large Screen Safari/533.4 GoogleTV/b39389" % Logitech Revue
            ]},
        {[{type,game_console}], [
                "Mozilla/5.0 (PLAYSTATION 3; 1.00)",
                "Opera/9.30 (Nintendo Wii; U; ; 2071; Wii Shop Channel/1.0; en)"
            ]},
        %% window CE devices
        {[{family,windows},{type,mobile},{manufacturer,microsoft}], [
                "Mozilla/4.0 (compatible; MSIE 4.01; Windows CE; O2 Xda 2mini; PPC; 240x320)",
                "Mozilla/4.0 (compatible; MSIE 4.01; Windows CE; PPC; MDA Compact/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1",
                "HPiPAQhw6900/1.0/Mozilla/4.0 (compatible; MSIE 4.01; Windows CE; PPC; 240x240)",
                "Mozilla/4.0 (compatible; MSIE 6.0; Windows CE; IEMobile 6.8) PPC; 240x320; HTC_P3300/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1",
                "PPC; 240x320; HTC_P3450/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 Mozilla/4.0 (compatible; MSIE 6.0; Windows CE; IEMobile 6.12)",
                "Mozilla/4.0 (compatible; MSIE 4.01; Windows CE; PPC; MDA compact/3.0 Profile/MIDP-2.0 Configuration/CLDC-1.1)",
                "Mozilla/4.0 (compatible; MSIE 4.01; Windows CE; PPC; MDA Vario/1.2 Profile/MIDP-2.0 Configuration/CLDC-1.1)",
                "HTC_S620 Mozilla/4.0 (compatible; MSIE 6.0; Windows CE; IEMobile 6.12)",
                "HTCS620-Mozilla/4.0 (compatible; MSIE 4.01; Windows CE; Smartphone; 320x240)",
                "Mozilla/4.0 (compatible; MSIE 6.0; Windows CE; PPC)",
                "SAMSUNG-SGH-i600/1.0 (compatible; MSIE 6.0; Windows CE; IEMobile 6.8)",
                "Mozilla/4.0 (compatible; MSIE 6.0; Windows CE; Smartphone)",
                "HTC_TouchDual Mozilla/4.0 (compatible; MSIE 6.0; Windows CE; IEMobile 7.6)",
                "Palm750/v0005 Mozilla/4.0 (compatible; MSIE 6.0; Windows CE; IEMobile 7.6) UP.Link/6.3.0.0.0"
            ]},
        {[{name,<<"PalmOS">>},{family,palm},{type,mobile},{manufacturer,hp}], [
                "Mozilla/4.0 (compatible; MSIE 6.0; Windows 98; PalmSource/Palm-TunX; Blazer/4.3) 16;320x320", % Palm LiveDrive
                "Mozilla/4.0 (compatible; MSIE 6.0; Windows 98; PalmSource/Palm-D050; Blazer/4.3) 16;320x320)", % Palm TX PDA
                "Mozilla/4.76 (compatible; MSIE 6.0; U; Windows 95; PalmSource; PalmOS; WebPro; Tungsten Proxyless 1.1 320x320x16)"
            ]},
        {[{name,<<"WebOS">>},{family,webos},{type,mobile},{manufacturer,hp}], [
                "Mozilla/5.0 (webOS/1.3; U; en-US) AppleWebKit/525.27.1 (KHTML, like Gecko) Version/1.0 Safari/525.27.1 Desktop/1.0",
                "Mozilla/5.0 (webOS/1.0; U; en-US) AppleWebKit/525.27.1 (KHTML, like Gecko) Version/1.0 Safari/525.27.1 Pre/1.0"
            ]},
        {[{name,<<"Symbian OS 9.x">>},{family,symbian},{type,mobile},{manufacturer,symbian}], [
                "Mozilla/5.0 (SymbianOS/9.2; U; Series60/3.1 NokiaN95/10.0.018; Profile/MIDP-2.0 Configuration/CLDC-1.1 ) AppleWebKit/413 (KHTML, like Gecko) Safari/413",
                "Mozilla/5.0 (SymbianOS/9.1; U; en-us) AppleWebKit/413 (KHTML, like Gecko) Safari/413",
                %% No symbian in string. from 3.0 on it is Symbian OS 9.
                "NokiaN80-3/1.0552.0.7Series60/3.0Profile/MIDP-2.0Configuration/CLDC-1.1",
                "NokiaN73-1/3.0638.0.0.1 Series60/3.0 Profile/MIDP-2.0 Configuration/CLDC-1.1",
                "Mozilla/5.0 (SymbianOS/9.2; U; Series60/3.1 NokiaE90-1/07.40.1.2; Profile/MIDP-2.0 Configuration/CLDC-1.1 ) AppleWebKit/413 (KHTML, like Gecko) Safari/413"
            ]},
        {[{name, <<"Symbian OS 8.x">>},{family,symbian},{type,mobile},{manufacturer,symbian}], [
                %% No Symbian in string, but we know, that 2.6. and 2.8 are Symbian OS 8 phones.
                "NokiaN90-1/3.0545.5.1 Series60/2.8 Profile/MIDP-2.0 Configuration/CLDC-1.1"
            ]},
        {[{name, <<"Symbian OS 7.x">>},{family,symbian},{type,mobile},{manufacturer,symbian}], [
                "Nokia3230/2.0 (5.0614.0) SymbianOS/7.0s Series60/2.1 Profile/MIDP-2.0Configuration/CLDC-1.0"
            ]},
        {[{name, <<"Symbian OS">>},{family,symbian},{type,mobile},{manufacturer,symbian}], [
                %% One of the SE phones with Symbian OS
                "SonyEricssonP1i/R100 Mozilla/4.0 (compatible; MSIE 6.0; Symbian OS; 661) Opera 8.65 [nl]"
            ]},
        {[{name, <<"Sony Ericsson">>},{family,sony_ericsson},{type,mobile},{manufacturer,sony_ericsson}], [
                "SonyEricssonK550i/R1JD Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1",
                "SonyEricssonK610i/R1CB Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1"
            ]},
        {[{name,<<"Mac OS X (iPhone)">>},{family,ios},{manufacturer,apple},{type,mobile}], [
                "Mozilla/5.0 (iPhone; U; CPU like Mac OS X; nl-nl) AppleWebKit/420.1 (KHTML, like Gecko)",
                "Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko)",
                "Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420.1 (KHTML, like Gecko) Version/3.0 Mobile/4A93 Safari/419.3"
            ]},
        {[{name,<<"iOS 4 (iPhone)">>},{family,ios},{manufacturer,apple},{type,mobile}], [
                "Mozilla/5.0 (iPhone Simulator; U; CPU iPhone OS 4_0 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8A293 Safari/6531.22.7",
                "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_0 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8A293 Safari/6531.22.7"
            ]},
        {[{name,<<"iOS 5 (iPhone)">>},{family,ios},{manufacturer,apple},{type,mobile}], [
                "Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3"
            ]},
        {[{name,<<"Mac OS X (iPod)">>},{family,ios},{manufacturer,apple},{type,mobile}], [
                "Mozilla/5.0 (iPod; U; CPU like Mac OS X; nl-nl) AppleWebKit/420.1 (KHTML, like Gecko)",
                "Mozilla/5.0 (iPod; U; CPU like Mac OS X; en) AppleWebKit/420.1 (KHTML, like Gecko)",
                "Mozilla/5.0 (iPod; U; CPU like Mac OS X; en) AppleWebKit/420.1 (KHTML, like Gecko) Version/3.0 Mobile/3A101a Safari/419.3"
            ]},
        {[{name,<<"Mac OS X (iPad)">>},{family,ios},{manufacturer,apple},{type,tablet}], [
                "Mozilla/5.0 (iPad; U; CPU OS 3_2 like Mac OS X; en-us) AppleWebKit/531.21.10 (KHTML, like Gecko) Version/4.0.4 Mobile/7B367 Safari/531.21.10", % final iPad Simulator
                "Mozilla/5.0 (iPad; U; CPU OS 3_2 like Mac OS X; en-us) AppleWebKit/531.21.10 (KHTML, like Gecko) Version/4.0.4 Mobile/7B334b Safari/531.21.10",
                "Mozilla/5.0 (iPad; U; CPU OS 4_2_1 like Mac OS X; ja-jp) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8C148 Safari/6533.18.5",
                "Mozilla/5.0 (iPad; CPU OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3"
            ]},
        {[{name,<<"BlackBerryOS">>},{family,blackberry},{manufacturer,blackberry},{type,mobile}], [
                "BlackBerry8700/4.1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 VendorID/150",
                "BlackBerry8707/4.1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 VendorID/139",
                "BlackBerry7290/4.0.2 Profile/MIDP-2.0 Configuration/CLDC-1.1",
                "BlackBerry8310/4.2.2 Profile/MIDP-2.0 Configuration/CLDC-1.1 VendorID/120",
                "BlackBerry8100/4.2.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 VendorID/150"			
            ]},
        {[{name,<<"BlackBerry 6">>},{family,blackberry},{manufacturer,blackberry},{type,mobile}], [
                "Mozilla/5.0 (BlackBerry; U; BlackBerry 9800; en-US) AppleWebKit/534.1+ (KHTML, like Gecko) Version/6.0.0.141 Mobile Safari/534.1+"
            ]},
        {[{name,<<"BlackBerry 7">>},{family,blackberry},{manufacturer,blackberry},{type,mobile}], [
                "Mozilla/5.0 (BlackBerry; U; BlackBerry 9850; en-US) AppleWebKit/534.11+ (KHTML, like Gecko) Version/7.0.0.115 Mobile Safari/534.11+"
            ]},
        {[{name,<<"Android 1.x">>},{family,android},{manufacturer,google},{type,mobile}], [
                "Mozilla/5.0 (Linux; U; Android 1.6; nl-nl; T-Mobile G1 Build/DRC92) AppleWebKit/528.5+ (KHTML, like Gecko) Version/3.1.2 Mobile Safari/525.20.1",
                "Mozilla/5.0 (Linux; U; Android 1.5; nl-nl; HTC Hero Build/CUPCAKE) AppleWebKit/528.5+ (KHTML, like Gecko) Version/3.1.2 Mobile Safari/525.20.1"
            ]},
        {[{name,<<"Android 2.x">>},{family,android},{manufacturer,google},{type,mobile}], [
                "Mozilla/5.0 (Linux; U; Android 2.1; en-gb; Nexus One Build/ERD79) AppleWebKit/530.17 (KHTML, like Gecko) Version/4.0 Mobile Safari/530.17",
                "Mozilla/5.0 (Linux; U; Android 2.0; en-gb; Milestone Build/SHOLS_U2_01.03.1) AppleWebKit/530.17 (KHTML, like Gecko) Version/4.0 Mobile Safari/530.17"
            ]},
        {[{name,<<"Android 4.x">>},{family,android},{manufacturer,google},{type,mobile}], [
                "Mozilla/5.0 (Linux; U; Android 4.0.1; en-us; Galaxy Nexus Build/ICL41) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30"
            ]},
        {[{name,<<"Android 2.x Tablet">>},{family,android},{manufacturer,google},{type,tablet}], [
                "Mozilla/5.0 (Linux; U; Android 2.3.4; en-us; Kindle Fire Build/GINGERBREAD) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1"
            ]},
        {[{name,<<"Android 3.x Tablet">>},{family,android},{manufacturer,google},{type,tablet}], [
                "Mozilla/5.0 (Linux; U; Android 3.0; en-us; Xoom Build/HRI39) AppleWebKit/534.13 (KHTML, like Gecko) Version/4.0 Safari/534.13",
                "Mozilla/5.0 (Linux; U; Android 3.0.1; en-us; Xoom Build/HRI66) AppleWebKit/534.13 (KHTML, like Gecko) Version/4.0 Safari/534.13",
                "Mozilla/5.0 (Linux; U; Android 3.1; en-us; GT-P7510 Build/HMJ37) AppleWebKit/534.13 (KHTML, like Gecko) Version/4.0 Safari/534.13" % Samsung Galaxy Tab
            ]},
        {[{name,<<"Android 4.x Tablet">>},{family,android},{manufacturer,google},{type,tablet}], [
                "Mozilla/5.0 (Linux; U; Android 4.0.3; en-us; Transformer TF101 Build/IML74K) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Safari/534.30",
                "Mozilla/5.0 (Linux; U; Android-4.0.3; en-us; Xoom Build/IML77) AppleWebKit/535.7 (KHTML, like Gecko) CrMo/16.0.912.75 Safari/535.7"
            ]},
        {[{name,<<"Windows 98">>},{family,windows},{manufacturer,microsoft},{type,computer}], [
                "Mozilla/4.0 (compatible; MSIE 6.0; Windows 98; Rogers HiáSpeed Internet; (R1 1.3))",
                "Mozilla/5.0 (Windows; U; Win98; en-US; rv:1.8b3) Gecko/20050713 SeaMonkey/1.0a"
            ]},
        {[{name,<<"Windows XP">>},{family,windows},{manufacturer,microsoft},{type,computer}], [
                "Mozilla/5.0 (Windows; U; Windows NT 5.1; de; rv:1.9.2.8) Gecko/20100722 Firefox/3.6.8 ( .NET CLR 3.5.30729)",
                "Mozilla/5.0 (compatible; MSIE 7.0; Windows NT 5.2; WOW64; .NET CLR 2.0.50727)"
            ]},
        {[{name,<<"Windows Vista">>},{family,windows},{manufacturer,microsoft},{type,computer}], [
                "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0; SLCC1; .NET CLR 2.0.50727; .NET CLR 3.0.04506)"
            ]},
        {[{name,<<"Windows 7">>},{family,windows},{manufacturer,microsoft},{type,computer}], [
                "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.1; WOW64; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; MDDC; MSOffice 12)",
                "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0; Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1) ; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; Media Center PC 5.0; SLCC1; InfoPath.2)"
            ]},
        {[{name,<<"Windows Mobile 7">>},{family,windows},{manufacturer,microsoft},{type,mobile}], [
                "Mozilla/4.0 (compatible; MSIE 7.0; Windows Phone OS 7.0; Trident/3.1; IEMobile/7.0) Asus;Galaxy6",
                "Mozilla/5.0 (compatible; MSIE 9.0; Windows Phone OS 7.5; Trident/5.0; IEMobile/9.0)"
            ]},
        {[{name,<<"Windows 8">>},{family,windows},{manufacturer,microsoft},{type,computer}], [
                "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.2; WOW64; Trident/6.0; .NET4.0E; .NET4.0C; Tablet PC 2.0; .NET CLR 3.5.30729; .NET CLR 3.0.30729; .NET CLR 2.0.50727; Zune 4.7; InfoPath.3)"
                "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.2; Win64; x64; Trident/6.0; .NET4.0E; .NET4.0C; Tablet PC 2.0; .NET CLR 3.5.30729; .NET CLR 3.0.30729; .NET CLR 2.0.50727; Zune 4.7; InfoPath.3)",
                "Mozilla/5.0 (Windows NT 6.2) AppleWebKit/537.13 (KHTML, like Gecko) Chrome/24.0.1290.1 Safari/537.13",
                "Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1312.57 Safari/537.17,gzip(gfe)",
                "Mozilla/5.0 (Windows NT 6.2; WOW64; rv:17.0) Gecko/20100101 Firefox/17.0",
                "Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; WOW64; Trident/6.0)",
                "Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; WOW64; Trident/6.0; VER#XC#80836766876745485371484874; MATBJS)",
                "Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; Win64; x64; Trident/6.0; MDDCJS)"
            ]},
        {[{name,<<"Bada">>},{family,bada},{manufacturer,samsung},{type,mobile}], [
                "Mozilla/5.0 (SAMSUNG; SAMSUNG-GT-S8500/S8500NEJE5; U; Bada/1.0; fr-fr) AppleWebKit/533.1 (KHTML, like Gecko) Dolfin/2.0 Mobile WVGA SMM-MMS/1.2.0 NexPlayer/3.0 profile/MIDP-2.1 configuration/CLDC-1.1 OPN-B",
                "Mozilla/5.0 (SAMSUNG; SAMSUNG-GT-S8500/S8500XXJL2; U; Bada/1.2; de-de) AppleWebKit/533.1 (KHTML, like Gecko) Dolfin/2.2 Mobile WVGA SMM-MMS/1.2.0 OPN-B"
            ]},
        {[{name,<<"Maemo">>},{family,maemo},{manufacturer,nokia},{type,mobile}], [
                "Mozilla/5.0 (X11; U; Linux armv7l; en-US; rv:1.9.2a1pre) Gecko/20091127 Firefox/3.5 Maemo Browser 1.5.6 RX-51 N900"
            ]},
        {[{name,<<"Linux (Kindle 2)">>},{family,kindle},{manufacturer,amazon},{type,tablet}], [
                "Mozilla/4.0 (compatible; Linux 2.6.22) NetFront/3.4 Kindle/2.0 (screen 600x800)"
            ]},
        {[{name,<<"Linux (Kindle 3)">>},{family,kindle},{manufacturer,amazon},{type,tablet}], [
                "Mozilla/5.0 (Linux; U; en-US) AppleWebKit/528.5+ (KHTML, like Gecko, Safari/528.5+) Version/4.0 Kindle/3.0 (screen 600x800; rotate)"
            ]},
        % kindle fire ?
        %{[{name,<<"Android 2.x Tablet">>},{family,android},{manufacturer,google},{type,tablet}], [
        %        "Mozilla/5.0 (Linux; U; Android 2.3.4; en-us; Kindle Fire Build/GINGERBREAD) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1",
        %        "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_3; en-us; Silk/1.1.0-80) AppleWebKit/533.16 (KHTML, like Gecko) Version/5.0 Safari/533.16 Silk-Accelerated=true" % silk mode
        %    ]},
        {[{name,<<"Roku OS">>},{family,roku},{manufacturer,roku},{type,dmr}], [
                "Roku/DVP-4.1 (024.01E01250A)", % Roku 2 XD
                "Roku/DVP-3.0 (013.00E02227A)"
            ]}
    ].
