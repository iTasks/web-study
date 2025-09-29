import ballerina/io;

// Define data types for transformation examples
type Employee record {
    int id;
    string name;
    string department;
    decimal salary;
    string email;
    string[] skills;
};

type Department record {
    string name;
    int employeeCount;
    decimal totalSalary;
    decimal averageSalary;
    string[] skills;
};

type EmployeeReport record {
    string name;
    string department;
    string salaryRange;
    int skillCount;
    boolean isHighPerformer;
};

public function main() returns error? {
    io:println("=== Ballerina Data Transformation Demo ===\n");
    
    // Sample employee data
    Employee[] employees = [
        {
            id: 1,
            name: "Alice Johnson",
            department: "Engineering",
            salary: 95000.0,
            email: "alice.johnson@company.com",
            skills: ["Java", "Python", "SQL"]
        },
        {
            id: 2,
            name: "Bob Smith",
            department: "Engineering",
            salary: 87000.0,
            email: "bob.smith@company.com",
            skills: ["JavaScript", "React", "Node.js", "MongoDB"]
        },
        {
            id: 3,
            name: "Carol Brown",
            department: "Marketing",
            salary: 65000.0,
            email: "carol.brown@company.com",
            skills: ["SEO", "Content Marketing", "Analytics"]
        },
        {
            id: 4,
            name: "David Wilson",
            department: "Engineering",
            salary: 110000.0,
            email: "david.wilson@company.com",
            skills: ["Go", "Kubernetes", "Docker", "AWS", "Microservices"]
        },
        {
            id: 5,
            name: "Eva Davis",
            department: "Sales",
            salary: 78000.0,
            email: "eva.davis@company.com",
            skills: ["CRM", "Negotiation", "Lead Generation"]
        }
    ];
    
    // Example 1: Basic data filtering and mapping
    check basicTransformations(employees);
    
    // Example 2: Data aggregation and grouping
    check dataAggregation(employees);
    
    // Example 3: Complex transformations with nested data
    check complexTransformations(employees);
    
    // Example 4: JSON/XML data processing
    check jsonXmlProcessing();
    
    // Example 5: Stream processing
    check streamProcessing(employees);
}

// Basic data filtering and mapping
function basicTransformations(Employee[] employees) returns error? {
    io:println("1. Basic Data Transformations:");
    
    // Filter engineers with salary > 90K
    Employee[] highPaidEngineers = employees.filter(emp => 
        emp.department == "Engineering" && emp.salary > 90000.0
    );
    
    io:println("High-paid engineers:");
    foreach Employee emp in highPaidEngineers {
        io:println("  " + emp.name + " - $" + emp.salary.toString());
    }
    
    // Map to employee names only
    string[] allNames = employees.map(emp => emp.name);
    io:println("All employee names: " + allNames.toString());
    
    // Extract unique departments
    string[] departments = employees.map(emp => emp.department).distinct();
    io:println("Departments: " + departments.toString() + "\n");
}

// Data aggregation and grouping
function dataAggregation(Employee[] employees) returns error? {
    io:println("2. Data Aggregation:");
    
    // Group employees by department
    map<Employee[]> empsByDept = {};
    foreach Employee emp in employees {
        if !empsByDept.hasKey(emp.department) {
            empsByDept[emp.department] = [];
        }
        empsByDept[emp.department].push(emp);
    }
    
    // Create department summaries
    Department[] departments = [];
    foreach [string, Employee[]] [deptName, deptEmployees] in empsByDept.entries() {
        decimal totalSalary = deptEmployees.reduce(
            function(decimal acc, Employee emp) returns decimal => acc + emp.salary, 
            0.0
        );
        
        string[] allSkills = [];
        foreach Employee emp in deptEmployees {
            foreach string skill in emp.skills {
                if allSkills.indexOf(skill) == () {
                    allSkills.push(skill);
                }
            }
        }
        
        Department dept = {
            name: deptName,
            employeeCount: deptEmployees.length(),
            totalSalary: totalSalary,
            averageSalary: totalSalary / deptEmployees.length(),
            skills: allSkills
        };
        
        departments.push(dept);
    }
    
    // Display department summaries
    foreach Department dept in departments {
        io:println("Department: " + dept.name);
        io:println("  Employees: " + dept.employeeCount.toString());
        io:println("  Total Salary: $" + dept.totalSalary.toString());
        io:println("  Average Salary: $" + dept.averageSalary.toString());
        io:println("  Skills: " + dept.skills.toString());
    }
    io:println();
}

