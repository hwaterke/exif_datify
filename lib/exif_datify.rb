require "exif_datify/version"
require 'date'
require 'json'
require 'logger'
require 'fileutils'

module ExifDatify
  class DateExtractor
    attr_reader :operation, :counters, :logger
    attr_accessor :datetime_format, :tags
    DATETIME_REGEX = /^\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2}/

    def initialize
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::WARN
      @tags = ['DateTimeOriginal', 'MediaCreateDate']
      @datetime_format = "%Y-%m-%d_%H-%M-%S_"
      @quiet = false
      @counters = Hash.new(0)
      rename!
      @month_subdirectories = false
    end

    def quiet!
      @quiet = true
    end

    def month_subdirectories!
      @month_subdirectories = true
    end

    def rename!
      @operation = :rename
    end

    def move!(destination)
      raise "#{destination} does not exist" unless FileTest.directory?(destination)
      @operation = :move
      @destination = destination
    end

    def copy!(destination)
      raise "#{destination} does not exist" unless FileTest.directory?(destination)
      @operation = :copy
      @destination = destination
    end

    def extract_datetime(file_path)
      @logger.debug "Extracting datetime from #{file_path}"
      meta = exiftool(file_path)
      @tags.each do |tag|
        return DateTime.parse(meta[tag]) if meta[tag]
      end
      nil
    end

    def process(file_path)
      @counters[:total] += 1
      datetime = extract_datetime(file_path)
      if datetime.nil?
        puts "Could not extract date from #{file_path}" unless @quiet
      else
        operate(file_path, datetime)
      end
    end

    private

    def destination(file_path, datetime)
      return File.dirname(file_path) if operation == :rename
      return @destination unless @month_subdirectories
      File.join(@destination, datetime.strftime('%Y'), datetime.strftime('%m'))
    end

    def operate(file_path, datetime)
      @logger.debug "Processing #{file_path} with #{datetime}"
      current_name = File.basename(file_path)
      prefix = datetime.strftime(@datetime_format)

      # No prefix if the basename has a good format already.
      prefix = '' if current_name.start_with?(prefix) or current_name =~ DATETIME_REGEX

      prefixed_name = File.join(destination(file_path, datetime), prefix + current_name)
      unless File.expand_path(file_path) == File.expand_path(prefixed_name)
        if File.exist?(prefixed_name)
          raise "Cannot #{operation} #{current_name}, #{prefixed_name} already exists."
        else
          @logger.debug "Destination: #{prefixed_name}"
          perform_operation(file_path, prefixed_name)
          puts "Performed #{operation} on #{current_name} to #{prefixed_name}." unless @quiet
          @counters[:renamed] += 1
        end
      end
    end

    def perform_operation(file_path, destination)
      case operation
      when :rename
        File.rename(file_path, destination)
      when :move
        FileUtils.mkdir_p File.dirname(destination)
        FileUtils.mv(file_path, destination)
      when :copy
        FileUtils.mkdir_p File.dirname(destination)
        FileUtils.cp(file_path, destination)
      else
        raise "Unknown operation #{operation}"
      end
    end

    def prepend_date(file_path)
      datetime = extract_datetime(file_path)
      current_name = File.basename(file_path)
      if datetime.nil?
        puts "Could not extract date from #{current_name}" unless @quiet
      else
        prefix = datetime.strftime(@datetime_format)
        unless current_name.start_with?(prefix)
          prefixed_name = File.join(File.dirname(file_path), prefix + current_name)
          if File.exist?(prefixed_name)
            raise "Cannot rename #{current_name}, #{prefixed_name} already exists."
          else
            File.rename(file_path, prefixed_name)
            puts "Renamed #{current_name} to #{File.basename(prefixed_name)}." unless @quiet
            @counters[:renamed] += 1
          end
        end
      end
    end

    def exiftool(file_path)
      raise "File #{file_path} does not exist" unless File.exist?(file_path)
      result = %x(exiftool -u -d "%Y-%m-%d %H:%M:%S" -json "#{file_path}")
      JSON.parse(result)[0]
    end
  end
end
