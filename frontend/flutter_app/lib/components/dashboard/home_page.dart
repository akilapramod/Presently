import 'package:flutter/material.dart';
import 'package:flutter_app/components/dashboard/navbar.dart';
import 'package:flutter_app/components/scenario_selection/session_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Provider.of<SessionProvider>(context, listen: false).loadSessionsFromSupabase();
  } // load sessions from supabase
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text('Hello Mariah,'),
        automaticallyImplyLeading: false,
        actions: [
      IconButton(
      icon: CircleAvatar(
      radius: 40,
        backgroundImage: NetworkImage(
          'https://via.placeholder.com/150',
        ),
      ),
      onPressed: () {
      },
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
                        'Hello Mariah,',
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
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
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

            Expanded(
              child: Consumer<SessionProvider>(
                builder: (context, sessionProvider, child){
                  if(sessionProvider.sessions.isEmpty){
                    return Center(
                      child: Text(
                        'No sessions available! Please start a new session',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.grey,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: sessionProvider.sessions.length,
                    itemBuilder: (context, index){
                      return _buildCard(
                        title: sessionProvider.sessions[index],
                        navigateTo: '/summary',
                      );
                    },
                  );
                }
              )
            ),
          ],
        ),
      ),
      bottomNavigationBar: const NavBar (selectedIndex: 0,),
    );
  }

  Widget _buildCard({
    required String title,
    required String navigateTo,
  }) {
    return GestureDetector(
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
            Icon(
              Icons.more_vert,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}