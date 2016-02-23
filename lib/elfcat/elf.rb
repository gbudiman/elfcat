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

  def section_table
    @section_table ||= SectionTable.new(file_header)
  end

  def section_names
    @section_names ||= SectionName.new(file_header, section_table)
  end

  def section_table_with_names
    section_table.populate(section_names)
  end
end