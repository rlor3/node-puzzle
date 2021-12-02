through2 = require 'through2'


module.exports = ->
  words = 0
  lines = 1

  transform = (chunk, encoding, cb) ->
    # count lines
    chunk = chunk.split('\n')
    if chunk[chunk.length-1] == ""
      chunk.pop()

    lines = chunk.length

    for c in chunk
      # handle quoted strings
      if c[0] == '"' && c[c.length-1] == '"'
        words += 1
        continue

      # handle camel cased words
      if c != c.toUpperCase()
        c = camelCase(c)
      tokens = c.split(' ')
      words += tokens.length
    return cb()

  flush = (cb) ->
    this.push {words, lines}
    this.push null
    return cb()

  return through2.obj transform, flush

camelCase = (word) ->
  return word.replace(/[A-Z]/g, (v, i) ->
    if i == 0
      return v
    return " " + v
  )