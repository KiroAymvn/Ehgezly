import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/guest.dart';
import '../../providers/guest_provider.dart';
import 'add_guest_simple_dialog.dart';
import 'edit_guest_dialog.dart';

class AllGuestsScreen extends StatefulWidget {
  @override
  State<AllGuestsScreen> createState() => _AllGuestsScreenState();
}

class _AllGuestsScreenState extends State<AllGuestsScreen> {
  String _searchQuery = '';
  List<Guest> _filteredGuests = [];

  @override
  void initState() {
    super.initState();
    _filteredGuests = [];
  }

  @override
  Widget build(BuildContext context) {
    final guests = context.watch<GuestProvider>().allGuests;

    // Filter guests based on search query
    _filteredGuests = _searchQuery.isEmpty
        ? guests
        : guests.where((guest) {
      return guest.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          guest.phone.contains(_searchQuery) ||
          guest.email.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('All Guests'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
            tooltip: 'Search',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.person_add),
        label: Text('Add Guest'),
        onPressed: () => _addGuest(context),
      ),
      body: Column(
        children: [
          // Search results info
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Chip(
                    label: Text('Search: "$_searchQuery"'),
                    onDeleted: () {
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  ),
                  Spacer(),
                  Text(
                    '${_filteredGuests.length} result${_filteredGuests.length != 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

          // Guests list or empty state
          Expanded(
            child: _filteredGuests.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _searchQuery.isEmpty
                        ? Icons.people_outline
                        : Icons.search_off,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty
                        ? 'No guests yet'
                        : 'No guests found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    _searchQuery.isEmpty
                        ? 'Add your first guest'
                        : 'Try a different search',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  if (_searchQuery.isEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.person_add),
                        label: Text('Add First Guest'),
                        onPressed: () => _addGuest(context),
                      ),
                    ),
                ],
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _filteredGuests.length,
              itemBuilder: (ctx, i) {
                final guest = _filteredGuests[i];
                return _buildGuestCard(context, guest);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestCard(BuildContext context, Guest guest) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.indigo[100],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              guest.name[0].toUpperCase(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
          ),
        ),
        title: Text(
          guest.name,
          style: TextStyle(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
// Update the subtitle in _buildGuestCard method:
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              guest.phone,
              style: TextStyle(fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (guest.email.isNotEmpty)
              Text(
                guest.email,
                style: TextStyle(fontSize: 12, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            // Add birthday display
            if (guest.formattedBirthday != null)
              Text(
                '🎂 ${guest.formattedBirthday} (${guest.age} years)',
                style: TextStyle(fontSize: 12, color: Colors.orange[700]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert),
          onSelected: (value) => _handleMenuSelection(context, guest, value),
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Edit Guest'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'history',
              child: Row(
                children: [
                  Icon(Icons.history, size: 20, color: Colors.green),
                  SizedBox(width: 8),
                  Text('View History'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete Guest'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    final searchController = TextEditingController(text: _searchQuery);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Search Guests'),
        content: TextField(
          controller: searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search by name, phone, or email...',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            setState(() {
              _searchQuery = value;
            });
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
              });
              Navigator.pop(context);
            },
            child: Text('Clear'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _searchQuery = searchController.text;
              });
              Navigator.pop(context);
            },
            child: Text('Search'),
          ),
        ],
      ),
    );
  }

  Future<void> _addGuest(BuildContext context) async {
    final added = await showDialog<bool>(
      context: context,
      builder: (_) => AddGuestSimpleDialog(),
    );
    if (added == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Guest added successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _handleMenuSelection(BuildContext context, Guest guest, String value) async {
    switch (value) {
      case 'edit':
        await _editGuest(context, guest);
        break;
      case 'history':
        _viewGuestHistory(context, guest);
        break;
      case 'delete':
        await _deleteGuest(context, guest);
        break;
    }
  }

  Future<void> _editGuest(BuildContext context, Guest guest) async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (_) => EditGuestDialog(guest: guest),
    );
    if (updated == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Guest updated successfully'),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _viewGuestHistory(BuildContext context, Guest guest) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${guest.name}\'s Booking History'),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // You can implement booking history here
              // For now, show a placeholder
              Icon(Icons.history, size: 60, color: Colors.grey[300]),
              SizedBox(height: 16),
              Text(
                'Booking history feature coming soon',
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 8),
              Text(
                'Guest ID: ${guest.id}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
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

  Future<void> _deleteGuest(BuildContext context, Guest guest) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Guest'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete this guest?'),
            SizedBox(height: 8),
            Text(
              'This will also delete all reservations for this guest.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    guest.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(guest.phone),
                  if (guest.email.isNotEmpty) Text(guest.email),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      context.read<GuestProvider>().deleteGuest(guest.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Guest deleted successfully'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}