// Complex transformations with business logic
function complexTransformations(Employee[] employees) returns error? {
    io:println("3. Complex Transformations:");
    
    // Create employee reports with derived fields
    EmployeeReport[] reports = employees.map(function(Employee emp) returns EmployeeReport {
        string salaryRange;
        if emp.salary < 70000.0 {
            salaryRange = "Entry Level";
        } else if emp.salary < 90000.0 {
            salaryRange = "Mid Level";
        } else {
            salaryRange = "Senior Level";
        }
        
        boolean isHighPerformer = emp.skills.length() >= 4 && emp.salary > 85000.0;
        
        return {
            name: emp.name,
            department: emp.department,
            salaryRange: salaryRange,
            skillCount: emp.skills.length(),
            isHighPerformer: isHighPerformer
        };
    });
    
    io:println("Employee Reports:");
    foreach EmployeeReport report in reports {
        io:println("  " + report.name + " (" + report.department + ")");
        io:println("    Salary Range: " + report.salaryRange);
        io:println("    Skills: " + report.skillCount.toString());
        io:println("    High Performer: " + report.isHighPerformer.toString());
    }
    io:println();
}

// JSON and XML data processing
function jsonXmlProcessing() returns error? {
    io:println("4. JSON/XML Processing:");
    
    // Sample JSON data
    json customerData = {
        "customers": [
            {
                "id": 1,
                "name": "Tech Corp",
                "orders": [
                    {"id": 101, "amount": 1500.50, "status": "completed"},
                    {"id": 102, "amount": 2300.75, "status": "pending"}
                ]
            },
            {
                "id": 2,
                "name": "Innovate LLC",
                "orders": [
                    {"id": 103, "amount": 850.25, "status": "completed"}
                ]
            }
        ]
    };
    
    // Transform JSON data
    json customers = check customerData.customers;
    
    if customers is json[] {
        decimal totalRevenue = 0.0;
        int totalOrders = 0;
        
        foreach json customer in customers {
            string customerName = customer.name.toString();
            json orders = check customer.orders;
            
            if orders is json[] {
                decimal customerRevenue = 0.0;
                foreach json 'order in orders {
                    decimal amount = check 'order.amount;
                    customerRevenue += amount;
                    totalOrders += 1;
                }
                totalRevenue += customerRevenue;
                
                io:println("Customer: " + customerName + 
                          ", Revenue: $" + customerRevenue.toString() + 
                          ", Orders: " + orders.length().toString());
            }
        }
        
        io:println("Total Revenue: $" + totalRevenue.toString());
        io:println("Total Orders: " + totalOrders.toString());
    }
    
    // XML processing example
    xml salesData = xml `<sales>
        <quarter name="Q1">
            <month name="Jan" revenue="10000"/>
            <month name="Feb" revenue="12000"/>
            <month name="Mar" revenue="15000"/>
        </quarter>
        <quarter name="Q2">
            <month name="Apr" revenue="18000"/>
            <month name="May" revenue="22000"/>
            <month name="Jun" revenue="25000"/>
        </quarter>
    </sales>`;
    
    // Extract quarterly data
    foreach xml quarter in salesData.selectDescendants("{http://www.w3.org/1999/xhtml}quarter") {
        string quarterName = quarter.getAttributes()["name"].toString();
        decimal quarterTotal = 0.0;
        
        foreach xml month in quarter.selectDescendants("{http://www.w3.org/1999/xhtml}month") {
            decimal revenue = check decimal:fromString(month.getAttributes()["revenue"].toString());
            quarterTotal += revenue;
        }
        
        io:println("Quarter " + quarterName + " Total: $" + quarterTotal.toString());
    }
    io:println();
}

// Stream processing example
function streamProcessing(Employee[] employees) returns error? {
    io:println("5. Stream Processing:");
    
    // Create a stream from employees
    stream<Employee, error?> employeeStream = employees.toStream();
    
    // Process stream with pipeline operations
    decimal totalSalaryEngineering = check employeeStream
        .filter(emp => emp.department == "Engineering")
        .map(emp => emp.salary)
        .reduce(function(decimal acc, decimal salary) returns decimal => acc + salary, 0.0);
    
    io:println("Total Engineering Salaries: $" + totalSalaryEngineering.toString());
    
    // Count employees by skill
    map<int> skillCounts = {};
    stream<Employee, error?> skillStream = employees.toStream();
    
    check skillStream.forEach(function(Employee emp) {
        foreach string skill in emp.skills {
            if skillCounts.hasKey(skill) {
                skillCounts[skill] = skillCounts[skill] + 1;
            } else {
                skillCounts[skill] = 1;
            }
        }
    });
    
    io:println("Skill counts:");
    foreach [string, int] [skill, count] in skillCounts.entries() {
        io:println("  " + skill + ": " + count.toString());
    }
    
    io:println("\nData transformation demo completed!");
}