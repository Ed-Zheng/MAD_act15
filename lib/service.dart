import 'package:cloud_firestore/cloud_firestore.dart';
import 'item.dart';

class FirestoreService {
  // TODO: Create collection reference for 'items'
  final CollectionReference itemsCollection =
      FirebaseFirestore.instance.collection('items');

  // TODO: Implement addItem method
  Future<void> addItem(Item item) async {
    // TODO: Convert item to map and add to collection
    await itemsCollection.add(item.toMap());
  }

  // TODO: Implement getItemsStream method
  Stream<List<Item>> getItemsStream() {
    // TODO: Return stream of items from Firestore
    return itemsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
          .map((doc) =>
            Item.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList());
  }

  // TODO: Implement updateItem method
  Future<void> updateItem(Item item) async {
    // TODO: Update specific document by ID
    if (item.id == null) return;
    await itemsCollection.doc(item.id).update(item.toMap());
  }

  // TODO: Implement deleteItem method
  Future<void> deleteItem(String itemId) async {
    // TODO: Delete document by ID
    await itemsCollection.doc(itemId).delete();
  }
}
