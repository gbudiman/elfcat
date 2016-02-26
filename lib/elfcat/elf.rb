class Elf
  def initialize _filepath
    $resource = File.binread _filepath

    return self
  end

  def file_header
    @file_header ||= FileHeader.new
  end

  def resource
    return $resource
  end

  def program_header
    @program_header ||= ProgramHeader.new(file_header, section_table_with_names)
  end

  def section_table
    @section_table ||= SectionTable.new(file_header)
  end

  def section_names
    @section_names ||= SectionName.new(file_header, section_table)
  end

  def section_table_with_names
    section_table.populate(section_names)
  end

  def string_table
    @string_table ||= StringTable.new(section_table_with_names)
  end

  def symbol_table
    @symbol_table ||= SymbolTable.new(section_table_with_names, string_table, program_header)
  end
end