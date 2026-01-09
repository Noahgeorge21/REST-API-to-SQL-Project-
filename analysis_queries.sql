
--1. Status Mix - count studies by overall_status 
select 
	overall_status , 
	count(*) as status_count 
from studies 
group by overall_status; 

--2. Studies Over Time - count studies by start year 
select 
	strftime('%Y', start_date) as year, 
	count(nct_id) as studies_started 
from studies 
group by year;

--3. Enrollment Distribution - avg enrollment by overall_status or by intervention_type, includes size bins for interpretation of results
--q1
select 
	a.intervention_type,
	avg(b.enrollment_count),
	CASE
		when avg(b.enrollment_count) between 0 and 50 then 'Small'
		when avg(b.enrollment_count) between 50 and 200 then 'Medium'
		when avg(b.enrollment_count) between 200 and 1000 then 'Large'
		when avg(b.enrollment_count) > 1000 then 'Very Large'
		else NULL
	END as size
from study_interventions a 
join studies b on a.nct_id = b.nct_id
group by a.intervention_type;
--q2
select 
	overall_status,
	avg(enrollment_count),
	CASE
		when avg(enrollment_count) between 0 and 50 then 'Small'
		when avg(enrollment_count) between 50 and 200 then 'Medium'
		when avg(enrollment_count) between 200 and 1000 then 'Large'
		when avg(enrollment_count) > 1000 then 'Very Large'
		else NULL
	END as size
from studies 
group by overall_status;

--4. Top Conditions 
select 
	distinct condition, 
	count(distinct nct_id) as condition_count 
from study_conditions 
group by condition 
order by condition_count desc;

--5. Intervention Mix
select 
	distinct intervention_type, 
	count(distinct nct_id) as type_count 
from study_interventions 
group by intervention_type 
order by type_count desc; 

--6. County Distribution
select 
	distinct country, 
	count(distinct nct_id) as study_count 
from study_locations 
group by country 
order by study_count desc;

--7. Single vs Multi-Site distribution 
-- do multi-site studies focus on more conditions, have higher enrollment, are more likely to be published?
select 
	a.nct_id,
	case 
		when a.location_count = 1 then 'Single-Site'
		when a.location_count > 1 then 'Multi-Site' 
		else 'Unspecified' 
	end as single_vs_multi_site,
	a.condition_count,
	a.overall_status, 
	b.enrollment_count, 
	a.has_publication
from study_overview a
join studies b on a.nct_id = b.nct_id;

--8. % of studies with at least 1 PMID by overall_status
select 
	overall_status,
	AVG(CASE
		when has_publication = 'Yes' then 1 else 0
	end) as pct_with_pmid
from study_overview
group by overall_status;







