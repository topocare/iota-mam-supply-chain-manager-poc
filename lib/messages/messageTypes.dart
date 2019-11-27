import 'ChannelOwnership.dart';

/// first message on a channel, defining it.
/// if the channel is owned, the [ownership] specifies data required to publish data on it.
abstract class ChannelDefiningObject extends MamMessage {
  ChannelOwnership ownership;

  ChannelDefiningObject(String root, String nextRoot, [this.ownership])
      : super(root, nextRoot);
}

/// subset of [MamMessage], can be published on a [Product]'s channel
abstract class ProductUpdate extends MamMessage {
  ProductUpdate(String root, String nextRoot) : super(root, nextRoot);
}

/// minimal properties of a MAM-Message.
abstract class MamMessage {
  String root;
  String nextRoot;

  MamMessage(this.root, this.nextRoot);
}