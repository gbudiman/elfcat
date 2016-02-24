class ProgramHeader < Base
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
    super()
    parse _fh
    populate _st
  end

  def debug
    @data.each_with_index do |(k, d), i|
      print_debug_header if i % 64 == 0
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
        elsif d.p_filesz > 0 and d.p_offset > 0
          _st.addresses[d.p_vaddr]
        elsif d.p_memsz > 0 and d.p_vaddr > 0
          _st.addresses[d.p_offset]
        # else
        #   name_by_elf = _st.addresses[d.p_offset]
        #   name_by_mem = _st.addresses[d.p_vaddr]

        #   if d.p_vaddr > 0 and d.p_offset > 0
        #     raise RuntimeError, "Mismatch elf and mem name #{name_by_elf} | #{name_by_mem}" if name_by_elf != name_by_mem
        #   end
        end
      }.call
    end
  end
end