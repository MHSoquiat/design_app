import 'package:flutter/material.dart';
import 'package:design_app/uuid_summary.dart';

class ProductDetails extends StatefulWidget {
  final String uuid;
  final String productName;
  final String imageLink;
  final String price;
  final String rating;
  final int quantity;

  const ProductDetails(
      {Key? key,
      required this.uuid,
      required this.productName,
      required this.imageLink,
      required this.price,
      required this.rating,
      required this.quantity})
      : super(key: key);

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  bool isBottomSheetVisible = true; // Track if BottomSheet is open

  @override
  void initState() {
    super.initState();
    // Show BottomSheet when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showProductDetailsBottomSheet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.uuid}'),
      ),
      body: Stack(
        children: [
          // Fullscreen Zoomable Image
          InteractiveViewer(
            boundaryMargin: const EdgeInsets.all(20),
            minScale: 1.0,
            maxScale: 4.0,
            child: Center(
              child: Image.network(
                widget.imageLink,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          ),
          // Floating button to reopen BottomSheet
          if (!isBottomSheetVisible)
            Positioned(
              bottom: 30,
              right: 20,
              child: FloatingActionButton.extended(
                onPressed: () {
                  showProductDetailsBottomSheet();
                },
                icon: const Icon(Icons.info_outline),
                label: const Text("Show Details"),
                backgroundColor: Colors.blueAccent,
              ),
            ),
        ],
      ),
    );
  }

  /// Show the BottomSheet with Product Details
  void showProductDetailsBottomSheet() {
    setState(() {
      isBottomSheetVisible = true;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.6, // Make BottomSheet larger
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 50,
                  height: 5,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Text(
                  widget.productName,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text('UUID: ${widget.uuid}',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Text('Price: ${widget.price}',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Text('Quantity: ${widget.quantity}'),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to summary page with UUID count
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UuidSummaryPage(),
                      ),
                    );
                  },
                  child: Text("View Summary"),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                      _buildStarRating(double.tryParse(widget.rating) ?? 0.0),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close BottomSheet
                    setState(() {
                      isBottomSheetVisible = false; // Show Floating Button
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                  ),
                  child: const Text("Close", style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      setState(() {
        isBottomSheetVisible = false; // Show Floating Button when dismissed
      });
    });
  }

  /// Generate star rating icons
  List<Widget> _buildStarRating(double rating) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;

    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        stars.add(const Icon(Icons.star, color: Colors.amber, size: 30));
      } else if (i == fullStars && hasHalfStar) {
        stars.add(const Icon(Icons.star_half, color: Colors.amber, size: 30));
      } else {
        stars.add(const Icon(Icons.star_border, color: Colors.amber, size: 30));
      }
    }
    return stars;
  }
}
