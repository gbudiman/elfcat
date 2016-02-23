class FileHeader < Base
  FH = {
    ei_magic_number:        [0x00,4],
    ei_class:               [0x04,1],
    ei_data:                [0x05,1],
    ei_version:             [0x06,1],
    ei_osabi:               [0x07,1],
    ei_abiversion:          [0x08,1],
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

  def initialize
    super
    x = $resource.slice_with_index(0, 64)

    FH.each do |k, v|
      @data[k] = Util.concatenate(x, v[0], v[1])
    end
  end

  def debug
    @data.each do |k, d|
      k_s = sprintf("%32s", k)
      puts "#{k_s}: #{CuteHex.x d.data, slicer: :byte, word_size: (FH[k][1] * 8), style: :data, pad_zeros: true}"
    end
  end
end