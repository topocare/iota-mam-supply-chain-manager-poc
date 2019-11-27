// response for fetching a mam-message from the tangle
class MamFetchResponse {
  final String root;
  final String nextRoot;
  final String payload;


  MamFetchResponse(this.root, this.nextRoot, this.payload, [bool log = false]) {
    if (log) {
      print(
          'MamFetchResponse:\n  root:     $root\n  nextRoot: $nextRoot\n  payload:  $payload');
    }
  }

  factory MamFetchResponse.byConcatString(String string, [bool log = false]) {
    return MamFetchResponse(string.substring(0, 81), string.substring(82, 163),
        string.substring(164), log);
  }
}
