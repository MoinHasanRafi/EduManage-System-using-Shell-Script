#!/bin/bash

# File to store student data and courses
STUDENT_DATA="students_data.txt"
COURSE_LIST="courses.txt"

# Admin credentials
ADMIN_USERNAME="admin"
ADMIN_PASSWORD="admin123"

# Ensure required files exist
if [ ! -f "$STUDENT_DATA" ]; then
    touch "$STUDENT_DATA"
fi

if [ ! -f "$COURSE_LIST" ]; then
    echo "Operating System" >"$COURSE_LIST"
    echo "Computer Network" >>"$COURSE_LIST"
    echo "Database Management System" >>"$COURSE_LIST"
fi

# Function to display admin menu
admin_menu() {
    echo "Admin Menu"
    echo "1. Create UserName and Password"
    echo "2. Delete User"
    echo "3. Modify User"
    echo "4. View All Users"
    echo "5. View Specific Student Information"
    echo "6. Manage Course List"
    echo "7. Exit"
    echo
}

# Function to display user menu
user_menu() {
    echo "User Menu"
    echo "1. View Course List"
    echo "2. Register for a Course"
    echo "3. View My Information"
    echo "4. Update Personal Information"
    echo "5. Change Password"
    echo "6. Exit"
    echo
}

# Admin functions
admin_login() {
    read -p "Enter Admin Username: " username
    read -s -p "Enter Admin Password: " password
    echo

    if [[ "$username" == "$ADMIN_USERNAME" && "$password" == "$ADMIN_PASSWORD" ]]; then
        echo "Admin login successful."
        admin_operations
    else
        echo "Invalid Admin credentials. Access denied."
        exit 1
    fi
}

create_user() {
    read -p "Enter username to create: " username
    if grep -q "^$username:" "$STUDENT_DATA"; then
        echo "Error: User '$username' already exists."
    else
        read -s -p "Enter password for user '$username': " password
        echo
        echo "$username:$password::::::" >>"$STUDENT_DATA"
        echo "User '$username' created successfully."
    fi
}

delete_user() {
    read -p "Enter username to delete: " username
    if grep -q "^$username:" "$STUDENT_DATA"; then
        sed -i "/^$username:/d" "$STUDENT_DATA"
        echo "User '$username' deleted successfully."
    else
        echo "Error: User '$username' does not exist."
    fi
}

modify_user() {
    read -p "Enter username to modify: " username
    if grep -q "^$username:" "$STUDENT_DATA"; then
        echo "Modify Options:"
        echo "1. Change Username"
        echo "2. Change Password"
        read -p "Choose an option: " option

        case $option in
        1)
            read -p "Enter new username: " new_username
            sed -i "s/^$username:/$new_username:/" "$STUDENT_DATA"
            echo "Username changed to '$new_username'."
            ;;
        2)
            read -s -p "Enter new password: " new_password
            sed -i "s/^$username:\([^:]*\):/$username:$new_password:/" "$STUDENT_DATA"
            echo
            echo "Password changed for user '$username'."
            ;;
        *)
            echo "Invalid option."
            ;;
        esac
    else
        echo "Error: User '$username' does not exist."
    fi
}

view_all_users() {
    if [ -s "$STUDENT_DATA" ]; then
        echo "All Users:"
        awk -F: '{print $1}' "$STUDENT_DATA"
    else
        echo "No users found."
    fi
}

view_student_info() {
    read -p "Enter username to view details: " username
    if grep -q "^$username:" "$STUDENT_DATA"; then
        awk -F: -v user="$username" '$1 == user {print "Username: " $1 "\nSchool: " $3 "\nCollege: " $4 "\nHometown: " $5 "\nSSC GPA: " $6 "\nHSC GPA: " $7 "\nUndergraduate Program: " $8}' "$STUDENT_DATA"
    else
        echo "Error: User '$username' does not exist."
    fi
}

manage_courses() {
    echo "Courses:"
    cat "$COURSE_LIST"
    echo
    echo "1. Add a Course"
    echo "2. Remove a Course"
    read -p "Choose an option: " option

    case $option in
    1)
        read -p "Enter course name to add: " course
        if grep -qx "$course" "$COURSE_LIST"; then
            echo "Error: Course '$course' already exists."
        else
            echo "$course" >>"$COURSE_LIST"
            echo "Course '$course' added."
        fi
        ;;
    2)
        read -p "Enter course name to remove: " course
        if grep -qx "$course" "$COURSE_LIST"; then
            sed -i "/^$course$/d" "$COURSE_LIST"
            echo "Course '$course' removed."
        else
            echo "Error: Course '$course' does not exist."
        fi
        ;;
    *)
        echo "Invalid option."
        ;;
    esac
}

# User functions
user_login() {
    read -p "Enter your username: " username
    read -s -p "Enter your password: " password
    echo

    if grep -q "^$username:$password:" "$STUDENT_DATA"; then
        echo "Login successful."
        user_operations "$username"
    else
        echo "Invalid credentials. Access denied."
        exit 1
    fi
}

view_courses() {
    echo "Available Courses:"
    cat "$COURSE_LIST"
}

view_my_info() {
    local username="$1"
    awk -F: -v user="$username" '$1 == user {print "Username: " $1 "\nSchool: " $3 "\nCollege: " $4 "\nHometown: " $5 "\nSSC GPA: " $6 "\nHSC GPA: " $7 "\nUndergraduate Program: " $8}' "$STUDENT_DATA"
}

update_information() {
    local username="$1"
    read -p "Enter School: " school
    read -p "Enter College: " college
    read -p "Enter Hometown: " hometown
    read -p "Enter SSC GPA: " ssc_gpa
    read -p "Enter HSC GPA: " hsc_gpa
    read -p "Enter Undergraduate Program: " undergraduate_program

    sed -i "s/^$username:\([^:]*\):.*/$username:\1:$school:$college:$hometown:$ssc_gpa:$hsc_gpa:$undergraduate_program/" "$STUDENT_DATA"
    echo "Information updated successfully."
}

change_password() {
    local username="$1"
    read -s -p "Enter new password: " new_password
    echo
    sed -i "s/^$username:\([^:]*\):/$username:$new_password:/" "$STUDENT_DATA"
    echo "Password changed successfully."
}

# Operations
admin_operations() {
    while true; do
        admin_menu
        read -p "Enter your choice: " choice
        case $choice in
        1) create_user ;;
        2) delete_user ;;
        3) modify_user ;;
        4) view_all_users ;;
        5) view_student_info ;;
        6) manage_courses ;;
        7) echo "Exiting Admin panel."; exit 0 ;;
        *) echo "Invalid choice. Please try again." ;;
        esac
    done
}

user_operations() {
    local username="$1"
    while true; do
        user_menu
        read -p "Enter your choice: " choice
        case $choice in
        1) view_courses ;;
        2) register_course "$username" ;;
        3) view_my_info "$username" ;;
        4) update_information "$username" ;;
        5) change_password "$username" ;;
        6) echo "Exiting User panel."; exit 0 ;;
        *) echo "Invalid choice. Please try again." ;;
        esac
    done
}

# Main script
echo "Welcome to the Role-Based System"
echo "1. Admin"
echo "2. User"
read -p "Enter your role (1 for Admin, 2 for User): " role

case $role in
1) admin_login ;;
2) user_login ;;
*) echo "Invalid role. Exiting."; exit 1 ;;
esac


