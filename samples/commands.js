
var parameters = require('..');
require('should');

// NAME
//     server - Manage a web server
// SYNOPSIS
//     server command [options...]
//     where command is one of
//       start             Start a web server
//       help              Display help information about server
// DESCRIPTION
//     start               Start a web server
//       -h --host           Web server listen host
//       -p --port           Web server listen port
//     help                Display help information about server
//       name                Help about a specific command
// EXAMPLES
//     server help       Show this message

command = parameters({
  name: 'server',
  description: 'Manage a web server',
  commands: [{
    name: 'start',
    description: 'Start a web server',
    options: [{
      name: 'host', shortcut: 'h', 
      description: 'Web server listen host'
    },{
      name: 'port', shortcut: 'p', type: 'integer', 
      description: 'Web server listen port'
    }]
  }]
});
// Print help
console.log( command.help() );
// Extract command arguments
command.parse(
  ['node', 'server.js', 'start', '--host', '127.0.0.1', '-p', '80']
).should.eql({
  command: 'start',
  host: '127.0.0.1',
  port: 80
});
// Create a command
command.stringify({
  command: 'start',
  host: '127.0.0.1',
  port: 80
}).should.eql(
  ['start', '--host', '127.0.0.1', '--port', '80']
);