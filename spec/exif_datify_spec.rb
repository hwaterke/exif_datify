require 'spec_helper'
require 'tmpdir'
require 'fileutils'

describe ExifDatify do
  it 'has a version number' do
    expect(ExifDatify::VERSION).not_to be nil
  end

  it 'can be instantiated' do
    expect(ExifDatify::DateExtractor.new).not_to be nil
  end

  describe 'operations' do
    before(:each) do
      @de = ExifDatify::DateExtractor.new
      @de.logger.level = Logger::DEBUG

      # Create temp directory
      @dir = Dir.mktmpdir
      @input = File.join(@dir, 'input')
      @output = File.join(@dir, 'output')

      FileUtils.mkdir @input
      FileUtils.mkdir @output
    end

    after(:each) do
      # Clean temp directory
      FileUtils.remove_entry @dir
    end

    describe 'rename' do
      it 'crashes if file does not exist' do
        expect { process('does_not_exist.png') }.to raise_exception(RuntimeError)
      end

      it "renames file in place" do
        addPicJan15
        process 'picJan15.png'
        expect_file_missing in_input 'picJan15.png'
        expect_file_exist in_input '2015-01-01_12-00-00_picJan15.png'
      end

      it "does not rename file already prefixed" do
        addPicJan15
        File.rename(in_input('picJan15.png'), in_input('2015-01-01_12-00-00_picJan15.png'))
        process '2015-01-01_12-00-00_picJan15.png'
        expect_file_missing in_input 'picJan15.png'
        expect_file_exist in_input '2015-01-01_12-00-00_picJan15.png'
      end

      it "does not renames file if destination already used" do
        addPicJan15
        File.write(in_input('2015-01-01_12-00-00_picJan15.png'), 'content')
        expect { process('picJan15.png') }.to raise_exception(RuntimeError)
        expect_file_exist in_input 'picJan15.png'
        expect_file_exist in_input '2015-01-01_12-00-00_picJan15.png'
        expect(File.read(in_input('2015-01-01_12-00-00_picJan15.png'))).to eq 'content'
      end
    end

    describe 'copy' do
      before(:each) do
        @de.copy! @output
      end

      it 'crashes if file does not exist' do
        expect { process('does_not_exist.png') }.to raise_exception(RuntimeError)
      end

      it "copies files" do
        addPicJan15
        process 'picJan15.png'
        expect_file_exist in_input 'picJan15.png'
        expect_file_exist in_output '2015-01-01_12-00-00_picJan15.png'
      end

      it "copies files in subdirs" do
        addPicNov14
        addPicJan15
        @de.month_subdirectories!
        process 'picNov14.png'
        process 'picJan15.png'
        expect_file_exist in_input 'picNov14.png'
        expect_file_exist in_input 'picJan15.png'
        expect_file_exist in_output '2014', '11', '2014-11-01_12-00-00_picNov14.png'
        expect_file_exist in_output '2015', '01', '2015-01-01_12-00-00_picJan15.png'
      end

      it "does not copy files if destination already used" do
        addPicJan15
        File.write(in_output('2015-01-01_12-00-00_picJan15.png'), 'content')
        expect { process('picJan15.png') }.to raise_exception(RuntimeError)
        expect_file_exist in_input 'picJan15.png'
        expect_file_exist in_output '2015-01-01_12-00-00_picJan15.png'
        expect(File.read(in_output('2015-01-01_12-00-00_picJan15.png'))).to eq 'content'
      end
    end

    describe 'move' do
      before(:each) do
        @de.move! @output
      end

      it 'crashes if file does not exist' do
        expect { process('does_not_exist.png') }.to raise_exception(RuntimeError)
      end

      it "copies files" do
        addPicJan15
        process 'picJan15.png'
        expect_file_missing in_input 'picJan15.png'
        expect_file_exist in_output '2015-01-01_12-00-00_picJan15.png'
      end

      it "copies files in subdirs" do
        addPicNov14
        addPicJan15
        @de.month_subdirectories!
        process 'picNov14.png'
        process 'picJan15.png'
        expect_file_missing in_input 'picNov14.png'
        expect_file_missing in_input 'picJan15.png'
        expect_file_exist in_output '2014', '11', '2014-11-01_12-00-00_picNov14.png'
        expect_file_exist in_output '2015', '01', '2015-01-01_12-00-00_picJan15.png'
      end

      it "does not copy files if destination already used" do
        addPicJan15
        File.write(in_output('2015-01-01_12-00-00_picJan15.png'), 'content')
        expect { process('picJan15.png') }.to raise_exception(RuntimeError)
        expect_file_exist in_input 'picJan15.png'
        expect_file_exist in_output '2015-01-01_12-00-00_picJan15.png'
        expect(File.read(in_output('2015-01-01_12-00-00_picJan15.png'))).to eq 'content'
      end
    end
  end
end
