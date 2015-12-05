require 'nokogiri'
require 'JSON'
require 'pp'

font_file_base = "inconsolata_medium_32"

texture_size = `identify -format "%w %h" #{font_file_base}.PNG`

doc = Nokogiri::XML(File.open(font_file_base + ".xml"))
meta = doc.xpath("//Font")
height = meta.attr("height").to_s.to_i
texture_width = texture_size.split.first.to_f
texture_height = texture_size.split.last.to_f

info = {
    chars: Hash[
        doc.xpath("//Font/Char").map do |element|
          width = element.attr("width").to_s.to_i

          offset = element.attr("offset").to_s.split
          offset[0] = (offset[0].to_f / width).round(5)
          offset[1] = (offset[1].to_f / height).round(5)

          rect = element.attr("rect").to_s.split
          rect[0] = (rect[0].to_f / texture_width).round(5)
          rect[1] = (rect[1].to_f / texture_height).round(5)
          rect[2] = (rect[2].to_f / texture_width).round(5)
          rect[3] = (rect[3].to_f / texture_height).round(5)

          [
              element.attr("code").to_s,
              {
                  offset: offset,
                  rect: rect,
              }
          ]
        end
    ]
}

puts info.to_json
