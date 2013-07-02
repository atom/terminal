Project = require 'project'
TerminalSession = require './terminal-session'

module.exports =
  activate: ->
    Project.registerOpener(@customOpener)
    rootView.command 'terminal:open', ->
      initialDirectory = project.getPath() ? '~'
      rootView.open("terminal://#{initialDirectory}")

  deactivate: ->
    Project.unregisterOpener(@customOpener)

  customOpener: (uri) ->
    if match = uri?.match(/^terminal:\/\/(.*)/)
      initialDirectory = match[1]
      new TerminalSession({path: initialDirectory})
