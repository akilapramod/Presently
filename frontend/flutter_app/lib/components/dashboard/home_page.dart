import 'package:flutter/material.dart';
import 'package:flutter_app/components/dashboard/navbar.dart';
import 'package:flutter_app/components/scenario_selection/session_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_app/services/home_page/home_page_service.dart';
import 'package:flutter_app/utils/image_utils.dart'; // Add this import

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabase = Supabase.instance.client;
  final homePageService = HomePageService();
  String? firstName;
  String? avatarUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Provider.of<SessionProvider>(context, listen: false)
        .loadSessionsFromSupabase(); // load sessions from supabase
    _loadHomePageData();
  }

  Future<void> _loadHomePageData() async {
    setState(() => isLoading = true);

    try {
      final homePageData = await homePageService.getHomePageData();
      if (homePageData != null && mounted) {
        setState(() {
          firstName = homePageData['first_name'];
          avatarUrl = homePageData['avatar_url'];
        });
      }
    } catch (e) {
      print('Error loading home page data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showRenameDialog(String currentName) {
    final TextEditingController controller =
        TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rename Session'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter new name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: TextStyle(fontFamily: 'Roboto', color: Colors.black)),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty &&
                    controller.text != currentName) {
                  Provider.of<SessionProvider>(context, listen: false)
                      .renameSession(currentName, controller.text);
                }
                Navigator.pop(context);
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: Color(0xFF7400B8)),
              child: Text('Save',
                  style: TextStyle(fontFamily: 'Roboto', color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(String sessionName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Session'),
          content: Text('Are you sure you want to delete "$sessionName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<SessionProvider>(context, listen: false)
                    .deleteSession(sessionName);
                Navigator.pop(context);
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[300],
              backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
                  ? NetworkImage(avatarUrl!)
                  : null,
              child: (avatarUrl == null || avatarUrl!.isEmpty)
                  ? Icon(
                      Icons.person,
                      color: Colors.grey[700],
                      size: 40,
                    )
                  : null,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello ${firstName ?? 'User'},',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        'Let\'s ace your next presentation',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 15.0),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/scenario_sel');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF7400B8),
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Start Session', style: TextStyle(fontSize: 17)),
                ),
                SizedBox(width: 16), // Space between buttons
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/task_group_page');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    side: BorderSide(color: Colors.grey),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.list, size: 20),
                        SizedBox(width: 8),
                        Text('Tasks', style: TextStyle(fontSize: 17)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15.0),
            Expanded(child: Consumer<SessionProvider>(
                builder: (context, sessionProvider, child) {
              if (sessionProvider.sessions.isEmpty) {
                return Center(
                  child: Text(
                    'No sessions available! \nPlease start a new session',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontFamily: 'Roboto',
                    ),
                  ),
                );
              }
              return ListView.builder(
                itemCount: sessionProvider.sessions.length,
                itemBuilder: (context, index) {
                  return _buildCard(
                    title: sessionProvider.sessions[index],
                    navigateTo: '/summary',
                  );
                },
              );
            })),
          ],
        ),
      ),
      bottomNavigationBar: NavBar(
        selectedIndex: ModalRoute.of(context)?.settings.arguments != null
            ? (ModalRoute.of(context)?.settings.arguments
                    as Map<String, dynamic>)['selectedIndex'] ??
                0
            : 0,
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String navigateTo,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, navigateTo);
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                Icons.bookmark_border,
                color: Colors.grey,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Presentation | University',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                color: Colors.white,
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.grey,
                ),
                onSelected: (value) {
                  if (value == 'delete') {
                    _showDeleteConfirmation(title);
                  } else if (value == 'rename') {
                    _showRenameDialog(title);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'rename',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Rename',
                          style: TextStyle(
                              color: Colors.black, fontFamily: 'Roboto'),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18),
                        SizedBox(width: 8),
                        Text('Delete',
                            style: TextStyle(
                                color: Colors.black, fontFamily: 'Roboto')),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
