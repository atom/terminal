TerminalSession = null
TerminalBuffer = null
TerminalCommandPromptView = null

atom.deserializers.add
  name: 'TerminalSession'
  version: 1
  deserialize: (state) -> Terminal.createTerminalSession(state)

module.exports =
Terminal =
  activate: ->
    atom.project.registerOpener (uri) => @customOpener(uri)

    atom.workspaceView.command 'terminal:open', ->
      initialDirectory = atom.project.getPath() ? '~'
      atom.workspaceView.open("terminal://#{initialDirectory}")

    atom.workspaceView.command 'terminal:run-command', => @toggleCommandPrompt()

  deactivate: ->
    atom.project.unregisterOpener(@customOpener)

  customOpener: (uri) ->
    if match = uri?.match(/^terminal:\/\/(.*)/)
      initialDirectory = match[1]
      @createTerminalSession({path: initialDirectory})

  activeSessions: []

  createTerminalSession: (state) ->
    TerminalSession ?= require './terminal-session'
    session = new TerminalSession(state)
    @registerSession(session)
    session

  registerSession: (session) ->
    @activeSessions.push(session)
    session.on 'exit', => @removeSession(session)

  removeSession: (session) ->
    index = @activeSessions.indexOf(session)
    @activeSessions.splice(index, 1) if index != -1

  toggleCommandPrompt: ->
    TerminalCommandPromptView ?= require('./terminal-command-prompt-view')
    @commandPromptView ?= new TerminalCommandPromptView(this)
    @commandPromptView.toggle()

  runCommand: (command) ->
    return unless command
    session = @activeSessions[0]
    return unless session

    TerminalBuffer ?= require './terminal-buffer'

    try
      session.emit 'input', command + TerminalBuffer.enter
    catch error
      if /terminated process/.test(error.message)
        @removeSession(session)
        @runCommand(command)
      else
        throw(error)
