// screens/manager/all_employees_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/employee.dart';
import '../../providers/employee_provider.dart';
import 'add_employee_dialog.dart';
import 'edit_employee_dialog.dart';

class AllEmployeesScreen extends StatefulWidget {
  @override
  _AllEmployeesScreenState createState() => _AllEmployeesScreenState();
}

class _AllEmployeesScreenState extends State<AllEmployeesScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Reception', 'Housekeeping', 'Kitchen', 'Maintenance', 'Security', 'Management'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employees'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              context.read<EmployeeProvider>().loadEmployees();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEmployee,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      body: Consumer<EmployeeProvider>(
        builder: (context, employeeProvider, child) {
          final employees = employeeProvider.allEmployees;
          final filteredEmployees = _selectedFilter == 'All'
              ? employees
              : employees.where((e) => e.department == _selectedFilter).toList();

          if (employees.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No employees yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap the + button to add an employee',
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: filteredEmployees.length,
            itemBuilder: (context, index) {
              final employee = filteredEmployees[index];
              return _buildEmployeeCard(employee, context);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmployeeCard(Employee employee, BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getDepartmentColor(employee.department),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              employee.firstName[0] + employee.secondName[0],
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        title: Text(
          employee.fullName,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.phone, size: 14, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  employee.phone,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.business, size: 14, color: Colors.grey),
                SizedBox(width: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getDepartmentColor(employee.department).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    employee.department,
                    style: TextStyle(
                      fontSize: 12,
                      color: _getDepartmentColor(employee.department),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            if (employee.hireDate != null) ...[
              SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    'Hired: ${DateFormat('MMM dd, yyyy').format(employee.hireDate!)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handlePopupMenu(value, employee, context),
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
            ];
          },
        ),
        onTap: () {
          // Show employee details
          _showEmployeeDetails(employee, context);
        },
      ),
    );
  }

  Color _getDepartmentColor(String department) {
    switch (department.toLowerCase()) {
      case 'reception':
        return Colors.blue;
      case 'housekeeping':
        return Colors.green;
      case 'kitchen':
        return Colors.orange;
      case 'maintenance':
        return Colors.red;
      case 'security':
        return Colors.purple;
      case 'management':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  void _handlePopupMenu(String value, Employee employee, BuildContext context) {
    switch (value) {
      case 'edit':
        _editEmployee(employee, context);
        break;
      case 'delete':
        _deleteEmployee(employee, context);
        break;
    }
  }

  void _showEmployeeDetails(Employee employee, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Employee Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: CircleAvatar(
                  backgroundColor: _getDepartmentColor(employee.department),
                  radius: 40,
                  child: Text(
                    employee.firstName[0] + employee.secondName[0],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildDetailRow('Name', employee.fullName, Icons.person),
              _buildDetailRow('Phone', employee.phone, Icons.phone),
              _buildDetailRow('Department', employee.department, Icons.business),
              if (employee.hireDate != null)
                _buildDetailRow(
                  'Hire Date',
                  DateFormat('MMMM dd, yyyy').format(employee.hireDate!),
                  Icons.calendar_today,
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addEmployee() async {
    final added = await showDialog<bool>(
      context: context,
      builder: (_) => AddEmployeeDialog(),
    );

    if (added == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Employee added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _editEmployee(Employee employee, BuildContext context) async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (_) => EditEmployeeDialog(employee: employee),
    );

    if (updated == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Employee updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _deleteEmployee(Employee employee, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Employee'),
        content: Text('Are you sure you want to delete ${employee.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await context.read<EmployeeProvider>().deleteEmployee(employee.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Employee deleted successfully'),
                    backgroundColor: Colors.red,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting employee: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter by Department'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _filters.length,
            itemBuilder: (context, index) {
              final filter = _filters[index];
              return RadioListTile<String>(
                title: Text(filter),
                value: filter,
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}