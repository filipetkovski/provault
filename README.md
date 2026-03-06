# ProVault

## Description
ProVault is a local password vault that securely stores your credentials.

The application is built using Qt QML and C++. Users unlock the vault using a single master key, after which they can create, edit, and manage multiple credentials.

## Features
### 1. User Authentication
- Master key used to unlock the vault
- Option to delete the vault
- Only one vault allowed per device
  
### 2. Credentials Management
- Credentials contain title, username, and password
- Built-in strong password generator
- View credentials in a table
- Add new credentials
- Edit existing credentials
- Delete credentials
- Copy credential password
- Export credentials as `.json`

## Getting Started
- Qt 6.8.3
- MSVC 2022 64-bit
- Qt Creator

## Installation
1. Install Qt 6.8.3 (MSVC2022 64-bit)
2. Clone the repository
    - git clone https://github.com/filipetkovski/provault.git
3. Open the project in Qt Creator
4. Select the Qt 6.8.3 MSVC2022 kit
5. Build and run the application
