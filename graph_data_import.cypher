// =========================================
// CYPHER SCRIPT FOR GRAPH DATA IMPORT
// =========================================

// Load Employee Nodes
:auto LOAD CSV WITH HEADERS FROM 'file:///employees_cleaned.csv' AS row
WITH row
CALL {
    WITH row
    MERGE (n:Employee {employee_id: toInteger(trim(row.employee_id))})
    SET n.employee_name = row.employee_name,
        n.hire_date = CASE WHEN row.hire_date IS NOT NULL THEN datetime(row.hire_date) ELSE NULL END,
        n.target_ratio = toInteger(trim(row.target_ratio)),
        n.rate = toInteger(trim(row.rate)),
        n.status = row.status,
        n.termination_date = CASE WHEN row.termination_date IS NOT NULL THEN datetime(row.termination_date) ELSE NULL END,
        n.termination_reason = row.termination_reason,
        n.employee_type = row.employee_type,
        n.labour_category = row.labour_category,
        n.partner = toBoolean(row.partner)
} IN TRANSACTIONS OF 10000 ROWS;

// Load Branch Nodes
// Load Project Nodes
:auto LOAD CSV WITH HEADERS FROM 'file:///projects_cleaned.csv' AS row
WITH row
CALL {
    WITH row
    MERGE (p:Project {project_key: row.project_key})
    SET p.branch_id = row.branch_id,
        p.project_leader = row.project_leader,
        p.project_coordinator = row.project_coordinator,
        p.project_type = row.project_type,
        p.status = row.status,
        p.source = row.source
} IN TRANSACTIONS OF 10000 ROWS;

CALL apoc.periodic.iterate(
"LOAD CSV WITH HEADERS FROM 'file:///billing_cleaned.csv' AS row 
RETURN toInteger(row.employee_id) AS employee_id,
row.project_key AS project_key,
toFloat(row.regular_hours) AS hours,
CASE
WHEN row.transfer_date IS NOT NULL AND row.transfer_date <> ''
THEN datetime(replace(row.transfer_date, '/', '-'))
ELSE NULL
END AS transfer_date,
row.category AS category",
"
CREATE (t:Time {
employee_id: employee_id,
project_key: project_key,
hours: hours,
transfer_date: transfer_date,
category: category
})",
{batchSize: 10000, parallel: true}
);

// Create Relationships

// Branch HAS Project
:auto MATCH (b:Branch), (p:Project)
WHERE b.branch_id = p.branch_id
CALL {
    WITH b, p
    MERGE (b)-[:HAS]->(p)
} IN TRANSACTIONS OF 10000 ROWS;

// Employee IS COACHED BY Another Employee
:auto LOAD CSV WITH HEADERS FROM 'file:///employees_cleaned.csv' AS row
WITH DISTINCT row.coach AS distinct_coach, row.employee_name AS employee_name
CALL {
    WITH distinct_coach, employee_name
    MATCH (target:Employee {employee_name: distinct_coach})
    MATCH (source:Employee {employee_name: employee_name})
    MERGE (source)-[:IS_COACHED_BY]->(target)
} IN TRANSACTIONS OF 10000 ROWS;

// Employee BELONGS TO Branch
:auto LOAD CSV WITH HEADERS FROM 'file:///employees_cleaned.csv' AS row
WITH row
CALL {
    WITH row
    MATCH (source:Employee {employee_id: toInteger(trim(row.employee_id))})
    MATCH (target:Branch {branch_id: row.branch_id})
    MERGE (source)-[:`Belongs To`]->(target)
} IN TRANSACTIONS OF 10000 ROWS;

// BILLED_FOR Relationship (Limited to 10 relationships for efficiency)
:auto LOAD CSV WITH HEADERS FROM 'file:///billing_cleaned.csv' AS row
WITH row
LIMIT 10
CALL {
    WITH row
    MATCH (t:Time {employee_id: toInteger(trim(row.employee_id)), project_key: row.project_key})
    MATCH (p:Project {project_key: row.project_key})
    MERGE (t)-[:IS_BILLED_FOR]->(p)
} IN TRANSACTIONS OF 10 ROWS;

// CHARGES Relationship (Limited to 10 relationships for efficiency)
:auto LOAD CSV WITH HEADERS FROM 'file:///billing_cleaned.csv' AS row
WITH row
LIMIT 10
CALL {
    WITH row
    MATCH (e:Employee {employee_id: toInteger(trim(row.employee_id))})
    MATCH (t:Time {employee_id: toInteger(trim(row.employee_id)), project_key: row.project_key})
    MERGE (e)-[:CHARGES]->(t)
} IN TRANSACTIONS OF 10 ROWS;

// Due to the large size of this dataset, loading the CHARGES and IS_BILLED_FOR relationships takes a long time. 
// Therefore, only 10 relationships are created as an example. 
// This limit can be adjusted to showcase more relationships between nodes if needed.
