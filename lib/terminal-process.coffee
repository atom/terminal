pty = require 'pty.js'

module.exports = (ptyCwd) ->
  callback = @async()
  ptyProcess = pty.spawn process.env.SHELL, ['-l'],
    name: 'xterm-256color'
    cols: 80
    rows: 30
    cwd: ptyCwd
    env: process.env

  ptyProcess.on 'data', (data) -> emit('terminal:data', data)
  ptyProcess.on 'exit', ->
    emit('terminal:exit')
    callback()

  process.on 'message', ({event, columns, rows, text}={}) ->
    switch event
      when 'resize' then ptyProcess.resize(columns, rows)
      when 'input' then ptyProcess.write(text)
