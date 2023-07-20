-- lets start with simple joins

select *
from toy t
     join accessoire a
     on t.id = a.toy_id;

-- make it an outer join for minions without hobbies
select *
from toy t
     left outer join accessoire a
     on t.id = a.toy_id;

-- we'll need that rownumber thing and also a count of rows
select *
from (
         select *,
                1 t_rn,
                1 t_cnt
         from toy) t
     left outer join (
    select *,
           row_number() over (partition by toy_id) a_rn,
           count(*) over (partition by toy_id)     a_cnt
    from accessoire) a
     on t.id = a.toy_id;


-- join the next table.
select *
from (
         select *,
                1 t_rn,
                1 t_cnt
         from toy) t
     left outer join (
    select *,
           row_number() over (partition by toy_id) a_rn,
           count(*) over (partition by toy_id)     a_cnt
    from accessoire) a
     on t.id = a.toy_id
     left outer join (
    select *,
           row_number() over (partition by toy_id) p_rn,
           count(*) over (partition by toy_id)     p_cnt
    from property) p
     on t.id = p.toy_id
order by t.id;



select
    greatest(t_rn, a_rn, p_rn) total_rn,
    *
from (
         select *,
                1 t_rn,
                1 t_cnt
         from toy) t
     left outer join (
    select *,
           row_number() over (partition by toy_id) a_rn,
           count(*) over (partition by toy_id)     a_cnt
    from accessoire) a
     on t.id = a.toy_id
     left outer join (
    select *,
           row_number() over (partition by toy_id) p_rn,
           count(*) over (partition by toy_id)     p_cnt
    from property) p
     on t.id = p.toy_id
where (
        a_rn is null
        or coalesce(a_rn, 1) = 1
        or a_rn = coalesce(t_rn, 1)
        or a_rn > coalesce(t_cnt, 1))
  and (
        p_rn is null
        or coalesce(p_rn, 1) = 1
        or (
                    (p_rn = coalesce(t_rn, 1) or (p_rn > coalesce(t_cnt, 1) and coalesce(t_rn, 1) = 1))
                    and (p_rn = coalesce(a_rn, 1)) or (p_rn > coalesce(a_cnt, 1) and coalesce(a_rn, 1) = 1)))
order by t.id, total_rn;


-- We have the right number of rows, but we now want to replace duplicated data with null ...
-- Therefore we pull the case expressions out
select
    t_id                                                        toy_root_id,
    t_id                                                        toy_minion_id,
    greatest(t_rn, t_rn)                                        rn,
    case when t_rn = greatest(t_rn, a_rn, p_rn) then t_id end   t_id,
    case when t_rn = greatest(t_rn, a_rn, p_rn) then t_name end t_name,
    case when a_rn = greatest(t_rn, a_rn, p_rn) then a_id end   a_id,
    case when a_rn = greatest(t_rn, a_rn, p_rn) then a_name end a_name,
    case when p_rn = greatest(t_rn, a_rn, p_rn) then p_id end   p_id,
    case when p_rn = greatest(t_rn, a_rn, p_rn) then p_name end p_name
from (
         select
             1    t_rn,
             1    t_cnt,
             id   t_id,
             name t_name
         from toy) t
     left outer join (
    select
        row_number() over (partition by toy_id) a_rn,
        count(*) over (partition by toy_id)     a_cnt,
        id                                      a_id,
        name                                    a_name,
        toy_id                                  a_toy_id
    from accessoire) a
     on t_id = a_toy_id
     left outer join (
    select
        row_number() over (partition by toy_id) p_rn,
        count(*) over (partition by toy_id)     p_cnt,
        id                                      p_id,
        name                                    p_name,
        toy_id                                  p_toy_id
    from property) p
     on t_id = p_toy_id
where (a_rn = t_rn or a_rn is null or a_rn > t_cnt)
  and (p_rn = greatest(t_rn, a_rn) -- if they match we want them
    or (p_rn < greatest(t_rn, a_rn) and p_rn = 1)
    or greatest(t_cnt, a_cnt) < p_rn -- also if we have more properties then accessoires
    or p_rn is null)
order by toy_root_id, rn;
