-- 3.1

SELECT 
    c.name, 
    c.email, 
    c.phone, 
    COUNT(b.ID_booking) AS total_bookings, 
    STRING_AGG(DISTINCT h.name, ', ') AS hotel_list, 
    ROUND(AVG(b.check_out_date - b.check_in_date), 4) AS avg_stay_duration
FROM Booking b
JOIN Customer c ON b.ID_customer = c.ID_customer
JOIN Room r ON b.ID_room = r.ID_room
JOIN Hotel h ON r.ID_hotel = h.ID_hotel
GROUP BY c.ID_customer
HAVING COUNT(DISTINCT h.ID_hotel) > 1  AND COUNT(b.ID_booking) >= 3
ORDER BY total_bookings DESC;

-- 3.2

WITH tempBookings AS (
    SELECT 
        c.ID_customer,
        c.name,
        COUNT(b.ID_booking) AS total_bookings,
        COUNT(DISTINCT h.ID_hotel) AS unique_hotels,
        SUM(r.price) AS total_spent
    FROM Booking b
    JOIN Customer c ON b.ID_customer = c.ID_customer
    JOIN Room r ON b.ID_room = r.ID_room
    JOIN Hotel h ON r.ID_hotel = h.ID_hotel
    GROUP BY c.ID_customer, c.name
    HAVING COUNT(b.ID_booking) > 2 AND COUNT(DISTINCT h.ID_hotel) > 1
),
tempClients AS (
    SELECT 
        c.ID_customer,
        c.name,
        SUM(r.price) AS total_spent,
        COUNT(b.ID_booking) AS total_bookings
    FROM Booking b
    JOIN Customer c ON b.ID_customer = c.ID_customer
    JOIN Room r ON b.ID_room = r.ID_room
    GROUP BY c.ID_customer, c.name
    HAVING SUM(r.price) > 500
)

SELECT 
    tb.ID_customer,
    tb.name,
    tb.total_bookings,
    tb.total_spent,
    tb.unique_hotels
FROM tempBookings tb
JOIN tempClients tc ON tb.ID_customer = tc.ID_customer
ORDER BY tb.total_spent ASC;

-- 3.3

WITH tempCategories AS (
    SELECT 
        h.ID_hotel,
        CASE
            WHEN AVG(r.price) < 175 THEN 'Дешевый'
            WHEN AVG(r.price) BETWEEN 175 AND 300 THEN 'Средний'
            WHEN AVG(r.price) > 300 THEN 'Дорогой'
        END AS hotel_category
    FROM Hotel h
    JOIN Room r ON h.ID_hotel = r.ID_hotel
    GROUP BY h.ID_hotel
),
tempChoise AS (
    SELECT 
        b.ID_customer,
        MAX(CASE 
            WHEN tc.hotel_category = 'Дорогой' THEN 'Дорогой'
            WHEN tc.hotel_category = 'Средний' THEN 'Средний'
            WHEN tc.hotel_category = 'Дешевый' THEN 'Дешевый'
            ELSE NULL
        END) AS preferred_hotel_type,
        STRING_AGG(DISTINCT h.name, ', ') AS visited_hotels
    FROM Booking b
    JOIN Room r ON b.ID_room = r.ID_room
    JOIN Hotel h ON r.ID_hotel = h.ID_hotel
    JOIN tempCategories tc ON h.ID_hotel = tc.ID_hotel
    GROUP BY b.ID_customer
)

SELECT 
    tc.ID_customer,
	c.name,
    tc.preferred_hotel_type,
    tc.visited_hotels
FROM tempChoise tc
JOIN Customer c ON tc.ID_customer = c.ID_customer
ORDER BY 
    CASE tc.preferred_hotel_type
        WHEN 'Дешевый' THEN 1
        WHEN 'Средний' THEN 2
        WHEN 'Дорогой' THEN 3
    END,
    tc.ID_customer;