# Departments Feature for GovConnect Home Screen

## Overview

Added a new "Departments" section to the home screen that displays either pinned departments or popular departments by default, similar to the existing appointments section.

## Features

### 1. Pinned Departments Section

- Shows departments that users have pinned to their dashboard
- If no departments are pinned, shows popular departments instead
- Displays up to 2 departments on the home screen
- Has a "View all" button that navigates to the services screen

### 2. Pin/Unpin Functionality

- Users can pin departments to show them on the home screen dashboard
- Pin/unpin buttons are available both on the home screen cards and in the services screen
- Pinned state is persisted using SharedPreferences
- Visual feedback with snackbar notifications when pinning/unpinning

### 3. Visual Design

- Consistent with existing appointment cards design
- Department cards show:
  - Department icon with color-coded background
  - Department name
  - Number of available services
  - Pin/unpin button
  - "Services" action button

## Implementation Details

### New Files Created:

1. `src/core/services/departments_service.dart` - Manages pinned departments state and persistence
2. `src/presentation/widgets/pinned_department_card.dart` - Home screen department card component
3. `src/presentation/widgets/department_card_with_pin.dart` - Services screen department card with pin functionality

### Modified Files:

1. `src/presentation/screens/home_screen.dart` - Added departments section
2. `src/presentation/screens/services_screen.dart` - Added pin functionality to department cards
3. `src/core/app_export.dart` - Exported new services
4. `src/injection.dart` - Added DepartmentsService to dependency injection

### Key Components:

#### DepartmentsService

- Manages list of pinned department IDs
- Provides methods to pin/unpin departments
- Persists data using SharedPreferences
- Offers convenient methods for home screen display

#### PinnedDepartmentCard

- Used on home screen for displaying departments
- Shows pin button and action button
- Handles navigation to form selection

#### DepartmentCardWithPin

- Used in services screen
- Grid layout compatible
- Pin button in top-right corner
- Maintains original department card design

## Usage

### Home Screen

The departments section automatically shows:

- Pinned departments (if any exist)
- Popular departments (as fallback)
- Maximum of 2 departments
- "View all" button to navigate to services

### Services Screen

Users can:

- Browse all available departments
- Pin/unpin departments using the pin button
- See visual feedback via snackbar
- Navigate to department services

### Data Persistence

- Pinned departments are stored in SharedPreferences
- Data persists across app restarts
- Automatically loads on app initialization

## Future Enhancements

- Add reordering functionality for pinned departments
- Implement department notifications
- Add department-specific quick actions
- Support for department categories/grouping
