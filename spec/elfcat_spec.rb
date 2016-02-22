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
      it 'should be able to parse file header' do
        @elf.file_header.debug
        expect(@elf.file_header.ei_magic_number).to eq(0x7F454C46)
      end
    end
  end
end
