class SectionTable < Base
  attr_reader :index, :addresses

  SH = {
    sh_name:       [0x00, 4],
    sh_type:       [0x04, 4],
    sh_flags:      [0x08, 4],
    sh_addr:       [0x0C, 4],
    sh_offset:     [0x10, 4],
    sh_size:       [0x14, 4],
    sh_link:       [0x18, 4],
    sh_info:       [0x1C, 4],
    sh_addralign:  [0x20, 4],
    sh_entsize:    [0x24, 4]
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

  LUT_SH_FLAGS = {
    0x1 => 'SHF_WRITE',
    0x2 => 'SHF_ALLOC',
    0x4 => 'SHF_EXECINSTR',
    0x10 => 'SHF_MERGE',
    0x20 => 'SHF_STRINGS',
    0x40 => 'SHF_INFO_LINK',
    0x80 => 'SHF_LINK_ORDER',
    0x100 => 'SHF_OS_NONCONFORMING',
    0x200 => 'SHF_GROUP',
    0x400 => 'SHF_TLS',
    0x0ff00000 => 'SHF_MASKOS',
    0x10000000 => 'SHF_AMD64_LARGE',
    0x40000000 => 'SHF_ORDERED',
    0x80000000 => 'SHF_EXCLUDE',
    0xf0000000 => 'SHF_MASKPROC'
  }

  LUT_SH_TYPE = {
    0 => 'SHT_NULL',
    1 => 'SHT_PROGBITS',
    2 => 'SHT_SYMTAB',
    3 => 'SHT_STRTAB',
    4 => 'SHT_RELA',
    5 => 'SHT_HASH',
    6 => 'SHT_DYNAMIC',
    7 => 'SHT_NOTE',
    8 => 'SHT_NOBITS',
    9 => 'SHT_REL',
    10 => 'SHT_SHLIB',
    11 => 'SHT_DYNSYM',
    14 => 'SHT_INIT_ARRAY',
    15 => 'SHT_FINI_ARRAY',
    16 => 'SHT_PREINIT_ARRAY',
    17 => 'SHT_GROUP',
    18 => 'SHT_SYMTAB_SHNDX',
    0x60000000 => 'SHT_LOOS',
    0x6fffffef => 'SHT_LOSUNW',
    0x6fffffef => 'SHT_SUNW_capchain',
    0x6ffffff0 => 'SHT_SUNW_capinfo',
    0x6ffffff1 => 'SHT_SUNW_symsort',
    0x6ffffff2 => 'SHT_SUNW_tlssort',
    0x6ffffff3 => 'SHT_SUNW_LDYNSYM',
    0x6ffffff4 => 'SHT_SUNW_dof',
    0x6ffffff5 => 'SHT_SUNW_cap',
    0x6ffffff6 => 'SHT_SUNW_SIGNATURE',
    0x6ffffff7 => 'SHT_SUNW_ANNOTATE',
    0x6ffffff8 => 'SHT_SUNW_DEBUGSTR',
    0x6ffffff9 => 'SHT_SUNW_DEBUG',
    0x6ffffffa => 'SHT_SUNW_move',
    0x6ffffffb => 'SHT_SUNW_COMDAT',
    0x6ffffffc => 'SHT_SUNW_syminfo',
    0x6ffffffd => 'SHT_SUNW_verdef',
    0x6ffffffe => 'SHT_SUNW_verneed',
    0x6fffffff => 'SHT_SUNW_versym',
    0x6fffffff => 'SHT_HISUNW',
    0x6fffffff => 'SHT_HIOS',
    0x70000000 => 'SHT_LOPROC',
    0x70000000 => 'SHT_SPARC_GOTDATA',
    0x70000001 => 'SHT_AMD64_UNWIND',
    0x7fffffff => 'SHT_HIPROC',
    0x80000000 => 'SHT_LOUSER',
    0xffffffff => 'SHT_HIUSER'
  }

  def initialize _fh
    super()
    @index = Hash.new
    @addresses = Hash.new

    parse _fh
  end

  def annotate_virtual_address_mapping _map
    @data.each do |k, d|
      next if LUT_SH_TYPE[d.sh_type] =~ /(NULL|NOBITS)$/

      #puts "##{d.sh_real_name} @#{CuteHex.x d.sh_offset} #{CuteHex.x d.sh_addr} (#{d.sh_size})"
      mapping = _map[d.sh_offset]

      if mapping and mapping.base != d.sh_addr
        d[:sh_vtpmap] = mapping.base
      end
    end
  end

  def populate _sn
    @data.each do |k, d|
      @data[k][:sh_real_name] = _sn[k]
      @index[_sn[k]] = k
      @addresses[d.sh_addr] ||= Array.new
      @addresses[d.sh_addr].push _sn[k]
      @addresses[d.sh_offset] ||= Array.new
      @addresses[d.sh_offset].push _sn[k]
    end

    return self
  end

  def get_by_index _n
    return @data[@index[_n]]
  end

  def at_address _x
    return @addresses[_x]
  end

  def debug
    @data.each_with_index do |(k, d), i|
      print_debug_header(d.sh_real_name) if i % 64 == 0
      index_s = sprintf("%4d", k)
      sh_name_index_s = d.sh_real_name ? sprintf("%-16.16s", d.sh_real_name) : sprintf("%4X", d.sh_name)
      sh_type_enum_s = sprintf("%-8.8s", LUT_SH_TYPE[d.sh_type] || d.sh_type)
      sh_flag_enum_s = sprintf("%-8.8s", LUT_SH_FLAGS[d.sh_flags] || d.sh_flags)
      sh_mem_address_s = CuteHex.x d.sh_addr
      sh_mem_address_s += d.sh_vtpmap ? " -> #{CuteHex.x d.sh_vtpmap}" : ' '*15
      sh_elf_address_s = CuteHex.x d.sh_offset
      sh_size_s = sprintf("%8d", d.sh_size)

      puts "#{index_s} | #{sh_name_index_s} #{sh_type_enum_s} #{sh_flag_enum_s} | #{sh_mem_address_s} #{sh_elf_address_s} #{sh_size_s}"
    end
  end

private
  def print_debug_header _has_real_name = false
    case _has_real_name
    when false
      puts "-------------------------------------------------------------------------------"
      puts " IDX | nidx type     flag     | vmem_addr   -> pmem_addr   elf_addr    size (B)"
      puts "-------------------------------------------------------------------------------"
    else
      puts "-------------------------------------------------------------------------------------------"
      puts " IDX | name             type     flag     | vmem_addr   -> pmem_addr   elf_addr    size (B)"
      puts "-------------------------------------------------------------------------------------------"
    end
  end

  def parse _fh
    base_elf_address = _fh.e_shoff
    struct_element_size = _fh.e_shentsize
    struct_count = _fh.e_shnum
    section_table_length = struct_element_size * struct_count

    x = $resource.slice_with_index(base_elf_address, section_table_length)

    parse_struct(SH, x, struct_count, struct_element_size)
  end
end