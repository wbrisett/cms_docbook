require 'nokogiri'
@dita = false
@ditavalues = Hash.new
@docbookvalues = Hash.new
@final_results = Array.new


def get_title(file, fullpath)

  filecontents_tmp = Nokogiri::XML(File.open(fullpath))
  doc_title = filecontents_tmp.xpath("//title").first.content.split(/\n+/).join("")
  #doc_title.split(/\n+/).join("")
  @ditavalues[doc_title] = file if @dita
  @docbookvalues[doc_title] = file if !@dita

end


#########################################
# Get Input Directories
#########################################

dita_directorypath = ARGV[0]
if dita_directorypath.nil?
  dita_directorypath = Dir.pwd
  dita_directorypath = "/Users/wayneb/ARM_WORK/content/authoring"     # For testing only remove after release
end

last_char = dita_directorypath.split('').last
dita_directorypath =  "#{dita_directorypath}/" if !last_char.match("/")

docbook_directorypath = ARGV[1]
if docbook_directorypath.nil?
  docbook_directorypath = Dir.pwd
  docbook_directorypath = "/Users/wayneb/ARM_WORK/A57Docs/ditaXML/book_topics"  # For testing only remove after release
end

last_char = docbook_directorypath.split('').last
docbook_directorypath =  "#{docbook_directorypath}/" if !last_char.match("/")

file_output = ARGV[2]
if file_output.nil?
  file_output = "Compare_File.tsv"
end

##############################################
# grab all files ending in XML in directories
##############################################

dita_filelist = Dir.entries(dita_directorypath).join(' ')
dita_filelist = dita_filelist.split(' ').grep(/\.xml/)
docbook_filelist = Dir.entries(docbook_directorypath).join(' ')
docbook_filelist = docbook_filelist.split(' ').grep(/\.xml/)

puts "\nDITA File Directory: #{dita_directorypath}\nDocBook File Directory: #{docbook_directorypath}\n"


dita_filelist.each do |ditafile|
 # puts "DITA File: #{ditafile}\n"
  ditafile_full = "#{dita_directorypath}#{ditafile}"
  @dita = true
  get_title(ditafile, ditafile_full)
end

@dita = false
  puts "\n\n"
docbook_filelist.each do |docbookfile|
  # puts "Docbook File: #{docbookfile}\n"
  docbookfile_full = "#{docbook_directorypath}/#{docbookfile}"
  get_title(docbookfile,docbookfile_full)
end


@final_results << "Document Title\tDITA CMS Filename\tDocBook to DITA Filename\r"

@ditavalues.each do |title, filename|
  params = @docbookvalues.select { |key, value| title.match(key.to_s) }

  if !params.empty?
  docbook_title = params.keys
  docbook_filename = params.values
  end

  results = "#{title}\t#{filename}\t#{docbook_filename[0]}\r"  if !docbook_title.nil?
  results = "#{title}\t#{filename}\t\r"  if docbook_title.nil?
  @final_results << results

end


# flip and now do DocBook converted docs comparison to DITA CMS docs

@final_results << "\r\rDocument Title\tDocBook to DITA Filename\tDITA CMS Filename\r"

@docbookvalues.each do |title, filename|

  params = @ditavalues.select { |key, value| title.match(key.to_s) }

  if !params.empty?
  dita_title = params.keys
  dita_filename = params.values
  end

  results = "#{title}\t#{filename}\t#{dita_filename[0]}\r"  if !dita_title.nil?
  results = "#{title}\t#{filename}\t\r"  if dita_title.nil?
  @final_results << results

end

File.open(file_output, 'w+') {|f| f.write(@final_results.join.to_s) }
puts "wrote: #{file_output}"