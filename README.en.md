# Coinsa - travel expense tracker

[🇷🇺 Русский](README.md) | [🇺🇸 English](README.en.md)

![iOS 26+](https://img.shields.io/badge/iOS-26%2B-178DF6)
![SwiftUI](https://img.shields.io/badge/SwiftUI-000000?logo=swift&logoColor=white)
![SwiftData](https://img.shields.io/badge/SwiftData-6A4C9C?style=flat&logo=swift&logoColor=white)
![CloudKit](https://img.shields.io/badge/CloudKit-3C61AB?logo=icloud&logoColor=white)
[![Last Commit](https://img.shields.io/github/last-commit/fullentropppy/coinsa.svg)](https://github.com/fullentropppy/coinsa/commits)

**Coinsa** is an iOS app for tracking expenses while traveling. It helps you plan budgets, track spending by location and across the whole trip, work with currencies, and get insights into your expenses.

## Main Features

### Trips and Locations

- Create trips with a home currency (budgets and expense amounts are stored in this currency for shared calculations)
- Add locations within each trip with a location currency (amounts can be entered and viewed in both the home and location currencies)
- Separate lists of locations and general expenses in trip details, with a summary of the whole trip

### Budget and Expenses

- Set a budget for each location and a separate budget for general trip expenses
- Record general expenses without a location, such as flights or insurance, and include them in the total trip budget and analytics
- Track expenses by subcategory and category:
  - Food
  - Transport
  - Accommodation
  - Leisure
  - Shopping
  - Medicine
  - Miscellaneous
- Choose a payment method:
  - Cash
  - Card
- Add comments, save expense locations, and choose them on a map
- Copy and move expenses between locations and general expenses within the same trip
- Exclude a location expense from daily spending: it reduces the available budget and stays in totals and analytics without counting toward the daily spending amount
- Transfer the full positive budget balance between locations in the same trip without changing the total trip budget

### "Today" Screen

- Information for the current day:
  - Recommended budget for today
  - Actual spending for the day
  - Remaining recommended budget
  - Current exchange rate for the location's currency
- Daily budget that accounts for prepayments, other-day expenses, and expenses excluded from daily spending
- Configurable switching of the summary budget and balance to the whole location when the daily limit is exceeded; the spending card still shows daily spending
- Quick expense creation and three subcategory shortcuts based on the selected location's history
- Today's expenses for the selected location and general expenses for its trip; general expenses do not affect the location's daily budget

### Currencies and Exchange Rates

- Automatically load up-to-date exchange rates
- Choose a currency from the list for each individual expense
- Set an exchange-rate adjustment percentage, for example to account for a bank fee
- Refresh rates for ongoing and upcoming locations from the trip menu without changing saved expense amounts
- Search currencies by code and name, with priority for trip and popular currencies
- Configure exchange-rate caching and automatic rate loading when creating an expense

### Analytics

- Analytics for the whole trip, its locations, and general expenses:
  - Total budget and expenses
  - Average daily budget and spending
  - Number of expenses and the largest expense
  - Daily and hourly expense charts with links to individual expenses
  - Expenses by category and subcategory as a chart and list
  - Comparison of spending across trip locations, excluding general expenses
- Expense maps with nearby markers grouped together and links to expense records
- Location totals in the home and location currencies using the location's saved rate; individual expenses retain their own rates

### Currency Converter

- A separate tab for converting amounts between currencies using a loaded rate
- Quickly swap the conversion direction, use a dedicated numeric keypad, and retain the selected currencies and amount

### Import and Export

- Export all trips, locations, and expenses to a JSON file without app settings
- Import JSON with a preview of records to add, update, or skip
- Merge by identifiers and modification dates without deleting records absent from the file

### Settings

- Default home currency for new trips and exchange-rate adjustment for new locations and general trip expenses
- Automatic rate loading and expense location detection when creating an expense
- System, light, or dark appearance, haptic feedback, and floating button placement

### Synchronization

- Automatically sync trips, locations, and expenses through private iCloud storage between devices running Coinsa with the same Apple Account
- App settings and saved converter state remain on the device

## System Requirements

Requires **iOS 26** or later.

## Privacy

Coinsa stores data on the device and syncs it through the user's private iCloud storage. The app requires no registration and does not use advertising or tracking technologies.

Exchange rates come from Hexarate, maps use Apple services, and new versions are checked through an API on Cloudflare. Exported JSON contains trip data, including comments and saved coordinates, and is not encrypted by the app. The user chooses where to save the file.

More details: [Privacy Policy](https://fullentropppy.github.io/coinsa/privacy-en.html)

## License

**Coinsa is not an open-source project.** The source code is available for viewing, study, and personal non-commercial use.

You may download, run, and modify the code for personal and non-commercial purposes, provided that the required copyright notice is retained.

Commercial use, sale, redistribution, publication of modified versions, and publication of Coinsa or derivative works on the App Store, TestFlight, or other distribution channels are prohibited.

The name **Coinsa** may not be used in derivative projects without written permission from the copyright holder.

Full terms: [Licence](LICENSE.en.md)

Copyright © 2026 Gritsenko Daniil. All rights reserved.
