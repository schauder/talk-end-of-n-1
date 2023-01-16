select 
	greatest(m.id, vh.minion_id) j1_id,
	greatest(1, vh.h_rn) j1_rn,
	m.*, vh.* 
from minion m
full outer join (
	select *,
		row_number() over (partition by minion_id) h_rn
	from hobby
) vh
on m.id = vh.minion_id
and 1 = vh.h_rn