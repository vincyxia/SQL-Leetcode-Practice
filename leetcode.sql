USE leetcode;

-- 1.176.Second highest salary
SELECT * FROM Employee;
SELECT
	IFNULL(
		(SELECT DISTINCT Salary 
		FROM Employee
		ORDER BY 1 DESC
		LIMIT 1, 1), NULL) AS SecondHighestSalary;

-- 2.175. Combine two tables
SELECT * FROM Address;
SELECT * FROM Person;
SELECT FirstName, LastName, City, State
FROM Person p
LEFT JOIN Address a ON p.PersonId = a.PersonId;

-- 3.177. Nth highest salary
DELIMITER //
CREATE FUNCTION getNthhighestsalary(N INT) 
RETURNS INT
READS SQL DATA -- add this 
DETERMINISTIC  -- add this 
BEGIN
		DECLARE M INT;
		SET M = N - 1;
	RETURN
	(SELECT
		IFNULL(
			(SELECT DISTINCT Salary
			FROM Employee
			ORDER BY 1 DESC
			LIMIT 1, M), NULL) AS getNthHighestSalary);
END //
DELIMITER ;
SELECT getNthhighestsalary(1);

-- 4.178. Rank scores
SELECT * FROM Scores;
-- solution 1
SELECT Score,
		DENSE_RANK() OVER(ORDER BY Score DESC) AS 'Rank'
FROM Scores;
-- solution 2
SELECT
  Score,
  (SELECT COUNT(DISTINCT Score) FROM Scores WHERE Score >= s.Score) 'Rank'
FROM Scores s
ORDER BY Score DESC;

-- 5.181. Employees earning more than their managers
SELECT * FROM Employee_181;
SELECT e.Name AS Employee
FROM Employee_181 e
LEFT JOIN Employee_181 m ON e.ManagerId = m.Id
WHERE e.Salary > m.Salary;

-- 6.262. Trips and users
SELECT * FROM trips;
SELECT * FROM users;

-- solution 1
SELECT DISTINCT Day,
		AVG(cancel_status) OVER(PARTITION BY Day) AS 'Cancellation Rate'
FROM
	(SELECT Request_at AS 'Day',
			CASE WHEN Status != 'completed' THEN 1 ELSE 0 END AS 'cancel_status'
	FROM trips
	WHERE Client_Id NOT IN (SELECT Users_Id FROM users WHERE Banned = 'Yes') AND
		Driver_Id NOT IN (SELECT Users_Id FROM users WHERE Banned = 'Yes')) T1
WHERE Day BETWEEN '2013-10-01' AND '2013-10-03';

-- solution 2
SELECT 
    Day,
    ROUND(completed/total,2) AS 'Cancellation Rate'
FROM (
    SELECT
        Request_at AS Day,
        SUM(CASE WHEN Status LIKE "cancelled%" THEN 1 ELSE 0 END) AS completed,
        COUNT(Id) AS total
    FROM Trips
    WHERE Client_Id IN (SELECT Users_Id FROM Users WHERE Banned = "No")
        AND Driver_Id IN (SELECT Users_Id FROM Users WHERE Banned = "No")
        AND Request_at BETWEEN '2013-10-01' AND '2013-10-03'
    GROUP BY 1) t2;
					
-- 7.184. Department highest salary
SELECT * FROM employee_184;
SELECT * FROM department;
SELECT Department,
		Employee,
        Salary
FROM
	(SELECT d.Name AS Department,
			e.Name AS Employee,
			e.Salary,
			RANK() OVER(PARTITION BY d.Name ORDER BY e.Salary DESC) AS rk
	FROM employee_184 e 
	INNER JOIN department d ON e.DepartmentId = d.Id) t1
WHERE rk = 1;

-- 8.180. Consecutive numbers
SELECT * FROM logs;
-- solution 1
SELECT DISTINCT
    l1.Num AS ConsecutiveNums
FROM
    Logs l1,
    Logs l2,
    Logs l3
WHERE
    l1.Id = l2.Id - 1
    AND l2.Id = l3.Id - 1
    AND l1.Num = l2.Num
    AND l2.Num = l3.Num;
-- solution 2
SELECT DISTINCT Num
FROM
	(
	SELECT Num,
		LEAD(num) OVER(ORDER BY id) AS leads, 
		LAG(num) OVER (ORDER BY id) AS lags
	FROM logs
	)t
WHERE Num = leads and Num = lags;

-- 9.185. Department top three salaries
SELECT * FROM employee_185;
SELECT Department,
		Employee,
        Salary
FROM
	(SELECT d.Name AS Department,
			e.Name AS Employee,
			e.Salary,
			DENSE_RANK() OVER(PARTITION BY d.Name ORDER BY e.Salary DESC) AS rk
	FROM employee_185 e 
	INNER JOIN department d ON e.DepartmentId = d.Id) t1
WHERE rk IN (1,2,3);

-- 10.1212. Team scores in football tournament
SELECT * FROM teams;
SELECT * FROM matches;

-- solution 1
SELECT team_id,
		team_name,
        IFNULL(SUM(CASE
						WHEN team_id = host_team AND host_goals > guest_goals THEN 3
						WHEN team_id = guest_team AND host_goals > guest_goals THEN 0
						WHEN team_id = host_team AND host_goals < guest_goals THEN 0
						WHEN team_id = guest_team AND host_goals < guest_goals THEN 3
						WHEN host_goals = guest_goals THEN 1
					END), 0) AS num_points
FROM teams t
	LEFT JOIN matches m
			ON t.team_id = m.host_team OR t.team_id = m.guest_team
GROUP BY 1,2
ORDER BY 3 DESC, 1;

SELECT *
FROM teams t
	LEFT JOIN matches m
			ON t.team_id = m.host_team OR t.team_id = m.guest_team;

-- solution 2
SELECT
    t.team_id,
    t.team_name,
    IFNULL(SUM(CASE WHEN t1.self_goals > t1.other_goals THEN 3
             WHEN t1.self_goals = t1.other_goals THEN 1
        ELSE 0
       END), 0) AS num_points
FROM Teams t
LEFT JOIN (
    SELECT
        host_team AS team,
        host_goals AS self_goals,
        guest_goals AS other_goals
    FROM Matches
    UNION ALL
    SELECT 
        guest_team AS team,
        guest_goals AS self_goals,
        host_goals AS other_goals
    FROM Matches) t1
    ON t.team_id = t1.team
GROUP BY 1, 2
ORDER BY 3 DESC, 1;

-- 11.183. Customers who never order
SELECT * FROM customers;
SELECT * FROM orders;
SELECT Name AS Customers
FROM customers
WHERE Id NOT IN
	(SELECT DISTINCT CustomerId FROM orders);

-- 12.626. Exchange seats
SELECT * FROM seat;
SELECT id,
		CASE
			WHEN id % 2 <> 0 THEN IFNULL(leads,student)
            ELSE lags
		END AS student
FROM(
		SELECT *,
				LAG(student,1) OVER(ORDER BY id) AS lags,
				LEAD(student, 1) OVER(ORDER BY id) AS leads
		FROM seat) t1;

-- 13.1179. Reformat department table
SELECT * FROM department_1179;
SELECT id,
		SUM(CASE WHEN month = 'Jan' THEN revenue ELSE null END) AS Jan_Revenue, 
		SUM(CASE WHEN month = 'Feb' THEN revenue ELSE null END) AS Feb_Revenue,
        SUM(CASE WHEN month = 'Mar' THEN revenue ELSE null END) AS Mar_Revenue,
        SUM(CASE WHEN month = 'Apr' THEN revenue ELSE null END) AS Apr_Revenue,
        SUM(CASE WHEN month = 'May' THEN revenue ELSE null END) AS May_Revenue,
        SUM(CASE WHEN month = 'Jun' THEN revenue ELSE null END) AS Jun_Revenue,
        SUM(CASE WHEN month = 'Jul' THEN revenue ELSE null END) AS Jul_Revenue,
        SUM(CASE WHEN month = 'Aug' THEN revenue ELSE null END) AS Aug_Revenue,
        SUM(CASE WHEN month = 'Sep' THEN revenue ELSE null END) AS Sep_Revenue,
        SUM(CASE WHEN month = 'Oct' THEN revenue ELSE null END) AS Oct_Revenue,
        SUM(CASE WHEN month = 'Nov' THEN revenue ELSE null END) AS Nov_Revenue,
        SUM(CASE WHEN month = 'Dec' THEN revenue ELSE null END) AS Dec_Revenue
FROM department_1179
GROUP BY id;

