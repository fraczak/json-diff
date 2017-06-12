remove_key = (obj,path) ->
  return unless obj
  return unless path.length > 0
  [a,path...] = path
  if not path or path.length is 0
    if Array.isArray(obj) and 'number' is typeof a
      obj.splice a, 1
    else
      delete obj[a]
  else
    remove_key obj[a], path
  obj

set_key = (obj,path,val) ->
  return unless obj
  return if 'object' isnt typeof obj
  [a,path...] = path
  return unless obj[a]
  if not path or path.length is 0
    obj[a] = val
  else
    set_key obj[a], path, val
  obj

module.exports = { remove_key, set_key }
