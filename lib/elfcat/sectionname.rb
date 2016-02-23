class SectionName < Base
  def initialize _fh, _st
    super()
    parse _fh, _st
  end

  def debug
    @data.each_with_index do |x, i|
      index_s = sprintf("%4d", i)
      name_s = sprintf("%s", x)

      puts "#{index_s} | #{name_s}"
    end
  end

private
  def parse _fh, _st
    entry = _st[_fh.e_shstrndx]
    base_elf_address = entry.sh_offset
    length = entry.sh_size

    @data = $resource.slice(base_elf_address, length).split(/\x0/).dup
  end
end