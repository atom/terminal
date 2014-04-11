fs = require 'fs-plus'
{_, Task} = require 'atom'
{Emitter} = require 'emissary'
guid = require 'guid'

TerminalBuffer = require './terminal-buffer'

module.exports =
class TerminalSession
  Emitter.includeInto(this)

  path: null
  process: null
  exitCode: null

  constructor: ({@path, @id}) ->
    @id ?= guid.create().toString()
    @buffer = new TerminalBuffer

    @process = @forkPtyProcess()
    @process.on 'terminal:data', (data) => @emit 'data', data

    @on 'data', (data) => @buffer.emit 'data', data
    @on 'input', (data) => @input(data)
    @on 'resize', (data) => @resize(data)
    @buffer.on 'update', (data) => @emit 'update', data
    @buffer.on 'clear', => @emit 'clear'
    @process.on 'terminal:exit', =>
      @emit 'exit'
      @exitCode = 0

  forkPtyProcess: ->
    processPath = require.resolve('./terminal-process')
    env = atom.config.get('terminal.env') ? {}
    env[key] = val for key, val of process.env
    Task.once(processPath, fs.absolute(@path), env)

  serialize: ->
    deserializer: 'TerminalSession'
    version: 1
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
