create type si_dicts_result as (dict_name VARCHAR, affix_name VARCHAR, words INT, affixes INT, bytes INT);

create function shared_ispell_dicts( OUT dict_name VARCHAR, OUT affix_name VARCHAR, OUT words INT, OUT affixes INT, OUT bytes INT)
returns SETOF record as $$
declare
    qString varchar(4000);
    rec si_dicts_result;
begin
    qString := 'select * from shared_ispell_dicts()';
    for rec in execute qString loop
        return NEXT;
    end loop;
    return;
end
$$ language plpgsql;

create extension shared_ispell;

drop extension if exists shared_ispell;
drop type si_dicts_result;
drop function shared_ispell_dicts;

create type si_stoplists_result as (stop_name VARCHAR, words INT, bytes INT);

create function shared_ispell_stoplists(OUT stop_name VARCHAR, OUT words INT, OUT bytes INT)
returns SETOF record as $$
declare 
    rec si_stoplists_result;
    qString varchar(4000);
begin
    qString := 'select * from shared_ispell_stoplists()';
    for rec in execute qString loop
        return NEXT;
    end loop;
    return;
end
$$ language plpgsql;

create extension shared_ispell;

drop extension if exists shared_ispell;
drop type si_stoplists_result;
drop function shared_ispell_stoplists;
