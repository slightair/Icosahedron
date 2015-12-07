require 'nokogiri'
require 'JSON'
require 'pp'

font_file_base = "inconsolata_medium_64"

texture_size = `identify -format "%w %h" #{font_file_base}.PNG`

doc = Nokogiri::XML(File.open(font_file_base + ".xml"))
meta = doc.xpath("//Font")
width = doc.xpath("// Font/Char[1]").attr("width").to_s.to_f
height = meta.attr("height").to_s.to_f
texture_width = texture_size.split.first.to_f
texture_height = texture_size.split.last.to_f
round = 10

info = {
    ratio: width / height,
    chars: Hash[
        doc.xpath("//Font/Char").map do |element|
          width = element.attr("width").to_s.to_f

          offset = element.attr("offset").to_s.split
          offset[0] = (offset[0].to_f / width).round(round)
          offset[1] = (offset[1].to_f / height).round(round)

          rect = element.attr("rect").to_s.split

          canvas = [
              offset[0],
              offset[1],
              (rect[2].to_f / width).round(round),
              (rect[3].to_f / height).round(round),
          ]

          rect[0] = (rect[0].to_f / texture_width).round(round)
          rect[1] = (rect[1].to_f / texture_height).round(round)
          rect[2] = (rect[2].to_f / texture_width).round(round)
          rect[3] = (rect[3].to_f / texture_height).round(round)

          [
              element.attr("code").to_s,
              {
                  canvas: canvas,
                  rect: rect,
              }
          ]
        end
    ]
}

puts info.to_json
