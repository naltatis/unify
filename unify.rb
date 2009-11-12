#!/usr/bin/env ruby

REGEX_BEGIN = '<!-- begin:XXX -->'
REGEX_END = '<!-- end:XXX -->'

def main
  matcher = Regexp.new REGEX_BEGIN.gsub(/XXX/,"(.*?\\.html)");

  files.each do |file|
    print "#{file}\t updating:"
    update_file file
    print "\n"
  end
end

def update_file file
  text = File.read(file)
  text.clone.scan(scan_pattern) do |p|
    text = update_part(text,p[0])
  end
  File.open(file, "w") { |f| f << text }
end

def update_part text, template
  # getting fragment
  target_content = template_content(template)
  if target_content.nil?
    puts "\nerror: '#{template}' not found"
    return text
  end
  
  # check if begin and end are present and in correct order
  if !has_begin_and_end_tag(text, template)
    puts "\nerror: missing '#{end_pattern(template)}'"
    return text
  end
  
  source_content = content(text, template)
  if source_content != target_content
    print " _#{template}"            
    text = replace(text,template,target_content)
  end
  text
end

def files
  Dir.entries(".").select {|f| f =~ /^[^_].*\.html/}
end

def scan_pattern
  Regexp.new REGEX_BEGIN.gsub(/XXX/,"(.*?\\.html)");
end

def begin_pattern template
  REGEX_BEGIN.gsub(/XXX/,template)
end

def end_pattern template
  REGEX_END.gsub(/XXX/,template)
end

def surround_with_patterns template, inner
  begin_pattern(template)+inner+end_pattern(template)
end

def has_begin_and_end_tag text, template
  pos_begin = text =~ Regexp.new(begin_pattern(template))
  pos_end = text =~ Regexp.new(end_pattern(template))
  pos_begin && pos_end && pos_begin < pos_end
end

def content text, template
  p = Regexp.new(surround_with_patterns(template,"(.*?)"),Regexp::MULTILINE)
  text.match(p)[1].strip
end

def template_content template
  File.read "_#{template}" if File.exists? "_#{template}"
end

def replace text, template, content
  p = Regexp.new(surround_with_patterns(template,"(.*?)"),Regexp::MULTILINE)
  r = surround_with_patterns(template,"\n#{content}\n")
  text.gsub(p, r)
end

main