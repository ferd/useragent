useragent
=========

Useragent is a minimalist port of the Java
[user-agent-utils](http://user-agent-utils.java.net/) in Erlang. It
implements the basic features to figure out the OS and browser information,
but will not look for accurate version numbers.

Build
-----

    make

Test
----

    make test

Usage
-----

The function `useragent:parse/1` can take an iolist or binary UserAgent and
will return desired details:

    1> useragent:parse("Mozilla/4.0 (compatible; MSIE 6.0; Windows CE; IEMobile 6.8) PPC; 240x320; HTC_TyTN/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1").
    [{browser,[{name,<<"IE Mobile 6">>},
               {family,ie},
               {type,mobile},
               {manufacturer,microsoft},
               {engine,trident}]},
     {os,[{name,<<"Windows Mobile">>},
          {family,windows},
          {type,mobile},
          {manufacturer,microsoft}]},
     {string,<<"Mozilla/4.0 (compatible; MSIE 6.0; Windows CE; IEMobile 6.8) PPC; 240x320; HTC_TyTN/1.0 Profile/"...>>}]
    2> useragent:parse(<<"Lynx/2.8.5rel.1 libwww-FM/2.14 SSL-MM/1.4.1 OpenSSL/0.9.7d">>).
    [{browser,[{name,<<"Lynx">>},
               {family,lynx},
               {type,text},
               {manufacturer,undefined},
               {engine,undefined}]},
     {os,[{name,undefined},
          {family,undefined},
          {type,undefined},
          {manufacturer,undefined}]},
     {string,<<"Lynx/2.8.5rel.1 libwww-FM/2.14 SSL-MM/1.4.1 OpenSSL/0.9.7d">>}]

Available information will be returned. All values that are not names are going
to be atoms. Unavailable information will have the atom `undefined`. Note that
the search uses lowercase versions of UA strings.

The downside is that Erlang/OTP only supports lowercasing for latin1 strings.
Because user agent strings are usually bit strings, there shouldn't be much of
a need to change things, but you can optionally pass in the original encoding
so that things get done right:

    3> useragent:parse(<<"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_7; da-dk) AppleWebKit/533.21.1 (KHTML, like Gecko) Version/5.0.5 Safari/533.21.1">>, utf8).
    [{browser,[{name,<<"Safari 5">>},
               {family,safari},
               {type,web},
               {manufacturer,apple},
               {engine,webkit}]},
     {os,[{name,<<"Mac OS X">>},
          {family,mac_osx},
          {type,computer},
          {manufacturer,apple}]},
     {string,<<"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_7; da-dk) AppleWebKit/533.21.1 (KHTML, like Gecko"...>>}]

Extending
---------

Send pull requests, make sure tests are not broken, add more if you can. Tests
were taken from the original Java project, too.
