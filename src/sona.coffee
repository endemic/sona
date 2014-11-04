class Sona
  # `sources` is an array of objects, each with `url` and `id` properties
  # e.g. [{ url: 'path/to/sound.mp3', id: 'mySound' }, { url: 'path/to/sound2.mp3', id: 'myOtherSound' }]
  constructor: (sources) ->
    # Standardize access to AudioContext object
    window.AudioContext = window.AudioContext || window.webkitAudioContext

    # Determine browser support
    @supported = !!AudioContext
    return if not @supported

    @context = new AudioContext()
    @sources = sources

    @buffers = {}
    @sounds = {}

  load: (callback) ->
    return if not @supported

    # Current source to load
    source = @sources.shift()

    request = new XMLHttpRequest()
    request.open 'GET', source.url, true
    request.responseType = 'arraybuffer'

    # Decode loaded audio data
    request.onload = =>
      @context.decodeAudioData request.response, (buffer) =>
        @buffers[source.id] = buffer

        if @sources.length then @load callback
        else if typeof callback is 'function' then callback()

    request.send()

  play: (id, _loop = false) ->
    return if not @supported or @buffers[id] is undefined

    @sounds[id] = @sounds[id] || {}

    # Re-initialize the source node; they can only be played once
    @sounds[id].sourceNode = @context.createBufferSource()  
    @sounds[id].sourceNode.buffer = @buffers[id]
    @sounds[id].sourceNode.loop = _loop

    # Gain node - for volume
    if not @sounds[id].gainNode
      @sounds[id].gainNode = @context.createGain()
      @sounds[id].gainNode.connect @context.destination
    
    @sounds[id].sourceNode.connect @sounds[id].gainNode
    
    # Play
    @sounds[id].sourceNode.start 0

  stop: (id) ->
    return if not @supported or @sounds[id] is undefined
    @sounds[id].sourceNode.stop 0

  getVolume: (id) ->
    return if not @supported or @sounds[id] is undefined
    @sounds[id].gainNode.gain.value

  setVolume: (id, volume) ->
    return if not @supported or @sounds[id] is undefined
    @sounds[id].gainNode.gain.value = volume

  getPosition: (id) ->
    return if not @supported or @buffers[id] is undefined
    # pass

  setPosition: (id) ->
    return if not @supported or @buffers[id] is undefined
    # pass

window.Sona = Sona