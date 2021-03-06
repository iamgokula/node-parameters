
fs = require 'fs'
os = require 'os'
{ Writable } = require 'stream'
parameters = require '../../src'

writer = (callback) ->
  chunks = []
  new Writable
    write: (chunk, encoding, callback) ->
      chunks.push chunk.toString()
      callback()
  .on 'finish', ->
    callback chunks.join ''

describe 'router.error', ->
  
  describe 'option', ->

    it 'application help', (next) ->
      parameters
        router:
          writer: writer (output) ->
            output.should.match /myapp - No description yet/
            next()
          end: true
      .route ['--help']

    it 'command help', (next) ->
      parameters
        router:
          writer: writer (output) ->
            output.should.match /myapp server - No description yet for the server command/
            next()
          end: true
        commands:
          'server':
            commands:
              'start': {}
      .route ['server', '--help']
        
  describe 'help command', ->

    it 'application help', (next) ->
      parameters
        router:
          writer: writer (output) ->
            output.should.match /^\s+Missing Application Route: a "route" definition is required when no child command is defined/
            output.should.match /^\s+myapp - No description yet/m
            next()
      .route []

    it 'command help', (next) ->
      parameters
        router:
          writer: writer (output) ->
            output.should.match /myapp server - No description yet for the server command/
            next()
          end: true
        commands:
          'server':
            commands:
              'start': {}
      .route ['help', 'server']
        
  describe 'command', ->
    
    it 'command without route and with orphan print help', (next) ->
      parameters
        router:
          writer: writer (output) ->
            output.should.not.match /^\s+Missing Command Route: a "route" definition \["server","start"\] is required when no child command is defined/
            output.should.match /^\s+myapp server start - No description yet for the start command/m
            next()
          end: true
        commands:
          'server':
            commands:
              'start':
                commands:
                  'sth': {}
      .route ['server', 'start']
    
    it 'print error message if leaf', (next) ->
      parameters
        router:
          writer: writer (output) ->
            output.should.match /^\s+Missing Command Route: a "route" definition \["server","start"\] is required when no child command is defined/
            output.should.match /^\s+myapp server start - No description yet for the start command/m
            next()
          end: true
        commands:
          'server':
            commands:
              'start': {}
      .route ['server', 'start']
        
  describe 'error', ->
    
    it 'Unhandled leftover', (next) ->
      parameters
        router:
          writer: writer (output) ->
            output.should.match /^\s+Invalid Argument: fail to interpret all arguments "invalid leftover"/
            output.should.match /^\s+myapp - No description yet/m
            next()
          end: true
      .route ['invalid', 'leftover']
        
    it 'Undeclared options in stric mode', (next) ->
      parameters
        router:
          writer: writer (output) ->
            output.should.match /^\s+Invalid Argument: the argument --opt is not a valid option/
            output.should.match /^\s+myapp - No description yet/m
            next()
          end: true
        strict: true
      .route ['--opt', 'val']
        
    it 'Undeclared options inside a command in stric mode', (next) ->
      parameters
        commands:
          'server': {}
        router:
          writer: writer (output) ->
            output.should.match /^\s+Invalid Argument: the argument --opt is not a valid option/
            output.should.match /^\s+myapp server - No description yet for the server command/m
            next()
          end: true
        strict: true
      .route ['server', '--opt', 'val']
