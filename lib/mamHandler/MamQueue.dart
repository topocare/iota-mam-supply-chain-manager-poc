import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';

import 'MamFetchResponse.dart';
import 'MamSendResponse.dart';

export 'MamFetchResponse.dart';
export 'MamSendResponse.dart';

/// Fetches and sends IOTA MAM messages.
/// Processes one send/fetch after another.
///
/// uses a [WebView] to run the mam.web.min.js
/// the WebView needs to exist before any other methods are called
///
///
/// should be replaced with a more efficient solution
class MamQueue {
 /* processing of a command:
  * - call of sendMessage or fetchMessage
  * - _processMessage queues the command as MamCommand to the mamCommandQueue
  * - messages in the mamCommandQueue are added to webView via _nextInQueue
  * - results are returned to the MamCommand via the javaScriptChannels
  * - command is re-evaluted by _processMessage regarding retries
  * - the MamFetch/SendResponse is returned (or an error) via the Future created by the MamCommand
  */



  static const String defaultNode = 'https://nodes.devnet.thetangle.org:443';
  static const String _defaultSideKey = "SIDEKEY";
  bool loggingEnabled = true;

  MamQueue() {
    mamCommandQueue = Queue<MamCommand>();
  }

  //the javascript file(s) in string-form for
  String jsFiles;

  // the current MamCommand to be executed
  MamCommand currentMamCommand;

  // queue of MamCommands waiting to be executed
  Queue<MamCommand> mamCommandQueue;

  // the WebViewController to run the js
  WebViewController _webViewController;

  //callback channel for successfully send messages
  JavascriptChannel sendSuccessChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'sendSuccessChannel',
        onMessageReceived: (JavascriptMessage message) {
          //print('mamQueue: got Success: ${message.message}');
          if (currentMamCommand != null) {
            currentMamCommand.handleSuccess(message.message);
            _removeAndNextInQueue();
          }
        });
  }

  //callback channel for successfully fetched messages
  JavascriptChannel fetchSuccessChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'fetchSuccessChannel',
        onMessageReceived: (JavascriptMessage message) {
          if (currentMamCommand != null) {
            currentMamCommand.handleSuccess(message.message);
            _removeAndNextInQueue();
          }
        });
  }

  //callback channel for errors within mam.js
  JavascriptChannel errorChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'errorChannel',
        onMessageReceived: (JavascriptMessage message) {
          print('mamQueue: got Error: ${message.message}');
          if (currentMamCommand != null) {
            currentMamCommand.handleError(message.message);
            _removeAndNextInQueue();
          }
        });
  }

  // adds a mam-command to the queue, also providing the completer to generate the response callback
  Future<String> _addToQueue(String command) async {
    Completer<String> completer = Completer<String>();
    mamCommandQueue.add(MamCommandFuture(command, completer));
    _nextInQueue();
    return completer.future;
  }

  // executes the next command in the queue using the javascript. the result is provided vial the JavascriptChannel
  void _nextInQueue() async {
    if (currentMamCommand == null && mamCommandQueue.isNotEmpty) {
      currentMamCommand = mamCommandQueue.removeFirst();

      jsFiles = await _loadJavaScriptFiles();
      _webViewController.evaluateJavascript('$jsFiles ${currentMamCommand.command}');
    }
  }

  // deletes the current command and runs the next in queue
  void _removeAndNextInQueue() {
    currentMamCommand = null;
    _nextInQueue();
  }

  // sends a specific payload to a specific mam-seed (with a specific mamStartIndex)
  // messages are send/fetched one at a time
  // WARNING: do not send multiple messages for the same seed (=channel) without incrementing the mamStartIndex
  Future<MamSendResponse> sendMessage(
      String seed, int mamStartIndex, String payload,
      {String sideKey = _defaultSideKey,
      int securityLevel = 2,
      String node,
      int maxAttempts = 3}) async {
    if (node == null) {
      node = defaultNode;
    }
    return MamSendResponse.byConcatString(
        await _processMamMessage(
            "sendPayload('$node', '$seed', $mamStartIndex, '$payload', '$sideKey', $securityLevel)",
            maxAttempts),
        loggingEnabled);
  }

  // fetches a the payload from a specific mam-root
  // messages are send/fetched one at a time
  Future<MamFetchResponse> fetchMessage(String root,
      {String sideKey = _defaultSideKey,
      String node,
      int maxAttempts = 3}) async {
    if (node == null) {
      node = defaultNode;
    }
    return MamFetchResponse.byConcatString(
        await _processMamMessage(
            "getPayload('$node', '$root', '$sideKey')", maxAttempts),
        loggingEnabled);
  }

  // concats a js command to the js-string loaded from the files and queues it for processing in [mamCommandQueue]
  // [maxAttempts] defines the maximal number of retries before an error is thrown
  // [simulateErrors] defines a number of errors provoked in the js script to test error handling.
  // if [simulateErrors] > [maxAttempts] it will always fail
  Future<String> _processMamMessage(String stringForJS, int maxAttempts,
      {int simulateErrors: 0}) async {
    String result;
    bool success = false;
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      //print('attempt: ${attempt} of $maxAttempts');
      try {
        if (attempt > simulateErrors) {
          result = await _addToQueue(stringForJS);
        } else {
          result = await _addToQueue("provokeError()");
        }
        success = true;
        break;
      } catch (e) {
        result = '$e';
      }
    }
    if (!success) {
      print("MamQueue:\nError in mam.min.web.js:\n$result");
      throw "MamQueue:\nError in mam.min.web.js:\n$result";
    }
    return result;
  }

  // provokes an error in the javascript files, for testing error handling
  Future<MamSendResponse> _provokeSendError(
      [String seed,
      int mamStartIndex,
      String payload,
      String sideKey = _defaultSideKey,
      int securityLevel = 2,
      String node]) async {
    return MamSendResponse.byConcatString(
        await _addToQueue("provokeError()"), loggingEnabled);
  }

  // loads the mam library and the adapter from files
  Future<String> _loadJavaScriptFiles() async {
    String str = "";
    str += await rootBundle.loadString('assets/mam.web.min.js');
    str += " ";
    str += await rootBundle.loadString('assets/webViewAdapter.js');
    return str;
  }

  /// Provides a WebView widget, needed to process the mam-requests.
  /// the widget need not be visible, but must be rendered, for example hidden behind the UI
  Widget getWidget(BuildContext context) {
    return WebView(
      javascriptMode: JavascriptMode.unrestricted,
      javascriptChannels: <JavascriptChannel>[
        sendSuccessChannel(context),
        fetchSuccessChannel(context),
        errorChannel(context),
      ].toSet(),
      onWebViewCreated: (WebViewController webViewController) {
        _webViewController = webViewController;
      },
      debuggingEnabled: true,
    );
  }
}

// a command used with MamQueue to queue individual js calls
abstract class MamCommand {
  final String command;

  MamCommand(this.command);

  void handleSuccess(String str);

  void handleError(String str);
}

// specific implementation of MamCommand, using a completer to convert callback to future<response>
class MamCommandFuture extends MamCommand {
  final Completer<String> completer;

  MamCommandFuture(String command, this.completer) : super(command);

  @override
  void handleSuccess(String str) {
    completer.complete(str);
  }

  @override
  void handleError(String str) {
    Exception e = Exception(str);
    completer.completeError(e, null);
  }
}
