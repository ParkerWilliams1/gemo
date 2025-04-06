# **Gemo**  

## **Overview**  
Gemo is a college-exclusive video chat app designed for students to connect, study, and socialize securely. It fosters real-time interactions in a safe and student-friendly environment.  

## **Key Features**  
✅ **Video Chat** – Seamless real-time video communication.  
✅ **Student-Only Access** – Secure authentication for college students.  
✅ **Study & Social Spaces** – Connect for academic collaboration or casual chats.  


## Gemo Coding Standards & Best Practices

#### **Code Readability**
1. Use automatic formatting: always use dart format (or enable auto-formatting in your IDE).
2. Follow naming conventions:
   - **camelCase** for variables, functions, methods
   - **UPPER_CASE** for constant variables
   - **PascalCase** for classes and enums
   - **_underscorePrefix** for private members
3. Keep functions short and focused on a single task.
4. Automate repetitive tasks and avoid code duplication.
5. Limit deep nesting in code structures.
6. Maintain short horizontal line lengths for better readability.
7. Use const when possible to improve performance
8. Avoid unnecessary  new and const:
    ✅ var button = ElevatedButton();
    ❌ var button = new ElevatedButton();

#### **Code Organization and Structure**
1. Follow a modular project structure (e.g., lib/screens/, lib/widgets/, lib/services/, lib/models/).
2. Separate UI, business logic, and state management (e.g., MVVM, Bloc, Riverpod, or Provider).
3. Keep files concise—split large files into smaller ones.

#### **Functions & Methods**
- Keep functions short and focused—aim for single responsibility.
- Use meaningful names that clearly describe the function's purpose.
- Use named parameters for clarity.

#### **Standardize Headers for Files and Functions**
#### **File Naming**
✅ Use lowercase and separate words with underscores (_)
✅ Keep file names descriptive but concise
✅ Avoid spaces, uppercase letters, or special characters
✅ Use meaningful names based on the file's purpose
✅ Group related files within folders (e.g., models/, widgets/, screens/)

##### **Class and Dart File Headers**
Each class and file should include a structured comment block at the top:

**Template:**
```dart
/*
    Class Name:
    Date of Creation:
    Name of Creator:
    Summary:
    Functions:
    Variables Accessed by Module:
    History of Modifications:
*/
```

**Example:**
```dart
/*
    WelcomeScreen.dart
    February 13, 2024
    John Smith
    This file contains the logic for the welcome screen, where users enter their username and password. The data is then uploaded to Firebase Authentication.
    
    Functions:
    void signIn(user, pass): Signs the user up via Firebase.
    void login(user, pass): Logs the user into Firebase.
    Widget build(): Constructs the UI for the screen.

    Variables Accessed by Module:
    None

    History of Modifications:
    John Smith - Feb 15, 2024: Added sign-in function and optimized sign-up function.
*/
```

##### **Function Headers**
Each function should include a structured comment block before its definition:

**Template:**
```dart
/*
    Function Name:
    Date of Creation:
    Name of Creator:
    Summary:
    Declared Variables:
    Parameters:
*/
```

**Example:**
```dart
/*
    login
    Feb 13, 2024
    John Smith
    Function to log in a user using Firebase Authentication and data from input text fields.

    Declared Variables:
    None

    Parameters:
    String user: Stores the user's username.
    String pass: Stores the user's password.
    String email: Stores the user's email address.
*/
```

#### **Naming Conventions**
- Use descriptive and specific variable names to avoid confusion.
- A single variable should not hold different types of data in different functions.
- Ensure unique variable names, avoiding overly generic terms like `username` when the context differs.

#### **Documentation & Comments**
- Leave comments assuming the reader has minimal coding experience.
- Prioritize clear and thorough documentation.
- Write comments while coding rather than postponing them for later.
