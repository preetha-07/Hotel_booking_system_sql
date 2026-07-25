-- ---------------------------------------------------------
-- 0. Create and use database
-- ---------------------------------------------------------
CREATE DATABASE IF NOT EXISTS hotel_booking_system;
USE hotel_booking_system;

-- ---------------------------------------------------------
-- 1. Drop tables if they already exist (safe re-run)
-- ---------------------------------------------------------
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS rooms;
DROP TABLE IF EXISTS guests;
DROP TABLE IF EXISTS hotels;

-- ---------------------------------------------------------
-- 2. TABLE: hotels
-- ---------------------------------------------------------
CREATE TABLE hotels (
    hotel_id     INT AUTO_INCREMENT PRIMARY KEY,
    hotel_name   VARCHAR(100) NOT NULL,
    city         VARCHAR(50)  NOT NULL,
    address      VARCHAR(150),
    star_rating  DECIMAL(2,1) CHECK (star_rating BETWEEN 0 AND 5)
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- 3. TABLE: rooms
-- ---------------------------------------------------------
CREATE TABLE rooms (
    room_id         INT AUTO_INCREMENT PRIMARY KEY,
    hotel_id        INT NOT NULL,
    room_number     VARCHAR(10) NOT NULL,
    room_type       ENUM('Single', 'Double', 'Deluxe', 'Suite') NOT NULL,
    price_per_night DECIMAL(10,2) NOT NULL,
    is_available    BOOLEAN DEFAULT TRUE,
    UNIQUE KEY unique_room_per_hotel (hotel_id, room_number),
    FOREIGN KEY (hotel_id) REFERENCES hotels(hotel_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- 4. TABLE: guests
-- ---------------------------------------------------------
CREATE TABLE guests (
    guest_id      INT AUTO_INCREMENT PRIMARY KEY,
    first_name    VARCHAR(50) NOT NULL,
    last_name     VARCHAR(50) NOT NULL,
    email         VARCHAR(100) UNIQUE,
    phone         VARCHAR(20),
    registered_on DATE DEFAULT (CURRENT_DATE)
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- 5. TABLE: bookings
-- ---------------------------------------------------------
CREATE TABLE bookings (
    booking_id     INT AUTO_INCREMENT PRIMARY KEY,
    guest_id       INT NOT NULL,
    room_id        INT NOT NULL,
    check_in_date  DATE NOT NULL,
    check_out_date DATE NOT NULL,
    total_amount   DECIMAL(10,2) NOT NULL,
    booking_status ENUM('Confirmed', 'Checked-In', 'Checked-Out', 'Cancelled') DEFAULT 'Confirmed',
    created_on     DATE DEFAULT (CURRENT_DATE),
    CHECK (check_out_date > check_in_date),
    FOREIGN KEY (guest_id) REFERENCES guests(guest_id) ON DELETE CASCADE,
    FOREIGN KEY (room_id)  REFERENCES rooms(room_id)  ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- 6. TABLE: payments
-- ---------------------------------------------------------
CREATE TABLE payments (
    payment_id     INT AUTO_INCREMENT PRIMARY KEY,
    booking_id     INT NOT NULL,
    amount_paid    DECIMAL(10,2) NOT NULL,
    payment_date   DATE DEFAULT (CURRENT_DATE),
    payment_method ENUM('Cash', 'Credit Card', 'UPI', 'Net Banking') NOT NULL,
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =========================================================
-- SAMPLE DATA
-- =========================================================

INSERT INTO hotels (hotel_name, city, address, star_rating) VALUES
('Taj Residency',      'Chennai',   '12 Marina Beach Road',   4.5),
('Green Palm Resort',  'Goa',       '45 Calangute Beach Rd',  4.0),
('City Comfort Inn',   'Bangalore', '78 MG Road',             3.5),
('Royal Orchid',       'Mumbai',    '9 Marine Drive',         4.8);

INSERT INTO rooms (hotel_id, room_number, room_type, price_per_night, is_available) VALUES
(1, '101', 'Single', 2500.00, TRUE),
(1, '102', 'Double', 3800.00, TRUE),
(1, '201', 'Suite',  7500.00, FALSE),
(2, '101', 'Deluxe', 4500.00, TRUE),
(2, '102', 'Double', 3200.00, TRUE),
(3, '101', 'Single', 1800.00, TRUE),
(3, '102', 'Deluxe', 3000.00, FALSE),
(4, '301', 'Suite',  9800.00, TRUE),
(4, '302', 'Double', 4200.00, TRUE);

INSERT INTO guests (first_name, last_name, email, phone) VALUES
('Aditi',   'Sharma', 'aditi.sharma@example.com',  '9876543210'),
('Rahul',   'Verma',  'rahul.verma@example.com',   '9876501234'),
('Priya',   'Nair',   'priya.nair@example.com',    '9876512345'),
('Karthik', 'Raman',  'karthik.raman@example.com', '9876523456');

INSERT INTO bookings (guest_id, room_id, check_in_date, check_out_date, total_amount, booking_status) VALUES
(1, 3, '2026-07-01', '2026-07-05', 30000.00, 'Checked-Out'),
(2, 4, '2026-07-10', '2026-07-12', 9000.00,  'Confirmed'),
(3, 7, '2026-06-20', '2026-06-22', 6000.00,  'Cancelled'),
(4, 8, '2026-07-15', '2026-07-20', 49000.00, 'Checked-In'),
(1, 2, '2026-08-01', '2026-08-03', 7600.00,  'Confirmed');

INSERT INTO payments (booking_id, amount_paid, payment_method) VALUES
(1, 30000.00, 'Credit Card'),
(2, 4500.00,  'UPI'),
(4, 49000.00, 'Net Banking'),
(5, 3800.00,  'Cash');

-- =========================================================
-- VIEW: booking_summary (joins everything into one report)
-- =========================================================
CREATE OR REPLACE VIEW booking_summary AS
SELECT
    b.booking_id,
    CONCAT(g.first_name, ' ', g.last_name) AS guest_name,
    h.hotel_name,
    h.city,
    r.room_number,
    r.room_type,
    b.check_in_date,
    b.check_out_date,
    DATEDIFF(b.check_out_date, b.check_in_date) AS nights_stayed,
    b.total_amount,
    b.booking_status,
    COALESCE(SUM(p.amount_paid), 0) AS amount_paid,
    b.total_amount - COALESCE(SUM(p.amount_paid), 0) AS balance_due
FROM bookings b
JOIN guests g ON b.guest_id = g.guest_id
JOIN rooms r  ON b.room_id  = r.room_id
JOIN hotels h ON r.hotel_id = h.hotel_id
LEFT JOIN payments p ON b.booking_id = p.booking_id
GROUP BY b.booking_id, guest_name, h.hotel_name, h.city, r.room_number,
         r.room_type, b.check_in_date, b.check_out_date, b.total_amount, b.booking_status;

-- Usage:
-- SELECT * FROM booking_summary WHERE booking_id = 1;

-- =========================================================
-- USEFUL QUERIES
-- =========================================================

-- 7.1 Full booking summary
SELECT * FROM booking_summary;

-- 7.2 All available rooms across all hotels
SELECT h.hotel_name, r.room_number, r.room_type, r.price_per_night
FROM rooms r
JOIN hotels h ON r.hotel_id = h.hotel_id
WHERE r.is_available = TRUE;

-- 7.3 Total revenue per hotel (based on payments received)
SELECT
    h.hotel_name,
    ROUND(SUM(p.amount_paid), 2) AS total_revenue
FROM payments p
JOIN bookings b ON p.booking_id = b.booking_id
JOIN rooms r     ON b.room_id  = r.room_id
JOIN hotels h    ON r.hotel_id = h.hotel_id
GROUP BY h.hotel_name
ORDER BY total_revenue DESC;

-- 7.4 Guests with pending balance (unpaid or partially paid)
SELECT guest_name, hotel_name, room_number, total_amount, amount_paid, balance_due
FROM booking_summary
WHERE balance_due > 0;

-- 7.5 Current bookings status count
SELECT booking_status, COUNT(*) AS total_bookings
FROM bookings
GROUP BY booking_status;

-- 7.6 Most booked room type
SELECT room_type, COUNT(*) AS times_booked
FROM booking_summary
GROUP BY room_type
ORDER BY times_booked DESC;

-- 7.7 Guest booking history (all bookings for one guest)
SELECT * FROM booking_summary
WHERE guest_name = 'Aditi Sharma'
ORDER BY check_in_date;

-- 7.8 Rooms currently occupied (checked-in) with expected checkout
SELECT hotel_name, room_number, guest_name, check_out_date
FROM booking_summary
WHERE booking_status = 'Checked-In';

-- 7.9 Average nightly rate booked per hotel
SELECT
    h.hotel_name,
    ROUND(AVG(r.price_per_night), 2) AS avg_room_price
FROM rooms r
JOIN hotels h ON r.hotel_id = h.hotel_id
GROUP BY h.hotel_name;
