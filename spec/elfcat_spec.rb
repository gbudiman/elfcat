require 'ap'
require 'elfcat/elf'
require 'spec_helper'

describe Elfcat do
  it 'has a version number' do
    expect(Elfcat::VERSION).not_to be nil
  end

  context 'parsing' do
    before :each do
      @path = File.join('**', 'proprietary/*.elf')
      @glob = Dir.glob(@path)
      @elf = Elf.new @glob.first
    end

    it 'should be able to load file into @resource' do
      e = Elf.new @glob.first
      expect(e.resource.size).to be > 0
    end

    context 'loaded Elf file' do
      before :each do
        e = Elf.new @glob.first
      end

      it 'should be able to parse file header' do
        @elf.file_header.debug
        expect(@elf.file_header.ei_magic_number).to eq(0x7F454C46)
      end

      it 'should be able to parse section tables' do
        @elf.section_table #.debug
        expect(@elf.section_table.data.keys.size).to be > 0
      end

      it 'should be able to parse section names' do
        @elf.section_names #.debug
        expect(@elf.section_names.data.length).to be > 0
      end

      it 'should be able to parse section tables with names' do
        @elf.section_table_with_names.debug
        expect(@elf.section_table.index.length).to be > 0
        expect(@elf.section_table.addresses.length).to be > 0
      end

      it 'should be able to parse string table' do
        @elf.string_table #.debug
        expect(@elf.string_table.data.length).to be > 0
      end

      it 'should be able to parse program header' do
        @elf.program_header.debug
      end
    end
  end
end
