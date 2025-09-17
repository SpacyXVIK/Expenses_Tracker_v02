# expense_tracker_v02

📊 Expense Tracker App

A Flutter-based Expense Tracker that helps users manage their daily expenses, track recurring expenses, set monthly budgets, and secure the app with fingerprint authentication.
🚀 My Approach

I designed this app with a clean architecture in mind:

Hive is used for local storage of expenses, categories, recurring expenses, and settings (like fingerprint lock).

Provider is used as the state management solution for efficient UI updates and reactive programming.

The app is modularized into models, providers, services, Widgets, and UI screens.

Added biometric authentication for security.

Implemented recurring expenses auto-generation logic to ensure expenses repeat based on frequency (weekly, monthly, yearly).

🛠️ State Management

Used Provider (ChangeNotifierProvider + Consumer) for:

Managing expense list and categories

Updating recurring expenses

Handling theme switching

Managing app settings (biometric)

🏞️ Note- All Screenshots are provided inside the images folder, so please check it out.

Why Provider?
✅ Simple to implement
✅ Lightweight and recommended by the Flutter team
✅ Easy to scale for this app’s use case

⚡ Challenges & Solutions
1. Handling Recurring Expenses Automatically

Challenge: Needed to automatically generate recurring expenses when due.

Solution: Added a _checkAndAddRecurringExpenses() function inside ExpenseProvider that runs at startup, checks due dates, and creates new expenses accordingly.

2. Fingerprint Authentication

Challenge: Securely locking/unlocking the app.

Solution: Used the local_auth package and stored the fingerprint lock setting in Hive (settings box). Added a lock screen that runs before accessing the app if biometric is enabled.

3. Hive Box Conflicts

Challenge: Hive threw errors when the same box (settings) was opened multiple times in different places.

Solution: Created a singleton Hive service to open the box only once and provide a shared instance throughout the app.

📦 Packages Used

provider – State management

hive & hive_flutter – Local storage

local_auth – Biometric authentication

intl – Multi-language support
    
path_provider- finding commonly used locations 

fl_chart- shwing charts
  
excel- Exporting data in excel form
  
file_picker- to pick a file from system
  
go_router- for smooth transition effects
  
📷 Features

✅ Add/Edit/Delete expenses

✅ Show trnding expenses

✅ Show expense distribution by category

✅ Recurring expenses with auto-generation

✅ Monthly budget tracking

✅ Export/Import expenses via Excel

✅ Fingerprint lock

✅ Dark/Light theme toggle

✅ Multi-language support (English + Hindi) [*Remaining still working on it]

✅ Notification reminder to log expenses [*Remaining still working on it]
