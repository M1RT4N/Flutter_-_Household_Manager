import 'package:cloud_firestore/cloud_firestore.dart';

typedef DocumentDeserializer<T> = T Function(Map<String, dynamic> json);
typedef DocumentSerializer<T> = Map<String, dynamic> Function(T data);

class DatabaseService<T> {
  final CollectionReference<T> _reference;

  CollectionReference<T> get reference => _reference;

  DatabaseService(
    String collectionName, {
    required DocumentDeserializer<T> fromJson,
    required DocumentSerializer<T> toJson,
  }) : _reference = FirebaseFirestore.instance
            .collection(collectionName)
            .withConverter(
              fromFirestore: (snapshot, _) =>
                  _deserializeJsonDocument(snapshot, fromJson),
              toFirestore: (value, _) => _serializeJsonDocument(value, toJson),
            );

  /// Creates a new document in collection with random ID
  Future<void> add(T data) async {
    await _reference.add(data);
  }

  /// Replaces all data of a specific document. If it does not exist, new document (with the specified ID) is created
  Future<void> setOrAdd(String id, T data) async {
    await _reference.doc(id).set(data);
  }

  /// Returns a stream of all documents in the collection
  Stream<List<T>> observeDocuments() {
    return _reference.snapshots().map(_mapQuerySnapshotToData);
  }

  /// Observes a single document in collection with specific ID
  Stream<T?> observeDocument(String id) {
    return _reference
        .doc(id)
        .snapshots()
        .map((documentSnapshot) => documentSnapshot.data());
  }

  /// Observes all documents, whose ID is in the set of [ids].
  Stream<List<T>> observeDocumentsByIds(Set<String> ids) {
    if (ids.isEmpty) {
      return Stream.value([]);
    }

    return _reference
        .where(FieldPath.documentId, whereIn: ids)
        .snapshots()
        .map(_mapQuerySnapshotToData);
  }

  /// Returns a list of all documents in collection
  Future<List<T>> getDocuments() async {
    final documentsSnapshot = await _reference.get();
    return _mapQuerySnapshotToData(documentsSnapshot);
  }

  /// Returns a single document in collection with specific ID
  Future<T?> getDocument(String id) async {
    final documentData = await _reference.doc(id).get();
    return documentData.data();
  }

  /// Observes all documents, whose ID is in the set of [ids].
  Future<List<T>> getDocumentsByIds(Set<String> ids) async {
    if (ids.isEmpty) {
      return [];
    }

    final documentsSnapshot =
        await _reference.where(FieldPath.documentId, whereIn: ids).get();
    return _mapQuerySnapshotToData(documentsSnapshot);
  }

  List<T> _mapQuerySnapshotToData(QuerySnapshot<T> snapshot) {
    return snapshot.docs
        .map((documentSnapshot) => documentSnapshot.data())
        .toList();
  }
}

T _deserializeJsonDocument<T>(DocumentSnapshot<Map<String, dynamic>> document,
    DocumentDeserializer<T> deserializer) {
  final json = document.data()!..['id'] = document.id;
  return deserializer(json);
}

Map<String, dynamic> _serializeJsonDocument<T>(
    T data, DocumentSerializer<T> serializer) {
  final json = serializer(data)..remove('id');
  return json;
}
