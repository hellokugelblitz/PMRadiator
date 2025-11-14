-- Keeps track of user information after google authentication...
-- User differs from resource in that all team members do not need access to the features of authentication
-- ...we want to encapsulate them as part of the project thats it.
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,

    google_uid VARCHAR(128) UNIQUE,
    email VARCHAR(255) UNIQUE NOT NULL,
    email_verified BOOLEAN DEFAULT FALSE,

    display_name VARCHAR(255),
    photo_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Resource related tables...
CREATE TABLE resources (
    resource_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NULL,
    name VARCHAR(255),
    role VARCHAR(255),
    department VARCHAR(255),
    email VARCHAR(255),
    phone_number VARCHAR(25),
    cost_rate FLOAT,
    percent_availability DECIMAL (5,2),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Holds information and relations for project encapsulation
CREATE TABLE projects (
    project_id INT PRIMARY KEY AUTO_INCREMENT,
    sponsor INT NULL,
    manager INT NULL,
    name VARCHAR(255),
    project_url TEXT,
    project_desc TEXT,
    planned_start_date DATE,
    planned_end_date DATE,
    actual_start_date DATE,
    actual_end_date DATE,
    baseline_start_date DATE,
    baseline_end_date DATE,
    phase ENUM('Initiation', 'Planning', 'Execution', 'Monitor & Control', 'Closure'),
    status ENUM('Green', 'Yellow', 'Red'),
    percent_complete DECIMAL(5,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (sponsor) REFERENCES resources(resource_id),
    FOREIGN KEY (manager) REFERENCES resources(resource_id)
);

-- Joining table between projects and resources
CREATE TABLE project_resources (
    project_id INT,
    resource_id INT,
    allocation_percent DECIMAL(5,2),
    FOREIGN KEY (project_id) REFERENCES projects(project_id),
    FOREIGN KEY (resource_id) REFERENCES resources(resource_id),
    PRIMARY KEY (project_id, resource_id) -- Composite primary key....
);

-- Joining table - Need to make a seperate table from the resource allocation table since users have special powers MUAHAHAHAHA
CREATE TABLE project_users (
    project_id INT,
    user_id INT,
    FOREIGN KEY (project_id) REFERENCES projects(project_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    PRIMARY KEY (project_id, user_id) -- Composite primary key....
);

-- Helper table
CREATE TABLE project_status_updates (
    metric_id INT PRIMARY KEY AUTO_INCREMENT,
    project_id INT NOT NULL,
    -- PMI Recommended Project KPIs
    pv DECIMAL(10,2), -- planned value
    ev DECIMAL(10,2), -- earned value
    ac DECIMAL(10,2),  -- actual spend
    bac DECIMAL(10,2), -- Budget
    eac DECIMAL(10,2), -- estimate at completion
    etc DECIMAL(10,2), -- estimate to completion
    vac DECIMAL(10,2), -- variance at completion
    spi DECIMAL(5,2), -- schedule performance index
    cpi DECIMAL(5,2), -- cost performance index
    report_date DATE NOT NULL,
    FOREIGN KEY (project_id) REFERENCES projects(project_id) ON DELETE CASCADE
);

-- Appear on project dashboard and countdown thingy...
CREATE TABLE milestones (
    milestone_id INT PRIMARY KEY AUTO_INCREMENT,
    project_id INT NOT NULL,
    name VARCHAR(255),
    planned_date DATE,
    actual_date DATE,
    status ENUM('Not Started', 'In Progress', 'Completed', 'Delayed'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(project_id) ON DELETE CASCADE
);

CREATE TABLE tasks (
    task_id INT PRIMARY KEY AUTO_INCREMENT,
    project_id INT NOT NULL,
    milestone_id INT NULL,
    resource_id INT NULL, -- can link to resource table with ID...
    dependency_task_id INT NULL, -- links to previous task
    name VARCHAR(255),
    task_desc TEXT,
    start_date DATE,
    end_date DATE,
    duration INT, -- in days
    completed_date DATE,
    percent_complete DECIMAL(5,2),
    wbs_code VARCHAR(25),
    status ENUM('Not Started', 'In Progress', 'Completed', 'Delayed'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(project_id) ON DELETE CASCADE,
    FOREIGN KEY (milestone_id) REFERENCES milestones(milestone_id),
    FOREIGN KEY (resource_id) REFERENCES resources(resource_id),
    FOREIGN KEY (dependency_task_id) REFERENCES tasks(task_id)
);

CREATE TABLE risks (
    risk_id INT PRIMARY KEY AUTO_INCREMENT,
    project_id INT NOT NULL,
    resource_id INT NULL,
    title VARCHAR(255),
    risk_desc TEXT,
    risk_mitigation VARCHAR(255),
    probability ENUM('Low', 'Medium', 'High'),
    impact ENUM('Low', 'Medium', 'High'),
    status ENUM('Open', 'Mitigated', 'Closed'),
    category ENUM('Internal', 'External', 'Technical', 'Operational'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(project_id) ON DELETE CASCADE,
    FOREIGN KEY (resource_id) REFERENCES resources(resource_id)
);

CREATE TABLE issues (
    issue_id INT PRIMARY KEY AUTO_INCREMENT,
    project_id INT NOT NULL,
    owner INT NULL,
    title VARCHAR(255),
    issue_desc TEXT,
    severity ENUM('Low', 'Medium', 'High'),
    status ENUM('Open', 'In Progress', 'Resolved', 'Closed'),
    category ENUM('Internal', 'External', 'Technical', 'Operational'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(project_id) ON DELETE CASCADE,
    FOREIGN KEY (owner) REFERENCES resources(resource_id)
);

CREATE TABLE stakeholders (
    stakeholder_id INT PRIMARY KEY AUTO_INCREMENT,
    project_id INT NOT NULL,
    resource_id INT NOT NULL,
    influence ENUM('Low','Medium','High'),
    engagement_level ENUM('Low','Medium','High'),
    FOREIGN KEY (project_id) REFERENCES projects(project_id) ON DELETE CASCADE,
    FOREIGN KEY (resource_id) REFERENCES resources(resource_id)
);

-- I need this too.. But this is boring haha
CREATE TABLE constraints (
    constraint_id INT PRIMARY KEY AUTO_INCREMENT,
    project_id INT,
    title VARCHAR(255),
    constraint_desc TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(project_id) ON DELETE CASCADE
);

-- Change related tables...
CREATE TABLE change_requests (
    change_id INT PRIMARY KEY AUTO_INCREMENT,
    project_id INT NOT NULL,
    requested_by INT NULL,
    approved_by INT NULL,
    title VARCHAR(255),
    change_desc TEXT,
    impact_cost DECIMAL(10,2),
    impact_time INT, -- This is in days
    impact_scope VARCHAR(255),
    status ENUM('Proposed', 'Approved', 'Rejected', 'Implemented'),
    decision_date DATE,
    implementation_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(project_id) ON DELETE CASCADE,
    FOREIGN KEY (requested_by) REFERENCES resources(resource_id),
    FOREIGN KEY (approved_by) REFERENCES resources(resource_id)
);

-- keeping this here incase it becomes useful
-- CREATE TABLE documents (
--    doc_id INT AUTO_INCREMENT PRIMARY KEY,
--    project_id INT,
--    uploaded_by INT,
--    file_path TEXT,
--    file_type VARCHAR(50),
--    created_at TIMESTAMP
-- )


