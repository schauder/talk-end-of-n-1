-- lets start with simple joins

select *
from minion m
     join toy t
     on m.id = t.minion_id;

-- make it an outer join for minions without hobbies
select *
from minion m
     left outer join toy t
     on m.id = t.minion_id;

-- we'll need that rownumber thing
select *
from (
         select *,
                1 m_rn
         from minion) m
     left outer join (
    select *,
           row_number() over (partition by minion_id)
    from toy) t
     on m.id = t.minion_id;


-- use this to replace duplicated data
select
    m.id,
    greatest(m_rn, t_rn)                                            rn,
    case when m_rn = greatest(m_rn, t_rn) then m.id else null end   m_id,
    case when m_rn = greatest(m_rn, t_rn) then m.name else null end m_name,
    case when t_rn = greatest(m_rn, t_rn) then t.id else null end   t_id,
    case when t_rn = greatest(m_rn, t_rn) then t.name else null end t_name
from (
         select *,
                1 m_rn
         from minion) m
     left outer join (
    select *,
           row_number() over (partition by minion_id) t_rn
    from toy) t
     on m.id = t.minion_id
order by id, rn;


-- now it gets interesting
-- join the next table.
-- lets start with a simple outer join
-- and of course we add the row_number because we are going to need it, right?
select *
from (
         select
             m.id                                                            root_id,
             greatest(m_rn, t_rn)                                            rn,
             case when m_rn = greatest(m_rn, t_rn) then m.name else null end m_name,
             case when t_rn = greatest(m_rn, t_rn) then t.id else null end   t_id,
             case when t_rn = greatest(m_rn, t_rn) then t.name else null end t_name
         from (
                  select *,
                         1 m_rn
                  from minion) m
              left outer join (
             select *,
                    row_number() over (partition by minion_id) t_rn
             from toy) t
              on m.id = t.minion_id) vt
     left outer join (
    select *,
           row_number() over (partition by minion_id) h_rn
    from hobby) h
     on vt.root_id = h.minion_id
order by root_id, rn;

-- now comes the secret sauce
-- use a simple where clause to remove duplicates

select *
from (
         select
             m.id                                                            root_id,
             greatest(m_rn, t_rn)                                            rn,
             case when m_rn = greatest(m_rn, t_rn) then m.name else null end m_name,
             case when t_rn = greatest(m_rn, t_rn) then t.id else null end   t_id,
             case when t_rn = greatest(m_rn, t_rn) then t.name else null end t_name
         from (
                  select *,
                         1 m_rn
                  from minion) m
              left outer join (
             select *,
                    row_number() over (partition by minion_id) t_rn
             from toy) t
              on m.id = t.minion_id) vt
     left outer join (
    select *,
           row_number() over (partition by minion_id) h_rn
    from hobby) h
     on vt.root_id = h.minion_id
where rn = h_rn -- if they match we want them
   or rn < h_rn -- also if we have more hobbies then toys
order by root_id, rn;


-- We have the right number of rows, but we now want to replace duplicated data with null ...
-- Therefore we pull the case expressions out
select
    t_id                                                                  root_id,
    greatest(t_rn, a_rn, p_rn)                                            rn,
    case when greatest(t_rn, a_rn, p_rn) = t_rn then t_id else null end   t_id,
    case when greatest(t_rn, a_rn, p_rn) = t_rn then t_name else null end t_name,
    case when greatest(t_rn, a_rn, p_rn) = a_rn then a_id else null end   a_id,
    case when greatest(t_rn, a_rn, p_rn) = a_rn then a_name else null end a_name,
    case when greatest(t_rn, a_rn, p_rn) = p_rn then p_id else null end   p_id,
    case when greatest(t_rn, a_rn, p_rn) = p_rn then p_name else null end p_name
from (
         select *
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
              on t_id = a_toy_id) va
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
order by root_id, rn;
