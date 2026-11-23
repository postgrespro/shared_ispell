Shared ISpell Dictionary
========================
This PostgreSQL extension provides a shared ispell dictionary, i.e.
a dictionary stored in shared memory. The traditional ispell
implementation means that each session initializes and stores the
dictionary in its own process memory, which leads to excessive CPU/RAM consumption.

This extension allocates an area of fixed size in shared memory (the size is defined
in the configuration file) and then loads the dictionary into it
upon the first query to the dictionary.

This extension is useless for stemming (snowball-type) or other simple dictionaries, 
which do not consume much memory. But for ispell dictionaries it can save you a lot of resources.


Install
-------

The supported PostgreSQL versions are from 9.6 to 19

Installing the extension is quite simple and is done as follows:

    $ git clone git@github.com:postgrespro/shared_ispell.git
    $ cd shared_ispell
    $ make USE_PGXS=1
    $ make USE_PGXS=1 install

and then (after connecting to the database)

    db=# CREATE EXTENSION shared_ispell;

> **Important:** Don't forget to set the `PG_CONFIG` variable in case you want to test `shared_ispell` on a custom build of PostgreSQL. Read more [here](https://wiki.postgresql.org/wiki/Building_and_Installing_PostgreSQL_Extension_Modules).


Config
------
This module should be preloaded as it needs to allocate space in the shared memory.
To ensure this add `shared_ispell` to the list of preloaded shared libraries in 
the configuration file.

    # libraries to load
    shared_preload_libraries = 'shared_ispell'

    # size of the shared memory allocated to store dictionaries
    shared_ispell.max_size = 32MB

The maximum size of the allocated shared segment is set by `max_size` GUC variable.
This is a hard limit, the shared segment is not
extensible and its size should be sufficient to load all the dictionaries to be used.

To find out how much memory is actually needed, use a large value
(e.g. 200MB) and load all the dictionaries you need. Then use
the shared_ispell_mem_used() function to find out how much memory
is actually used and then set the `max_size` GUC variable accordingly.
Add some extra space (like 512 kB) to make possible to reload the 
dictionaries with slight changes.

The number of dictionaries loaded in shared segment is limited 
only by their total size.


Using the dictionary
--------------------
Technically, the extension defines a 'shared_ispell' template that
may be used to define custom dictionaries. The following example shows
how to do this:

    CREATE TEXT SEARCH DICTIONARY czech_shared (
        TEMPLATE = shared_ispell,
        DictFile = czech,
        AffFile = czech,
        StopWords = czech
    );

    CREATE TEXT SEARCH CONFIGURATION public.czech_shared
        ( COPY = pg_catalog.simple );

    ALTER TEXT SEARCH CONFIGURATION czech_shared
        ALTER MAPPING FOR asciiword, asciihword, hword_asciipart,
                        word, hword, hword_part
        WITH czech_shared;

The dictionary is ready for usage:

    db=# SELECT ts_lexize('czech_shared', 'automobile');

or whatever you want.


Available functions
-------------------
The extension provides five management functions, that allow to
manage and get information about the preloaded dictionaries. The first two
functions

    shared_ispell_mem_used()
    shared_ispell_mem_available()

allow to get information about the shared segment (used and free memory)
e.g. to properly size the segment (max_size). The following functions
return the list of all loaded dictionaries and stop word lists:

    shared_ispell_dicts()
    shared_ispell_stoplists()

e.g. like this:

    db=# SELECT * FROM shared_ispell_dicts();

     dict_name | affix_name | words | affixes |  bytes   
    -----------+------------+-------+---------+----------
     bulgarian | bulgarian  | 79267 |      12 |  7622128
     czech     | czech      | 96351 |    2544 | 12715000
    (2 rows)


    db=# SELECT * FROM shared_ispell_stoplists();

     stop_name | words | bytes 
    -----------+-------+-------
     czech     |   259 |  4552
    (1 row)

One more function allows to reset the shared memory before reloading 
the updated dictionary files from disk. The sessions that already use
the dictionaries will be forced to reinitialize them (the first one
will rebuild them and copy to the shared segment, other ones will
use it then).

    db=# SELECT shared_ispell_reset();

That's all for now ...

Changes from the original version
-----------------------------
The original version of this module is located in the Tomas Vondra's
[GitHub](https://github.com/tvondra/shared_ispell). It does not handle
affixes which require full regular expressions (regex_t, implemented in regex.h).

The present version of this module can handle affixes with full regular
exressions. To handle it the module loads and stores affix files in each
session memort. As the affix lists are relatively small we hope it is affordable.
Actually this is Tomas
[idea](http://www.postgresql.org/message-id/56A5F3D5.9030702@2ndquadrant.com),
but there is not related code in the GitHub.

Authors
------
- Tomas Vondra [GitHub](https://github.com/tvondra)
- Teodor Sigaev [Postgres Pro](https://postgrespro.com)
