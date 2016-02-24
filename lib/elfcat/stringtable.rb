class StringTable < Base
  def initialize _st
    super()
    parse _st
  end

  def debug
    @data.each_with_index do |x, i|
      index_s = sprintf("%4d", i)
      name_s = sprintf("%s", x)

      puts "#{index_s} | #{name_s}"
    end
  end

private
  def parse _st
    entry = _st.get_by_index('.strtab')
    base_elf_address = entry.sh_offset
    length = entry.sh_size

    @data = parse_slice(base_elf_address, length)
  end
end