
// Neo4j Graph Database: Small-Scale Company

// Creating Employees, Departments, and Company Nodes
CREATE 
(alice:EMPLOYEE {name:"Alice Johnson", age: 35, position: "Software Engineer", salary: 95000}),
(bob:EMPLOYEE {name:"Bob Smith", age: 42, position: "Data Analyst", salary: 85000}),
(charlie:EMPLOYEE {name:"Charlie Davis", age: 29, position: "Software Engineer", salary: 92000}),
(diana:EMPLOYEE {name:"Diana Wilson", age: 38, position: "Project Manager", salary: 110000}),
(ethan:EMPLOYEE {name:"Ethan Brown", age: 50, position: "CTO", salary: 200000}),
(fiona:EMPLOYEE {name:"Fiona Adams", age: 45, position: "HR Manager", salary: 95000}),

(engineering:DEPARTMENT {name:"Engineering", budget: 5000000}),
(data:DEPARTMENT {name:"Data Science", budget: 3000000}),
(hr:DEPARTMENT {name:"Human Resources", budget: 1000000}),
(marketing:DEPARTMENT {name:"Marketing", budget: 2000000}),

(acme:COMPANY {name:"Acme Corp", industry: "Technology", founded: 2005});

// Creating Relationships
MATCH 
(alice:EMPLOYEE {name:"Alice Johnson"}), 
(charlie:EMPLOYEE {name:"Charlie Davis"}), 
(engineering:DEPARTMENT {name:"Engineering"}), 
(bob:EMPLOYEE {name:"Bob Smith"}), 
(data:DEPARTMENT {name:"Data Science"}), 
(diana:EMPLOYEE {name:"Diana Wilson"}), 
(fiona:EMPLOYEE {name:"Fiona Adams"}), 
(hr:DEPARTMENT {name:"Human Resources"}), 
(ethan:EMPLOYEE {name:"Ethan Brown"}), 
(acme:COMPANY {name:"Acme Corp"}), 
(marketing:DEPARTMENT {name:"Marketing"})
CREATE 
(alice)-[:WORKS_IN]->(engineering),
(charlie)-[:WORKS_IN]->(engineering),
(bob)-[:WORKS_IN]->(data),
(diana)-[:WORKS_IN]->(engineering),
(fiona)-[:WORKS_IN]->(hr),
(ethan)-[:WORKS_IN]->(acme),

(diana)-[:MANAGES]->(alice),
(diana)-[:MANAGES]->(charlie),
(ethan)-[:MANAGES]->(diana),
(ethan)-[:MANAGES]->(bob),
(ethan)-[:MANAGES]->(fiona),

(ethan)-[:OWNS]->(acme),
(engineering)-[:BELONGS_TO]->(acme),
(data)-[:BELONGS_TO]->(acme),
(hr)-[:BELONGS_TO]->(acme),
(marketing)-[:BELONGS_TO]->(acme);
