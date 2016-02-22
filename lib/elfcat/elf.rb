class Elf
  attr_reader :resource

  def initialize _filepath
    @resource = File.binread _filepath

    return self
  end

  def file_header
    @file_header ||= FileHeader.new(@resource.slice_with_index(0, 64))

    # ap @file_header.ei_magic_number
    # ap @file_header[:ei_magic_number]
    # @file_header.debug
  end
end