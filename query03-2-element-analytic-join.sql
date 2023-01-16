select * from (


select
	greatest(t.id, va.toy_id) j1_toy_id,
	greatest(1, va.a_rn) j1_rn,
	t.*, va.*
from toy t
full outer join (
	select *,
		row_number() over (partition by toy_id) a_rn
	from accessoire
) va
on t.id = va.toy_id
and 1 = va.a_rn

	
) x order by j1_toy_id, j1_rn