######################################################################################
SET @sql = NULL;
SELECT
	GROUP_CONCAT( DISTINCT
		CONCAT(
			'SUM(CASE WHEN month = ''',
            mt,
            '''THEN revenue ELSE 0 END) AS `',
            mt,
            '`'
        )
	) INTO @sql
FROM 
	(
    SELECT month AS mt FROM department_1179
    ) t1;

SET @sql = 
	CONCAT(
		'SELECT id, ',
        @sql,
        'FROM department_1179
        GROUP BY id
        ORDER BY id'
        );
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
######################################################################################

-- 14.1241.Number of comments per post
SELECT * FROM submissions;
SELECT
    S1.sub_id AS post_id,
    COUNT(DISTINCT S2.sub_id) AS number_of_comments
FROM
    Submissions S1
LEFT JOIN
    Submissions S2
ON
    S1.sub_id = S2.parent_id
WHERE S1.parent_id IS NULL
GROUP BY S1.sub_id;

-- 15.608.Tree node
SELECT * FROM tree;
SELECT DISTINCT id,
		CASE WHEN p IS NULL THEN 'Root'
			 WHEN c IS NULL THEN 'Leaf'
             ELSE 'Inner'
		END AS 'Type'
FROM
	(SELECT t1.id AS id, t1.p_id AS p, t2.id AS c
	FROM tree t1
	LEFT JOIN tree t2 ON t1.id = t2.p_id) t;
    
-- 16.1204. Last person to fit in the elevator
SELECT * FROM queue
ORDER BY turn;
SELECT person_name
FROM
	(SELECT *,
			SUM(weight) OVER(ORDER BY turn) AS CUMSUM
	FROM queue) t1
WHERE CUMSUM <= 1000
ORDER BY CUMSUM DESC
LIMIT 1;

-- 17.1270. All people report to the given manager
SELECT * FROM Employees_1270; 
WITH RECURSIVE a AS (
SELECT
    1 AS employee_id,
    1 AS lvl
UNION ALL
SELECT
    e.employee_id,
    lvl + 1 AS lvl
FROM employees_1270 e
INNER JOIN a
    ON a.employee_id = e.manager_id
WHERE lvl + 1 <= 4
)
SELECT DISTINCT employee_id
FROM a
WHERE employee_id <> 1;

-- 18.601. Human traffic to stadium
SELECT * FROM stadium; 
SELECT DISTINCT t1.*
FROM
    stadium t1,
    stadium t2,
    stadium t3
WHERE
    t1.people >= 100 AND t2.people >= 100 AND t3.people >= 100
        AND ((t1.id - t2.id = 1 AND t1.id - t3.id = 2
        AND t2.id - t3.id = 1)
        OR (t2.id - t1.id = 1 AND t2.id - t3.id = 2
        AND t1.id - t3.id = 1)
        OR (t3.id - t2.id = 1 AND t2.id - t1.id = 1
        AND t3.id - t1.id = 2))
ORDER BY t1.id;

-- 19.1341. Movie rating
SELECT * FROM movies;
SELECT * FROM users_1341;
SELECT * FROM movie_rating;
SELECT name AS results
FROM
	(SELECT 
        name, 
        COUNT(movie_id) AS ct
	FROM movie_rating m
	LEFT JOIN users u 
        ON m.user_id = u.user_id
	GROUP BY name
	ORDER BY ct DESC, name
	LIMIT 1) t1
UNION ALL
SELECT title AS results
FROM
	(SELECT 
        title, 
        DATE_FORMAT(created_at, '%Y-%m') AS dt,
        AVG(rating) AS avg_rating
    FROM movie_rating mr
	LEFT JOIN movies m 
        ON m.movie_id = mr.movie_id
	GROUP BY dt, title
    HAVING dt = '2020-02'
    ORDER BY avg_rating DESC, title
    LIMIT 1) t2;

-- 20.618. Students report by geography
SELECT * FROM student;
SELECT MAX(America) as America, MAX(Asia) as Asia, MAX(Europe) as Europe
FROM 
	(SELECT ID,  
			CASE WHEN continent = 'America' THEN name END as America,
			CASE WHEN continent = 'Asia' THEN name END as Asia,
			CASE WHEN continent = 'Europe' THEN name END as Europe
	FROM 
		(SELECT ROW_NUMBER() OVER (PARTITION BY continent ORDER BY name) AS ID, name ,continent
		FROM student) tmp) a
GROUP BY ID;

-- 21.1126. Active businesses
SELECT * FROM events;

-- solution 1
SELECT business_id
FROM
	(SELECT e.*, avg_occur
	FROM events e
	INNER JOIN
			(SELECT event_type,
					AVG(occurences) AS avg_occur
			FROM events
			GROUP BY event_type) t1
				ON t1.event_type = e.event_type) t2
WHERE occurences > avg_occur
GROUP BY 1
HAVING COUNT(DISTINCT event_type) > 1;

-- solution 2
SELECT DISTINCT business_id
FROM (
    SELECT 
        *,
        AVG(occurences) OVER(PARTITION BY event_type) AS avg_event
    FROM Events) t1
GROUP BY 1
HAVING SUM(CASE WHEN occurences > avg_event THEN 1 ELSE 0 END) > 1;

-- 22.614. Second degree follower
SELECT * FROM follow;
SELECT followee AS follower,
		COUNT(DISTINCT follower) AS num
FROM 
	(SELECT f1.follower AS followee, f2.follower AS follower 
	FROM follow f1
	INNER JOIN follow f2 ON f1.follower = f2.followee) t1
GROUP BY 1;

-- 23.610. Triangle judgement
SELECT * FROM triangle;
SELECT *,
		CASE WHEN x+y>z AND x+z>y AND y+z>x THEN 'Yes'
        ELSE 'No'
        END AS triangle
FROM triangle;

-- 24.602. Friend requests: who has the most friends
SELECT * FROM request_accepted;
SELECT a AS id,
		COUNT(b) AS num
FROM
	(SELECT requester_id AS a,
			accepter_id AS b
	FROM request_accepted
	UNION ALL
	SELECT accepter_id AS a,
			requester_id AS b
	FROM request_accepted) t1
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- 25.584. Find customer referee
SELECT * FROM customer_584;
SELECT name
FROM customer_584
WHERE referee_id <> 2 OR referee_id IS NULL;

-- 26.197. Rising temperature
SELECT * FROM weather;
-- solution 1
SELECT DISTINCT w1.id
FROM Weather w1
CROSS JOIN Weather w2
WHERE DATEDIFF(w1.recordDate, w2.recordDate) = 1
    AND
      w1.Temperature > w2.Temperature;
-- solution 2
SELECT
    weather.Id AS 'Id'
FROM
    weather
        JOIN
    weather w ON DATEDIFF(weather.RecordDate, w.RecordDate) = 1
        AND weather.Temperature > w.Temperature;

-- 27.579. Find cumulative salary of an employee
SELECT * FROM employee_579;
SELECT * FROM employee_579
ORDER BY Id;
SELECT 
    Id,
    Month,
    Salary
FROM (
    SELECT 
        Id,
        Month,
        SUM(Salary) OVER(PARTITION BY Id ORDER BY Month ROWS BETWEEN 2 PRECEDING AND 0 FOLLOWING) AS Salary,
        ROW_NUMBER() OVER(PARTITION BY Id ORDER BY Month DESC) as row_n
    FROM employee_579) t1
WHERE row_n <> 1
ORDER BY 1, 2 DESC;

-- 28.1336. Number of transactions per visit
SELECT * FROM Visits;
SELECT * FROM transactions;
WITH RECURSIVE a AS (
    SELECT 0 AS num
    UNION ALL
    SELECT num + 1 AS num
    FROM a
    WHERE num + 1 <= 
        (SELECT COUNT(*) FROM Transactions 
         GROUP BY user_id, transaction_date
        ORDER BY COUNT(*) DESC
        LIMIT 1)
)
SELECT 
    a.num AS transactions_count,
    COUNT(t2.transactions_count) AS visits_count
FROM a
LEFT JOIN (
    SELECT
        user_id,
        visit_date,
        COUNT(amount) AS transactions_count
    FROM (
        SELECT 
            v.user_id,
            v.visit_date,
            t.amount
        FROM Visits v
        LEFT JOIN Transactions t
            ON v.user_id = t.user_id AND v.visit_date = t.transaction_date) t1
    GROUP BY user_id, visit_date) t2

    ON t2.transactions_count = a.num
GROUP BY a.num
ORDER BY transactions_count;

-- 29.1159. Market analysis
SELECT * FROM Users_1159;
SELECT * FROM Orders_1159;
SELECT * FROM Items_1159;
SELECT
    DISTINCT u1.user_id AS seller_id,
    IFNULL(t2.matches, 'no') AS 2nd_item_fav_brand
FROM Users u1
LEFT JOIN
(
    SELECT
        seller_id,
        CASE WHEN item = fav THEN 'yes' ELSE 'no' END AS matches
    FROM (
        SELECT o.order_date,
            i.item_brand AS item,
            o.seller_id,
            u.favorite_brand AS fav,
            ROW_NUMBER() OVER(PARTITION BY o.seller_id ORDER BY o.order_date) AS rn
        FROM Orders o
        INNER JOIN Items i ON o.item_id = i.item_id
        INNER JOIN Users u ON u.user_id = o.seller_id ) t1
    WHERE rn = 2) t2
    ON u1.user_id = t2.seller_id;

-- 30.597. Friend requests: overall acceptance rate
SELECT * FROM friend_request_597;
SELECT * FROM request_accepted_597;
SELECT 
ROUND(
	IFNULL(
		(SELECT COUNT(DISTINCT CONCAT(requester_id,accepter_id)) FROM request_accepted_597) 
		/
		(SELECT COUNT(DISTINCT CONCAT(sender_id,send_to_id)) FROM friend_request_597),
		0),
	2) AS accept_rate;


-- 31.1225. Report contiguous dates
SELECT * FROM failed;
SELECT * FROM succeeded;
WITH a AS (
SELECT 
    DISTINCT fail_date AS dt,
    'failed' AS period_state
FROM failed
WHERE YEAR(fail_date) = '2019'
UNION ALL
SELECT
    DISTINCT success_date AS dt,
    'succeeded' AS period_state
FROM succeeded
WHERE YEAR(success_date) = '2019'
),

b AS (
SELECT 
    *,
    ROW_NUMBER() OVER(PARTITION BY period_state ORDER BY dt) AS rn
FROM a
),

c AS (
SELECT
    *,
    DATE_SUB(dt, INTERVAL rn DAY) AS rn_tag
FROM b
)
SELECT
    period_state,
    MIN(dt) AS start_date,
    MAX(dt) AS end_date
FROM c
GROUP BY rn_tag, period_state
ORDER BY start_date;

-- 32.569. Median employee salary
SELECT * FROM employee_569;
SELECT Id,
		Company,
        Salary
FROM (
	SELECT *,
			ROW_NUMBER() OVER(PARTITION BY Company ORDER BY Salary, Id) AS 'row_asc',
			ROW_NUMBER() OVER(PARTITION BY Company ORDER BY Salary DESC, Id DESC) AS 'row_desc'
	FROM employee_569) t1
WHERE row_asc BETWEEN row_desc - 1 AND row_desc + 1
ORDER BY 2,3;

-- 33.182. Duplicate emails
SELECT * FROM Person_182;
SELECT Email
FROM person_182
GROUP BY Email
HAVING COUNT(Id) > 1;

-- 34.1350. Students with invalid departments
SELECT * FROM Departments_1350;
SELECT * FROM Students_1350 ;
SELECT id,
		name
FROM students_1350
WHERE department_id NOT IN
	(SELECT DISTINCT id FROM departments_1350);

-- 35.1112.Highest grade for each student
SELECT * FROM Enrollments; 
SELECT student_id,
		course_id,
        grade
FROM
	(SELECT *,
			RANK() OVER(PARTITION BY student_id ORDER BY grade DESC, course_id) AS rk
	FROM enrollments) t1
WHERE rk = 1;

-- 36.603. Consecutive available seats
SELECT * FROM cinema ;
SELECT DISTINCT c1.seat_id
FROM cinema c1, cinema c2
WHERE c1.free = 1 AND c2.free = 1
	AND (c1.seat_id - 1 = c2.seat_id
    OR c1.seat_id + 1 = c2.seat_id);

-- 37.1142. User activity for the past 30 days
SELECT * FROM activity;
SELECT ROUND(
	(SELECT COUNT(DISTINCT session_id) FROM activity
		WHERE activity_date BETWEEN '2019-06-28' AND '2019-07-27')
    /
    (SELECT COUNT(DISTINCT user_id) FROM activity
		WHERE activity_date BETWEEN '2019-06-28' AND '2019-07-27'),
        2) AS average_session_per_user;

-- 38.1084. Sales analysis
SELECT * FROM Product;
SELECT * FROM Sales; 
-- solution 1
SELECT s.product_id, product_name
FROM sales s
INNER JOIN product p ON s.product_id = p.product_id
WHERE sale_date BETWEEN '2019-01-01' AND '2019-03-31'
	AND s.product_id NOT IN
		(SELECT product_id FROM sales WHERE sale_date NOT BETWEEN '2019-01-01' AND '2019-03-31');
-- solution 2
SELECT s.product_id, product_name
FROM Sales s
LEFT JOIN Product p
ON s.product_id = p.product_id
GROUP BY s.product_id, product_name
HAVING MIN(sale_date) >= CAST('2019-01-01' AS DATE) AND
       MAX(sale_date) <= CAST('2019-03-31' AS DATE);

-- 39.1321. Restaurant growth
SELECT * FROM Customer_1321;
WITH days AS (
SELECT visited_on, 
		SUM(amount) AS amount 
FROM customer_1321 
GROUP BY 1)

SELECT visited_on, 
		amount, 
        average_amount
FROM (
	SELECT visited_on,
			SUM(amount) OVER(ORDER BY visited_on ROWS 6 PRECEDING) AS amount,
			ROUND(AVG(amount) OVER(ORDER BY visited_on ROWS 6 PRECEDING),2) AS average_amount
	FROM days) t1
WHERE visited_on >= DATE_ADD((SELECT MIN(visited_on) FROM Customer_1321), INTERVAL 6 DAY);

-- 40.1132. Reported posts
SELECT * FROM Actions;
SELECT * FROM Removals;
SELECT
    IFNULL(ROUND(AVG(daily_avg)*100,2),0) AS average_daily_percent
FROM (
    SELECT
        a.action_date,
        COUNT(DISTINCT r.post_id) / COUNT(DISTINCT a.post_id) AS daily_avg
    FROM actions a
    LEFT JOIN removals r
        ON a.post_id = r.post_id AND a.action_date <= r.remove_date
    WHERE a.extra = 'spam'
    GROUP BY a.action_date) t1;

-- 41.1069. Product sales analysis
SELECT * FROM Sales_1069;
SELECT * FROM Product_1069;
SELECT product_id,
		SUM(quantity) AS total_quantity
FROM sales_1069
GROUP BY 1;

-- 42.1158. Market analysis
SELECT * FROM Users_1158;
SELECT * FROM Orders_1158;
SELECT * FROM Items_1158;
SELECT user_id AS buyer_id,
		join_date,
        COUNT(order_id) AS orders_in_2019
FROM users_1158 u
LEFT JOIN 
		(SELECT order_id, buyer_id 
        FROM orders_1158
        WHERE order_date BETWEEN '2019-01-01' AND '2019-12-31') o ON u.user_id = o.buyer_id
GROUP BY 1,2;

-- 43.574. Winning candidate
SELECT * FROM Candidate;
SELECT * FROM Vote;
WITH a AS (
	SELECT Name,
			COUNT(Name) AS ct
	FROM vote v
	LEFT JOIN candidate c ON v.CandidateId = c.id
	GROUP BY Name)
SELECT Name
FROM a
WHERE Name IN 
	(SELECT Name, Max(ct) FROM a);

-- 44.550. Game play analysis
SELECT * FROM Activity_550;
SELECT ROUND(COUNT(a.event_date)/COUNT(t1.player_id),2) AS fraction
FROM (
    SELECT player_id, DATE_ADD(MIN(event_date), INTERVAL 1 DAY) AS next_day
    FROM Activity_550
    GROUP BY 1) t1
LEFT JOIN Activity_550 a
    ON t1.player_id = a.player_id AND t1.next_day = a.event_date;
    
-- 45.534. Game play analysis
SELECT * FROM Activity_534;
SELECT player_id,
		event_date,
	  SUM(games_played) OVER(PARTITION BY player_id ORDER BY event_date) AS games_palyed_so_far
FROM activity_534;

-- 46.1083. Sales analysis
SELECT * FROM Product_1083;
SELECT * FROM Sales_1083;
WITH a AS (
SELECT buyer_id, s.product_id, product_name
FROM sales_1083 s
LEFT JOIN product_1083 p 
	ON s.product_id = p.product_id)
SELECT DISTINCT buyer_id
FROM a
WHERE buyer_id NOT IN
	(SELECT buyer_id
	FROM a
	WHERE product_name = 'iPhone')
    AND product_name = 'S8';

-- 47.595. Big countries
SELECT * FROM world;
SELECT name,
		population,
        area
FROM world
WHERE area > 3000000 
	OR population > 25000000;

-- 48.1173. Immediate food delivery
SELECT * FROM Delivery;
SELECT ROUND(AVG(CASE
			WHEN order_date = customer_pref_delivery_date THEN 1
            ELSE 0
            END)*100,2) AS immediate_percentage
FROM delivery;

-- 49.512. Game play analysis
SELECT * FROM Activity_512;

-- solution
SELECT player_id, device_id
FROM
	(SELECT *,
			ROW_NUMBER() OVER(PARTITION BY player_id ORDER BY event_date) AS rn
	FROM activity_512) t1
WHERE rn = 1;

-- solution
SELECT 
    player_id,
    device_id
FROM Activity
WHERE (player_id, event_date) IN
    (SELECT player_id, MIN(event_date) FROM Activity GROUP BY 1);

-- 50.196. Delete duplicate email
SELECT * FROM person_196;
SELECT Id, Email
FROM
	(SELECT Email, Id,
			ROW_NUMBER() OVER(PARTITION BY Email ORDER BY Id) AS rn
	FROM person_196) t1
WHERE rn = 1
ORDER BY Id;

-- Using DELETE 
DELETE FROM Person_196
WHERE Id IN
    (SELECT Id 
     FROM (
        SELECT Id, ROW_NUMBER() OVER(PARTITION BY Email ORDER BY Id) AS rn 
         FROM Person_196) t1
    WHERE rn > 1);

-- 51.1098. Unpopular books
SELECT * FROM Books_1098;
SELECT * FROM Orders_1098;
SELECT book_id, name
FROM
	(SELECT b.book_id,name,
			IFNULL(SUM(quantity),0) AS total
	FROM books_1098 b
	LEFT JOIN 
		(SELECT * FROM orders_1098 WHERE dispatch_date BETWEEN '2018-06-23' AND '2019-06-23') o 
			ON b.book_id = o.book_id
	WHERE available_from < DATE_SUB('2019-06-23', INTERVAL 30 DAY)
	GROUP BY b.book_id, name) t1
WHERE total < 10;

-- 52.627. Swap salary
SELECT * FROM salary;
SET SQL_SAFE_UPDATES = 0;
UPDATE salary
SET sex = CASE 
			WHEN sex = 'm' THEN 'f'
			ELSE 'm'
		  END;

-- 53.1082. Sales analysis
SELECT * FROM Product_1082;
SELECT * FROM Sales_1082;
WITH t1 AS (
SELECT seller_id,
			SUM(price) AS price
	FROM sales_1082
	GROUP BY seller_id)
SELECT seller_id
FROM t1
WHERE price =
			(SELECT MAX(price) AS price FROM t1);

-- 54.1251. Average selling price
SELECT * FROM Prices_1251;
SELECT * FROM UnitsSold_1251;
SELECT
    p.product_id,
    ROUND(SUM(p.price * u.units)/SUM(u.units), 2) AS average_price
FROM Prices_1251 p
INNER JOIN UnitsSold_1251 u
    ON p.product_id = u.product_id 
        AND
        (u.purchase_date >= p.start_date AND u.purchase_date <= p.end_date)
GROUP BY 1;

-- 55.620. Not boring movies
SELECT * FROM cinema_620;
SELECT *
FROM cinema_620
WHERE id % 2 <> 0 
	AND description <> 'boring'
ORDER BY rating DESC;

-- 56.1068. Product sales analysis
SELECT * FROM Sales_1068;
SELECT * FROM Product_1068;
SELECT product_name,
		year,
        price
FROM sales_1068 s
LEFT JOIN product_1068 p ON s.product_id = p.product_id;

-- 57.596. Classes more than 5 students
SELECT * FROM courses;
SELECT class
FROM courses
GROUP BY class
HAVING COUNT(DISTINCT student) >= 5;

-- 58.1393. Capital gain/loss
SELECT * FROM stocks;

-- solution 1
SELECT
    stock_name,
    SUM(IF(operation = 'Buy', -price, price)) AS capital_gain_loss
FROM stocks
GROUP BY stock_name;

-- solution 2
WITH a AS (
SELECT 
    stock_name,
    SUM(price) AS buy_price
FROM Stocks
WHERE operation = 'Buy'
GROUP BY stock_name       
),
b AS (
SELECT 
    stock_name,
    SUM(price) AS sell_price
FROM Stocks
WHERE operation = 'Sell'
GROUP BY stock_name     
)
SELECT 
    a.stock_name,
    b.sell_price - a.buy_price AS capital_gain_loss
FROM a LEFT JOIN b ON b.stock_name = a.stock_name;

-- 59.1384. Total sales amount by year
SELECT * FROM Product_1384;
SELECT * FROM Sales_1384;

-- Myself solution
WITH a AS (
SELECT CAST(product_id AS CHAR(50)) AS product_id, product_name, '2018' AS 'report_year' FROM product_1384
UNION ALL
SELECT CAST(product_id AS CHAR(50)) AS product_id, product_name, '2019' AS 'report_year' FROM product_1384
UNION ALL
SELECT CAST(product_id AS CHAR(50)) AS product_id, product_name, '2020' AS 'report_year' FROM product_1384
)
SELECT
    a.product_id AS PRODUCT_ID,
    a.product_name AS PRODUCT_NAME,
    a.report_year AS REPORT_YEAR,
    SUM(CASE WHEN a.report_year = '2018' AND YEAR(s.period_start) > 2018 THEN 0
         WHEN a.report_year = '2018' AND YEAR(s.period_start) <= 2018 THEN s.average_daily_sales * (DATEDIFF(LEAST('2018-12-31',s.period_end), GREATEST('2018-01-01', s.period_start))+1)
         WHEN a.report_year = '2019' AND YEAR(s.period_start) > 2019 THEN 0
         WHEN a.report_year = '2019' AND YEAR(s.period_start) <= 2019 THEN s.average_daily_sales * (DATEDIFF(LEAST('2019-12-31',s.period_end), GREATEST('2019-01-01', s.period_start))+1)
         WHEN a.report_year = '2020' AND YEAR(s.period_start) > 2020 THEN 0
         WHEN a.report_year = '2020' AND YEAR(s.period_start) <= 2020 THEN s.average_daily_sales * (DATEDIFF(LEAST('2020-12-31',s.period_end), GREATEST('2020-01-01', s.period_start))+1)
    END) AS TOTAL_AMOUNT
FROM sales_1384 s
INNER JOIN a
    ON a.product_id = s.product_id
GROUP BY a.product_id, a.product_name, a.report_year
HAVING TOTAL_AMOUNT > 0
ORDER BY PRODUCT_ID, REPORT_YEAR;


-- solution 1
WITH a AS (
SELECT s.product_id AS product_id, product_name, period_start, period_end, average_daily_sales,
		CASE WHEN period_end < '2018-01-01' THEN 0
             WHEN period_start > '2018-12-31' THEN 0
			 WHEN period_start >= '2018-01-01' AND period_end <= '2018-12-31' THEN DATEDIFF(period_end, period_start)+1
			 WHEN period_start >= '2018-01-01' AND period_end > '2018-12-31' THEN DATEDIFF('2018-12-31',period_start)+1
             WHEN period_start < '2018-01-01' AND period_end <= '2018-12-31' THEN DATEDIFF(period_end,'2018-01-01')+1
             WHEN period_start < '2018-01-01' AND period_end > '2018-12-31' THEN DATEDIFF('2018-12-31','2018-01-01')+1
             ELSE 0
		END AS 'Y2018',
        CASE WHEN period_end < '2019-01-01' THEN 0
             WHEN period_start > '2019-12-31' THEN 0
			 WHEN period_start >= '2019-01-01' AND period_end <= '2019-12-31' THEN DATEDIFF(period_end,period_start)+1
			 WHEN period_start >= '2019-01-01' AND period_end > '2019-12-31' THEN DATEDIFF('2019-12-31',period_start)+1
             WHEN period_start < '2019-01-01' AND period_end <= '2019-12-31' THEN DATEDIFF(period_end,'2019-01-01')+1
             WHEN period_start < '2019-01-01' AND period_end > '2019-12-31' THEN DATEDIFF('2019-12-31','2019-01-01')+1
             ELSE 0
		END AS 'Y2019',
        CASE WHEN period_end < '2020-01-01' THEN 0
             WHEN period_start > '2020-12-31' THEN 0
			 WHEN period_start >= '2020-01-01' AND period_end <= '2020-12-31' THEN DATEDIFF(period_end,period_start)+1
			 WHEN period_start >= '2020-01-01' AND period_end > '2020-12-31' THEN DATEDIFF('2020-12-31',period_start)+1
             WHEN period_start < '2020-01-01' AND period_end <= '2020-12-31' THEN DATEDIFF(period_end,'2020-01-01')+1
             WHEN period_start < '2020-01-01' AND period_end > '2020-12-31' THEN DATEDIFF('2020-12-31','2020-01-01')+1
             ELSE 0
		END AS 'Y2020'
FROM sales_1384 s
LEFT JOIN product_1384 p ON s.product_id = p.product_id)
SELECT product_id, product_name, '2018',
		average_daily_sales*Y2018 AS total_amount
FROM a
WHERE average_daily_sales*Y2018 > 0
UNION ALL
SELECT product_id, product_name, '2019',
		average_daily_sales*Y2019 AS total_amount
FROM a
WHERE average_daily_sales*Y2019 > 0
UNION ALL
SELECT product_id, product_name, '2020',
		average_daily_sales*Y2020 AS total_amount
FROM a
WHERE average_daily_sales*Y2020 > 0
ORDER BY product_id;
-- solution 2
SELECT a.product_id, b.product_name, a.report_year, a.total_amount
FROM (
    SELECT product_id, '2018' AS report_year,
        average_daily_sales * (DATEDIFF(LEAST(period_end, '2018-12-31'), GREATEST(period_start, '2018-01-01'))+1) AS total_amount
    FROM Sales_1384
    WHERE YEAR(period_start)=2018 OR YEAR(period_end)=2018

    UNION ALL

    SELECT product_id, '2019' AS report_year,
        average_daily_sales * (DATEDIFF(LEAST(period_end, '2019-12-31'), GREATEST(period_start, '2019-01-01'))+1) AS total_amount
    FROM Sales_1384
    WHERE YEAR(period_start)<=2019 AND YEAR(period_end)>=2019

    UNION ALL

    SELECT product_id, '2020' AS report_year,
        average_daily_sales * (DATEDIFF(LEAST(period_end, '2020-12-31'), GREATEST(period_start, '2020-01-01'))+1) AS total_amount
    FROM Sales_1384
    WHERE YEAR(period_start)=2020 OR YEAR(period_end)=2020
) a
LEFT JOIN Product_1384 b
ON a.product_id = b.product_id
ORDER BY a.product_id, a.report_year;

-- solution 3
WITH RECURSIVE a AS (
SELECT '2018' AS years
UNION ALL
SELECT years + 1 AS years
FROM a 
WHERE years + 1 <= 2020
),
b AS (
SELECT DISTINCT product_id, years FROM Sales_1384 CROSS JOIN a
),
c AS (
SELECT b.product_id, b.years, s.period_start, s.period_end, s.average_daily_sales 
FROM b
LEFT JOIN Sales_1384 s
	ON s.product_id = b.product_id 
    AND
    (YEAR(s.period_start) = b.years OR YEAR(s.period_end) = b.years OR (YEAR(s.period_start) < b.years AND YEAR(s.period_end) > b.years))
    WHERE s.product_id IS NOT NULL)    
SELECT 
	c.product_id AS PRODUCT_ID,
    p.product_name AS PRODUCT_NAME,
    c.years AS REPORT_YEAR,
    (c.average_daily_sales * CASE WHEN c.years = '2019' AND YEAR(c.period_start) = '2019' AND YEAR(c.period_end) = '2019' THEN DATEDIFF(c.period_end, c.period_start) + 1
		 WHEN c.years = '2019' AND YEAR(c.period_start) = '2019' AND YEAR(c.period_end) > '2019' THEN DATEDIFF('2019-12-31', c.period_start) + 1
         WHEN c.years = '2019' AND YEAR(c.period_start) < '2019' AND YEAR(c.period_end) > '2019' THEN DATEDIFF('2019-12-31', '2019-01-01') + 1
         WHEN c.years = '2019' AND YEAR(c.period_start) < '2019' AND YEAR(c.period_end) = '2019' THEN DATEDIFF(c.period_end, '2019-01-01') + 1
         WHEN c.years = '2018' AND YEAR(c.period_start) = '2018' AND YEAR(c.period_end) = '2018' THEN DATEDIFF(c.period_end, c.period_start) + 1
		 WHEN c.years = '2018' AND YEAR(c.period_start) = '2018' AND YEAR(c.period_end) > '2018' THEN DATEDIFF('2018-12-31', c.period_start) + 1
         WHEN c.years = '2018' AND YEAR(c.period_start) < '2018' AND YEAR(c.period_end) > '2018' THEN DATEDIFF('2018-12-31', '2018-01-01') + 1
         WHEN c.years = '2018' AND YEAR(c.period_start) < '2018' AND YEAR(c.period_end) = '2018' THEN DATEDIFF(c.period_end, '2018-01-01') + 1
         WHEN c.years = '2020' AND YEAR(c.period_start) = '2020' AND YEAR(c.period_end) = '2020' THEN DATEDIFF(c.period_end, c.period_start) + 1
		 WHEN c.years = '2020' AND YEAR(c.period_start) = '2020' AND YEAR(c.period_end) > '2020' THEN DATEDIFF('2020-12-31', c.period_start) + 1
         WHEN c.years = '2020' AND YEAR(c.period_start) < '2020' AND YEAR(c.period_end) > '2020' THEN DATEDIFF('2020-12-31', '2020-01-01') + 1
         WHEN c.years = '2020' AND YEAR(c.period_start) < '2020' AND YEAR(c.period_end) = '2020' THEN DATEDIFF(c.period_end, '2020-01-01') + 1
	END) AS TOTAL_AMOUNT
FROM c
INNER JOIN Product_1384 p
	ON p.product_id = c.product_id
ORDER BY PRODUCT_ID, REPORT_YEAR;

-- 60.1378. 
SELECT * FROM Employees_1378;
SELECT * FROM EmployeeUNI_1378;
SELECT unique_id, name
FROM Employees_1378 e
LEFT JOIN EmployeeUNI_1378 u ON u.id = e.id;

-- 61.1369. Get second most recent activity
SELECT * FROM UserActivity;
-- solution 1
SELECT
    username,
    activity,
    startDate,
    endDate
FROM (
    SELECT
        *,
        RANK() OVER(PARTITION BY username ORDER BY startDate) AS rk_asc,
        RANK() OVER(PARTITION BY username ORDER BY startDate DESC) AS rk_desc
    FROM UserActivity) t1
WHERE (rk_asc = 1 AND rk_desc = 1)
    OR
        rk_desc = 2;
-- solution 2
SELECT ua.username, ua.activity, ua.startDate, ua.endDate
FROM UserActivity ua,
    (SELECT username, MAX(startDate) AS startDate
    FROM useractivity
    GROUP BY 1
    HAVING COUNT(*) = 1 
    
    UNION ALL 
    
    SELECT username, MAX(startDate) AS startDate
    FROM useractivity
    WHERE (username , startDate) NOT IN 
		(SELECT u2.username, MAX(u2.startDate)
		 FROM useractivity u2
		 GROUP BY 1)
    GROUP BY 1) a
WHERE ua.username = a.username
	AND ua.startDate = a.startDate;

-- 62.1364. Number of trusted contracts of a customer
SELECT * FROM Customers_1364;
SELECT * FROM Contacts_1364;
SELECT * FROM Invoices_1364;
SELECT invoice_id, c1.customer_name, price, 
		COUNT(DISTINCT con.contact_name) AS 'contacts_cnt',
        COUNT(DISTINCT c2.customer_name) AS 'trusted_contacts_cnt'
FROM Invoices_1364 i
LEFT JOIN Customers_1364 c1 ON i.user_id = c1.customer_id
LEFT JOIN Contacts_1364 con ON con.user_id = i.user_id
LEFT JOIN Customers_1364 c2 ON con.contact_name = c2.customer_name
GROUP BY 1,2,3;

-- 63.1355. Activity participants
SELECT * FROM Friends_1355;
SELECT * FROM Activities_1355; 
WITH a AS (
SELECT activity,
		COUNT(*) AS 'cnt'
FROM Friends_1355
GROUP BY 1)
SELECT activity AS name
FROM a
WHERE cnt <>
	(SELECT MAX(cnt) FROM a)
    AND 
	  cnt <>
	(SELECT MIN(cnt) FROM a);

-- 64.1327. List the products ordered in a period
SELECT * FROM Products_1327;
SELECT * FROM Orders_1327;
SELECT product_name,
		SUM(unit) AS unit
FROM orders_1327 o
LEFT JOIN products_1327 p ON o.product_id = p.product_id
WHERE order_date BETWEEN '2020-02-01' AND '2020-02-29'
GROUP BY 1
HAVING SUM(unit) >= 100;

-- 65.1322. Ads performance
SELECT * FROM Ads_1322;
SELECT ad_id,
		IFNULL(ROUND(SUM(clicked)*100 / SUM(viewed),2),0) AS ctr
FROM (
	SELECT *,
			CASE WHEN action = 'Viewed' OR action = 'Clicked' THEN 1 ELSE 0 END AS 'viewed',
			CASE WHEN action = 'Clicked' THEN 1 ELSE 0 END AS 'clicked'
	FROM ads_1322) t1
GROUP BY 1
ORDER BY 2 DESC;

-- Using correlated subquery
SELECT 
    DISTINCT ad_id,
    IFNULL((SELECT ROUND(AVG(IF(a1.action = 'Clicked', 1, 0))*100,2)
    FROM ads_1322 a1
    WHERE a1.ad_id = ads_1322.ad_id
        AND action <> 'Ignored'
    GROUP BY a1.ad_id),0) AS ctr
FROM ads_1322
ORDER BY ctr DESC, ad_id;

-- 66.1308. Running total for different genders
SELECT * FROM Scores_1308;
SELECT gender,
		day,
        SUM(score_points) OVER(PARTITION BY gender ORDER BY day) AS total
FROM scores_1308;

-- 67.1303. Find team size
SELECT * FROM Employee_1303;
SELECT employee_id,
		team_size
FROM Employee_1303 e1
LEFT JOIN 
	(SELECT team_id,
			COUNT(employee_id) AS team_size
	 FROM Employee_1303
     GROUP BY 1) e2
     ON e1.team_id = e2.team_id;

-- 68.1294. Weather type in each country
SELECT * FROM Countries_1294;
SELECT * FROM Weather_1294;
SELECT country_name,
		CASE WHEN AVG(weather_state) <= 15 THEN 'Cold'
			WHEN AVG(weather_state) >= 25 THEN 'Hot'
            ELSE 'Warm'
		END AS 'weather_type'
FROM Weather_1294 w
LEFT JOIN Countries_1294 c ON w.country_id = c.country_id
WHERE day BETWEEN '2019-11-01' AND '2019-11-30'
GROUP BY 1;

-- 69.1285. Find the start and end number of continuous ranges
SELECT * FROM Logs_1285;
WITH a AS (
SELECT *,
		ROW_NUMBER() OVER(ORDER BY log_id) AS 'seq'
FROM Logs_1285),

b AS (
SELECT *,
		log_id - seq AS 'seqlog'
FROM a)
SELECT MIN(log_id) AS start_id,
		MAX(log_id) AS end_id
FROM b
GROUP BY seqlog
ORDER BY start_id;

-- 70.1280. Students and examinations
SELECT * FROM Students_1280;
SELECT * FROM Subjects_1280;
SELECT * FROM Examinations_1280;
SELECT 
    st.student_id,
    st.student_name,
    sb.subject_name,
    IFNULL(COUNT(e.subject_name),0) AS attended_exams
FROM Students_1280 st 
CROSS JOIN Subjects_1280 sb
LEFT JOIN Examinations_1280 e
    ON st.student_id = e.student_id AND sb.subject_name = e.subject_name
GROUP BY 1, 2, 3
ORDER BY 1, 3;

-- 71.1264. Page recommendations
SELECT * FROM Friendship_1264;
SELECT * FROM Likes_1264;

-- solution 1
SELECT DISTINCT page_id AS recommended_page
FROM Likes_1264
WHERE user_id IN 
	(SELECT DISTINCT user2_id
	FROM Friendship_1264
	WHERE user1_id = 1
	UNION ALL
	SELECT DISTINCT user1_id
	FROM Friendship_1264
	WHERE user2_id = 1) 
    AND page_id NOT IN 
	(SELECT page_id FROM Likes_1264 WHERE user_id = 1);

-- solution 2
SELECT
    DISTINCT page_id AS recommended_page
FROM(
    SELECT
        f.user1_id,
        f.user2_id,
        l.page_id
    FROM Friendship_1264 f
    INNER JOIN Likes_1264 l
        ON f.user1_id = l.user_id
            OR
            f.user2_id = l.user_id) t1
WHERE (user1_id = 1 OR user2_id = 1)
    AND
        page_id NOT IN
            (SELECT page_id FROM Likes_1264 WHERE user_id = 1);

-- 72.1211. Queries quality and percentage
SELECT * FROM Queries;
SELECT  query_name,
		ROUND(AVG(rating / position),2) AS quality,
        ROUND(AVG(CASE WHEN rating < 3 THEN 1 ELSE 0 END)*100,2) AS poor_query_percentage
FROM queries
GROUP BY 1;

-- 73.1205. Monthly transactions
SELECT * FROM Transactions_1205;
SELECT * FROM Chargebacks_1205;

-- solution 1
SELECT month, 
	   country, 
       SUM(CASE WHEN state = "approved" THEN 1 ELSE 0 END) AS approved_count, 
       SUM(CASE WHEN state = "approved" THEN amount ELSE 0 END) AS approved_amount, 
       SUM(CASE WHEN state = "back" THEN 1 ELSE 0 END) AS chargeback_count, 
       SUM(CASE WHEN state = "back" THEN amount ELSE 0 END) AS chargeback_amount
FROM
(
    SELECT LEFT(chargebacks_1205.trans_date, 7) AS month, country, "back" AS state, amount
    FROM chargebacks_1205
    JOIN transactions_1205 ON chargebacks_1205.trans_id = transactions_1205.id
    UNION ALL
    SELECT LEFT(trans_date, 7) AS month, country, state, amount
    FROM transactions_1205
    WHERE state = "approved"
) s
GROUP BY month, country;

-- solution 2
WITH a AS (
SELECT 
    *,
    DATE_FORMAT(trans_date, '%Y-%m') AS month
FROM transactions_1205
WHERE state = 'approved'
UNION
SELECT
    c.trans_id AS id,
    t.country,
    'chargeback' AS state,
    t.amount,
    c.trans_date,
    DATE_FORMAT(c.trans_date, '%Y-%m') AS month
FROM chargebacks_1205 c
INNER JOIN transactions_1205 t
    ON c.trans_id = t.id
)
SELECT
    month,
    country,
    SUM(CASE WHEN state = 'approved' THEN 1 ELSE 0 END) AS approved_count,
    SUM(CASE WHEN state = 'approved' THEN amount ELSE 0 END) AS approved_amount,
    SUM(CASE WHEN state = 'chargeback' THEN 1 ELSE 0 END) AS chargeback_count,
    SUM(CASE WHEN state = 'chargeback' THEN amount ELSE 0 END) AS chargeback_amount
FROM a
GROUP BY month, country
ORDER BY month, country;

-- 74.511. Game play analysis
SELECT * FROM Activity_511;
SELECT player_id,
		MIN(event_date) AS first_login
FROM Activity_511
GROUP BY 1;

-- 75.570. Managers with at least 5 direct reports
SELECT * FROM Employee_570; 
SELECT Name
FROM (
	SELECT e2.Name AS Name, e2.Id AS Id, e1.Id AS employee
	FROM Employee_570 e1
	INNER JOIN Employee_570 e2
		ON e1.ManagerId = e2.Id) t1
GROUP BY Name
HAVING COUNT(DISTINCT employee) >= 5;

-- 76.571. Find median given frequency of numbers
SELECT * FROM Numbers;
SELECT AVG(Number) AS median
FROM (
    SELECT 
        *,
        SUM(Frequency) OVER(ORDER BY Number) AS forward,
        SUM(Frequency) OVER(ORDER BY Number DESC) AS backward
    FROM Numbers) t1
WHERE Frequency >= ABS(forward - backward);

-- 77.577. Employee bonus
SELECT * FROM Employee_577;
SELECT * FROM Bonus_577; 
SELECT name,
		bonus
FROM Employee_577 e
LEFT JOIN Bonus_577 b
	ON e.empId = b.empId
WHERE bonus < 1000 OR bonus IS NULL;

-- 78.578. Get highest answer rate question
SELECT * FROM survey_log;
WITH t1 AS (
SELECT question_id AS survey_log,
    COUNT(answer_id)/COUNT(action) AS rate
FROM survey_log
GROUP BY 1)
SELECT survey_log
FROM t1
WHERE rate IN (SELECT MAX(rate) FROM t1);

-- 79.580. Count student number in departments
SELECT * FROM student_580;
SELECT * FROM department_580;
SELECT dept_name,
		IFNULL(COUNT(student_id),0) AS student_number
FROM department_580 d
LEFT JOIN student_580 s
	ON d.dept_id = s.dept_id
GROUP BY 1
ORDER BY 2 DESC, 1;

-- 80.585. Investment in 2016
SELECT * FROM insurance;
WITH t1 AS (
SELECT *,
		CONCAT(LAT,LON) AS location
FROM insurance)
SELECT SUM(TIV_2016) AS TIV_2016
FROM t1
WHERE TIV_2015 IN 
		(SELECT TIV_2015 FROM t1 GROUP BY 1 HAVING COUNT(PID) > 1)
	AND location IN 
		(SELECT location FROM t1 GROUP BY 1 HAVING COUNT(PID) = 1);

-- 81.586. Customer Placing the Largest Number of Orders
SELECT * FROM orders_586;
SELECT customer_number
FROM orders_586
GROUP BY 1
HAVING COUNT(order_number) = 
	(SELECT COUNT(order_number) FROM orders_586 GROUP BY customer_number ORDER BY 1 DESC LIMIT 1);

-- 82.607. Sales Person
SELECT * FROM salesperson_607;
SELECT * FROM company_607;
SELECT * FROM orders_607;
SELECT name
FROM salesperson_607
WHERE name NOT IN (
	SELECT s.name
	FROM orders_607 o
	LEFT JOIN company_607 c
		ON o.com_id = c.com_id
	LEFT JOIN salesperson_607 s
		ON o.sales_id = s.sales_id
	WHERE c.name = 'RED');

-- 83.612. Shortest Distance in a Plane
SELECT * FROM point_2d;
SELECT ROUND(SQRT(MIN(POW(p1.x-p2.x,2) + POW(p1.y-p2.y,2))),2)
FROM point_2d p1, point_2d p2
WHERE p1.x <> p2.x OR p1.y <> p2.y;

-- 84.613. Shortest Distance in a Line
SELECT * FROM point;
SELECT MIN(Distance) AS shortest
FROM
	(SELECT ABS(p1.x - p2.x) AS 'Distance'
	FROM point p1, point p2
	WHERE p1.x <> p2.x) t1;

-- 85.615. Average Salary: Departments VS Company
SELECT * FROM salary_615;
SELECT * FROM employee_615;

-- solution 1
WITH t1 AS (
SELECT s.employee_id,
			e.department_id,
			amount,
			DATE_FORMAT(s.pay_date,'%Y-%m') AS pay_month
FROM salary_615 s
INNER JOIN employee_615 e
	ON s.employee_id = e.employee_id),

t2 AS (
SELECT pay_month,
		AVG(amount) AS company_avg
FROM t1
GROUP BY 1),

t3 AS (
SELECT pay_month AS dpt_pay_month,
		department_id,
		AVG(amount) AS dpt_avg
FROM t1
GROUP BY 1,2)
SELECT pay_month,
		department_id,
        comparison
FROM (
	SELECT *,
			CASE WHEN company_avg < dpt_avg THEN 'higher'
				WHEN company_avg > dpt_avg THEN 'lower'
				ELSE 'same'
			END AS comparison
	FROM t2
	INNER JOIN t3
		ON t2.pay_month = t3.dpt_pay_month) t4;

-- solution 2
SELECT 
    DISTINCT pay_month,
    department_id,
    CASE WHEN avg_dept > avg_comp THEN 'higher'
         WHEN avg_dept < avg_comp THEN 'lower'
    ELSE 'same'
    END AS comparison
FROM (
    SELECT
        department_id,
        DATE_FORMAT(pay_date, '%Y-%m') AS pay_month,
        AVG(amount) OVER(PARTITION BY DATE_FORMAT(pay_date, '%Y-%m'), department_id) AS avg_dept,
        AVG(amount) OVER(PARTITION BY DATE_FORMAT(pay_date, '%Y-%m')) AS avg_comp
    FROM salary s
    INNER JOIN employee e
        ON s.employee_id = e.employee_id) t1
ORDER BY 1 DESC, 2;

-- 86.619. Biggest Single Number
SELECT * FROM my_numbers;
SELECT IFNULL(
	(SELECT num
	FROM my_numbers
	WHERE num IN 
		(SELECT num
		FROM my_numbers
		GROUP BY 1
		HAVING COUNT(NUM) = 1)
	ORDER BY num DESC
	LIMIT 1), NULL) AS num;

-- 87.1045. Customers Who Bought All Products
SELECT * FROM Customer_1045;
SELECT * FROM Product_1045;
SELECT customer_id
FROM 
	(SELECT p.product_key,
		customer_id
	FROM Product_1045 p
	LEFT JOIN Customer_1045 c
		ON p.product_key = c.product_key) t1
GROUP BY 1
HAVING COUNT(DISTINCT product_key) = 
	(SELECT COUNT(DISTINCT product_key) FROM Product_1045);

-- 88.1050. Actors and Directors Who Cooperated At Least Three Times
SELECT * FROM ActorDirector;
SELECT actor_id,
	   director_id
FROM ActorDirector
GROUP BY 1,2
HAVING COUNT(DISTINCT timestamp) >= 3;

-- 89. 1070. Product Sales Analysis III
SELECT * FROM Sales_1070;
SELECT * FROM Product_1070;
SELECT s.product_id,
		s.year AS first_year,
        quantity,
        price
FROM Sales_1070 s
INNER JOIN (
	SELECT product_id,
			MIN(year) AS year
	FROM Sales_1070
	GROUP BY 1) t1
		ON s.product_id = t1.product_id AND s.year = t1.year;
        
-- 90.1075. Project Employees I
SELECT * FROM Project_1075;
SELECT * FROM Employee_1075;
SELECT project_id,
		ROUND(AVG(experience_years),2) AS average_years
FROM Project_1075 p
LEFT JOIN Employee_1075 e
	ON p.employee_id = e.employee_id
GROUP BY 1;

-- 91.1076. Project Employees II
SELECT project_id
FROM Project_1075
GROUP BY 1
HAVING COUNT(DISTINCT employee_id) = 
	(SELECT COUNT(DISTINCT employee_id)
	FROM Project_1075
	GROUP BY project_id
    ORDER BY 1 DESC
    LIMIT 1) ;

-- 92.1077. Project Employees III
SELECT project_id,
		employee_id
FROM (
	SELECT project_id,
			p.employee_id,
			RANK() OVER(PARTITION BY project_id ORDER BY experience_years DESC) AS rk
	FROM Project_1075 p
	LEFT JOIN Employee_1075 e
	 ON p.employee_id = e.employee_id) t1
WHERE rk = 1;

-- 93.1097. Game Play Analysis V
SELECT * FROM Activity_1097;
SELECT 
    t1.install_dt,
    COUNT(*) AS installs,
    ROUND(SUM(CASE WHEN DATEDIFF(leads, install_dt) = 1 THEN 1 ELSE 0 END )  / COUNT(*), 2) AS Day1_retention
FROM (
    SELECT player_id, event_date AS install_dt,
            RANK() OVER(PARTITION BY player_id ORDER BY event_date) AS pos,
            LEAD(event_date) OVER(PARTITION BY player_id ORDER BY event_date) AS leads
    FROM Activity_1097
    ) t1
WHERE t1.pos = 1
GROUP BY t1.install_dt;

-- 94.1107. New Users Daily Count
SELECT * FROM Traffic;
SELECT 
    activity_date AS login_date,
    COUNT(DISTINCT user_id) AS user_count
FROM (
    SELECT
        user_id,
        activity_date,
        RANK() OVER(PARTITION BY user_id ORDER BY activity_date) AS rk
    FROM (
        SELECT DISTINCT *
        FROM Traffic) t1
    WHERE activity = 'login') t2
WHERE rk = 1 AND activity_date >= DATE_SUB('2019-06-30', INTERVAL 90 DAY)
GROUP BY 1;
	
-- 95.1113. Reported Posts
SELECT * FROM Actions_1113;
SELECT 
	extra AS report_reason,
    COUNT(DISTINCT post_id) AS report_count
FROM actions
WHERE action_date = DATE_SUB('2019-07-05', INTERVAL 1 DAY)
	AND extra <> 'None' 
    AND action = 'report'
GROUP BY 1;
	
-- 96.1127. User Purchase Platform
SELECT * FROM Spending;

-- solution 1
SELECT 
	t1.spend_date,
    t1.platform,
    IFNULL(SUM(amount),0) AS total_amount,
    IFNULL(COUNT(user_id),0) AS total_users
FROM
	(SELECT DISTINCT(spend_date), 'desktop' AS platform FROM spending
	UNION 
	SELECT DISTINCT(spend_date), 'mobile' AS platform FROM spending
	UNION 
	SELECT DISTINCT(spend_date), 'both' AS platform FROM spending) t1
LEFT JOIN (
	SELECT
		spend_date,
		user_id,
		IF(mobile >0, IF(desktop > 0, 'both', 'mobile'), 'desktop') AS platform,
		mobile + desktop AS amount
	FROM 
		(SELECT
			spend_date,
			user_id,
			SUM(CASE WHEN platform = 'mobile' THEN amount ELSE 0 END) AS mobile,
			SUM(CASE WHEN platform = 'desktop' THEN amount ELSE 0 END) AS desktop
		FROM spending
		GROUP BY 1,2) t2) t3
	ON t1.spend_date = t3.spend_date AND t1.platform = t3.platform
GROUP BY 1,2
ORDER BY 1;

-- solution 2
WITH temp AS
(
    SELECT DISTINCT spend_date, 'desktop' AS platform FROM Spending
    UNION ALL
    SELECT DISTINCT spend_date, 'mobile' AS platform FROM Spending
    UNION ALL
    SELECT DISTINCT spend_date, 'both' AS platform FROM Spending
)
SELECT 
    temp.spend_date,
    temp.platform,
    IFNULL(SUM(t3.mobile) + SUM(t3.desktop), 0) AS total_amount,
    IFNULL(COUNT(DISTINCT t3.user_id), 0) AS total_users
FROM temp
LEFT JOIN (

    SELECT 
        *,
        CASE WHEN mobile <> 0 AND desktop <> 0 THEN 'both'
            WHEN mobile <> 0 AND desktop = 0 THEN 'mobile'
        ELSE 'desktop'
        END AS platform
    FROM (
        SELECT
            user_id,
            spend_date,
            MAX(mobile) AS mobile,
            MAX(desktop) AS desktop
        FROM (
            SELECT 
                user_id,
                spend_date,
                CASE WHEN platform = 'mobile' THEN amount ELSE 0 END AS 'mobile',
                CASE WHEN platform = 'desktop' THEN amount ELSE 0 END AS 'desktop'
            FROM Spending) t1
        GROUP BY 1, 2) t2) t3
    ON temp.spend_date = t3.spend_date AND temp.platform = t3.platform
GROUP BY 1, 2
ORDER BY 1;

-- 97.1141. User Activity for the Past 30 Days I
SELECT * FROM Activity_1141;
SELECT 
	activity_date AS day,
    COUNT(DISTINCT user_id) AS active_users
FROM Activity_1141
WHERE activity_date > DATE_SUB('2019-07-27', INTERVAL 30 day)
GROUP BY 1;

-- 98.1148. Article Views I
SELECT * FROM Views;
SELECT DISTINCT author_id AS id
FROM views
WHERE author_id = viewer_id
ORDER BY 1;

-- 99.1149. Article Views II
SELECT * FROM Views_1149;
SELECT DISTINCT viewer_id AS id
FROM Views_1149
GROUP BY viewer_id, view_date
HAVING COUNT(DISTINCT article_id) > 1
ORDER BY 1;

-- 100.1164. Product Price at a Given Date
SELECT * FROM Products_1164;
SELECT 
	DISTINCT p.product_id,
    IFNULL(t2.new_price, 10) AS price
FROM Products_1164 p
LEFT JOIN 
	(SELECT 
		product_id,
        new_price
	FROM 
    (SELECT 
		product_id,
        new_price,
        RANK() OVER(PARTITION BY product_id ORDER BY change_date DESC) AS rk
	FROM Products_1164
    WHERE change_date <= '2019-08-16') t1 
    WHERE rk = 1) t2
    ON p.product_id = t2.product_id
ORDER BY 2 DESC;

-- 101.1174. Immediate Food Delivery II
SELECT * FROM Delivery_1174;
SELECT ROUND(AVG(immediate)*100,2) AS immediate_percentage
FROM (
	SELECT 
		customer_id,
		ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date) AS rn,
		CASE WHEN order_date = customer_pref_delivery_date THEN 1.0 ELSE 0.0 END AS immediate
	FROM Delivery_1174) t1
WHERE rn = 1;

-- 102.1193. Monthly Transactions I
SELECT * FROM Transactions_1193;
SELECT 
    month,
    country,
    COUNT(id) AS trans_count,
    COUNT(CASE WHEN approved > 0 THEN 1 END) AS approved_count, -- IFNULL
    SUM(amount) AS trans_total_amount,                          -- IFNULL
    SUM(approved) AS approved_total_amount
FROM (
    SELECT
        *,
        DATE_FORMAT(trans_date, '%Y-%m') AS month,
        CASE WHEN state = 'approved' THEN amount
        ELSE 0                                                  -- END AS
        END AS approved
    FROM Transactions_1193) t1
GROUP BY 1, 2;

-- 103.1194. Tournament Winners
SELECT * FROM Players_1194;
SELECT * FROM Matches_1194;

SELECT
    group_id,
    player AS player_id
FROM (
    SELECT
            p.group_id,
            t1.player,
            RANK() OVER(PARTITION BY p.group_id ORDER BY SUM(t1.score) DESC, t1.player) AS rk
        FROM Players_1194 p
        LEFT JOIN (
            SELECT
                match_id,
                first_player AS player,
                first_score AS score
            FROM Matches_1194
            UNION ALL
            SELECT
                match_id,
                second_player AS player,
                second_score AS score
            FROM Matches_1194) t1
            ON p.player_id = t1.player
        GROUP BY 1,2) t2
WHERE rk = 1;

-- 104.1398. Customers Who Bought Products A and B but Not C
SELECT * FROM Customers_1398;
SELECT * FROM Orders_1398;
-- solution 1
SELECT a.customer_id, a.customer_name
FROM customers_1398 a 
INNER JOIN orders_1398 b
	ON a.customer_id  = b.customer_id
GROUP BY a.customer_id, a.customer_name
HAVING SUM(b.product_name="A") >0 AND SUM(b.product_name="B") > 0 AND SUM(b.product_name="C")=0;

-- solution 2
SELECT 
    t1.customer_id,
    c.customer_name
FROM Customers_1398 c
INNER JOIN (
    SELECT
        customer_id,
        CASE WHEN product_name = 'A' THEN 1 ELSE 0 END AS 'A',
        CASE WHEN product_name = 'B' THEN 1 ELSE 0 END AS 'B',
        CASE WHEN product_name = 'C' THEN 1 ELSE 0 END AS 'C'
    FROM Orders_1398) t1
    ON t1.customer_id = c.customer_id
GROUP BY t1.customer_id, c.customer_name
HAVING SUM(A) >0 AND SUM(B) >0 AND SUM(C) = 0
ORDER BY customer_id;

-- solution 3
SELECT 
	DISTINCT customer_id, customer_name
FROM Customers_1398
WHERE
    customer_id IN 
    (SELECT customer_id
	FROM Orders_1398
	WHERE product_name = 'A')
	AND 
    customer_id IN 
    (SELECT customer_id
	FROM Orders_1398
	WHERE product_name = 'B')
	AND 
    customer_id NOT IN 
    (SELECT customer_id
	FROM Orders_1398
	WHERE product_name = 'C');

-- 105.1407. Top Travellers
SELECT * FROM Users_1407;
SELECT * FROM Rides_1407;

SELECT 
	name,
    IFNULL(SUM(distance),0) AS travelled_distance
FROM Rides_1407 r
RIGHT JOIN Users_1407 u
	ON r.user_id = u.id
GROUP BY u.id, name
ORDER BY 2 DESC, 1;

-- 106.1412. Find the Quiet Students in All Exams
SELECT * FROM Student_1412;
SELECT * FROM Exam_1412;
WITH a AS (
    SELECT
        exam_id,
        student_id,
        RANK() OVER(PARTITION BY exam_id ORDER BY score) AS rk_asc,
        RANK() OVER(PARTITION BY exam_id ORDER BY score DESC) AS rk_desc
    FROM Exam_1412
)
SELECT
    DISTINCT e.student_id,
    s.student_name
FROM Exam_1412 e
LEFT JOIN Student_1412 s
    ON s.student_id = e.student_id
WHERE e.student_id NOT IN
    (
    SELECT student_id FROM a
    WHERE rk_asc = 1 OR rk_desc = 1);
    
-- 107.1421.NPV Queries
SELECT * FROM NPV_1421;
SELECT * FROM Queries_1421;
SELECT
    q.id,
    q.year,
    IFNULL(n.npv, 0) AS npv
FROM Queries_1421 q
LEFT JOIN NPV_1421 n
    ON q.id = n.id AND q.year = n.year;
    
-- 108.1435.Create a Session Bar Chart
SELECT * FROM Sessions_1435;
WITH a AS (
    SELECT '[0-5>' AS bin
    UNION ALL
    SELECT '[5-10>' AS bin
    UNION ALL
    SELECT '[10-15>' AS bin
    UNION ALL
    SELECT '15 or more' AS bin
)
SELECT
    a.bin,
    COUNT(t1.bin) AS total
FROM a
LEFT JOIN (
    SELECT
        session_id,
        CASE WHEN duration < 300 THEN '[0-5>'
             WHEN duration >= 300 AND duration < 600 THEN '[5-10>'
             WHEN duration >= 600 AND duration < 900 THEN '[10-15>'
        ELSE '15 or more'
        END AS bin
    FROM Sessions_1435) t1
    ON t1.bin = a.bin
GROUP BY a.bin;

-- 109.1440.Evaluate Boolean Expression
SELECT * FROM Expressions;
SELECT * FROM Variables;
SELECT 
	e.*,
    CASE WHEN operator = '>' AND v1.value > v2.value THEN 'true'
		 WHEN operator = '<' AND v1.value < v2.value THEN 'true'
         WHEN operator = '=' AND v1.value = v2.value THEN 'true'
	ELSE 'false'
    END AS value
FROM Expressions e
INNER JOIN Variables v1 ON e.left_operand = v1.name
INNER JOIN Variables v2 ON e.right_operand = v2.name;

-- 110.1445.Apples & Oranges
SELECT * FROM Sales_1445;
SELECT
    sale_date,
    SUM(CASE WHEN fruit = 'oranges' THEN sold_num * -1 ELSE sold_num END) AS diff
FROM Sales_1445
GROUP BY sale_date
ORDER BY sale_date;

-- 111.1454.Active Users
SELECT * FROM Accounts_1454;
SELECT * FROM Logins_1454;
-- solution 1
WITH a AS (
    SELECT
        t1.*,
        ROW_NUMBER() OVER(PARTITION BY id ORDER BY login_date) AS seq
    FROM 
		(SELECT DISTINCT * FROM Logins_1454) t1
),
b AS (
    SELECT
        *,
        DATE_SUB(login_date, INTERVAL seq DAY) AS seq_m
    FROM a
)
SELECT DISTINCT b.id, acc.name
FROM b
INNER JOIN Accounts_1454 acc
    ON b.id = acc.id
GROUP BY b.id, acc.name, b.seq_m
HAVING COUNT(b.id) >= 5;

-- solution 2
SELECT DISTINCT l1.id, A.name
FROM Logins_1454 l1
JOIN Logins_1454 l2
ON l1.id = l2.id AND DATEDIFF(l2.login_date, l1.login_date) BETWEEN 1 AND 4
JOIN Accounts_1454 A
ON l1.id = A.id
GROUP BY l1.login_date,l1.id, A.name
HAVING COUNT(DISTINCT l2.login_date) >= 4;

-- 112.1459.Rectangles Area
SELECT * FROM Points_1459; 
SELECT *
FROM (
    SELECT
        DISTINCT p1.id AS p1,
        p2.id AS p2,
        ABS(p2.x_value - p1.x_value) * ABS(p2.y_value - p1.y_value) AS area
    FROM points p1
        INNER JOIN points p2
        ON p1.id < p2.id) t1
WHERE area > 0
ORDER BY area DESC, p1, p2;

-- 113.1468.Calculate Salaries
SELECT * FROM Salaries_1468; 
WITH a AS (
    SELECT 
        company_id,
        CASE WHEN MAX(salary) < 1000 THEN 0.00
             WHEN MAX(salary) >= 1000 AND MAX(salary) <= 10000 THEN 0.24
        ELSE 0.49
        END AS tax_rate
    FROM Salaries_1468
    GROUP BY company_id
)
SELECT
    s.company_id,
    s.employee_id,
    s.employee_name,
    ROUND(s.salary * (1-a.tax_rate),0) AS salary
FROM Salaries_1468 s
INNER JOIN a
    ON s.company_id = a.company_id;

-- 114.1479.Sales by Day of the Week
SELECT * FROM Orders_1479;
SELECT * FROM Items_1479;
SELECT
    i.item_category AS CATEGORY,
    IFNULL(SUM(CASE WHEN DAYOFWEEK(o.order_date)  = 2 THEN o.quantity ELSE 0 END),0) AS 'MONDAY',
    IFNULL(SUM(CASE WHEN DAYOFWEEK(o.order_date)  = 3 THEN o.quantity ELSE 0 END),0) AS 'TUESDAY',
    IFNULL(SUM(CASE WHEN DAYOFWEEK(o.order_date)  = 4 THEN o.quantity ELSE 0 END),0) AS 'WEDNESDAY',
    IFNULL(SUM(CASE WHEN DAYOFWEEK(o.order_date)  = 5 THEN o.quantity ELSE 0 END),0) AS 'THURSDAY',
    IFNULL(SUM(CASE WHEN DAYOFWEEK(o.order_date)  = 6 THEN o.quantity ELSE 0 END),0) AS 'FRIDAY',
    IFNULL(SUM(CASE WHEN DAYOFWEEK(o.order_date)  = 7 THEN o.quantity ELSE 0 END),0) AS 'SATURDAY',
    IFNULL(SUM(CASE WHEN DAYOFWEEK(o.order_date)  = 1 THEN o.quantity ELSE 0 END),0) AS 'SUNDAY'
FROM Orders_1479 o
RIGHT JOIN Items_1479 i
    ON o.item_id = i.item_id
GROUP BY i.item_category
ORDER BY Category;

########################################################################################################
SET @sql = NULL;
SELECT
	GROUP_CONCAT(DISTINCT 
		CONCAT(
			'SUM(CASE WHEN DATE_FORMAT(o.order_date, ''%a'') = ''',
            dow,
            ''' THEN o.quantity ELSE 0 END) AS `',
            dow,
            '`'
        )
	) INTO @sql
FROM (
	SELECT DATE_FORMAT(order_date, '%a') AS dow
    FROM orders_1479
    ) t1;

SET @sql = 
	CONCAT('SELECT i.item_category AS category, ', @sql, 
			'FROM items_1479 i
            LEFT JOIN orders_1479 o
				ON i.item_id = o.item_id
			GROUP BY category
            ORDER BY category;');

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
########################################################################################################
    
-- 115.1484.Group Sold Products By The Date
SELECT * FROM Activities_1484;
SELECT
    sell_date,
    COUNT(DISTINCT product) AS num_sold,
    GROUP_CONCAT(DISTINCT product ORDER BY product SEPARATOR ',') AS products
FROM Activities_1484
GROUP BY sell_date
ORDER BY sell_date;

-- 116.1495.Friendly Movies Streamed Last Month
SELECT * FROM TVProgram;
SELECT * FROM Content;
SELECT
    DISTINCT c.title
FROM TVProgram t
INNER JOIN Content c
    ON t.content_id = c.content_id
WHERE c.Kids_content = 'Y' 
    AND
    c.content_type = 'Movies'
    AND
    t.program_date BETWEEN '2020-06-01' AND '2020-06-30';
    
-- 117.1501.Countries You Can Safely Invest In
SELECT * FROM Person_1501;
SELECT * FROM Country_1501;
SELECT * FROM Calls_1501;
SELECT 
	DISTINCT cou.name AS country
FROM Person_1501 p
INNER JOIN Country_1501 cou
	ON LEFT(p.phone_number,3) = cou.country_code
INNER JOIN Calls_1501 c
	ON c.caller_id = p.id OR c.callee_id = p.id
GROUP BY cou.name
HAVING AVG(c.duration) > (SELECT AVG(duration) FROM Calls_1501);

-- 118.1511.Customer Order Frequency
SELECT * FROM Customers_1511;
SELECT * FROM Product_1511;
SELECT * FROM Orders_1511;
SELECT
    customer_id,
    name
FROM (
    SELECT
        o.customer_id,
        c.name,
        CASE WHEN SUM(o.quantity*p.price) >= 100 THEN 1 ELSE 0 END AS total
    FROM Orders_1511 o
    INNER JOIN Customers_1511 c
        ON o.customer_id = c.customer_id
    INNER JOIN Product_1511 p
        ON o.product_id = p.product_id
    WHERE o.order_date BETWEEN '2020-06-01' AND '2020-07-31'
    GROUP BY o.customer_id, c.name, DATE_FORMAT(o.order_date, '%Y-%m')) t1
GROUP BY customer_id, name
HAVING SUM(total) = 2;

-- 119.1517.Find Users With Valid E-Mails
SELECT * FROM Users_1517;
/*
A detailed explanation of the following regular expression solution:

'^[A-Za-z]+[A-Za-z0-9\_\.\-]*@leetcode.com$'

1. ^ means the beginning of the string
    - This is important because without it, we can have something like
    '.shapiro@leetcode.com'
    This is because *part* of the regex matches the pattern perfectly. 
    The part that is 'shapiro@leetcode.com'.
    This is how I understand it: regex will return the whole 
    thing as long as part of it matches. By adding ^ we are saying: you have to
    match FROM THE START.
	
2. [] means character set. [A-Z] means any upper case chars. In other words, 
    the short dash in the character set means range.
	
3. After the first and the second character set, there is a notation: + or *.
    + means at least one of the character from the preceding charset, and * means 
    0 or more. 
	
4. \ inside the charset mean skipping. In other words, \. means we want the dot as 
    it is. Remember, for example, - means range in the character set. So what if
     we would like to find - itself as a character? use \-. 
	 
5. Everything else, like @leetcode.com refers to exact match.

6. $ means ending with
*/;
SELECT * FROM Users_1517
WHERE REGEXP_LIKE(mail, '^[A-Za-z]+[A-Za-z0-9_./-]*(@leetcode.com)$');

-- 120.1527.Patients With a Condition
SELECT * FROM Patients;
SELECT * FROM Patients
WHERE conditions REGEXP '^DIAB1| DIAB1';

-- 121.1532.The Most Recent Three Orders
SELECT * FROM Customers_1532;
SELECT * FROM Orders_1532;
SELECT
    c.name AS customer_name,
    t1.customer_id,
    t1.order_id,
    t1.order_date
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date DESC) AS rn
    FROM Orders_1532) t1
INNER JOIN Customers_1532 c
    ON t1.customer_id = c.customer_id
WHERE rn <= 3
ORDER BY customer_name, customer_id, order_date DESC;

-- 122.1543.Fix Product Name Format
SELECT * FROM Sales_1543;
SELECT
    LOWER(TRIM(product_name)) AS product_name,
    DATE_FORMAT(sale_date, '%Y-%m') AS sale_date,
    COUNT(sale_id) AS total
FROM Sales_1543
GROUP BY 1, 2
ORDER BY 1, 2;

-- 123.1549.The Most Recent Orders for Each Product
SELECT * FROM Customers_1549;
SELECT * FROM Orders_1549;
SELECT * FROM Products_1549;
-- solution 1
SELECT
    p.product_name,
    t1.product_id,
    t1.order_id,
    t1.order_date
FROM (
    SELECT
        *,
        RANK() OVER(PARTITION BY product_id ORDER BY order_date DESC) AS rk
    FROM Orders_1549) t1
INNER JOIN Products_1549 p
    ON t1.product_id = p.product_id
WHERE t1.rk = 1
ORDER BY 1, 2, 3;

-- solution 2
SELECT
    p.product_name,
    o.product_id,
    o.order_id,
    o.order_date
FROM Orders_1549 o
INNER JOIN Products_1549 p
    ON o.product_id = p.product_id
WHERE 
    (o.product_id, o.order_date) IN
    (
        SELECT product_id, MAX(order_date) FROM Orders_1549 GROUP BY product_id
    )
ORDER BY 1, 2, 3;

-- 124.1596.The Most Frequently Ordered Products for Each Customer

SELECT * FROM Customers_1596;
SELECT * FROM Orders_1596;
SELECT * FROM Products_1596;

SELECT 
    customer_id,
    product_id,
    product_name
FROM (
    SELECT
        RANK() OVER(PARTITION BY o.customer_id ORDER BY COUNT(*) DESC) AS rk,
        p.product_name,
        p.product_id,
        o.customer_id
    FROM orders_1596 o 
    INNER JOIN products_1596 p
        ON o.product_id = p.product_id
	GROUP BY o.customer_id, p.product_id, p.product_name) t1
WHERE rk = 1;

-- 125.1635.Hopper Company Queries I
SELECT * FROM drivers;
SELECT * FROM rides;
SELECT * FROM acceptedrides;
WITH RECURSIVE a AS (
SELECT 1 AS month
UNION ALL
SELECT month + 1 
FROM a
WHERE month + 1 <= 12
)
SELECT 
	month,
    (SELECT COUNT(DISTINCT driver_id) FROM drivers WHERE join_date < IFNULL(DATE(CONCAT_WS('-', 2020, a.month + 1, 1)), '2021-1-1')) AS active_drivers,
    (SELECT COUNT(DISTINCT a.ride_id)
    FROM rides r 
    LEFT JOIN acceptedrides a
		ON r.ride_id = a.ride_id
	WHERE YEAR(r.requested_at) = 2020 AND MONTH(r.requested_at) = month) AS accepted_rides
FROM a;

-- 126.1651.opper Company Queries III
WITH RECURSIVE a AS (
SELECT 1 AS month
UNION ALL
SELECT month + 1 
FROM a
WHERE month + 1 <= 12
)
SELECT
	month,
    ROUND(AVG(ride_distance) OVER(ORDER BY month ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING),2) AS average_ride_distance,
    ROUND(AVG(ride_duration) OVER(ORDER BY month ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING),2) AS average_ride_duration
FROM (
	SELECT
		month,
		IFNULL(SUM(ride_distance),0) AS ride_distance,
		IFNULL(SUM(ride_duration),0) AS ride_duration
	FROM (
		SELECT *
		FROM a
		LEFT JOIN 
			(SELECT r.ride_id, r.requested_at, a.ride_distance, a.ride_duration
			FROM rides r
			INNER JOIN acceptedrides a
				ON r.ride_id = a.ride_id
			WHERE YEAR(r.requested_at) = 2020) t1
			ON a.month = MONTH(t1.requested_at)) t2
	GROUP BY month) t3
ORDER BY month
LIMIT 10;




























