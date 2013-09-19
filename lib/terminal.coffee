TerminalSession = null
createTerminalSession = (state) ->
  TerminalSession ?= require './terminal-session'
  new TerminalSession(state)

registerDeserializer
  name: 'TerminalSession'
  version: 1
  deserialize: (state) -> createTerminalSession(state)

module.exports =
  activate: ->
    project.registerOpener(@customOpener)
    rootView.command 'terminal:open', ->
      initialDirectory = project.getPath() ? '~'
      rootView.open("terminal://#{initialDirectory}")

  deactivate: ->
    project.unregisterOpener(@customOpener)

  customOpener: (uri) ->
    if match = uri?.match(/^terminal:\/\/(.*)/)
      initialDirectory = match[1]
      createTerminalSession({path: initialDirectory})
