import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/pg_card.dart'; // Ensure the PGCard is correctly implemented and imported
import 'Pg.dart';

class CategoryPGListScreen extends StatefulWidget {
  final String category; // Updated to accept category for better filtering

  const CategoryPGListScreen({required this.category, Key? key}) : super(key: key);

  @override
  _CategoryPGListScreenState createState() => _CategoryPGListScreenState();
}

class _CategoryPGListScreenState extends State<CategoryPGListScreen> {
  List<Map<String, dynamic>> pgList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPGsByCategory();
  }

  Future<void> _fetchPGsByCategory() async {
    try {
      Query query = FirebaseFirestore.instance.collection('pgs');

      // Apply category-based filtering
      switch (widget.category) {
        case 'Boys':
          query = query.where('gender', whereIn: ['Boys', 'Both']);
          break;
        case 'Girls':
          query = query.where('gender', whereIn: ['Girls', 'Both']);
          break;
        case 'AC':
          query = query.where('ac', isEqualTo: 'Available');
          break;
        case 'Non AC':
          query = query.where('ac', isEqualTo: 'Not Available');
          break;
        case 'Single':
          query = query.where('sharing', isEqualTo: 'Single');
          break;
        case 'Double':
          query = query.where('sharing', isEqualTo: 'Double');
          break;
        default:
        // If no category matches, return all PGs
          break;
      }

      QuerySnapshot snapshot = await query.get();
      List<DocumentSnapshot> docs = snapshot.docs;
      List<Map<String, dynamic>> pgs = [];

      for (var doc in docs) {
        Map<String, dynamic> pgData = doc.data() as Map<String, dynamic>;
        List<String> images = List<String>.from(pgData['images']);

        // Check if images list is not empty
        if (images.isNotEmpty) {
          pgs.add({
            'id': doc.id,
            'name': pgData['name'],
            'summary': pgData['summary'],
            'image': images.first, // Safely access the first image
          });
        }
      }

      setState(() {
        pgList = pgs;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching PGs by category: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} PGs'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : pgList.isEmpty
          ? Center(child: Text('No PGs available for this category.'))
          : ListView.builder(
        itemCount: pgList.length,
        itemBuilder: (context, index) {
          final pg = pgList[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Pg(pgId: pg['id']),
                ),
              );
            },
            child: HotelCard(
              name: pg['name'],
              summary: pg['summary'],
              imageUrls: [pg['image']],
              // Assuming PgCard has the following parameters
              onEdit: () {},
              onDelete: () {},
            ),
          );
        },
      ),
    );
  }
}
