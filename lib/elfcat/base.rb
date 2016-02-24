class Base
  attr_reader :data, :debug

  def initialize
    @data = Hash.new
    @debug = Proc.new { self.debug }
  end

  def method_missing _method
    return @data[_method][:data]
  end

  def [](_name)
    return @data[_name]
  end

  def debug
    raise RuntimeError, "Base::debug() is stubbed. Please override this method"
  end

  def parse_struct _struct, _resource, _element_count, _element_size
    _element_count.times do |i|
      st = Hash.new
      struct_address = i * _element_size

      _struct.each do |k, v|
        st[k] = Util.concatenate(_resource, struct_address + v[0], v[1])
      end

      @data[i] = st.dup
    end
  end

  def parse_slice _address, _length
    return $resource.slice(_address, _length).split(/\x0/).dup
  end
end