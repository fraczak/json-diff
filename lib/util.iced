
extendedTypeOf = (obj) ->
  result = typeof obj
  if !obj?
    'null'
  else if result is 'object' and obj.constructor is Array
    'array'
  else
    result

removeKey = (obj,path) ->
  return unless obj
  return unless path.length > 0
  [a,path...] = path
  if not path or path.length is 0
    if Array.isArray(obj) and 'number' is typeof a
      obj.splice a, 1
    else
      delete obj[a]
  else
    removeKey obj[a], path
  obj

setKey = (obj,path,val) ->
  return unless obj
  return if 'object' isnt typeof obj
  [a,path...] = path
  return unless obj[a]
  if not path or path.length is 0
    obj[a] = val
  else
    setKey obj[a], path, val
  obj

module.exports = { extendedTypeOf, removeKey, setKey }
