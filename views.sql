/*
OBJECTIVE: Denormalized Study View
METHODOLOGY: 
  - Flattens a one-to-many relational structure into a 1:1 "Study-Grain" view to optimize 
    BI tool performance and prevent row duplication.
  - Utilizes pre-aggregated subqueries (Common Table Expressions/Derived Tables) to count 
    related entities (Conditions, Interventions, Locations) prior to the primary join.
  - Implements COALESCE functions to handle NULLs from LEFT JOINs, ensuring numeric fields 
    are analysis-ready (0 instead of NULL).
  - Features a derived categorical flag (has_publication) for rapid segmentation.
OUTPUT: 
  - A comprehensive study overview containing core trial metadata and engagement metrics, 
    serving as the primary Fact Table for dashboarding.
*/
DROP VIEW IF EXISTS study_overview;
CREATE VIEW study_overview AS 
SELECT 
	a.nct_id,
	a.brief_title, 
	coalesce(b.condition_count, 0) as condition_count, 
	coalesce(c.intervention_count, 0) as intervention_count,
	coalesce(d.location_count, 0) as location_count,
	CASE WHEN coalesce(e.reference_count, 0) > 0 THEN 'Yes' ELSE 'No' END AS has_publication
FROM studies a
LEFT JOIN (
	SELECT 
	nct_id, 
	COUNT(*) AS condition_count
	FROM study_conditions 
	GROUP BY nct_id
) b 
	ON a.nct_id = b.nct_id
LEFT JOIN (
	SELECT
	nct_id, 
	COUNT(*) AS intervention_count
	FROM study_interventions
	GROUP BY nct_id
) c
	ON a.nct_id = c.nct_id
LEFT JOIN (
	SELECT
	nct_id, 
	COUNT(*) AS location_count
	FROM study_locations
	GROUP BY nct_id
) d
	ON a.nct_id = d.nct_id
LEFT JOIN (
	SELECT
	nct_id, 
	COUNT(*) AS reference_count
	FROM study_references
	GROUP BY nct_id
) e
	ON a.nct_id = e.nct_id;

	
	
/*
OBJECTIVE: Condition-Level Market Intelligence View
METHODOLOGY: 
  - Normalizes study-level data into a condition-centric granularity for categorical analysis.
  - Implements an 'Aggregated Boolean' logic via AVG(CASE...) to calculate completion rates 
    without the need for complex sub-selects or multiple passes.
  - Joins the 'studies' fact table with the 'conditions' dimension table to attribute enrollment metrics 
    across specific disease areas.
OUTPUT: 
  - A clean analytical dataset for Tableau/PowerBI to identify high-volume therapeutic areas, 
    average trial sizes, and success-to-failure ratios (pct_completed) per condition.
*/
DROP VIEW IF EXISTS condition_breakdown;
CREATE VIEW condition_breakdown as 
SELECT 
	a.condition, 
	COUNT(b.nct_id) AS num_studies, 
	AVG(b.enrollment_count) AS avg_enrollment, 
	AVG(CASE WHEN b.overall_status = 'Completed' THEN 1 ELSE 0 END) AS pct_completed
FROM study_conditions a 
JOIN studies b ON a.nct_id = b.nct_id
GROUP BY a.condition;



/*
OBJECTIVE: Intervention-Type Performance & Lifecycle Mix
METHODOLOGY: 
  - Aggregates trial metrics by Intervention Category to evaluate the scale and success 
    of various treatment modalities (e.g., Drug, Device, Behavioral).
  - Leverages pre-cleaned 'overall_status' buckets (Completed, Ongoing, Stopped) 
    to provide a streamlined lifecycle distribution.
  - Utilizes COUNT(DISTINCT) to ensure accurate study volume reporting in cases 
    where studies list multiple interventions within the same category.
OUTPUT: 
  - A summary table designed for stacked-bar visualizations and competitive 
    landscape analysis in Tableau.
*/
DROP VIEW IF EXISTS intervention_breakdown;
CREATE VIEW intervention_breakdown AS
SELECT 
	a.intervention_type,
	COUNT(DISTINCT a.nct_id) AS num_studies,
	AVG(b.enrollment_count) AS avg_enrollment, 
	COUNT(DISTINCT CASE WHEN b.overall_status = 'Completed' THEN a.nct_id END) AS completed_count, 
	COUNT(DISTINCT CASE WHEN b.overall_status = 'Ongoing' THEN a.nct_id END) AS ongoing_count, 
	COUNT(DISTINCT CASE WHEN b.overall_status = 'Stopped' THEN a.nct_id END) AS stopped_count,
	COUNT(DISTINCT CASE WHEN b.overall_status IS NULL THEN a.nct_id END) AS unknown_count
FROM study_interventions a
JOIN studies b ON a.nct_id = b.nct_id
GROUP BY a.intervention_type;



/*
OBJECTIVE: Geospatial Clinical Research Distribution View
METHODOLOGY: 
  - Aggregates trial data at the country level to identify global research hubs 
    and regional recruitment trends.
  - Addresses "Site-to-Study" duplication: Uses COUNT(DISTINCT) to ensure a 
    multi-site trial (e.g., a study with 50 locations in the USA) is counted 
    only once toward the country’s total volume.
  - Implements high-accuracy conditional aggregation to maintain mathematical 
    reconciliation between the 'num_studies' total and individual status buckets.
  - Prepares data for geospatial mapping (Chloropleth/Bubble maps) by providing 
    normalized enrollment averages and active trial density per region.
OUTPUT: 
  - A clean analytical dataset optimized for global map visualizations and 
    cross-border clinical trial capacity comparisons.
*/
DROP VIEW IF EXISTS geography_breakdown;
CREATE VIEW geography_breakdown AS
SELECT  
a.country, 
COUNT(DISTINCT a.nct_id) AS num_studies,
AVG(b.enrollment_count) AS avg_enrollment, 
COUNT(DISTINCT CASE WHEN b.overall_status = 'Completed' THEN a.nct_id END) AS completed_count, 
COUNT(DISTINCT CASE WHEN b.overall_status = 'Ongoing' THEN a.nct_id END) AS ongoing_count, 
COUNT(DISTINCT CASE WHEN b.overall_status = 'Stopped' THEN a.nct_id END) AS stopped_count,
COUNT(DISTINCT CASE WHEN b.overall_status IS NULL THEN a.nct_id END) AS unknown_count
FROM study_locations a 
JOIN studies b ON a.nct_id = b.nct_id
GROUP BY a.country;




		




