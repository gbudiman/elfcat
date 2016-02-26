class ProgramHeader < Base
  attr_reader :index, :elf_addresses, :mem_addresses

  PH = {
    p_type:      [0x00, 4],
    p_offset:    [0x04, 4],
    p_vaddr:     [0x08, 4],
    p_paddr:     [0x0C, 4],
    p_filesz:    [0x10, 4],
    p_memsz:     [0x14, 4],
    p_flags:     [0x18, 4],
    p_align:     [0x1C, 4]
  }

  def initialize _fh, _st
    @index = Hash.new
    @elf_addresses = Hash.new
    @mem_addresses = Hash.new
    @vtp_map = Hash.new

    super()

    parse _fh
    populate _st
  end

  def get_by_index _n
    return @data[@index[_n]]
  end

  def at_elf_address _x
    return @data[@elf_addresses[_x]] || {}
  end

  # def at_mem_address _x
  #   return @data[@mem_addresses[_x]] || {}
  # end

  def debug
    @data.each do |k, d|
      print_debug_header if k % 64 == 0
      index_s = sprintf("%4d", k)

      real_name_s = sprintf("%-16.16s", d.real_name)

      elf_address_s = CuteHex.x d.p_offset
      elf_size_s = sprintf("%8d", d.p_filesz)

      virtual_address_s = CuteHex.x d.p_vaddr
      physical_address_s = CuteHex.x d.p_paddr
      mem_size_s = sprintf("%8d", d.p_memsz)

      puts "#{index_s} | #{real_name_s} #{elf_address_s} (#{elf_size_s}) | #{virtual_address_s} (#{mem_size_s})"
    end
  end

  def debug_vtp_map
    puts "-----------------------"
    puts "base_elf    -> base_mem"
    puts "-----------------------"
    @vtp_map.each do |elf, d|
      puts "#{CuteHex.x elf} -> #{CuteHex.x d.base}"
    end
  end

private
  def print_debug_header
    puts "----------------------------------------------------------------------------"
    puts " IDX | section_name     elf_addr    (  size B) | mem_addr    (  size B)"
    puts "----------------------------------------------------------------------------"
  end

  def parse _fh
    base_elf_address = _fh.e_phoff
    struct_element_size = _fh.e_phentsize
    struct_count = _fh.e_phnum
    total_program_header_length = struct_count * struct_element_size

    x = $resource.slice_with_index(base_elf_address, total_program_header_length)

    parse_struct(PH, x, struct_count, struct_element_size)
  end

  def populate _st
    @data.each do |k, d|
      @data[k][:real_name] = Proc.new {
        if d.p_filesz == 0 and d.memsz == 0
          raise RuntimeError, 'Unexpected empty elf and mem'
        else
          if d.p_filesz > 0 and d.p_offset > 0
            @elf_addresses[d.p_offset] ||= Array.new #k
            @elf_addresses[d.p_offset].push k
          end

          if d.p_memsz > 0 and d.p_vaddr > 0
            @mem_addresses[d.p_vaddr] = k
          end

          if d.p_filesz == 0
            @vtp_map[d.p_offset] ||= { base: nil, members: Array.new }
            @vtp_map[d.p_offset][:members].push d.p_vaddr
          end

          _st.addresses[d.p_offset] || _st.addresses[d.p_vaddr]
        end
      }.call


      @index[d.real_name] ||= Array.new 
      @index[d.real_name].push k   
    end

    summarize_vtp_map
    _st.annotate_virtual_address_mapping @vtp_map
  end

  def summarize_vtp_map
    @vtp_map.each do |elf, d|
      d[:base] = d[:members].min
    end

    debug_vtp_map
  end
end