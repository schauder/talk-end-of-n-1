select *
from minion m
    join /*lateral*/ (
             select *
             from toy t
             where t.minion_id = m.id -- not a good example, but ...
        ) t2
on m.id = t2.minion_id