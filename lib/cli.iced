fs  = require 'fs'
tty = require 'tty'
dreamopt = require 'dreamopt'

{ diff } = require './index'
{ colorize } = require './colorize'
{ remove_key, set_key } = require "./helpers"

module.exports = (argv) ->
  options = dreamopt [
    "Usage: json-diff [options] old.json new.json"

    "Arguments:"
    "  old.json              Old file #var(old) #required"
    "  new.json              New file #var(new) #required"

    "General options:"
    "  -v, --verbose                    Output progress info"
    "  -C, --[no-]color                 Colored output"
    "  -j, --raw-json                   Display raw JSON encoding of the diff #var(raw)"
    "  -K, --ignore-keys KEYS           Ignore keys (comma separated)"
    "  -V, --ignore-val-for-keys KEYS   Ignore value of keys (comma separated)"
    "  -s, --path-sep SEP               In path to key description (default '/')"
  ], argv

  options["path-sep"] ?= "/"
  for x in ["ignore-keys", "ignore-val-for-keys"]
    if options[x]
      options[x] = options[x].split(",").map (x) ->
        x.split options["path-sep"]
    else
      options[x] = []

  process.stderr.write "#{JSON.stringify(options, null, 2)}\n"  if options.verbose

  process.stderr.write "Loading files...\n"  if options.verbose
  data = {old:null, new:null}
  err  = {old:null, new:null}
  await
    for k of data
      fs.readFile options[k], 'utf8', defer(err[k], data[k])

  for k,v of err
    throw v if v

  for k,v of data
    process.stderr.write "Parsing #{k} file...\n"  if options.verbose
    json = JSON.parse(v)
    for x in options["ignore-keys"]
      remove_key json, x
    for x in options["ignore-val-for-keys"]
      set_key json, x, "IGNORED"
    data[k] = json

  process.stderr.write "Running diff...\n"  if options.verbose

  result = diff(data.old, data.new)

  options.color ?= tty.isatty(process.stdout.fd)

  if options.raw
    process.stderr.write "Serializing JSON output...\n"  if options.verbose
    process.stdout.write JSON.stringify(result, null, 2)
  else
    process.stderr.write "Producing colored output...\n"  if options.verbose
    process.stdout.write colorize(result, color: options.color)

  process.exit 1 if result
