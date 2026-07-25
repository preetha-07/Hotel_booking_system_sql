# 🏨 Hotel Booking Database (MySQL)

A simple MySQL project that models a hotel booking system — built as part of my internship. 🛎️

## 📖 Overview

This project demonstrates core relational database concepts using **pure MySQL syntax**:
- 🏗️ Table design with `AUTO_INCREMENT`, `ENUM`, primary/foreign keys, and constraints
- ⚙️ InnoDB storage engine with cascading deletes
- 👀 A consolidated view joining hotels, rooms, guests, bookings, and payments
- 📊 Aggregate queries for revenue, occupancy, and booking status
- 💰 Balance-due tracking per booking

## 🗂️ Schema

| Table | Description |
|---|---|
| 🏨 `hotels` | Hotel details (name, city, rating) |
| 🛏️ `rooms` | Rooms per hotel with type, price, and availability |
| 👤 `guests` | Guest personal details |
| 📅 `bookings` | Check-in/check-out records linking guests to rooms |
| 💳 `payments` | Payments made against each booking |

## ✨ Features

- 📋 `booking_summary` view: one-stop report combining guest, hotel, room, dates, and payment status
- 🛌 List of currently available rooms
- 💵 Total revenue per hotel
- ⚠️ Guests with pending/unpaid balances
- 📊 Booking status breakdown (Confirmed, Checked-In, Checked-Out, Cancelled)
- 🏆 Most booked room type
- 🕓 Guest booking history
- 🔑 Currently occupied rooms with expected checkout
- 💲 Average nightly rate per hotel

## 🚀 How to Run

1. Clone this repo
   ```bash
   git clone https://github.com/preethamanikandan07-cpu/Hotel_booking_system_sql
   ```
2. Open `hotel_booking_system.sql` in MySQL Workbench 
2. Run the script — it creates the database, tables, sample data, the `booking_summary` view, and example queries.

💡 The script creates its own database (`hotel_booking_system`) via `CREATE DATABASE IF NOT EXISTS`, so no manual setup is needed beforehand.

## 🛎️ Booking Status Flow

| Status | Meaning |
|---|---|
| 🟡 Confirmed | Room reserved, guest not yet arrived |
| 🟢 Checked-In | Guest currently staying |
| ⚪ Checked-Out | Stay completed |
| 🔴 Cancelled | Booking cancelled |

## 🛠️ Tech Stack

- 🐬 MySQL 8.0+ (uses `ENUM`, `CREATE OR REPLACE VIEW`, `DATEDIFF`)

---

*Built by Preetha Manikandan as part of a SQL internship project.*
