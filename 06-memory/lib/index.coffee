fs = require 'fs'


exports.countryIpCounter = (countryCode, cb) ->
  return cb() unless countryCode

  dataStream = fs.createReadStream "#{__dirname}/../data/geo.txt", {encoding: "utf8", highWaterMark: 4096}

  counter = 0
  temp = ""
  addCounter = (countryCode, counter, data) ->
    line = data.split '\t'
    # GEO_FIELD_MIN, GEO_FIELD_MAX, GEO_FIELD_COUNTRY
    # line[0],       line[1],       line[3]

    if line[3] == countryCode then counter += +line[1] - +line[0]

    return counter

  dataStream.on 'data', (dataChunk) ->
    data = dataChunk.toString().split '\n'
    for i in [0...data.length-1] by 1
      if i == 0 && temp != ""
        # concat chunk of partial data
        data[i] = temp + data[i]
        temp = ""

      counter = addCounter(countryCode, counter, data[i])

    # store last line to be processed
    temp = data[data.length-1]

  dataStream.on 'end', () ->

    cb null, counter