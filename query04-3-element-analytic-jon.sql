select * from (

	select
		greatest( j1.j1_toy_id, vp.toy_id) j2_toy_id,
		greatest( j1.j1_rn, vp.p_rn) j2_rn,
--		max(minion_id) over (partition by greatest( j1.j1_toy_id, vp.toy_id)) j2_minion_id,
		j1.*, vp.*
	from (
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
	) j1
	full outer join  (
		select *,
			row_number() over (partition by toy_id) p_rn
		from property
	) vp
	on j1.j1_toy_id = vp.toy_id
	and j1.j1_rn = vp.p_rn

) x order by 
-- j2_minion_id, 
j2_toy_id, j2_rn
