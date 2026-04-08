// screens/manager/edit_employee_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/employee.dart';
import '../../features/employees/cubit/employee_cubit.dart';

class EditEmployeeDialog extends StatefulWidget {
  final Employee employee;

  const EditEmployeeDialog({Key? key, required this.employee}) : super(key: key);

  @override
  _EditEmployeeDialogState createState() => _EditEmployeeDialogState();
}

class _EditEmployeeDialogState extends State<EditEmployeeDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _secondNameController;
  late TextEditingController _phoneController;
  late String _selectedDepartment;

  final List<String> _departments = [
    'Reception',
    'Housekeeping',
    'Kitchen',
    'Maintenance',
    'Security',
    'Management',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.employee.firstName);
    _secondNameController = TextEditingController(text: widget.employee.secondName);
    _phoneController = TextEditingController(text: widget.employee.phone);
    _selectedDepartment = widget.employee.department;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _secondNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateEmployee() async {
    if (_formKey.currentState!.validate()) {
      try {
        final cubit = context.read<EmployeeCubit>();

        await cubit.updateEmployee(
          employeeId: widget.employee.id,
          firstName: _firstNameController.text.trim(),
          secondName: _secondNameController.text.trim(),
          phone: _phoneController.text.trim(),
          department: _selectedDepartment,
        );

        Navigator.of(context).pop(true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating employee: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Employee'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter first name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _secondNameController,
                decoration: InputDecoration(
                  labelText: 'Second Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter second name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  if (value.length < 10) {
                    return 'Phone number must be at least 10 digits';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedDepartment,
                decoration: InputDecoration(
                  labelText: 'Department',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                items: _departments.map((String department) {
                  return DropdownMenuItem<String>(
                    value: department,
                    child: Text(department),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedDepartment = newValue;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a department';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _updateEmployee,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
          child: Text('Update'),
        ),
      ],
    );
  }
}
