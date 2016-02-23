class String
  def slice_with_index _start, _end
    index = 0
    result = []

    self.slice(_start, _end).each_byte do |b|
      result[index] = b
      index += 1
    end

    return result
  end
end

class Hash
  def method_missing _method
    return self[_method].is_a?(Hash) ? self[_method][:data] : self[_method]
  end
end

module Util
  def self.concatenate _h, _start, _length = 1
    start = _start
    length = _length
    result = 0

    loop do
      result |= (_h[start] << ((length - 1) * 8))

      length -= 1
      break if length == 0
      start += 1
    end

    return {address: _start, length: _length, data: result}
  end
end