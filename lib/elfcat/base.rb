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
end