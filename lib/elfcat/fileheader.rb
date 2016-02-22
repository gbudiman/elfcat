class FileHeader
  attr_reader :file_header

  FH = {
    ei_magic_number:        [0x00,4],
    ei_class:               [0x04],
    ei_data:                [0x05],
    ei_version:             [0x06],
    ei_osabi:               [0x07],
    ei_abiversion:          [0x08],
    e_type:                 [0x10,2],
    e_machine:              [0x12,2],
    e_version:              [0x14,4],
    e_entry:                [0x18,4],
    e_phoff:                [0x1C,4],
    e_shoff:                [0x20,4],
    e_flags:                [0x24,4],
    e_ehsize:               [0x28,2],
    e_phentsize:            [0x2A,2],
    e_phnum:                [0x2C,2],
    e_shentsize:            [0x2E,2],
    e_shnum:                [0x30,2],
    e_shstrndx:             [0x32,2]
  }

  def initialize _x
    @data = Hash.new
    @debug = Proc.new{self.debug}

    FH.each do |k, v|
      @data[k] = Util.concatenate(_x, v[0], v[1] || 1)
    end
  end

  def method_missing _method
    puts "i'm called"
    return @data[_method][:data]
  end

  def [](_name)
    return @data[_name]
  end

  def debug
    @data.each do |k, d|
      k_s = sprintf("%32s", k)
      puts "#{k_s} #{CuteHex.x d.data}"
    end
  end
end