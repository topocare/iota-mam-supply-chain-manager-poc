async function getPayload(node, root, sideKey) {
    Mam.init(node)
    try {
        result = await Mam.fetchSingle(root, 'restricted', sideKey, null)
        fetchSuccessChannel.postMessage(root+";"+result.nextRoot +";"+ result.payload)
    } catch (e) {
        errorChannel.postMessage(JSON.stringify(result))
    }
}



async function sendPayload(node, seed, mamStartIndex, payload, sideKey, securityLevel) {
    mamState = Mam.init(node, seed, securityLevel)
    mamState = Mam.changeMode(
        mamState,
        'restricted',
        sideKey
    )
    mamState.channel.start = mamStartIndex

    message = Mam.create(mamState, payload)
    root = message.root
    try {
        result = await Mam.attach(message.payload, message.address, 3, 14, '')
        sendSuccessChannel.postMessage(message.address + ";" + root + ";" + message.state.channel.next_root + ";" + payload)
    } catch (e) {
        errorChannel.postMessage(JSON.stringify(e));
    }
}

async function provokeError() {
        errorChannel.postMessage("DemonstrationError");
}
