{View, EditorView} = require 'atom'

module.exports =
class TerminalCommandPromptView extends View
  @content: ->
    @div class: 'terminal-prompt overlay from-top', =>
      @div class: 'editor-container', outlet: 'editorContainer', =>
        editor = new EditorView(mini: true)
        editor.setPlaceholderText "enter command"
        @subview 'editor', editor

  initialize: (@terminal) ->

  handleEvents: ->
    @editor.on 'core:confirm', @confirm
    @editor.on 'core:cancel', @remove
    @editor.find('input').on 'blur', @remove

  focus: =>
    @removeClass('hidden')
    @editorContainer.find('.editor').focus()

  confirm: =>
    @terminal.runCommand @editor.getText()
    @remove()

  remove: =>
    atom.workspaceView?.focus()
    @addClass('hidden')

  toggle: ->
    atom.workspaceView.append(@)
    @focus()
    @handleEvents()
