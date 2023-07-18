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
    m_id                                                                  root_id,
    greatest(m_rn, t_rn, h_rn)                                            rn,
    case when greatest(m_rn, t_rn, h_rn) = m_rn then m_id else null end   m_id,
    case when greatest(m_rn, t_rn, h_rn) = m_rn then m_name else null end m_name,
    case when greatest(m_rn, t_rn, h_rn) = t_rn then t_id else null end   t_id,
    case when greatest(m_rn, t_rn, h_rn) = t_rn then t_name else null end t_name,
    case when greatest(m_rn, t_rn, h_rn) = h_rn then h_id else null end   h_id,
    case when greatest(m_rn, t_rn, h_rn) = h_rn then h_name else null end h_name,
    *
from (
         select *
         from (
                  select
                      1    m_rn,
                      1    m_cnt,
                      id   m_id,
                      name m_name
                  from minion) m
              left outer join (
             select
                 row_number() over (partition by minion_id) t_rn,
                 count(*) over  (partition by minion_id) t_cnt,
                 id                                         t_id,
                 name                                       t_name,
                 minion_id                                  t_minion_id
             from toy) t
              on m_id = t_minion_id) vt
     left outer join (
    select
        row_number() over (partition by minion_id) h_rn,
        count(*) over  (partition by minion_id) h_cnt,
        id                                         h_id,
        name                                       h_name,
        minion_id                                  h_minion_id
    from hobby) h
     on m_id = h_minion_id
where (t_rn = m_rn or t_rn is null or t_rn > m_cnt)
and (h_rn = greatest(m_rn, t_rn)   -- if they match we want them
   or greatest(m_cnt, t_cnt) < h_rn -- also if we have more hobbies then toys
   or h_rn is null)
order by root_id, rn;
