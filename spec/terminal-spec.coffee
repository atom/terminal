TerminalSession = require '../lib/terminal-session'
RootView = require 'root-view'

describe "Terminal", ->
  beforeEach ->
    window.rootView = new RootView
    atom.activatePackage 'terminal'

  describe "the terminal:open command", ->
    it "opens a terminal session for the given path in the current pane", ->
      rootView.trigger 'terminal:open'
      expect(rootView.getActivePaneItem() instanceof TerminalSession).toBeTruthy()
