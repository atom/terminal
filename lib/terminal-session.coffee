{_, EventEmitter, fs, Task} = require 'atom'
guid = require 'guid'

TerminalBuffer = require './terminal-buffer'

module.exports =
class TerminalSession
  path: null
  process: null
  exitCode: null

  constructor: ({@path, @id}) ->
    @id ?= guid.create().toString()
    @buffer = new TerminalBuffer

    @process = @forkPtyProcess()
    @process.on 'terminal:data', (data) => @trigger 'data', data

    @on 'data', (data) => @buffer.trigger 'data', data
    @on 'input', (data) => @input(data)
    @on 'resize', (data) => @resize(data)
    @buffer.on 'update', (data) => @trigger 'update', data
    @buffer.on 'clear', => @trigger 'clear'
    @process.on 'terminal:exit', =>
      @trigger 'exit'
      @exitCode = 0

  forkPtyProcess: ->
    processPath = require.resolve('./terminal-process')
    Task.once(processPath, fs.absolute(@path))

  serialize: ->
    deserializer: 'TerminalSession'
    path: @path
    id: @id

  getViewClass: ->
    require './terminal-view'

  getTitle: -> 'Terminal'

  getUri: -> "terminal://#{@id}#{@path}"

  destroy: ->
    @process.terminate()

  input: (data) ->
    @process.send(event: 'input', text: data)

  resize: (data) ->
    [rows, columns] = data
    @buffer.setSize([rows, columns])
    @process.send({event: 'resize', rows, columns})

_.extend TerminalSession.prototype, EventEmitter
