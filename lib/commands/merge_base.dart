import 'dart:io';

import 'package:args/command_runner.dart';

import 'package:dart_git/git.dart';
import 'package:dart_git/git_hash.dart';
import 'package:dart_git/plumbing/objects/commit.dart';

class MergeBaseCommand extends Command {
  @override
  final name = 'merge-base';

  @override
  final description = 'Find as good common ancestors as possible for a merge';

  @override
  Future run() async {
    var args = argResults!.rest;
    if (args.length != 2) {
      print('Incorrect usage');
      return;
    }

    var gitRootDir = GitRepository.findRootDir(Directory.current.path)!;
    var repo = await GitRepository.load(gitRootDir);

    var aHash = GitHash(args[0]);
    var bHash = GitHash(args[1]);

    var aRes = await repo.objStorage.readObjectFromHash(aHash);
    var bRes = await repo.objStorage.readObjectFromHash(bHash);

    var a = aRes.get();
    var b = bRes.get();

    var commits = await repo.mergeBase(a as GitCommit, b as GitCommit);
    for (var c in commits) {
      print(c.hash);
    }
  }
}
