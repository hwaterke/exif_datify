$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'exif_datify'

def in_input(*paths)
  File.join(@input, *paths)
end

def in_output(*paths)
  File.join(@output, *paths)
end

def addPicJan15
  FileUtils.cp(File.join('test_data', 'picJan15.png'), @input)
end

def addPicNov14
  FileUtils.cp(File.join('test_data', 'picNov14.png'), @input)
end

def process(filename)
  @de.process(in_input(filename))
end

def expect_file_exist(file)
  expect(File.exist?(file)).to be true
end

def expect_file_missing(file)
  expect(File.exist?(file)).to be false
end
