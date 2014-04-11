pty = require 'pty.js'

module.exports = (ptyCwd, ptyEnv) ->
  callback = @async()
  if process.platform is 'win32'
    shell = 'C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe'

    # TODO: Remove this swapping once atom/pty.js#47 lands
    cols = 30
    rows = 80
  else
    shell = process.env.SHELL
    cols = 80
    rows = 30

  ptyProcess = pty.fork shell, [],
    name: 'xterm-256color'
    cols: cols
    rows: rows
    cwd: ptyCwd
    env: ptyEnv

  ptyProcess.on 'data', (data) -> emit('terminal:data', data)
  ptyProcess.on 'exit', ->
    emit('terminal:exit')
    callback()

  process.on 'message', ({event, columns, rows, text}={}) ->
    switch event
      when 'resize' then ptyProcess.resize(columns, rows)
      when 'input' then ptyProcess.write(text)
