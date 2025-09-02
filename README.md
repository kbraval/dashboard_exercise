# CPU Project Dashboard Exercise

## Why Dashboarding Matters

Project dashboards are powerful tools for both project managers and developers:

- **High-Level Overview:** Dashboards provide project managers with a quick, visual summary of the status of all units, helping them track progress, spot bottlenecks, and prioritize resources.
- **Collaboration & Debugging:** Developers can use dashboards to identify failing tests, open bugs, and sign-off status, making it easier to coordinate debugging efforts and share information about issues between team members.
- **Transparency:** Everyone on the team can see the current health of the project, which improves communication and accountability.
- **Historical Tracking:** By visualizing status changes over time, teams can analyze trends, understand the impact of changes, and make data-driven decisions.


In this exercise, you'll build a dashboard that brings these benefits to a hypothetical CPU project, using example data and SQL queries.

Try to complete as many tasks as you can—there is no failure! Every step you take will help you learn and demonstrate your skills, so feel free to experiment and explore.

## Database Structure Overview

The project uses a SQLite database (`data.db`) with several tables to model the CPU project and its status. Understanding the schema will help you query the right data for your dashboard:

- **unit_rtl**: Each row represents a hardware unit (e.g., ALU, FPU) with its RTL path and the commit where it was introduced.
- **project_dashboard**: Maps each unit to a human-readable name and links to `unit_rtl` via `unit_id`.
- **unit_tests**: Stores test results for each unit (`status`: pass/fail), linked to `unit_rtl`.
- **unit_test_names**: Details individual test cases for each test run, including their status and name.
- **test_runs**: Tracks each test run for a unit at a specific commit, with timestamps, status, and log URLs.
- **signoff_runs**: Records sign-off attempts for each unit at each commit, with status and logs.
- **bugs**: Lists bugs found during test runs, including their status (opened, assigned, closed, not-a-bug) and details.

**Relationships:**
- Units are defined in `unit_rtl` and referenced throughout other tables.
- Test and signoff runs are linked to units and commits, allowing you to track status over time.
- Bugs are tied to specific test runs, so you can show open issues per unit.

**How to Use This Structure:**
- For the dashboard, join `project_dashboard`, `unit_rtl`, and `test_runs` to show each unit's latest test and signoff status.
- For drill-downs, use `bugs` and `unit_test_names` to show open bugs and failing tests for a unit.
- For visualizations, use `test_runs` and `signoff_runs` to plot status changes across commits.

Refer to `schema.sql` for full details and example data.


## Setup Instructions


### 1. Generate the SQLite Database

Before you start coding, you need to create the SQLite database (`data.db`) from the provided schema and sample data.

**Steps:**
1. Run the following command in your project directory (SQLite is already installed on your system):
  ```sh
  sqlite3 data.db < schema.sql
  ```
  This will create `data.db` with all tables and sample data.

### 2. (Recommended) Install SQLite Viewer Extension

To easily explore and navigate the `data.db` database file, install the **SQLite Viewer** extension in VS Code:

1. Open the Extensions sidebar (`Cmd+Shift+X` on macOS).
2. Search for `SQLite Viewer` and install it (by Florian Klampfer).
3. After installation, you can open and browse `data.db` directly in VS Code, inspect tables, and run queries interactively.

This will help you understand the schema and debug your SQL queries as you build your dashboard.

## Your Tasks

### Task 1: Explore Table Relationships
Before building your dashboard, start by exploring how the tables relate to each other. Use these example SQL queries to get familiar with the schema and basic joins:

Open the terminal from Visual Studio Code and do:
```sh
sqlite3 data.db
```
To open the sqlite3 console.

The following command makes the outputs prettier:
```bash
.mode table
```
You can try the following queries:

**List all units:**
```sql
SELECT * FROM project_dashboard;
```

**List tests run on a specific commit:**
```sql
SELECT * FROM test_runs
WHERE git_commit = "cmt_004";
```

**Show all test runs for each unit:**
```sql
SELECT pd.unit_name, tr.git_commit, tr.status
FROM project_dashboard pd
JOIN unit_rtl ur ON pd.unit_id = ur.id
JOIN test_runs tr ON ur.id = tr.unit_rtl_id;
```

**Find open bugs for each unit:**
```sql
SELECT pd.unit_name, b.details, b.status
FROM project_dashboard pd
JOIN unit_rtl ur ON pd.unit_id = ur.id
JOIN test_runs tr ON ur.id = tr.unit_rtl_id
JOIN bugs b ON tr.id = b.test_run_id
WHERE b.status IN ('opened', 'assigned');
```

**Show signoff status for each unit:**
```sql
SELECT pd.unit_name, sr.git_commit, sr.status
FROM project_dashboard pd
JOIN unit_rtl ur ON pd.unit_id = ur.id
JOIN signoff_runs sr ON ur.id = sr.unit_rtl_id;
```
Try modifying these queries to understand the relationships.

### Task 2: Project Status Dashboard
- Create a Node.js application that connects to `data.db`.
- On the main page, display a table listing all units in the project.
- For each unit, show:
  - Unit name
  - Pass/fail status for its tests (from the view)
  - Sign-off status (from the view)

### Task 3: Drill-down Details
- Allow the user to click on a unit or status to view more details:
  - List of open bugs for the unit
  - Details of failing tests (if any)
  - Sign-off status and history

### Task 4: Status Visualisation
- If you have time, add a chart or graph to show how the test status for a unit changes over time (across commits).

### Task 5: Git
- Git does not have serial-looking commits. The commit IDs are random-looking strings like 'c0cbf9eca98576b63bb` and they can't be compared to get an order.
    - How would you deal with this?

## Tips
- Use the `sqlite3` Node.js package or any SQLite library you prefer.
- You can use any web framework (Express, etc.) or just plain Node.js and HTML.
- Focus on clear, readable code and a simple, user-friendly interface.

## Good Luck!
Have fun, and don't hesitate to experiment with SQL and Node.js to build your dashboard!
