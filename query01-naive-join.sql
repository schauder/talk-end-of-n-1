select * 
from minion m
left join hobby h
on m.id = h.minion_id
left join toy t
on m.id = t.minion_id
left join accessoire a
on t.id = a.toy_id
left join property p
on t.id = p.toy_id;

-- insert into toy (minion_id, id, name) values(2,999, 'axt');