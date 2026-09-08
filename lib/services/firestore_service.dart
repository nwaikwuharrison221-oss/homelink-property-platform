import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Properties Collection
  CollectionReference get properties =>
      _firestore.collection('properties');

  /// Users Collection
  CollectionReference get users =>
      _firestore.collection('users');

  /// Favorites Collection
  CollectionReference get favorites =>
      _firestore.collection('favorites');

  /// Add Property
  Future<DocumentReference> addProperty(
      Map<String, dynamic> propertyData) async {
    return await properties.add(propertyData);
  }

  /// Update Property
  Future<void> updateProperty(
      String propertyId,
      Map<String, dynamic> propertyData) async {
    await properties.doc(propertyId).update(propertyData);
  }

  /// Delete Property
  Future<void> deleteProperty(String propertyId) async {
    await properties.doc(propertyId).delete();
  }

  /// Get All Properties
  Stream<QuerySnapshot> getProperties() {
    return properties.snapshots();
  }

  /// Get One Property
  Future<DocumentSnapshot> getProperty(String propertyId) async {
    return await properties.doc(propertyId).get();
  }

  /// Get properties belonging to one landlord
  Stream<QuerySnapshot> getMyProperties(String ownerId) {
    return properties
        .where('ownerId', isEqualTo: ownerId)
        .snapshots();
  }

  /// Add Property to Favorites
  Future<void> addToFavorites({
    required String userId,
    required String propertyId,
  }) async {
    await favorites.doc("${userId}_$propertyId").set({
      "userId": userId,
      "propertyId": propertyId,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  /// Remove Property from Favorites
  Future<void> removeFromFavorites({
    required String userId,
    required String propertyId,
  }) async {
    await favorites.doc("${userId}_$propertyId").delete();
  }

  /// Get User Favorites
  Stream<QuerySnapshot> getFavorites(String userId) {
    return favorites
        .where("userId", isEqualTo: userId)
        .snapshots();
  }

  /// Book Inspection
  Future<void> bookInspection({
    required String propertyId,
    required String tenantId,
    required String landlordId,
    required String propertyTitle,
  }) async {
    await inspectionRequests.add({
      "propertyId": propertyId,
      "tenantId": tenantId,
      "landlordId": landlordId,
      "propertyTitle": propertyTitle,
      "status": "Pending",
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  /// Inspection Requests Collection
  CollectionReference get inspectionRequests =>
      _firestore.collection('inspection_requests');

  /// Get Property by ID
  Future<DocumentSnapshot> getPropertyById(String propertyId) async {
    return await properties.doc(propertyId).get();
  }

  /// Get Inspection Requests for a Landlord
  Stream<QuerySnapshot> getInspectionRequests(String landlordId) {
    return inspectionRequests
        .where("landlordId", isEqualTo: landlordId)
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  /// Update Inspection Status
  Future<void> updateInspectionStatus({
    required String requestId,
    required String status,
  }) async {
    await inspectionRequests.doc(requestId).update({
      "status": status,
    });
  }

  /// Check if Property is Favorite
  Stream<bool> isFavorite({
    required String userId,
    required String propertyId,
  }) {
    return favorites
        .doc("${userId}_$propertyId")
        .snapshots()
        .map((doc) => doc.exists);
  }
}