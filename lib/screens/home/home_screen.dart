import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../property/add_property_screen.dart';
import '../../services/firestore_service.dart';
import '../../main.dart';
import '../../models/property.dart';
import '../../widgets/category_card.dart';
import '../../widgets/property_card.dart';
import 'inspection_requests_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final FirestoreService _firestoreService = FirestoreService();

  String searchQuery = "";
  String selectedCategory = "";

  int? selectedBedrooms;
  int? selectedBathrooms;
  int? maxPrice;

  String selectedSort = "Recommended";

  String? userRole;
  bool isLoadingRole = true;

  @override
  void initState() {
    super.initState();
    getUserRole();
  }

  Future<void> getUserRole() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!mounted) return;

if (doc.exists) {
final data = doc.data();

setState(() {
userRole = data?['role'] ?? "tenant";
isLoadingRole = false;
});
} else {
setState(() {
userRole = "tenant";
isLoadingRole = false;
});
}
  } //
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    String greeting;

    final hour = DateTime.now().hour;

    if (hour < 12) {
      greeting = "Good Morning ☀️";
    } else if (hour < 17) {
      greeting = "Good Afternoon 🌤️";
    } else {
      greeting = "Good Evening 🌙";
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text("HomeLink"),
        centerTitle: true,
        actions: [

          if (userRole == "landlord" ||
              userRole == "agent" ||
              userRole == "admin")
            IconButton(
              icon: const Icon(Icons.assignment),
              tooltip: "Inspection Requests",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InspectionRequestsScreen(),
                  ),
                );
              },
            ),

          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              if (!context.mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const WelcomeScreen(),
                ),
                    (route) => false,
              );
            },
          ),
        ],
      ),
      floatingActionButton: isLoadingRole
          ? null
          : (userRole == "landlord" ||
          userRole == "agent" ||
          userRole == "admin")
          ? FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddPropertyScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      )
          : null,

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              greeting,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              user?.email ?? "",
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 25),

            Row(
              children: [

                Expanded(
                  child: TextField(
                    textInputAction: TextInputAction.search,
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                    onSubmitted: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search properties, location...",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            searchQuery = "";
                          });
                        },
                      )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                IconButton(
                  icon: const Icon(Icons.filter_list),
                  tooltip: "Filter",
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(25),
                        ),
                      ),
                      builder: (context) {
                        return Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              const Text(
                                "Filter Properties",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 20),

                              const Text("Sort By"),

                              DropdownButton<String>(
                                value: selectedSort,
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(
                                    value: "Recommended",
                                    child: Text("Recommended"),
                                  ),
                                  DropdownMenuItem(
                                    value: "Price Low to High",
                                    child: Text("Price: Low to High"),
                                  ),
                                  DropdownMenuItem(
                                    value: "Price High to Low",
                                    child: Text("Price: High to Low"),
                                  ),
                                  DropdownMenuItem(
                                    value: "Most Bedrooms",
                                    child: Text("Most Bedrooms"),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value == null) return;

                                  setState(() {
                                    selectedSort = value;
                                  });
                                },
                              ),

                              const SizedBox(height: 20),

                              const Text("Bedrooms"),

                              DropdownButton<int>(
                                value: selectedBedrooms,
                                hint: const Text("Any"),
                                isExpanded: true,
                                items: [1, 2, 3, 4, 5]
                                    .map(
                                      (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text("$e Bedroom"),
                                  ),
                                )
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedBedrooms = value;
                                  });
                                },
                              ),

                              const SizedBox(height: 20),

                              const Text("Bathrooms"),

                              DropdownButton<int>(
                                value: selectedBathrooms,
                                hint: const Text("Any"),
                                isExpanded: true,
                                items: [1, 2, 3, 4, 5]
                                    .map(
                                      (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text("$e Bathroom"),
                                  ),
                                )
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedBathrooms = value;
                                  });
                                },
                              ),

                              const SizedBox(height: 20),

                              const Text("Maximum Price"),

                              DropdownButton<int>(
                                value: maxPrice,
                                hint: const Text("No Limit"),
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(value: 100000, child: Text("₦100,000")),
                                  DropdownMenuItem(value: 250000, child: Text("₦250,000")),
                                  DropdownMenuItem(value: 500000, child: Text("₦500,000")),
                                  DropdownMenuItem(value: 1000000, child: Text("₦1,000,000")),
                                  DropdownMenuItem(value: 2000000, child: Text("₦2,000,000")),
                                  DropdownMenuItem(value: 5000000, child: Text("₦5,000,000")),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    maxPrice = value;
                                  });
                                },
                              ),

                              const SizedBox(height: 20),

                              Row(
                                children: [

                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          selectedSort = "Recommended";
                                          selectedBedrooms = null;
                                          selectedBathrooms = null;
                                          maxPrice = null;
                                        });

                                        Navigator.pop(context);
                                      },
                                      child: const Text("Reset"),
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Apply Filter"),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 15),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [

                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selectedCategory == "Apartment") {
                          selectedCategory = "";
                        } else {
                          selectedCategory = "Apartment";
                        }
                      });
                    },
                    child: CategoryCard(
                      icon: Icons.apartment,
                      title: "Apartment",
                      isSelected: selectedCategory == "Apartment",
                    ),
                  ),
                  const SizedBox(width: 10),

                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selectedCategory == "Duplex") {
                          selectedCategory = "";
                        } else {
                          selectedCategory = "Duplex";
                        }
                      });
                    },
                    child: CategoryCard(
                      icon: Icons.house,
                      title: "Duplex",
                      isSelected: selectedCategory == "Duplex",
                    ),
                  ),
                  const SizedBox(width: 10),

                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selectedCategory == "Hotel/Lodge") {
                          selectedCategory = "";
                        } else {
                          selectedCategory = "Hotel/Lodge";
                        }
                      });
                    },
                    child: CategoryCard(
                      icon: Icons.hotel,
                      title: "Hotel/Lodge",
                      isSelected: selectedCategory == "Hotel/Lodge",
                    ),
                  ),

                  const SizedBox(width: 10),

                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selectedCategory == "Self Contain") {
                          selectedCategory = "";
                        } else {
                          selectedCategory = "Self Contain";
                        }
                      });
                    },
                    child: CategoryCard(
                      icon: Icons.home,
                      title: "Self Contain",
                      isSelected: selectedCategory == "Self Contain",
                    ),
                  ),
                  const SizedBox(width: 10),

                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selectedCategory == "Shop") {
                          selectedCategory = "";
                        } else {
                          selectedCategory = "Shop";
                        }
                      });
                    },
                    child: CategoryCard(
                      icon: Icons.store,
                      title: "Shop",
                      isSelected: selectedCategory == "Shop",
                    ),
                  ),

                  const SizedBox(width: 10),

                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selectedCategory == "Office") {
                          selectedCategory = "";
                        } else {
                          selectedCategory = "Office";
                        }
                      });
                    },
                    child: CategoryCard(
                      icon: Icons.business,
                      title: "Office",
                      isSelected: selectedCategory == "Office",
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Featured Properties",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            StreamBuilder<QuerySnapshot>(
              stream: _firestoreService.getProperties(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return const Text("Something went wrong");
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text("No properties found");
                }

                final properties = snapshot.data!.docs
                    .map((doc) => Property.fromFirestore(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ))
                    .where((property) {
                  if (!property.available) {
                    return false;
                  }

                  final matchesSearch =
                      searchQuery.isEmpty ||
                          property.title.toLowerCase().contains(searchQuery) ||
                          property.location.toLowerCase().contains(searchQuery) ||
                          property.category.toLowerCase().contains(searchQuery) ||
                          property.description.toLowerCase().contains(searchQuery) ||
                          property.price.toString().contains(searchQuery) ||
                          property.bedrooms.toString().contains(searchQuery) ||
                          property.bathrooms.toString().contains(searchQuery);

                  final matchesCategory =
                      selectedCategory.isEmpty ||
                          property.category == selectedCategory;

                  final matchesBedrooms =
                      selectedBedrooms == null ||
                          property.bedrooms == selectedBedrooms;

                  final matchesBathrooms =
                      selectedBathrooms == null ||
                          property.bathrooms == selectedBathrooms;

                  final matchesPrice =
                      maxPrice == null ||
                          property.price <= maxPrice!;

                  return matchesSearch &&
                      matchesCategory &&
                      matchesBedrooms &&
                      matchesBathrooms &&
                      matchesPrice;
                })
                    .toList();

                switch (selectedSort) {
                  case "Price Low to High":
                    properties.sort(
                          (a, b) => a.price.compareTo(b.price),
                    );
                    break;

                  case "Price High to Low":
                    properties.sort(
                          (a, b) => b.price.compareTo(a.price),
                    );
                    break;

                  case "Most Bedrooms":
                    properties.sort(
                          (a, b) => b.bedrooms.compareTo(a.bedrooms),
                    );
                    break;

                  default:
                    break;
                }



                if (properties.isEmpty) {
                  return const Center(
                    child: Text("No available properties found"),
                  );
                }

                return Column(
                  children: properties.map((property) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: PropertyCard(property: property),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
