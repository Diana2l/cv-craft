import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fs = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  String _searchQuery = '';
  bool _loadingAction = false;
  String _currentUid = '';

  @override
  void initState() {
    super.initState();
    _currentUid = _auth.currentUser?.uid ?? '';
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    // Ensure current user has admin claim; otherwise you may redirect away.
    if (_auth.currentUser == null) return;
    final idTokenResult = await _auth.currentUser!.getIdTokenResult(true);
    final role = idTokenResult.claims?['role'];
    if (role != 'admin') {
      // Not admin - show dialog and pop or navigate away
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Access denied'),
            content: Text('You are not an admin.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).maybePop();
                },
                child: Text('OK'),
              ),
            ],
          ),
          barrierDismissible: false,
        );
      });
    }
  }

  Future<void> _deleteUser(String uid) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete user?'),
        content: Text('This will permanently delete the user and their account.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _loadingAction = true);
    try {
      final callable = _functions.httpsCallable('deleteUser');
      final res = await callable.call({'uid': uid});
      if (res.data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User deleted')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed'), backgroundColor: Colors.red));
      }
    } on FirebaseFunctionsException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Function error'), backgroundColor: Colors.red));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unexpected error: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() => _loadingAction = false);
    }
  }

  Future<void> _setUserRole(String uid, String role) async {
    setState(() => _loadingAction = true);
    try {
      final callable = _functions.httpsCallable('setUserRole');
      final res = await callable.call({'uid': uid, 'role': role});
      if (res.data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Role updated')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed'), backgroundColor: Colors.red));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() => _loadingAction = false);
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _usersStream() {
    // Basic query — order by createdAt if available
    return _fs.collection('users').orderBy('createdAt', descending: true).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Refresh roles/token',
            onPressed: () async {
              // Force refresh token so claims update quickly
              await _auth.currentUser?.getIdTokenResult(true);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Refreshed')));
            },
            icon: Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async {
              await _auth.signOut();
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.logout),
          ),
        ],
        backgroundColor: Colors.teal[700],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal[700]),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: _auth.currentUser?.photoURL != null ? NetworkImage(_auth.currentUser!.photoURL!) : null,
                    child: _auth.currentUser?.photoURL == null ? Icon(Icons.admin_panel_settings, size: 36) : null,
                    backgroundColor: Colors.white24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_auth.currentUser?.displayName ?? 'Admin', style: TextStyle(color: Colors.white, fontSize: 18)),
                        Text(_auth.currentUser?.email ?? '', style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Users'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.bar_chart),
              title: Text('Stats (coming soon)'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Top summary / quick stats
              Container(
                color: Colors.teal[50],
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: _fs.collection('users').snapshots(),
                        builder: (ctx, snap) {
                          final total = snap.data?.docs.length ?? 0;
                          return _StatCard(title: 'Total users', value: '$total');
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(child: _StatCard(title: 'Admins', valueWidget: FutureBuilder<int>(
                      future: _countAdmins(),
                      builder: (ctx, s) {
                        if (!s.hasData) return Text('—', style: TextStyle(fontSize: 20));
                        return Text('${s.data}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
                      },
                    ))),
                  ],
                ),
              ),

              // Search bar
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search users by name or email',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
                ),
              ),

              // Users list
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _usersStream(),
                  builder: (ctx, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final docs = snapshot.data?.docs ?? [];

                    final filtered = docs.where((d) {
                      final data = d.data();
                      final name = (data['displayName'] ?? '').toString().toLowerCase();
                      final email = (data['email'] ?? '').toString().toLowerCase();
                      if (_searchQuery.isEmpty) return true;
                      return name.contains(_searchQuery) || email.contains(_searchQuery);
                    }).toList();

                    if (filtered.isEmpty) {
                      return Center(child: Text('No users found.'));
                    }

                    return ListView.builder(
                      padding: EdgeInsets.all(12),
                      itemCount: filtered.length,
                      itemBuilder: (context, idx) {
                        final doc = filtered[idx];
                        final data = doc.data();
                        final uid = doc.id;
                        final email = data['email'] ?? '';
                        final name = data['displayName'] ?? '';
                        final role = data['role'] ?? 'user';
                        final photo = data['photoURL'] ?? null;
                        final createdAt = data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : null;

                        return Card(
                          elevation: 2,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage: photo != null ? CachedNetworkImageProvider(photo) : null,
                                  child: photo == null ? Icon(Icons.person) : null,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(name.isNotEmpty ? name : email, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                      SizedBox(height: 4),
                                      Text(email, style: TextStyle(color: Colors.black54)),
                                      SizedBox(height: 6),
                                      Wrap(
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        spacing: 8,
                                        children: [
                                          Chip(label: Text(role.toString().toUpperCase()), backgroundColor: role == 'admin' ? Colors.orange[100] : Colors.blue[50]),
                                          if (createdAt != null) Text('${createdAt.year}-${createdAt.month.toString().padLeft(2,'0')}-${createdAt.day.toString().padLeft(2,'0')}',
                                              style: TextStyle(color: Colors.black45, fontSize: 13)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    // Change role button
                                    PopupMenuButton<String>(
                                      onSelected: (value) async {
                                        if (value == 'toggle') {
                                          final newRole = role == 'admin' ? 'user' : 'admin';
                                          await _setUserRole(uid, newRole);
                                        } else if (value == 'view') {
                                          // Optionally view details
                                          _showUserDetails(context, data, uid);
                                        }
                                      },
                                      itemBuilder: (ctx) => [
                                        PopupMenuItem(value: 'view', child: Text('View details')),
                                        PopupMenuItem(value: 'toggle', child: Text(role == 'admin' ? 'Set as user' : 'Set as admin')),
                                      ],
                                      icon: Icon(Icons.more_vert),
                                    ),
                                    SizedBox(height: 8),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400),
                                      onPressed: _loadingAction || uid == _currentUid
                                          ? null
                                          : () async {
                                              await _deleteUser(uid);
                                            },
                                      child: Text('Delete'),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              )
            ],
          ),

          if (_loadingAction)
            Container(
              color: Colors.black45,
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Future<int> _countAdmins() async {
    final snap = await _fs.collection('users').where('role', isEqualTo: 'admin').get();
    return snap.docs.length;
  }

  void _showUserDetails(BuildContext context, Map<String, dynamic> user, String uid) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(user['displayName'] ?? user['email'] ?? 'User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (user['photoURL'] != null) Image.network(user['photoURL'], height: 80),
            SizedBox(height: 8),
            Text('Email: ${user['email'] ?? '-'}'),
            SizedBox(height: 6),
            Text('Role: ${user['role'] ?? 'user'}'),
            SizedBox(height: 6),
            Text('UID: $uid', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Close')),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String? value;
  final Widget? valueWidget;

  const _StatCard({Key? key, required this.title, this.value, this.valueWidget}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final display = valueWidget ?? Text(value ?? '—', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(color: Colors.black54)),
        SizedBox(height: 8),
        display,
      ]),
    );
  }
}
