// response for sending a mam-message to the tangle
class MamSendResponse {
  final String root;
  final String nextRoot;
  final String address;
  final String payload;

  MamSendResponse(this.address, this.root, this.nextRoot, this.payload,
      [bool log = false]) {
    if (log) {
      print(
          'MamSendResponse:\n  address:  $address\n  root:     $root\n  nextRoot: $nextRoot\n  payload:  $payload');
    }
  }

  factory MamSendResponse.byConcatString(String string, [bool log = false]) {
    return MamSendResponse(string.substring(0, 81), string.substring(82, 163),
        string.substring(164, 245), string.substring(246), log);
  }
}
