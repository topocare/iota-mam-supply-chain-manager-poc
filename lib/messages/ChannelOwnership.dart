import 'dart:math';

import 'package:supply_chain_manager/trytes/defines.dart';

/// Contains the required Data for a MAM channel.
/// Can generate random seed for new channels.
class ChannelOwnership{

  String _seed;
  int mamStartIndex = 0;
  int databaseId;

  String get seed => _seed;

  ChannelOwnership(this._seed, [this.mamStartIndex = 0, this.databaseId]);
  ChannelOwnership.generate() {
    String tmpSeed = "";
    for (int i = 0; i < 81; i++) {
      tmpSeed+=tryteAlphabet[Random.secure().nextInt(26)];
    }
    _seed = tmpSeed;
  }
}