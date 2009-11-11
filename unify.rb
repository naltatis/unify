#!/usr/bin/env ruby

REGEX_BEGIN = '<!-- begin:XXX -->'
REGEX_END = '<!-- end:XXX -->'


def main
  matcher = Regexp.new REGEX_BEGIN.gsub(/XXX/,"(.*?\\.html)");

  files.each do |file|
    puts
    puts ">> #{file}"
    
    text = File.read(file)
    
    File.read(file).scan pattern do |p|
      template = p[0]
      
      target_content = template_content(template)
      if target_content
        if has_begin_and_end_tag(text, template)
          source_content = content(text, template)
          text.gsub!(source_content, target_content)
          puts "beginning: #{template}"
          puts "end: #{template}"
        end
      end
    end
    puts text;
  end
end

def files
  Dir.entries(".").select {|f| f =~ /^[^_].*\.html/}
end

def pattern
  Regexp.new REGEX_BEGIN.gsub(/XXX/,"(.*?\\.html)");
end

def begin_pattern template
  REGEX_BEGIN.gsub(/XXX/,template)
end

def end_pattern template
  REGEX_END.gsub(/XXX/,template)
end

def content_pattern template
  Regexp.new(begin_pattern(template)+"(.*?)"+end_pattern(template),Regexp::MULTILINE)
end

def has_begin_and_end_tag text, template
  pos_begin = text =~ Regexp.new(begin_pattern(template))
  pos_end = text =~ Regexp.new(end_pattern(template))
  pos_begin && pos_end && pos_begin < pos_end
end

def content text, template
  text.match(content_pattern(template))[1].strip
end

def template_content template
  File.read("_#{template}")
end

main