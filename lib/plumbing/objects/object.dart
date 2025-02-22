import 'dart:convert';
import 'dart:typed_data';

import 'package:charcode/charcode.dart';
import 'package:collection/collection.dart';

import 'package:dart_git/exceptions.dart';
import 'package:dart_git/plumbing/git_hash.dart';
import 'package:dart_git/plumbing/objects/blob.dart';
import 'package:dart_git/plumbing/objects/commit.dart';
import 'package:dart_git/plumbing/objects/tree.dart';
import 'package:dart_git/utils/result.dart';

abstract class GitObject {
  Uint8List serialize() {
    var data = serializeData();

    final bytesBuilder = BytesBuilder(copy: false);
    bytesBuilder
      ..add(format())
      ..addByte($space)
      ..add(ascii.encode(data.length.toString()))
      ..addByte(0x0)
      ..add(data);

    //assert(GitHash.compute(result) == hash());
    return bytesBuilder.toBytes();
  }

  Uint8List serializeData();
  Uint8List format();
  String formatStr();

  GitHash get hash;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GitObject && _listEq(serialize(), other.serialize());

  @override
  int get hashCode => hash.hashCode;
}

Function _listEq = const ListEquality().equals;

Result<GitObject> createObject(int type, Uint8List rawData, GitHash? hash) {
  switch (type) {
    case ObjectTypes.COMMIT:
      // FIXME: Handle the case of this being null
      var obj = GitCommit.parse(rawData, hash)!;
      return Result(obj);

    case ObjectTypes.TREE:
      var obj = GitTree(rawData, hash);
      return Result(obj);

    case ObjectTypes.BLOB:
      var obj = GitBlob(rawData, hash);
      return Result(obj);

    default:
      var typeStr = ObjectTypes.getTypeString(type);
      return Result.fail(GitObjectInvalidType(typeStr));
  }
}

abstract class ObjectTypes {
  static const String BLOB_STR = 'blob';
  static const String TREE_STR = 'tree';
  static const String COMMIT_STR = 'commit';
  static const String TAG_STR = 'tag';
  static const String OFS_DELTA_STR = 'ofs_delta';
  static const String REF_DELTA_STR = 'ref_delta';

  static const int COMMIT = 1;
  static const int TREE = 2;
  static const int BLOB = 3;
  static const int TAG = 4;
  static const int OFS_DELTA = 6;
  static const int REF_DELTA = 7;

  static String getTypeString(int type) {
    switch (type) {
      case COMMIT:
        return COMMIT_STR;
      case TREE:
        return TREE_STR;
      case BLOB:
        return BLOB_STR;
      case TAG:
        return TAG_STR;
      case OFS_DELTA:
        return OFS_DELTA_STR;
      case REF_DELTA:
        return REF_DELTA_STR;
      default:
        throw Exception('unsupported pack type $type');
    }
  }

  static int getType(String type) {
    switch (type) {
      case COMMIT_STR:
        return COMMIT;
      case TREE_STR:
        return TREE;
      case BLOB_STR:
        return BLOB;
      case TAG_STR:
        return TAG;
      case OFS_DELTA_STR:
        return OFS_DELTA;
      case REF_DELTA_STR:
        return REF_DELTA;
      default:
        throw Exception('unsupported pack type $type');
    }
  }
}
