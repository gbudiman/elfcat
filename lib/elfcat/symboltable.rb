class SymbolTable < Base
  attr_reader :index

  ST = {
    st_name:      [0x0, 4],
    st_value:     [0x4, 4],
    st_size:      [0x8, 4],
    st_info:      [0xC, 1],
    st_other:     [0xD, 1],
    st_shndx:     [0xE, 2]
  }

  LUT_SHN = {
    0 => 'SHN_UNDEF',
    0xff00 => 'SHN_LORESERVE',
    0xff00 => 'SHN_LOPROC',
    0xff00 => 'SHN_BEFORE',
    0xff01 => 'SHN_AFTER',
    0xff02 => 'SHN_AMD64_LCOMMON',
    0xff1f => 'SHN_HIPROC',
    0xff20 => 'SHN_LOOS',
    0xff3f => 'SHN_LOSUNW',
    0xff3f => 'SHN_SUNW_IGNORE',
    0xff3f => 'SHN_HISUNW',
    0xff3f => 'SHN_HIOS',
    0xfff1 => 'SHN_ABS',
    0xfff2 => 'SHN_COMMON',
    0xffff => 'SHN_XINDEX',
    0xffff => 'SHN_HIRESERVE',

  }

  def initialize _st, _strtab, _ph
    @st = _st
    @ph = _ph
    @strtab = _strtab
    @index = Hash.new

    super()
    parse _st
    build_index
  end

  def get_by_index _n
    return @data[@index[_n]]
  end

  def debug
    i = -1
    @data.each do |k, d|
      
      
      if LUT_SHN[d.st_shndx]
        sh_name_s = sprintf("%-16.16s", LUT_SHN[d.st_shndx])

        i += 1
      else 
        next if d.st_size == 0
        sh_entry = @st[d.st_shndx]
        section_name = sh_entry.sh_real_name
        mem_addr = sh_entry.sh_addr
        elf_addr = sh_entry.sh_offset
        sh_name_s = sprintf("%-16.16s", section_name) + " #{CuteHex.x mem_addr} #{CuteHex.x elf_addr}"

        #program_header_entry = @ph.at_index section_name

        # program_header_entry = @ph.at_index(section_name, d.mem_addr)
        # mem_ph = program_header_entry.base_mem || 0
        # elf_ph = program_header_entry.base_elf || 0

        # sh_name_s += " | #{CuteHex.x mem_ph} #{CuteHex.x elf_ph}"

        i += 1
      end

      name_s = sprintf("%-32.32s", @strtab[k])
      value_s = CuteHex.x d.st_value
      size_s = sprintf("%6d", d.st_size)

      print_debug_header if i % 64 == 0
      puts "#{name_s} #{value_s} (#{size_s}) | #{sh_name_s}"
    end
  end

private
  def print_debug_header
    puts "----------------------------------------------------------------------------"
    puts "symbol_name                      mem_addr    size     | section_name     base_mem    base_addr"
    puts "----------------------------------------------------------------------------"
  end

  def build_index
    @data.each do |k, d|
      @index[@strtab[k]] = k
    end
  end

  def parse _st
    entry = _st.get_by_index('.symtab')

    base_elf_address = entry.sh_offset
    length = entry.sh_size
    element_count = length / entry.sh_entsize

    x = $resource.slice_with_index(base_elf_address, length)

    parse_struct(ST, x, element_count, entry.sh_entsize)
  end
end