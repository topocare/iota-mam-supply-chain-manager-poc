import 'package:supply_chain_manager/mamHandler/MamQueue.dart';
import 'package:supply_chain_manager/messages/MamMessageTypeHandler.dart';
import 'package:supply_chain_manager/messages/messageTypes.dart';

/// Buffer for fetched MAM messages
/// makes sure no message needs to be fetched twice
class MamBuffer {
  MamQueue _mamQueue;
  Map<String, Future<MamMessage>> _buffer =  Map<String, Future<MamMessage>>();

  MamBuffer(this._mamQueue);


  Future<MamMessage> getMessage(String root) async{
    bool requestNeeded = false;
    if (!_buffer.containsKey(root)) {
      requestNeeded = true;
    } else {
      if (_buffer[root] == null)
        requestNeeded =  true;
    }
    if (requestNeeded) {
      _buffer[root] = _getMessage(root);
      _emptyMessageCheck(root, _buffer[root]);
    }
    return _buffer[root];
  }

  // checks of message is of specific type first
  Future<T> getTypedMessage<T>(String root) async{
    MamMessage message = await getMessage(root);
    if (message != null) {
      if (message is T) {
        return message as T;
      }
    }
    return null;
  }

  // gets the message and checks the content
  Future<MamMessage> _getMessage(String root) async{
    MamFetchResponse response = await _mamQueue.fetchMessage(root);
    if (response.payload != null && response.payload != "undefined") {
      MamMessage mamMessage = MamMessageTypeHandler.messageFactoryByResponse(response);
      return mamMessage;
    } else {
      return null;
    }
  }

  // Removes an empty message (null) from the list of already fetched messages.
  // It is not published yet, but may be in the future.
  void _emptyMessageCheck(String root, Future<MamMessage> mamMessageFuture) async {
    MamMessage mamMessage = await mamMessageFuture;
    if (mamMessage == null) {
      if(_buffer.containsKey(root)) {
        _buffer.remove(root);
      }
    }
  }


}