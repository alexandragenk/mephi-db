-- 4.1

WITH RECURSIVE tempSubordinates AS (
    SELECT 
        EmployeeID, 
        Name, 
        ManagerID, 
        DepartmentID, 
        RoleID
    FROM 
        Employees
    WHERE 
        ManagerID = 1  
    UNION ALL
    SELECT 
        emp.EmployeeID, 
        emp.Name, 
        emp.ManagerID, 
        emp.DepartmentID, 
        emp.RoleID
    FROM 
        Employees emp
    INNER JOIN 
        tempSubordinates sub ON emp.ManagerID = sub.EmployeeID
)
SELECT 
    sub.EmployeeID,
    sub.Name,
    sub.ManagerID,
    COALESCE(dep.DepartmentName, 'NULL') AS Department, 
    COALESCE(role.RoleName, 'NULL') AS Role,              
    COALESCE((
        SELECT STRING_AGG(proj.ProjectName, ', ') 
        FROM Projects proj 
        WHERE proj.DepartmentID = sub.DepartmentID
    ), 'NULL') AS Projects,                             
    COALESCE((
        SELECT STRING_AGG(task.TaskName, ', ') 
        FROM Tasks task 
        WHERE task.AssignedTo = sub.EmployeeID
    ), 'NULL') AS Tasks                                
FROM 
    tempSubordinates sub
LEFT JOIN 
    Departments dep ON sub.DepartmentID = dep.DepartmentID
LEFT JOIN 
    Roles role ON sub.RoleID = role.RoleID
ORDER BY 
    sub.Name;

-- 4.2

WITH RECURSIVE tempSubordinates AS (
    SELECT 
        EmployeeID,
        Name as EmployeeName,
        ManagerID,
        DepartmentID,
        RoleID
    FROM Employees
    WHERE ManagerID = 1
    
    UNION ALL
    
    SELECT 
        emp.EmployeeID,
        emp.Name,
        emp.ManagerID,
        emp.DepartmentID,
        emp.RoleID
    FROM Employees emp
    INNER JOIN tempSubordinates sub
        ON emp.ManagerID = sub.EmployeeID
)
SELECT
    sub.EmployeeID,
    sub.EmployeeName,
    sub.ManagerID,
    dep.DepartmentName,
    role.RoleName,
    COALESCE(
        (SELECT STRING_AGG(proj.ProjectName, ', ') 
         FROM Projects proj 
         WHERE proj.DepartmentID = sub.DepartmentID),
        'NULL'
    ) AS ProjectNames,
    COALESCE(
        (SELECT STRING_AGG(task.TaskName, ', ') 
         FROM Tasks task
         WHERE task.AssignedTo = sub.EmployeeID),
        'NULL'
    ) AS TaskNames,
    (SELECT COUNT(*) 
     FROM Tasks task 
     WHERE task.AssignedTo = sub.EmployeeID) AS TotalTasks,
    
    (SELECT COUNT(*) 
     FROM Employees emp 
     WHERE emp.ManagerID = sub.EmployeeID) AS TotalSubordinates
FROM tempSubordinates sub
LEFT JOIN Departments dep 
    ON sub.DepartmentID = dep.DepartmentID
LEFT JOIN Roles role 
    ON sub.RoleID = role.RoleID
ORDER BY sub.EmployeeName;

-- 4.3

WITH RECURSIVE tempManagerHierarchy AS (
    SELECT 
        emp.EmployeeID,
        emp.Name,
        emp.ManagerID,
        emp.DepartmentID,
        emp.RoleID,
        emp.EmployeeID AS RootManagerID
    FROM 
        Employees emp
    INNER JOIN 
        Roles r ON emp.RoleID = r.RoleID
    WHERE 
        r.RoleName = 'Менеджер'
        AND EXISTS (
            SELECT 1 
            FROM Employees sub 
            WHERE sub.ManagerID = emp.EmployeeID
        )
    
    UNION ALL
    
    SELECT 
        sub.EmployeeID,
        sub.Name,
        sub.ManagerID,
        sub.DepartmentID,
        sub.RoleID,
        mh.RootManagerID
    FROM 
        Employees sub
    INNER JOIN 
        tempManagerHierarchy mh 
        ON sub.ManagerID = mh.EmployeeID
)
SELECT 
    m.RootManagerID AS EmployeeID,
    emp.Name AS EmployeeName,
    emp.ManagerID,
    dep.DepartmentName,
    role.RoleName,
    (SELECT STRING_AGG(proj.ProjectName, ', ') 
     FROM Projects proj
     WHERE proj.DepartmentID = emp.DepartmentID) AS ProjectNames,
    (SELECT STRING_AGG(task.TaskName, ', ') 
     FROM Tasks task
     WHERE task.AssignedTo = emp.EmployeeID) AS TaskNames,
    (SELECT COUNT(*) - 1 
     FROM tempManagerHierarchy mh_count 
     WHERE mh_count.RootManagerID = emp.EmployeeID) AS TotalSubordinates
FROM 
    (SELECT DISTINCT RootManagerID FROM tempManagerHierarchy) m
INNER JOIN 
    Employees emp 
    ON m.RootManagerID = emp.EmployeeID
LEFT JOIN 
    Departments dep
    ON emp.DepartmentID = dep.DepartmentID
LEFT JOIN 
    Roles role
    ON emp.RoleID = role.RoleID
WHERE 
    role.RoleName = 'Менеджер'  
ORDER BY 
    emp.Name;