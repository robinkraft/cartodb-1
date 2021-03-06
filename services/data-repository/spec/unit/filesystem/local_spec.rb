# encoding: utf-8
require 'minitest/autorun'
require 'stringio'
require_relative '../../../filesystem/local'

include DataRepository::Filesystem

describe Local do
  before do
    @data   = StringIO.new(Time.now.to_f.to_s)
    @path   = File.join( (0..2).map { Time.now.to_f.to_s } )
    @prefix = File.join(Local::DEFAULT_PREFIX, Time.now.to_i.to_s)
  end

  after do
    @data.close
    FileUtils.rmtree(@prefix)
    FileUtils.rmtree(Local::DEFAULT_PREFIX)
  end

  describe '#initialize' do
    it 'sets the storage prefix to Local::DEFAULT_PREFIX by default' do
      File.exists?( File.join(Local::DEFAULT_PREFIX, @path) ).must_equal false

      path = Local.new.store(@path, @data)
      File.exists?( File.join(Local::DEFAULT_PREFIX, @path) ).must_equal true
    end
  end #initialize

  describe '#store' do
    it 'stores data in the specified path' do
      filesystem  = Local.new(@prefix)
      path = filesystem.store(@path, @data)

      @data.rewind

      stored_data = File.open( File.join(@prefix, path) )
      stored_data.read.must_equal @data.read
    end
  end #store

  describe '#fetch' do
    it 'retrieves data from the specified path' do
      filesystem  = Local.new(@prefix)
      path = filesystem.store(@path, @data)

      @data.rewind

      stored_data = Local.new(@prefix).fetch(path)
      stored_data.read.must_equal @data.read
    end
  end #fetch

  describe '#zip' do
    it 'zips a directory' do
      filesystem    = Local.new(@prefix)
      path          = filesystem.store("sample/#{@path}", @data)
      zip_path      = filesystem.zip("sample")

      zip_path.must_match /.zip/
    end
  end #zip

  describe '#unzip' do
    it 'unzips an existing zip file in the filesystem' do
      filesystem    = Local.new(@prefix)
      path          = filesystem.store("sample/#{@path}", @data)
      zip_path      = filesystem.zip("sample")

      filesystem.unzip(zip_path)
    end
  end #unzip
end # Local

